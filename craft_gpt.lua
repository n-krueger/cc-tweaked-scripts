local pretty = require("cc.pretty")

print("Please enter ChatGPT API key:")
local api_key = read("l")

local url = "https://api.openai.com/v1/chat/completions"
local body = {
    model = "gpt-3.5-turbo",
    messages = {
        {
            role = "user",
            content = "Your name is now Trusty. You are an advanced AI inside of a Minecraft world supporting the players with your vast knowledge."
        }
    }
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

if response.choices == nil then
    textutils.slowPrint(response_json)
else
    local message = response.choices
    print(type(message))
    textutils.slowPrint(message)
end