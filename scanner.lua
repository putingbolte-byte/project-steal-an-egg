--// sae_scan.lua  v2  |  Steal an Egg - resumable full recon
--// Delta / mobile.  Survives PlayerGui wipes, resumes where it stopped,
--// chunked clipboard for big reports.

local G = (getgenv and getgenv()) or _G
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- ================================================================
-- 0. PERSISTENT STATE  (survives gui destruction / re-execution)                       -- ================================================================
local S = G.SAE_State
if type(S) ~= "table" then                                                                      S = {
                lines = {},
                n = 0,
                phase = 1,
                idx = 1,
                scanning = false,
                done = false,
                chunk = 1500,
                remotes = {},
                summary = {},
                t0 = os.clock(),
                ALL = nil,
                total = 0,
        }
        G.SAE_State = S
end
local CH = S.chunk

local function Add(s)
        S.n = S.n + 1
        S.lines[S.n] = tostring(s)
end
local function Summ(s)
        S.summary[#S.summary + 1] = tostring(s)
end

-- ================================================================
-- 1. UI  (rebuildable - call BuildUI again any time)
-- ================================================================
local Gui = nil
local T = {}   -- ui refs
local Driver, CopyStep, SaveFile

local Z = 9000
local function mk(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        o.Parent = parent
        return o
end
local function round(o, r) mk("UICorner", { CornerRadius = UDim.new(0, r or 10) }, o) end

local function BuildUI()
        local pg = LP:WaitForChild("PlayerGui", 10)
        if not pg then return false end
        pcall(function() if pg:FindFirstChild("SAE_Scan") then pg:FindFirstChild("SAE_Scan"):Destroy() end end)

        Gui = mk("ScreenGui", {
                Name = "SAE_Scan",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                DisplayOrder = 2147483647,
                ZIndexBehavior = Enum.ZIndexBehavior.Global,
        }, pg)

        local Frame = mk("Frame", {
                Size = UDim2.new(0.94, 0, 0.80, 0),
                Position = UDim2.new(0.03, 0, 0.07, 0),
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                BorderSizePixel = 0, Active = true, ZIndex = Z,
        }, Gui)
        round(Frame, 12)

        local Bar = mk("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Color3.fromRGB(240, 240, 245),
                BorderSizePixel = 0, Active = true, ZIndex = Z + 1,
        }, Frame)
        round(Bar, 12)
        mk("TextLabel", {
                Size = UDim2.new(1, -46, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = "STEAL AN EGG - SCANNER",
                TextColor3 = Color3.new(0, 0, 0), TextSize = 15,
                Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = Z + 2,
        }, Bar)

        do
                local dragging, grab, origin
                Bar.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.Touch
                                or i.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = true; grab = i.Position; origin = Frame.Position
                        end
                end)
                Bar.InputChanged:Connect(function(i)
                        if dragging and (i.UserInputType == Enum.UserInputType.Movement
                                or i.UserInputType == Enum.UserInputType.Touch) then
                                local d = i.Position - grab
                                Frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X,
                                        origin.Y.Scale, origin.Y.Offset + d.Y)
                        end
                end)
                Bar.InputEnded:Connect(function() dragging = false end)
        end

        local Close = mk("TextButton", {
                Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(1, -40, 0, 2),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 0,
                Text = "X", TextColor3 = Color3.new(1, 1, 1), TextSize = 17,
                Font = Enum.Font.GothamBold, ZIndex = Z + 2,
        }, Frame)
        round(Close, 8)

        T.Status = mk("TextLabel", {
                Size = UDim2.new(1, -18, 0, 30), Position = UDim2.new(0, 9, 0, 46),
                BackgroundTransparency = 1, Text = "ready",
                TextColor3 = Color3.fromRGB(150, 255, 170), TextSize = 14,
                Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true, ZIndex = Z + 1,
        }, Frame)

        T.BarBG = mk("Frame", {
                Size = UDim2.new(1, -18, 0, 12), Position = UDim2.new(0, 9, 0, 78),
                BackgroundColor3 = Color3.fromRGB(35, 35, 45), BorderSizePixel = 0,
                Visible = false, ZIndex = Z + 1,
        }, Frame)
        round(T.BarBG, 6)
        T.Fill = mk("Frame", {
                Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(90, 230, 130),
                BorderSizePixel = 0, ZIndex = Z + 2,
        }, T.BarBG)
        round(T.Fill, 6)

        T.Box = mk("ScrollingFrame", {
                Size = UDim2.new(1, -18, 1, -168), Position = UDim2.new(0, 9, 0, 96),
                BackgroundColor3 = Color3.fromRGB(22, 22, 30), BorderSizePixel = 0,
                ScrollBarThickness = 9, ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140),
                AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = Z + 1,
        }, Frame)
        round(T.Box, 8)

        T.Out = mk("TextBox", {
                Size = UDim2.new(1, -14, 0, 0), Position = UDim2.new(0, 7, 0, 7),
                BackgroundTransparency = 1, Text = "",
                PlaceholderText = "press SCAN...", PlaceholderColor3 = Color3.fromRGB(90, 90, 105),
                TextColor3 = Color3.fromRGB(190, 255, 200), TextSize = 12,
                Font = Enum.Font.Code, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
                MultiLine = true, ClearTextOnFocus = false,
                AutomaticSize = Enum.AutomaticSize.Y, ZIndex = Z + 2,
        }, T.Box)

        local function btn(x, w, col, txt)
                local b = mk("TextButton", {
                        Size = UDim2.new(w, 0, 0, 56), Position = UDim2.new(x, 0, 1, -64),
                        BackgroundColor3 = col, BorderSizePixel = 0, Text = txt,
                        TextColor3 = Color3.new(1, 1, 1), TextSize = 15,
                        Font = Enum.Font.GothamBold, ZIndex = Z + 2,
                }, Frame)
                round(b, 10)
                return b
        end

        T.Scan = btn(0.010, 0.30, Color3.fromRGB(45, 140, 70), "SCAN")
        T.Copy = btn(0.320, 0.32, Color3.fromRGB(35, 55, 85), "COPY")
        T.File = btn(0.650, 0.22, Color3.fromRGB(70, 90, 140), "FILE")
        T.Hide = btn(0.880, 0.11, Color3.fromRGB(70, 70, 90), "-")
        T.Copy.Active = false
        T.Copy.AutoButtonColor = false
        T.File.Active = false
        T.File.AutoButtonColor = false

        T.Mini = mk("TextButton", {
                Size = UDim2.new(0, 170, 0, 42), Position = UDim2.new(0.02, 0, 0.6, 0),
                BackgroundColor3 = Color3.fromRGB(45, 140, 70), BorderSizePixel = 0,
                Text = "EGG SCAN", TextColor3 = Color3.new(1, 1, 1), TextSize = 15,
                Font = Enum.Font.GothamBold, Visible = false, ZIndex = Z,
        }, Gui)
        round(T.Mini, 21)
        T.Mini.MouseButton1Click:Connect(function() Frame.Visible = true end)

        Close.MouseButton1Click:Connect(function() Frame.Visible = false T.Mini.Visible = true end)
        T.Hide.MouseButton1Click:Connect(function() Frame.Visible = false T.Mini.Visible = true end)

        T.Scan.MouseButton1Click:Connect(function() Driver() end)
        T.Copy.MouseButton1Click:Connect(function() CopyStep() end)
        T.File.MouseButton1Click:Connect(function() SaveFile() end)

        return true
end

-- ================================================================
-- 2. UI PUSH  (safe when gui is gone)
-- ================================================================
local tick = 0
local function Push()
        if not T.Status then return end
        tick = tick + 1
        if tick % 2 ~= 0 and S.scanning then return end
        pcall(function()
                T.Out.Text = table.concat(S.lines, "\n")
                T.Out.CursorPosition = Vector2.new(0, 0)
        end)
end

local function Say(msg, col)
        if not T.Status then return end
        pcall(function()
                T.Status.Text = msg
                if col then T.Status.TextColor3 = col end
        end)
end

-- ================================================================
-- 3. SCAN ENGINE  (resumable, budgeted chunks)
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
        "relic", "cursed", "blessed", "pristine", "transmuted", "mega", "golden",
        "rainbow", "secret", "exclusive", "common", "uncommon", "rare", "epic",
        "legendary", "mythic", "divine", "godlike",
}
local ACTION = {
        "hatch", "crack", "open", "buy", "spin", "roll", "gacha", "evolve",
        "trade", "equip", "unequip", "claim", "collect", "reveal", "incubate",
        "start", "summon", "use", "redeem", "unlock", "hatchmultiple", "auto",
}
local function Hit(s)
        local l = string.lower(tostring(s))
        for i = 1, #KW do if string.find(l, KW[i], 1, true) then return true end end
        return false
end
local function Acts(s)
        local l = string.lower(tostring(s))
        for i = 1, #ACTION do if string.find(l, ACTION[i], 1, true) then return true end end
        return false
end
local function Cut(s, n)
        s = tostring(s) n = n or 90
        if #s > n then return s:sub(1, n - 3) .. "..." end
        return s
end
local function PathOf(o)
        local parts, cur = {}, o
        while cur and cur ~= game do table.insert(parts, 1, cur.Name) cur = cur.Parent end
        return table.concat(parts, " > ")
end
local function PPos(o)
        if o and o:IsA("BasePart") then
                local p = o.Position
                return string.format(" @ %.0f,%.0f,%.0f", p.X, p.Y, p.Z)
        end
        return ""
end

local function PhRemotes(from)
        local A = S.ALL
        local j = from
        while j <= #A and j - from < CH do
                local o = A[j]
                if o:IsA("RemoteEvent") or o:IsA("RemoteFunction")
                        or o:IsA("BindableEvent") or o:IsA("BindableFunction") then
                        S.remotes[#S.remotes + 1] = o
                end
                j = j + 1
        end
        return j, 0.02, "remotes " .. math.min(j, #A) .. "/" .. #A
end

local function PhButtons(from)
        local A = S.ALL
        local j = from
        while j <= #A and j - from < CH do
                local o = A[j]
                if o:IsA("TextButton") or o:IsA("ImageButton") then
                        local txt = ""
                        if o:IsA("TextButton") then pcall(function() txt = o.Text end) end
                        if Acts(txt) or Acts(o.Name) then
                                local vis, act = false, false
                                pcall(function() vis = o.Visible end)
                                pcall(function() act = o.Active end)
                                S.btns = (S.btns or 0) + 1
                                if S.btns <= 140 then
                                        local line = string.format('BTN %-20s text="%s" vis=%s act=%s  %s',
                                                Cut(o.Name, 20), Cut(txt, 24), tostring(vis), tostring(act), Cut(PathOf(o), 52))
                                        Add(line)
                                        Summ("BUTTON| " .. line)
                                end
                        end
                end
                j = j + 1
        end
        return j, 0.24, "action buttons " .. math.min(j, #A) .. "/" .. #A
end

local function PhAttrs(from)
        local A = S.ALL
        local j = from
        while j <= #A and j - from < CH do
                local o = A[j]
                if o:IsA("BasePart") or o:IsA("Model") or o:IsA("Configuration")
                        or o:IsA("ValueBase") or o:IsA("Tool") then
                        local ok, at = pcall(function() return o:GetAttributes() end)
                        if ok and type(at) == "table" and next(at) then
                                local keys = {}
                                for k in pairs(at) do table.insert(keys, k) end
                                table.sort(keys)
                                local want = Hit(o.Name)
                                for i = 1, #keys do
                                        if Hit(keys[i]) then want = true break end
                                end
                                if want then
                                        local parts = {}
                                        for i = 1, math.min(#keys, 10) do
                                                table.insert(parts, tostring(keys[i]) .. "=" .. Cut(at[keys[i]], 20))
                                        end
                                        local line = string.format("ATTR %s  %s", Cut(PathOf(o), 46), table.concat(parts, " | "))
                                        S.attrs = (S.attrs or 0) + 1
                                        if S.attrs <= 300 then
                                                Add(line)
                                                if S.attrs <= 60 then Summ("ATTR| " .. line) end
                                        end
                                end
                        end
                end
                j = j + 1
        end
        return j, 0.38, "attributes " .. math.min(j, #A) .. "/" .. #A
end

local function PhPrompts(from)
        local A = S.ALL
        local j = from
        while j <= #A and j - from < CH do
                local o = A[j]
                if o:IsA("ProximityPrompt") then
                        local at, hd = "", 0
                        pcall(function() at = o.ActionText end)
                        pcall(function() hd = o.HoldDuration end)
                        local line = string.format("PP  act='%s' hold=%.1fs obj=%s  %s",
                                Cut(at, 20), hd, Cut(o.Name, 24), Cut(PathOf(o), 54))
                        Add(line)
                        if (S.pp or 0) < 100 then Summ("PROMPT| " .. line) end
                        S.pp = (S.pp or 0) + 1
                end
                j = j + 1
        end
        return j, 0.60, "prompts " .. math.min(j, #A) .. "/" .. #A
end

local function PhNPCs(from)
        local A = S.ALL
        local j = from
        while j <= #A and j - from < CH do
                local o = A[j]
                if o:IsA("Model") then
                        local ok, h = pcall(function() return o:FindFirstChildOfClass("Humanoid") end)
                        if ok and h then
                                local line = string.format("NPC %-24s%s%s", Cut(o.Name, 24), PPos(o), Hit(o.Name) and "  <~ VENDOR" or "")
                                Add(line)
                                if (S.npc or 0) < 80 then Summ("NPC| " .. line) end
                                S.npc = (S.npc or 0) + 1
                        end
                end
                j = j + 1
        end
        return j, 0.68, "npcs " .. math.min(j, #A) .. "/" .. #A
end

local function PhKeyword(from)
        local A = S.ALL
        local j = from
        while j <= #A and j - from < CH do
                local o = A[j]
                if Hit(o.Name) and (S.kw or 0) < 320 then
                        S.kw = S.kw + 1
                        local line = string.format("[%s] %s%s  %s", o.ClassName, Cut(o.Name, 26), PPos(o), Cut(PathOf(o), 48))
                        Add(line)
                        if S.kw <= 50 then Summ("OBJ| " .. line) end
                end
                j = j + 1
        end
        return j, 0.76, "keyword objects " .. math.min(j, #A) .. "/" .. #A
end

local function PhText(from)
        local A = S.ALL
        local j = from
        while j <= #A and j - from < CH do
                local o = A[j]
                if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
                        local ok, t = pcall(function() return o.Text end)
                        if ok and type(t) == "string" and #t > 0 and #t < 180 then
                                local vis = false
                                pcall(function() vis = o.Visible end)
                                local line = string.format('TXT %-18s vis=%-5s "%s"', Cut(o.Name, 18), tostring(vis), Cut(t, 64))
                                Add(line)
                                if (S.txt or 0) < 90 then Summ("TEXT| " .. line) end
                                S.txt = (S.txt or 0) + 1
                        end
                end
                j = j + 1
        end
        return j, 0.84, "gui text " .. math.min(j, #A) .. "/" .. #A
end

local function PhModules(from)
        local A = S.ALL
        local j = from
        while j <= #A and j - from < CH do
                local o = A[j]
                if o:IsA("ModuleScript") then
                        Add("MOD " .. Cut(PathOf(o), 80))
                        if (S.mod or 0) < 60 then Summ("MOD| " .. Cut(PathOf(o), 70)) end
                        S.mod = (S.mod or 0) + 1
                end
                j = j + 1
        end
        return j, 0.90, "modules " .. math.min(j, #A) .. "/" .. #A
end

local PHASES = {
        PhRemotes, PhButtons, PhAttrs, PhPrompts, PhNPCs, PhKeyword, PhText, PhModules,
}

local function PlayerData()
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
                                local line = pre .. tostring(c.Name) .. " = " .. Cut(v, 56)
                                Add(line)
                                if d <= 2 then Summ("DATA| " .. line) end
                        else
                                Add(pre .. tostring(c.Name) .. " : " .. cn)
                                Dump(c, pre .. "  ", d + 1)
                        end
                end
        end
        for _, n in ipairs({"leaderstats", "Data", "PlayerData", "Stats", "Inventory",
                "Pets", "PetInventory", "Backpack", "GameData", "Profile", "SaveData",
                "Eggs", "Settings", "Key", "Keys", "Chests", "Stats2"}) do
                local o = LP:FindFirstChild(n)
                if o then Add("-- " .. n) Dump(o, "   ", 1) end
        end
        Add("")
end

local function Connections()
        Add("=== REMOTE OnClientEvent CONNECTIONS ===")
        if type(getconnections) ~= "function" then
                Add("(getconnections not exposed)")
                return
        end
        local total = 0
        for _, r in ipairs(S.remotes) do
                if r:IsA("RemoteEvent") then
                        local ok, cs = pcall(getconnections, r.OnClientEvent)
                        if ok and cs and #cs > 0 then
                                total = total + #cs
                                local line = string.format("[%d conns] %s", #cs, Cut(PathOf(r), 70))
                                Add(line)
                                if total <= 40 then Summ("CONN| " .. line) end
                        end
                end
        end
        Add("connections total: " .. total)
        Add("")
end

-- ================================================================
-- 4. DRIVER
-- ================================================================
local function RunChunk()
        if not S.ALL then
                S.ALL = game:GetDescendants()
                S.total = #S.ALL
                Add("=== STEAL AN EGG - FULL SCAN ===")
                Add("game    : " .. tostring(game.Name))
                Add("placeId : " .. tostring(game.PlaceId))
                Add("gameId  : " .. tostring(game.GameId))
                Add("player  : " .. tostring(LP.Name) .. " uid=" .. tostring(LP.UserId))
                Add("time    : " .. os.date("%H:%M:%S"))
                Add("descendants: " .. S.total)
                Add("")
                Add("=== REMOTES ===")
        end

        -- remotes collected -> print them, move on
        if S.phase == 1 and S.idx > S.total then
                Add("total remotes: " .. #S.remotes)
                for _, r in ipairs(S.remotes) do
                        local fl = (Acts(r.Name) and "   <<< ACTION") or (Hit(r.Name) and "  <~") or ""
                        local line = string.format("[%s] %-26s %s%s", r.ClassName,
                                Cut(tostring(r.Name), 26), Cut(PathOf(r), 66), fl)
                        Add(line)
                        if #S.remotes <= 80 or Acts(r.Name) then Summ("REMOTE| " .. line) end
                end
                Add("")
                S.phase = S.phase + 1
                S.idx = 1
                return true
        end

        if S.phase <= #PHASES then
                local fn = PHASES[S.phase]
                local nextFrom, base, msg = fn(S.idx)
                local reached = nextFrom > S.total
                if reached then
                        S.phase = S.phase + 1
                        S.idx = 1
                        Add("")
                else
                        S.idx = nextFrom
                end
                if T and T.Fill then
                        pcall(function()
                                T.Fill.Size = UDim2.new(math.clamp(base, 0, 1), 0, 1, 0)
                                if T.BarBG then T.BarBG.Visible = true end
                        end)
                end
                Say("phase " .. S.phase .. "/" .. (#PHASES + 3) .. " - " .. msg
                        .. (reached and "  [done]" or ""))
                return true
        end

        if S.phase == #PHASES + 1 then
                pcall(PlayerData)
                S.phase = S.phase + 1
                return true
        end
        if S.phase == #PHASES + 2 then
                pcall(Connections)
                S.phase = S.phase + 1
                return true
        end

        -- finished
        S.phase = #PHASES + 3
        S.done = true
        S.scanning = false
        Add("=== DONE - " .. S.n .. " lines in "
                .. string.format("%.1f", os.clock() - S.t0) .. "s ===")

        local head = {"=== SUMMARY (copy this part) ==="}
        for i = 1, #S.summary do head[#head + 1] = S.summary[i] end
        head[#head + 1] = "=== FULL DUMP ==="
        local out = {}
        for i = 1, #head do out[i] = head[i] end
        for i = 1, S.n do out[#out + 1] = S.lines[i] end
        S.text = table.concat(out, "\n")
        G.SAE_Report = S.text

        if T and T.BarBG then pcall(function() T.BarBG.Visible = false end) end
        Say("DONE - " .. S.n .. " lines. tap COPY", Color3.fromRGB(120, 255, 150))
        if T and T.Scan then
                pcall(function()
                        T.Scan.Text = "RESCAN"
                        T.Scan.Active = true
                        T.Copy.Active = true
                        T.Copy.AutoButtonColor = true
                        T.Copy.BackgroundColor3 = Color3.fromRGB(40, 100, 190)
                        T.File.Active = true
                        T.File.AutoButtonColor = true
                        T.Out.Text = S.text
                end)
        end
        return true
end

local running = false
function Driver()
        if running then
                S.scanning = not S.scanning
                Say(S.scanning and "resumed" or "paused - tap SCAN to continue",
                        Color3.fromRGB(255, 220, 120))
                return
        end
        if S.done then
                S.lines, S.n, S.phase, S.idx = {}, 0, 1, 1
                S.remotes, S.summary, S.ALL = {}, {}, nil
                S.done, S.scanning, S.t0 = false, true, os.clock()
                S.btns, S.attrs, S.pp, S.npc = nil, nil, nil, nil
                S.kw, S.txt, S.mod, S.text = nil, nil, nil, nil
        end
        if not S.scanning then S.scanning = true end

        running = true
        if T and T.Scan then
                pcall(function() T.Scan.Text = "..." T.Scan.Active = false end)
        end
        if T and T.Out and S.n == 0 then pcall(function() T.Out.Text = "" end) end
        Say("scanning - tap SCAN to pause/resume", Color3.fromRGB(255, 220, 120))

        while S.phase <= #PHASES + 2 do
                if not S.scanning then
                        running = false
                        Say("paused at phase " .. S.phase .. " - tap SCAN to resume",
                                Color3.fromRGB(255, 180, 120))
                        Push()
                        return
                end
                local ok, err = pcall(RunChunk)
                if not ok then
                        running = false
                        Add("!! chunk error: " .. tostring(err))
                        Say("error: " .. Cut(err, 70), Color3.fromRGB(255, 120, 120))
                        Push()
                        return
                end
                Push()
                task.wait()
        end
        pcall(RunChunk)
        Push()
        running = false
end

-- ================================================================
-- 5. OUTPUT
-- ================================================================
local PART = 0
local function Chunked(text, size)
        local parts, cur, cnt = {}, {}, 0
        for line in (text .. "\n"):gmatch("([^\n]*)\n") do
                if #cur > 0 and cnt + #line + 1 > size then
                        parts[#parts + 1] = table.concat(cur, "\n")
                        cur, cnt = {}, 0
                end
                table.insert(cur, line)
                cnt = cnt + #line + 1
        end
        if #cur > 0 then parts[#parts + 1] = table.concat(cur, "\n") end
        return parts
end

local function SetClip(t)
        if type(setclipboard) == "function" then
                local ok = pcall(setclipboard, t)
                if ok then return true end
        end
        return pcall(function()
                game:GetService("ClipboardService"):SetClipboard(t)
        end)
end

function SaveFile()
        local text = S.text or table.concat(S.lines, "\n")
        local ok = false
        pcall(function()
                if type(writefile) == "function" then
                        writefile("sae_scan.txt", text)
                        ok = true
                end
        end)
        if ok then
                Say("saved sae_scan.txt (" .. #text .. " chars) - open Delta file tab",
                        Color3.fromRGB(120, 255, 150))
        else
                Say("no writefile - use COPY parts", Color3.fromRGB(255, 180, 120))
        end
end

function CopyStep()
        if S.scanning then
                Say("still scanning - wait for DONE", Color3.fromRGB(255, 200, 120))
                return
        end
        local text = S.text
        if not text then
                Say("nothing scanned yet - press SCAN", Color3.fromRGB(255, 150, 150))
                return
        end
        local parts = Chunked(text, 6000)
        PART = (PART % #parts) + 1
        local p = parts[PART]
        if T and T.Out then
                pcall(function() T.Out.Text = p T.Out.CursorPosition = Vector2.new(0, 0) end)
        end
        if SetClip(p) then
                Say(string.format("PART %d/%d copied (%d chars) - tap COPY for next",
                        PART, #parts, #p), Color3.fromRGB(120, 255, 150))
        else
                Say("clipboard blocked - hold the box, Select All, Copy",
                        Color3.fromRGB(255, 150, 150))
        end
end

-- ================================================================
-- 6. BOOT
-- ================================================================
BuildUI()

task.spawn(function()
        while true do
                task.wait(2)
                local pg = LP:FindFirstChild("PlayerGui")
                if not (pg and pg:FindFirstChild("SAE_Scan")) then
                        if BuildUI() then
                                Push()
                                if S.scanning then
                                        pcall(function() T.Scan.Text = "RESUME" end)
                                        Say("gui wiped - rebuilt. tap SCAN to continue", Color3.fromRGB(255, 200, 120))
                                elseif S.done then
                                        pcall(function()
                                                T.Scan.Text = "RESCAN" T.Scan.Active = true
                                                T.Copy.Active = true T.Copy.AutoButtonColor = true
                                                T.Copy.BackgroundColor3 = Color3.fromRGB(40, 100, 190)
                                                T.File.Active = true T.File.AutoButtonColor = true
                                                T.Out.Text = S.text
                                        end)
                                        Say("gui rebuilt - scan DONE, tap COPY")
                                else
                                        pcall(function() T.Scan.Text = "RESUME" end)
                                        Say("gui rebuilt - tap SCAN to continue", Color3.fromRGB(255, 200, 120))
                                end
                        end
                end
        end
end)

Push()
Say("auto-scan in 1s... you can close the panel", Color3.fromRGB(150, 255, 170))
task.wait(1)
Driver()
print("[SAE Scan] v2 ready. SCAN / COPY / FILE at panel bottom. "
        .. S.n .. " lines so far.")
