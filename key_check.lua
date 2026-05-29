local HttpService = game:GetService("HttpService")


local RENDER_URL = "https://keysystem-t9cf.onrender.com"


local source = debug.info(2, "s") or ""
local UserKey = source:match("--key%s+(%w+)")

if not UserKey or UserKey == "" then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "❌ Missing Key", Text = "Please provide a key in line 1!", Duration = 10})
    return
end


local success, HWID = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
if not success or not HWID then HWID = "Unknown_Executor_ID" end


local response
local reqSuccess = pcall(function()
    response = HttpService:GetAsync(RENDER_URL .. "/verify?key=" .. UserKey .. "&hwid=" .. HWID)
end)

if not reqSuccess then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "❌ Error", Text = "Server connection failed!", Duration = 10})
    return
end

if response == "Success" then
   
    loadstring(game:HttpGet("https://raw.githubusercontent.com/memoriesburnslow/KeySystem.lua/main/main_script.lua"))()
elseif response == "HWID_Mismatch" then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "❌ HWID Mismatch", Text = "hwid mismatch create a ticket", Duration = 10})
else
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "❌ Invalid Key", Text = "invalid key", Duration = 10})
end
