print("Let's detect some mobs!")

local sensor = peripheral.wrap("right")
local entities = sensor.sense()
local n = #entities

local n_cows = 0
local n_chickens = 0

for i, e in ipairs(entities) do
    if e.name == "Cow" then
        n_cows = n_cows + 1    
    end
    if e.name == "Chicken" then
        n_chickens = n_chickens + 1
    end
end

print("# cows detected: " .. n_cows)
print("# chickens detected: " .. n_chickens)

local monitor = peripheral.wrap("left")
monitor.setBackgroundColor(colors.magenta)
monitor.blit("# mobs detected: " .. n, colors.white, colors.black)
monitor.blit("# cows detected: " .. n_cows, colors.brown, colors.black)
monitor.blit("# chickens detected: " .. n_chickens, colors.red, colors.black)
