local pretty = require("cc.pretty")
local fun = require("fun")

local Farm = require("farm")

local farms = {
    ender_1 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_1") }),
    barley_1 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_2") }),
    wheat_1 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_3") }),
    spruce_1 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_4") }),
    spruce_2 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_5") }),
    spruce_3 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_6") }),
    spruce_4 = Farm:new({ peripheral = peripheral.wrap("forestry:farm_7") }),
}

local farm_counts = fun.tomap(fun.map(
    function(key, _) return key, {} end,
    fun.iter(farms)
))

local farm_diffs = fun.tomap(fun.map(
    function(key, _) return key, {} end,
    fun.iter(farms)
))

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
    return fun.tomap(fun.map(
        function(k, v) return k, v - (a[k] or 0) end,
        fun.iter(b)
    ))
end

local runtime = 20
local n_iters = runtime * 20

while true do
    print("Collecting data for " .. runtime .. "s...")

    for i=1,n_iters do
        local funcs = fun.totable(fun.map(
            function(key, farm)
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
            end,
            fun.iter(farms)
        ))
    
        parallel.waitForAll(table.unpack(funcs))
    end

    local farm_aggregates = fun.tomap(fun.map(
        function(key, _)
            return key, fun.reduce(
                function(acc, x)
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
                },
                fun.iter(farm_diffs[key])
            )
        end,
        fun.iter(farms)
    ))

    pretty.print(pretty.pretty(farm_aggregates))
end
