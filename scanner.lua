--// scan_egg.lua
--// Steal an Egg — introspection scanner
--// Place in a LocalScript inside StarterPlayerScripts. Run, then copy the
--// "=== SCAN REPORT ===" block from the Dev Console and paste it here.

--// ============================================================
--// 0. SINK
--// ============================================================
local REPORT = {}
local function say(s)
        table.insert(REPORT, tostring(s))
        print("[SCAN] " .. tostring(s))
end

local function section(title)
        table.insert(REPORT, "\n=== " .. title .. " ===")
end

--// ============================================================
--// 1. SCAN TREE
--//    Walks the DataModel for anything that looks like an egg UI.
--//    UI is usually built at runtime from clones, so we search deep
--//    and log every template / pool / remote we trip over.
--// ============================================================
local IGNORE = {
        Workspace = true, Lighting = true, ReplicatedStorage = true,
        Players = true, SoundService = true, StarterGui = true,
        StarterPack = true, StarterPlayer = true, HttpService = true,
        CoreGui = true, GuiService = true, VideoService = true,
        TextChatService = true, Teams = true, UserInputService = true,
        Chat = true, ContextActionService = true, PolicyService = true,
        TextService = true, TweenService = true, RunService = true,
        Debris = true, InsertService = true, CollectionService = true,
        Sound = true, LocalizationService = true, Application = true,
        Avatar = true, MouseBehavior = true, Tool = true, Accoutrement = true,
}

local ROOT_HINTS = {
        "Egg", "Hatch", "Pet", "Shop", "UI", "Gui", "Main", "Screen", "Menu",
}

local MAX_DEPTH = 14
local scanned = 0

local function classify(obj)
        local cn = obj.ClassName
        if cn == "RemoteEvent" or cn == "RemoteFunction" then return "REMOTE" end
        if cn == "ScreenGui" or cn == "SurfaceGui" or cn == "Frame" or cn == "ScrollingFrame" then return "GUI" end
        if cn == "Model" then return "MODEL" end
        if cn == "TextLabel" or cn == "TextButton" or cn == "TextBox" then return "TEXT" end
        return nil
end

local function search(root, depth, label)
        if depth > MAX_DEPTH then return end
        scanRoot = root
        for _, child in ipairs(root:GetChildren()) do
                scanned = scanned + 1
                local cn = child.ClassName
                local nm = tostring(child.Name)

                if not IGNORE[nm] and not IGNORE[cn] then
                        local kind = classify(child)
                        if kind then
                                say(string.format("%s[%s] %s : %s  path=%s",
                                        label, kind, nm, cn, child:GetFullName():sub(1, 120)))
                        end

                        -- egg-ish named stuff gets dumped hard
                        local lower = string.lower(nm)
                        if lower:find("egg") or lower:find("hatch") or lower:find("pet") or lower:find("reveal") then
                                say(">>> HIT: " .. nm .. " (" .. cn .. ") at " .. child:GetFullName():sub(1, 140))
                        end

                        search(child, depth + 1, label .. "  ")
                end
        end
end

say("DataModel root = " .. tostring(game:GetService("Players").LocalPlayer and PlayerGui))
section("PLAYERGUI TREE")

scanRoot = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
search(scanRoot, 0, "")

--// ============================================================
--// 2. REMOTE INVENTORY
--//    Every remote the game has, with its full path. This is the
--//    critical part: the open/hatch packet args are unknown until
--//    we see the names.
--// ============================================================
section("ALL REMOTES (full paths)")
local remotes = {}
local function collectRemotes(root, depth)
        if depth > 16 then return end
        for _, c in ipairs(root:GetChildren()) do
                if c.ClassName == "RemoteEvent" or c.ClassName == "RemoteFunction" then
                        table.insert(remotes, c)
                else
                        collectRemotes(c, depth + 1)
                end
        end
end
collectRemotes(game:GetService("ReplicatedStorage"), 0)
collectRemotes(game:GetService("Players").LocalPlayer.PlayerGui, 0)

for i, r in ipairs(remotes) do
        say(string.format("REMOTE[%d] %s : %s", i, tostring(r.Name), r:GetFullName()))
end
say("total remotes = " .. #remotes)

--// ============================================================
--// 3. KNOWN-ISH REMOTE NAME MATCHES
--//    Flag the ones that smell like egg openers.
--// ============================================================
section("SUSPECT REMOTES")
local SUSPECT = {
        "egg", "hatch", "open", "pet", "reveal", "buy", "equip", "index",
        "request", "spin", "roll", "claim", "get", "collect", "sell",
}
for _, r in ipairs(remotes) do
        local low = string.lower(r.Name)
        for _, s in ipairs(SUSPECT) do
                if low:find(s) then
                        say("SUSPECT: " .. r.Name .. " -> " .. r:GetFullName())
                        break
                end
        end
end

--// ============================================================
--// 4. GUI TEXT SCRAPE
--//    Egg UIs are TextLabels. Pull every string so we learn the
--//    currency names, egg names, and button labels.
--// ============================================================
section("GUI TEXT NODES")
local function scrapeText(root, depth)
        if depth > 14 then return end
        for _, c in ipairs(root:GetChildren()) do
                if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                        local txt = ""
                        pcall(function() txt = c.Text end)
                        if txt and #txt > 0 and #txt < 200 then
                                say(string.format("TEXT %s : %s : \"%s\"", c.ClassName, c.Name, txt))
                        end
                end
                if c:IsA("GuiObject") and c.Visible then
                        scrapeText(c, depth + 1)
                end
        end
end
scrapeText(game:GetService("Players").LocalPlayer.PlayerGui, 0)

--// ============================================================
--// 5. MODULE / REMOTE LISTENERS
--//    If a LocalScript already hooked these we can read state.
--// ============================================================
section("PLAYER STATE")
local p = game:GetService("Players").LocalPlayer
pcall(function()
        say("leaderstats:")
        for k, v in pairs(p:FindFirstChild("leaderstats") or {}) do
                say("  " .. tostring(k) .. " = " .. tostring(v and v.Value or v))
        end
end)
pcall(function()
        local function dumpAll(root, name, depth)
                if depth > 3 then return end
                say(name .. " " .. root:GetFullName() .. " : " .. root.ClassName)
                for _, c in ipairs(root:GetChildren()) do
                        if c:IsA("ValueBase") then
                                say("   ." .. tostring(c.Name) .. " = " .. tostring(c.Value))
                        else
                                dumpAll(c, "  ", depth + 1)
                        end
                end
        end
        for _, n in ipairs({"Data", "DataStore", "PlayerData", "Stats", "Inventory", "Pets", "Eggs"}) do
                local o = p:FindFirstChild(n)
                if o then dumpAll(o, "", 1) end
        end
end)

--// ============================================================
--// 6. VERSION / IDENTITY
--// ============================================================
section("GAME")
pcall(function()
        say("placeId = " .. game.PlaceId)
        say("gameId  = " .. game.GameId)
        say("jobId   = " .. game.JobId)
        say("name    = " .. game.Name)
end)

--// ============================================================
--// 7. DUMP
--// ============================================================
print("\n\n=== SCAN REPORT BEGIN ===")
print(table.concat(REPORT, "\n"))
print("=== SCAN REPORT END ===\n\n")

--// also surface in a scrollable gui if the console got truncated
pcall(function()
        local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local g = Instance.new("ScreenGui")
        g.Name = "SCANOUT"
        g.IgnoreGuiInset = true
        g.Parent = pg
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.5, 0, 0.8, 0)
        f.Position = UDim2.new(0.25, 0, 0.1, 0)
        f.BackgroundColor3 = Color3.new(0, 0, 0)
        f.BackgroundTransparency = 0.15
        f.Parent = g
        local tf = Instance.new("TextBox")
        tf.Size = UDim2.new(1, -10, 1, -10)
        tf.Position = UDim2.fromOffset(5, 5)
        tf.BackgroundTransparency = 1
        tf.TextColor3 = Color3.new(0.7, 1, 0.7)
        tf.Font = Enum.Font.Code
        tf.TextSize = 12
        tf.TextXAlignment = Enum.TextXAlignment.Left
        tf.TextYAlignment = Enum.TextYAlignment.Top
        tf.MultiLine = true
        tf.ClearTextOnFocus = false
        tf.Text = table.concat(REPORT, "\n")
        tf.Parent = f
end)
