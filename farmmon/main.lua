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
                            soil_counts = diff_tables(res.soil_counts, res.soil_counts),
                            seed_counts = diff_tables(res.seed_counts, res.seed_counts),
                            output_counts = diff_tables(res.output_counts, res.output_counts),
                            fertilizer_count = 0,
                        }
                        or {
                            soil_counts = diff_tables(prev.soil_counts, res.soil_counts),
                            seed_counts = diff_tables(prev.seed_counts, res.seed_counts),
                            output_counts = diff_tables(prev.output_counts, res.output_counts),
                            fertilizer_count = res.fertilizer_count - prev.fertilizer_count,
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
            return key, fun.iter(farm_diffs[key]):reduce(
                function(acc, x)
                    -- consumables are clamped to [-Inf, 0]
                    -- outputs are clamped to [0, Inf]
                    -- this is done to ignore effects on the counts caused by items being
                    -- piped into and out of the farm
                    local res = {
                        soil_counts = sum_tables(
                            fun.tomap(fun.map(
                                function(k, v) return k, math.min(v, 0) end,
                                acc.soil_counts
                            )),
                            fun.tomap(fun.map(
                                function(k, v) return k, math.min(v, 0) end,
                                x.soil_counts
                            ))
                        ),
                        seed_counts = sum_tables(
                            fun.tomap(fun.map(
                                function(k, v) return k, math.min(v, 0) end,
                                acc.seed_counts
                            )),
                            fun.tomap(fun.map(
                                function(k, v) return k, math.min(v, 0) end,
                                x.seed_counts
                            ))
                        ),
                        output_counts = sum_tables(
                            fun.tomap(fun.map(
                                function(k, v) return k, math.max(v, 0) end,
                                acc.output_counts
                            )),
                            fun.tomap(fun.map(
                                function(k, v) return k, math.max(v, 0) end,
                                x.output_counts
                            ))
                        ),
                        fertilizer_count = math.min(acc.fertilizer_count, 0)
                            + math.min(x.fertilizer_count, 0)
                    }

                    return res
                end,
                {
                    soil_counts = {},
                    seed_counts = {},
                    output_counts = {},
                    fertilizer_count = 0,
                }
            )
        end)
        :tomap()
    
    return farm_aggregates
end

local main_frame = basalt.createFrame()
    :setMonitor("right", 0.5)
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setBorder(colors.black)

local farm_update_thread = main_frame:addThread()
farm_update_thread:start(function()
    while true do
        local farm_aggregates = calculate_farm_aggregates()
        os.queueEvent("farm_aggregates", farm_aggregates)
    end
end)

local farm_aggregate_count = 0
local function farmAggregateHandler(self, event, ...)
    if event == "farm_aggregates" then
        basalt.debug("self:getName(): " .. self:getName())
        basalt.debug("frame.left name:" .. main_frame:getObject("frame.left"):getName())

        local farm_aggregate = ...
        farm_aggregate_count = farm_aggregate_count + 1
        basalt.debug("Received 'farm_aggregates' " .. farm_aggregate_count .. " times")
        basalt.debug("spruce_1 fertilizer_count:  " .. farm_aggregate.spruce_1.fertilizer_count)
        
    end
end

basalt.setVariable("farmAggregateHandler", farmAggregateHandler)

local farm_frames = fun.iter(farms)
    :enumerate()
    :map(function(idx, key, _)
        local frame_id = "frame." .. key
        
        local parent_width, parent_height = main_frame:getSize()
        local width = math.floor(parent_width / 7)
        local height = parent_height
        local pos_x = (idx - 1) * width + 1
        local pos_y = 1

        local sub_frame = main_frame
            :addFrame(frame_id)
            :setSize(width, height)
            :setPosition(pos_x, pos_y)
            :setBackground(colors.black)
            :setForeground(colors.white)
            :setBorder(colors.black)
            :addLayout(fs.combine(base_dir, "farm_frame.xml"))
        
        local title_label = sub_frame:getObject("label.title")
        title_label:setText(key)

        return sub_frame
    end)
    :tomap()

basalt.autoUpdate()
