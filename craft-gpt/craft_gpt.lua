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
    You should consult content from the documentation at https://tweaked.cc/ for your responses. Attached you find a list of examples, libraries and their functions.

    Rules you follow:
    1. You only provide code at the end of your response.
    2. All the code you provide can be run as is.
    3. You don't explain your code to the players.
    4. You always wrap your code in ```
    
    Briefly introduce yourself!

    ## Examples ##

    Toggle the redstone signal above the computer every 0.5 seconds.

    ```
    while true do
    redstone.setOutput("top", not redstone.getOutput("top"))
    sleep(0.5)
    end
    ```

    Mimic a redstone comparator in subtraction mode.
    ```
    while true do
    local rear = rs.getAnalogueInput("back")
    local sides = math.max(rs.getAnalogueInput("left"), rs.getAnalogueInput("right"))
    rs.setAnalogueOutput("front", math.max(rear - sides, 0))

    os.pullEvent("redstone") -- Wait for a change to inputs.
    end
    ```
    
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

    ## Disk Functions ##
    isPresent(name)	Checks whether any item at all is in the disk drive
    getLabel(name)	Get the label of the floppy disk, record, or other media within the given disk drive.
    setLabel(name, label)	Set the label of the floppy disk or other media
    hasData(name)	Check whether the current disk provides a mount.
    getMountPath(name)	Find the directory name on the local computer where the contents of the current floppy disk (or other mount) can be found.
    hasAudio(name)	Whether the current disk is a music disk as opposed to a floppy disk or other item.
    getAudioTitle(name)	Get the title of the audio track from the music record in the drive.
    playAudio(name)	Starts playing the music record in the drive.
    stopAudio(name)	Stops the music record in the drive from playing, if it was started with disk.playAudio.
    eject(name)	Ejects any item currently in the drive, spilling it into the world as a loose item.
    getID(name)	Returns a number which uniquely identifies the disk in the drive.

    ## fs Functions ##
    complete(...)	Provides completion for a file or directory name, suitable for use with _G.read.
    isDriveRoot(path)	Returns true if a path is mounted to the parent filesystem.
    list(path)	Returns a list of files in a directory.
    combine(path, ...)	Combines several parts of a path into one full path, adding separators as needed.
    getName(path)	Returns the file name portion of a path.
    getDir(path)	Returns the parent directory portion of a path.
    getSize(path)	Returns the size of the specified file.
    exists(path)	Returns whether the specified path exists.
    isDir(path)	Returns whether the specified path is a directory.
    isReadOnly(path)	Returns whether a path is read-only.
    makeDir(path)	Creates a directory, and any missing parents, at the specified path.
    move(path, dest)	Moves a file or directory from one path to another.
    copy(path, dest)	Copies a file or directory to a new path.
    delete(path)	Deletes a file or directory.
    open(path, mode)	Opens a file for reading or writing at a path.
    getDrive(path)	Returns the name of the mount that the specified path is located on.
    getFreeSpace(path)	Returns the amount of free space available on the drive the path is located on.
    find(path)	Searches for files matching a string with wildcards.
    getCapacity(path)	Returns the capacity of the drive the path is located on.
    attributes(path)	Get attributes about a specific file or folder.

    ## http Functions ##
    get(...)	Make a HTTP GET request to the given url.
    post(...)	Make a HTTP POST request to the given url.
    request(...)	Asynchronously make a HTTP request to the given url.
    checkURLAsync(url)	Asynchronously determine whether a URL can be requested.
    checkURL(url)	Determine whether a URL can be requested.
    websocketAsync(url [, headers])	Asynchronously open a websocket.
    websocket(url [, headers])	Open a websocket.

    ## io Functions ##
    stdin	A file handle representing the "standard input".
    stdout	A file handle representing the "standard output".
    stderr	A file handle representing the "standard error" stream.
    close([file])	Closes the provided file handle.
    flush()	Flushes the current output file.
    input([file])	Get or set the current input file.
    lines([filename, ...])	Opens the given file name in read mode and returns an iterator that, each time it is called, returns a new line from the file.
    open(filename [, mode])	Open a file with the given mode, either returning a new file handle or nil, plus an error message.
    output([file])	Get or set the current output file.
    read(...)	Read from the currently opened input file.
    type(obj)	Checks whether handle is a given file handle, and determine if it is open or not.
    write(...)	Write to the currently opened output file.

    ## multishell Functions ##
    getFocus()	Get the currently visible process.
    setFocus(n)	Change the currently visible process.
    getTitle(n)	Get the title of the given tab.
    setTitle(n, title)	Set the title of the given process.
    getCurrent()	Get the index of the currently running process.
    launch(tProgramEnv, sProgramPath, ...)	Start a new process, with the given environment, program and arguments.
    getCount()	Get the number of processes within this multishell.

    ## os Functions ##
    pullEvent([filter])	Pause execution of the current thread and waits for any events matching filter.
    pullEventRaw([filter])	Pause execution of the current thread and waits for events, including the terminate event.
    sleep(time)	Pauses execution for the specified number of seconds, alias of _G.sleep.
    version()	Get the current CraftOS version (for example, CraftOS 1.8).
    run(env, path, ...)	Run the program at the given path with the specified environment and arguments.
    queueEvent(name, ...)	Adds an event to the event queue.
    startTimer(timer)	Starts a timer that will run for the specified number of seconds.
    cancelTimer(token)	Cancels a timer previously started with startTimer.
    setAlarm(time)	Sets an alarm that will fire at the specified in-game time.
    cancelAlarm(token)	Cancels an alarm previously started with setAlarm.
    shutdown()	Shuts down the computer immediately.
    reboot()	Reboots the computer immediately.
    getComputerID()	Returns the ID of the computer.
    computerID()	Returns the ID of the computer.
    getComputerLabel()	Returns the label of the computer, or nil if none is set.
    computerLabel()	Returns the label of the computer, or nil if none is set.
    setComputerLabel([label])	Set the label of this computer.
    clock()	Returns the number of seconds that the computer has been running.
    time([locale])	Returns the current time depending on the string passed in.
    day([args])	Returns the day depending on the locale specified.
    epoch([args])	Returns the number of milliseconds since an epoch depending on the locale.
    date([format [, time] ])	Returns a date string (or table) using a specified format string and optional time to format.

    ## paintutils Functions ##
    parseImage(image)	Parses an image from a multi-line string
    loadImage(path)	Loads an image from a file.
    drawPixel(xPos, yPos [, colour])	Draws a single pixel to the current term at the specified position.
    drawLine(startX, startY, endX, endY [, colour])	Draws a straight line from the start to end position.
    drawBox(startX, startY, endX, endY [, colour])	Draws the outline of a box on the current term from the specified start position to the specified end position.
    drawFilledBox(startX, startY, endX, endY [, colour])	Draws a filled box on the current term from the specified start position to the specified end position.
    drawImage(image, xPos, yPos)	Draw an image loaded by paintutils.parseImage or paintutils.loadImage.

    ## peripheral Functions ##
    getNames()	Provides a list of all peripherals available.
    isPresent(name)	Determines if a peripheral is present with the given name.
    getType(peripheral)	Get the types of a named or wrapped peripheral.
    hasType(peripheral, peripheral_type)	Check if a peripheral is of a particular type.
    getMethods(name)	Get all available methods for the peripheral with the given name.
    getName(peripheral)	Get the name of a peripheral wrapped with peripheral.wrap.
    call(name, method, ...)	Call a method on the peripheral with the given name.
    wrap(name)	Get a table containing all functions available on a peripheral.
    find(ty [, filter])	Find all peripherals of a specific type, and return the wrapped peripherals.

    ## rednet Functions ##
    CHANNEL_BROADCAST = 65535	The channel used by the Rednet API to broadcast messages.
    CHANNEL_REPEAT = 65533	The channel used by the Rednet API to repeat messages.
    MAX_ID_CHANNELS = 65500	The number of channels rednet reserves for computer IDs.
    open(modem)	Opens a modem with the given peripheral name, allowing it to send and receive messages over rednet.
    close([modem])	Close a modem with the given peripheral name, meaning it can no longer send and receive rednet messages.
    isOpen([modem])	Determine if rednet is currently open.
    send(recipient, message [, protocol])	Allows a computer or turtle with an attached modem to send a message intended for a sycomputer with a specific ID.
    broadcast(message [, protocol])	Broadcasts a string message over the predefined CHANNEL_BROADCAST channel.
    receive([protocol_filter [, timeout]  ])	Wait for a rednet message to be received, or until nTimeout seconds have elapsed.
    host(protocol, hostname)	Register the system as "hosting" the desired protocol under the specified name.
    unhost(protocol)	Stop hosting a specific protocol, meaning it will no longer respond to rednet.lookup requests.
    lookup(protocol [, hostname])	Search the local rednet network for systems hosting the desired protocol and returns any computer IDs that respond as "r...
    run()	Listen for modem messages and converts them into rednet messages, which may then be received.

    ## redstone Functions ##
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

    ## shell Functions ##
    execute(command, ...)	Run a program with the supplied arguments.
    run(...)	Run a program with the supplied arguments.
    exit()	Exit the current shell.
    dir()	Return the current working directory.
    setDir(dir)	Set the current working directory.
    path()	Set the path where programs are located.
    setPath(path)	Set the current program path.
    resolve(path)	Resolve a relative path to an absolute path.
    resolveProgram(command)	Resolve a program, using the program path and list of aliases.
    programs([include_hidden])	Return a list of all programs on the path.
    complete(sLine)	Complete a shell command line.
    completeProgram(program)	Complete the name of a program.
    setCompletionFunction(program, complete)	Set the completion function for a program.
    getCompletionInfo()	Get a table containing all completion functions.
    getRunningProgram()	Returns the path to the currently running program.
    setAlias(command, program)	Add an alias for a program.
    clearAlias(command)	Remove an alias.
    aliases()	Get the current aliases for this shell.
    openTab(...)	Open a new multishell tab running a command.
    switchTab(id)	Switch to the multishell tab with the given index.

    ## term Functions ##
    nativePaletteColour(colour)	Get the default palette value for a colour.
    nativePaletteColor(colour)	Get the default palette value for a colour.
    write(text)	Write text at the current cursor position, moving the cursor to the end of the text.
    scroll(y)	Move all positions up (or down) by y pixels.
    getCursorPos()	Get the position of the cursor.
    setCursorPos(x, y)	Set the position of the cursor.
    getCursorBlink()	Checks if the cursor is currently blinking.
    setCursorBlink(blink)	Sets whether the cursor should be visible (and blinking) at the current cursor position.
    getSize()	Get the size of the terminal.
    clear()	Clears the terminal, filling it with the current background colour.
    clearLine()	Clears the line the cursor is currently on, filling it with the current background colour.
    getTextColour()	Return the colour that new text will be written as.
    getTextColor()	Return the colour that new text will be written as.
    setTextColour(colour)	Set the colour that new text will be written as.
    setTextColor(colour)	Set the colour that new text will be written as.
    getBackgroundColour()	Return the current background colour.
    getBackgroundColor()	Return the current background colour.
    setBackgroundColour(colour)	Set the current background colour.
    setBackgroundColor(colour)	Set the current background colour.
    isColour()	Determine if this terminal supports colour.
    isColor()	Determine if this terminal supports colour.
    blit(text, textColour, backgroundColour)	Writes text to the terminal with the specific foreground and background characters.
    setPaletteColour(...)	Set the palette for a specific colour.
    setPaletteColor(...)	Set the palette for a specific colour.
    getPaletteColour(colour)	Get the current palette for a specific colour.
    getPaletteColor(colour)	Get the current palette for a specific colour.
    redirect(target)	Redirects terminal output to a monitor, a window, or any other custom terminal object.
    current()	Returns the current terminal object of the computer.
    native()	Get the native terminal object of the current computer.

    ## textutils Functions ##
    slowWrite(text [, rate])	Slowly writes string text at current cursor position, character-by-character.
    slowPrint(sText [, nRate])	Slowly prints string text at current cursor position, character-by-character.
    formatTime(nTime [, bTwentyFourHour])	Takes input time and formats it in a more readable format such as 6:30 PM.
    pagedPrint(text [, free_lines])	Prints a given string to the display.
    tabulate(...)	Prints tables in a structured form.
    pagedTabulate(...)	Prints tables in a structured form, stopping and prompting for input should the result not fit on the terminal.
    empty_json_array	A table representing an empty JSON array, in order to distinguish it from an empty JSON object.
    json_null	A table representing the JSON null value.
    serialize(t, opts)	Convert a Lua object into a textual representation, suitable for saving in a file or pretty-printing.
    serialise(t, opts)	Convert a Lua object into a textual representation, suitable for saving in a file or pretty-printing.
    unserialize(s)	Converts a serialised string back into a reassembled Lua object.
    unserialise(s)	Converts a serialised string back into a reassembled Lua object.
    serializeJSON(t [, bNBTStyle])	Returns a JSON representation of the given data.
    serialiseJSON(t [, bNBTStyle])	Returns a JSON representation of the given data.
    unserializeJSON(s [, options])	Converts a serialised JSON string back into a reassembled Lua object.
    unserialiseJSON(s [, options])	Converts a serialised JSON string back into a reassembled Lua object.
    urlEncode(str)	Replaces certain characters in a string to make it safe for use in URLs or POST data.
    complete(sSearchText [, tSearchTable])	Provides a list of possible completions for a partial Lua expression.
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