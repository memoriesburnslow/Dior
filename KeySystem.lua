local HttpService = game:GetService("HttpService")
local request = (syn and syn.request) or (http and http.request) or request or http_request
if not request then return end

-- Liest den Key aus der ersten Zeile aus (sucht nach allem hinter "key:")
local editorText = (get_editor_text and get_editor_text()) or (current_script and current_script()) or ""
local enteredKey = editorText:match("%-%-%s*key%s*:%s*(%S+)")

if not enteredKey or enteredKey == "" then 
    print("[Key-System] Kein Key im Executor gefunden!")
    return 
end

local serverURL = "https://node7sndxpye-jpva--3000--4c73681d.local-corp.webcontainer.io/verify"
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

local success, response = pcall(function()
    return request({
        Url = serverURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({key = enteredKey, hwid = hwid})
    })
end)

-- Wenn der Server "Success" zurückgibt, laden wir dein echtes Skript
if success and response and response.Body == "Success" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/memoriesburnslow/KeySystem.lua/main/MainScript.lua"))()
else
    print("[Key-System] Zugriff verweigert! Key ist falsch oder abgelaufen.")
end
