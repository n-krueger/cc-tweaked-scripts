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
    
    
]]

local system_message = {
    role = "system",
    content = system_input.gsub("n", " ")
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