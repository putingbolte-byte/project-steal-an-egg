--// scan_egg.lua  (Delta / mobile)
--// Steal an Egg — button-driven scanner with COPY ALL
--// StarterPlayer > StarterPlayerScripts > LocalScript

--// ============================================================
--// 0. CORE
--// ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REPORT = {}
local LINES = 0                                                                         local function R(s)
        LINES = LINES + 1
        REPORT[#REPORT + 1] = tostring(s)
end

--// ============================================================
--// 1. UI
--// ============================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "EggScanUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999
Gui.Parent = PlayerGui

local function mk(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        o.Parent = parent
        return o
end

--// draggable header
local Frame = mk("Frame", {
        Size = UDim2.new(0.92, 0, 0.78, 0),
        Position = UDim2.new(0.04, 0, 0.06, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        ClipsDescendants = true,
}, Gui)
mk("UICorner", { CornerRadius = UDim.new(0, 10) }, Frame)

local Header = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(40, 20, 60),
        BorderSizePixel = 0,
        Text = "EGG SCANNER  —  tap to drag",
        TextColor3 = Color3.fromRGB(230, 220, 255),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true,
}, Frame)
mk("UICorner", { CornerRadius = UDim.new(0, 10) }, Header)

--// status label
local Status = mk("TextLabel", {
        Size = UDim2.new(1, -16, 0, 30),
        Position = UDim2.new(0, 8, 0, 44),
        BackgroundTransparency = 1,
        Text = "idle — press SCAN",
        TextColor3 = Color3.fromRGB(150, 255, 170),
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
}, Frame)

--// progress bar
local BarBG = mk("Frame", {
        Size = UDim2.new(1, -16, 0, 12),
        Position = UDim2.new(0, 8, 0, 74),
        BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        BorderSizePixel = 0,
        Visible = false,
}, Frame)
mk("UICorner", { CornerRadius = UDim.new(1, 6) }, BarBG)
local Bar = mk("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(90, 230, 130),
        BorderSizePixel = 0,
}, BarBG)
mk("UICorner", { CornerRadius = UDim.new(1, 6) }, Bar)

--// output box
local Out = mk("TextBox", {
        Size = UDim2.new(1, -16, 1, -190),
        Position = UDim2.new(0, 8, 0, 92),
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "output shows here...",
        PlaceholderColor3 = Color3.fromRGB(90, 90, 105),
        TextColor3 = Color3.fromRGB(190, 255, 200),
        TextSize = 13,
        Font = Enum.Font.Code,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ClearTextOnFocus = false,
        MultiLine = true,
        ScrollBarThickness = 8,
        RichText = false,
}, Frame)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, Out)

--// buttons (big, thumb-friendly)
local function layoutButtons(...)
        local n = select("#", ...)
        local pad = 0.02
        local w = (1 - pad * (n + 1)) / n
        local idx = 0
        for _, b in ipairs({...}) do
                idx = idx + 1
                b.Size = UDim2.new(w, 0, 0, 52)
                b.Position = UDim2.new(pad * idx, 0, 1, -62)
        end
end

local BtnScan   = mk("TextButton", { BackgroundColor3 = Color3.fromRGB(40, 120, 60) },
        Frame)
local BtnCopy   = mk("TextButton", { BackgroundColor3 = Color3.fromRGB(40, 100, 190) },
        Frame)
local BtnClose  = mk("TextButton", { BackgroundColor3 = Color3.fromRGB(150, 50, 50) },
        Frame)
for _, b in ipairs({ BtnScan, BtnCopy, BtnClose }) do
        b.BorderSizePixel = 0
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 15
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = true
        mk("UICorner", { CornerRadius = UDim.new(0, 8) }, b)
end
BtnScan.Text = "SCAN"
BtnCopy.Text = "COPY ALL"
BtnClose.Text = "CLOSE"
BtnCopy.Active = false
BtnCopy.AutoButtonColor = false
BtnCopy.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
layoutButtons(BtnScan, BtnCopy, BtnClose)

--// ============================================================
--// 2. SCAN ENGINE (coroutine so the UI never freezes)
--// ============================================================
local IGNORE_NAMES = {
        Workspace = true, Lighting = true, Players = true, SoundService = true,
        HttpService = true, CoreGui = true, GuiService = true, VideoService = true,
        TextChatService = true, Teams = true, UserInputService = true,
        ContextActionService = true, PolicyService = true, TextService = true,
        TweenService = true, Debris = true, InsertService = true,
        CollectionService = true, Sound = true, LocalizationService = true,
        Application = true, Avatar = true, RunService = true, MouseBehavior = true,
        Tool = true, Accoutrement = true, Chat = true, PIP = true,
}

local REMOTES = {}
local SUSPECT = {
        "egg", "hatch", "open", "pet", "reveal", "buy", "equip", "index",
        "request", "spin", "roll", "claim", "collect", "sell", "incubate",
        "hatchpet", "opene", "useitem", "craft",
}

local scanning = false

local function flush()
        Out.Text = table.concat(REPORT, "\n")
        Out.Position = UDim2.new(0, 8, 0, 92)
end

local function setProgress(cur, max, msg)
        BarBG.Visible = max > 0
        Bar.Size = UDim2.new(math.clamp(cur / math.max(max, 1), 0, 1), 0, 1, 0)
        Status.Text = msg
        flush()
end

local function scanTree(root, depth, label, counter, totalRef)
        if depth > 16 or scanning ~= true then return end
        for _, c in ipairs(root:GetChildren()) do
                if scanning ~= true then return end
                counter.n = counter.n + 1
                if counter.n % 25 == 0 then
                        setProgress(counter.n, totalRef[1], ("scanning tree... %d objects"):format(counter.n))
                        task.wait()
                end
                local cn, nm = c.ClassName, tostring(c.Name)
                local lower = string.lower(nm)
                if not IGNORE_NAMES[nm] and not IGNORE_NAMES[cn] then
                        local isRemote = (cn == "RemoteEvent" or cn == "RemoteFunction")
                        if isRemote then
                                table.insert(REMOTES, { obj = c, path = c:GetFullName() })
                        end
                        if lower:find("egg") or lower:find("hatch") or lower:find("pet")
                                or lower:find("reveal") or lower:find("incubat") then
                                R(">>> HIT " .. nm .. "  [" .. cn .. "]  " .. c:GetFullName())
                        end
                        scanTree(c, depth + 1, label .. " ", counter, totalRef)
                end
        end
end

local function scrapeText(root, depth, counter, totalRef)
        if depth > 16 or scanning ~= true then return end
        for _, c in ipairs(root:GetChildren()) do
                if scanning ~= true then return end
                counter.n = counter.n + 1
                if counter.n % 25 == 0 then
                        setProgress(counter.n, totalRef[1], "reading gui text... " .. counter.n)
                        task.wait()
                end
                local ok, cls = pcall(function() return c.ClassName end)
                if ok and (cls == "TextLabel" or cls == "TextButton" or cls == "TextBox") then
                        local ok2, txt = pcall(function() return c.Text end)
                        if ok2 and type(txt) == "string" and #txt > 0 and #txt < 220 then
                                R(("[%s] %s : \"%s\""):format(cls, tostring(c.Name), txt))
                        end
                end
                local ok3, gui = pcall(function() return c:IsA("GuiObject") end)
                if ok3 and gui then
                        scrapeText(c, depth + 1, counter, totalRef)
                end
        end
end

local function runScan()
        if scanning then return end
        scanning = true
        REPORT = {}
        LINES = 0
        REMOTES = {}
        BtnScan.Active = false
        BtnScan.Text = "SCANNING"
        BtnCopy.Active = false
        BtnCopy.Text = "COPY ALL"
        BtnCopy.BackgroundColor3 = Color3.fromRGB(40, 60, 90)

        R("### EGG SCAN — " .. os.date("%H:%M:%S"))
        local okGame, err = pcall(function()
                R("placeId = " .. tostring(game.PlaceId))
                R("gameId  = " .. tostring(game.GameId))
                R("game    = " .. tostring(game.Name))
        end)
        if not okGame then R("game info error: " .. tostring(err)) end
        R("")

        local totalRef = { 0 }
        local counter = { n = 0 }

        --// pass 1: remotes
        R("=== REMOTES ===")
        Status.Text = "collecting remotes..."
        task.wait()

        local function collect(root, depth)
                if depth > 18 or scanning ~= true then return end
                local ok, kids = pcall(function() return root:GetChildren() end)
                if not ok then return end
                for _, c in ipairs(kids) do
                        if scanning ~= true then return end
                        counter.n = counter.n + 1
                        if counter.n % 20 == 0 then
                                setProgress(counter.n, totalRef[1], "collecting remotes... " .. counter.n)
                                task.wait()
                        end
                        local cn = c.ClassName
                        if cn == "RemoteEvent" or cn == "RemoteFunction" then
                                REMOTES[#REMOTES + 1] = { obj = c, path = c:GetFullName() }
                        elseif not IGNORE_NAMES[c.Name] and not IGNORE_NAMES[cn] then
                                collect(c, depth + 1)
                        end
                end
        end

        collect(ReplicatedStorage, 0)
        collect(PlayerGui, 0)
        for _, v in ipairs({"ReplicatedFirst", "ServerScriptService"}) do
                local s = game:FindFirstChild(v)
                if s then pcall(collect, s, 0) end
        end

        for i, e in ipairs(REMOTES) do
                R(("R[%d] %s  <-  %s"):format(i, tostring(e.obj.Name), e.path))
        end
        R("total remotes = " .. #REMOTES)
        R("")

        --// pass 2: suspects
        R("=== SUSPECT REMOTES ===")
        for _, e in ipairs(REMOTES) do
                local low = string.lower(tostring(e.obj.Name))
                for _, s in ipairs(SUSPECT) do
                        if low:find(s, 1, true) then
                                R("!! " .. tostring(e.obj.Name) .. "  " .. e.path)
                                break
                        end
                end
        end
        R("")

        --// pass 3: egg-ish objects
        R("=== EGG NAMED OBJECTS ===")
        counter.n = 0
        setProgress(0, totalRef[1], "hunting egg objects...")
        scanTree(PlayerGui, 0, "", counter, totalRef)
        scanTree(ReplicatedStorage, 0, "", counter, totalRef)
        R("")

        --// pass 4: gui text
        R("=== GUI TEXT ===")
        counter.n = 0
        setProgress(0, totalRef[1], "reading gui text...")
        scrapeText(PlayerGui, 0, counter, totalRef)
        R("")

        --// pass 5: player state
        R("=== PLAYER VALUES ===")
        local function dumpValues(root, prefix, depth)
                if depth > 4 or scanning ~= true then return end
                for _, c in ipairs(root:GetChildren()) do
                        local cn = c.ClassName
                        if cn == "IntValue" or cn == "StringValue" or cn == "BoolValue"
                                or cn == "NumberValue" or cn == "ObjectValue" then
                                local v
                                pcall(function() v = c.Value end)
                                R(prefix .. tostring(c.Name) .. " = " .. tostring(v))
                        else
                                R(prefix .. tostring(c.Name) .. " : " .. cn)
                                dumpValues(c, prefix .. "  ", depth + 1)
                        end
                end
        end
        for _, n in ipairs({"leaderstats", "Data", "PlayerData", "Stats", "Inventory",
                "Pets", "Eggs", "GameData", "Profile", "SaveData"}) do
                local o = LocalPlayer:FindFirstChild(n)
                if o then
                        R("-- " .. n)
                        dumpValues(o, "   ", 1)
                end
        end

        R("")
        R("=== SCAN COMPLETE — " .. LINES .. " lines ===")
        scanning = false
        BarBG.Visible = false
        Status.Text = "done — " .. LINES .. " lines. tap COPY ALL."
        BtnScan.Text = "RESCAN"
        BtnScan.Active = true
        BtnScan.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
        BtnCopy.Active = true
        BtnCopy.Text = "COPY ALL (" .. LINES .. ")"
        BtnCopy.BackgroundColor3 = Color3.fromRGB(40, 100, 190)
        flush()
        Out.Position = UDim2.new(0, 8, 0, 92)
end

--// ============================================================
--// 3. CLIPBOARD  (Delta -> setclipboard)
--// ============================================================
local function toClipboard(text)
        local ok = false
        if type(setclipboard) == "function" then
                pcall(setclipboard, text)
                ok = true
        end
        if not ok then
                pcall(function()
                        game:GetService("ClipboardService"):SetClipboard(text)
                end)
        end
        return ok
end

BtnScan.MouseButton1Click:Connect(function()
        if LINES == 0 and not scanning then
                Status.Text = "scan first..."
        else
                runScan()
        end
end)

BtnCopy.MouseButton1Click:Connect(function()
        if scanning then
                Status.Text = "wait for scan to finish"
                return
        end
        if LINES == 0 then
                Status.Text = "nothing scanned yet — press SCAN"
                return
        end
        local text = table.concat(REPORT, "\n")
        Out.Text = text
        task.wait(0.1)
        local ok = toClipboard(text)
        if ok then
                Status.Text = "copied " .. #text .. " chars to clipboard — paste it here"
                BtnCopy.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
                task.delay(1.5, function()
                        BtnCopy.BackgroundColor3 = Color3.fromRGB(40, 100, 190)
                end)
        else
                Status.Text = "clipboard blocked — long-press the box and select all"
                BtnCopy.Text = "SEL ALL"
                BtnCopy.Active = true
        end
end)

BtnClose.MouseButton1Click:Connect(function()
        Gui:Destroy()
end)

--// long-press select-all fallback inside the box
Out.MouseButton1Click:Connect(function()
        if BtnCopy.Text == "SEL ALL" then
                pcall(function() Out.CursorPosition = Vector2.new(9999, 9999) end)
        end
end)

Status.Text = "ready — press SCAN"
print("[EggScan] UI loaded. Tap SCAN.")
