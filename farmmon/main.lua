local pretty = require("cc.pretty")
local basalt = require("basalt")
local fun = require("fun")

local Farm = require("farm")

local base_dir = fs.getDir(shell.getRunningProgram())
local runtime = 10
local n_iters = runtime * 20

local color_list = fun.iter(colors)
    :map(function(k, v) return v end)
    :totable()
local function random_color()
    return color_list[math.random(#color_list)]
end

local farms = {
    ender_1 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_1") }),
    barley_1 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_2") }),
    wheat_1 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_3") }),
    spruce_1 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_4") }),
    spruce_2 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_5") }),
    spruce_3 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_6") }),
    spruce_4 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_7") }),
}

local farm_counts = fun.iter(farms)
    :map(function(key, _) return key, {} end)
    :tomap()

local farm_diffs = fun.iter(farms)
    :map(function(key, _) return key, {} end)
    :tomap()

local function sum_tables(a, b)
    local res = {}

    for k, v in pairs(a) do
        res[k] = v
    end

    for k, v in pairs(b) do
        res[k] = (res[k] or 0) + v
    end

    return res
end

local function diff_tables(a, b)
    return fun.iter(b)
        :map(function(k, v) return k, v - (a[k] or 0) end)
        :tomap()
end

local function calculate_farm_aggregates()
    for i=1,n_iters do
        local funcs = fun.iter(farms)
            :map(function(key, farm)
                return function()
                    farm:fetch()
                    
                    local res = {
                        soil_counts = farm:get_soil_counts(),
                        seed_counts = farm:get_seed_counts(),
                        output_counts = farm:get_output_counts(),
                        fertilizer_count = farm:get_fertilizer_count(),
                    }
                    farm_counts[key][i] = res
    
                    local prev = farm_counts[key][i-1]
                    local diff = prev == nil
                        and {
                            soil_diff = diff_tables(res.soil_counts, res.soil_counts),
                            seed_diff = diff_tables(res.seed_counts, res.seed_counts),
                            output_diff = diff_tables(res.output_counts, res.output_counts),
                            fertilizer_diff = 0,
                        }
                        or {
                            soil_diff = diff_tables(prev.soil_counts, res.soil_counts),
                            seed_diff = diff_tables(prev.seed_counts, res.seed_counts),
                            output_diff = diff_tables(prev.output_counts, res.output_counts),
                            fertilizer_diff = res.fertilizer_count - prev.fertilizer_count,
                        }
                    farm_diffs[key][i] = diff
                end
            end)
            :totable()
    
        -- need to parallelize because Farm:fetch() blocks for 1 tick (0.05s)
        parallel.waitForAll(table.unpack(funcs))
    end

    local farm_aggregates = fun.iter(farms)
        :map(function(key, _)
            local latest_counts = farm_counts[key][n_iters]
            local diff_aggregate = fun.iter(farm_diffs[key]):reduce(
                function(acc, x)
                    -- consumables are clamped to [-Inf, 0]
                    -- outputs are clamped to [0, Inf]
                    -- this is done to ignore effects on the counts caused by items being
                    -- piped into and out of the farm
                    local res = {
                        soil_diff = sum_tables(
                            fun.tomap(fun.map(
                                function(k, v) return k, math.min(v, 0) end,
                                acc.soil_diff
                            )),
                            fun.tomap(fun.map(
                                function(k, v) return k, math.min(v, 0) end,
                                x.soil_diff
                            ))
                        ),
                        seed_diff = sum_tables(
                            fun.tomap(fun.map(
                                function(k, v) return k, math.min(v, 0) end,
                                acc.seed_diff
                            )),
                            fun.tomap(fun.map(
                                function(k, v) return k, math.min(v, 0) end,
                                x.seed_diff
                            ))
                        ),
                        output_diff = sum_tables(
                            fun.tomap(fun.map(
                                function(k, v) return k, math.max(v, 0) end,
                                acc.output_diff
                            )),
                            fun.tomap(fun.map(
                                function(k, v) return k, math.max(v, 0) end,
                                x.output_diff
                            ))
                        ),
                        fertilizer_diff = math.min(acc.fertilizer_diff, 0)
                            + math.min(x.fertilizer_diff, 0)
                    }

                    return res
                end,
                {
                    soil_diff = {},
                    seed_diff = {},
                    output_diff = {},
                    fertilizer_diff = 0,
                }
            )

            return key, {
                soil_counts = latest_counts.soil_counts,
                seed_counts = latest_counts.seed_counts,
                output_counts = latest_counts.output_counts,
                fertilizer_count = latest_counts.fertilizer_count,
                soil_diff = diff_aggregate.soil_diff,
                seed_diff = diff_aggregate.seed_diff,
                output_diff = diff_aggregate.output_diff,
                fertilizer_diff = diff_aggregate.fertilizer_diff,
            }
        end)
        :tomap()
    
    return farm_aggregates
end

local main_frame = basalt.createFrame():setMonitor("right", 0.5)

local farm_update_thread = main_frame:addThread()
farm_update_thread:start(function()
    while true do
        local farm_aggregates = calculate_farm_aggregates()
        os.queueEvent("farm_aggregates", farm_aggregates)
    end
end)

local farm_frames = fun.iter(farms)
    :enumerate()
    :map(function(idx, key, _)
        local frame_id = "frame." .. key

        local function on_event_handler(self, event, ...)
            if event == "farm_aggregates" then
                local farm_aggregates = ...
                local aggregate = farm_aggregates[key]
                
                basalt.debug("self:getName(): " .. self:getName())
                basalt.debug("fertilizer_count:  " .. aggregate.fertilizer_count)

                local seed_count = fun.iter(aggregate.seed_counts)
                    :map(function(k, v) return v end)
                    :sum()
                local seed_label = self:getDeepObject("label.seed.data")
                seed_label:setText(tostring(seed_count))
            end
        end

        local parent_width, parent_height = main_frame:getSize()
        local width = math.floor(parent_width / 7)
        local height = parent_height
        local pos_x = (idx - 1) * width + 1
        local pos_y = 1

        local sub_frame = main_frame
            :addFrame(frame_id)
            :setSize(width, height)
            :setPosition(pos_x, pos_y)
            :onEvent(on_event_handler)
            :addLayout(fs.combine(base_dir, "farm_frame.xml"))
        
        local title_label = sub_frame:getObject("label.title")
        title_label:setText(key)

        return sub_frame
    end)
    :tomap()

basalt.autoUpdate()
