local fun = require("fun")
local pretty = require("cc.pretty")

local farm_ender_1 = peripheral.wrap("forestry:farm_1")
local farm_barley_1 = peripheral.wrap("forestry:farm_2")
local farm_wheat_1 = peripheral.wrap("forestry:farm_3")
local farm_spruce_1 = peripheral.wrap("forestry:farm_4")
local farm_spruce_2 = peripheral.wrap("forestry:farm_5")
local farm_spruce_3 = peripheral.wrap("forestry:farm_6")
local farm_spruce_4 = peripheral.wrap("forestry:farm_7")

pretty.print(pretty.pretty(farm_ender_1))
