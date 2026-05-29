local HttpService = game:GetService("HttpService")
local request = (syn and syn.request) or (http and http.request) or request or http_request
if not request then return end

local editorText = ""
if get_editor_text then
    editorText = get_editor_text()
elseif current_script then
    editorText = current_script()
end

local enteredKey = editorText:match("%-%-%s*key%s*:%s*([%w%d]+)")
if not enteredKey or enteredKey == "" then 
    return -- Kein Key eingegeben? Sofort abbrechen!
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

-- DER ULTRA-SCHUTZ: Nur wenn der Server EXAKT mit "Success" antwortet, darf es weitergehen!
if not success or not response or response.Body ~= "Success" then
    print("Zugriff verweigert oder Server offline.")
    return -- Hier bricht das Skript JETZT gnadenlos ab!
end

-- Nur wenn ALLES perfekt war, wird dein echtes Skript geladen
loadstring(game:HttpGet("https://raw.githubusercontent.com/memoriesburnslow/KeySystem.lua/main/MainScript.lua"))()
