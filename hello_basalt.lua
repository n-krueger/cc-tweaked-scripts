local basalt = require("basalt")

local main = basalt.createFrame()

local clickCount = 0

local button = main:addButton()
button:setPosition(4, 4)
button:setSize(16, 3)
button:setText("Click me!")

local function buttonClick()
    clickCount = clickCount + 1
    basalt.debug("# of button clicks: " .. clickCount)
end

button:onClick(buttonClick)

basalt.autoUpdate()
