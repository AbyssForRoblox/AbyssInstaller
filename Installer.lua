local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedzLibV5/main/Source.Lua"))()
local baseDirectory = (shared.VapePrivate and "vapeprivate") or "vape"
local httpservice = game:GetService("HttpService")

local hm = "Waiting"
local prog = 0

local function WriteFiles(link)
    local suc, res = pcall(function()
        local gitfiles = "/"
        if link ~= "main" then gitfiles = "/"..link.."/" end
        if link == "games" then gitfiles = "/CustomModules/" end
        if link == "libraries" then gitfiles = "/Libraries/" end
        
        local apiUrl = "https://api.github.com/repos/AbyssForRoblox/AbyssVape/contents"..gitfiles
        local fileList = game:HttpGet(apiUrl)
        local decodedList = httpservice:JSONDecode(fileList)
        
        for _, file in ipairs(decodedList) do
            if file.type == "file" then
                local content = game:HttpGet(file.download_url)
                writefile(baseDirectory..gitfiles..file.name, content)
                task.wait(0.01)
                prog = prog + 1
            end
        end
    end)
    if not suc then
        hm = "Error Code 0"..math.random(0,999)..": "..res
        error(res)
    end
end

local function FetchProfiles()
    local suc, res = pcall(function()
        local profilesUrl = "https://api.github.com/repos/AbyssForRoblox/AbyssVape/contents/Profiles"
        local profilesList = game:HttpGet(profilesUrl)
        local decodedProfiles = httpservice:JSONDecode(profilesList)
        
        for _, profile in ipairs(decodedProfiles) do
            if profile.type == "file" then
                local profileContent = game:HttpGet(profile.download_url)
                writefile(baseDirectory.."/Profiles/"..profile.name, profileContent)
                task.wait(0.01)
                prog = prog + 1
            end
        end
    end)
    if not suc then
        hm = "Error Code 0"..math.random(0,999)..": "..res
        error(res)
    end
end

local Window = lib:MakeWindow({
  Title = "Abyss Vape Installer",
  SubTitle = ""
})

local Tab1 = Window:MakeTab({"Installer", ""})

local Paragraph = Tab1:AddParagraph({"Progress Monitor", "This is a Paragraph"})

Paragraph:Set("Progress: 0%, Waiting")

local butt
butt = Tab1:AddButton({"Install", function()
    makefolder("vape")
    makefolder("vape/CustomModules")
    makefolder("vape/assets")
    makefolder("vape/Libraries")
    makefolder("vape/Profiles")
    butt:Destroy()
    task.spawn(function()
        repeat
            task.wait(0.005)
            Paragraph:Set("Progress: "..prog.."%, "..hm)
        until false
    end)

    WriteFiles("main")
    hm = "Installing main files"
    for i = 0, 30 do prog = prog + 1 task.wait(0.005) end
    hm = "Installing libraries"
    WriteFiles("libraries")
    for i = 0, 20 do prog = prog + 1 task.wait(0.005) end
    hm = "Installing games"
    WriteFiles("games")
    for i = 0, 10 do prog = prog + 1 task.wait(0.005) end
    hm = "Installing assets"
    WriteFiles("assets")
    for i = 0, 10 do prog = prog + 1 task.wait(0.005) end
    hm = "Installing profiles"
    FetchProfiles()
    if prog <= 100 then
        for i = 0, 99 - prog do
            prog = prog + 1
            task.wait(0.009)
        end
    end
    local stat = "Finished!"
    task.wait(0.75)
    -- error handler
    if not isfile("vape/loader.lua") then
        stat = "Error Code 0001: Files not downloaded"
    else
        local str1 = readfile("vape/loader.lua")
        local str2 = game:HttpGet("https://raw.githubusercontent.com/AbyssForRoblox/AbyssVape/refs/heads/main/Loader.lua")
        if str1 ~= str2 then
            stat = "Error Code 0002: Files Outdated"
        end
    end
    -- error handler
    hm = stat
    if stat == "Finished!" then
        local butt2 = Tab1:AddButton({"Launch Abyss",function()
            game.CoreGui["redz Library V5"]:Destroy()
            loadfile("vape/Loader.lua")()
        end})
    end
end})
