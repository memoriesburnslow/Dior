local HttpService = game:GetService("HttpService")
local request = (syn and syn.request) or (http and http.request) or request or http_request
if not request then 
    print("[Key-System] FEHLER: Dein Executor unterstützt keine HTTP-Anfragen!")
    return 
end

local editorText = (get_editor_text and get_editor_text()) or (current_script and current_script()) or ""
local enteredKey = editorText:match("%-%-%s*key%s*:%s*(%S+)")

if not enteredKey or enteredKey == "" then 
    print("[Key-System] FEHLER: Kein Key im Executor-Tab gefunden!")
    return 
end

print("[Key-System] Gesendeter Key: " .. tostring(enteredKey))

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

-- HIER DRUCKEN WIR JETZT DIE GANZE WAHRHEIT IN DIE KONSOLE:
if not success then
    print("[Key-System] HTTP-Anfrage komplett fehlgeschlagen (pcall Error)!")
    return
end

if response then
    print("[Key-System] Server Status-Code: " .. tostring(response.StatusCode))
    print("[Key-System] Server Antwort-Inhalt: '" .. tostring(response.Body) .. "'")
else
    print("[Key-System] Server hat überhaupt keine Antwort gesendet (response ist nil)!")
end

-- Echte Überprüfung:
if response and response.Body == "Success" then
    print("[Key-System] Key KORREKT! Lade echtes Skript...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/memoriesburnslow/KeySystem.lua/main/MainScript.lua"))()
else
    print("[Key-System] BLOCKIERT: Der Server hat kein 'Success' gesendet!")
end
