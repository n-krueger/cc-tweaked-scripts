local fun = require("fun")

local function soil_slots()
    return fun.range(1, 6)
end

local function seed_slots()
    return fun.range(7, 12)
end

local function output_slots()
    return fun.range(13, 20)
end

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
        function(slot) self.peripheral.getItemMeta(slot) end,
        soil_slots()
    ))
end

function Farm:list_seed()
    return fun.totable(fun.map(
        function(slot) self.peripheral.getItemMeta(slot) end,
        seed_slots()
    ))
end

function Farm:list_output()
    return fun.totable(fun.map(
        function(slot) self.peripheral.getItemMeta(slot) end,
        output_slots()
    ))
end

function Farm:get_fertilizer()
    return self.peripheral.getItemMeta(fertilizer_slot)
end

return Farm
