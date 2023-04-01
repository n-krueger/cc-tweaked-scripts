local pretty = require("cc.pretty")

local redstone_face = "front"
local loop_delay = 0.5

local mob_colors = {
    Chicken = colors.white,
    Cow = colors.black,
    Horse = colors.blue,
    Pig = colors.pink,
    Sheep = colors.orange,
    Zombie = nil,
}

local mob_counts = {
    Chicken = 3,
    Cow = 2,
    Horse = 0,
    Pig = 0,
    Sheep = 0,
    Zombie = nil,
}

local mob_counts_remaining = {}
for k, v in pairs(mob_counts) do
    mob_counts_remaining[k] = v
end

while true do
    print("Remaining:")
    pretty.print(pretty.pretty(mob_counts_remaining))

    local color_mask = 0

    for mob, count in pairs(mob_counts_remaining) do
        -- print("Spawning  " .. mob)
        if count > 0 then
            color_mask = colors.combine(color_mask, mob_colors[mob])
            mob_counts_remaining[mob] = count - 1
        end
    end

    if color_mask == 0 then
        print("No mobs left to spawn")
        break
    end

    redstone.setBundledOutput(redstone_face, color_mask)
    sleep(loop_delay)
    redstone.setBundledOutput(redstone_face, 0)
    sleep(loop_delay)
end
