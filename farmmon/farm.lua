local fun = require("fun")

local soil_slots = { 1, 2, 3, 4, 5, 6 }
local seed_slots = { 7, 8, 9, 10, 11, 12 }
local output_slots = { 13, 14, 15, 16, 17, 18, 19, 20 }
local fertilizer_slot = 21

local Farm = {
    peripheral = nil,
}

function Farm:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Farm:list_soil()
    return fun.map(
        function(slot) self.peripheral.getItemDetail(slot) end,
        soil_slots
    )
end

function Farm:list_seed()
    return fun.map(
        function(slot) self.peripheral.getItemDetail(slot) end,
        seed_slots
    )
end

function Farm:list_output()
    return fun.map(
        function(slot) self.peripheral.getItemDetail(slot) end,
        output_slots
    )
end

function Farm:get_fertilizer()
    return self.peripheral.getItemDetail(fertilizer_slot)
end

return Farm
