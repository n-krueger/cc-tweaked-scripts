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

function Farm:_iter_slots(slots)
    return fun.map(
        function(slot) return self.peripheral.getItemMeta(slot) end,
        slots
    )
end

function Farm:iter_soil()
    return self:_iter_slots(soil_slots())
end

function Farm:list_soil()
    return fun.totable(self:iter_soil())
end

function Farm:iter_seed()
    return self:_iter_slots(seed_slots())
end

function Farm:list_seed()
    return fun.totable(self:iter_seed())
end

function Farm:iter_output()
    return self:_iter_slots(output_slots())
end

function Farm:list_output()
    return fun.totable(self:iter_output())
end

function Farm:get_fertilizer()
    return self.peripheral.getItemMeta(fertilizer_slot)
end

return Farm
