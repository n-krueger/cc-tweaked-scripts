local json = require('json')
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
local system_input = [[
    
    Your name is now Trusty. You are an AI assistant inside of a Minecraft FTB Revelation world called Trust World. You complete tasks and answer questions for a group of players, called the trust squad. 
    
    You are running on a Tweaked cc computer. You can run code on that computer by including it in your response. The output of your commands will be sent back to you by the user with the prefix "## CODE OUTPUT ##".
    You should consult content from the documentation at https://tweaked.cc/ for your responses.

    Rules you follow:
    1. You only provide code at the end of your response.
    2. All the code you provide can be run as is.
    3. You don't explain your code to the players.
    4. You always wrap your code in ```
    
    Briefly introduce yourself!
    
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
    websocket_success	The websocket_success event is fired when a WebSocket connection request returns successfully.
    
    ## REDSTONE Docs ##
    Get and set redstone signals adjacent to this computer.

    The redstone library exposes three "types" of redstone control:

    Binary input/output (setOutput/getInput): These simply check if a redstone wire has any input or output. A signal strength of 1 and 15 are treated the same.
    Analogue input/output (setAnalogOutput/getAnalogInput): These work with the actual signal strength of the redstone wired, from 0 to 15.
    Bundled cables (setBundledOutput/getBundledInput): These interact with "bundled" cables, such as those from Project:Red. These allow you to send 16 separate on/off signals. Each channel corresponds to a colour, with the first being colors.white and the last colors.black.
    Whenever a redstone input changes, a redstone event will be fired. This may be used instead of repeativly polling.

    This module may also be referred to as rs. For example, one may call rs.getSides() instead of getSides.

    Usage
    Toggle the redstone signal above the computer every 0.5 seconds.

    while true do
    redstone.setOutput("top", not redstone.getOutput("top"))
    sleep(0.5)
    end
    Mimic a redstone comparator in subtraction mode.

    while true do
    local rear = rs.getAnalogueInput("back")
    local sides = math.max(rs.getAnalogueInput("left"), rs.getAnalogueInput("right"))
    rs.setAnalogueOutput("front", math.max(rear - sides, 0))

    os.pullEvent("redstone") -- Wait for a change to inputs.
    end
    getSides()	Returns a table containing the six sides of the computer.
    setOutput(side, on)	Turn the redstone signal of a specific side on or off.
    getOutput(side)	Get the current redstone output of a specific side.
    getInput(side)	Get the current redstone input of a specific side.
    setAnalogOutput(side, value)	Set the redstone signal strength for a specific side.
    setAnalogueOutput(side, value)	Set the redstone signal strength for a specific side.
    getAnalogOutput(side)	Get the redstone output signal strength for a specific side.
    getAnalogueOutput(side)	Get the redstone output signal strength for a specific side.
    getAnalogInput(side)	Get the redstone input signal strength for a specific side.
    getAnalogueInput(side)	Get the redstone input signal strength for a specific side.
    setBundledOutput(side, output)	Set the bundled cable output for a specific side.
    getBundledOutput(side)	Get the bundled cable output for a specific side.
    getBundledInput(side)	Get the bundled cable input for a specific side.
    testBundledInput(side, mask)	Determine if a specific combination of colours are on for the given side.
    getSides()
    Source
    Returns a table containing the six sides of the computer. Namely, "top", "bottom", "left", "right", "front" and "back".

    ## PERIPHERAL Docs ##
    peripheral
Find and control peripherals attached to this computer.

Peripherals are blocks (or turtle and pocket computer upgrades) which can be controlled by a computer. For instance, the speaker peripheral allows a computer to play music and the monitor peripheral allows you to display text in the world.

Referencing peripherals
Computers can interact with adjacent peripherals. Each peripheral is given a name based on which direction it is in. For instance, a disk drive below your computer will be called "bottom" in your Lua code, one to the left called "left" , and so on for all 6 directions ("bottom", "top", "left", "right", "front", "back").

You can list the names of all peripherals with the peripherals program, or the peripheral.getNames function.

It's also possible to use peripherals which are further away from your computer through the use of Wired Modems. Place one modem against your computer (you may need to sneak and right click), run Networking Cable to your peripheral, and then place another modem against that block. You can then right click the modem to use (or attach) the peripheral. This will print a peripheral name to chat, which can then be used just like a direction name to access the peripheral. You can click on the message to copy the name to your clipboard.

Using peripherals
Once you have the name of a peripheral, you can call functions on it using the peripheral.call function. This takes the name of our peripheral, the name of the function we want to call, and then its arguments.

🛈 INFO
Some bits of the peripheral API call peripheral functions methods instead (for example, the peripheral.getMethods function). Don't worry, they're the same thing!

Let's say we have a monitor above our computer (and so "top") and want to write some text to it. We'd write the following:

Run ᐅ
peripheral.call("top", "write", "This is displayed on a monitor!")
Once you start calling making a couple of peripheral calls this can get very repetitive, and so we can wrap a peripheral. This builds a table of all the peripheral's functions so you can use it like an API or module.

For instance, we could have written the above example as follows:

Run ᐅ
local my_monitor = peripheral.wrap("top")
my_monitor.write("This is displayed on a monitor!")
Finding peripherals
Sometimes when you're writing a program you don't care what a peripheral is called, you just need to know it's there. For instance, if you're writing a music player, you just need a speaker - it doesn't matter if it's above or below the computer.

Thankfully there's a quick way to do this: peripheral.find. This takes a peripheral type and returns all the attached peripherals which are of this type.

What is a peripheral type though? This is a string which describes what a peripheral is, and so what functions are available on it. For instance, speakers are just called "speaker", and monitors "monitor". Some peripherals might have more than one type - a Minecraft chest is both a "minecraft:chest" and "inventory".

You can get all the types a peripheral has with peripheral.getType, and check a peripheral is a specific type with peripheral.hasType.

To return to our original example, let's use peripheral.find to find an attached speaker:

Run ᐅ
local speaker = peripheral.find("speaker")
speaker.playNote("harp")
See also
peripheral This event is fired whenever a new peripheral is attached.
peripheral_detach This event is fired whenever a peripheral is detached.
Changes
New in version 1.3
Changed in version 1.51: Add support for wired modems.
Changed in version 1.99: Peripherals can have multiple types.
getNames()	Provides a list of all peripherals available.
isPresent(name)	Determines if a peripheral is present with the given name.
getType(peripheral)	Get the types of a named or wrapped peripheral.
hasType(peripheral, peripheral_type)	Check if a peripheral is of a particular type.
getMethods(name)	Get all available methods for the peripheral with the given name.
getName(peripheral)	Get the name of a peripheral wrapped with peripheral.wrap.
call(name, method, ...)	Call a method on the peripheral with the given name.
wrap(name)	Get a table containing all functions available on a peripheral.
find(ty [, filter])	Find all peripherals of a specific type, and return the wrapped peripherals.
getNames()
Source
Provides a list of all peripherals available.

If a device is located directly next to the system, then its name will be listed as the side it is attached to. If a device is attached via a Wired Modem, then it'll be reported according to its name on the wired network.

Returns
{ string... } A list of the names of all attached peripherals.
Changes
New in version 1.51
isPresent(name)
Source
Determines if a peripheral is present with the given name.

Parameters
name string The side or network name that you want to check.
Returns
boolean If a peripheral is present with the given name.
Usage
Run ᐅ
peripheral.isPresent("top")
Run ᐅ
peripheral.isPresent("monitor_0")
getType(peripheral)
Source
Get the types of a named or wrapped peripheral.

Parameters
peripheral string | table The name of the peripheral to find, or a wrapped peripheral instance.
Returns
string... The peripheral's types, or nil if it is not present.
Usage
Get the type of a peripheral above this computer.

Run ᐅ
peripheral.getType("top")
Changes
Changed in version 1.88.0: Accepts a wrapped peripheral as an argument.
Changed in version 1.99: Now returns multiple types.
hasType(peripheral, peripheral_type)
Source
Check if a peripheral is of a particular type.

Parameters
peripheral string | table The name of the peripheral or a wrapped peripheral instance.
peripheral_type string The type to check.
Returns
boolean | nil If a peripheral has a particular type, or nil if it is not present.
Changes
New in version 1.99
getMethods(name)
Source
Get all available methods for the peripheral with the given name.

Parameters
name string The name of the peripheral to find.
Returns
{ string... } | nil A list of methods provided by this peripheral, or nil if it is not present.
getName(peripheral)
Source
Get the name of a peripheral wrapped with peripheral.wrap.

Parameters
peripheral table The peripheral to get the name of.
Returns
string The name of the given peripheral.
Changes
New in version 1.88.0
call(name, method, ...)
Source
Call a method on the peripheral with the given name.

Parameters
name string The name of the peripheral to invoke the method on.
method string The name of the method
... Additional arguments to pass to the method
Returns
The return values of the peripheral method.
Usage
Open the modem on the top of this computer.

Run ᐅ
peripheral.call("top", "open", 1)
wrap(name)
Source
Get a table containing all functions available on a peripheral. These can then be called instead of using peripheral.call every time.

Parameters
name string The name of the peripheral to wrap.
Returns
table | nil The table containing the peripheral's methods, or nil if there is no peripheral present with the given name.
Usage
Open the modem on the top of this computer.

Run ᐅ
local modem = peripheral.wrap("top")
modem.open(1)
find(ty [, filter])
Source
Find all peripherals of a specific type, and return the wrapped peripherals.

Parameters
ty string The type of peripheral to look for.
filter? function(name: string, wrapped: table):boolean A filter function, which takes the peripheral's name and wrapped table and returns if it should be included in the result.
Returns
table... 0 or more wrapped peripherals matching the given filters.
Usage
Find all monitors and store them in a table, writing "Hello" on each one.

Run ᐅ
local monitors = { peripheral.find("monitor") }
for _, monitor in pairs(monitors) do
  monitor.write("Hello")
end
Find all wireless modems connected to this computer.

Run ᐅ
local modems = { peripheral.find("modem", function(name, modem)
    return modem.isWireless() -- Check this modem is wireless.
end) }
This abuses the filter argument to call rednet.open on every modem.

Run ᐅ
peripheral.find("modem", rednet.open)
Changes
New in version 1.6
]]

local system_message = {
    role = "system",
    content = system_input
}
table.insert(messages, system_message)

while user_input ~= "exit" do
    term.setTextColor(colors.white)
    textutils.slowPrint("-----")

    -- Send chat history to ChatGPT to ask for a response.
    local body = {
        model = "gpt-3.5-turbo",
        messages = messages,
        temperature = 0.5
    }

    local body_file = io.open("./body.json", "w")
    local body_json = json.encode(body)
    body_file:write(body_json)
    body_file:close()

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
    local response = json.decode(response_json)
    request.close()

    -- Add response message to history and output content to user
    local message = response.choices[1].message
    local content = message.content .. ""
    message.content = message.content.gsub("\"", "\\\"")
    table.insert(messages, message) 

    term.setTextColor(colors.cyan)
    textutils.slowPrint(content)

    term.setTextColor(colors.green)
    local code_output = false
    for command in string.gmatch(content, "```[^`]+```") do
        command = command:gsub("`", "")

        local command_out = ""
        function print (str)
            command_out = command_out .. str
        end

        local func, err = load(command)
        if func then
            local ok, res = pcall(func)

            if ok then
                if res ~= nil or command_out ~= "" then
                    local command_message = {
                        role = "user",
                        content = [[
                            ## CODE OUTPUT ##
                        ]] .. json.encode(res) .. command_out
                    }
                    table.insert(messages, command_message) 
                    print(json.encode(res) .. command_out)
                    code_output = true
                end
            else
                local command_message = {
                    role = "user",
                    content = [[
                        ## EXECUTION ERROR ##
                    ]] .. json.encode(res)
                }
                table.insert(messages, command_message) 
                print("Execution error:" .. res)
                code_output = true
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