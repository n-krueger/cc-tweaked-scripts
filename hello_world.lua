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

local backgroundColour = monitor.getBackgroundColour()
local textColour = monitor.getTextColour()

monitor.setBackgroundColour(colors.gray)
monitor.clear()
monitor.setCursorPos(0,0)

monitor.setTextColour(colors.white)
monitor.write("# mobs detected: " .. n .. "\n")
monitor.setTextColour(colors.blue)
monitor.write("# cows detected: " .. n_cows .. "\n")
monitor.setTextColour(colors.red)
monitor.write("# chickens detected: " .. n_chickens .. "\n")

-- Reset colour settings to original settings
monitor.setBackgroundColour(backgroundColour)
monitor.setTextColour(textColour)
