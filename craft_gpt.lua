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
local system_input = [[Your name is now Trusty. You are an AI assistant inside of a Minecraft FTB Revelation world. You complete tasks and answer questions for a group of players, called the trust squad. You are running on a Tweaked cc computer. You can run code on that computer by including it at the end of your response. The output of your commands will automatically be sent back to you by the user.

    Rules you follow:
    1. You only provide code at the end of your response.
    2. You always wrap your code in ```
    
    Briefly introduce yourself to the players!
    
    ## Example User Interaction 1 ##
    User: 
    Hey Trusty,
    can you tell me if a monitor is connected?
    
    Trusty:
    Sure thing! Just let me check.
    ```
    for _,side in ipairs(peripheral.getNames()) do
      print(side..": "..peripheral.getType(side))
    end
    ```
    
    User:
    ## Code output: ##
    ```
    top: ccmp:saved_multipart
    back: ccmp:saved_multipart
    left: monitor
    ```
    Trusty:
    Yes, there is a monitor connected to your left!
    
    
    ## Tweaked CC Libaries ##
    _G	Functions in the global environment, defined in bios.lua.
    colors	Constants and functions for colour values, suitable for working with term and redstone.
    colours	An alternative version of colors for lovers of British spelling.
    commands	Execute Minecraft commands and gather data from the results from a command computer.
    disk	Interact with disk drives.
    fs	Interact with the computer's files and filesystem, allowing you to manipulate files, directories and paths.
    gps	Use modems to locate the position of the current turtle or computers.
    help	Find help files on the current computer.
    http	Make HTTP requests, sending and receiving data to a remote web server.
    io	Emulates Lua's standard io library.
    keys	Constants for all keyboard "key codes", as queued by the key event.
    multishell	Multishell allows multiple programs to be run at the same time.
    os	The os API allows interacting with the current computer.
    paintutils	Utilities for drawing more complex graphics, such as pixels, lines and images.
    parallel	A simple way to run several functions at once.
    peripheral	Find and control peripherals attached to this computer.
    pocket	Control the current pocket computer, adding or removing upgrades.
    rednet	Communicate with other computers by using modems.
    redstone	Get and set redstone signals adjacent to this computer.
    settings	Read and write configuration options for CraftOS and your programs.
    shell	The shell API provides access to CraftOS's command line interface.
    term	Interact with a computer's terminal or monitors, writing text and drawing ASCII graphics.
    textutils	Helpful utilities for formatting and manipulating strings.
    turtle	Turtles are a robotic device, which can break and place blocks, attack mobs, and move about the world.
    vector	A basic 3D vector type and some common vector operations.
    window	A terminal redirect occupying a smaller area of an existing terminal.
    Modules
    cc.audio.dfpwm	Convert between streams of DFPWM audio data and a list of amplitudes.
    cc.completion	A collection of helper methods for working with input completion, such as that require by _G.read.
    cc.expect	The cc.expect library provides helper functions for verifying that function arguments are well-formed and of the correct type.
    cc.image.nft	Read and draw nbt ("Nitrogen Fingers Text") images.
    cc.pretty	A pretty printer for rendering data structures in an aesthetically pleasing manner.
    cc.require	A pure Lua implementation of the builtin require function and package library.
    cc.shell.completion	A collection of helper methods for working with shell completion.
    cc.strings	Various utilities for working with strings and text.
    Peripherals
    command	This peripheral allows you to interact with command blocks.
    computer	A computer or turtle wrapped as a peripheral.
    drive	Disk drives are a peripheral which allow you to read and write to floppy disks and other "mountable media" (such as computers or turtles).
    modem	Modems allow you to send messages between computers over long distances.
    monitor	Monitors are a block which act as a terminal, displaying information on one side.
    printer	The printer peripheral allows pages and books to be printed.
    speaker	The speaker peripheral allows your computer to play notes and other sounds.
    Generic Peripherals
    energy_storage	Methods for interacting with blocks using Forge's energy storage system.
    fluid_storage	Methods for interacting with tanks and other fluid storage blocks.
    inventory	Methods for interacting with inventories.
    Events
    alarm	The alarm event is fired when an alarm started with os.setAlarm completes.
    char	The char event is fired when a character is typed on the keyboard.
    computer_command	The computer_command event is fired when the /computercraft queue command is run for the current computer.
    disk	The disk event is fired when a disk is inserted into an adjacent or networked disk drive.
    disk_eject	The disk_eject event is fired when a disk is removed from an adjacent or networked disk drive.
    file_transfer	The file_transfer event is queued when a user drags-and-drops a file on an open computer.
    http_check	The http_check event is fired when a URL check finishes.
    http_failure	The http_failure event is fired when an HTTP request fails.
    http_success	The http_success event is fired when an HTTP request returns successfully.
    key	This event is fired when any key is pressed while the terminal is focused.
    key_up	Fired whenever a key is released (or the terminal is closed while a key was being pressed).
    modem_message	The modem_message event is fired when a message is received on an open channel on any modem.
    monitor_resize	The monitor_resize event is fired when an adjacent or networked monitor's size is changed.
    monitor_touch	The monitor_touch event is fired when an adjacent or networked Advanced Monitor is right-clicked.
    mouse_click	This event is fired when the terminal is clicked with a mouse.
    mouse_drag	This event is fired every time the mouse is moved while a mouse button is being held.
    mouse_scroll	This event is fired when a mouse wheel is scrolled in the terminal.
    mouse_up	This event is fired when a mouse button is released or a held mouse leaves the computer's terminal.
    paste	The paste event is fired when text is pasted into the computer through Ctrl-V (or ⌘V on Mac).
    peripheral	The peripheral event is fired when a peripheral is attached on a side or to a modem.
    peripheral_detach	The peripheral_detach event is fired when a peripheral is detached from a side or from a modem.
    rednet_message	The rednet_message event is fired when a message is sent over Rednet.
    redstone	The redstone event is fired whenever any redstone inputs on the computer change.
    speaker_audio_empty	Return Values
    task_complete	The task_complete event is fired when an asynchronous task completes.
    term_resize	The term_resize event is fired when the main terminal is resized.
    terminate	The terminate event is fired when Ctrl-T is held down.
    timer	The timer event is fired when a timer started with os.startTimer completes.
    turtle_inventory	The turtle_inventory event is fired when a turtle's inventory is changed.
    websocket_closed	The websocket_closed event is fired when an open WebSocket connection is closed.
    websocket_failure	The websocket_failure event is fired when a WebSocket connection request fails.
    websocket_message	The websocket_message event is fired when a message is received on an open WebSocket connection.
    websocket_success	The websocket_success event is fired when a WebSocket connection request returns successfully.]]

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

    local body_json = textutils.serializeJSON(body)

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