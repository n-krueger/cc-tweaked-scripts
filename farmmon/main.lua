local pretty = require("cc.pretty")
local fun = require("fun")

local Farm = require("farm")

local peripheral_ender_1 = peripheral.wrap("forestry:farm_1")
local farm_ender_1 = Farm:new({ peripheral = peripheral_ender_1 })

local peripheral_barley_1 = peripheral.wrap("forestry:farm_2")
local farm_barley_1 = Farm:new({ peripheral = peripheral_barley_1 })

local peripheral_wheat_1 = peripheral.wrap("forestry:farm_3")
local farm_wheat_1 = Farm:new({ peripheral = peripheral_wheat_1 })

local peripheral_spruce_1 = peripheral.wrap("forestry:farm_4")
local farm_spruce_1 = Farm:new({ peripheral = peripheral_spruce_1 })

local peripheral_spruce_2 = peripheral.wrap("forestry:farm_5")
local farm_spruce_2 = Farm:new({ peripheral = peripheral_spruce_2 })

local peripheral_spruce_3 = peripheral.wrap("forestry:farm_6")
local farm_spruce_3 = Farm:new({ peripheral = peripheral_spruce_3 })

local peripheral_spruce_4 = peripheral.wrap("forestry:farm_7")
local farm_spruce_4 = Farm:new({ peripheral = peripheral_spruce_4 })

local execution_count = 0

for i=1,100 do
    print("i=" .. i)

    print("===== Soil =====")
    pretty.print(pretty.pretty(farm_ender_1:get_soil_counts()))

    print("===== Seed =====")
    pretty.print(pretty.pretty(farm_ender_1:get_seed_counts()))

    print("===== Output =====")
    pretty.print(pretty.pretty(farm_ender_1:get_output_counts()))

    print("===== Fertilizer =====")
    pretty.print(pretty.pretty(farm_ender_1:get_fertilizer_count()))

    sleep(0.049)
end
