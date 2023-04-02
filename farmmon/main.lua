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

for i=1,100 do
    print("i=" .. i)

    local start_time = os.clock()

    local results = {}
    local funcs = fun.map(
        function(key, farm)
            return function()
                farm:fetch()
                local res = {
                    soil_counts = farm:get_soil_counts(),
                    seed_counts = farm:get_seed_counts(),
                    output_counts = farm:get_output_counts(),
                    fertilizer_count = farm:get_fertilizer_count(),
                }
                results[key] = res
            end
        end,
        fun.iter(farms)
    )

    parallel.waitForAll(funcs)
    pretty.print(pretty.pretty(results))

    local end_time = os.clock()
    print("Execution time: " .. (end_time - start_time))

    -- sleep(0.049)
end
