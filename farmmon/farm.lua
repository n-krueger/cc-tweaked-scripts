local fun = require("fun")

local soil_slots = fun.totable(fun.range(1, 6))
local seed_slots = fun.totable(fun.range(7, 12))
local output_slots = fun.totable(fun.range(13, 20))
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
    return fun.totable(fun.map(
        function(slot) self.peripheral.getItemDetail(slot) end,
        soil_slots
    ))
end

function Farm:list_seed()
    return fun.totable(fun.map(
        function(slot) self.peripheral.getItemDetail(slot) end,
        seed_slots
    ))
end

function Farm:list_output()
    return fun.totable(fun.map(
        function(slot) self.peripheral.getItemDetail(slot) end,
        output_slots
    ))
end

function Farm:get_fertilizer()
    return self.peripheral.getItemDetail(fertilizer_slot)
end

return Farm
