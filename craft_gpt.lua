local url = "https://api.openai.com/v1/chat/completions"

term.clear()
term.setCursorPos(1,1)

-- Get an API key
local api_key
local key_file, err = io.open("./gpt-key.txt", "r")
if err == nil then
    api_key = key_file:read("l")
    key_file:close()
else
    print("Please enter ChatGPT API key:")
    api_key = read("*")
end

local messages = {}

local user_input = ""
local system_input = [[Your name is now Trusty. You are an AI assistant inside of a Minecraft FTB Revelation world. You complete tasks and answer questions for a group of players, called the trust squad. You are running on a Tweaked cc computer. You can run code on that computer by including it at the end of your response. The output of your commands will automatically be sent back to you by the user.\nnRules you follow:\n1. You only provide code at the end of your response.\n2. You always wrap your code in ```\nnBriefly introduce yourself to the players!\nn## Example User Interaction 1 ##\nUser: \nHey Trusty,\ncan you tell me if a monitor is connected?\nnTrusty:\nSure thing! Just let me check.\n```\nfor _,side in ipairs(peripheral.getNames()) do\nprint(side..": "..peripheral.getType(side))\nend\n```\nnUser:\n## Code output: ##\n```\ntop: ccmp:saved_multipart\nback: ccmp:saved_multipart\nleft: monitor\n```\nTrusty:\nYes, there is a monitor connected to your left!\nnn## Tweaked CC Libaries ##\n_G	Functions in the global environment, defined in bios.lua.\ncolors	Constants and functions for colour values, suitable for working with term and redstone.\ncolours	An alternative version of colors for lovers of British spelling.\ncommands	Execute Minecraft commands and gather data from the results from a command computer.\ndisk	Interact with disk drives.\nfs	Interact with the computer's files and filesystem, allowing you to manipulate files, directories and paths.\ngps	Use modems to locate the position of the current turtle or computers.\nhelp	Find help files on the current computer.\nhttp	Make HTTP requests, sending and receiving data to a remote web server.\nio	Emulates Lua's standard io library.\nkeys	Constants for all keyboard "key codes", as queued by the key event.\nmultishell	Multishell allows multiple programs to be run at the same time.\nos	The os API allows interacting with the current computer.\npaintutils	Utilities for drawing more complex graphics, such as pixels, lines and images.\nparallel	A simple way to run several functions at once.\nperipheral	Find and control peripherals attached to this computer.\npocket	Control the current pocket computer, adding or removing upgrades.\nrednet	Communicate with other computers by using modems.\nredstone	Get and set redstone signals adjacent to this computer.\nsettings	Read and write configuration options for CraftOS and your programs.\nshell	The shell API provides access to CraftOS's command line interface.\nterm	Interact with a computer's terminal or monitors, writing text and drawing ASCII graphics.\ntextutils	Helpful utilities for formatting and manipulating strings.\nturtle	Turtles are a robotic device, which can break and place blocks, attack mobs, and move about the world.\nvector	A basic 3D vector type and some common vector operations.\nwindow	A terminal redirect occupying a smaller area of an existing terminal.\nModules\ncc.audio.dfpwm	Convert between streams of DFPWM audio data and a list of amplitudes.\ncc.completion	A collection of helper methods for working with input completion, such as that require by _G.read.\ncc.expect	The cc.expect library provides helper functions for verifying that function arguments are well-formed and of the correct type.\ncc.image.nft	Read and draw nbt ("Nitrogen Fingers Text") images.\ncc.pretty	A pretty printer for rendering data structures in an aesthetically pleasing manner.\ncc.require	A pure Lua implementation of the builtin require function and package library.\ncc.shell.completion	A collection of helper methods for working with shell completion.\ncc.strings	Various utilities for working with strings and text.\nPeripherals\ncommand	This peripheral allows you to interact with command blocks.\ncomputer	A computer or turtle wrapped as a peripheral.\ndrive	Disk drives are a peripheral which allow you to read and write to floppy disks and other "mountable media" (such as computers or turtles).\nmodem	Modems allow you to send messages between computers over long distances.\nmonitor	Monitors are a block which act as a terminal, displaying information on one side.\nprinter	The printer peripheral allows pages and books to be printed.\nspeaker	The speaker peripheral allows your computer to play notes and other sounds.\nGeneric Peripherals\nenergy_storage	Methods for interacting with blocks using Forge's energy storage system.\nfluid_storage	Methods for interacting with tanks and other fluid storage blocks.\ninventory	Methods for interacting with inventories.\nEvents\nalarm	The alarm event is fired when an alarm started with os.setAlarm completes.\nchar	The char event is fired when a character is typed on the keyboard.\ncomputer_command	The computer_command event is fired when the /computercraft queue command is run for the current computer.\ndisk	The disk event is fired when a disk is inserted into an adjacent or networked disk drive.\ndisk_eject	The disk_eject event is fired when a disk is removed from an adjacent or networked disk drive.\nfile_transfer	The file_transfer event is queued when a user drags-and-drops a file on an open computer.\nhttp_check	The http_check event is fired when a URL check finishes.\nhttp_failure	The http_failure event is fired when an HTTP request fails.\nhttp_success	The http_success event is fired when an HTTP request returns successfully.\nkey	This event is fired when any key is pressed while the terminal is focused.\nkey_up	Fired whenever a key is released (or the terminal is closed while a key was being pressed).\nmodem_message	The modem_message event is fired when a message is received on an open channel on any modem.\nmonitor_resize	The monitor_resize event is fired when an adjacent or networked monitor's size is changed.\nmonitor_touch	The monitor_touch event is fired when an adjacent or networked Advanced Monitor is right-clicked.\nmouse_click	This event is fired when the terminal is clicked with a mouse.\nmouse_drag	This event is fired every time the mouse is moved while a mouse button is being held.\nmouse_scroll	This event is fired when a mouse wheel is scrolled in the terminal.\nmouse_up	This event is fired when a mouse button is released or a held mouse leaves the computer's terminal.\npaste	The paste event is fired when text is pasted into the computer through Ctrl-V (or ⌘V on Mac).\nperipheral	The peripheral event is fired when a peripheral is attached on a side or to a modem.\nperipheral_detach	The peripheral_detach event is fired when a peripheral is detached from a side or from a modem.\nrednet_message	The rednet_message event is fired when a message is sent over Rednet.\nredstone	The redstone event is fired whenever any redstone inputs on the computer change.\nspeaker_audio_empty	Return Values\ntask_complete	The task_complete event is fired when an asynchronous task completes.\nterm_resize	The term_resize event is fired when the main terminal is resized.\nterminate	The terminate event is fired when Ctrl-T is held down.\ntimer	The timer event is fired when a timer started with os.startTimer completes.\nturtle_inventory	The turtle_inventory event is fired when a turtle's inventory is changed.\nwebsocket_closed	The websocket_closed event is fired when an open WebSocket connection is closed.\nwebsocket_failure	The websocket_failure event is fired when a WebSocket connection request fails.\nwebsocket_message	The websocket_message event is fired when a message is received on an open WebSocket connection.\nwebsocket_success	The websocket_success event is fired when a WebSocket connection request returns successfully.]]

local system_message = {
    role = "system",
    content = system_input
}
table.insert(messages, system_message)

while user_input ~= "exit" do
    -- Send chat history to ChatGPT to ask for a response.
    local body = {
        model = "gpt-3.5-turbo",
        messages = messages
    }

    local body_file = io.open("./body.json", "w")
    local body_json = textutils.serializeJSON(body)
    body_file:write(body_json)
    body_file:close()

    print("Body JSON:")
    print(body_json)

    local headers = {
        Authorization = "Bearer " .. api_key 
    }
    headers["Content-Type"] = "application/json" 
    local request, message, error_response = http.post(url, body_json, headers)
    if request == nil then
        print("Error: "..message)
        print(error_response.readAll())
    end
    local response_json = request.readAll()
    local response = textutils.unserializeJSON(response_json)
    request.close()

    -- Add response message to history and output content to user
    local message = response.choices[1].message
    local content = message.content .. ""
    message.content = message.content.gsub("\"", "\\\"")
    table.insert(messages, message) 

    term.setTextColor(colors.cyan)
    textutils.slowPrint(content)

    term.setTextColor(colors.green)
    for command in string.gmatch(content, "```[^`]+```") do
        command = command:gsub("`", "")

        local code_output = false
        local func, err = load(command)
        if func then
            local ok, res = pcall(func)
            if ok then
                if res ~= nil then
                    local command_message = {
                        role = "user",
                        content = [[
                            ## CODE OUTPUT ##
                        ]] .. textutils.serializeJSON(res)
                    }
                    table.insert(messages, command_message) 
                    print(textutils.serializeJSON(res))
                    code_output = true
                end
            else
                print("Execution error:", res)
            end
        else
            -- print("Compilation error, running as shell command. Error:", err)
            -- shell.run(command)
        end
    end

    if not code_output then
        term.setTextColor(colors.orange)
        user_input = read()
    
        -- Add new user message into the chat history.
        local user_message = {
            role = "user",
            content = user_input
        }
        table.insert(messages, user_message) 
    end
end