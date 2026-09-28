--// sae_scan.lua   |   Steal an Egg - full recon scanner
--// Delta / mobile. Paste into the Delta script box and hit RUN.
--// Pre-shrunk from the HTF version: CoreGui parent, full-game GetDescendants
--// walk, egg keyword set, attribute mining, action-button detection.

local G = (getgenv and getgenv()) or _G
if G.SAE_Loaded then
        pcall(function() G.SAE_Report = nil end)
        local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        pcall(function() if pg then pg:FindFirstChild("SAE_Scan"):Destroy() end end)
end
G.SAE_Loaded = true

-- ================================================================                     -- 0. CORE
-- ================================================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui", 15)
local UIS = game:GetService("UserInputService")

local REPORT = {}
local LINES = 0
local function Add(s)
        LINES = LINES + 1
        REPORT[LINES] = tostring(s)
end

-- ================================================================
-- 1. UI  (mobile scale, Global ZIndex, PlayerGui parent)
-- ================================================================
local Z = 9000
local function mk(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        o.Parent = parent
        return o
end
local function round(o, r)
        mk("UICorner", { CornerRadius = UDim.new(0, r or 10) }, o)
end

local Gui = mk("ScreenGui", {
        Name = "SAE_Scan",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 2147483647,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
}, PG)

local Frame = mk("Frame", {
        Size = UDim2.new(0.94, 0, 0.80, 0),
        Position = UDim2.new(0.03, 0, 0.07, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0,
        Active = true,
        ZIndex = Z,
}, Gui)
round(Frame, 12)

-- topbar / drag
local Bar = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(240, 240, 245),
        BorderSizePixel = 0,
        Active = true,
        ZIndex = Z + 1,
}, Frame)
round(Bar, 12)
mk("TextLabel", {
        Size = UDim2.new(1, -46, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "STEAL AN EGG - SCANNER",
        TextColor3 = Color3.new(0, 0, 0),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Z + 2,
}, Bar)

do
        local dragging, grab, origin
        Bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Touch
                        or i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        grab = i.Position
                        origin = Frame.Position
                end
        end)
        Bar.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.Movement
                        or i.UserInputType == Enum.UserInputType.Touch) then
                        local d = i.Position - grab
                        Frame.Position = UDim2.new(
                                origin.X.Scale, origin.X.Offset + d.X,
                                origin.Y.Scale, origin.Y.Offset + d.Y)
                end
        end)
        Bar.InputEnded:Connect(function() dragging = false end)
end

local Close = mk("TextButton", {
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(1, -40, 0, 2),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        ZIndex = Z + 2,
}, Frame)
round(Close, 8)

-- status + progress
local Status = mk("TextLabel", {
        Size = UDim2.new(1, -18, 0, 26),
        Position = UDim2.new(0, 9, 0, 46),
        BackgroundTransparency = 1,
        Text = "ready",
        TextColor3 = Color3.fromRGB(150, 255, 170),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Z + 1,
}, Frame)

local BarBG = mk("Frame", {
        Size = UDim2.new(1, -18, 0, 12),
        Position = UDim2.new(0, 9, 0, 74),
        BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = Z + 1,
}, Frame)
round(BarBG, 6)
local Fill = mk("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(90, 230, 130),
        BorderSizePixel = 0,
        ZIndex = Z + 2,
}, BarBG)
round(Fill, 6)

-- output
local Box = mk("ScrollingFrame", {
        Size = UDim2.new(1, -18, 1, -168),
        Position = UDim2.new(0, 9, 0, 92),
        BackgroundColor3 = Color3.fromRGB(22, 22, 30),
        BorderSizePixel = 0,
        ScrollBarThickness = 9,
        ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ZIndex = Z + 1,
}, Frame)
round(Box, 8)

local Out = mk("TextBox", {
        Size = UDim2.new(1, -14, 0, 0),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "press SCAN...",
        PlaceholderColor3 = Color3.fromRGB(90, 90, 105),
        TextColor3 = Color3.fromRGB(190, 255, 200),
        TextSize = 12,
        Font = Enum.Font.Code,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        MultiLine = true,
        ClearTextOnFocus = false,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = Z + 2,
}, Box)

-- buttons
local BtnScan = mk("TextButton", {
        Size = UDim2.new(0.42, 0, 0, 58),
        Position = UDim2.new(0.012, 0, 1, -66),
        BackgroundColor3 = Color3.fromRGB(45, 140, 70),
        BorderSizePixel = 0,
        Text = "SCAN",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        ZIndex = Z + 2,
}, Frame)
round(BtnScan, 10)

local BtnCopy = mk("TextButton", {
        Size = UDim2.new(0.33, 0, 0, 58),
        Position = UDim2.new(0.44, 0, 1, -66),
        BackgroundColor3 = Color3.fromRGB(35, 55, 85),
        BorderSizePixel = 0,
        Text = "COPY ALL",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Active = false,
        AutoButtonColor = false,
        ZIndex = Z + 2,
}, Frame)
round(BtnCopy, 10)

local BtnMini = mk("TextButton", {
        Size = UDim2.new(0.21, 0, 0, 58),
        Position = UDim2.new(0.78, 0, 1, -66),
        BackgroundColor3 = Color3.fromRGB(70, 70, 90),
        BorderSizePixel = 0,
        Text = "HIDE",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        ZIndex = Z + 2,
}, Frame)
round(BtnMini, 10)

local Mini = mk("TextButton", {
        Size = UDim2.new(0, 160, 0, 42),
        Position = UDim2.new(0.02, 0, 0.6, 0),
        BackgroundColor3 = Color3.fromRGB(45, 140, 70),
        BorderSizePixel = 0,
        Text = "EGG SCAN",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Visible = false,
        ZIndex = Z,
}, Gui)
round(Mini, 21)
Mini.MouseButton1Click:Connect(function() Frame.Visible = true end)

Close.MouseButton1Click:Connect(function()
        Frame.Visible = false
        Mini.Visible = true
end)
BtnMini.MouseButton1Click:Connect(function()
        Frame.Visible = false
        Mini.Visible = true
end)

-- ================================================================
-- 2. HELPERS
-- ================================================================
local KW = {
        "egg", "hatch", "crack", "open", "pet", "petdex", "evolve", "evolution",
        "trade", "backpack", "inventory", "neighborhood", "school", "robin", "hood",
        "shop", "buy", "sell", "vendor", "merchant", "market", "npc", "trader",
        "stand", "booth", "stall", "dealer", "key", "chest", "crate", "shrine",
        "charm", "chicken", "monkey", "raven", "ostrich", "falcon", "dodo",
        "penguin", "turkey", "kangaroo", "deer", "dragon", "slime", "tiger",
        "bull", "horse", "toaster", "cobra", "coffin", "clown", "dice", "ghost",
        "swamp", "forest", "tundra", "savanna", "volcano", "jungle", "desert",
        "meadow", "energy", "gacha", "spin", "roll", "reveal", "spawn", "claim",
        "reward", "quest", "coin", "cash", "diamond", "gold", "level", "weight",
        "power", "health", "hunger", "thirst", "equip", "unequip", "best", "index",
        "world", "door", "teleport", "area", "zone", "country", "donation", "gift",
        "auto", "relic", "cursed", "blessed", "pristine", "transmuted", "mega",
        "golden", "rainbow",
}

local ACTION = {
        "hatch", "crack", "open", "buy", "spin", "roll", "gacha", "evolve",
        "trade", "equip", "unequip", "claim", "collect", "reveal", "incubate",
        "start", "summon", "use", "redeem", "unlock",
}

local function Hit(s)
        local l = string.lower(tostring(s))
        for i = 1, #KW do
                if string.find(l, KW[i], 1, true) then return true end
        end
        return false
end

local function Acts(s)
        local l = string.lower(tostring(s))
        for i = 1, #ACTION do
                if string.find(l, ACTION[i], 1, true) then return true end
        end
        return false
end

local function Cut(s, n)
        s = tostring(s)
        n = n or 90
        if #s > n then return s:sub(1, n - 3) .. "..." end
        return s
end

local function Path(o)
        local parts = {}
        local cur = o
        while cur and cur ~= game do
                table.insert(parts, 1, cur.Name)
                cur = cur.Parent
        end
        return table.concat(parts, " > ")
end

local function PPos(o)
        if o and (o:IsA("BasePart") or o:IsA("Model")) then
                local p = o:IsA("BasePart") and o.Position or (o.PrimaryPart and o.PrimaryPart.Position or nil)
                if p then
                        return string.format(" @ %.0f,%.0f,%.0f", p.X, p.Y, p.Z)
                end
        end
        return ""
end

local THROTTLE = 0
local function Flush()
        THROTTLE = THROTTLE + 1
        if THROTTLE % 4 == 1 or LINES < 60 then
                Out.Text = table.concat(REPORT, "\n")
                Out.CursorPosition = Vector2.new(0, 0)
        end
end
local function Prog(p, msg)
        Fill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0)
        BarBG.Visible = true
        Status.Text = msg
        Flush()
end

-- ================================================================
-- 3. SCAN
-- ================================================================
local scanning = false

local function Scan()
        local t0 = os.clock()
        REPORT = {}
        LINES = 0
        THROTTLE = 0

        Add("=== STEAL AN EGG - FULL SCAN ===")
        Add("game    : " .. tostring(game.Name))
        Add("placeId : " .. tostring(game.PlaceId))
        Add("gameId  : " .. tostring(game.GameId))
        Add("time    : " .. os.date("%Y-%m-%d %H:%M:%S"))
        Add("player  : " .. tostring(LP.Name) .. "  uid=" .. tostring(LP.UserId))
        Add("char    : " .. tostring(LP.Character and LP.Character.Name or "NONE"))
        Add("")

        -- one native call, then filter in one pass
        Prog(0.02, "enumerating game tree...")
        task.wait()
        local ALL = game:GetDescendants()
        Add("descendants total: " .. #ALL)
        Add("")

        -- ---- PHASE 1 : remotes --------------------------------
        Add("=== REMOTES (full tree) ===")
        local remotes = {}
        for i = 1, #ALL do
                if not scanning then return nil end
                local o = ALL[i]
                if o:IsA("RemoteEvent") or o:IsA("RemoteFunction")
                        or o:IsA("BindableEvent") or o:IsA("BindableFunction") then
                        remotes[#remotes + 1] = o
                end
                if i % 900 == 0 then
                        Prog(0.02 + 0.20 * (i / #ALL), "remotes... " .. i .. "/" .. #ALL)
                        task.wait()
                end
        end
        for _, r in ipairs(remotes) do
                local flag = (Acts(r.Name) and "   <<< ACTION") or (Hit(r.Name) and "  <~") or ""
                Add(string.format("[%s] %-28s %s%s",
                        r.ClassName, Cut(tostring(r.Name), 28), Cut(Path(r), 76), flag))
        end
        Add("total remotes: " .. #remotes)
        Add("")

        -- ---- PHASE 2 : action buttons -------------------------
        Add("=== ACTION BUTTONS / GUI (hatch, crack, buy, spin...) ===")
        local acts = 0
        for i = 1, #ALL do
                if not scanning then return nil end
                local o = ALL[i]
                if o:IsA("TextButton") or o:IsA("ImageButton") then
                        local txt = ""
                        if o:IsA("TextButton") then
                                pcall(function() txt = o.Text end)
                        end
                        if Acts(txt) or Acts(o.Name) then
                                acts = acts + 1
                                if acts <= 120 then
                                        local vis, act = false, false
                                        pcall(function() vis = o.Visible end)
                                        pcall(function() act = o.Active end)
                                        Add(string.format('BTN %-22s text="%s" vis=%s active=%s  %s',
                                                Cut(tostring(o.Name), 22), Cut(txt, 26), tostring(vis),
                                                tostring(act), Cut(Path(o), 60)))
                                end
                        end
                end
                if i % 900 == 0 then
                        Prog(0.22 + 0.10 * (i / #ALL), "action buttons... " .. i)
                        task.wait()
                end
        end
        Add("action buttons found: " .. acts)
        Add("")

        -- ---- PHASE 3 : attribute mining ------------------------
        Add("=== ATTRIBUTES (ItemId / Level / Power / Area / Weight) ===")
        local attrHits = 0
        for i = 1, #ALL do
                if not scanning then return nil end
                local o = ALL[i]
                if o:IsA("BasePart") or o:IsA("Model") or o:IsA("Configuration")
                        or o:IsA("ValueBase") or o:IsA("ObjectValue") or o:IsA("Tool") then
                        local ok, at = pcall(function() return o:GetAttributes() end)
                        if ok and type(at) == "table" and next(at) then
                                local keys = {}
                                for k in pairs(at) do table.insert(keys, k) end
                                table.sort(keys)
                                local interesting = false
                                for j = 1, #keys do
                                        if Hit(keys[j]) then interesting = true break end
                                end
                                if interesting or Hit(o.Name) then
                                        local parts = {}
                                        for j = 1, #keys and math.min(#keys, 12) or 0 do
                                                table.insert(parts, tostring(keys[j]) .. "=" .. Cut(at[keys[j]], 22))
                                        end
                                        attrHits = attrHits + 1
                                        if attrHits <= 250 then
                                                Add(string.format("ATTR %s  %s",
                                                        Cut(Path(o), 52), table.concat(parts, " | ")))
                                        end
                                end
                        end
                end
                if i % 700 == 0 then
                        Prog(0.32 + 0.22 * (i / #ALL), "mining attributes... " .. i)
                        task.wait()
                end
        end
        Add("attribute hits: " .. attrHits)
        Add("")

        -- ---- PHASE 4 : proximity prompts -----------------------
        Add("=== PROXIMITY PROMPTS ===")
        local pps = 0
        for i = 1, #ALL do
                if not scanning then return nil end
                local o = ALL[i]
                if o:IsA("ProximityPrompt") then
                        pps = pps + 1
                        if pps <= 150 then
                                local at, hd = "", 0
                                pcall(function() at = o.ActionText end)
                                pcall(function() hd = o.HoldDuration end)
                                Add(string.format("PP  act='%s' hold=%.1fs obj=%s  %s",
                                        Cut(at, 22), hd, Cut(o.Name, 26), Cut(Path(o), 60)))
                        end
                end
                if i % 900 == 0 then
                        Prog(0.54 + 0.08 * (i / #ALL), "prompts... " .. i)
                        task.wait()
                end
        end
        Add("total prompts: " .. pps)
        Add("")

        -- ---- PHASE 5 : NPC vendors -----------------------------
        Add("=== NPC MODELS (vendors / gacha stands) ===")
        local npcs = 0
        for i = 1, #ALL do
                if not scanning then return nil end
                local o = ALL[i]
                if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") then
                        npcs = npcs + 1
                        if npcs <= 120 then
                                local flag = Hit(o.Name) and "  <~ VENDOR?" or ""
                                Add(string.format("NPC %-26s%s%s", Cut(o.Name, 26), PPos(o), flag))
                        end
                end
                if i % 900 == 0 then
                        Prog(0.62 + 0.08 * (i / #ALL), "npcs... " .. i)
                        task.wait()
                end
        end
        Add("total npc models: " .. npcs)
        Add("")

        -- ---- PHASE 6 : workspace keyword objects ---------------
        Add("=== WORKSPACE KEYWORD OBJECTS (egg / pet / shop / key) ===")
        local kwc = 0
        for i = 1, #ALL do
                if not scanning then return nil end
                local o = ALL[i]
                if Hit(o.Name) and kwc < 260 then
                        kwc = kwc + 1
                        Add(string.format("[%s] %s%s  %s", o.ClassName, Cut(o.Name, 30),
                                PPos(o), Cut(Path(o), 54)))
                end
                if i % 900 == 0 then
                        Prog(0.70 + 0.08 * (i / #ALL), "keyword objects... " .. i)
                        task.wait()
                end
        end
        Add("keyword objects: " .. kwc)
        Add("")

        -- ---- PHASE 7 : gui text --------------------------------
        Add("=== GUI TEXT (costs, egg names, currencies) ===")
        local gt = 0
        for i = 1, #ALL do
                if not scanning then return nil end
                local o = ALL[i]
                if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
                        local ok, t = pcall(function() return o.Text end)
                        if ok and type(t) == "string" and #t > 0 and #t < 200 then
                                gt = gt + 1
                                if gt <= 300 then
                                        local vis = false
                                        pcall(function() vis = o.Visible end)
                                        Add(string.format('TXT %-20s vis=%-5s "%s"', Cut(o.Name, 20),
                                                tostring(vis), Cut(t, 70)))
                                end
                        end
                end
                if i % 900 == 0 then
                        Prog(0.78 + 0.09 * (i / #ALL), "gui text... " .. i)
                        task.wait()
                end
        end
        Add("text nodes: " .. gt)
        Add("")

        -- ---- PHASE 8 : player data ----------------------------
        Add("=== PLAYER VALUES / STATE ===")
        local function Dump(o, pre, d)
                if d > 4 then return end
                local ok, kids = pcall(function() return o:GetChildren() end)
                if not ok then return end
                for _, c in ipairs(kids) do
                        local cn = c.ClassName
                        if cn == "IntValue" or cn == "StringValue" or cn == "BoolValue"
                                or cn == "NumberValue" or cn == "ObjectValue" then
                                local v
                                pcall(function() v = c.Value end)
                                Add(pre .. tostring(c.Name) .. " = " .. Cut(v, 60))
                        else
                                Add(pre .. tostring(c.Name) .. " : " .. cn)
                                Dump(c, pre .. "  ", d + 1)
                        end
                end
        end
        for _, n in ipairs({"leaderstats", "Data", "PlayerData", "Stats", "Inventory",
                "Pets", "PetInventory", "Backpack", "GameData", "Profile", "SaveData",
                "Eggs", "Settings", "Key", "Keys", "Chests"}) do
                local o = LP:FindFirstChild(n)
                if o then
                        Add("-- " .. n)
                        Dump(o, "   ", 1)
                end
        end
        -- tool dump
        for _, container in ipairs({ LP.Character or Instance.new("Folder"), LP.Backpack }) do
                for _, t in ipairs(container:GetChildren()) do
                        if t:IsA("Tool") then
                                Add("TOOL " .. Cut(t.Name, 40) .. PPos(t:FindFirstChild("Handle") or t))
                                for _, d in ipairs(t:GetDescendants()) do
                                        if d:IsA("ValueBase") or d:IsA("Configuration") then
                                                local v = d:IsA("ValueBase") and d.Value or "?"
                                                Add("   ." .. tostring(d.Name) .. " = " .. Cut(v, 40))
                                        end
                                end
                        end
                end
        end
        Add("")

        -- ---- PHASE 9 : module scripts --------------------------
        Add("=== MODULESCRIPTS (structure map) ===")
        for i = 1, #ALL do
                if not scanning then return nil end
                local o = ALL[i]
                if o:IsA("ModuleScript") then
                        Add("MOD " .. Cut(Path(o), 84))
                end
                if i % 900 == 0 then
                        Prog(0.89 + 0.06 * (i / #ALL), "modules... " .. i)
                        task.wait()
                end
        end
        Add("")

        -- ---- PHASE 10 : getconnections ------------------------
        Add("=== REMOTE OnClientEvent CONNECTIONS ===")
        local conn = 0
        if type(getconnections) == "function" then
                for _, r in ipairs(remotes) do
                        if r:IsA("RemoteEvent") then
                                local ok, cs = pcall(getconnections, r.OnClientEvent)
                                if ok and cs and #cs > 0 then
                                        conn = conn + #cs
                                        Add(string.format("[%d] %s", #cs, Cut(Path(r), 74)))
                                end
                        end
                end
        else
                Add("(getconnections not exposed)")
        end
        Add("connections total: " .. conn)
        Add("")

        Add("=== DONE - " .. LINES .. " lines in " ..
                string.format("%.1f", os.clock() - t0) .. "s ===")
        Flush()
        return table.concat(REPORT, "\n"), LINES
end

-- ================================================================
-- 4. ACTIONS
-- ================================================================
local function DoScan()
        if scanning then return end
        scanning = true
        BtnScan.Text = "..."
        BtnScan.Active = false
        BtnCopy.Active = false
        BtnCopy.Text = "COPY"
        BtnCopy.BackgroundColor3 = Color3.fromRGB(35, 55, 85)
        REPORT = {}
        LINES = 0
        Out.Text = ""

        local ok, text, n = pcall(Scan)
        scanning = false
        BarBG.Visible = false

        if not ok or not text then
                Status.Text = "scan cancelled"
                BtnScan.Text = "SCAN"
                BtnScan.Active = true
                return
        end

        G.SAE_Report = text
        Status.Text = "done - " .. n .. " lines"
        BtnScan.Text = "RESCAN"
        BtnScan.Active = true
        BtnCopy.Active = true
        BtnCopy.Text = "COPY"
        BtnCopy.BackgroundColor3 = Color3.fromRGB(40, 100, 190)
        Out.Text = text
        Out.CursorPosition = Vector2.new(0, 0)
end

local function Clip(t)
        if type(setclipboard) == "function" then
                pcall(setclipboard, t)
                return true
        end
        return pcall(function()
                game:GetService("ClipboardService"):SetClipboard(t)
        end)
end

BtnScan.MouseButton1Click:Connect(function() DoScan() end)

BtnCopy.MouseButton1Click:Connect(function()
        if scanning then Status.Text = "still scanning..." return end
        if LINES == 0 and not G.SAE_Report then Status.Text = "press SCAN first" return end
        local t = G.SAE_Report or table.concat(REPORT, "\n")
        Out.Text = t
        task.wait(0.2)
        local wrote = false
        pcall(function()
                if type(writefile) == "function" then
                        writefile("sae_scan.txt", t)
                        wrote = true
                end
        end)
        local clipped = Clip(t)
        if clipped then
                Status.Text = "copied " .. #t .. " chars" .. (wrote and " + sae_scan.txt" or "") .. " - paste it here"
                BtnCopy.BackgroundColor3 = Color3.fromRGB(45, 160, 95)
                task.delay(1.5, function() BtnCopy.BackgroundColor3 = Color3.fromRGB(40, 100, 190) end)
        else
                Status.Text = "clip blocked - hold box, Select All, Copy"
        end
end)

-- ================================================================
-- 5. AUTO-SCAN
-- ================================================================
Status.Text = "auto-scanning in 1s..."
task.wait(1)
if G.SAE_AutoScan ~= false then
        DoScan()
end
print("[SAE Scan] ready. SCAN / COPY ALL at the bottom of the panel.")
