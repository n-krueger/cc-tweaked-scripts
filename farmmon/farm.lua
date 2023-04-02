local fun = require("fun")

local soil_slots_start = 1
local soil_slots_end = 6
local function soil_slots()
    return fun.range(1, 6)
end

local seed_slots_start = 7
local seed_slots_end = 12
local function seed_slots()
    return fun.range(7, 12)
end

local output_slots_start = 13
local output_slots_end = 20
local function output_slots()
    return fun.range(13, 20)
end

local fertilizer_slot = 21

local Farm = {
    peripheral = nil,
    _items = nil
}

function Farm:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Farm:fetch()
    self._items = self.peripheral.list()
end

function Farm:_iter_slots(slots)
    return fun.map(
        function(slot) return self._items[slot] end,
        slots
    )
end

function Farm:_item_iter_counts(it)
    return fun.reduce(
        function(acc, item_meta)
            acc[item_meta.name] = (acc[item_meta.name] or 0) + item_meta.count
            return acc
        end,
        {},
        fun.filter(function(x) return x ~= nil end, it)
    )
end

function Farm:iter_soil()
    return self:_iter_slots(soil_slots())
end

function Farm:list_soil()
    return fun.totable(self:iter_soil())
end

function Farm:get_soil_counts()
    return self:_item_iter_counts(self:iter_soil())
end

function Farm:iter_seed()
    return self:_iter_slots(seed_slots())
end

function Farm:list_seed()
    return fun.totable(self:iter_seed())
end

function Farm:get_seed_counts()
    return self:_item_iter_counts(self:iter_seed())
end

function Farm:iter_output()
    return self:_iter_slots(output_slots())
end

function Farm:list_output()
    return fun.totable(self:iter_output())
end

function Farm:get_output_counts()
    return self:_item_iter_counts(self:iter_output())
end

function Farm:get_fertilizer()
    return self._items[fertilizer_slot]
end

function Farm:get_fertilizer_count()
    return self:get_fertilizer().count
end

return Farm
