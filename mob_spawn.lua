local pretty = require("cc.pretty")

local redstone_face = "front"

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
    Horse = 1,
    Pig = 1,
    Sheep = 1,
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
    sleep(0.5)
    redstone.setBundledOutput(redstone_face, 0)
end
