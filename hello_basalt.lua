local basalt = require("basalt")

local main = basalt.createFrame()

local clickCount = 0
local sensor = peripheral.wrap("right")
local n = #entities
local n_cows = 0
local n_chickens = 0


local button = main:addButton()
button:setPosition(4, 4)
button:setSize(16, 3)
button:setText("Click me!")

local function buttonClick()
    clickCount = clickCount + 1
    basalt.debug("# of button clicks: " .. clickCount)
end

local function countAnimals()
    
end

local function loadImage()
    local aImage = main:addImage():loadImage("../images/cow.jpg")
end

button:onClick(loadImage)

basalt.autoUpdate()
