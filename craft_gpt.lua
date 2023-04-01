print("Please enter ChatGPT API key:")
local api_key = read("l")

print("Your input:")
print(api_key)

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