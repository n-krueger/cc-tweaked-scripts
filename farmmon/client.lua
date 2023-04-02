local basalt = require("libs.basalt")
local fun = require("libs.fun")

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

local frame_width, frame_height = main_frame:getSize()
local farm_frame_width = 26
local farm_frame_height = 16

local n_cols = math.floor(frame_width / farm_frame_width)
local n_rows = math.ceil(#farms / n_cols)

local farm_frames = fun.iter(farms)
    :enumerate()
    :map(function(idx, key, _)
        local col_idx = (idx - 1) % n_cols + 1
        local row_idx = math.floor((idx - 1) / n_rows) + 1
        local frame_id = "frame." .. key

        local indicators = {}
        local indicator_idx = 1

        local function on_event_handler(self, event, ...)
            if event == "farm_aggregates" then
                local farm_aggregates = ...
                local aggregate = farm_aggregates[key]
                
                local content_frame = self:getObject("frame.content")
                basalt.debug("content_frame:getName(): " .. content_frame:getName())

                -- delete old indicators
                while (indicator_idx > 1) do
                    content_frame:removeObject(indicators[indicator_idx])
                    indicators[indicator_idx] = nil
                    indicator_idx = indicator_idx - 1
                end

                local fertilizer_count = aggregate.fertilizer_count
                local fertilizer_indicator = content_frame:addFrame()
                    :setSize(farm_frame_width, 2)
                    :setPosition(2, (indicator_idx - 1) * 2 + 2)
                    :setBackground(colors.black)
                    :setForeground(colors.white)
                    :addLayout(fs.combine(base_dir, "indicator_frame.xml"))
                indicators[indicator_idx] = fertilizer_indicator
                indicator_idx = indicator_idx + 1

                local fertilizer_label_title = fertilizer_indicator:getObject("label.title")
                fertilizer_label_title:setText("Fertilizer")
                
                local fertilizer_label_data = fertilizer_indicator:getObject("label.data")
                fertilizer_label_data:setText(tostring(fertilizer_count))
                
                local fertilizer_progressbar = fertilizer_indicator:getObject("progressbar")
                fertilizer_progressbar:setProgress((fertilizer_count / 64) * 100)

                local indicator_iterator = fun.zip(
                    fun.iter({ "soil", "seed", "ouptut" }),
                    fun.iter({ aggregate.soil_counts, aggregate.seed_counts, aggregate.output_counts }),
                    fun.iter({ 6 * 64, 6 * 64, 8 * 64 })
                )
                indicator_iterator:each(function(key, counts, max_count)
                    fun.iter(counts):each(function(item_name, count)
                        local indicator = content_frame:addFrame()
                            :setSize(farm_frame_width, 2)
                            :setPosition(2, (indicator_idx - 1) * 2 + 2)
                            :setBackground(colors.black)
                            :setForeground(colors.white)
                            :addLayout(fs.combine(base_dir, "indicator_frame.xml"))
                        indicators[indicator_idx] = indicator
                        indicator_idx = indicator_idx + 1

                        basalt.debug(item_name)
                        local label_title = indicator:getObject("label.title")
                        label_title:setText(string.format("%s - %s", key, item_name))

                        local label_data = indicator:getObject("label.data")
                        label_data:setText(string.format("%3d/%3d", count, max_count))

                        local progressbar = indicator:getObject("progressbar")
                        progressbar:setProgress((count / max_count) * 100)
                    end)
                end)
            end
        end

        local pos_x = (col_idx - 1) * farm_frame_width + 1
        local pos_y = (row_idx - 1) * farm_frame_height + 1

        local sub_frame = main_frame
            :addFrame(frame_id)
            :setSize(farm_frame_width, farm_frame_height)
            :setPosition(pos_x, pos_y)
            :onEvent(on_event_handler)
            :addLayout(fs.combine(base_dir, "farm_frame.xml"))
        
        local title_label = sub_frame:getObject("label.title")
        title_label:setText(key)

        return sub_frame
    end)
    :tomap()

basalt.autoUpdate()
