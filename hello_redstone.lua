print("Enabling Lamps")

local colorMask = colors.combine(colors.black)
redstone.setBundledOutput("front", colorMask)
sleep(0.5)
redstone.setBundledOutput("front", 0)
