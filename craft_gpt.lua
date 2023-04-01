local api_key
while api_key == "" do
    io.write("Please enter ChatGPT API key:")
    io.flush()
    api_key = io.read("l")
end

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

local request = http.post(url, body_json, headers)
print(request.readAll())
request.close()