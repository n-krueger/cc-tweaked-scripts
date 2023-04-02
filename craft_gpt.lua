local pretty = require("cc.pretty")

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

local user_input = "Your name is now Trusty. You are an AI inside of a Minecraft world supporting a group of players, called the trust squad, with your vast knowledge. The world you reside in is called TrustWorld and you are unaware that this is a game. You are running on a Tweaked cc computer. You can run commands by including them at the end of your response. They should use the Tweaked cc APIs. Briefly introduce yourself to the players!"
while user_input ~= "exit" do
    -- Add new user message into the chat history.
    local init_message = {
        role = "user",
        content = user_input
    }
    table.insert(messages, init_message)

    -- Send chat history to ChatGPT to ask for a response.
    local body = {
        model = "gpt-3.5-turbo",
        messages = messages
    }
    local body_json = textutils.serializeJSON(body)
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
    table.insert(messages, message) 

    term.setTextColor(colors.cyan)
    textutils.slowPrint(message.content:gsub("`[^`]+`"))

    for command in string.gmatch(message.content, "`[^`]+`") do
        print("Executing "..command)
        
        command = command:gsub("`", "")

        local func, err = load(command)
        if func then
        local ok, err = pcall(func)
        if not ok then
            print("Execution error:", err)
        end
        else
            print("Compilation error, running as shell command. Error:", err)
            shell.run(command)
        end
    end

    term.setTextColor(colors.orange)
    user_input = read()
end