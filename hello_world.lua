print("Let's detect some mobs!")

local sensor = peripheral.wrap("right")
local entities = sensor.sense()
local n = #entities

print("# mobs detected: " + n)