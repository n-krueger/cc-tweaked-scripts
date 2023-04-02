local fun = require("libs.fun")
local Farm = require("farm")

local moving_average_duration = 60
local n_iters = moving_average_duration * 20
local protocol = "farmmon"

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

local function calculate_farm_aggregates(i)
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

    local farm_aggregates = fun.iter(farms)
        :map(function(key, _)
            local latest_counts = farm_counts[key][i]
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

print("Starting FarmMon Server")
print(string.format("moving_average_duration = %ds", moving_average_duration))
print(string.format("n_iters = %d", n_iters))
print(string.format("protocol = %s", protocol))

rednet.open("left")

fun.range(1, n_iters):cycle():each(function(i)
    local farm_aggregates = calculate_farm_aggregates(i)
    rednet.broadcast(farm_aggregates, protocol)
end)
