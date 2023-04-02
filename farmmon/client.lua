local basalt = require("basalt")
local fun = require("fun")

local base_dir = fs.getDir(shell.getRunningProgram())
local protocol = "farmmon"
local farms = {
    "ender_1",
    "barley_1",
    "wheat_1",
    "spruce_1",
    "spruce_2",
    "spruce_3",
    "spruce_4",
}

-- open all connected modems for rednet
peripheral.find("modem", rednet.open)

local main_frame = basalt.createFrame():setMonitor("right", 0.5)
local farm_update_thread = main_frame:addThread()
farm_update_thread:start(function()
    while true do
        local src_id, farm_aggregates = rednet.receive(protocol)

        basalt.debug(string.format("Got message from %d", src_id))
        os.queueEvent("farm_aggregates", farm_aggregates)
    end
end)

local farm_frames = fun.iter(farms)
    :enumerate()
    :map(function(idx, key, _)
        local frame_id = "frame." .. key

        local function on_event_handler(self, event, ...)
            if event == "farm_aggregates" then
                local farm_aggregates = ...
                local aggregate = farm_aggregates[key]
                
                basalt.debug("self:getName(): " .. self:getName())
                basalt.debug("fertilizer_count:  " .. aggregate.fertilizer_count)

                local soil_count = fun.iter(aggregate.soil_counts)
                    :map(function(k, v) return v end)
                    :sum()
                local soil_perc = (soil_count / (6 * 64)) * 100
                local soil_label = self:getDeepObject("label.soil.data")
                soil_label:setText(tostring(soil_count))
                local soil_progressbar = self:getDeepObject("progressbar.soil")
                soil_progressbar:setProgress(soil_perc)

                local seed_count = fun.iter(aggregate.seed_counts)
                    :map(function(k, v) return v end)
                    :sum()
                local seed_perc = (seed_count / (6 * 64)) * 100
                local seed_label = self:getDeepObject("label.seed.data")
                seed_label:setText(tostring(seed_count))
                local seed_progressbar = self:getDeepObject("progressbar.seed")
                seed_progressbar:setProgress(seed_perc)

                local fertilizer_count = aggregate.fertilizer_count
                local fertilizer_perc = (fertilizer_count / 64) * 100
                local fertilizer_label = self:getDeepObject("label.fertilizer.data")
                fertilizer_label:setText(tostring(fertilizer_count))
                local fertilizer_progressbar = self:getDeepObject("progressbar.fertilizer")
                fertilizer_progressbar:setProgress(fertilizer_perc)
            end
        end

        local parent_width, parent_height = main_frame:getSize()
        local width = math.floor(parent_width / 7)
        local height = parent_height
        local pos_x = (idx - 1) * width + 1
        local pos_y = 1

        local sub_frame = main_frame
            :addFrame(frame_id)
            :setSize(width, height)
            :setPosition(pos_x, pos_y)
            :onEvent(on_event_handler)
            :addLayout(fs.combine(base_dir, "farm_frame.xml"))
        
        local title_label = sub_frame:getObject("label.title")
        title_label:setText(key)

        return sub_frame
    end)
    :tomap()

basalt.autoUpdate()
