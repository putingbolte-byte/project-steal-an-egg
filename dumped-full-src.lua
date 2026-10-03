if not game:IsLoaded() then
    game.Loaded:Wait()
end
do
    local UserIdStr

    do
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        if not LocalPlayer then
            pcall(function()
                Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
            end)
            LocalPlayer = Players.LocalPlayer
        end

        UserIdStr = tostring(LocalPlayer and LocalPlayer.UserId or 0)
    end

    local EnvTable = getgenv and getgenv() or _G
    local KozuaHub = EnvTable.KozuaHub

    if type(KozuaHub) ~= "table" then
        KozuaHub = {
			slots = {}
		}
        EnvTable.KozuaHub = KozuaHub
    end

    if type(KozuaHub.slots) ~= "table" then
        KozuaHub.slots = {}
    end

    local unload

    do
        local userSlot = KozuaHub.slots[UserIdStr]

        if type(userSlot) ~= "table" then
            userSlot = {}
            KozuaHub.slots[UserIdStr] = userSlot
        end

        userSlot.gen = (tonumber(userSlot.gen) or 0) + 1

        local otherAliveFound = false

        for k, v in pairs(KozuaHub.slots) do
            if UserIdStr ~= tostring(k) and type(v) == "table" and v.alive == true then
                otherAliveFound = true

                break
            end
        end

        if not otherAliveFound then
            EnvTable.KozuaCfgGen = (tonumber(EnvTable.KozuaCfgGen) or 0) + 1
        end

        unload = userSlot.unload
        userSlot.unload = nil
        userSlot.alive = false
    end

    if type(unload) == "function" then
        pcall(unload)
    elseif type(EnvTable.KozuaUnload) == "function" then
        local KozuaUnloadUid = EnvTable.KozuaUnloadUid
        local shouldRunUnload = KozuaUnloadUid == nil or UserIdStr == tostring(KozuaUnloadUid)

        if KozuaUnloadUid == nil then
            for k, v in pairs(KozuaHub.slots) do
                if UserIdStr ~= tostring(k) and type(v) == "table" and type(v.unload) == "function" then
                    shouldRunUnload = false

                    break
                end
            end
        end

        if shouldRunUnload then
            local KozuaUnload = EnvTable.KozuaUnload

            if UserIdStr == tostring(KozuaUnloadUid or UserIdStr) then
                EnvTable.KozuaUnload = nil
                EnvTable.KozuaUnloadUid = nil
            end

            pcall(KozuaUnload)
        end
    end
end
do
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    if not LocalPlayer then
        pcall(function()
            Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        end)
        LocalPlayer = Players.LocalPlayer
    end

    local waitDeadline = os.clock() + 60

    while LocalPlayer and waitDeadline > os.clock() do
        local humanoid, rootPart

        do
            local Character = LocalPlayer.Character

            humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            rootPart = Character and Character:FindFirstChild("HumanoidRootPart")
        end

        if humanoid and rootPart and humanoid.Health > 0 then
            task.wait(0.45)

            local Character = LocalPlayer.Character
            local charHumanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            local charRoot = Character and Character:FindFirstChild("HumanoidRootPart")

            if not charHumanoid or not charRoot or not (charHumanoid.Health > 0) then
                continue
            end

            break
        end

        task.wait(0.1)
    end
end
local HubInfo = {
	Title = "KOZUA",
	Version = "0.1",
	Product = "Steal an Egg",
	OpenBind = Enum.KeyCode.RightShift,
	FlightBind = Enum.KeyCode.F,
	Tagline = "keyless · paste and run",
	Status = "stable",
	Game = "Steal an Egg",
	Discord = "",
	Website = "",
	Changelog = "kozua rebrand — keyless build, live header pills, sidebar glow, toasts, Kozua theme",
	Author = "kozua",
	Credits = "the kozua crew",
	Support = "kozua — no key, no gate, no loader"
}
local function sanitizeFileName(rawName)
    local sanitizedName = tostring(rawName or "Game"):gsub("[<>:\"/\\|?*]", "_"):gsub("%s+", "_"):gsub("_+", "_"):match("^%s*(.-)%s*$")

    if not sanitizedName or sanitizedName == "" or sanitizedName == "_" then
        sanitizedName = "Game"
    end

    return sanitizedName
end
HubInfo.LogoFile = "kozua" .. "/logo.png"
HubInfo.LogoFileLight = "kozua" .. "/logo-light.png"
local WinWidth = 620
local WinHeight = 430
local SidebarWidth = 152
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService, Stats, ProximityPromptService, ReplicatedStorage, LocalPlayer, isMobile, computeWindowSize, IsMobile, PhoneUILocked, ApplyResponsiveLayout, UserIdStr, GuiTag, WorldGuiTag, getEnvTable, getUserSlot, ThemePresets
local Theme, Fonts, BiomeList, RarityList, TraitList, Config, WidgetRegistry, SpareRegistry, TabRegistry, ActiveTab, OpenDropdown, SelectTab, FilterTabItems, SetVisible, ApplyTheme, CleanupList
local trackDisposable, LogoAssetDark, LogoAssetLight, refreshLogoImages, TweenRegistry, newInstance, applyStroke, applyPadding, bindHoverTheme, createLogoMark, ScreenGui, DropdownOverlay, WindowScale, Window, Sidebar, MainPage
local Header, MinimizeButton, HeaderStatPill1, HeaderStatPill2, SearchIcon, SearchBox, CreateTab, AddSectionHeader, tintIcon, BuildCard, IsApplyingConfig, IsSavingDebounced, ConfigGen, collectConfig, saveConfig, applyConfig
local refreshPresetOptions, saveNamedConfig, loadNamedConfig, loadAutoConfig, AddToggle, AddSlider, CloseDropdown, AddDropdown, AddTextbox, AddButton, AddKeybind, isNonEmptyString, resolveDiscordInvite, AddParagraph, kozuaToast
do
    local TabIcons, TabOrder, tween, drawIcon

    do
        local screenGuiProps, guiParent

        do
            local TweenService = game:GetService("TweenService")

            HttpService = game:GetService("HttpService")
            Stats = game:GetService("Stats")
            ProximityPromptService = game:GetService("ProximityPromptService")
            ReplicatedStorage = game:GetService("ReplicatedStorage")

            local GuiService = game:GetService("GuiService")

            LocalPlayer = Players.LocalPlayer

            if not LocalPlayer then
                pcall(function()
                    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
                end)
                LocalPlayer = Players.LocalPlayer
            end

            function isMobile()
                if UserInputService.VREnabled then
                    return false
                end
                local isTenFoot = false
                pcall(function()
                    isTenFoot = GuiService:IsTenFootInterface()
                end)
                if isTenFoot then
                    return false
                end
                if UserInputService.TouchEnabled then
                    return true
                end
                if UserInputService.MouseEnabled == false then
                    return true
                end
                local hasGyro = false
                local hasAccel = false
                pcall(function()
                    hasGyro = UserInputService.GyroscopeEnabled == true
                end)
                pcall(function()
                    hasAccel = UserInputService.AccelerometerEnabled == true
                end)
                if hasGyro or hasAccel then
                    return true
                end
                local PreferredInput
                local LastInputType
                pcall(function()
                    PreferredInput = UserInputService.PreferredInput
                end)
                pcall(function()
                    LastInputType = UserInputService:GetLastInputType()
                end)
                if PreferredInput == Enum.PreferredInput.Touch or LastInputType == Enum.UserInputType.Touch then
                    return true
                end
                local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui and (playerGui:FindFirstChild("TouchGui", true) or playerGui:FindFirstChild("TouchControlFrame", true) or playerGui:FindFirstChild("JumpButton", true) or playerGui:FindFirstChild("DynamicThumbstickFrame", true)) then
                    return true
                end

                return false
            end
            function computeWindowSize()
                local CurrentCamera = workspace.CurrentCamera
                local viewportSize = if not CurrentCamera then Vector2.new(1280, 720) else CurrentCamera.ViewportSize
                local winW = math.floor(math.clamp(viewportSize.X * 0.7, 440, 560))
                local winH = math.floor(math.clamp(viewportSize.Y * 0.74, 340, 410))

                if viewportSize.X > 80 then
                    winW = math.min(winW, viewportSize.X - 36)
                end

                if viewportSize.Y > 80 then
                    winH = math.min(winH, viewportSize.Y - 36)
                end

                return math.max(400, winW), math.max(320, winH)
            end

            IsMobile = isMobile()
            PhoneUILocked = false
            ApplyResponsiveLayout = nil

            if IsMobile then
                local mobileW, mobileH = computeWindowSize()

                WinWidth = mobileW
                WinHeight = mobileH
                SidebarWidth = 128
            end

            UserIdStr = tostring(LocalPlayer and LocalPlayer.UserId or 0)
            GuiTag = "PH_UI_" .. UserIdStr
            WorldGuiTag = "KozuaWorldGui_" .. UserIdStr

            function getEnvTable()
                return getgenv and getgenv() or _G
            end
            function getUserSlot()
                local envTable = getgenv and getgenv() or _G
                local KozuaHub = envTable.KozuaHub

                if type(KozuaHub) ~= "table" then
                    KozuaHub = {
						slots = {}
					}
                    envTable.KozuaHub = KozuaHub
                end

                if type(KozuaHub.slots) ~= "table" then
                    KozuaHub.slots = {}
                end

                local slotEntry = KozuaHub.slots[UserIdStr]

                if type(slotEntry) ~= "table" then
                    slotEntry = {}
                    KozuaHub.slots[UserIdStr] = slotEntry
                end

                return slotEntry
            end

            HubInfo.ConfigFile = (("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/" .. sanitizeFileName(LocalPlayer and LocalPlayer.Name or "Player") .. "-config.json"
            ThemePresets = {
				Dark = {
					bg = Color3.fromRGB(12, 11, 10),
					rail = Color3.fromRGB(16, 15, 14),
					card = Color3.fromRGB(32, 30, 27),
					lift = Color3.fromRGB(42, 39, 35),
					fill = Color3.fromRGB(48, 44, 39),
					line = Color3.fromRGB(58, 53, 46),
					text = Color3.fromRGB(246, 242, 234),
					dim = Color3.fromRGB(168, 158, 144),
					mute = Color3.fromRGB(110, 102, 92),
					accent = Color3.fromRGB(214, 168, 108),
					accentDeep = Color3.fromRGB(92, 68, 36),
					accentHover = Color3.fromRGB(228, 186, 128),
					ink = Color3.fromRGB(22, 18, 14),
					ok = Color3.fromRGB(138, 166, 128),
					Kozua = Color3.fromRGB(246, 242, 234)
				},
				Light = {
					bg = Color3.fromRGB(232, 226, 218),
					rail = Color3.fromRGB(232, 226, 218),
					card = Color3.fromRGB(252, 250, 246),
					lift = Color3.fromRGB(242, 236, 228),
					fill = Color3.fromRGB(224, 218, 208),
					line = Color3.fromRGB(204, 196, 184),
					text = Color3.fromRGB(28, 24, 20),
					dim = Color3.fromRGB(92, 84, 74),
					mute = Color3.fromRGB(128, 120, 108),
					accent = Color3.fromRGB(168, 114, 56),
					accentDeep = Color3.fromRGB(120, 80, 38),
					accentHover = Color3.fromRGB(186, 132, 70),
					ink = Color3.fromRGB(252, 250, 246),
					ok = Color3.fromRGB(64, 118, 82),
					Kozua = Color3.fromRGB(28, 24, 20)
				},
				Kozua = {
					bg = Color3.fromRGB(13, 11, 22),
					rail = Color3.fromRGB(18, 15, 30),
					card = Color3.fromRGB(27, 23, 45),
					lift = Color3.fromRGB(37, 32, 61),
					fill = Color3.fromRGB(44, 38, 70),
					line = Color3.fromRGB(62, 55, 96),
					text = Color3.fromRGB(240, 238, 255),
					dim = Color3.fromRGB(163, 156, 198),
					mute = Color3.fromRGB(108, 100, 142),
					accent = Color3.fromRGB(150, 124, 255),
					accentDeep = Color3.fromRGB(74, 56, 150),
					accentHover = Color3.fromRGB(178, 158, 255),
					ink = Color3.fromRGB(15, 12, 28),
					ok = Color3.fromRGB(104, 214, 190),
					Kozua = Color3.fromRGB(240, 238, 255)
				}
			}
            Theme = {}

            for k, v in pairs(ThemePresets.Dark) do
                Theme[k] = v
            end

            Fonts = {
				title = Enum.Font.BuilderSansBold,
				mid = Enum.Font.BuilderSansMedium,
				body = Enum.Font.BuilderSans,
				mono = Enum.Font.RobotoMono
			}
            BiomeList = {
				"Forest",
				"Desert",
				"Lake",
				"Jungle",
				"Snow",
				"Volcano",
				"Prehistoric",
				"Cosmic",
				"Abyss Ocean",
				"Cherry Blossom"
			}
            RarityList = {
				"Common",
				"Uncommon",
				"Rare",
				"Epic",
				"Legendary",
				"Mythic",
				"Cosmic",
				"Secret",
				"Eternal",
				"Divine",
				"Titan"
			}
            TraitList = {
				"Golden",
				"Rainbow",
				"Galaxy",
				"Crystal",
				"Bloom"
			}
            TabIcons = {
				About = "info",
				["Auto Steal"] = "egg",
				Plot = "grid",
				Serverhop = "rocket",
				Misc = "layers",
				Webhook = "out",
				Settings = "cog"
			}
            Config = {}
            WidgetRegistry = {}
            SpareRegistry = {}
            TabRegistry = {}
            TabOrder = {}
            ActiveTab = nil
            OpenDropdown = nil
            SelectTab = nil
            FilterTabItems = nil
            SetVisible = nil
            ApplyTheme = nil
            CleanupList = {}

            function trackDisposable(disposable)
                if disposable then
                    CleanupList[#CleanupList + 1] = disposable
                end

                return disposable
            end

            local LogoFrames = {}

            LogoAssetDark = nil
            LogoAssetLight = nil

            local function tryBase64Decode(b64String)
                if type(b64String) ~= "string" or b64String == "" then
                    return
                end

                local DecoderFns = {}

                if crypt then
                    DecoderFns[#DecoderFns + 1] = crypt.base64decode
                    DecoderFns[#DecoderFns + 1] = crypt.base64_decode
                end

                if syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode then
                    DecoderFns[#DecoderFns + 1] = syn.crypt.base64.decode
                end

                if base64 and base64.decode then
                    DecoderFns[#DecoderFns + 1] = base64.decode
                end

                if base64_decode then
                    DecoderFns[#DecoderFns + 1] = base64_decode
                end

                for i = 1, #DecoderFns do
                    local ok, result = pcall(DecoderFns[i], b64String)

                    if ok and type(result) == "string" and #result > 64 then
                        return result
                    end
                end
            end
            local function ensureLogoAsset(wantLight)
                if wantLight then
                    if LogoAssetLight then
                        return LogoAssetLight
                    end
                elseif LogoAssetDark then
                    return LogoAssetDark
                end

                local decodedPng = tryBase64Decode((not wantLight and "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") or "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")

                if not decodedPng then
                    return
                end

                local logoPath = wantLight and HubInfo.LogoFileLight or HubInfo.LogoFile

                if type(makefolder) == "function" then
                    pcall(makefolder, "kozua")
                end

                if writefile then
                    pcall(writefile, logoPath, decodedPng)
                end

                if getcustomasset then
                    local ok, result = pcall(getcustomasset, logoPath)

                    if ok and type(result) == "string" and result ~= "" then
                        if wantLight then
                            LogoAssetLight = result

                            return result
                        end

                        LogoAssetDark = result

                        return result
                    end
                end
            end

            function refreshLogoImages()
                local logoAsset = ensureLogoAsset(Config.Theme == "Light")

                if not logoAsset then
                    return
                end

                for _, v in ipairs(LogoFrames) do
                    local Mark = v:FindFirstChild("Mark")

                    if Mark and Mark:IsA("ImageLabel") then
                        Mark.Image = logoAsset
                        Mark.ImageColor3 = Color3.new(1, 1, 1)
                    end
                end
            end

            TweenRegistry = setmetatable({}, {
				__mode = "k"
			})

            function tween(tweenTarget, tweenDuration, tweenGoal, easeStyle)
                local activeTween = TweenRegistry[tweenTarget]

                if activeTween then
                    pcall(function()
                        activeTween:Cancel()
                    end)
                end

                local tween = TweenService:Create(tweenTarget, TweenInfo.new(tweenDuration, easeStyle or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), tweenGoal)

                TweenRegistry[tweenTarget] = tween
                tween:Play()
                tween.Completed:Connect(function()
                    if TweenRegistry[tweenTarget] == tween then
                        TweenRegistry[tweenTarget] = nil
                    end
                end)
            end
            function newInstance(className, props, parent)
                local createdInst = Instance.new(className)

                if props then
                    for k, v in pairs(props) do
                        createdInst[k] = v
                    end
                end

                if parent then
                    createdInst.Parent = parent
                end

                return createdInst
            end
            function applyStroke(strokeTarget, strokeColorKey, strokeThickness)
                local strokeKey
                local strokeColor
                if type(strokeColorKey) == "string" then
                    strokeKey = strokeColorKey
                    strokeColor = Theme[strokeColorKey] or Theme.line
                else
                    strokeColor = strokeColorKey or Theme.line
                end
                local uiStrokeProps = {
					Color = strokeColor,
					Thickness = strokeThickness or 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}
                local UIStroke = Instance.new("UIStroke")
                if uiStrokeProps then
                    for k, v in pairs(uiStrokeProps) do
                        UIStroke[k] = v
                    end
                end
                if strokeTarget then
                    UIStroke.Parent = strokeTarget
                end
                if strokeKey then
                    UIStroke:SetAttribute("th_stroke", strokeKey)
                end

                return UIStroke
            end
            function applyPadding(padTarget, padLeft, padTop, padRight, padBottom)
                if padTop == nil then
                    padTop = padLeft
                    padRight = padLeft
                    padBottom = padLeft
                end

                local uiPaddingProps = {
					PaddingLeft = UDim.new(0, padLeft),
					PaddingTop = UDim.new(0, padTop),
					PaddingRight = UDim.new(0, padRight or padLeft),
					PaddingBottom = UDim.new(0, padBottom or padTop)
				}
                local UIPadding = Instance.new("UIPadding")

                if uiPaddingProps then
                    for k, v in pairs(uiPaddingProps) do
                        UIPadding[k] = v
                    end
                end

                if padTarget then
                    UIPadding.Parent = padTarget
                end

                return UIPadding
            end
            function bindHoverTheme(hoverTarget, bgKey, hoverKey)
                if type(bgKey) == "string" then
                    if hoverTarget and bgKey then
                        hoverTarget:SetAttribute("th_bg", bgKey)

                        local themeColor = Theme[bgKey]

                        if themeColor and hoverTarget:IsA("GuiObject") then
                            hoverTarget.BackgroundColor3 = themeColor
                        end
                    end

                    hoverTarget:SetAttribute("th_hover", hoverKey)
                end

                hoverTarget.MouseEnter:Connect(function()
                    if hoverTarget:GetAttribute("locked") then
                        return
                    end

                    hoverTarget:SetAttribute("th_over", true)

                    local hoverKey = hoverTarget:GetAttribute("th_hover") or hoverKey
                    local hoverColor = type(hoverKey) == "string" and Theme[hoverKey] or hoverKey

                    if hoverColor then
                        tween(hoverTarget, 0.12, {
							BackgroundColor3 = hoverColor
						})
                    end
                end)
                hoverTarget.MouseLeave:Connect(function()
                    if hoverTarget:GetAttribute("locked") then
                        return
                    end

                    hoverTarget:SetAttribute("th_over", false)

                    local bgKey = hoverTarget:GetAttribute("th_bg") or bgKey
                    local bgColor = type(bgKey) == "string" and Theme[bgKey] or bgKey

                    if bgColor then
                        tween(hoverTarget, 0.12, {
							BackgroundColor3 = bgColor
						})
                    end
                end)
            end
            function drawIcon(iconParent, iconGlyph, iconColor, iconZ)
                local frameProps = {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(16, 16),
					ZIndex = iconZ
				}
                local Frame = Instance.new("Frame")

                if frameProps then
                    for k, v in pairs(frameProps) do
                        Frame[k] = v
                    end
                end

                if iconParent then
                    Frame.Parent = iconParent
                end

                local iconFrame = Frame

                local function drawBar(barX, barY, barW, barH, barCorner)
                    local frameProps2 = {
						BackgroundColor3 = iconColor,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(barX, barY),
						Size = UDim2.fromOffset(barW, barH),
						ZIndex = iconZ + 1
					}
                    local barParent = iconFrame
                    local Frame2 = Instance.new("Frame")

                    if frameProps2 then
                        for k, v in pairs(frameProps2) do
                            Frame2[k] = v
                        end
                    end

                    if barParent then
                        Frame2.Parent = barParent
                    end

                    if barCorner then
                        local uiCornerProps = {
							CornerRadius = UDim.new(0, barCorner or 8)
						}
                        local UICorner = Instance.new("UICorner")

                        if uiCornerProps then
                            for k, v in pairs(uiCornerProps) do
                                UICorner[k] = v
                            end
                        end

                        if Frame2 then
                            UICorner.Parent = Frame2
                        end
                    end

                    return Frame2
                end
                local function drawDot(dotX, dotY, dotW, dotH, dotCorner)
                    local frameProps3 = {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(dotX, dotY),
						Size = UDim2.fromOffset(dotW, dotH),
						ZIndex = iconZ + 1
					}
                    local dotParent = iconFrame
                    local Frame3 = Instance.new("Frame")

                    if frameProps3 then
                        for k, v in pairs(frameProps3) do
                            Frame3[k] = v
                        end
                    end

                    if dotParent then
                        Frame3.Parent = dotParent
                    end

                    local uiCornerProps2 = {
						CornerRadius = UDim.new(0, dotCorner or 8)
					}
                    local UICorner = Instance.new("UICorner")

                    if uiCornerProps2 then
                        for k, v in pairs(uiCornerProps2) do
                            UICorner[k] = v
                        end
                    end

                    if Frame3 then
                        UICorner.Parent = Frame3
                    end

                    applyStroke(Frame3, iconColor, 1.2)

                    return Frame3
                end

                if iconGlyph == "egg" then
                    drawBar(4, 2, 8, 12, 5)

                    return iconFrame
                end

                if iconGlyph == "aim" then
                    drawDot(2, 2, 12, 12, 6)
                    drawBar(7, 7, 2, 2, 1)
                    drawBar(7, 0, 2, 3, 0)
                    drawBar(7, 13, 2, 3, 0)
                    drawBar(0, 7, 3, 2, 0)
                    drawBar(13, 7, 3, 2, 0)

                    return iconFrame
                end

                if iconGlyph == "spark" then
                    drawBar(7, 1, 2, 14, 1)
                    drawBar(1, 7, 14, 2, 1)
                    drawBar(4, 4, 2, 2, 1)
                    drawBar(10, 10, 2, 2, 1)

                    return iconFrame
                end

                if iconGlyph == "grid" then
                    drawBar(1, 1, 6, 6, 2)
                    drawBar(9, 1, 6, 6, 2)
                    drawBar(1, 9, 6, 6, 2)
                    drawBar(9, 9, 6, 6, 2)

                    return iconFrame
                end

                if iconGlyph == "layers" then
                    drawBar(2, 3, 12, 2, 1)
                    drawBar(2, 7, 12, 2, 1)
                    drawBar(2, 11, 12, 2, 1)

                    return iconFrame
                end

                if iconGlyph == "out" then
                    drawDot(1, 3, 10, 10, 3)
                    drawBar(8, 2, 6, 2, 1)
                    drawBar(12, 2, 2, 6, 1)

                    return iconFrame
                end

                if iconGlyph == "cog" then
                    drawDot(3, 3, 10, 10, 5)
                    drawBar(7, 1, 2, 3, 1)
                    drawBar(7, 12, 2, 3, 1)
                    drawBar(1, 7, 3, 2, 1)
                    drawBar(12, 7, 3, 2, 1)

                    return iconFrame
                end

                if iconGlyph == "rocket" then
                    drawBar(6, 1, 4, 9, 2)
                    drawBar(7, 0, 2, 3, 1)
                    drawBar(4, 8, 3, 4, 1)
                    drawBar(9, 8, 3, 4, 1)
                    drawBar(7, 11, 2, 4, 1)

                    return iconFrame
                end

                if iconGlyph == "search" then
                    drawDot(1, 1, 10, 10, 5)
                    drawBar(9, 10, 5, 2, 1).Rotation = 40

                    return iconFrame
                end

                if iconGlyph == "info" then
                    drawDot(2, 2, 12, 12, 6)
                    drawBar(7, 4, 2, 2, 1)
                    drawBar(7, 7, 2, 5, 1)
                end

                return iconFrame
            end
            function createLogoMark(logoParent, logoZ, logoSizeParam)
                local logoSize = logoSizeParam or 18
                local frameProps4 = {
					Name = "KOZUA",
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(logoSize, logoSize),
					ZIndex = logoZ
				}
                local Frame = Instance.new("Frame")

                if frameProps4 then
                    for k, v in pairs(frameProps4) do
                        Frame[k] = v
                    end
                end

                if logoParent then
                    Frame.Parent = logoParent
                end

                local logoImg = ensureLogoAsset(false)
                local imageLabelProps = {
					Name = "Mark",
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Image = logoImg or "",
					ImageColor3 = Color3.new(1, 1, 1),
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = logoZ + 1
				}
                local ImageLabel = Instance.new("ImageLabel")

                if imageLabelProps then
                    for k, v in pairs(imageLabelProps) do
                        ImageLabel[k] = v
                    end
                end

                if Frame then
                    ImageLabel.Parent = Frame
                end

                LogoFrames[#LogoFrames + 1] = Frame

                return Frame
            end

            local function resolveGuiParent()
                if gethui then
                    local ok, result = pcall(gethui)

                    if ok and result then
                        return result
                    end
                end

                local CoreGui = game:GetService("CoreGui")

                if pcall(function()
                    return CoreGui:FindFirstChild("PH_UI")
                end) then
                    return CoreGui
                end

                return LocalPlayer:WaitForChild("PlayerGui")
            end

            local guiParentCandidate = resolveGuiParent()
            local existingTagGui = guiParentCandidate:FindFirstChild(GuiTag)

            if existingTagGui then
                existingTagGui:Destroy()
            end

            local PH_UI = guiParentCandidate:FindFirstChild("PH_UI")

            if PH_UI then
                local KozuaUnloadUid = (getgenv and getgenv() or _G).KozuaUnloadUid

                if KozuaUnloadUid == nil or UserIdStr == tostring(KozuaUnloadUid) then
                    PH_UI:Destroy()
                end
            end

            screenGuiProps = {
				Name = GuiTag,
				ResetOnSpawn = false,
				IgnoreGuiInset = true,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = 1200
			}
            guiParent = resolveGuiParent()
        end

        local ScreenGui = Instance.new("ScreenGui")

        if screenGuiProps then
            for k, v in pairs(screenGuiProps) do
                ScreenGui[k] = v
            end
        end

        if guiParent then
            ScreenGui.Parent = guiParent
        end

        ScreenGui = ScreenGui
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(ScreenGui)
            end
        end)

        local overlayProps = {
			Name = "Overlay",
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			ZIndex = 80
		}
        local TextButton = Instance.new("TextButton")

        if overlayProps then
            for k, v in pairs(overlayProps) do
                TextButton[k] = v
            end
        end

        if ScreenGui then
            TextButton.Parent = ScreenGui
        end

        DropdownOverlay = TextButton

        local scaleProps = {
			Scale = 1
		}
        local UIScale = Instance.new("UIScale")

        if scaleProps then
            for k, v in pairs(scaleProps) do
                UIScale[k] = v
            end
        end

        WindowScale = UIScale

        local windowProps = {
			Name = "Window",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(WinWidth, WinHeight),
			BackgroundColor3 = Theme.bg,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			ZIndex = 10
		}
        local Frame = Instance.new("Frame")

        if windowProps then
            for k, v in pairs(windowProps) do
                Frame[k] = v
            end
        end

        if ScreenGui then
            Frame.Parent = ScreenGui
        end

        Window = Frame
    end

    do
        local windowCornerProps = {
			CornerRadius = UDim.new(0, 12)
		}
        local UICorner = Instance.new("UICorner")

        if windowCornerProps then
            for k, v in pairs(windowCornerProps) do
                UICorner[k] = v
            end
        end

        if Window then
            UICorner.Parent = Window
        end

        local strokeKeyWindow = "line"
        local windowStrokeProps = {
			Color = Theme.line or Theme.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke = Instance.new("UIStroke")

        if windowStrokeProps then
            for k, v in pairs(windowStrokeProps) do
                UIStroke[k] = v
            end
        end

        if Window then
            UIStroke.Parent = Window
        end

        if strokeKeyWindow then
            UIStroke:SetAttribute("th_stroke", strokeKeyWindow)
        end

        WindowScale.Parent = Window

        if Window then
            Window:SetAttribute("th_bg", "bg")

            local bg = Theme.bg

            if bg and Window:IsA("GuiObject") then
                Window.BackgroundColor3 = bg
            end
        end

        local shadowProps = {
			Name = "Shadow",
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.7,
			Position = UDim2.fromOffset(8, 12),
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 9,
			BorderSizePixel = 0
		}
        local Frame = Instance.new("Frame")

        if shadowProps then
            for k, v in pairs(shadowProps) do
                Frame[k] = v
            end
        end

        if Window then
            Frame.Parent = Window
        end

        local Shadow = Window.Shadow
        local shadowCornerProps = {
			CornerRadius = UDim.new(0, 14)
		}
        local UICorner2 = Instance.new("UICorner")

        if shadowCornerProps then
            for k, v in pairs(shadowCornerProps) do
                UICorner2[k] = v
            end
        end

        if Shadow then
            UICorner2.Parent = Shadow
        end
    end

    do
        local headBarProps = {
			Name = "HeadBar",
			BackgroundColor3 = Theme.rail,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 82),
			ZIndex = 11
		}
        local Frame = Instance.new("Frame")

        if headBarProps then
            for k, v in pairs(headBarProps) do
                Frame[k] = v
            end
        end

        if Window then
            Frame.Parent = Window
        end

        if Frame then
            Frame:SetAttribute("th_bg", "rail")

            local rail = Theme.rail

            if rail and Frame:IsA("GuiObject") then
                Frame.BackgroundColor3 = rail
            end
        end

        local uiCornerProps3 = {
			CornerRadius = UDim.new(0, 12)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps3 then
            for k, v in pairs(uiCornerProps3) do
                UICorner[k] = v
            end
        end

        if Frame then
            UICorner.Parent = Frame
        end

        local frameProps5 = {
			BackgroundColor3 = Theme.rail,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -16),
			Size = UDim2.new(1, 0, 0, 16),
			ZIndex = 11
		}
        local Frame4 = Instance.new("Frame")

        if frameProps5 then
            for k, v in pairs(frameProps5) do
                Frame4[k] = v
            end
        end

        if Frame then
            Frame4.Parent = Frame
        end

        if Frame4 then
            Frame4:SetAttribute("th_bg", "rail")

            local rail = Theme.rail

            if rail and Frame4:IsA("GuiObject") then
                Frame4.BackgroundColor3 = rail
            end
        end

        local frameProps6 = {
			Name = "Rail",
			BackgroundColor3 = Theme.rail,
			BorderSizePixel = 0,
			Size = UDim2.new(0, SidebarWidth, 1, 0),
			ZIndex = 11
		}
        local Frame5 = Instance.new("Frame")

        if frameProps6 then
            for k, v in pairs(frameProps6) do
                Frame5[k] = v
            end
        end

        if Window then
            Frame5.Parent = Window
        end

        Sidebar = Frame5

        if Sidebar then
            Sidebar:SetAttribute("th_bg", "rail")

            local rail = Theme.rail

            if rail and Sidebar:IsA("GuiObject") then
                Sidebar.BackgroundColor3 = rail
            end
        end

        local uiCornerProps4 = {
			CornerRadius = UDim.new(0, 12)
		}
        local UICorner3 = Instance.new("UICorner")

        if uiCornerProps4 then
            for k, v in pairs(uiCornerProps4) do
                UICorner3[k] = v
            end
        end

        if Sidebar then
            UICorner3.Parent = Sidebar
        end
    end

    local SidebarScroll, HeaderTitle, HeaderSubtitle

    do
        local Frame, TextLabel

        do
            local frameProps7 = {
				BackgroundColor3 = Theme.rail,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -16, 0, 0),
				Size = UDim2.new(0, 16, 1, 0),
				ZIndex = 11
			}
            local Frame6 = Instance.new("Frame")

            if frameProps7 then
                for k, v in pairs(frameProps7) do
                    Frame6[k] = v
                end
            end

            if Sidebar then
                Frame6.Parent = Sidebar
            end

            if Frame6 then
                Frame6:SetAttribute("th_bg", "rail")

                local rail = Theme.rail

                if rail and Frame6:IsA("GuiObject") then
                    Frame6.BackgroundColor3 = rail
                end
            end

            local frameProps8 = {
				BackgroundColor3 = Theme.line,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -1, 0, 2),
				Size = UDim2.new(0, 1, 1, -2),
				ZIndex = 12
			}
            local Frame7 = Instance.new("Frame")

            if frameProps8 then
                for k, v in pairs(frameProps8) do
                    Frame7[k] = v
                end
            end

            if Sidebar then
                Frame7.Parent = Sidebar
            end

            if Frame7 then
                Frame7:SetAttribute("th_bg", "line")

                local line = Theme.line

                if line and Frame7:IsA("GuiObject") then
                    Frame7.BackgroundColor3 = line
                end
            end

            Sidebar.Active = true

            local scrollingFrameProps = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -18),
				Position = UDim2.fromOffset(0, 12),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = not IsMobile and 0 or 5,
				BorderSizePixel = 0,
				ZIndex = 12
			}
            local ScrollingFrame = Instance.new("ScrollingFrame")

            if scrollingFrameProps then
                for k, v in pairs(scrollingFrameProps) do
                    ScrollingFrame[k] = v
                end
            end

            if Sidebar then
                ScrollingFrame.Parent = Sidebar
            end

            SidebarScroll = ScrollingFrame
            applyPadding(SidebarScroll, 10, 2, 10, 12)

            local uiListLayoutProps = {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 3),
				SortOrder = Enum.SortOrder.LayoutOrder
			}
            local UIListLayout = Instance.new("UIListLayout")

            if uiListLayoutProps then
                for k, v in pairs(uiListLayoutProps) do
                    UIListLayout[k] = v
                end
            end

            if SidebarScroll then
                UIListLayout.Parent = SidebarScroll
            end

            local frameProps9 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 40),
				LayoutOrder = 0,
				ZIndex = 12
			}

            Frame = Instance.new("Frame")

            if frameProps9 then
                for k, v in pairs(frameProps9) do
                    Frame[k] = v
                end
            end

            if SidebarScroll then
                Frame.Parent = SidebarScroll
            end

            createLogoMark(Frame, 13, 28).Position = UDim2.fromOffset(0, 2)

            local sidebarTitleProps = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(34, 3),
				Size = UDim2.new(1, -34, 0, 16),
				Font = Fonts.title,
				Text = HubInfo.Title,
				TextColor3 = Theme.text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 13
			}

            TextLabel = Instance.new("TextLabel")

            if sidebarTitleProps then
                for k, v in pairs(sidebarTitleProps) do
                    TextLabel[k] = v
                end
            end
        end

        if Frame then
            TextLabel.Parent = Frame
        end

        if TextLabel then
            TextLabel:SetAttribute("th_text", "text")

            local text = Theme.text

            if text then
                TextLabel.TextColor3 = text
            end
        end

        local textLabelProps = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(34, 20),
			Size = UDim2.new(1, -34, 0, 12),
			Font = Fonts.mono,
			Text = HubInfo.Product,
			TextColor3 = Theme.mute,
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 13
		}
        local TextLabel2 = Instance.new("TextLabel")

        if textLabelProps then
            for k, v in pairs(textLabelProps) do
                TextLabel2[k] = v
            end
        end

        if Frame then
            TextLabel2.Parent = Frame
        end

        if TextLabel2 then
            TextLabel2:SetAttribute("th_text", "mute")

            local mute = Theme.mute

            if mute then
                TextLabel2.TextColor3 = mute
            end
        end

        local frameProps10 = {
			Name = "Main",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(SidebarWidth, 2),
			Size = UDim2.new(1, -SidebarWidth, 1, -2),
			ZIndex = 11
		}
        local Frame8 = Instance.new("Frame")

        if frameProps10 then
            for k, v in pairs(frameProps10) do
                Frame8[k] = v
            end
        end

        if Window then
            Frame8.Parent = Window
        end

        MainPage = Frame8

        local frameProps11 = {
			Name = "Header",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 46),
			ZIndex = 12,
			Active = true
		}
        local Frame9 = Instance.new("Frame")

        if frameProps11 then
            for k, v in pairs(frameProps11) do
                Frame9[k] = v
            end
        end

        if MainPage then
            Frame9.Parent = MainPage
        end

        Header = Frame9

        local textLabelProps2 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 8),
			Size = UDim2.new(1, -180, 0, 18),
			Font = Fonts.title,
			Text = "Auto Steal",
			TextColor3 = Theme.text,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 12
		}
        local TextLabel3 = Instance.new("TextLabel")

        if textLabelProps2 then
            for k, v in pairs(textLabelProps2) do
                TextLabel3[k] = v
            end
        end

        if Header then
            TextLabel3.Parent = Header
        end

        HeaderTitle = TextLabel3

        if HeaderTitle then
            HeaderTitle:SetAttribute("th_text", "text")

            local text = Theme.text

            if text then
                HeaderTitle.TextColor3 = text
            end
        end

        local textLabelProps3 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 26),
			Size = UDim2.new(1, -180, 0, 14),
			Font = Fonts.body,
			Text = "idle",
			TextColor3 = Theme.dim,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 12
		}
        local TextLabel4 = Instance.new("TextLabel")

        if textLabelProps3 then
            for k, v in pairs(textLabelProps3) do
                TextLabel4[k] = v
            end
        end

        if Header then
            TextLabel4.Parent = Header
        end

        HeaderSubtitle = TextLabel4
    end

    if HeaderSubtitle then
        HeaderSubtitle:SetAttribute("th_text", "dim")

        local dim = Theme.dim

        if dim then
            HeaderSubtitle.TextColor3 = dim
        end
    end

    local Frame, UIStroke

    do
        local function makeHeaderPill(pillWidth, pillXOffset)
            local headerPillProps = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme.card,
				Position = UDim2.new(1, pillXOffset, 0.5, 2),
				Size = UDim2.fromOffset(pillWidth, 22),
				Font = Fonts.mono,
				Text = "—",
				TextColor3 = Theme.dim,
				TextSize = 10,
				ZIndex = 12
			}
            local headerParent = Header
            local TextLabel = Instance.new("TextLabel")

            if headerPillProps then
                for k, v in pairs(headerPillProps) do
                    TextLabel[k] = v
                end
            end

            if headerParent then
                TextLabel.Parent = headerParent
            end

            local uiCornerProps5 = {
				CornerRadius = UDim.new(0, 7)
			}
            local UICorner = Instance.new("UICorner")

            if uiCornerProps5 then
                for k, v in pairs(uiCornerProps5) do
                    UICorner[k] = v
                end
            end

            if TextLabel then
                UICorner.Parent = TextLabel
            end

            local strokeKeyPill = "line"
            local uiStrokeProps2 = {
				Color = Theme.line or Theme.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke2 = Instance.new("UIStroke")

            if uiStrokeProps2 then
                for k, v in pairs(uiStrokeProps2) do
                    UIStroke2[k] = v
                end
            end

            if TextLabel then
                UIStroke2.Parent = TextLabel
            end

            if strokeKeyPill then
                UIStroke2:SetAttribute("th_stroke", strokeKeyPill)
            end

            if TextLabel then
                TextLabel:SetAttribute("th_bg", "card")

                local card = Theme.card

                if card and TextLabel:IsA("GuiObject") then
                    TextLabel.BackgroundColor3 = card
                end
            end

            if TextLabel then
                TextLabel:SetAttribute("th_text", "dim")

                local dim = Theme.dim

                if not dim then
                    return TextLabel
                end

                TextLabel.TextColor3 = dim
            end

            return TextLabel
        end

        local minButtonProps = {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Theme.card,
			Position = UDim2.new(1, -12, 0.5, 2),
			Size = UDim2.fromOffset(not IsMobile and 22 or 32, not IsMobile and 22 or 32),
			Font = Fonts.mid,
			Text = "–",
			TextColor3 = Theme.dim,
			TextSize = 14,
			AutoButtonColor = false,
			ZIndex = 12
		}
        local TextButton = Instance.new("TextButton")

        if minButtonProps then
            for k, v in pairs(minButtonProps) do
                TextButton[k] = v
            end
        end

        if Header then
            TextButton.Parent = Header
        end

        MinimizeButton = TextButton

        local uiCornerProps6 = {
			CornerRadius = UDim.new(0, 7)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps6 then
            for k, v in pairs(uiCornerProps6) do
                UICorner[k] = v
            end
        end

        if MinimizeButton then
            UICorner.Parent = MinimizeButton
        end

        local strokeKeyMinBtn = "line"
        local uiStrokeProps3 = {
			Color = Theme.line or Theme.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke3 = Instance.new("UIStroke")

        if uiStrokeProps3 then
            for k, v in pairs(uiStrokeProps3) do
                UIStroke3[k] = v
            end
        end

        if MinimizeButton then
            UIStroke3.Parent = MinimizeButton
        end

        if strokeKeyMinBtn then
            UIStroke3:SetAttribute("th_stroke", strokeKeyMinBtn)
        end

        bindHoverTheme(MinimizeButton, "card", "lift")

        if MinimizeButton then
            MinimizeButton:SetAttribute("th_text", "dim")

            local dim = Theme.dim

            if dim then
                MinimizeButton.TextColor3 = dim
            end
        end

        HeaderStatPill1 = makeHeaderPill(52, -54)
        HeaderStatPill2 = makeHeaderPill(56, -110)

        local frameProps12 = {
			BackgroundColor3 = Theme.card,
			Position = UDim2.fromOffset(14, 46),
			Size = UDim2.new(1, -28, 0, not IsMobile and 28 or 36),
			ZIndex = 12
		}

        Frame = Instance.new("Frame")

        if frameProps12 then
            for k, v in pairs(frameProps12) do
                Frame[k] = v
            end
        end

        if MainPage then
            Frame.Parent = MainPage
        end

        local uiCornerProps7 = {
			CornerRadius = UDim.new(0, 9)
		}
        local UICorner4 = Instance.new("UICorner")

        if uiCornerProps7 then
            for k, v in pairs(uiCornerProps7) do
                UICorner4[k] = v
            end
        end

        if Frame then
            UICorner4.Parent = Frame
        end

        if Frame then
            Frame:SetAttribute("th_bg", "card")

            local card = Theme.card

            if card and Frame:IsA("GuiObject") then
                Frame.BackgroundColor3 = card
            end
        end

        local strokeKeySearch = "line"
        local uiStrokeProps4 = {
			Color = Theme.line or Theme.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}

        UIStroke = Instance.new("UIStroke")

        if uiStrokeProps4 then
            for k, v in pairs(uiStrokeProps4) do
                UIStroke[k] = v
            end
        end

        if Frame then
            UIStroke.Parent = Frame
        end

        if strokeKeySearch then
            UIStroke:SetAttribute("th_stroke", strokeKeySearch)
        end
    end

    local searchStroke = UIStroke

    SearchIcon = drawIcon(Frame, "search", Theme.mute, 13)
    SearchIcon.Position = UDim2.fromOffset(8, 6)

    local searchBoxProps = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.fromOffset(30, 0),
		Font = Fonts.body,
		PlaceholderText = "Filter this page",
		PlaceholderColor3 = Theme.mute,
		Text = "",
		TextColor3 = Theme.text,
		TextSize = not IsMobile and 12 or 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 13
	}
    local TextBox = Instance.new("TextBox")

    if searchBoxProps then
        for k, v in pairs(searchBoxProps) do
            TextBox[k] = v
        end
    end

    if Frame then
        TextBox.Parent = Frame
    end

    SearchBox = TextBox

    if SearchBox then
        SearchBox:SetAttribute("th_text", "text")

        local text = Theme.text

        if text then
            SearchBox.TextColor3 = text
        end
    end

    if SearchBox then
        SearchBox:SetAttribute("th_placeholder", "mute")

        local mute = Theme.mute

        if mute and SearchBox:IsA("TextBox") then
            SearchBox.PlaceholderColor3 = mute
        end
    end

    SearchBox.Focused:Connect(function()
        tween(searchStroke, 0.12, {
			Color = Theme.accent
		})
    end)
    SearchBox.FocusLost:Connect(function()
        tween(searchStroke, 0.12, {
			Color = Theme.line
		})
    end)

    local contentTop = not IsMobile and 80 or 88
    local frameProps13 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, contentTop),
		Size = UDim2.new(1, 0, 1, -contentTop),
		ClipsDescendants = true,
		ZIndex = 12
	}
    local Frame10 = Instance.new("Frame")

    if frameProps13 then
        for k, v in pairs(frameProps13) do
            Frame10[k] = v
        end
    end

    if MainPage then
        Frame10.Parent = MainPage
    end

    local tabContentClip = Frame10

    function CreateTab(tabName, tabSubtitle)
        local tabScrollProps = {
			Name = tabName,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = not IsMobile and 4 or 8,
			ScrollBarImageColor3 = Theme.line,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 13
		}
        local tabContainer = tabContentClip
        local ScrollingFrame = Instance.new("ScrollingFrame")

        if tabScrollProps then
            for k, v in pairs(tabScrollProps) do
                ScrollingFrame[k] = v
            end
        end

        if tabContainer then
            ScrollingFrame.Parent = tabContainer
        end

        if ScrollingFrame then
            ScrollingFrame:SetAttribute("th_scroll", "line")

            local line = Theme.line

            if line and ScrollingFrame:IsA("ScrollingFrame") then
                ScrollingFrame.ScrollBarImageColor3 = line
            end
        end

        applyPadding(ScrollingFrame, 12, 4, 12, 14)

        local uiListLayoutProps2 = {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder
		}
        local UIListLayout = Instance.new("UIListLayout")

        if uiListLayoutProps2 then
            for k, v in pairs(uiListLayoutProps2) do
                UIListLayout[k] = v
            end
        end

        if ScrollingFrame then
            UIListLayout.Parent = ScrollingFrame
        end

        local newTabRecord = {
			name = tabName,
			subtitle = tabSubtitle,
			scroll = ScrollingFrame,
			items = {},
			n = 0,
			card = nil,
			lastRule = nil
		}

        TabRegistry[tabName] = newTabRecord
        TabOrder[#TabOrder + 1] = tabName

        return newTabRecord
    end

    local SidebarButtons = {}

    function AddSectionHeader(sectionTitle, sectionTabs, sectionOrder)
        local sectionHeaderProps = {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Fonts.mono,
			Text = sectionTitle,
			TextColor3 = Theme.mute,
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = sectionOrder,
			ZIndex = 12
		}
        local sidebarParentA = SidebarScroll
        local TextLabel = Instance.new("TextLabel")

        if sectionHeaderProps then
            for k, v in pairs(sectionHeaderProps) do
                TextLabel[k] = v
            end
        end

        if sidebarParentA then
            TextLabel.Parent = sidebarParentA
        end

        if TextLabel then
            TextLabel:SetAttribute("th_text", "mute")

            local mute = Theme.mute

            if mute then
                TextLabel.TextColor3 = mute
            end
        end

        for i, v in ipairs(sectionTabs) do
            local textButtonProps = {
				BackgroundColor3 = Theme.rail,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, not IsMobile and 26 or 34),
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = sectionOrder + i,
				ZIndex = 12
			}
            local sidebarParentB = SidebarScroll
            local TextButton = Instance.new("TextButton")

            if textButtonProps then
                for k, propVal2 in pairs(textButtonProps) do
                    TextButton[k] = propVal2
                end
            end

            if sidebarParentB then
                TextButton.Parent = sidebarParentB
            end

            local tabButton = TextButton
            local uiCornerProps8 = {
				CornerRadius = UDim.new(0, 6)
			}
            local UICorner = Instance.new("UICorner")

            if uiCornerProps8 then
                for k, propVal3 in pairs(uiCornerProps8) do
                    UICorner[k] = propVal3
                end
            end

            if tabButton then
                UICorner.Parent = tabButton
            end

            local tabIcon = drawIcon(tabButton, TabIcons[v] or "layers", Theme.mute, 13)

            tabIcon.Name = "Ico"
            tabIcon.Position = UDim2.fromOffset(6, 5)

            local textLabelProps4 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(26, 0),
				Size = UDim2.new(1, -30, 1, 0),
				Font = Fonts.body,
				Text = v,
				TextColor3 = Theme.dim,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 13
			}
            local TextLabel5 = Instance.new("TextLabel")

            if textLabelProps4 then
                for k, propVal5 in pairs(textLabelProps4) do
                    TextLabel5[k] = propVal5
                end
            end

            if tabButton then
                TextLabel5.Parent = tabButton
            end

            if TextLabel5 then
                TextLabel5:SetAttribute("th_text", "dim")

                local dim = Theme.dim

                if dim then
                    TextLabel5.TextColor3 = dim
                end
            end

            SidebarButtons[v] = {
				btn = tabButton,
				lab = TextLabel5,
				ico = tabIcon
			}
            tabButton.MouseEnter:Connect(function()
                if SidebarButtons[v].on then
                    return
                end

                tween(tabButton, 0.12, {
					BackgroundTransparency = 0,
					BackgroundColor3 = Theme.lift
				})
            end)
            tabButton.MouseLeave:Connect(function()
                if SidebarButtons[v].on then
                    return
                end

                tween(tabButton, 0.12, {
					BackgroundTransparency = 1
				})
            end)
            tabButton.MouseButton1Click:Connect(function()
                SelectTab(v)
            end)
        end
    end
    function tintIcon(tintRoot, tintColor)
        for _, descendant in ipairs(tintRoot:GetDescendants()) do
            if descendant:IsA("ImageLabel") then
                descendant.ImageColor3 = tintColor
            elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
                descendant.BackgroundColor3 = tintColor
            elseif descendant:IsA("UIStroke") then
                descendant.Color = tintColor
            end
        end
    end
    function SelectTab(selectName)
        local tabRecord = TabRegistry[selectName]

        if not tabRecord then
            return
        end

        ActiveTab = tabRecord

        for k, v in pairs(SidebarButtons) do
            local isSelected = k == selectName

            v.on = isSelected
            v.lab.TextColor3 = isSelected and Theme.text or Theme.dim
            v.lab.Font = isSelected and Fonts.mid or Fonts.body
            v.btn.BackgroundColor3 = isSelected and Theme.card or Theme.rail
            v.btn.BackgroundTransparency = not isSelected and 1 or 0
            tintIcon(v.ico, isSelected and Theme.accent or Theme.mute)
        end

        for _, v in pairs(TabRegistry) do
            v.scroll.Visible = v == tabRecord

            if v == tabRecord then
                v.scroll.CanvasPosition = Vector2.zero
            end
        end

        HeaderTitle.Text = selectName
        HeaderSubtitle.Text = tabRecord.subtitle or ""
        FilterTabItems(tabRecord, SearchBox.Text)
    end
    function FilterTabItems(filterTab, filterQuery)
        local queryLower = string.lower(filterQuery or "")
        local inst
        local sectionHasMatch = false
        for _, v in ipairs(filterTab.items) do
            if v.kind == "section" then
                if inst then
                    inst.Visible = queryLower == "" or sectionHasMatch
                end

                inst = v.inst
                sectionHasMatch = false
            else
                local itemMatches = (queryLower == "" or string.find(v.q, queryLower, 1, true) ~= nil) and (not v.visibleIf or v.visibleIf() or false)

                v.inst.Visible = itemMatches

                if itemMatches then
                    sectionHasMatch = true
                end
            end
        end
        if inst then
            inst.Visible = queryLower == "" or sectionHasMatch
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if ActiveTab then
            FilterTabItems(ActiveTab, SearchBox.Text)
        end
    end)

    function BuildCard(cardTab, cardTitle)
        cardTab.lastRule = nil

        local cardProps = {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Theme.card,
			BorderSizePixel = 0
		}

        cardTab.n = cardTab.n + 1
        cardProps.LayoutOrder = cardTab.n
        cardProps.ZIndex = 13

        local scroll = cardTab.scroll
        local Frame11 = Instance.new("Frame")

        if cardProps then
            for k, v in pairs(cardProps) do
                Frame11[k] = v
            end
        end

        if scroll then
            Frame11.Parent = scroll
        end

        local uiCornerProps9 = {
			CornerRadius = UDim.new(0, 8)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps9 then
            for k, v in pairs(uiCornerProps9) do
                UICorner[k] = v
            end
        end

        if Frame11 then
            UICorner.Parent = Frame11
        end

        local strokeKeyCard = "line"
        local uiStrokeProps5 = {
			Color = Theme.line or Theme.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke4 = Instance.new("UIStroke")

        if uiStrokeProps5 then
            for k, v in pairs(uiStrokeProps5) do
                UIStroke4[k] = v
            end
        end

        if Frame11 then
            UIStroke4.Parent = Frame11
        end

        if strokeKeyCard then
            UIStroke4:SetAttribute("th_stroke", strokeKeyCard)
        end

        if Frame11 then
            Frame11:SetAttribute("th_bg", "card")

            local card = Theme.card

            if card and Frame11:IsA("GuiObject") then
                Frame11.BackgroundColor3 = card
            end
        end

        local uiListLayoutProps3 = {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}
        local UIListLayout = Instance.new("UIListLayout")

        if uiListLayoutProps3 then
            for k, v in pairs(uiListLayoutProps3) do
                UIListLayout[k] = v
            end
        end

        if Frame11 then
            UIListLayout.Parent = Frame11
        end

        local frameProps14 = {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = 0,
			ZIndex = 14
		}
        local Frame12 = Instance.new("Frame")

        if frameProps14 then
            for k, v in pairs(frameProps14) do
                Frame12[k] = v
            end
        end

        if Frame11 then
            Frame12.Parent = Frame11
        end

        local frameProps15 = {
			BackgroundColor3 = Theme.accent,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(10, 2),
			ZIndex = 15
		}
        local Frame13 = Instance.new("Frame")

        if frameProps15 then
            for k, v in pairs(frameProps15) do
                Frame13[k] = v
            end
        end

        if Frame12 then
            Frame13.Parent = Frame12
        end

        if Frame13 then
            Frame13:SetAttribute("th_bg", "accent")

            local accent = Theme.accent

            if accent and Frame13:IsA("GuiObject") then
                Frame13.BackgroundColor3 = accent
            end
        end

        local textLabelProps5 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(28, 0),
			Size = UDim2.new(1, -36, 1, 0),
			Font = Fonts.mono,
			Text = cardTitle,
			TextColor3 = Theme.dim,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 15
		}
        local TextLabel = Instance.new("TextLabel")

        if textLabelProps5 then
            for k, v in pairs(textLabelProps5) do
                TextLabel[k] = v
            end
        end

        if Frame12 then
            TextLabel.Parent = Frame12
        end

        local TextLabel6 = Frame12:FindFirstChildWhichIsA("TextLabel")

        if TextLabel6 then
            TextLabel6:SetAttribute("th_text", "dim")

            local dim = Theme.dim

            if dim then
                TextLabel6.TextColor3 = dim
            end
        end

        cardTab.card = Frame11
        cardTab.items[#cardTab.items + 1] = {
			kind = "section",
			inst = Frame11,
			q = string.lower(cardTitle)
		}

        return Frame11
    end

    local function BuildRow(rowTab, rowTitle, rowDesc, rowControlW)
        local rowHeightParam = rowControlW or (not IsMobile and 132 or 140)
        local rowParent = rowTab.card or rowTab.scroll
        local rowHeight = not rowDesc and 36 or 46
        if IsMobile then
            rowHeight = not rowDesc and 44 or 54
        end
        local frameProps16 = {
			BackgroundColor3 = Theme.card,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, rowHeight)
		}
        rowTab.n = rowTab.n + 1
        frameProps16.LayoutOrder = rowTab.n
        frameProps16.ZIndex = 14
        local Frame14 = Instance.new("Frame")
        if frameProps16 then
            for k, v in pairs(frameProps16) do
                Frame14[k] = v
            end
        end
        if rowParent then
            Frame14.Parent = rowParent
        end
        local rowFrame = Frame14
        local frameProps17 = {
			BackgroundColor3 = Theme.line,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -28, 0, 1),
			Visible = rowTab.lastRule ~= nil,
			ZIndex = 15
		}
        local Frame15 = Instance.new("Frame")
        if frameProps17 then
            for k, v in pairs(frameProps17) do
                Frame15[k] = v
            end
        end
        if rowFrame then
            Frame15.Parent = rowFrame
        end
        rowTab.lastRule = Frame15
        if Frame15 then
            Frame15:SetAttribute("th_bg", "line")

            local line = Theme.line

            if line and Frame15:IsA("GuiObject") then
                Frame15.BackgroundColor3 = line
            end
        end
        if rowFrame then
            rowFrame:SetAttribute("th_bg", "card")

            local card = Theme.card

            if card and rowFrame:IsA("GuiObject") then
                rowFrame.BackgroundColor3 = card
            end
        end
        rowFrame:SetAttribute("th_hover", "lift")
        rowFrame:SetAttribute("th_row", true)
        rowFrame.MouseEnter:Connect(function()
            rowFrame:SetAttribute("th_over", true)
            tween(rowFrame, 0.1, {
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.lift
			})
        end)
        rowFrame.MouseLeave:Connect(function()
            rowFrame:SetAttribute("th_over", false)
            tween(rowFrame, 0.1, {
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme.card
			})
        end)
        local rowTitleProps = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, not rowDesc and 10 or 6),
			Size = UDim2.new(1, -(rowHeightParam + 20), 0, 14),
			Font = Fonts.mid,
			Text = rowTitle,
			TextColor3 = Theme.text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 15
		}
        local TextLabel = Instance.new("TextLabel")
        if rowTitleProps then
            for k, v in pairs(rowTitleProps) do
                TextLabel[k] = v
            end
        end
        if rowFrame then
            TextLabel.Parent = rowFrame
        end
        if TextLabel then
            TextLabel:SetAttribute("th_text", "text")

            local text = Theme.text

            if text then
                TextLabel.TextColor3 = text
            end
        end
        local TextLabel7
        if rowDesc then
            local rowDescProps = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 22),
				Size = UDim2.new(1, -(rowHeightParam + 20), 0, 20),
				Font = Fonts.body,
				Text = rowDesc,
				TextColor3 = Theme.dim,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				ZIndex = 15
			}

            TextLabel7 = Instance.new("TextLabel")

            if rowDescProps then
                for k, v in pairs(rowDescProps) do
                    TextLabel7[k] = v
                end
            end

            if rowFrame then
                TextLabel7.Parent = rowFrame
            end

            if TextLabel7 then
                TextLabel7:SetAttribute("th_text", "dim")

                local dim = Theme.dim

                if dim then
                    TextLabel7.TextColor3 = dim
                end
            end
        end
        local frameProps18 = {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(rowHeightParam, not IsMobile and 26 or 32),
			ZIndex = 16
		}
        local Frame16 = Instance.new("Frame")
        if frameProps18 then
            for k, v in pairs(frameProps18) do
                Frame16[k] = v
            end
        end
        if rowFrame then
            Frame16.Parent = rowFrame
        end
        rowTab.items[#rowTab.items + 1] = {
			kind = "row",
			inst = rowFrame,
			q = string.lower(rowTitle .. " " .. (rowDesc or ""))
		}

        return rowFrame, Frame16, TextLabel7
    end

    IsApplyingConfig = false
    IsSavingDebounced = false

    local TransientSkipKeys = {
		ImportPaste = true,
		Flight = true,
		HopNearNight = true,
		CfgSaveName = true,
		PhoneUI = true
	}

    ConfigGen = getUserSlot().gen or 1

    local function cfgWarn(...)
        warn("[kozua/cfg]", ...)
    end

    function collectConfig()
        for k, v in pairs(WidgetRegistry) do
            if v and v.kind == "input" and v.box then
                pcall(function()
                    local boxText = v.box.Text

                    if type(boxText) ~= "string" then
                        return
                    end

                    if boxText ~= "" or Config[k] == nil or Config[k] == "" then
                        Config[k] = boxText
                    end
                end)
            end
        end

        local SerializableConfig = {}

        for k, v in pairs(Config) do
            if not TransientSkipKeys[k] and (k ~= "HookUrl" or Config.ExportUrl) then
                local cfgValType = type(v)

                if cfgValType == "boolean" or cfgValType == "number" or cfgValType == "string" then
                    SerializableConfig[k] = v
                elseif cfgValType == "table" then
                    SerializableConfig[k] = v
                else
                    local ok, result = pcall(function()
                        return v.Name
                    end)

                    if ok and type(result) == "string" then
                        SerializableConfig[k] = result
                    end
                end
            end
        end

        return SerializableConfig
    end

    local function ensureWriteFile(filePath, fileContent)
        if type(filePath) ~= "string" or filePath == "" then
            return false
        end

        if type(makefolder) == "function" then
            pcall(makefolder, "kozua")
        end

        local gameDir = "kozua" .. "/" .. sanitizeFileName(HubInfo.Game)

        if type(makefolder) == "function" then
            pcall(makefolder, gameDir)
        end

        local cacheDir = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache"

        if type(makefolder) == "function" then
            pcall(makefolder, cacheDir)
        end

        local configsDir = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/configs"

        if type(makefolder) == "function" then
            pcall(makefolder, configsDir)
        end

        local parentDir = filePath:match("^(.*)/[^/]+$")

        if parentDir and type(makefolder) == "function" then
            pcall(makefolder, parentDir)
        end

        local ok, result = pcall(writefile, filePath, fileContent)

        if not ok then
            cfgWarn("write fail", filePath, (tostring(result)))

            return false
        end

        return true
    end

    function saveConfig(forceSave)
        if IsApplyingConfig and not forceSave then
            return
        end

        if not writefile then
            cfgWarn("writefile missing")

            return
        end

        local ok, result = pcall(function()
            return HttpService:JSONEncode((collectConfig()))
        end)

        if not ok or type(result) ~= "string" then
            cfgWarn("encode fail", (tostring(result)))

            return
        end

        if not ensureWriteFile((("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/" .. sanitizeFileName(LocalPlayer and LocalPlayer.Name or "Player") .. "-config.json", result) then
            ensureWriteFile((("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/" .. UserIdStr .. "-config.json", result)
        end
    end

    local function coerceConfigValue(cfgKey, cfgValue)
        local keybindWidget = WidgetRegistry[cfgKey]

        if keybindWidget and (keybindWidget.kind == "keybind" and type(cfgValue) == "string") then
            local ok, result = pcall(function()
                return Enum.KeyCode[cfgValue]
            end)

            if ok and result then
                return result
            end
        end

        if cfgKey == "Theme" and (cfgValue == "Dusk" or cfgValue == "dusk") then
            return "Dark"
        end

        return cfgValue
    end

    function applyConfig(cfgTable, fromLoad)
        if type(cfgTable) ~= "table" then
            return
        end

        IsApplyingConfig = true

        local ok, result = pcall(function()
            if cfgTable.NeverTraps == true then
                cfgTable.AntiTrap = true
            end

            cfgTable.NeverTraps = nil
            cfgTable.RarityZones = nil
            cfgTable.HopMinPlayers = nil
            cfgTable.HopMaxPlayers = nil
            cfgTable.AntiDie = nil

            if cfgTable.StealMode == "Rarity snipe" then
                cfgTable.StealMode = "Egg type filter"
            end

            for k, v in pairs(cfgTable) do
                if k ~= "ImportPaste" then
                    local coercedVal = coerceConfigValue(k, v)
                    local targetWidget = WidgetRegistry[k]

                    if targetWidget and targetWidget.set then
                        pcall(targetWidget.set, coercedVal)

                        if fromLoad and targetWidget.on and targetWidget.kind ~= "slider" and k ~= "Flight" and k ~= "CfgPreset" then
                            pcall(targetWidget.on, Config[k])
                        end
                    else
                        Config[k] = coercedVal
                    end
                end
            end
        end)

        IsApplyingConfig = false

        if not ok then
            cfgWarn("apply fail", (tostring(result)))
        end
    end

    local function readJsonFile(jsonPath)
        if type(jsonPath) ~= "string" or jsonPath == "" or not readfile then
            return
        end

        local ok, result = pcall(readfile, jsonPath)

        if ok and type(result) == "string" and result ~= "" then
            local ok2, result2 = pcall(function()
                return HttpService:JSONDecode(result)
            end)

            if ok2 and type(result2) == "table" then
                return result2, jsonPath
            end
        end
    end
    local function listConfigNames()
        local PresetNameList = { "default" }
        local PresetNameSet = {
			default = true
		}

        if type(listfiles) == "function" then
            local ok, result = pcall(listfiles, ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/configs")

            if ok and type(result) == "table" then
                for i = 1, #result do
                    local presetName = tostring(result[i] or ""):gsub("\\", "/"):match("([^/]+)%.json$")

                    if presetName and not PresetNameSet[presetName] then
                        PresetNameSet[presetName] = true
                        PresetNameList[#PresetNameList + 1] = presetName
                    end
                end
            end
        elseif type(isfile) == "function" then
            local presetRaw = tostring(Config.CfgPreset or ""):gsub("^%s+", ""):gsub("%s+$", "")
            local presetNorm = if presetRaw ~= "" then sanitizeFileName(presetRaw) else "default"

            if presetNorm ~= "default" and not PresetNameSet[presetNorm] then
                PresetNameList[#PresetNameList + 1] = presetNorm
            end
        end

        table.sort(PresetNameList, function(sortA, sortB)
            if sortA == "default" then
                return true
            end

            if sortB == "default" then
                return false
            end

            return sortA < sortB
        end)

        return PresetNameList
    end

    function refreshPresetOptions()
        local CfgPreset = WidgetRegistry.CfgPreset

        if not CfgPreset or not CfgPreset.options then
            return
        end

        local presetList = listConfigNames()

        for i = #CfgPreset.options, 1, -1 do
            CfgPreset.options[i] = nil
        end

        for i = 1, #presetList do
            CfgPreset.options[i] = presetList[i]
        end

        local currentRaw = tostring(Config.CfgPreset or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local currentNorm = if currentRaw ~= "" then sanitizeFileName(currentRaw) else "default"
        local presetFound = false

        for i = 1, #presetList do
            if currentNorm == presetList[i] then
                presetFound = true

                break
            end
        end

        if not presetFound then
            currentNorm = "default"
            Config.CfgPreset = currentNorm
        end

        if CfgPreset.set then
            pcall(CfgPreset.set, currentNorm)

            return
        end

        if CfgPreset.refresh then
            pcall(CfgPreset.refresh)
        end
    end
    function saveNamedConfig(presetNameToSave)
        local saveRaw = tostring(presetNameToSave or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local saveNorm = if saveRaw ~= "" then sanitizeFileName(saveRaw) else "default"
        local ok, result = pcall(function()
            return HttpService:JSONEncode((collectConfig()))
        end)

        if not ok or type(result) ~= "string" then
            cfgWarn("named encode fail", (tostring(result)))

            return false
        end

        local writeFn = ensureWriteFile
        local configDirPath = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/configs"
        local fileBase = tostring(saveNorm or ""):gsub("^%s+", ""):gsub("%s+$", "")

        if not writeFn(configDirPath .. "/" .. ((if fileBase ~= "" then sanitizeFileName(fileBase) else "default")) .. ".json", result) then
            return false
        end

        Config.CfgPreset = saveNorm
        refreshPresetOptions()
        cfgWarn("saved named", saveNorm)

        return true
    end
    function loadNamedConfig(presetNameToLoad, fireAfterLoad)
        local loadRaw = tostring(presetNameToLoad or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local loadNorm = if loadRaw ~= "" then sanitizeFileName(loadRaw) else "default"
        local readFn = readJsonFile
        local loadDir = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/configs"
        local loadBase = tostring(loadNorm or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local loadedTable, loadedPath = readFn(loadDir .. "/" .. ((if loadBase ~= "" then sanitizeFileName(loadBase) else "default")) .. ".json")

        if not loadedTable then
            cfgWarn("no named config", loadNorm)

            return false
        end

        applyConfig(loadedTable, fireAfterLoad)
        Config.Flight = false

        if WidgetRegistry.Flight and WidgetRegistry.Flight.set then
            pcall(WidgetRegistry.Flight.set, false)
        end

        Config.CfgPreset = loadNorm
        ApplyTheme(Config.Theme or "Dark")

        local num = tonumber(Config.UIScale)

        if num then
            WindowScale.Scale = num / 100
        end

        saveConfig(true)
        cfgWarn("loaded named", loadedPath)

        return true
    end
    function loadAutoConfig(autoFire)
        if not readfile then
            cfgWarn("readfile missing")

            return false
        end

        local autoTable, autoPath = readJsonFile((("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/" .. sanitizeFileName(LocalPlayer and LocalPlayer.Name or "Player") .. "-config.json")

        if not autoTable then
            autoTable, autoPath = readJsonFile((("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/" .. UserIdStr .. "-config.json")
        end

        if not autoTable then
            local readFn2 = readJsonFile
            local defaultDir = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/configs"
            local defaultBase = tostring("default" or ""):gsub("^%s+", ""):gsub("%s+$", "")

            autoTable, autoPath = readFn2(defaultDir .. "/" .. ((if defaultBase ~= "" then sanitizeFileName(defaultBase) else "default")) .. ".json")
        end

        if not autoTable then
            local LegacyConfigPaths = {
				("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/config.json",
				"kozua" .. "/config.json",
				"kozua" .. "/" .. HubInfo.Game .. "/config.json",
				("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/Kozua.json",
				"kozua" .. "/Kozua.json",
				"kozua.json",
				("Kira" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/config.json",
				"Kira" .. "/config.json",
				"Kira" .. "/" .. HubInfo.Game .. "/config.json",
				("Kira" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/Kira.json",
				"Kira" .. "/Kira.json",
				"Kira.json"
			}

            for i = 1, #LegacyConfigPaths do
                autoTable, autoPath = readJsonFile(LegacyConfigPaths[i])

                if autoTable then
                    break
                end
            end
        end

        if not autoTable then
            refreshPresetOptions()

            return false
        end

        applyConfig(autoTable, autoFire)
        Config.Flight = false

        if WidgetRegistry.Flight and WidgetRegistry.Flight.set then
            pcall(WidgetRegistry.Flight.set, false)
        end

        ApplyTheme(Config.Theme or "Dark")

        local num = tonumber(Config.UIScale)

        if num then
            WindowScale.Scale = num / 100
        end

        if Config.StartMin then
            SetVisible(false)
        end

        for k, v in pairs(WidgetRegistry) do
            if v and v.set and Config[k] ~= nil then
                if v.kind == "toggle" then
                    pcall(v.set, Config[k] == true)
                elseif v.kind == "choice" or v.kind == "dropdown" or v.kind == "input" or v.kind == "slider" then
                    pcall(v.set, Config[k])
                end
            end
        end

        if ActiveTab then
            FilterTabItems(ActiveTab, SearchBox.Text)
        end

        refreshPresetOptions()

        if autoPath ~= (("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/" .. sanitizeFileName(LocalPlayer and LocalPlayer.Name or "Player") .. "-config.json" then
            saveConfig(true)
        end

        cfgWarn("loaded", autoPath)

        return true
    end
    function AddToggle(toggleTab, toggleFlag, toggleTitle, toggleDesc, toggleDefault, toggleExtra)
        Config[toggleFlag] = not not toggleDefault

        local toggleWidth = (not toggleExtra or not toggleExtra.options) and 132 or 214

        if IsMobile then
            toggleWidth = (not toggleExtra or not toggleExtra.options) and 148 or 220
        end

        local _, toggleRight, toggleExtra = BuildRow(toggleTab, toggleTitle, toggleDesc, toggleWidth)

        if toggleExtra and toggleExtra.options then
            Config[toggleExtra.flag] = Config[toggleExtra.flag] or toggleExtra.options[1]

            local choiceButtonProps = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme.fill,
				Position = UDim2.new(1, -40, 0.5, 0),
				Size = UDim2.fromOffset(72, 22),
				Font = Fonts.mid,
				Text = tostring(Config[toggleExtra.flag]) .. " ▾",
				TextColor3 = Theme.text,
				TextSize = 10,
				TextTruncate = Enum.TextTruncate.AtEnd,
				AutoButtonColor = false,
				ZIndex = 17
			}
            local TextButton = Instance.new("TextButton")

            if choiceButtonProps then
                for k, v in pairs(choiceButtonProps) do
                    TextButton[k] = v
                end
            end

            if toggleRight then
                TextButton.Parent = toggleRight
            end

            local choiceButton = TextButton
            local uiCornerProps10 = {
				CornerRadius = UDim.new(0, 6)
			}
            local UICorner = Instance.new("UICorner")

            if uiCornerProps10 then
                for k, v in pairs(uiCornerProps10) do
                    UICorner[k] = v
                end
            end

            if choiceButton then
                UICorner.Parent = choiceButton
            end

            local strokeKeyToggle = "line"
            local uiStrokeProps6 = {
				Color = Theme.line or Theme.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke5 = Instance.new("UIStroke")

            if uiStrokeProps6 then
                for k, v in pairs(uiStrokeProps6) do
                    UIStroke5[k] = v
                end
            end

            if choiceButton then
                UIStroke5.Parent = choiceButton
            end

            if strokeKeyToggle then
                UIStroke5:SetAttribute("th_stroke", strokeKeyToggle)
            end

            if choiceButton then
                choiceButton:SetAttribute("th_bg", "fill")

                local fill = Theme.fill

                if fill and choiceButton:IsA("GuiObject") then
                    choiceButton.BackgroundColor3 = fill
                end
            end

            if choiceButton then
                choiceButton:SetAttribute("th_text", "text")

                local text = Theme.text

                if text then
                    choiceButton.TextColor3 = text
                end
            end

            choiceButton.MouseButton1Click:Connect(function()
                if OpenDropdown then
                    OpenDropdown(choiceButton, toggleExtra.flag, toggleExtra.options)
                end
            end)
            WidgetRegistry[toggleExtra.flag] = {
				kind = "choice",
				chip = choiceButton,
				set = function(choiceValue)
                Config[toggleExtra.flag] = choiceValue
                choiceButton.Text = tostring(choiceValue) .. " ▾"

                if IsApplyingConfig then
                    return
                end

                if IsSavingDebounced then
                    return
                end

                IsSavingDebounced = true

                local saveGenAtCall = ConfigGen

                task.delay(0.35, function()
                    IsSavingDebounced = false

                    if saveGenAtCall ~= (getUserSlot().gen or 0) then
                        return
                    end

                    saveConfig()
                end)
            end
			}
        end

        local textButtonProps2 = {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Config[toggleFlag] and Theme.accent or Theme.fill,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(not IsMobile and 34 or 42, not IsMobile and 18 or 24),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 17
		}
        local TextButton = Instance.new("TextButton")

        if textButtonProps2 then
            for k, v in pairs(textButtonProps2) do
                TextButton[k] = v
            end
        end

        if toggleRight then
            TextButton.Parent = toggleRight
        end

        local switchTrack = TextButton
        local switchPad = not IsMobile and 9 or 12
        local uiCornerProps11 = {
			CornerRadius = UDim.new(0, switchPad or 8)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps11 then
            for k, v in pairs(uiCornerProps11) do
                UICorner[k] = v
            end
        end

        if switchTrack then
            UICorner.Parent = switchTrack
        end

        local switchStroke = applyStroke(switchTrack, Config[toggleFlag] and Theme.accent or Theme.line, 1)
        local knobOnPos = IsMobile and UDim2.new(1, -20, 0.5, -8) or UDim2.new(1, -16, 0.5, -6)
        local uDim2 = UDim2.fromOffset(2, 2)
        local switchH = not IsMobile and 14 or 16
        local frameProps19 = {
			BackgroundColor3 = Config[toggleFlag] and Theme.ink or Theme.text,
			Position = Config[toggleFlag] and knobOnPos or uDim2,
			Size = UDim2.fromOffset(switchH, switchH),
			ZIndex = 18
		}
        local Frame17 = Instance.new("Frame")

        if frameProps19 then
            for k, v in pairs(frameProps19) do
                Frame17[k] = v
            end
        end

        if switchTrack then
            Frame17.Parent = switchTrack
        end

        local switchKnob = Frame17
        local knobSize = not IsMobile and 7 or 8
        local uiCornerProps12 = {
			CornerRadius = UDim.new(0, knobSize or 8)
		}
        local UICorner5 = Instance.new("UICorner")

        if uiCornerProps12 then
            for k, v in pairs(uiCornerProps12) do
                UICorner5[k] = v
            end
        end

        if switchKnob then
            UICorner5.Parent = switchKnob
        end

        local function paintSwitch(switchOn)
            tween(switchTrack, 0.16, {
				BackgroundColor3 = switchOn and Theme.accent or Theme.fill
			}, Enum.EasingStyle.Quart)
            tween(switchKnob, 0.16, {
				Position = switchOn and knobOnPos or uDim2,
				BackgroundColor3 = switchOn and Theme.ink or Theme.text
			}, Enum.EasingStyle.Quart)
            tween(switchStroke, 0.16, {
				Color = switchOn and Theme.accent or Theme.line
			})
        end

        switchTrack.MouseButton1Click:Connect(function()
            local newToggleState = not Config[toggleFlag]

            Config[toggleFlag] = newToggleState
            paintSwitch(newToggleState)

            if not IsApplyingConfig and not IsSavingDebounced then
                IsSavingDebounced = true

                local toggleGenAtCall = ConfigGen

                task.delay(0.35, function()
                    IsSavingDebounced = false

                    if toggleGenAtCall ~= (getUserSlot().gen or 0) then
                        return
                    end

                    saveConfig()
                end)
            end

            local toggleWidget = WidgetRegistry[toggleFlag]

            task.defer(function()
                if toggleWidget and toggleWidget.on then
                    pcall(toggleWidget.on, newToggleState)
                end
            end)
        end)
        WidgetRegistry[toggleFlag] = {
			kind = "toggle",
			status = toggleExtra,
			set = function(newToggleState)
            Config[toggleFlag] = not not newToggleState
            paintSwitch(Config[toggleFlag])
        end
		}
    end
    function AddSlider(sliderTab, sliderFlag, sliderTitle, sliderDesc, sliderMin, sliderMax, sliderDefault, sliderSuffix)
        Config[sliderFlag] = sliderDefault

        local sliderRow, sliderRight, sliderExtra = BuildRow(sliderTab, sliderTitle, sliderDesc)

        sliderRow.Size = UDim2.new(1, 0, 0, 72)
        sliderRight.Size = UDim2.fromOffset(148, 48)

        local textLabelProps6 = {
			BackgroundColor3 = Theme.fill,
			Size = UDim2.new(1, 0, 0, 20),
			Font = Fonts.mono,
			Text = tostring(sliderDefault) .. (sliderSuffix or ""),
			TextColor3 = Theme.accent,
			TextSize = 12,
			ZIndex = 17
		}
        local TextLabel = Instance.new("TextLabel")

        if textLabelProps6 then
            for k, v in pairs(textLabelProps6) do
                TextLabel[k] = v
            end
        end

        if sliderRight then
            TextLabel.Parent = sliderRight
        end

        local sliderValueLabel = TextLabel
        local uiCornerProps13 = {
			CornerRadius = UDim.new(0, 5)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps13 then
            for k, v in pairs(uiCornerProps13) do
                UICorner[k] = v
            end
        end

        if sliderValueLabel then
            UICorner.Parent = sliderValueLabel
        end

        if sliderValueLabel then
            sliderValueLabel:SetAttribute("th_bg", "fill")

            local fill = Theme.fill

            if fill and sliderValueLabel:IsA("GuiObject") then
                sliderValueLabel.BackgroundColor3 = fill
            end
        end

        if sliderValueLabel then
            sliderValueLabel:SetAttribute("th_text", "accent")

            local accent = Theme.accent

            if accent then
                sliderValueLabel.TextColor3 = accent
            end
        end

        local frameProps20 = {
			BackgroundColor3 = Theme.fill,
			Position = UDim2.fromOffset(0, 32),
			Size = UDim2.new(1, 0, 0, 10),
			ZIndex = 17,
			Active = true
		}
        local Frame18 = Instance.new("Frame")

        if frameProps20 then
            for k, v in pairs(frameProps20) do
                Frame18[k] = v
            end
        end

        if sliderRight then
            Frame18.Parent = sliderRight
        end

        local sliderTrack = Frame18
        local uiCornerProps14 = {
			CornerRadius = UDim.new(0, 5)
		}
        local UICorner6 = Instance.new("UICorner")

        if uiCornerProps14 then
            for k, v in pairs(uiCornerProps14) do
                UICorner6[k] = v
            end
        end

        if sliderTrack then
            UICorner6.Parent = sliderTrack
        end

        local frameProps21 = {
			BackgroundColor3 = Theme.accent,
			Size = UDim2.new((sliderDefault - sliderMin) / math.max(sliderMax - sliderMin, 1), 0, 1, 0),
			ZIndex = 18
		}
        local Frame19 = Instance.new("Frame")

        if frameProps21 then
            for k, v in pairs(frameProps21) do
                Frame19[k] = v
            end
        end

        if sliderTrack then
            Frame19.Parent = sliderTrack
        end

        local sliderFill = Frame19
        local uiCornerProps15 = {
			CornerRadius = UDim.new(0, 5)
		}
        local UICorner7 = Instance.new("UICorner")

        if uiCornerProps15 then
            for k, v in pairs(uiCornerProps15) do
                UICorner7[k] = v
            end
        end

        if sliderFill then
            UICorner7.Parent = sliderFill
        end

        local frameProps22 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.text,
			Position = UDim2.new((sliderDefault - sliderMin) / math.max(sliderMax - sliderMin, 1), 0, 0.5, 0),
			Size = UDim2.fromOffset(18, 18),
			ZIndex = 19
		}
        local Frame20 = Instance.new("Frame")

        if frameProps22 then
            for k, v in pairs(frameProps22) do
                Frame20[k] = v
            end
        end

        if sliderTrack then
            Frame20.Parent = sliderTrack
        end

        local sliderKnob = Frame20
        local uiCornerProps16 = {
			CornerRadius = UDim.new(0, 9)
		}
        local UICorner8 = Instance.new("UICorner")

        if uiCornerProps16 then
            for k, v in pairs(uiCornerProps16) do
                UICorner8[k] = v
            end
        end

        if sliderKnob then
            UICorner8.Parent = sliderKnob
        end

        local strokeKeySliderTrack = "accentDeep"
        local uiStrokeProps7 = {
			Color = Theme.accentDeep or Theme.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke6 = Instance.new("UIStroke")

        if uiStrokeProps7 then
            for k, v in pairs(uiStrokeProps7) do
                UIStroke6[k] = v
            end
        end

        if sliderKnob then
            UIStroke6.Parent = sliderKnob
        end

        if strokeKeySliderTrack then
            UIStroke6:SetAttribute("th_stroke", strokeKeySliderTrack)
        end

        local textButtonProps3 = {
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Active = true,
			Position = UDim2.fromOffset(0, 20),
			Size = UDim2.new(1, 0, 0, 32),
			ZIndex = 21
		}
        local TextButton = Instance.new("TextButton")

        if textButtonProps3 then
            for k, v in pairs(textButtonProps3) do
                TextButton[k] = v
            end
        end

        if sliderRight then
            TextButton.Parent = sliderRight
        end

        local function applySliderNum(sliderText)
            local num = tonumber(sliderText)

            if not num then
                return
            end

            local clampedNum = math.clamp(math.floor(num + 0.5), sliderMin, sliderMax)

            Config[sliderFlag] = clampedNum

            local sliderFrac = (clampedNum - sliderMin) / math.max(sliderMax - sliderMin, 1)

            sliderFill.Size = UDim2.new(sliderFrac, 0, 1, 0)
            sliderKnob.Position = UDim2.new(sliderFrac, 0, 0.5, 0)
            sliderValueLabel.Text = tostring(clampedNum) .. (sliderSuffix or "")

            if IsApplyingConfig then
                return
            end

            local sliderWidget = WidgetRegistry[sliderFlag]

            if sliderWidget and sliderWidget.on then
                pcall(sliderWidget.on, clampedNum)
            end

            if IsApplyingConfig then
                return
            end

            if IsSavingDebounced then
                return
            end

            IsSavingDebounced = true

            local sliderGenAtCall = ConfigGen

            task.delay(0.35, function()
                IsSavingDebounced = false

                if sliderGenAtCall ~= (getUserSlot().gen or 0) then
                    return
                end

                saveConfig()
            end)
        end

        local sliderDragging = false

        TextButton.InputBegan:Connect(function(input)
            local UserInputType = input.UserInputType

            if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                sliderDragging = true

                if sliderTab and sliderTab.scroll then
                    sliderTab.scroll.ScrollingEnabled = false
                end

                if SidebarScroll then
                    SidebarScroll.ScrollingEnabled = false
                end

                local PositionX = input.Position.X
                local fracDown = math.clamp((PositionX - sliderTrack.AbsolutePosition.X) / math.max(sliderTrack.AbsoluteSize.X, 1), 0, 1)

                applySliderNum(sliderMin + fracDown * (sliderMax - sliderMin))
            end
        end)

        local connection = UserInputService.InputChanged:Connect(function(input)
            if sliderDragging then
                local UserInputType = input.UserInputType

                if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Touch then
                    local PositionX = input.Position.X
                    local fracMove = math.clamp((PositionX - sliderTrack.AbsolutePosition.X) / math.max(sliderTrack.AbsoluteSize.X, 1), 0, 1)

                    applySliderNum(sliderMin + fracMove * (sliderMax - sliderMin))
                end
            end
        end)

        if connection then
            CleanupList[#CleanupList + 1] = connection
        end

        local connection2 = UserInputService.InputEnded:Connect(function(input)
            if sliderDragging then
                local UserInputType = input.UserInputType

                if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                    sliderDragging = false

                    if sliderTab and sliderTab.scroll then
                        sliderTab.scroll.ScrollingEnabled = true
                    end

                    if SidebarScroll then
                        SidebarScroll.ScrollingEnabled = true
                    end
                end
            end
        end)

        if connection2 then
            CleanupList[#CleanupList + 1] = connection2
        end

        WidgetRegistry[sliderFlag] = {
			kind = "slider",
			status = sliderExtra,
			set = applySliderNum
		}
    end

    local DropdownList = newInstance("Frame", {
		Name = "Drops",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 90
	}, ScreenGui)

    function CloseDropdown()
        DropdownList:ClearAllChildren()
        DropdownList.Visible = false
    end

    DropdownOverlay.MouseButton1Click:Connect(function()
        CloseDropdown()
        DropdownOverlay.Visible = false
    end)

    function OpenDropdown(anchorBtn, dropFlag, dropOptions)
        CloseDropdown()
        DropdownOverlay.Visible = true
        DropdownOverlay.ZIndex = 85
        DropdownList.Visible = true

        local AbsolutePosition = anchorBtn.AbsolutePosition
        local AbsoluteSize = anchorBtn.AbsoluteSize
        local frameProps23 = {
			BackgroundColor3 = Theme.card,
			Position = UDim2.fromOffset(AbsolutePosition.X, AbsolutePosition.Y + AbsoluteSize.Y + 6),
			Size = UDim2.fromOffset(math.max(AbsoluteSize.X, 120), #dropOptions * 28 + 10),
			ZIndex = 95
		}
        local dropdownLayer = DropdownList
        local Frame21 = Instance.new("Frame")

        if frameProps23 then
            for k, v in pairs(frameProps23) do
                Frame21[k] = v
            end
        end

        if dropdownLayer then
            Frame21.Parent = dropdownLayer
        end

        local uiCornerProps17 = {
			CornerRadius = UDim.new(0, 10)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps17 then
            for k, v in pairs(uiCornerProps17) do
                UICorner[k] = v
            end
        end

        if Frame21 then
            UICorner.Parent = Frame21
        end

        local strokeKeyChoicePopup = "line"
        local uiStrokeProps8 = {
			Color = Theme.line or Theme.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke7 = Instance.new("UIStroke")

        if uiStrokeProps8 then
            for k, v in pairs(uiStrokeProps8) do
                UIStroke7[k] = v
            end
        end

        if Frame21 then
            UIStroke7.Parent = Frame21
        end

        if strokeKeyChoicePopup then
            UIStroke7:SetAttribute("th_stroke", strokeKeyChoicePopup)
        end

        if Frame21 then
            Frame21:SetAttribute("th_bg", "card")

            local card = Theme.card

            if card and Frame21:IsA("GuiObject") then
                Frame21.BackgroundColor3 = card
            end
        end

        local uiListLayoutProps4 = {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		}
        local UIListLayout = Instance.new("UIListLayout")

        if uiListLayoutProps4 then
            for k, v in pairs(uiListLayoutProps4) do
                UIListLayout[k] = v
            end
        end

        if Frame21 then
            UIListLayout.Parent = Frame21
        end

        applyPadding(Frame21, 5, 5, 5, 5)

        for i, v in ipairs(dropOptions) do
            local isChosen = v == Config[dropFlag]
            local choiceItemProps = {
				BackgroundColor3 = isChosen and Theme.lift or Theme.card,
				Size = UDim2.new(1, 0, 0, 24),
				Font = Fonts.body,
				Text = "  " .. v,
				TextColor3 = isChosen and Theme.accent or Theme.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				LayoutOrder = i,
				ZIndex = 97
			}
            local TextButton = Instance.new("TextButton")

            if choiceItemProps then
                for k, propVal8 in pairs(choiceItemProps) do
                    TextButton[k] = propVal8
                end
            end

            if Frame21 then
                TextButton.Parent = Frame21
            end

            local uiCornerProps18 = {
				CornerRadius = UDim.new(0, 6)
			}
            local UICorner9 = Instance.new("UICorner")

            if uiCornerProps18 then
                for k, propVal9 in pairs(uiCornerProps18) do
                    UICorner9[k] = propVal9
                end
            end

            if TextButton then
                UICorner9.Parent = TextButton
            end

            TextButton.MouseButton1Click:Connect(function()
                Config[dropFlag] = v

                local choiceWidget = WidgetRegistry[dropFlag]

                if choiceWidget and choiceWidget.set then
                    choiceWidget.set(v)
                end

                if choiceWidget and choiceWidget.on then
                    pcall(choiceWidget.on, v)
                end

                CloseDropdown()
                DropdownOverlay.Visible = false

                if IsApplyingConfig then
                    return
                end

                if IsSavingDebounced then
                    return
                end

                IsSavingDebounced = true

                local choiceGenAtCall = ConfigGen

                task.delay(0.35, function()
                    IsSavingDebounced = false

                    if choiceGenAtCall ~= (getUserSlot().gen or 0) then
                        return
                    end

                    saveConfig()
                end)
            end)
        end
    end

    local function summarizeMultiSelect(selectedList, allOptions)
        if type(selectedList) ~= "table" then
            return "none"
        end

        local matchCount = 0
        local totalOptions = #allOptions
        local MultiSelectSet = {}

        for _, v in ipairs(selectedList) do
            MultiSelectSet[v] = true
        end

        for _, v in ipairs(allOptions) do
            if MultiSelectSet[v] then
                matchCount += 1
            end
        end

        if matchCount == 0 then
            return "none"
        end

        if matchCount == totalOptions then
            return "all · " .. totalOptions
        end

        return matchCount .. " / " .. totalOptions
    end
    local function makeDropdownButton(btnParent, btnLabel)
        local textButtonProps4 = {
			BackgroundColor3 = Theme.fill,
			Size = UDim2.new(1, 0, 0, 24),
			Font = Fonts.mid,
			Text = btnLabel,
			TextColor3 = Theme.text,
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AutoButtonColor = false,
			ZIndex = 17
		}
        local TextButton = Instance.new("TextButton")

        if textButtonProps4 then
            for k, v in pairs(textButtonProps4) do
                TextButton[k] = v
            end
        end

        if btnParent then
            TextButton.Parent = btnParent
        end

        local uiCornerProps19 = {
			CornerRadius = UDim.new(0, 7)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps19 then
            for k, v in pairs(uiCornerProps19) do
                UICorner[k] = v
            end
        end

        if TextButton then
            UICorner.Parent = TextButton
        end

        local strokeKeyDropBtn = "line"
        local uiStrokeProps9 = {
			Color = Theme.line or Theme.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke8 = Instance.new("UIStroke")

        if uiStrokeProps9 then
            for k, v in pairs(uiStrokeProps9) do
                UIStroke8[k] = v
            end
        end

        if TextButton then
            UIStroke8.Parent = TextButton
        end

        if strokeKeyDropBtn then
            UIStroke8:SetAttribute("th_stroke", strokeKeyDropBtn)
        end

        bindHoverTheme(TextButton, "fill", "lift")

        if TextButton then
            TextButton:SetAttribute("th_text", "text")

            local text = Theme.text

            if not text then
                return TextButton
            end

            TextButton.TextColor3 = text
        end

        return TextButton
    end

    function AddDropdown(dropTab, dropFlag2, dropTitle, dropDesc, dropChoices, dropDefault, dropMulti)
        if dropMulti then
            Config[dropFlag2] = dropDefault or { unpack(dropChoices) }
        else
            Config[dropFlag2] = dropDefault or dropChoices[1]
        end

        local _, dropRight, dropExtra = BuildRow(dropTab, dropTitle, dropDesc)
        local dropButton = makeDropdownButton(dropRight, dropMulti and summarizeMultiSelect(Config[dropFlag2], dropChoices) or tostring(Config[dropFlag2]))
        local textLabelProps7 = {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			Font = Fonts.mid,
			Text = "▾",
			TextColor3 = Theme.mute,
			TextSize = 11,
			ZIndex = 18
		}
        local TextLabel = Instance.new("TextLabel")

        if textLabelProps7 then
            for k, v in pairs(textLabelProps7) do
                TextLabel[k] = v
            end
        end

        if dropButton then
            TextLabel.Parent = dropButton
        end

        dropButton.Text = (dropMulti and summarizeMultiSelect(Config[dropFlag2], dropChoices) or tostring(Config[dropFlag2])) .. "   "
        dropButton.MouseButton1Click:Connect(function()
            CloseDropdown()
            DropdownOverlay.Visible = true
            DropdownOverlay.ZIndex = 85
            DropdownList.Visible = true

            local AbsolutePosition = dropButton.AbsolutePosition
            local AbsoluteSize = dropButton.AbsoluteSize
            local dropHeight = math.min(7, #dropChoices) * 28 + 10
            local frameProps24 = {
				BackgroundColor3 = Theme.card,
				Position = UDim2.fromOffset(AbsolutePosition.X, AbsolutePosition.Y + AbsoluteSize.Y + 6),
				Size = UDim2.fromOffset(math.max(AbsoluteSize.X, 180), dropHeight),
				ZIndex = 95
			}
            local dropLayerAlias = DropdownList
            local Frame22 = Instance.new("Frame")

            if frameProps24 then
                for k, v in pairs(frameProps24) do
                    Frame22[k] = v
                end
            end

            if dropLayerAlias then
                Frame22.Parent = dropLayerAlias
            end

            local uiCornerProps20 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner = Instance.new("UICorner")

            if uiCornerProps20 then
                for k, v in pairs(uiCornerProps20) do
                    UICorner[k] = v
                end
            end

            if Frame22 then
                UICorner.Parent = Frame22
            end

            local strokeKeyDropItem = "accentDeep"
            local uiStrokeProps10 = {
				Color = Theme.accentDeep or Theme.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke9 = Instance.new("UIStroke")

            if uiStrokeProps10 then
                for k, v in pairs(uiStrokeProps10) do
                    UIStroke9[k] = v
                end
            end

            if Frame22 then
                UIStroke9.Parent = Frame22
            end

            if strokeKeyDropItem then
                UIStroke9:SetAttribute("th_stroke", strokeKeyDropItem)
            end

            local scrollingFrameProps2 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				CanvasSize = UDim2.new(0, 0, 0, #dropChoices * 28),
				ScrollBarThickness = 3,
				BorderSizePixel = 0,
				ZIndex = 96
			}
            local ScrollingFrame = Instance.new("ScrollingFrame")

            if scrollingFrameProps2 then
                for k, v in pairs(scrollingFrameProps2) do
                    ScrollingFrame[k] = v
                end
            end

            if Frame22 then
                ScrollingFrame.Parent = Frame22
            end

            applyPadding(ScrollingFrame, 5, 5, 5, 5)

            local uiListLayoutProps5 = {
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			}
            local UIListLayout = Instance.new("UIListLayout")

            if uiListLayoutProps5 then
                for k, v in pairs(uiListLayoutProps5) do
                    UIListLayout[k] = v
                end
            end

            if ScrollingFrame then
                UIListLayout.Parent = ScrollingFrame
            end

            local DropdownSelectionSet = {}

            if dropMulti and type(Config[dropFlag2]) == "table" then
                for _, v in ipairs(Config[dropFlag2]) do
                    DropdownSelectionSet[v] = true
                end
            end

            for i, v in ipairs(dropChoices) do
                local isOptSelected = dropMulti and DropdownSelectionSet[v] or v == Config[dropFlag2]
                local dropOptionProps = {
					BackgroundColor3 = isOptSelected and Theme.lift or Theme.card,
					Size = UDim2.new(1, 0, 0, 26),
					Font = Fonts.body,
					Text = "   " .. v,
					TextColor3 = isOptSelected and Theme.accent or Theme.text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					LayoutOrder = i,
					ZIndex = 97
				}
                local TextButton = Instance.new("TextButton")

                if dropOptionProps then
                    for k, propVal10 in pairs(dropOptionProps) do
                        TextButton[k] = propVal10
                    end
                end

                if ScrollingFrame then
                    TextButton.Parent = ScrollingFrame
                end

                local optButton = TextButton
                local uiCornerProps21 = {
					CornerRadius = UDim.new(0, 6)
				}
                local UICorner10 = Instance.new("UICorner")

                if uiCornerProps21 then
                    for k, propVal11 in pairs(uiCornerProps21) do
                        UICorner10[k] = propVal11
                    end
                end

                if optButton then
                    UICorner10.Parent = optButton
                end

                bindHoverTheme(optButton, isOptSelected and Theme.lift or Theme.card, Theme.fill)
                optButton.MouseButton1Click:Connect(function()
                    if dropMulti then
                        local DropdownItemState = {}

                        DropdownSelectionSet[v] = not DropdownSelectionSet[v]

                        for _, optionValue in ipairs(dropChoices) do
                            if DropdownSelectionSet[optionValue] then
                                DropdownItemState[#DropdownItemState + 1] = optionValue
                            end
                        end

                        Config[dropFlag2] = DropdownItemState

                        local wasSelected = DropdownSelectionSet[v]

                        optButton.BackgroundColor3 = wasSelected and Theme.lift or Theme.card
                        optButton.TextColor3 = wasSelected and Theme.accent or Theme.text
                        optButton:SetAttribute("locked", false)
                        dropButton.Text = (dropMulti and summarizeMultiSelect(Config[dropFlag2], dropChoices) or tostring(Config[dropFlag2])) .. "   "

                        local dropWidget = WidgetRegistry[dropFlag2]

                        if dropWidget and dropWidget.on then
                            pcall(dropWidget.on, DropdownItemState)
                        end

                        if IsApplyingConfig then
                            return
                        end

                        if IsSavingDebounced then
                            return
                        end

                        IsSavingDebounced = true

                        local dropGenAtCall = ConfigGen

                        task.delay(0.35, function()
                            IsSavingDebounced = false

                            if dropGenAtCall ~= (getUserSlot().gen or 0) then
                                return
                            end

                            saveConfig()
                        end)

                        return
                    end

                    Config[dropFlag2] = v

                    local dropWidget2 = WidgetRegistry[dropFlag2]

                    if dropWidget2 and dropWidget2.on then
                        pcall(dropWidget2.on, v)
                    end

                    CloseDropdown()
                    DropdownOverlay.Visible = false
                    dropButton.Text = (dropMulti and summarizeMultiSelect(Config[dropFlag2], dropChoices) or tostring(Config[dropFlag2])) .. "   "

                    if IsApplyingConfig then
                        return
                    end

                    if IsSavingDebounced then
                        return
                    end

                    IsSavingDebounced = true

                    local dropGenAtCall2 = ConfigGen

                    task.delay(0.35, function()
                        IsSavingDebounced = false

                        if dropGenAtCall2 ~= (getUserSlot().gen or 0) then
                            return
                        end

                        saveConfig()
                    end)
                end)
            end
        end)
        WidgetRegistry[dropFlag2] = {
			kind = "dropdown",
			status = dropExtra,
			options = dropChoices,
			refresh = function()
            dropButton.Text = (dropMulti and summarizeMultiSelect(Config[dropFlag2], dropChoices) or tostring(Config[dropFlag2])) .. "   "
        end,
			set = function(dropNewValue)
            Config[dropFlag2] = dropNewValue
            dropButton.Text = (dropMulti and summarizeMultiSelect(Config[dropFlag2], dropChoices) or tostring(Config[dropFlag2])) .. "   "
        end
		}
    end
    function AddTextbox(inputTab, inputFlag, inputTitle, inputDesc, inputPlaceholder, inputDefault, inputExtra)
        Config[inputFlag] = inputDefault or ""

        local _, inputRight, inputExtra = BuildRow(inputTab, inputTitle, inputDesc)
        local inputBoxProps = {
			BackgroundColor3 = Theme.fill,
			Size = UDim2.new(1, 0, 0, 24),
			Font = Fonts.mono,
			Text = Config[inputFlag],
			PlaceholderText = inputPlaceholder or "",
			PlaceholderColor3 = Theme.mute,
			TextColor3 = Theme.text,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			ZIndex = 17
		}
        local TextBox2 = Instance.new("TextBox")

        if inputBoxProps then
            for k, v in pairs(inputBoxProps) do
                TextBox2[k] = v
            end
        end

        if inputRight then
            TextBox2.Parent = inputRight
        end

        local inputBox = TextBox2
        local uiCornerProps22 = {
			CornerRadius = UDim.new(0, 7)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps22 then
            for k, v in pairs(uiCornerProps22) do
                UICorner[k] = v
            end
        end

        if inputBox then
            UICorner.Parent = inputBox
        end

        if inputBox then
            inputBox:SetAttribute("th_bg", "fill")

            local fill = Theme.fill

            if fill and inputBox:IsA("GuiObject") then
                inputBox.BackgroundColor3 = fill
            end
        end

        if inputBox then
            inputBox:SetAttribute("th_text", "text")

            local text = Theme.text

            if text then
                inputBox.TextColor3 = text
            end
        end

        if inputBox then
            inputBox:SetAttribute("th_placeholder", "mute")

            local mute = Theme.mute

            if mute and inputBox:IsA("TextBox") then
                inputBox.PlaceholderColor3 = mute
            end
        end

        local strokeKeyInput = "line"
        local uiStrokeProps11 = {
			Color = Theme.line or Theme.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke10 = Instance.new("UIStroke")

        if uiStrokeProps11 then
            for k, v in pairs(uiStrokeProps11) do
                UIStroke10[k] = v
            end
        end

        if inputBox then
            UIStroke10.Parent = inputBox
        end

        if strokeKeyInput then
            UIStroke10:SetAttribute("th_stroke", strokeKeyInput)
        end

        local inputStroke = UIStroke10

        applyPadding(inputBox, 8, 0, 8, 0)
        inputBox.Focused:Connect(function()
            tween(inputStroke, 0.12, {
				Color = Theme.accent
			})
        end)
        inputBox.FocusLost:Connect(function()
            tween(inputStroke, 0.12, {
				Color = Theme.line
			})
            Config[inputFlag] = inputBox.Text

            local inputWidget = WidgetRegistry[inputFlag]

            if inputWidget and inputWidget.on then
                pcall(inputWidget.on, inputBox.Text)
            end

            if IsApplyingConfig then
                return
            end

            if IsSavingDebounced then
                return
            end

            IsSavingDebounced = true

            local inputGenAtCall = ConfigGen

            task.delay(0.35, function()
                IsSavingDebounced = false

                if inputGenAtCall ~= (getUserSlot().gen or 0) then
                    return
                end

                saveConfig()
            end)
        end)
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            Config[inputFlag] = inputBox.Text

            if IsApplyingConfig then
                return
            end

            if IsSavingDebounced then
                return
            end

            IsSavingDebounced = true

            local inputGenAtCall2 = ConfigGen

            task.delay(0.35, function()
                IsSavingDebounced = false

                if inputGenAtCall2 ~= (getUserSlot().gen or 0) then
                    return
                end

                saveConfig()
            end)
        end)
        WidgetRegistry[inputFlag] = {
			kind = "input",
			status = inputExtra,
			box = inputBox,
			set = function(inputNewValue)
            Config[inputFlag] = inputNewValue
            inputBox.Text = tostring(inputNewValue)
        end
		}

        local lastItem = inputTab.items[#inputTab.items]

        if inputExtra and inputExtra.visibleIf and lastItem then
            lastItem.visibleIf = inputExtra.visibleIf
        end
    end
    function AddButton(buttonTab, buttonFlag, buttonTitle, buttonDesc, buttonLabel, buttonCallback, buttonPrimary)
        local _, btnRight, btnExtra = BuildRow(buttonTab, buttonTitle, buttonDesc)
        local textButtonProps5 = {
			Size = UDim2.new(1, 0, 0, 24),
			Font = Fonts.mid,
			Text = buttonLabel,
			TextSize = 11,
			AutoButtonColor = false,
			ZIndex = 17
		}
        local TextButton = Instance.new("TextButton")

        if textButtonProps5 then
            for k, v in pairs(textButtonProps5) do
                TextButton[k] = v
            end
        end

        if btnRight then
            TextButton.Parent = btnRight
        end

        local uiCornerProps23 = {
			CornerRadius = UDim.new(0, 7)
		}
        local UICorner = Instance.new("UICorner")

        if uiCornerProps23 then
            for k, v in pairs(uiCornerProps23) do
                UICorner[k] = v
            end
        end

        if TextButton then
            UICorner.Parent = TextButton
        end

        if not buttonPrimary then
            local strokeKeyButton = "line"
            local uiStrokeProps12 = {
				Color = Theme.line or Theme.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke11 = Instance.new("UIStroke")

            if uiStrokeProps12 then
                for k, v in pairs(uiStrokeProps12) do
                    UIStroke11[k] = v
                end
            end

            if TextButton then
                UIStroke11.Parent = TextButton
            end

            if strokeKeyButton then
                UIStroke11:SetAttribute("th_stroke", strokeKeyButton)
            end
        end

        bindHoverTheme(TextButton, not buttonPrimary and "fill" or "accent", not buttonPrimary and "lift" or "accentHover")

        local btnThemeKey = not buttonPrimary and "text" or "ink"

        if TextButton and btnThemeKey then
            TextButton:SetAttribute("th_text", btnThemeKey)

            local btnThemeColor = Theme[btnThemeKey]

            if btnThemeColor then
                TextButton.TextColor3 = btnThemeColor
            end
        end

        WidgetRegistry[buttonFlag] = {
			kind = "button",
			status = btnExtra,
			btn = TextButton
		}
        TextButton.MouseButton1Click:Connect(function()
            if buttonCallback then
                pcall(buttonCallback)
            end

            local buttonWidget = WidgetRegistry[buttonFlag]

            if buttonWidget and buttonWidget.on then
                pcall(buttonWidget.on)
            end
        end)
    end
    function AddKeybind(keyTab, keyFlag, keyTitle, keyDesc, keyDefault)
        Config[keyFlag] = keyDefault

        local _, keyRight, keyExtra = BuildRow(keyTab, keyTitle, keyDesc)
        local keyListening = false
        local keyButton = makeDropdownButton(keyRight, keyDefault.Name)

        keyButton.Font = Fonts.mono
        keyButton.MouseButton1Click:Connect(function()
            keyListening = true
            keyButton.Text = "press"
            keyButton.TextColor3 = Theme.accent
        end)

        local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not keyListening then
                return
            end

            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            if gameProcessed then
                return
            end

            keyListening = false
            Config[keyFlag] = input.KeyCode
            keyButton.Text = input.KeyCode.Name
            keyButton.TextColor3 = Theme.text

            local keyWidget = WidgetRegistry[keyFlag]

            if keyWidget and keyWidget.on then
                pcall(keyWidget.on, input.KeyCode)
            end

            if IsApplyingConfig then
                return
            end

            if IsSavingDebounced then
                return
            end

            IsSavingDebounced = true

            local keyGenAtCall = ConfigGen

            task.delay(0.35, function()
                IsSavingDebounced = false

                if keyGenAtCall ~= (getUserSlot().gen or 0) then
                    return
                end

                saveConfig()
            end)
        end)

        if connection then
            CleanupList[#CleanupList + 1] = connection
        end

        WidgetRegistry[keyFlag] = {
			kind = "keybind",
			status = keyExtra,
			set = function(keyNewValue)
            if type(keyNewValue) == "string" then
                local ok, result = pcall(function()
                    return Enum.KeyCode[keyNewValue]
                end)

                if ok then
                    keyNewValue = result
                end
            end

            Config[keyFlag] = keyNewValue

            local ok, result = pcall(function()
                return keyNewValue.Name
            end)

            keyButton.Text = ok and result or tostring(keyNewValue)
        end
		}
    end
    function isNonEmptyString(testString)
        return type(testString) == "string" and testString:match("%S") ~= nil
    end
    function resolveDiscordInvite()
        local Discord = HubInfo.Discord

        if type(Discord) ~= "string" or Discord:match("%S") == nil then
            return
        end

        if Discord:find("discord%.", 1) or Discord:find("http", 1, true) then
            return Discord
        end

        return "discord.gg/" .. Discord
    end
    function AddParagraph(paraTab, paraTitle, paraBody)
        local paraParent = paraTab.card or paraTab.scroll
        local frameProps25 = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.card,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}

        paraTab.n = paraTab.n + 1
        frameProps25.LayoutOrder = paraTab.n
        frameProps25.ZIndex = 14

        local Frame23 = Instance.new("Frame")

        if frameProps25 then
            for k, v in pairs(frameProps25) do
                Frame23[k] = v
            end
        end

        if paraParent then
            Frame23.Parent = paraParent
        end

        local paraFrame = Frame23
        local frameProps26 = {
			BackgroundColor3 = Theme.line,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -28, 0, 1),
			Visible = paraTab.lastRule ~= nil,
			ZIndex = 15
		}
        local Frame24 = Instance.new("Frame")

        if frameProps26 then
            for k, v in pairs(frameProps26) do
                Frame24[k] = v
            end
        end

        if paraFrame then
            Frame24.Parent = paraFrame
        end

        paraTab.lastRule = Frame24

        if Frame24 then
            Frame24:SetAttribute("th_bg", "line")

            local line = Theme.line

            if line and Frame24:IsA("GuiObject") then
                Frame24.BackgroundColor3 = line
            end
        end

        if paraFrame then
            paraFrame:SetAttribute("th_bg", "card")

            local card = Theme.card

            if card and paraFrame:IsA("GuiObject") then
                paraFrame.BackgroundColor3 = card
            end
        end

        paraFrame:SetAttribute("th_hover", "lift")
        paraFrame:SetAttribute("th_row", true)
        paraFrame.MouseEnter:Connect(function()
            paraFrame:SetAttribute("th_over", true)
            tween(paraFrame, 0.1, {
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.lift
			})
        end)
        paraFrame.MouseLeave:Connect(function()
            paraFrame:SetAttribute("th_over", false)
            tween(paraFrame, 0.1, {
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme.card
			})
        end)

        local textLabelProps8 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 8),
			Size = UDim2.new(1, -28, 0, 14),
			Font = Fonts.mid,
			Text = paraTitle,
			TextColor3 = Theme.text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 15
		}
        local TextLabel = Instance.new("TextLabel")

        if textLabelProps8 then
            for k, v in pairs(textLabelProps8) do
                TextLabel[k] = v
            end
        end

        if paraFrame then
            TextLabel.Parent = paraFrame
        end

        if TextLabel then
            TextLabel:SetAttribute("th_text", "text")

            local text = Theme.text

            if text then
                TextLabel.TextColor3 = text
            end
        end

        local paraBodyProps = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 24),
			Size = UDim2.new(1, -28, 0, 0),
			Font = Fonts.body,
			Text = paraBody,
			TextColor3 = Theme.dim,
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 15
		}
        local TextLabel8 = Instance.new("TextLabel")

        if paraBodyProps then
            for k, v in pairs(paraBodyProps) do
                TextLabel8[k] = v
            end
        end

        if paraFrame then
            TextLabel8.Parent = paraFrame
        end

        if TextLabel8 then
            TextLabel8:SetAttribute("th_text", "dim")

            local dim = Theme.dim

            if dim then
                TextLabel8.TextColor3 = dim
            end
        end

        local uiPaddingProps2 = {
			PaddingBottom = UDim.new(0, 10)
		}
        local UIPadding = Instance.new("UIPadding")

        if uiPaddingProps2 then
            for k, v in pairs(uiPaddingProps2) do
                UIPadding[k] = v
            end
        end

        if paraFrame then
            UIPadding.Parent = paraFrame
        end

        paraTab.items[#paraTab.items + 1] = {
			kind = "row",
			inst = paraFrame,
			q = string.lower(paraTitle .. " " .. paraBody)
		}
    end
end
local TabAbout = CreateTab("About", "kozua for Steal an Egg")
local TabAutoSteal = CreateTab("Auto Steal", "targeting, filters, travel")
local TabPlot = CreateTab("Plot", "eggs, pets, upgrades, selling")
local TabServerhop = CreateTab("Serverhop", "fill a reason, then turn Auto hop on")
local TabMisc = CreateTab("Misc", "esp, defence, flight")
local TabWebhook = CreateTab("Webhook", "outbound messages")
local TabSettings = CreateTab("Settings", "window and config")
AddSectionHeader("About", { "About" }, 0)
AddSectionHeader("Autofarm", { "Auto Steal" }, 10)
AddSectionHeader("Other stuff", {
	"Plot",
	"Serverhop",
	"Misc"
}, 30)
AddSectionHeader("Config", {
	"Webhook",
	"Settings"
}, 50);
-- Compat: scan found zero remaining bare v/t/u/n/s refs lacking `local` declarations
-- (after normalization + Var->bare + divergent->canonical renames); no aliases needed.
(function(p130)
    local aboutCardProps = {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Theme.card,
		BorderSizePixel = 0
	}

    p130.n = p130.n + 1
    aboutCardProps.LayoutOrder = p130.n
    aboutCardProps.ZIndex = 13

    local scroll = p130.scroll
    local Frame = Instance.new("Frame")

    if aboutCardProps then
        for k, v in pairs(aboutCardProps) do
            Frame[k] = v
        end
    end

    if scroll then
        Frame.Parent = scroll
    end

    local t135 = {
		CornerRadius = UDim.new(0, 8)
	}
    local UICorner = Instance.new("UICorner")

    if t135 then
        for k, v in pairs(t135) do
            UICorner[k] = v
        end
    end

    if Frame then
        UICorner.Parent = Frame
    end

    local s13 = "line"
    local t136 = {
		Color = Theme.line or Theme.line,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}
    local UIStroke = Instance.new("UIStroke")

    if t136 then
        for k, v in pairs(t136) do
            UIStroke[k] = v
        end
    end

    if Frame then
        UIStroke.Parent = Frame
    end

    if s13 then
        UIStroke:SetAttribute("th_stroke", s13)
    end

    if Frame then
        Frame:SetAttribute("th_bg", "card")

        local card = Theme.card

        if card and Frame:IsA("GuiObject") then
            Frame.BackgroundColor3 = card
        end
    end

    applyPadding(Frame, 14, 14, 14, 14)

    local t137 = {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder
	}
    local UIListLayout = Instance.new("UIListLayout")

    if t137 then
        for k, v in pairs(t137) do
            UIListLayout[k] = v
        end
    end

    if Frame then
        UIListLayout.Parent = Frame
    end

    local t138 = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		LayoutOrder = 1,
		ZIndex = 14
	}
    local Frame25 = Instance.new("Frame")

    if t138 then
        for k, v in pairs(t138) do
            Frame25[k] = v
        end
    end

    if Frame then
        Frame25.Parent = Frame
    end

    createLogoMark(Frame25, 15, 44).Position = UDim2.fromOffset(0, 2)

    local t139 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 2),
		Size = UDim2.new(1, -54, 0, 20),
		Font = Fonts.title,
		Text = HubInfo.Title .. " " .. HubInfo.Product,
		TextColor3 = Theme.text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 15
	}
    local TextLabel = Instance.new("TextLabel")

    if t139 then
        for k, v in pairs(t139) do
            TextLabel[k] = v
        end
    end

    if Frame25 then
        TextLabel.Parent = Frame25
    end

    if TextLabel then
        TextLabel:SetAttribute("th_text", "text")

        local text = Theme.text

        if text then
            TextLabel.TextColor3 = text
        end
    end

    local t140 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 26),
		Size = UDim2.new(1, -54, 0, 20),
		ZIndex = 15
	}
    local Frame26 = Instance.new("Frame")

    if t140 then
        for k, v in pairs(t140) do
            Frame26[k] = v
        end
    end

    if Frame25 then
        Frame26.Parent = Frame25
    end

    local v979 = Frame26
    local t141 = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center
	}
    local UIListLayout2 = Instance.new("UIListLayout")

    if t141 then
        for k, v in pairs(t141) do
            UIListLayout2[k] = v
        end
    end

    if v979 then
        UIListLayout2.Parent = v979
    end

    local function v984(p131, p132, p133)
        local t142 = {
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.fill,
			Size = UDim2.fromOffset(0, 18),
			Font = Fonts.mono,
			Text = "  " .. p131 .. "  ",
			TextColor3 = Theme[p133] or Theme.dim,
			TextSize = 10,
			LayoutOrder = p132,
			ZIndex = 16
		}
        local v1373 = v979
        local TextLabel9 = Instance.new("TextLabel")

        if t142 then
            for k, v in pairs(t142) do
                TextLabel9[k] = v
            end
        end

        if v1373 then
            TextLabel9.Parent = v1373
        end

        local t143 = {
			CornerRadius = UDim.new(0, 5)
		}
        local UICorner11 = Instance.new("UICorner")

        if t143 then
            for k, v in pairs(t143) do
                UICorner11[k] = v
            end
        end

        if TextLabel9 then
            UICorner11.Parent = TextLabel9
        end

        if TextLabel9 then
            TextLabel9:SetAttribute("th_bg", "fill")

            local fill = Theme.fill

            if fill and TextLabel9:IsA("GuiObject") then
                TextLabel9.BackgroundColor3 = fill
            end
        end

        local v1382 = p133 or "dim"

        if TextLabel9 then
            if not v1382 then
                return TextLabel9
            end

            TextLabel9:SetAttribute("th_text", v1382)

            local v1383 = Theme[v1382]

            if not v1383 then
                return TextLabel9
            end

            TextLabel9.TextColor3 = v1383
        end

        return TextLabel9
    end

    v984("v" .. tostring(HubInfo.Version), 1, "accent")

    local Status = HubInfo.Status

    if type(Status) == "string" and Status:match("%S") ~= nil then
        v984(HubInfo.Status, 2, "dim")
    end

    local Game = HubInfo.Game

    if type(Game) == "string" and Game:match("%S") ~= nil then
        v984(HubInfo.Game, 3, "dim")
    end

    local Tagline = HubInfo.Tagline
    local v988 = type(Tagline) == "string" and Tagline:match("%S") ~= nil and HubInfo.Tagline or "Autofarm, hatch eggs and other stuff"
    local t144 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Font = Fonts.body,
		Text = v988,
		TextColor3 = Theme.dim,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		ZIndex = 15
	}
    local TextLabel10 = Instance.new("TextLabel")

    if t144 then
        for k, v in pairs(t144) do
            TextLabel10[k] = v
        end
    end

    if Frame then
        TextLabel10.Parent = Frame
    end

    if TextLabel10 then
        TextLabel10:SetAttribute("th_text", "dim")

        local dim = Theme.dim

        if dim then
            TextLabel10.TextColor3 = dim
        end
    end

    p130.items[#p130.items + 1] = {
		kind = "section",
		inst = Frame,
		q = string.lower(TextLabel.Text .. " " .. v988)
	}
    p130.card = nil
    p130.lastRule = nil

    return Frame
end)(TabAbout)
BuildCard(TabAbout, "kozua")
AddParagraph(TabAbout, "Keyless", "No key, no loader, no gate — paste the file and it runs. Nothing is checked before the UI comes up.")
AddParagraph(TabAbout, "Your files", "Configs and the mark live in kozua/<game>/. Configs written by an older build still load.")
AddButton(TabAbout, "CopyBrand", "Brand", "KOZUA — clipboard", "Copy", function()
    if setclipboard then
        pcall(setclipboard, "KOZUA")
    end

    kozuaToast("copied · KOZUA", "ok")
end, true)
AddButton(TabAbout, "CopySysInfo", "System info", "executor, fps, ping and place — for bug reports", "Copy", function()
    local ping = 0

    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)

    local line = table.concat({
        "kozua " .. tostring(HubInfo.Version),
        "executor: " .. tostring((identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "unknown"),
        "fps: " .. tostring(HeaderStatPill2 and HeaderStatPill2.Text or "?"),
        "ping: " .. tostring(ping) .. " ms",
        "place: " .. tostring(game.PlaceId),
        "game: " .. tostring(HubInfo.Game)
    }, "\n")

    if setclipboard then
        pcall(setclipboard, line)
    end

    kozuaToast("system info copied")
end, false)
BuildCard(TabAbout, "Features")
AddParagraph(TabAbout, "Auto Steal", "Snatch eggs and bring them to safe zone")
AddParagraph(TabAbout, "Plot", "Place, hatch eggs, auto sell")
AddParagraph(TabAbout, "Serverhop", "Idle, time, or night spawn — Auto hop only leaves if one of those boxes has a number")
AddParagraph(TabAbout, "Misc", "ESP, stats, index claim, anti trap / ragdoll, bat aura, flight, bypass speed, optimizer")
AddParagraph(TabAbout, "Webhook", "Discord embeds with the pet/egg icon on steal, hatch, and sell")
local v301 = resolveDiscordInvite()
local v302 = isNonEmptyString(HubInfo.Website)
local v303 = isNonEmptyString(HubInfo.Changelog)
if v301 or v302 or v303 then
    BuildCard(TabAbout, "Links")

    if v301 then
        AddButton(TabAbout, "CopyDiscord", "Discord", v301, "Copy", function()
            if setclipboard then
                pcall(setclipboard, v301)
            end
        end, true)
    end

    if v302 then
        AddButton(TabAbout, "CopySite", "Website", HubInfo.Website, "Copy", function()
            if setclipboard then
                pcall(setclipboard, HubInfo.Website)
            end
        end, false)
    end

    if v303 then
        AddParagraph(TabAbout, "What's new", HubInfo.Changelog)
    end
end
BuildCard(TabAbout, "Credits")
AddParagraph(TabAbout, "Made by", isNonEmptyString(HubInfo.Author) and HubInfo.Author or HubInfo.Title)
if isNonEmptyString(HubInfo.Credits) then
    AddParagraph(TabAbout, "With", HubInfo.Credits)
end
if isNonEmptyString(HubInfo.Support) then
    local v304 = resolveDiscordInvite()

    if not v304 or not string.find(HubInfo.Support, v304, 1, true) then
        AddParagraph(TabAbout, "Support", HubInfo.Support)
    end
end
BuildCard(TabAbout, "Disclaimer")
AddParagraph(TabAbout, "Not official", "Not affiliated with " .. (HubInfo.Game or "this game") .. ". I'm not responsible for any bans, use at your own risk !")
BuildCard(TabAutoSteal, "Auto steal")
AddToggle(TabAutoSteal, "AutoSteal", "Auto steal", "idle · took 0 · lost 0 · re-grabbed 0", false, {
	flag = "StealTravel",
	options = {
		"Speed",
		"Flight"
	}
})
AddSlider(TabAutoSteal, "StealSpeed", "Travel speed", "Studs/s — can pullback if this is too high", 50, 1300, 300, " studs/s")
BuildCard(TabAutoSteal, "Targeting")
AddDropdown(TabAutoSteal, "StealMode", "What to take", "Filters being used from below", {
	"Best value",
	"Egg type filter",
	"Gen ($/s) snipe"
}, "Best value", false)
AddTextbox(TabAutoSteal, "GenSnipeFloor", "Egg ($/s) snipe", "What the pet inside of the egg will pay", "any · e.g. 100m", "", {
	visibleIf = function()
    return Config.StealMode == "Gen ($/s) snipe"
end
})
BuildCard(TabAutoSteal, "Where to look")
AddDropdown(TabAutoSteal, "Areas", "Areas", "which zones to steal from", BiomeList, { unpack(BiomeList) }, true)
BuildCard(TabAutoSteal, "What qualifies")
AddToggle(TabAutoSteal, "UseRarity", "Egg type filter", "off = any egg type counts", false)
AddDropdown(TabAutoSteal, "Rarities", "Egg types", "an egg counts if it is one of these", RarityList, { unpack(RarityList) }, true)
AddToggle(TabAutoSteal, "UseMutation", "Use mutation filter", "off = mutated or not, both fine", false)
AddDropdown(TabAutoSteal, "Mutations", "Mutations", "an egg counts if it carries one of these", TraitList, { unpack(TraitList) }, true)
AddTextbox(TabAutoSteal, "MinWeight", "Minimum weight (Kg)", "the same Kg the game shows — blank for any", "any", "")
BuildCard(TabAutoSteal, "Event")
AddToggle(TabAutoSteal, "AutoEvent", "Auto Hungry Monster", "after filters: grab infested, equip, feed", false)
AddTextbox(TabAutoSteal, "EventKeepGen", "Don't feed if egg makes ($/s)", "keeps high-pay eggs · blank = feed any", "feed any · e.g. 5m", "")
BuildCard(TabPlot, "Eggs & pets")
AddToggle(TabPlot, "AutoPlaceEggs", "Auto place eggs", "idle · placed 0 · hatched 0", false)
AddDropdown(TabPlot, "NeverPlaceRarity", "Never place rarer", "Keeps better eggs in inventory", {
	"Place all",
	unpack(RarityList)
}, "Place all", false)
AddTextbox(TabPlot, "PlaceMinGen", "Only place eggs worth ($/s)", "pen fills with the best first — blank for any", "any · e.g. 1.5m", "")
AddToggle(TabPlot, "AutoHatch", "Auto hatch", "hatches every egg the moment its timer is up", false)
AddToggle(TabPlot, "EquipBest", "Auto place best pets", "uses the game's own equip-best", false)
BuildCard(TabPlot, "Upgrades")
AddToggle(TabPlot, "UpgTrails", "Auto upgrade trails", "idle · bought 0 · sold 0", false)
AddToggle(TabPlot, "UpgTreadmill", "Auto upgrade treadmill", "buys the next treadmill when you can afford it", false)
AddToggle(TabPlot, "UpgPen", "Auto upgrade pen", "more room for pets", false)
AddTextbox(TabPlot, "KeepMoney", "Keep this much money", "never spend below this — blank to spend freely", "spend it all · e.g. 500m", "")
BuildCard(TabPlot, "Selling")
AddButton(TabPlot, "SellPreview", "Preview what will sell", "opens a window under the stats panel — Hover icon to display stats", "Preview", nil, false)
AddTextbox(TabPlot, "SellUnderGen", "Sell anything earning under ($/s)", "blank = nothing sells", "nothing sells · e.g. 250k", "")
AddToggle(TabPlot, "AutoSellPets", "Auto sell pets", "equips then sells at the stall · worst first · only below the floor", false)
AddToggle(TabPlot, "AutoSellEggs", "Auto sell eggs", "equips then sells at the stall · spare eggs only — plot eggs stay", false)
BuildCard(TabPlot, "Treadmill training")
AddToggle(TabPlot, "AutoTreadmill", "Auto treadmill", "not training · 0/s · earned 0 this session", false)
AddToggle(TabPlot, "TrainWhenIdle", "Train when nothing to steal", "only when Auto Steal is off. Auto Steal never wears the belt", true)
AddSlider(TabPlot, "ReadyEarly", "Get ready early", "Step earlier to steal", 0, 15, 4, "s before reset")
BuildCard(TabServerhop, "Auto hop")
AddToggle(TabServerhop, "AutoHop", "Auto hop", "off · 0 hops this session", false)
BuildCard(TabServerhop, "Leave when")
AddTextbox(TabServerhop, "HopIdle", "No steal for (seconds)", "Auto Steal on, nothing banked. Night does not count. Min 5. Blank = off.", "off · 90", "")
AddTextbox(TabServerhop, "HopAfter", "Been here (minutes)", "leave after this long no matter what. Min 1. Blank = off.", "off · 20", "")
BuildCard(TabServerhop, "Leave now")
AddButton(TabServerhop, "HopNow", "Hop now", "one hop. Auto hop can stay off.", "Hop", function()
end, true)
BuildCard(TabServerhop, "Which servers")
AddSlider(TabServerhop, "HopPages", "Pages to fetch", "3 is enough. more pages is slower.", 1, 10, 3, " pages")
AddToggle(TabServerhop, "HopSkipFull", "Skip full servers", "a full server just dumps you back here", true)
AddDropdown(TabServerhop, "HopPlayers", "Players", "Lowest = emptier, Highest = fuller", {
	"Lowest",
	"Highest"
}, "Lowest", false);
(function(p134, p135)
    local v930 = p134.card or p134.scroll
    local t145 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0)
	}

    p134.n = p134.n + 1
    t145.LayoutOrder = p134.n
    t145.ZIndex = 14

    local Frame = Instance.new("Frame")

    if t145 then
        for k, v in pairs(t145) do
            Frame[k] = v
        end
    end

    if v930 then
        Frame.Parent = v930
    end

    local t146 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 6),
		Size = UDim2.new(1, -28, 0, 0),
		Font = Fonts.body,
		Text = p135,
		TextColor3 = Theme.mute,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 15
	}
    local TextLabel = Instance.new("TextLabel")

    if t146 then
        for k, v in pairs(t146) do
            TextLabel[k] = v
        end
    end

    if Frame then
        TextLabel.Parent = Frame
    end

    local t147 = {
		PaddingBottom = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 6)
	}
    local UIPadding = Instance.new("UIPadding")

    if t147 then
        for k, v in pairs(t147) do
            UIPadding[k] = v
        end
    end

    if Frame then
        UIPadding.Parent = Frame
    end

    if TextLabel then
        TextLabel:SetAttribute("th_text", "mute")

        local mute = Theme.mute

        if mute then
            TextLabel.TextColor3 = mute
        end
    end

    p134.items[#p134.items + 1] = {
		kind = "row",
		inst = Frame,
		q = string.lower(p135)
	}
end)(TabServerhop, "skips this job and recent servers — shared across accounts in this workspace")
BuildCard(TabMisc, "Eggs on the map")
AddToggle(TabMisc, "EggESP", "Egg ESP", nil, false)
AddDropdown(TabMisc, "ESPFilter", "Show ESP on", nil, {
	"All eggs",
	"Eggs matching my filters",
	"Stolen target only"
}, "All eggs", false)
AddToggle(TabMisc, "ESPBeam", "Beam to current target", "line to the egg auto steal picked", false)
BuildCard(TabMisc, "Eggs on your plot")
AddToggle(TabMisc, "PlotESP", "Plot egg ESP", "payout and hatch timer — green when ready", false)
BuildCard(TabMisc, "Stats")
AddToggle(TabMisc, "StatsPanel", "Show stats panel", "draggable: money, income, pen, best pet, best egg, speed, session", false)
AddToggle(TabMisc, "ClaimIndex", "Auto claim index", "redeems every completed index entry in one sweep", false)
BuildCard(TabMisc, "Defence")
AddToggle(TabMisc, "AntiTrap", "Anti trap", "Disables traps", false)
AddToggle(TabMisc, "AntiMob", "Anti ragdoll", "guards and other players' bats cannot flop or knock you; your bat still swings", false)
BuildCard(TabMisc, "Bat")
AddToggle(TabMisc, "BatAura", "Bat aura", "swings at any player in range — Auto Steal also equips the bat and chases whoever took your egg", false)
BuildCard(TabMisc, "Walking")
AddToggle(TabMisc, "BypassSpeed", "Bypass speed", "off = normal walk. on = Bypass cap. Auto steal uses Travel speed only while going to an egg, not while looking", false)
AddSlider(TabMisc, "BypassCap", "Bypass speed cap", "studs per second while walking with bypass on", 150, 1300, 880, " studs/s")
BuildCard(TabMisc, "Flight")
AddToggle(TabMisc, "Flight", "Flight", "WASD to fly, Space up, Left Ctrl down — holds altitude when you let go", false)
AddSlider(TabMisc, "FlightSpeed", "Flight speed", "studs per second while flying", 150, 1300, 880, " studs/s")
AddKeybind(TabMisc, "FlightBind", "Flight keybind", "toggles flight without opening the window", HubInfo.FlightBind)
BuildCard(TabMisc, "Performance")
AddToggle(TabMisc, "Optimizer", "Game optimizer", "lowest gfx: shadows, particles, lights, post-fx, terrain water — off restores", false)
AddSlider(TabMisc, "FPSCap", "FPS cap", "0 - no fps cap", 0, 240, 0, "")
BuildCard(TabWebhook, "Connection")
AddToggle(TabWebhook, "HookEnabled", "Send outbound", "", false)
AddTextbox(TabWebhook, "HookUrl", "Endpoint URL", "paste a URL — never committed", "https://", "")
AddButton(TabWebhook, "HookTest", "Test send", "posts a sample embed to the URL above", "Send", function()
end, true)
BuildCard(TabWebhook, "What to send")
AddToggle(TabWebhook, "HookStolen", "Egg stolen", "icon, $/s, rarity, mutations, where it came from", true)
AddToggle(TabWebhook, "HookHatched", "Egg hatched", "icon, $/s, rarity, weight", true)
AddToggle(TabWebhook, "HookSold", "Sold pets or eggs", "icon and what it was earning", false)
AddToggle(TabWebhook, "HookRewards", "Rewards claimed", "index redeem count", false)
BuildCard(TabWebhook, "How much noise")
AddTextbox(TabWebhook, "HookMinGen", "Only eggs earning over ($/s)", "stolen and hatched — blank for everything", "everything · e.g. 50m", "")
AddDropdown(TabWebhook, "HookRarityFloor", "Rarity floor", "stolen and hatched below this rarity are skipped", {
	"Any",
	unpack(RarityList)
}, "Any", false)
AddToggle(TabWebhook, "SessionDigest", "Session recap", "every 10 minutes — stolen, lost, hatched, sold, cash. not a steal ping", false)
BuildCard(TabWebhook, "The message")
AddDropdown(TabWebhook, "HookPing", "Ping", "", {
	"No ping",
	"Here",
	"User id"
}, "No ping", false)
AddTextbox(TabWebhook, "HookUserId", "User id", "optional", "0", "")
AddToggle(TabWebhook, "HookUsername", "Show my Roblox name and headshot", "", false)
AddToggle(TabWebhook, "ExportUrl", "Let exported configs carry the URL", "off by default", false)
BuildCard(TabSettings, "Appearance")
AddToggle(TabSettings, "PhoneUI", "Phone layout", "compact hub for phones / emulators — leave off on PC", IsMobile)
AddSlider(TabSettings, "UIScale", "UI scale", "zooms the hub — does not crush the layout", 75, 125, 100, "%")
AddDropdown(TabSettings, "Theme", "Theme", "dark, light or kozua — mark swaps with the theme", {
	"Dark",
	"Light",
	"Kozua"
}, "Dark", false)
BuildCard(TabSettings, "Keybinds")
AddKeybind(TabSettings, "OpenBind", "Open / close", "press this any time to show or hide", HubInfo.OpenBind)
AddKeybind(TabSettings, "FlightBind2", "Toggle flight", "same bind as the movement page", HubInfo.FlightBind)
AddToggle(TabSettings, "StartMin", "Start minimised", nil, false)
BuildCard(TabSettings, "Config")
AddDropdown(TabSettings, "CfgPreset", "Load config", "new accounts use default", { "default" }, "default", false)
AddTextbox(TabSettings, "CfgSaveName", "Save as", "blank = default", "name · or leave blank", "")
AddButton(TabSettings, "SaveCfgAs", "Save config", "writes kozua/.../configs/<name>.json", "Save", function()
    saveNamedConfig(Config.CfgSaveName)
end, true)
AddButton(TabSettings, "ExportCfg", "Export settings", "copies config to clipboard", "Copy", function()
    saveConfig()

    local ok, result = pcall(function()
        return HttpService:JSONEncode((collectConfig()))
    end)

    if not ok then
        return
    end

    if setclipboard then
        pcall(setclipboard, result)
    end
end, true)
AddTextbox(TabSettings, "ImportPaste", "Import settings", "load config from clipboard", "paste, then press Import", "")
AddButton(TabSettings, "ImportCfg", "Import", nil, "Import", function()
    local ImportPaste = Config.ImportPaste

    if type(ImportPaste) ~= "string" or ImportPaste == "" then
        return
    end

    local ok, result = pcall(function()
        return HttpService:JSONDecode(ImportPaste)
    end)

    if not ok or type(result) ~= "table" then
        return
    end

    applyConfig(result, true)
    ApplyTheme(Config.Theme or "Dark")
    saveConfig(true)
end, false)
BuildCard(TabSettings, "Window")
local u305
AddButton(TabSettings, "ResetWin", "Reset position & size", "window and orb back to the middle at default size", "Reset", function()
    Window.Position = UDim2.fromScale(0.5, 0.5)
    Window.Size = UDim2.fromOffset(WinWidth, WinHeight)
    WindowScale.Scale = 1

    if WidgetRegistry.UIScale and WidgetRegistry.UIScale.set then
        WidgetRegistry.UIScale.set(100)
    end

    if IsMobile then
        Orb.Position = UDim2.new(0, 36, 1, -88)
    else
        Orb.Position = UDim2.new(0, 40, 0.5, 0)
    end

    u305()
end, false)
function WidgetRegistry.UIScale.on(p136)
    WindowScale.Scale = p136 / 100
end
function WidgetRegistry.PhoneUI.on(p137)
    PhoneUILocked = true
    IsMobile = not not p137

    if ApplyResponsiveLayout then
        ApplyResponsiveLayout()
    end
end
function WidgetRegistry.Theme.on(p138)
    ApplyTheme(p138)
end
function WidgetRegistry.FlightBind2.on(p139)
    Config.FlightBind = p139
end
function WidgetRegistry.CfgPreset.on(p140)
    loadNamedConfig(p140, true)
    refreshPresetOptions()
end
local v306 = newInstance("TextButton", {
	Name = "Orb",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = IsMobile and UDim2.new(0, 36, 1, -88) or UDim2.new(0, 40, 0.5, 0),
	Size = UDim2.fromOffset(not IsMobile and 34 or 48, not IsMobile and 34 or 48),
	BackgroundColor3 = Theme.rail,
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	ZIndex = 20
}, ScreenGui);
(function(p141, p142)
    local t148 = {
		CornerRadius = UDim.new(0, p142 or 8)
	}
    local UICorner = Instance.new("UICorner")

    if t148 then
        for k, v in pairs(t148) do
            UICorner[k] = v
        end
    end

    if p141 then
        UICorner.Parent = p141
    end

    return UICorner
end)(v306, not IsMobile and 14 or 18)
applyStroke(v306, "accent", 1.4);
(function(p143, p144, p145)
    if not p143 or not p145 then
        return p143
    end

    p143:SetAttribute("th_" .. p144, p145)

    local v414 = Theme[p145]

    if not v414 then
        return p143
    end

    if p144 == "bg" and p143:IsA("GuiObject") then
        p143.BackgroundColor3 = v414

        return p143
    end

    if p144 == "text" then
        p143.TextColor3 = v414

        return p143
    end

    if p144 == "placeholder" and p143:IsA("TextBox") then
        p143.PlaceholderColor3 = v414

        return p143
    end

    if p144 == "stroke" and p143:IsA("UIStroke") then
        p143.Color = v414

        return p143
    end

    if p144 == "scroll" and p143:IsA("ScrollingFrame") then
        p143.ScrollBarImageColor3 = v414
    end

    return p143
end)(v306, "bg", "rail")
local v307 = createLogoMark(v306, 21, 20)
v307.AnchorPoint = Vector2.new(0.5, 0.5)
v307.Position = UDim2.fromScale(0.5, 0.5)
local u308 = true
function SetVisible(p146)
    u308 = not not p146
    Window.Visible = u308
    v306.Visible = not u308

    if not u308 then
        CloseDropdown()
        DropdownOverlay.Visible = false
    end
end
MinimizeButton.MouseButton1Click:Connect(function()
    SetVisible(false)
end)
v306.MouseButton1Click:Connect(function()
    SetVisible(true)
end)
local u309
local s14
local inputPosition
local Position
local AbsoluteSize
Header.InputBegan:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = true
        s14 = "win"
        inputPosition = input.Position
        Position = Window.Position
    end
end)
Sidebar.InputBegan:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = true
        s14 = "win"
        inputPosition = input.Position
        Position = Window.Position
    end
end)
v306.InputBegan:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = true
        s14 = "orb"
        inputPosition = input.Position
        Position = v306.Position
    end
end)
local v314 = newInstance("Frame", {
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, 0, 1, 0),
	Size = UDim2.fromOffset(not IsMobile and 18 or 32, not IsMobile and 18 or 32),
	ZIndex = 30,
	Active = true
}, Window)
for i = 0, 1 do
    newInstance("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -4 - i * 4, 1, -4),
		Size = UDim2.fromOffset(8 - i * 2, 1),
		BackgroundColor3 = Theme.mute,
		BorderSizePixel = 0,
		ZIndex = 31
	}, v314)
end
v314.InputBegan:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = true
        s14 = "resize"
        inputPosition = input.Position
        AbsoluteSize = Window.AbsoluteSize
        Position = Window.Position
    end
end)
trackDisposable(UserInputService.InputChanged:Connect(function(input)
    if not u309 then
        return
    end

    local UserInputType = input.UserInputType

    if UserInputType ~= Enum.UserInputType.MouseMovement and UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local v1044 = input.Position - inputPosition

    if s14 == "win" then
        Window.Position = UDim2.new(Position.X.Scale, Position.X.Offset + v1044.X, Position.Y.Scale, Position.Y.Offset + v1044.Y)

        return
    end

    if s14 == "orb" then
        v306.Position = UDim2.new(Position.X.Scale, Position.X.Offset + v1044.X, Position.Y.Scale, Position.Y.Offset + v1044.Y)

        return
    end

    if s14 == "resize" then
        local CurrentCamera = workspace.CurrentCamera
        local v1046 = if not CurrentCamera then Vector2.new(1280, 720) else CurrentCamera.ViewportSize
        local Scale = WindowScale.Scale

        if Scale <= 0 then
            Scale = 1
        end

        local v1048 = not IsMobile and 520 or 400
        local v1049 = not IsMobile and 360 or 320
        local v1050 = math.max(v1048, v1046.X - 24)
        local v1051 = math.max(v1049, v1046.Y - 24)
        local v1052 = math.clamp(AbsoluteSize.X / Scale + v1044.X / Scale, v1048, v1050)
        local v1053 = math.clamp(AbsoluteSize.Y / Scale + v1044.Y / Scale, v1049, v1051)

        Window.Size = UDim2.fromOffset(v1052, v1053)
        WinWidth = v1052
        WinHeight = v1053
    end
end))
trackDisposable(UserInputService.InputEnded:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = false
    end
end))
function u305()
    local CurrentCamera = workspace.CurrentCamera
    local v1057 = if not CurrentCamera then Vector2.new(1280, 720) else CurrentCamera.ViewportSize

    if v1057.X < 80 or v1057.Y < 80 then
        return
    end

    local XOffset = Window.Size.X.Offset
    local YOffset = Window.Size.Y.Offset

    if XOffset <= 0 then
        XOffset = WinWidth
    end

    if YOffset <= 0 then
        YOffset = WinHeight
    end

    local v1060 = not IsMobile and 520 or 400
    local v1061 = not IsMobile and 360 or 320
    local v1062 = math.clamp(XOffset, v1060, math.max(v1060, v1057.X - 24))
    local v1063 = math.clamp(YOffset, v1061, math.max(v1061, v1057.Y - 24))

    if v1062 ~= Window.Size.X.Offset or v1063 ~= Window.Size.Y.Offset then
        Window.Size = UDim2.fromOffset(v1062, v1063)
    end
end
WindowScale.Scale = (tonumber(Config.UIScale) or 100) / 100
if IsMobile then
    local v316, v317 = computeWindowSize()

    WinWidth = v316
    WinHeight = v317
    Window.Size = UDim2.fromOffset(v316, v317)
end
u305()
function ApplyResponsiveLayout()
    local v1064 = not not IsMobile

    SidebarWidth = not v1064 and 152 or 128
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
    MainPage.Position = UDim2.fromOffset(SidebarWidth, 2)
    MainPage.Size = UDim2.new(1, -SidebarWidth, 1, -2)
    MinimizeButton.Size = UDim2.fromOffset(not v1064 and 22 or 32, not v1064 and 22 or 32)
    v306.Size = UDim2.fromOffset(not v1064 and 34 or 48, not v1064 and 34 or 48)
    v314.Size = UDim2.fromOffset(not v1064 and 18 or 32, not v1064 and 18 or 32)

    if v1064 then
        v306.Position = UDim2.new(0, 36, 1, -88)

        local v1065, v1066 = computeWindowSize()

        WinWidth = v1065
        WinHeight = v1066
        Window.Size = UDim2.fromOffset(v1065, v1066)
    else
        WinWidth = 620
        WinHeight = 430
        Window.Size = UDim2.fromOffset(WinWidth, WinHeight)
    end

    if u305 then
        u305()
    end
end
local function v318()
    if PhoneUILocked then
        return
    end

    if isMobile() and not IsMobile then
        IsMobile = true
        ApplyResponsiveLayout()

        if WidgetRegistry.PhoneUI and WidgetRegistry.PhoneUI.set then
            pcall(WidgetRegistry.PhoneUI.set, true)
        end
    end
end
task.defer(v318)
for _, v in ipairs({
	0.2,
	0.6,
	1.2,
	2.5
}) do
    task.delay(v, v318)
end
task.spawn(function()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

    if not PlayerGui then
        pcall(function()
            PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 8)
        end)
    end

    if not PlayerGui then
        return
    end

    local connection = PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "TouchGui" or child.Name == "TouchControlFrame" then
            if PhoneUILocked then
                return
            end

            if isMobile() and not IsMobile then
                IsMobile = true
                ApplyResponsiveLayout()

                if WidgetRegistry.PhoneUI and WidgetRegistry.PhoneUI.set then
                    pcall(WidgetRegistry.PhoneUI.set, true)
                end
            end
        end
    end)

    if connection then
        CleanupList[#CleanupList + 1] = connection
    end

    if not PhoneUILocked and isMobile() and not IsMobile then
        IsMobile = true
        ApplyResponsiveLayout()

        if WidgetRegistry.PhoneUI and WidgetRegistry.PhoneUI.set then
            pcall(WidgetRegistry.PhoneUI.set, true)
        end
    end
end)
pcall(function()
    local connection = UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(v318)

    if connection then
        CleanupList[#CleanupList + 1] = connection
    end

    local connection3 = UserInputService:GetPropertyChangedSignal("GyroscopeEnabled"):Connect(v318)

    if connection3 then
        CleanupList[#CleanupList + 1] = connection3
    end

    local connection4 = UserInputService:GetPropertyChangedSignal("AccelerometerEnabled"):Connect(v318)

    if connection4 then
        CleanupList[#CleanupList + 1] = connection4
    end
end)
pcall(function()
    local CurrentCamera = workspace.CurrentCamera

    if CurrentCamera then
        local connection = CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not PhoneUILocked and isMobile() and not IsMobile then
                IsMobile = true
                ApplyResponsiveLayout()

                if WidgetRegistry.PhoneUI and WidgetRegistry.PhoneUI.set then
                    pcall(WidgetRegistry.PhoneUI.set, true)
                end
            end

            u305()
        end)

        if connection then
            CleanupList[#CleanupList + 1] = connection
        end
    end

    local connection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        local CurrentCamera2 = workspace.CurrentCamera

        if CurrentCamera2 then
            local connection = CurrentCamera2:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                if not PhoneUILocked and isMobile() and not IsMobile then
                    IsMobile = true
                    ApplyResponsiveLayout()

                    if WidgetRegistry.PhoneUI and WidgetRegistry.PhoneUI.set then
                        pcall(WidgetRegistry.PhoneUI.set, true)
                    end
                end

                u305()
            end)

            if connection then
                CleanupList[#CleanupList + 1] = connection
            end

            u305()
        end
    end)

    if connection then
        CleanupList[#CleanupList + 1] = connection
    end
end)
trackDisposable(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if (Config.OpenBind or HubInfo.OpenBind) == input.KeyCode then
        SetVisible(not u308)
    end
end))
local n5 = 0
local elapsed = os.clock()
trackDisposable(RunService.RenderStepped:Connect(function()
    n5 += 1

    local elapsed2 = os.clock()

    if elapsed2 - elapsed < 0.4 then
        return
    end

    local v1078 = math.floor(n5 / (elapsed2 - elapsed) + 0.5)

    n5 = 0
    elapsed = elapsed2

    local n6 = 0

    pcall(function()
        local v1387 = Stats.Network.ServerStatsItem["Data Ping"]

        n6 = math.floor(v1387:GetValue())
    end)
    HeaderStatPill2.Text = v1078 .. " fps"
    HeaderStatPill1.Text = n6 .. " ms"
    HeaderStatPill1.TextColor3 = n6 < 90 and Theme.ok or Theme.dim
end))
local function u323()
    if CloseDropdown then
        pcall(CloseDropdown)
    end

    for i = 1, #CleanupList do
        local v1081 = CleanupList[i]

        CleanupList[i] = nil

        if v1081 then
            pcall(function()
                v1081:Disconnect()
            end)
        end
    end

    if ScreenGui then
        pcall(function()
            ScreenGui:Destroy()
        end)
    end
end
if Config.StartMin then
    SetVisible(false)
end
function ApplyTheme(p147)
    if p147 == "Dusk" or p147 == "dusk" then
        p147 = "Dark"
    end

    local v1083 = ThemePresets[p147] or ThemePresets.Dark
    local s15

    if v1083 == ThemePresets.Light then
        s15 = "Light"
    elseif v1083 == ThemePresets.Kozua then
        s15 = "Kozua"
    else
        s15 = "Dark"
        v1083 = ThemePresets.Dark
    end

    Config.Theme = s15

    for k, v in pairs(v1083) do
        Theme[k] = v
    end

    local function v1087(p148)
        local th_bg = p148:GetAttribute("th_bg")

        if th_bg and (Theme[th_bg] and p148:IsA("GuiObject")) then
            local v1390 = TweenRegistry[p148]

            if v1390 then
                pcall(function()
                    v1390:Cancel()
                end)
                TweenRegistry[p148] = nil
            end

            local th_hover = p148:GetAttribute("th_hover")
            local v1392 = p148:GetAttribute("th_over") == true

            p148.BackgroundColor3 = v1392 and (not not th_hover and Theme[th_hover]) or Theme[th_bg]

            if p148:GetAttribute("th_row") then
                p148.BackgroundTransparency = not v1392 and 1 or 0
            end
        end

        local th_text = p148:GetAttribute("th_text")

        if th_text and Theme[th_text] then
            pcall(function()
                p148.TextColor3 = Theme[th_text]
            end)
        end

        if p148:IsA("TextBox") then
            local th_placeholder = p148:GetAttribute("th_placeholder")

            if th_placeholder and Theme[th_placeholder] then
                p148.PlaceholderColor3 = Theme[th_placeholder]
            end
        end

        if p148:IsA("UIStroke") then
            local th_stroke = p148:GetAttribute("th_stroke")

            if th_stroke and Theme[th_stroke] then
                p148.Color = Theme[th_stroke]
            end
        end

        if p148:IsA("ImageLabel") then
            local th_img = p148:GetAttribute("th_img")

            if th_img and Theme[th_img] then
                p148.ImageColor3 = Theme[th_img]
            end
        end

        if p148:IsA("ScrollingFrame") then
            local th_scroll = p148:GetAttribute("th_scroll")

            if th_scroll and Theme[th_scroll] then
                p148.ScrollBarImageColor3 = Theme[th_scroll]
            end
        end
    end

    v1087(Window)
    v1087(v306)

    for _, descendant in ipairs(ScreenGui:GetDescendants()) do
        v1087(descendant)
    end

    refreshLogoImages()
    tintIcon(SearchIcon, Theme.mute)

    for _, v in pairs(TabRegistry) do
        local scroll = v.scroll

        if scroll then
            local CanvasPosition = scroll.CanvasPosition

            scroll.CanvasPosition = CanvasPosition + Vector2.new(0, 1)
            scroll.CanvasPosition = CanvasPosition
        end
    end

    if ActiveTab then
        SelectTab(ActiveTab.name)
    end

    for k, v in pairs(WidgetRegistry) do
        if v.kind == "toggle" and v.set then
            v.set(Config[k] == true)
        end
    end
end
SelectTab("Auto Steal")
local v324 = getEnvTable()
local v325 = getUserSlot()
v325.alive = true
local KozuaUI = {
	Flags = Config,
	Widgets = WidgetRegistry,
	SetPage = SelectTab,
	SetVisible = SetVisible,
	SetTheme = ApplyTheme,
	Destroy = u323,
	SetStatus = function(p149, p150)
    local v1098 = WidgetRegistry[p149]

    if v1098 and v1098.status then
        v1098.status.Text = p150
    end
end,
	On = function(p151, p152)
    local v1101 = WidgetRegistry[p151]

    if v1101 then
        v1101.on = p152
    end
end
}
v325.UI = KozuaUI
v324.KozuaUI = type(v324.KozuaUI) == "table" and v324.KozuaUI or {}
v324.KozuaUI[UserIdStr] = KozuaUI
if type(v324.UI) ~= "table" or not (function()
    local KozuaHub = (getgenv and getgenv() or _G).KozuaHub
    local v354 = type(KozuaHub) == "table" and KozuaHub.slots

    if type(v354) ~= "table" then
        return false
    end

    for k, v in pairs(v354) do
        if tostring(k) ~= UserIdStr and type(v) == "table" and v.alive == true then
            return true
        end
    end

    return false
end)() then
    v324.UI = KozuaUI
end;
--[[ kozua UI layer — branding, live header read-out, toasts, tab glow, shimmer, watermark.
     Presentation only: no steal/hatch/hop/fly behaviour is touched here. ]]
do
    local KozuaTween = game:GetService("TweenService")
    local TOAST_W, TOAST_H, TOAST_GAP = 236, 34, 8

    local ToastStack = newInstance("Frame", {
		Name = "KozuaToasts",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -14, 1, -14),
		Size = UDim2.fromOffset(TOAST_W, 8),
		ZIndex = 40
	}, Window)

    local liveToasts = {}

    function kozuaToast(text, kind)
        if type(text) ~= "string" or text == "" then
            return
        end

        if not ToastStack or not Window then
            return
        end

        local tone = kind == "ok" and Theme.ok or (kind == "bad" and Theme.accentHover or Theme.accent)
        local card = newInstance("Frame", {
			Name = "Toast",
			BackgroundColor3 = Theme.card,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, -(TOAST_H + 18)),
			Size = UDim2.fromOffset(TOAST_W, TOAST_H),
			ZIndex = 41
		}, ToastStack)

        card:SetAttribute("th_bg", "card")

        local cardStroke = newInstance("UIStroke", {
			Color = Theme.line or Theme.card,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, card)

        cardStroke:SetAttribute("th_stroke", "line")
        newInstance("UICorner", {
			CornerRadius = UDim.new(0, 9)
		}, card)

        local toneBar = newInstance("Frame", {
			Name = "Tone",
			BackgroundColor3 = tone,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 6),
			Size = UDim2.fromOffset(3, TOAST_H - 12),
			ZIndex = 42
		}, card)

        local label = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(18, 0),
			Size = UDim2.new(1, -26, 1, 0),
			Font = Fonts.body,
			Text = text,
			TextColor3 = Theme.text,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 42
		}, card)

        label:SetAttribute("th_text", "text")

        local entry = {
			card = card,
			label = label,
			bar = toneBar,
			slot = 1
		}

        for _, other in ipairs(liveToasts) do
            other.slot = other.slot + 1
            tween(other.card, 0.2, {
				Position = UDim2.fromOffset(0, -(other.slot * (TOAST_H + TOAST_GAP)))
			})
        end

        table.insert(liveToasts, entry)
        tween(card, 0.24, {
			Position = UDim2.fromOffset(0, -(TOAST_H + TOAST_GAP))
		})

        task.delay(2.6, function()
            if not card.Parent then
                return
            end

            tween(card, 0.22, {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, -(TOAST_H + 18))
			})
            tween(label, 0.22, {
				TextTransparency = 1
			})
            tween(toneBar, 0.22, {
				BackgroundTransparency = 1
			})
            task.delay(0.26, function()
                for i, other in ipairs(liveToasts) do
                    if other.card == card then
                        table.remove(liveToasts, i)

                        break
                    end
                end

                pcall(function()
                    card:Destroy()
                end)

                for _, other in ipairs(liveToasts) do
                    other.slot = other.slot - 1
                    tween(other.card, 0.2, {
						Position = UDim2.fromOffset(0, -(other.slot * (TOAST_H + TOAST_GAP)))
					})
                end
            end)
        end)
    end

    local shimmer = newInstance("Frame", {
		Name = "KozuaShimmer",
		BackgroundColor3 = Theme.accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, 2),
		ZIndex = 13
	}, Header)

    shimmer:SetAttribute("th_bg", "accent")

    local shimmerGradient = newInstance("UIGradient", {
		Offset = Vector2.new(-0.8, 0),
		Rotation = 0,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
	}, shimmer)

    local shimmerTween = KozuaTween:Create(shimmer, TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Offset = Vector2.new(0.8, 0)
	})

    shimmerTween:Play()

    trackDisposable(Window:GetPropertyChangedSignal("Visible"):Connect(function()
        pcall(function()
            if Window.Visible then
                shimmerTween:Play()
            else
                shimmerTween:Pause()
            end
        end)
    end))

    local livePill

    if not IsMobile then
        livePill = newInstance("TextLabel", {
			Name = "KozuaLivePill",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Theme.card,
			Position = UDim2.new(1, -166, 0.5, 2),
			Size = UDim2.fromOffset(74, 22),
			Font = Fonts.mono,
			Text = "-- online",
			TextColor3 = Theme.dim,
			TextSize = 10,
			ZIndex = 12
		}, Header)

        livePill:SetAttribute("th_bg", "card")
        livePill:SetAttribute("th_text", "dim")

        local liveStroke = newInstance("UIStroke", {
			Color = Theme.line or Theme.card,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, livePill)

        liveStroke:SetAttribute("th_stroke", "line")
        newInstance("UICorner", {
			CornerRadius = UDim.new(0, 7)
		}, livePill)

        local liveFrames, liveLast = 0, os.clock()

        trackDisposable(RunService.RenderStepped:Connect(function()
            if not livePill then
                return
            end

            liveFrames += 1

            local now = os.clock()

            if now - liveLast < 0.5 then
                return
            end

            local fps = math.floor(liveFrames / (now - liveLast) + 0.5)

            liveFrames = 0
            liveLast = now

            local online = #Players:GetPlayers()

            livePill.Text = "#" .. online .. " online · " .. fps .. " fps"
            livePill.TextColor3 = online > 1 and Theme.ok or Theme.dim
        end))
    end

    local sideMark = newInstance("TextLabel", {
		Name = "KozuaMark",
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 1, -8),
		Size = UDim2.fromOffset(math.max(60, SidebarWidth - 24), 12),
		Font = Fonts.mono,
		Text = "kozua · keyless",
		TextColor3 = Theme.mute,
		TextSize = 9,
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 13
	}, Sidebar)

    sideMark:SetAttribute("th_text", "mute")

    local glow = newInstance("Frame", {
		Name = "KozuaTabGlow",
		BackgroundColor3 = Theme.accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.fromOffset(3, 20),
		ZIndex = 13
	}, Sidebar)

    glow:SetAttribute("th_bg", "accent")

    newInstance("UICorner", {
		CornerRadius = UDim.new(0, 2)
	}, glow)

    local function sidebarButtonFor(tabName)
        if not Sidebar or type(tabName) ~= "string" then
            return nil
        end

        for _, child in ipairs(Sidebar:GetDescendants()) do
            if child:IsA("TextButton") then
                for _, sub in ipairs(child:GetChildren()) do
                    if sub:IsA("TextLabel") and sub.Text == tabName then
                        return child
                    end
                end
            end
        end

        return nil
    end

    local glowPrimed = false

    local function moveGlow(tabName)
        local btn = sidebarButtonFor(tabName)

        if not btn or not Sidebar then
            return
        end

        local scale = (WindowScale and WindowScale.Scale) or 1

        if not (scale > 0) then
            scale = 1
        end

        local centerY = (btn.AbsolutePosition.Y + btn.AbsoluteSize.Y * 0.5 - Sidebar.AbsolutePosition.Y) / scale
        local height = math.max(10, btn.AbsoluteSize.Y / scale - 6)
        local goal = {
			BackgroundTransparency = 0,
			Position = UDim2.fromOffset(4, math.round(centerY - height * 0.5)),
			Size = UDim2.fromOffset(3, math.round(height))
		}

        if glowPrimed then
            tween(glow, 0.18, goal)
        else
            glowPrimed = true
            glow.BackgroundTransparency = goal.BackgroundTransparency
            glow.Position = goal.Position
            glow.Size = goal.Size
        end
    end

    local rawSelectTab = SelectTab

    SelectTab = function(selectName)
        rawSelectTab(selectName)
        moveGlow(selectName)
    end

    KozuaUI.SetPage = SelectTab

    local rawApplyTheme = ApplyTheme

    ApplyTheme = function(themeName)
        rawApplyTheme(themeName)

        pcall(function()
            shimmer.BackgroundColor3 = Theme.accent
            glow.BackgroundColor3 = Theme.accent

            if ActiveTab then
                moveGlow(ActiveTab.name)
            end
        end)
    end

    KozuaUI.SetTheme = ApplyTheme
    KozuaUI.Toast = kozuaToast
    KozuaUI.Brand = "KOZUA"
    v325.Toast = kozuaToast

    -- phone layout squeezes the header: drop the wide live pill rather than let it sit on the title
    local rawResponsive = ApplyResponsiveLayout

    ApplyResponsiveLayout = function()
        rawResponsive()

        if IsMobile and livePill then
            livePill:Destroy()
            livePill = nil
        end
    end

    if ActiveTab then
        moveGlow(ActiveTab.name)
    end

    local kozuaEnv = getEnvTable()

    kozuaEnv.kozua = {
		Name = "KOZUA",
		Version = HubInfo.Version,
		Status = HubInfo.Status,
		Game = HubInfo.Game,
		Keyless = true,
		Config = Config,
		Flags = Config,
		Widgets = WidgetRegistry,
		UI = KozuaUI,
		Toast = kozuaToast,
		Dump = function(...)
            return v324.KozuaDump(...)
        end,
		Unload = function(...)
            return v324.KozuaUnload(...)
        end,
		SetPage = function(...)
            return KozuaUI.SetPage(...)
        end,
		SetTheme = function(...)
            return KozuaUI.SetTheme(...)
        end,
		Hide = function()
            return SetVisible(false)
        end,
		Show = function()
            return SetVisible(true)
        end
    }
end
(function()
    local function KozuaLog(p153, ...)
        warn("[kozua/" .. tostring(p153) .. "]", ...)
    end
    local EggState
    local Directory
    local Directory2
    local ok, result = pcall(function()
        return require(ReplicatedStorage.Client.EggState)
    end)
    if ok then
        EggState = result
    else
        KozuaLog("modules", "EggState require failed", (tostring(result)))
    end
    local ok3, result3 = pcall(function()
        return require(ReplicatedStorage.Data.Assets)
    end)
    if ok3 and type(result3) == "table" then
        Directory = result3.Directory
    else
        KozuaLog("modules", "Assets require failed", (tostring(result3)))
    end
    local ok4, result4 = pcall(function()
        return require(ReplicatedStorage.Data.Areas)
    end)
    if ok4 and type(result4) == "table" then
        Directory2 = result4.Directory

        if type(Directory2) == "table" then
            KozuaLog("modules", "areas dir", "ok")
        end
    else
        KozuaLog("modules", "Areas require failed", (tostring(result4)))
    end
    local function GetCharParts()
        local Character = LocalPlayer.Character

        if not Character then
            return
        end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if not Humanoid or not HumanoidRootPart or Humanoid.Health <= 0 then
            return
        end

        return Humanoid, HumanoidRootPart, Character
    end
    local function v1113()
        local CurrentCamera = workspace.CurrentCamera

        if not CurrentCamera then
            return Vector3.new(0, 0, -1)
        end

        local vector3 = Vector3.new(CurrentCamera.CFrame.LookVector.X, 0, CurrentCamera.CFrame.LookVector.Z)

        if vector3.Magnitude < 0.001 then
            return Vector3.new(0, 0, -1)
        end

        return vector3.Unit
    end
    local t150 = {
		"VerticalTrajectory",
		"CorrectionContext",
		"PivotTo",
		"Relocate",
		"Authoritative WalkSpeed",
		"BeginImpulse",
		"LastValidatedGroundedSample"
	}
    local t151 = {
		"LastGoodSample",
		"LastObservedSample",
		"LastValidatedSample",
		"LastValidatedGroundedSample",
		"LastConfirmedGroundSample",
		"LastSample",
		"LastGameplayTrustedSample"
	}
    local EngineOn = false
    local IsAlive = true
    local u1118
    local u1119
    local u1120
    local ConnList = {}
    local t153 = {}
    local t154 = {}
    local MoveWraps = {}
    local n7 = 0.016666666666667
    local n8 = 0
    local StealDest
    local StealActive = false
    local n9 = 16
    local IsFlying
    local EnsureFlight
    local StealTick
    local StealState
    local PanelCtl
    local FarmSync
    local function v1136(p154)
        if p154 then
            ConnList[p154] = true
        end

        return p154
    end
    local function v1137()
        for k in pairs(ConnList) do
            ConnList[k] = nil
            pcall(function()
                k:Disconnect()
            end)
        end
    end
    local function v1138(p155, p156)
        local v1415 = p156 or 16

        if not debug or not debug.getconstants then
            return {}
        end

        local ok5, result5 = pcall(debug.getconstants, p155)

        if not ok5 or type(result5) ~= "table" then
            return {}
        end

        local t156 = {}
        local n10 = 0

        for _, v in pairs(result5) do
            n10 += 1

            if n10 <= v1415 then
                t156[#t156 + 1] = tostring(v)
            end
        end

        return t156
    end
    local function v1139(p157)
        local v1423 = table.concat(v1138(p157, 50), "|")

        for _, v in ipairs(t150) do
            if v1423:find(v, 1, true) then
                return true, v
            end
        end

        if v1423:find("WalkSpeed", 1, true) and v1423:find("AssemblyLinearVelocity", 1, true) and v1423:find("Magnitude", 1, true) then
            return true, "ALVvsWalkSpeed"
        end

        return false
    end
    local function v1140(p158, p159, p160, p161, p162)
        if type(p158) ~= "table" or not p159 then
            return
        end

        local v1441 = v1113()

        if StealActive and Config.StealTravel == "Flight" and not Config.Flight and StealState and typeof(StealState.flyLook) == "Vector3" then
            v1441 = StealState.flyLook
        end

        local cFrame = CFrame.new(p161, p161 + v1441)

        pcall(function()
            p158.Position = p161
            p158.CFrame = cFrame
            p158.LinearVelocity = p162
            p158.AngularVelocity = Vector3.zero
            p158.IsSupported = true
            p158.Timestamp = os.clock()

            if p160 then
                p158.WalkSpeed = p160.WalkSpeed
                p158.JumpPower = p160.JumpPower
                p158.JumpHeight = p160.JumpHeight
                p158.UseJumpPower = p160.UseJumpPower
                p158.HumanoidState = Enum.HumanoidStateType.Running
            end

            p158.Gravity = workspace.Gravity
        end)
    end
    local function v1141(p163, p164, p165, p166, p167)
        local v1453

        if type(p163) ~= "table" then
            v1453 = false
        else
            local ok6, result6 = pcall(rawget, p163, "LastGoodSample")
            local ok7, result7 = pcall(rawget, p163, "SafeGroundCheckpoints")

            v1453 = ok6 and (type(result6) == "table" and (ok7 and type(result7) == "table"))
        end

        if not v1453 then
            return
        end

        local v1459

        if type(p163) == "table" and type(p163.ExpectedHipHeight) == "number" then
            local v1458 = type(p163.ExpectedRootHalfHeight) == "number" and p163.ExpectedRootHalfHeight or 1

            v1459 = p163.ExpectedHipHeight + v1458 * 0.5
        else
            v1459 = 2.51
        end

        local v1460 = v1459

        pcall(function()
            local elapsed3 = os.clock()

            p163.MaxHorizontalSpeed = 10000000
            p163.MaxVerticalSpeed = 10000000
            p163.IsSupportedNow = true
            p163.LastSupportedAt = elapsed3
            p163.LastCorrectionAt = 0
            p163.HighestYSinceGround = p166.Y
            p163.MovementMode = "Grounded"
            p163.TelemetryRepeatCount = 0
            p163.ValidationLocked = false
            p163.MonitorRunning = false
            p163.MonitorPending = false
            p163.ThreatLevel = "Trusted"
            p163.WasMeaningfullyFalling = false
            p163.InitializingUntil = elapsed3 + 3600
            p163.SupportStartedAt = elapsed3
            p163.ValidationStartedAt = elapsed3

            local GroundContactWitness = p163.GroundContactWitness

            if type(GroundContactWitness) == "table" then
                GroundContactWitness.GroundDistance = v1460
                GroundContactWitness.GroundPosition = Vector3.new(p166.X, p166.Y - v1460, p166.Z)

                if p164.Parent then
                    GroundContactWitness.Character = p164.Parent
                end

                if type(GroundContactWitness.ContactSample) == "table" then
                    v1140(GroundContactWitness.ContactSample, p164, p165, p166, p167)
                end
            end

            local Evidence = p163.Evidence

            if type(Evidence) == "table" then
                Evidence.Speed = 0
                Evidence.Flight = 0
                Evidence.Teleport = 0
            end

            local LastVerticalTrajectoryDecision = p163.LastVerticalTrajectoryDecision

            if type(LastVerticalTrajectoryDecision) == "table" then
                LastVerticalTrajectoryDecision.Active = false
                LastVerticalTrajectoryDecision.CorrectionStarted = false
                LastVerticalTrajectoryDecision.ConsecutiveInvalidWindows = 0
                LastVerticalTrajectoryDecision.EvidenceEventCount = 0
                LastVerticalTrajectoryDecision.MeaningfulDescent = false
                LastVerticalTrajectoryDecision.LandingCandidate = false
                LastVerticalTrajectoryDecision.CurrentY = p166.Y
                LastVerticalTrajectoryDecision.PeakY = p166.Y
                LastVerticalTrajectoryDecision.StartY = p166.Y
                LastVerticalTrajectoryDecision.AirborneDuration = 0
                LastVerticalTrajectoryDecision.LandingDuration = 0
                LastVerticalTrajectoryDecision.LatestLegalSampleAge = 0
                LastVerticalTrajectoryDecision.AllowedRise = 10000000
                LastVerticalTrajectoryDecision.AllowedAirborneDuration = 10000000
                LastVerticalTrajectoryDecision.Evidence = 0
                LastVerticalTrajectoryDecision.PrimaryEvidenceSource = "None"
            end

            local LastVerticalSegmentDecision = p163.LastVerticalSegmentDecision

            if type(LastVerticalSegmentDecision) == "table" then
                LastVerticalSegmentDecision.Active = false
                LastVerticalSegmentDecision.CorrectionStarted = false
                LastVerticalSegmentDecision.Displacement = 0
                LastVerticalSegmentDecision.Excess = 0
                LastVerticalSegmentDecision.AllowedDistance = 10000000
                LastVerticalSegmentDecision.Decision = "Reachable"
                LastVerticalSegmentDecision.CurrentY = p166.Y
                LastVerticalSegmentDecision.PreviousY = p166.Y
                LastVerticalSegmentDecision.MovementContext = "OrdinaryStationaryY"
            end
        end)

        for _, v in ipairs(t151) do
            v1140(p163[v], p164, p165, p166, p167)
        end

        local SampleHistory = p163.SampleHistory

        if type(SampleHistory) == "table" then
            for _, v in pairs(SampleHistory) do
                if type(v) == "table" then
                    v1140(v, p164, p165, p166, p167)
                end
            end
        end

        local SafeGroundCheckpoints = p163.SafeGroundCheckpoints

        if type(SafeGroundCheckpoints) == "table" then
            for _, v in pairs(SafeGroundCheckpoints) do
                if type(v) == "table" then
                    v1140(v, p164, p165, p166, p167)
                end
            end
        end
    end
    local function FlightEnable()
        t153 = {}

        if not getconnections then
            KozuaLog("engine", "no getconnections — wraps skipped")

            return 0
        end

        local t157 = {}

        for _, v in ipairs(getconnections(RunService.PostSimulation)) do
            if not ConnList[v] and v1139(v.Function) then
                pcall(function()
                    v:Enable()
                end)

                for i = 1, 24 do
                    local Function = v.Function
                    local ok8, result8, v1476 = pcall(debug.getupvalue, Function, i)
                    local v1477 = if ok8 then if v1476 == nil then result8 else v1476 else nil

                    if v1477 == nil then
                        break
                    end

                    if type(v1477) == "table" and not t157[v1477] then
                        t157[v1477] = true
                        t153[#t153 + 1] = v1477
                    end
                end
            end
        end

        return #t153
    end
    local function FlightDisable()
        local t158 = {}
        local t159 = {}

        for i = 1, #t153 do
            local v1481 = t153[i]
            local v1482

            if type(v1481) ~= "table" then
                v1482 = false
            else
                local ok9, result9 = pcall(rawget, v1481, "LastGoodSample")
                local ok10, result10 = pcall(rawget, v1481, "SafeGroundCheckpoints")

                v1482 = ok9 and (type(result9) == "table" and (ok10 and type(result10) == "table"))
            end

            if v1482 and not t158[v1481] then
                t158[v1481] = true
                t159[#t159 + 1] = v1481
            end
        end

        for i = 1, #t154 do
            local v1488 = t154[i]
            local v1489

            if type(v1488) ~= "table" then
                v1489 = false
            else
                local ok11, result11 = pcall(rawget, v1488, "LastGoodSample")
                local ok12, result12 = pcall(rawget, v1488, "SafeGroundCheckpoints")

                v1489 = ok11 and (type(result11) == "table" and (ok12 and type(result12) == "table"))
            end

            if v1489 and not t158[v1488] then
                t158[v1488] = true
                t159[#t159 + 1] = v1488
            end
        end

        if #t159 > 0 then
            t154 = t159
        end

        return #t154
    end
    local function v1144()
        u1120 = nil

        local v1494 = u1119 ~= nil

        if u1119 then
            pcall(function()
                u1119:Destroy()
            end)
            u1119 = nil
        end

        if v1494 then
            for _, child in ipairs(workspace:GetChildren()) do
                if child.Name == "KozuaSupport" or child.Name == "Hub45Support" then
                    pcall(function()
                        child:Destroy()
                    end)
                end
            end
        end
    end
    local u1145 = false
    local function v1146(p168, p169, p170)
        v1144()

        if not p168 or not p169 then
            local Character = LocalPlayer.Character
            local v1503, v1504

            if not Character then
                v1503 = nil
                v1504 = nil
            else
                v1503 = Character:FindFirstChildOfClass("Humanoid")
                v1504 = Character:FindFirstChild("HumanoidRootPart")

                if not v1503 or not v1504 or v1503.Health <= 0 then
                    v1503 = nil
                    v1504 = nil
                end
            end

            p168 = p168 or v1503
            p169 = p169 or v1504
        end

        if not p168 then
            return
        end

        pcall(function()
            p168.PlatformStand = false
            p168.Sit = false
            p168.AutoRotate = true
            p168.AutoJumpEnabled = true
            p168.Jump = false

            if type(p168.WalkSpeed) == "number" and p168.WalkSpeed > 0 and p168.WalkSpeed <= 36 then
                n9 = p168.WalkSpeed
            end

            p168.WalkSpeed = n9

            if p170 then
                p168:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end)

        if p169 then
            pcall(function()
                p169.Anchored = false

                if p170 then
                    local AssemblyLinearVelocity = p169.AssemblyLinearVelocity

                    p169.AssemblyLinearVelocity = Vector3.new(0, math.min(AssemblyLinearVelocity.Y, -22), 0)
                end

                p169.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
    local function v1147(p171)
        if typeof(p171) ~= "Vector3" then
            return nil
        end

        local raycastParams = RaycastParams.new()

        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local t160 = { LocalPlayer.Character }

        if u1119 then
            t160[#t160 + 1] = u1119
        end

        if workspace.CurrentCamera then
            t160[#t160 + 1] = workspace.CurrentCamera
        end

        raycastParams.FilterDescendantsInstances = t160

        local vector3 = Vector3.new(p171.X, math.max(p171.Y + 48, 80), p171.Z)
        local raycastResult = workspace:Raycast(vector3, Vector3.new(0, -360, 0), raycastParams)

        if raycastResult and raycastResult.Instance and raycastResult.Instance.CanCollide then
            return raycastResult.Position.Y
        end

        if raycastResult then
            return raycastResult.Position.Y
        end

        return p171.Y
    end
    local function v1148(p172, p173)
        if not p172 then
            return
        end

        if not u1119 or not u1119.Parent then
            v1144()

            local Part = Instance.new("Part")

            Part.Name = "KozuaSupport"
            Part.Size = Vector3.new(8, 1.2, 8)
            Part.Anchored = true
            Part.CanCollide = true
            Part.CanQuery = true
            Part.CanTouch = false
            Part.CastShadow = false
            Part.Transparency = 1
            Part.Material = Enum.Material.Concrete
            Part.Parent = workspace
            u1119 = Part
        end

        local max = math.max
        local v1516 = t154[1]
        local v1518

        if type(v1516) == "table" and type(v1516.ExpectedHipHeight) == "number" then
            local v1517 = type(v1516.ExpectedRootHalfHeight) == "number" and v1516.ExpectedRootHalfHeight or 1

            v1518 = v1516.ExpectedHipHeight + v1517 * 0.5
        else
            v1518 = 2.51
        end

        local v1519 = max(3.8, v1518)

        if StealActive and typeof(StealDest) == "Vector3" and type(IsFlying) == "function" and IsFlying() then
            u1120 = p172.Position.Y - v1519 - 0.6
            u1119.CFrame = CFrame.new(p172.Position.X, u1120, p172.Position.Z)

            return
        end

        local v1520 = p172.Position.Y - v1519 - 0.6
        local v1521 = tonumber(p173) or 0

        if u1120 == nil then
            u1120 = v1520
        elseif v1521 > 8 then
            u1120 = math.max(u1120, v1520)
        elseif v1521 < -8 then
            u1120 = v1520
        else
            local v1522 = u1120 + 0.6

            if p172.Position.Y - v1522 > v1519 + 8 then
                u1120 = v1520
            end
        end

        u1119.CFrame = CFrame.new(p172.Position.X, u1120, p172.Position.Z)
    end
    local function v1149(p174, p175, p176)
        local WalkSpeed = p175.WalkSpeed
        local v1527 = math.max(10, WalkSpeed or 16)
        local v1528 = if not (p176.Magnitude > v1527 + 1) then p176 else p176.Magnitude > 0.0001 and p176.Unit * v1527 or Vector3.zero

        pcall(function()
            p174.AssemblyLinearVelocity = v1528
        end)

        for i = 1, #t154 do
            v1141(t154[i], p174, p175, p174.Position, v1528)
        end
    end
    local function FlightSetWrap(p177)
        if p177 then
            if not hookfunction or not getconnections then
                KozuaLog("engine", "cannot wrap PostSim validators")

                return 0
            end

            local n11 = 0

            for _, v in ipairs(getconnections(RunService.PostSimulation)) do
                if not ConnList[v] then
                    local v1534, v1535 = v1139(v.Function)
                    local Function = v.Function

                    if v1534 and not MoveWraps[Function] then
                        local t161 = {
							old = Function
						}

                        local function v1538(...)
                            local Character = LocalPlayer.Character
                            local v2705, v2706
                            if not Character then
                                v2705 = nil
                                v2706 = nil
                            else
                                v2705 = Character:FindFirstChildOfClass("Humanoid")
                                v2706 = Character:FindFirstChild("HumanoidRootPart")

                                if not v2705 or not v2706 or v2705.Health <= 0 then
                                    v2705 = nil
                                    v2706 = nil
                                end
                            end
                            local v2707 = v2706
                            local AssemblyLinearVelocity
                            local CFrame2
                            if v2707 and v2705 then
                                AssemblyLinearVelocity = v2707.AssemblyLinearVelocity
                                CFrame2 = v2707.CFrame

                                if IsFlying() then
                                    v1148(v2707, 0)
                                end

                                v1149(v2707, v2705, AssemblyLinearVelocity)
                            end
                            local u2710
                            local ok13, result13 = pcall(function(...)
                                u2710 = table.pack(t161.old(...))
                            end, ...)
                            if v2707 and CFrame2 then
                                local Magnitude = (v2707.Position - CFrame2.Position).Magnitude

                                if Magnitude > 1.5 then
                                    pcall(function()
                                        v2707.CFrame = CFrame2
                                        v2707.AssemblyLinearVelocity = AssemblyLinearVelocity
                                    end)

                                    local elapsed4 = os.clock()

                                    if elapsed4 - n8 > 1 then
                                        n8 = elapsed4
                                        KozuaLog("engine", "undid relocate", math.floor(Magnitude * 10 + 0.5) / 10)
                                    end
                                end
                            end
                            if v2707 and v2705 then
                                v1149(v2707, v2705, AssemblyLinearVelocity or v2707.AssemblyLinearVelocity)
                            end
                            if v2707 and AssemblyLinearVelocity then
                                pcall(function()
                                    v2707.AssemblyLinearVelocity = AssemblyLinearVelocity
                                end)
                            end
                            if not ok13 then
                                error(result13)
                            end

                            return table.unpack(u2710, 1, u2710.n)
                        end

                        if type(newcclosure) == "function" then
                            v1538 = newcclosure(v1538)
                        end

                        local ok14, result14 = pcall(hookfunction, Function, v1538)

                        if ok14 then
                            t161.old = result14 or Function
                            MoveWraps[Function] = t161.old
                            n11 += 1
                        else
                            KozuaLog("engine", "wrap fail", v1535, (tostring(result14)))
                        end
                    end
                end
            end

            return n11
        end

        local _restorefunction = restorefunction

        for k, v in pairs(MoveWraps) do
            if _restorefunction then
                pcall(_restorefunction, k)
            elseif hookfunction and v then
                pcall(hookfunction, k, v)
            end
        end

        MoveWraps = {}
        KozuaLog("engine", "validator wraps restored")

        return 0
    end
    local function v1151()
        if Config.Flight then
            return math.clamp(tonumber(Config.FlightSpeed) or 880, 150, 1300)
        end

        if StealActive and typeof(StealDest) == "Vector3" then
            return math.clamp(tonumber(Config.StealSpeed) or 300, 50, 1300)
        end

        if Config.BypassSpeed == true then
            return math.clamp(tonumber(Config.BypassCap) or 880, 150, 1300)
        end

        return n9
    end
    function IsFlying()
        if Config.Flight then
            return true
        end

        if FarmSync and FarmSync.driving and FarmSync.driving() then
            return true
        end

        return StealActive == true and (Config.StealTravel == "Flight" and typeof(StealDest) == "Vector3")
    end
    local function v1152()
        local v1544 = v1113()
        local vector3 = Vector3.new(-v1544.Z, 0, v1544.X)
        local zero = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            zero += v1544
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            zero -= v1544
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            zero += vector3
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            zero -= vector3
        end

        if zero.Magnitude < 0.001 then
            return Vector3.zero
        end

        return zero.Unit
    end
    local function v1153()
        local v1547 = v1151()
        local v1548 = v1152()
        local n12 = 0

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            n12 = 40
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            n12 = -40
        end

        if v1548.Magnitude > 0.05 then
            return Vector3.new(v1548.X * v1547, n12, v1548.Z * v1547)
        end

        return Vector3.new(0, n12, 0)
    end
    local function v1154(p178, p179)
        if Config.Flight and (not StealActive or not StealDest) then
            return v1153()
        end

        local v1552 = v1151()

        if StealActive and StealDest then
            local v1553 = StealDest - p179.Position
            local vector3 = Vector3.new(v1553.X, 0, v1553.Z)
            local Magnitude = vector3.Magnitude
            local n13 = 0

            if IsFlying() then
                n13 = 0

                if StealActive then
                    local v1557 = v1147(Vector3.new(p179.Position.X, p179.Position.Y + 4, p179.Position.Z))

                    if type(v1557) == "number" and v1557 <= p179.Position.Y + 1 and p179.Position.Y > v1557 + 14 then
                        n13 = math.clamp(v1557 + 3 - p179.Position.Y, -28, 0)
                    end
                elseif p179.Position.Y > StealDest.Y + 0.6 then
                    n13 = math.clamp(StealDest.Y - p179.Position.Y, -36, 0)
                end
            end

            if Magnitude < 1.4 then
                if IsFlying() then
                    return Vector3.new(0, n13, 0)
                end

                return Vector3.zero
            end

            local v1558 = Magnitude < 8 and math.clamp(v1552 * (Magnitude / 8), 18, v1552) or v1552

            return Vector3.new(vector3.Unit.X * v1558, n13, vector3.Unit.Z * v1558)
        end

        if StealActive and IsFlying() then
            return Vector3.zero
        end

        if Config.BypassSpeed == true then
            local MoveDirection = p178.MoveDirection

            if MoveDirection.Magnitude > 0.05 then
                return Vector3.new(MoveDirection.X * v1552, 0, MoveDirection.Z * v1552)
            end
        end

        return Vector3.zero
    end
    local n14 = 0
    local n15 = 7.2
    local u1157 = false
    local function v1158(p180)
        if not Config.AntiTrap then
            u1157 = false

            return false
        end

        local Character = LocalPlayer.Character
        local v1562, v1563

        if not Character then
            v1562 = nil
            v1563 = nil
            Character = nil
        else
            v1562 = Character:FindFirstChildOfClass("Humanoid")
            v1563 = Character:FindFirstChild("HumanoidRootPart")

            if not v1562 or not v1563 or v1562.Health <= 0 then
                v1562 = nil
                v1563 = nil
                Character = nil
            end
        end

        local v1564 = v1562
        local v1565 = v1563
        local v1566 = Character

        if not v1564 then
            return false
        end

        if type(v1564.JumpHeight) == "number" and v1564.JumpHeight > 0.5 then
            n15 = v1564.JumpHeight
        end

        local v1567 = IsFlying()
        local v1568 = v1566:GetAttribute("IsTrapped") == true

        if not v1568 and (not v1565.Anchored and v1564.JumpHeight ~= 0) then
            u1157 = false

            return false
        end

        pcall(function()
            if v1568 then
                v1566:SetAttribute("IsTrapped", nil)
            end

            v1565.Anchored = false

            if not v1567 then
                v1564.PlatformStand = false
            end

            v1564.Sit = false

            if StealActive and Config.StealTravel == "Flight" and not Config.Flight then
                v1564.AutoRotate = false
            else
                v1564.AutoRotate = true
            end

            if v1564.JumpHeight < 0.5 then
                v1564.JumpHeight = n15
            end

            local State = v1564:GetState()

            if State == Enum.HumanoidStateType.Physics or State == Enum.HumanoidStateType.PlatformStanding or State == Enum.HumanoidStateType.Seated then
                v1564:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
        pcall(function()
            local TrapBillboard = v1566:FindFirstChild("TrapBillboard", true)

            if TrapBillboard then
                TrapBillboard:Destroy()
            end
        end)

        if not u1157 then
            u1157 = true
            n14 += 1
            KozuaLog("steal", "untrap", p180 or "freeze", n14)
        end

        return true
    end
    local t162 = {
		saved = {},
		char = nil,
		at = 0
	}
    local function TrapRefresh()
        local v1569 = Config.AntiTrap == true or Config.AntiMob == true

        if not v1569 and not next(t162.saved) then
            return
        end

        local Character = LocalPlayer.Character

        if Character ~= t162.char then
            t162.saved = {}
            t162.char = Character
            t162.at = 0

            if not v1569 then
                return
            end
        end

        if not Character then
            return
        end

        if v1569 then
            local elapsed5 = os.clock()

            if elapsed5 - (t162.at or 0) < 0.25 then
                return
            end

            t162.at = elapsed5
        end

        for _, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if v1569 then
                    if t162.saved[descendant] == nil then
                        t162.saved[descendant] = descendant.CanTouch
                    end

                    if descendant.CanTouch ~= false then
                        descendant.CanTouch = false
                    end
                else
                    local v1574 = t162.saved[descendant]

                    if v1574 ~= nil then
                        descendant.CanTouch = v1574
                        t162.saved[descendant] = nil
                    end
                end
            end
        end

        if not v1569 then
            t162.saved = {}
        end
    end
    local t163 = {
		saved = {},
		on = false
	}
    local function v1162()
        if t163.on or next(t163.saved) then
            for k, v in pairs(t163.saved) do
                if k.Parent then
                    pcall(function()
                        k.CanCollide = v.c == nil or (v.c or true)
                        k.CanTouch = v.t
                    end)
                end

                t163.saved[k] = nil
            end

            t163.on = false
        end

        local Character = LocalPlayer.Character

        if not Character then
            return
        end

        for _, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" and not descendant:FindFirstAncestorWhichIsA("Accessory") and descendant.CanCollide == false then
                descendant.CanCollide = true
            end
        end
    end
    local function v1163(p181, p182, p183)
        if not p181 or (not p182 or not (p182.Magnitude > 0.05)) then
            return false
        end

        local v1583 = p183 or 12
        local raycastParams = RaycastParams.new()

        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local t164 = { LocalPlayer.Character }

        if workspace.CurrentCamera then
            t164[#t164 + 1] = workspace.CurrentCamera
        end

        raycastParams.FilterDescendantsInstances = t164

        local v1586 = p181.Position + Vector3.new(0, 2.2, 0)
        local raycastResult = workspace:Raycast(v1586, p182.Unit * v1583, raycastParams)

        if not raycastResult or not raycastResult.Instance or not raycastResult.Instance.CanCollide then
            return false
        end

        local Instance2 = raycastResult.Instance
        local FullName = Instance2:GetFullName()
        local v1590 = string.lower(Instance2.Name)
        local v1591 = Instance2.Parent and string.lower(Instance2.Parent.Name) or ""
        local Instance2Size = Instance2.Size
        local Normal = raycastResult.Normal
        local v1594 = FullName:find("LobbyBoundaries", 1, true) or (FullName:find("MapBound", 1, true) or (v1590:find("boundar", 1, true) or (v1590:find("mapedge", 1, true) or Instance2Size.Y >= 24 and (math.min(Instance2Size.X, Instance2Size.Z) <= 14 and math.max(Instance2Size.X, Instance2Size.Z) >= 40))))

        if v1590:find("treadmill", 1, true) or (v1590:find("belt", 1, true) or (FullName:find("Treadmill", 1, true) or v1591:find("treadmill", 1, true))) then
            return true, Vector3.new(Normal.X, 0, Normal.Z), "belt"
        end

        if not v1594 then
            return false
        end

        return true, Vector3.new(Normal.X, 0, Normal.Z)
    end
    local t165 = {
		saved = {},
		at = 0,
		ragOff = false,
		patched = {},
		muted = {},
		groups = false,
		strikeWrapped = false,
		components = {},
		runtimes = {},
		hitArmed = false
	}
    local function v1165()
        for k, v in pairs(t165.saved) do
            if k.Parent then
                pcall(function()
                    k.CanCollide = v.collide
                    k.CanTouch = v.touch

                    if v.group then
                        k.CollisionGroup = v.group
                    end
                end)
            end

            t165.saved[k] = nil
        end
    end
    local function v1166(p184)
        for _, descendant in ipairs(p184:GetDescendants()) do
            local ok15, result15 = pcall(function()
                return descendant:IsA("BasePart")
            end)

            if ok15 and result15 then
                if t165.saved[descendant] == nil then
                    t165.saved[descendant] = {
						collide = descendant.CanCollide,
						touch = descendant.CanTouch,
						group = descendant.CollisionGroup
					}
                end

                pcall(function()
                    descendant.CanTouch = false
                    descendant.CanCollide = false
                end)
                pcall(function()
                    descendant.CollisionGroup = "GuardsNoCollide"
                end)
            end
        end
    end
    local function v1167(p185)
        local PhysicsService = game:GetService("PhysicsService")

        pcall(function()
            PhysicsService:RegisterCollisionGroup("Guards")
            PhysicsService:RegisterCollisionGroup("Players")
            PhysicsService:RegisterCollisionGroup("GuardsNoCollide")
        end)
        pcall(function()
            PhysicsService:CollisionGroupSetCollidable("Guards", "Players", not p185)
            PhysicsService:CollisionGroupSetCollidable("Players", "Guards", not p185)
            PhysicsService:CollisionGroupSetCollidable("GuardsNoCollide", "Players", false)
            PhysicsService:CollisionGroupSetCollidable("Players", "GuardsNoCollide", false)
            PhysicsService:CollisionGroupSetCollidable("GuardsNoCollide", "Default", false)
            PhysicsService:CollisionGroupSetCollidable("GuardsNoCollide", "Guards", false)
        end)
        t165.groups = p185 == true
    end
    local function RequireShared(p186)
        local Shared = ReplicatedStorage:FindFirstChild("Shared")

        for i = 1, #p186 do
            if not Shared then
                return
            end

            Shared = Shared:FindFirstChild(p186[i])
        end

        if Shared and Shared:IsA("ModuleScript") then
            local ok16, result16 = pcall(require, Shared)

            if ok16 then
                return result16
            end
        end
    end
    local function v1169(p187, p188, p189)
        if type(p187) ~= "table" or type(p187[p188]) ~= "function" then
            return false
        end
        local v1617 = tostring(p187) .. "." .. tostring(p188)
        if t165.patched[v1617] then
            return true
        end
        local v1618 = p189(p187[p188])
        local g1619
        local ok17
        local result17
        repeat
            if g1619 or type(newcclosure) == "function" then
                if not g1619 then
                    ok17, result17 = pcall(newcclosure, v1618)
                end

                if g1619 or ok17 and type(result17) == "function" then
                    g1619 = false
                    p187[p188] = result17
                    t165.patched[v1617] = true

                    return true
                end
            end

            result17 = v1618
            g1619 = true
        until not g1619
    end
    local function UnwrapRemote(p190)
        if typeof(p190) == "Instance" then
            return p190
        end

        if type(p190) ~= "table" then
            return nil
        end

        for _, v in ipairs({
			"Remote",
			"remote",
			"Instance",
			"_remote",
			"_instance",
			"Event"
		}) do
            local v1625 = p190[v]

            if typeof(v1625) == "Instance" then
                return v1625
            end
        end
    end
    local function v1171(p191)
        local v1627 = UnwrapRemote(p191) or typeof(p191) == "Instance" and p191

        if not v1627 or t165.muted[v1627] then
            return
        end

        local OnClientEvent = v1627.OnClientEvent

        if not OnClientEvent or not getconnections then
            return
        end

        local ok18, result18 = pcall(getconnections, OnClientEvent)

        if not ok18 or type(result18) ~= "table" then
            return
        end

        local t166 = {}

        for _, v in ipairs(result18) do
            pcall(function()
                if v.Disable then
                    v:Disable()
                end
            end)
            t166[#t166 + 1] = v
        end

        t165.muted[v1627] = t166
    end
    local function v1172(p192)
        if not p192 then
            for k, v in pairs(t165.components) do
                pcall(function()
                    if v.handler then
                        k._attackHandler = v.handler
                    end

                    k._enabled = v.enabled ~= false
                end)
                t165.components[k] = nil
            end

            for k in pairs(t165.runtimes) do
                pcall(function()
                    k:SetEnabled(true)
                end)
                t165.runtimes[k] = nil
            end

            return
        end

        t165.noopAttack = t165.noopAttack or function()
        end

        for k in pairs(t165.components) do
            k._attackHandler = t165.noopAttack
            k._enabled = false
        end
    end
    local function v1173()
        for k, v in pairs(t165.muted) do
            for _, v14 in ipairs(v) do
                pcall(function()
                    if v14.Enable then
                        v14:Enable()
                    end
                end)
            end

            t165.muted[k] = nil
        end
    end
    local function v1174()
        t165.noopAttack = t165.noopAttack or function()
        end

        for k in pairs(t165.components) do
            k._attackHandler = t165.noopAttack
            k._enabled = false
        end

        local v1644 = RequireShared({
			"Modules",
			"GuardAreas",
			"GuardDistance"
		})
        local v1645 = v1169(v1644, "XZ", function(p193)
            return function(p194, p195)
                if Config.AntiMob then
                    return 1000000000
                end

                return p193(p194, p195)
            end
        end)
        local v1646 = RequireShared({
			"Modules",
			"GuardAreas",
			"GuardComponent"
		})
        local v1647 = v1169(v1646, "_attemptAttack", function(p196)
            return function(...)
                if Config.AntiMob then
                    return
                end

                return p196(...)
            end
        end)

        v1169(v1646, "Step", function(p197)
            return function(p198, ...)
                if Config.AntiMob then
                    return nil
                end

                return p197(p198, ...)
            end
        end)

        local v1648 = RequireShared({
			"Modules",
			"Ragdoll"
		})

        v1169(v1648, "IsRagdolled", function(p199)
            return function(p200, ...)
                if Config.AntiMob and p200 == LocalPlayer.Character then
                    return false
                end

                return p199(p200, ...)
            end
        end)

        for _, v in ipairs({
			"TimedRagdoll",
			"TimedRagdollAsync",
			"ApplyClientRagdoll",
			"Ragdoll"
		}) do
            v1169(v1648, v, function(p201)
                return function(p202, ...)
                    if Config.AntiMob then
                        local Character = LocalPlayer.Character

                        if p202 == nil or p202 == Character then
                            return
                        end
                    end

                    return p201(p202, ...)
                end
            end)
        end

        local v1651 = RequireShared({
			"Modules",
			"RagdollJoints"
		})

        v1169(v1651, "Bind", function(p203)
            return function(...)
                if Config.AntiMob then
                    return
                end

                return p203(...)
            end
        end)
        pcall(function()
            local v2723 = RequireShared({ "Remotes" })
            local v2724 = v2723 and v2723.GuardPatrol

            if type(v2724) ~= "table" then
                return
            end

            for k, v in pairs(v2724) do
                local str2 = tostring(k)
                local v2728 = UnwrapRemote(v) or typeof(v) == "Instance" and v

                if str2:find("Strike", 1, true) or str2:find("Handoff", 1, true) then
                    local v2729 = "gpfs." .. str2

                    if not t165.patched[v2729] then
                        if v2728 and typeof(v2728) == "Instance" then
                            v2724[k] = setmetatable({
								FireServer = function(_, ...)
                                if Config.AntiMob then
                                    return
                                end

                                return v2728:FireServer(...)
                            end
							}, {
								__index = v2728
							})
                            t165.patched[v2729] = true
                        elseif type(v) == "table" and type(v.FireServer) == "function" then
                            v1169(v, "FireServer", function(p205)
                                return function(...)
                                    if Config.AntiMob then
                                        return
                                    end

                                    return p205(...)
                                end
                            end)
                        end
                    end
                end

                if str2:find("Strike", 1, true) or str2:find("Handoff", 1, true) or str2:find("SpeedToll", 1, true) or str2:find("SpeedHit", 1, true) or str2:find("Ragdoll", 1, true) or str2:find("Limp", 1, true) or str2:find("Slap", 1, true) or str2:find("Jolt", 1, true) then
                    v1171(v2728 or v)
                end
            end
        end)
        pcall(function()
            local v2730 = RequireShared({ "Remotes" })

            if type(v2730) ~= "table" then
                return
            end

            local Limpness = v2730.Limpness

            v1171(Limpness and Limpness.WriteLimpness)

            local SharedFx = v2730.SharedFx

            v1171(SharedFx and SharedFx.JoltOnce)
        end)
        pcall(function()
            local t167 = {}
            local Network = ReplicatedStorage:FindFirstChild("Network")

            if Network then
                t167[#t167 + 1] = Network
            end

            local Packages = ReplicatedStorage:FindFirstChild("Packages")
            local v2736 = Packages and Packages:FindFirstChild("Networking")

            if v2736 then
                t167[#t167 + 1] = v2736
            end

            for _, v in ipairs(t167) do
                for _, descendant in ipairs(v:GetDescendants()) do
                    if descendant:IsA("RemoteEvent") then
                        local descendantName = descendant.Name

                        if descendantName:find("Strike", 1, true) or descendantName:find("SpeedToll", 1, true) or descendantName:find("SpeedHit", 1, true) or descendantName:find("Handoff", 1, true) or descendantName:find("Ragdoll", 1, true) or descendantName:find("Limp", 1, true) or descendantName:find("Slap", 1, true) or descendantName:find("Jolt", 1, true) then
                            v1171(descendant)
                        end
                    end
                end
            end
        end)
        pcall(function()
            if not EggState or t165.patched["EggState.DropFieldEgg"] then
                return
            end

            v1169(EggState, "DropFieldEgg", function(p206)
                return function(p207, ...)
                    if Config.AntiMob and (p207 == "GuardHit" or p207 == "PlayerSlap") then
                        return
                    end

                    if Config.StealState and StealState and StealState.running then
                        return
                    end

                    return p206(p207, ...)
                end
            end)
        end)
        pcall(function()
            local v2742 = RequireShared({ "Remotes" })
            local v2743 = v2742 and v2742.EggWorld
            local v2744 = v2743 and v2743.AskFieldEggDrop
            local v2745 = UnwrapRemote(v2744) or typeof(v2744) == "Instance" and v2744

            if v2745 and (typeof(v2745) == "Instance" and not t165.patched.AskFieldEggDrop) then
                v2743.AskFieldEggDrop = setmetatable({
					InvokeServer = function(_, p209, ...)
                    local v4604 = type(p209) == "table" and p209.Reason

                    if Config.AntiMob and (v4604 == "GuardHit" or v4604 == "PlayerSlap") then
                        return
                    end

                    if Config.StealState and StealState and StealState.running then
                        return
                    end

                    return v2745:InvokeServer(p209, ...)
                end
				}, {
					__index = v2745
				})
                t165.patched.AskFieldEggDrop = true

                return
            end

            if type(v2744) == "table" then
                v1169(v2744, "InvokeServer", function(p210)
                    return function(p211, p212, ...)
                        local v4885 = type(p212) == "table" and p212.Reason

                        if Config.AntiMob and (v4885 == "GuardHit" or v4885 == "PlayerSlap") then
                            return
                        end

                        if Config.StealState and StealState and StealState.running then
                            return
                        end

                        return p210(p211, p212, ...)
                    end
                end)
            end
        end)

        if not t165.attrConn then
            local v1652 = t165
            local connection = LocalPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
                if Config.AntiMob then
                    EnsureFlight()
                end
            end)

            if connection then
                ConnList[connection] = true
            end

            v1652.attrConn = connection
        end

        local v1654 = (not v1645 and "no-xz" or "xz") .. " " .. (not v1647 and "no-atk" or "atk")

        if v1654 ~= t165.logged then
            t165.logged = v1654
            KozuaLog("engine", "anti ragdoll patch", v1654)
        end
    end
    function EnsureFlight()
        local Character = LocalPlayer.Character
        local v1656, v1657

        if not Character then
            v1656 = nil
            v1657 = nil
        else
            v1656 = Character:FindFirstChildOfClass("Humanoid")
            v1657 = Character:FindFirstChild("HumanoidRootPart")

            if not v1656 or not v1657 or v1656.Health <= 0 then
                v1656 = nil
                v1657 = nil
            end
        end

        local v1658 = v1656
        local v1659 = v1657

        if not v1658 then
            return
        end

        local State = v1658:GetState()
        local RagdollEndTime = LocalPlayer:GetAttribute("RagdollEndTime")
        local Parent = v1658.Parent

        if type(RagdollEndTime) ~= "number" and Parent then
            RagdollEndTime = Parent:GetAttribute("RagdollEndTime")
        end

        local v1663 = type(RagdollEndTime) == "number" and RagdollEndTime > workspace:GetServerTimeNow() - 0.05

        if not v1663 and (State ~= Enum.HumanoidStateType.Ragdoll and (State ~= Enum.HumanoidStateType.FallingDown and State ~= Enum.HumanoidStateType.Physics)) then
            return
        end

        t165.ragOff = true

        local v1664 = IsFlying and IsFlying()

        pcall(function()
            v1658:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            v1658:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            v1658:SetStateEnabled(Enum.HumanoidStateType.Physics, false)

            if v1664 then
                v1658.PlatformStand = true

                return
            end

            v1658:ChangeState(Enum.HumanoidStateType.GettingUp)
            v1658.PlatformStand = false
            v1658.Sit = false
        end)

        if Parent then
            if not t165.joints then
                t165.joints = RequireShared({
					"Modules",
					"RagdollJoints"
				})
            end

            local joints = t165.joints

            if joints and type(joints.Release) == "function" then
                pcall(joints.Release, Parent)
            end

            pcall(function()
                Parent:SetAttribute("RagdollEndTime", 0)
            end)
        end

        if v1663 then
            pcall(function()
                LocalPlayer:SetAttribute("RagdollEndTime", 0)
            end)
        end

        if v1659 and not v1664 then
            pcall(function()
                local MoveDirection = v1658.MoveDirection
                local v2747 = v1658.WalkSpeed or 0

                v1659.AssemblyLinearVelocity = Vector3.new(MoveDirection.X * v2747, v1659.AssemblyLinearVelocity.Y, MoveDirection.Z * v2747)
                v1659.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
    local function RagdollRefresh()
        if Config.AntiMob ~= true then
            if not t165.hitArmed and not t165.ragOff and not t165.groups and not next(t165.saved) then
                return
            end

            v1173()
            v1172(false)

            if t165.groups then
                v1167(false)
            end

            if next(t165.saved) then
                v1165()
            end

            if t165.ragOff then
                local v1666 = select(1, GetCharParts())

                if v1666 then
                    pcall(function()
                        v1666:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                        v1666:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                        v1666:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                        v1666:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                    end)
                end

                t165.ragOff = false
            end

            t165.hitArmed = false

            return
        end

        if not t165.hitArmed then
            v1174()
            t165.hitArmed = true
        end

        if not t165.groups then
            v1167(true)
        end

        local v1667 = select(1, GetCharParts())

        if v1667 then
            if v1667.Health < v1667.MaxHealth then
                pcall(function()
                    if v1667.Health <= 0 then
                        v1667:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    end

                    v1667.Health = v1667.MaxHealth
                end)
            end

            EnsureFlight()

            if v1667 ~= t165.hum then
                t165.hum = v1667

                if t165.stConn then
                    pcall(function()
                        t165.stConn:Disconnect()
                    end)
                end

                if t165.hpConn then
                    pcall(function()
                        t165.hpConn:Disconnect()
                    end)
                end

                local v1668 = t165
                local connection = v1667.StateChanged:Connect(function(_, newState)
                    if Config.AntiMob ~= true then
                        return
                    end

                    if newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Dead then
                        EnsureFlight()
                    end
                end)

                if connection then
                    ConnList[connection] = true
                end

                v1668.stConn = connection

                local v1670 = t165
                local connection5 = v1667.HealthChanged:Connect(function(p214)
                    if Config.AntiMob == true and p214 < v1667.MaxHealth then
                        pcall(function()
                            if p214 <= 0 then
                                v1667:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                            end

                            v1667.Health = v1667.MaxHealth
                        end)
                    end
                end)

                if connection5 then
                    ConnList[connection5] = true
                end

                v1670.hpConn = connection5
            end
        end

        local elapsed6 = os.clock()

        if elapsed6 - (t165.muteAt or 0) < 0.35 then
            return
        end

        t165.muteAt = elapsed6
        pcall(function()
            local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
            local v2752 = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
            local v2753 = v2752 and v2752:FindFirstChild("GuardAreas") or workspace:FindFirstChild("GuardAreas")

            if not v2753 then
                return
            end

            for _, child in ipairs(v2753:GetChildren()) do
                local Guard = child:FindFirstChild("Guard")

                if Guard and Guard:IsA("Model") then
                    v1166(Guard)
                end

                for _, child2 in ipairs(child:GetChildren()) do
                    if child2:IsA("Model") and child2 ~= Guard and (string.lower(child2.Name):find("guard", 1, true) or child2:FindFirstChildOfClass("Humanoid")) then
                        v1166(child2)
                    end
                end
            end
        end)
    end
    local connection = LocalPlayer.CharacterRemoving:Connect(function()
        u1145 = false
        StealDest = nil
        v1144()
    end)
    if connection then
        ConnList[connection] = true
    end
    local connection7 = LocalPlayer.CharacterAdded:Connect(function(character)
        t162.saved = {}
        t162.char = nil
        u1145 = false
        StealDest = nil

        if StealState then
            StealState.target = nil
            StealState.lastPos = nil
            StealState.stillFor = 0
            StealState.pendingCarry = nil
        end

        task.spawn(function()
            if not IsAlive then
                return
            end

            local Humanoid = character:WaitForChild("Humanoid", 15)

            if not IsAlive then
                return
            end

            local v2760 = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 15)

            if not Humanoid or not v2760 then
                return
            end

            task.wait(0.55)

            if not IsAlive or character.Parent == nil or Humanoid.Health <= 0 then
                return
            end

            v1144()
            TrapRefresh()
            RagdollRefresh()

            local connection6 = Humanoid.Died:Connect(function()
                u1145 = false
                StealDest = nil
                v1144()
            end)

            if connection6 then
                ConnList[connection6] = true
            end

            if StealState and StealState.running then
                StealState.state = "Scan"
                StealState.since = os.clock()
                StealActive = false
                StealDest = nil
            end

            if type(Humanoid.WalkSpeed) == "number" and Humanoid.WalkSpeed > 0 and Humanoid.WalkSpeed <= 36 then
                n9 = Humanoid.WalkSpeed
            end

            if IsFlying() and v2760 then
                v1148(v2760, 0)
            end
        end)
    end)
    if connection7 then
        ConnList[connection7] = true
    end
    local Character = LocalPlayer.Character
    local v1179 = Character and Character:FindFirstChildOfClass("Humanoid")
    if v1179 then
        local connection8 = v1179.Died:Connect(function()
            u1145 = false
            StealDest = nil
            v1144()
        end)

        if connection8 then
            ConnList[connection8] = true
        end
    end
    local function v1181(p215, p216, p217)
        v1148(p216, p217 and p217.Y)

        local v1678 = StealActive and (Config.StealTravel == "Flight" and not Config.Flight)

        pcall(function()
            p215.Jump = false
            p215.AutoJumpEnabled = false
            p215:Move(Vector3.zero, false)
            p215.PlatformStand = true

            if v1678 then
                p215.AutoRotate = false
            end
        end)

        if v1678 and p216 then
            pcall(function()
                p216.AssemblyAngularVelocity = Vector3.zero

                local v2762 = StealState and StealState.flyLook

                if typeof(v2762) ~= "Vector3" or v2762.Magnitude < 0.05 then
                    local vector3 = Vector3.new(p216.CFrame.LookVector.X, 0, p216.CFrame.LookVector.Z)

                    v2762 = if not (vector3.Magnitude < 0.05) then vector3.Unit else Vector3.new(0, 0, -1)

                    if StealState then
                        StealState.flyLook = v2762
                    end
                end

                local p216Position = p216.Position
                local p216PositionY = p216Position.Y
                local v2766 = p216Position

                if p217 and n7 then
                    v2766 = p216Position + Vector3.new(p217.X, 0, p217.Z) * math.clamp(n7, 0, 0.05)
                end

                if StealActive then
                    p217 = Vector3.new(p217.X, math.min(p217.Y, 0), p217.Z)
                else
                    local v2767 = v1147(v2766)
                    local v2768 = type(v2767) == "number" and v2767 + 3.15 or nil

                    if typeof(StealDest) == "Vector3" then
                        local Y = StealDest.Y

                        if v2768 then
                            Y = math.max(Y, v2768)
                        end

                        if Y < p216PositionY then
                            p216PositionY = Y
                            p217 = Vector3.new(p217.X, math.min(p217.Y, 0), p217.Z)
                        end
                    end

                    if v2768 and p216PositionY < v2768 then
                        p216PositionY = v2768
                        p217 = Vector3.new(p217.X, math.max(p217.Y, 0), p217.Z)
                    end
                end

                p216.CFrame = CFrame.new(Vector3.new(p216Position.X, p216PositionY, p216Position.Z), Vector3.new(p216Position.X, p216PositionY, p216Position.Z) + v2762)
            end)
        elseif p216 then
            if StealState then
                StealState.flyLook = nil
            end

            local v1679 = v1147(p216.Position)

            if type(v1679) == "number" and p216.Position.Y < v1679 + 3.15 then
                local v1680 = v1679 + 3.15 - p216.Position.Y

                pcall(function()
                    p216.CFrame = p216.CFrame + Vector3.new(0, v1680, 0)
                end)

                if p217 then
                    p217 = Vector3.new(p217.X, math.max(p217.Y, 0), p217.Z)
                end
            end
        end

        if p216 and p217 then
            p216.AssemblyLinearVelocity = p217
        end
    end
    local function v1182(p218)
        if not IsAlive then
            return
        end
        n7 = p218 or n7
        local v1682 = IsFlying()
        local Character2 = LocalPlayer.Character
        local v1684, v1685
        if not Character2 then
            v1684 = nil
            v1685 = nil
        else
            v1684 = Character2:FindFirstChildOfClass("Humanoid")
            v1685 = Character2:FindFirstChild("HumanoidRootPart")

            if not v1684 or not v1685 or v1684.Health <= 0 then
                v1684 = nil
                v1685 = nil
            end
        end
        local v1686 = v1684
        if u1145 and not v1682 then
            local v1687 = FarmSync and (FarmSync.leaving and FarmSync.leaving())

            v1146(v1686, v1685, not v1687)
            u1145 = false
            pcall(v1158, "engine")
            pcall(TrapRefresh)
            pcall(RagdollRefresh)

            return
        end
        u1145 = v1682
        if v1682 then
            if v1685 then
                pcall(function()
                    if v1686 then
                        v1686.WalkSpeed = math.clamp(v1151(), 16, 1300)
                    end
                end)

                local v1688 = v1154(v1686, v1685)
                local v1689 = v1685.Position + v1688 * math.clamp(n7, 0, 0.05)

                v1148(v1685, v1688.Y)

                local v1690 = v1686 and v1686.WalkSpeed or v1151()
                local v1691 = math.max(10, v1690 or 16)
                local v1692 = if not (v1688.Magnitude > v1691 + 1) then v1688 else v1688.Magnitude > 0.0001 and v1688.Unit * v1691 or Vector3.zero

                for i = 1, #t154 do
                    v1141(t154[i], v1685, v1686, v1689, v1692)
                end

                v1181(v1686, v1685, v1688)
            else
                v1144()
            end

            pcall(v1158, "engine")
            pcall(TrapRefresh)
            pcall(RagdollRefresh)
            v1162(false)

            return
        end
        v1144()
        v1158("engine")
        TrapRefresh()
        RagdollRefresh()
        if v1686 and type(v1686.WalkSpeed) == "number" and v1686.WalkSpeed > 0 and v1686.WalkSpeed <= 36 then
            n9 = v1686.WalkSpeed
        end
        local v1694 = StealActive and typeof(StealDest) == "Vector3"
        if not v1694 and Config.BypassSpeed ~= true and Config.Flight ~= true then
            pcall(function()
                if v1686 then
                    v1686.WalkSpeed = n9
                end
            end)

            return
        end
        if not v1685 then
            return
        end
        local v1695 = v1154(v1686, v1685)
        local vector3 = Vector3.new(v1695.X, 0, v1695.Z)
        local v1697 = v1694 and not IsFlying()
        local u1698
        local v1699
        local v1700
        if v1697 and vector3.Magnitude > 1 then
            local v1701

            v1701, v1699, v1700 = v1163(v1685, vector3, 16)
            u1698 = v1701
        end
        if u1698 and v1700 == "belt" then
            if StealState and StealState.beltSunk then
                u1698 = false
            else
                local v1702 = typeof(v1699) == "Vector3" and Vector3.new(v1699.X, 0, v1699.Z) or Vector3.zero
                local vector3_2 = Vector3.new(StealDest.X - v1685.Position.X, 0, StealDest.Z - v1685.Position.Z)

                if v1702.Magnitude > 0.05 then
                    local Unit = v1702.Unit

                    if vector3_2.Magnitude > 2 and vector3_2:Dot(Unit) < 0 then
                        vector3_2 -= Unit * vector3_2:Dot(Unit)
                    end

                    if vector3_2.Magnitude < 4 then
                        vector3_2 = Unit * 20
                    end

                    vector3 = vector3_2.Unit * math.max(40, v1151() * 0.5)
                    v1695 = Vector3.new(vector3.X, v1695.Y, vector3.Z)
                    pcall(function()
                        v1686.Jump = true
                    end)
                end

                u1698 = false
            end
        end
        if u1698 and typeof(v1699) == "Vector3" and v1699.Magnitude > 0.05 then
            local vector3_3 = Vector3.new(v1699.X, 0, v1699.Z)

            if vector3_3.Magnitude > 0.05 then
                local Unit = vector3_3.Unit
                local v1707 = vector3:Dot(Unit)

                if v1707 < 0 then
                    vector3 -= Unit * v1707
                end

                if vector3.Magnitude < 8 then
                    local vector3_4 = Vector3.new(StealDest.X - v1685.Position.X, 0, StealDest.Z - v1685.Position.Z)
                    local vector3_5 = Vector3.new(-Unit.Z, 0, Unit.X)

                    if vector3_5.Magnitude > 0.05 then
                        if vector3_5:Dot(vector3_4) < 0 then
                            vector3_5 = -vector3_5
                        end

                        vector3 = vector3_5.Unit * math.max(40, v1151() * 0.35)
                    end
                end

                v1695 = Vector3.new(vector3.X, v1695.Y, vector3.Z)
            end
        end
        pcall(function()
            v1686.PlatformStand = false
            v1686.Sit = false
            v1686.AutoRotate = true
            v1686.AutoJumpEnabled = true

            local v2770 = FarmSync and (FarmSync.leaving and FarmSync.leaving())

            if v1697 then
                local v2771 = v1151()

                if u1698 then
                    v1686.WalkSpeed = math.clamp(v2771, 16, 90)
                else
                    v1686.WalkSpeed = math.clamp(v2771, 16, 1300)
                end
            elseif Config.BypassSpeed == true then
                v1686.WalkSpeed = math.clamp(tonumber(Config.BypassCap) or 880, 16, 1300)
            else
                v1686.WalkSpeed = n9
            end

            if v2770 or v1697 and StealState and (StealState.stillFor or 0) > 0.4 then
                v1686.Jump = true
            elseif not v1697 then
                v1686.Jump = false
            end

            local State = v1686:GetState()

            if State == Enum.HumanoidStateType.PlatformStanding or State == Enum.HumanoidStateType.Physics or State == Enum.HumanoidStateType.Seated then
                v1686:ChangeState(Enum.HumanoidStateType.Running)
            end

            if vector3.Magnitude > 1 then
                v1686:Move(vector3.Unit, false)

                return
            end

            v1686:Move(Vector3.zero, false)
        end)
        v1162()
        v1685.AssemblyLinearVelocity = Vector3.new(v1695.X, v1685.AssemblyLinearVelocity.Y, v1695.Z)
        local AssemblyLinearVelocity = v1685.AssemblyLinearVelocity
        local WalkSpeed = v1686.WalkSpeed
        local v1712 = math.max(10, WalkSpeed or 16)
        local v1713 = if not (AssemblyLinearVelocity.Magnitude > v1712 + 1) then AssemblyLinearVelocity else AssemblyLinearVelocity.Magnitude > 0.0001 and AssemblyLinearVelocity.Unit * v1712 or Vector3.zero
        for i = 1, #t154 do
            v1141(t154[i], v1685, v1686, v1685.Position, v1713)
        end
    end
    local function EngineRefresh(p219)
        local v1716 = not not p219

        if v1716 == EngineOn then
            if not EngineOn then
                return
            end

            if (Config.Flight or Config.BypassSpeed) and true or (Config.StealState or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                FlightEnable()
                FlightDisable()
                FlightSetWrap(true)

                return
            end

            if next(MoveWraps) then
                FlightSetWrap(false)
            end

            return
        end

        if v1716 then
            FlightEnable()
            FlightDisable()
            KozuaLog("engine", "movementStates=", #t154)

            if (Config.Flight or Config.BypassSpeed) and true or (Config.StealState or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                FlightSetWrap(true)
            end

            if u1118 then
                u1118:Disconnect()
            end

            local connection9 = RunService.Stepped:Connect(function(_, dt)
                if not IsAlive then
                    return
                end

                if StealTick and StealState and StealState.running and Config.StealState then
                    local ok19, result19 = pcall(StealTick, dt)

                    if not ok19 then
                        local elapsed7 = os.clock()

                        if elapsed7 - (StealState.lastErrAt or 0) > 2 then
                            StealState.lastErrAt = elapsed7
                            KozuaLog("steal", "tick ERR", (tostring(result19)))
                        end
                    end
                end

                pcall(v1182, dt)

                if FarmSync and FarmSync.tick then
                    pcall(FarmSync.tick)
                end

                if PanelCtl and PanelCtl.tick then
                    pcall(PanelCtl.tick)
                end
            end)

            if connection9 then
                ConnList[connection9] = true
            end

            u1118 = connection9
            EngineOn = true

            if IsFlying() then
                local Character3 = LocalPlayer.Character
                local v1719

                if not Character3 then
                    v1719 = nil
                else
                    local Humanoid = Character3:FindFirstChildOfClass("Humanoid")
                    local HumanoidRootPart = Character3:FindFirstChild("HumanoidRootPart")

                    v1719 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
                end

                if v1719 then
                    v1148(v1719, 0)
                end
            end

            KozuaLog("engine", "ON speed=", v1151(), "fly=", IsFlying(), "wrap=", (Config.Flight or Config.BypassSpeed) and true or (not not Config.StealState or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))))

            return
        end

        local v1722 = u1145 or u1119 ~= nil

        EngineOn = false
        StealActive = false
        StealDest = nil
        u1145 = false
        FlightSetWrap(false)

        if u1118 then
            u1118:Disconnect()
            u1118 = nil
        end

        local Character4 = LocalPlayer.Character
        local v1724, v1725

        if not Character4 then
            v1724 = nil
            v1725 = nil
        else
            v1724 = Character4:FindFirstChildOfClass("Humanoid")
            v1725 = Character4:FindFirstChild("HumanoidRootPart")

            if not v1724 or not v1725 or v1724.Health <= 0 then
                v1724 = nil
                v1725 = nil
            end
        end

        v1146(v1724, v1725, v1722)
        v1162(false)
        KozuaLog("engine", "OFF")
    end
    local function EngineWantsFlight()
        if Config.StealState or (Config.AntiTrap or Config.AntiMob) then
            return true
        end

        if FarmSync and FarmSync.wanted and FarmSync.wanted() then
            return true
        end

        if FarmSync and FarmSync.driving and FarmSync.driving() then
            return true
        end

        if FarmSync and FarmSync.leaving and FarmSync.leaving() then
            return true
        end

        return Config.BypassSpeed or Config.Flight
    end
    local v1185 = fireproximityprompt or fireproximityprompttrigger
    local u1186
    local u1187
    local function v1188(p221)
        if typeof(p221) ~= "Instance" then
            return
        end

        local ok20, result20 = pcall(function()
            return p221:IsA("ProximityPrompt")
        end)

        if not ok20 or not result20 then
            return
        end

        pcall(function()
            p221.HoldDuration = 0
            p221.RequiresLineOfSight = false
            p221.ClickablePrompt = true
        end)

        if p221.Name == "CarryAreaEgg" then
            u1186 = p221
        end
    end
    local function v1189(p222)
        if not p222 then
            return false
        end

        if p222.Name == "CarryAreaEgg" then
            return true
        end

        local s16 = ""

        pcall(function()
            s16 = string.lower(tostring(p222.Name) .. " " .. tostring(p222.ActionText) .. " " .. tostring(p222.ObjectText))
        end)

        return s16:find("steal", 1, true) ~= nil or s16:find("carry", 1, true) ~= nil
    end
    local function v1190(p223)
        if not p223 then
            return
        end

        v1188(p223)

        if v1185 then
            pcall(v1185, p223, 0)

            return
        end

        pcall(function()
            p223:InputHoldBegin()
            p223:InputHoldEnd()
        end)
    end
    local function v1191()
        if u1187 and (u1187.Parent and v1189(u1187)) then
            return u1187
        end

        if u1186 and u1186.Parent then
            return u1186
        end

        local SmartPromptPart = workspace:FindFirstChild("SmartPromptPart")
        local v1733 = SmartPromptPart and SmartPromptPart:FindFirstChild("CarryAreaEgg")

        if v1733 and v1733:IsA("ProximityPrompt") then
            u1186 = v1733

            return v1733
        end
    end
    local function v1192(p224, _)
        if type(p224) ~= "table" then
            return nil
        end

        local Rarity = p224.Rarity

        if type(Rarity) == "table" then
            local DefaultRarityValue = Rarity.DefaultRarityValue

            if type(DefaultRarityValue) == "string" and DefaultRarityValue ~= "" then
                local v1747 = string.gsub(DefaultRarityValue, ",", "")
                local v1748 = string.gsub(v1747, "1 in ", "1/")
                local v1749 = string.gsub(v1748, " ", "")

                if string.sub(v1749, 1, 2) == "1/" then
                    local num = tonumber(string.sub(v1749, 3))

                    if num and num >= 1000000000000 then
                        return string.format("1/%.2ft", num / 1000000000000)
                    end

                    if num and num >= 1000000000 then
                        return string.format("1/%.2fb", num / 1000000000)
                    end

                    if num and num >= 1000000 then
                        return string.format("1/%.2fm", num / 1000000)
                    end

                    if num and num >= 1000 then
                        return string.format("1/%.0fk", num / 1000)
                    end

                    return v1749
                end
            end
        end

        return nil
    end
    local function v1193(p226, p227)
        if type(p227) ~= "table" and type(p226) == "table" then
            local v1754 = p226.AssetCategory or p226.Category

            p227 = if not not Directory and v1754 then Directory[v1754] else nil
        end
        if type(p226) == "table" then
            local num = tonumber(p226.MoneyPerSecond)

            if num and num > 0 then
                return num
            end

            local ItemData = p226.ItemData

            if type(ItemData) == "table" then
                local num2 = tonumber(ItemData.MoneyPerSecond)

                if num2 and num2 > 0 then
                    return num2
                end

                if type(ItemData.Category) == "string" and tonumber(ItemData.Scale) then
                    local ok21, result21 = pcall(function()
                        return require(ReplicatedStorage.Shared.Util.AssetEarnings).MutationOnlyRatePerSecond(ItemData)
                    end)

                    if ok21 and tonumber(result21) then
                        return (tonumber(result21))
                    end
                end
            end
        end
        local v1760 = if type(p227) == "table" then tonumber(p227.EarningRate) or 0 else 0
        local v1761 = type(p226) == "table" and (p226.AssetCategory or p226.Category) or nil
        local t168 = {}
        if type(p226) == "table" then
            if type(p226.Mutations) == "table" then
                t168 = p226.Mutations
            elseif type(p226.ItemData) == "table" and type(p226.ItemData.Mutations) == "table" then
                t168 = p226.ItemData.Mutations
            end
        end
        local num
        if type(p226) == "table" then
            num = tonumber(p226.Scale)

            if (not num or not (num > 0)) and type(p226.ItemData) == "table" then
                num = tonumber(p226.ItemData.Scale)
            end
        end
        if not num or not (num > 0) then
            local v1764 = type(p226) == "table" and (tonumber(p226.Weight) or (tonumber(p226.Kg) or tonumber(p226.ModelWeight)))
            local v1765 = type(p227) == "table" and tonumber(p227.ModelWeight)

            num = (not v1764 or (not (v1764 > 0) or (not v1765 or not (v1765 > 0)))) and 1 or (v1764 / v1765) ^ 0.33333333333333
        end
        if type(v1761) == "string" then
            local ok22, result22 = pcall(function()
                return require(ReplicatedStorage.Shared.Util.AssetEarnings).MutationOnlyRatePerSecond({
					Category = v1761,
					Mutations = t168,
					Scale = num
				})
            end)

            if ok22 and tonumber(result22) then
                return (tonumber(result22))
            end
        end
        local v1768 = num <= 5 and num ^ 1.85 or (num / 5) ^ 1.2 * 19.637875755794
        local n16 = 1
        pcall(function()
            n16 = require(ReplicatedStorage.Shared.Modules.Mutations).EarningsFor(t168)
        end)
        n16 = tonumber(n16) or 1
        local v1770 = v1760 * v1768 * n16
        if v1770 < 1 and v1760 > 0 then
            v1770 = 1
        end

        return math.floor(v1770 + 0.5)
    end
    local function v1194(p228)
        if type(p228) ~= "string" then
            return 0
        end

        local v1772 = string.lower(p228:gsub(",", ""):gsub("%s+", ""))

        if v1772 == "" or v1772 == "any" or v1772:find("blank") then
            return 0
        end

        local v1773, v1774 = v1772:match("([%d%.]+)([kmb]?)")
        local num = tonumber(v1773)

        if not num then
            return 0
        end

        if v1774 == "k" then
            return num * 1000
        end

        if v1774 == "m" then
            return num * 1000000
        end

        if v1774 == "b" then
            num *= 1000000000
        end

        return num
    end
    local u1195 = (function()
        local elapsed8 = os.clock()
        local elapsed9 = os.clock()
        local t169 = {}
        local t170 = {
			"IndexImage",
			"IndexIcon",
			"Icon",
			"Image",
			"ImageId",
			"IconImage",
			"Thumbnail",
			"AssetImage",
			"PetImage",
			"EggImage",
			"RenderImage",
			"Picture"
		}
        local t171 = {
			common = 9807270,
			uncommon = 3066993,
			rare = 3447003,
			epic = 10181046,
			legendary = 15844367,
			mythic = 15158332,
			cosmic = 5793266,
			secret = 2303786,
			eternal = 16766720,
			divine = 16738740,
			titan = 16777215
		}

        local function v1781(p229)
            local v2785 = tonumber(p229) or 0
            local v2786 = math.abs(v2785)

            if v2786 >= 1000000000000 then
                return string.format("%.2fT", v2785 / 1000000000000)
            end

            if v2786 >= 1000000000 then
                return string.format("%.2fB", v2785 / 1000000000)
            end

            if v2786 >= 1000000 then
                return string.format("%.2fm", v2785 / 1000000)
            end

            if v2786 >= 1000 then
                return string.format("%.1fk", v2785 / 1000)
            end

            return string.format("%.0f", v2785)
        end
        local function v1782(p230)
            local HookRarityFloor = Config.HookRarityFloor

            if not HookRarityFloor or HookRarityFloor == "Any" then
                return true
            end

            local n17 = 0
            local n18 = 0
            local v2795 = string.lower((tostring(p230 or "")))
            local v2796 = string.lower((tostring(HookRarityFloor)))

            for i, v in ipairs(RarityList) do
                local v2799 = string.lower(v)

                if v2799 == v2796 then
                    n17 = i
                end

                if v2799 == v2795 then
                    n18 = i
                end
            end

            return n17 <= n18
        end
        local function v1783()
            local v2802 = math.max(0, math.floor(os.clock() - elapsed9))
            local v2803 = math.floor(v2802 / 3600)
            local v2804 = math.floor(v2802 % 3600 / 60)
            local v2805 = v2802 % 60

            if v2803 > 0 then
                return string.format("%d:%02d:%02d", v2803, v2804, v2805)
            end

            return string.format("%d:%02d", v2804, v2805)
        end
        local function v1784(p231)
            if p231 == nil then
                return
            end

            local v2807 = typeof(p231)

            if v2807 == "number" then
                if p231 > 100 then
                    return "rbxassetid://" .. tostring(math.floor(p231))
                end

                return
            end

            if v2807 == "string" then
                if p231 == "" or p231 == "0" or p231 == "rbxassetid://0" then
                    return
                end

                if string.find(p231, "http", 1, true) or string.find(p231, "rbxasset", 1, true) or string.find(p231, "rbxthumb", 1, true) then
                    return p231
                end

                local num = tonumber(p231)

                if num and num > 100 then
                    return "rbxassetid://" .. tostring(math.floor(num))
                end
            end

            if v2807 == "Instance" then
                if p231:IsA("ImageLabel") or p231:IsA("ImageButton") then
                    return v1784(p231.Image)
                end

                if p231:IsA("Decal") or p231:IsA("Texture") then
                    return v1784(p231.Texture)
                end

                local v2809 = p231:FindFirstChildWhichIsA("ImageLabel", true) or (p231:FindFirstChildWhichIsA("ImageButton", true) or p231:FindFirstChildWhichIsA("Decal", true))

                if v2809 then
                    return v1784(v2809)
                end

                return
            end

            if v2807 == "table" then
                return v1784(p231.Image) or (v1784(p231.ImageId) or (v1784(p231.Icon) or v1784(p231.Id)))
            end
        end
        local function v1785(p232)
            if type(p232) ~= "table" then
                return
            end

            for i = 1, #t170 do
                local v2812 = v1784(p232[t170[i]])

                if v2812 then
                    return v2812
                end
            end

            if type(p232.Egg) == "table" then
                for i = 1, #t170 do
                    local v2814 = v1784(p232.Egg[t170[i]])

                    if v2814 then
                        return v2814
                    end
                end
            end
        end
        local function v1786(p233, p234, p235)
            if PanelCtl and PanelCtl.scanIcons then
                pcall(PanelCtl.scanIcons, true)
            end

            if PanelCtl and PanelCtl.liveIcon then
                local ok23, result23 = pcall(PanelCtl.liveIcon, p233, p234, p235)

                if ok23 and type(result23) == "string" and result23 ~= "" then
                    return result23
                end
            end

            if PanelCtl and PanelCtl.icon then
                local ok24, result24 = pcall(PanelCtl.icon, p233, p234)

                if ok24 and type(result24) == "string" and result24 ~= "" then
                    return result24
                end
            end

            return v1785(p233)
        end
        local function v1787(p236)
            if type(p236) ~= "string" or p236 == "" then
                return
            end

            local v2823 = p236:gsub("^http://", "https://")

            if not string.find(v2823, "^https://") then
                return
            end

            if string.find(v2823, "rbxcdn.com", 1, true) then
                return v2823
            end
        end
        local function v1788(p237)
            local v2828 = v1787(p237)
            local g2829
            repeat
                if g2829 or v2828 then
                    if g2829 or (type(v2828) ~= "string" or string.find(v2828, "PrivateImage", 1, true) == nil) then

                        if not v2828 then
                            return
                        end
                        if v2828:find("/Image/", 1, true) or v2828:find("/AvatarHeadshot/", 1, true) or v2828:find("/Avatar/", 1, true) or v2828:find("/Outfit/", 1, true) then
                            return v2828
                        end

                        return
                    end
                end

                v2828 = nil
                g2829 = true
            until not g2829
        end
        local function v1789(p238)
            if type(p238) ~= "string" or p238 == "" then
                return
            end

            local v2831 = v1787(p238)

            if v2831 then
                return {
					cdn = v2831
				}
            end

            local v2832, v2833 = p238:match("rbxthumb://type=([%w]+)&id=(%d+)")

            if not v2833 then
                v2832, v2833 = p238:match("rbxthumb://[^%s]*type=([%w]+)[^%s]*id=(%d+)")
            end

            if v2833 then
                local v2834 = string.lower((tostring(v2832 or "asset")))

                if v2834 == "avatarheadshot" or v2834 == "avatarbust" or v2834 == "avatar" then
                    return {
						kind = "user",
						id = v2833
					}
                end

                if v2834 == "bundlethumbnail" or v2834 == "bundle" then
                    return {
						kind = "bundle",
						id = v2833
					}
                end

                return {
					kind = "asset",
					id = v2833
				}
            end

            local v2835 = p238:match("rbxassetid://(%d+)") or (p238:match("[?&]assetId=(%d+)") or (p238:match("[?&]assetid=(%d+)") or (p238:match("/asset/%?id=(%d+)") or p238:match("[?&]id=(%d+)"))))

            if v2835 then
                return {
					kind = "asset",
					id = v2835
				}
            end
        end
        local function v1790(p239)
            local v2837 = syn and syn.request or (http_request or (request or (http and http.request or fluxus and fluxus.request)))

            if not v2837 then
                return
            end

            for i = 1, 3 do
                local ok25, result25 = pcall(v2837, {
					Url = p239,
					Method = "GET",
					Headers = {
						Accept = "application/json"
					}
				})

                if (ok25 and (type(result25) == "table" and tonumber(result25.StatusCode or (result25.status_code or result25.Status)))) ~= 429 then
                    if not ok25 or type(result25) ~= "table" then
                        return
                    end
                    local v2841 = result25.Body or result25.body
                    if type(v2841) == "table" then
                        return v2841
                    end
                    if type(v2841) ~= "string" or v2841 == "" then
                        return
                    end
                    local data
                    pcall(function()
                        data = HttpService:JSONDecode(v2841)
                    end)

                    return data, v2841
                end

                task.wait(i * 0.45)
            end
        end
        local function v1791(p240)
            if type(p240) ~= "string" then
                return
            end
            local g2869
            local g2871
            local g2873
            local g2875
            local n20
            local n19
            for match, v2864 in p240:gsub("\\/", "/"):gmatch("\"targetId\":(%d+).-?\"imageUrl\":\"(https://[^\"]+)\"") do
                local str3 = tostring(match or "")
                local v2866 = v1787(v2864)

                if str3 == "" or not v2866 then
                    continue
                end

                local v2867 = t169[str3]

                if v2867 then
                    if v1788(v2866) then
                        n19 = 3
                        g2869 = true
                    end

                    if not g2869 then
                        local v2870 = v1787(v2866)

                        repeat
                            if not g2871 and v2870 then
                                if type(v2870) == "string" and string.find(v2870, "PrivateImage", 1, true) ~= nil then
                                    g2871 = true
                                end
                            else
                                g2871 = false
                                v2870 = nil
                            end
                        until not g2871

                        n19 = if not v2870 then not (type(v2866) == "string" and string.find(v2866, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                    end

                    g2869 = false

                    if v1788(v2867) then
                        n20 = 3
                        g2873 = true
                    end

                    if not g2873 then
                        local v2874 = v1787(v2867)

                        repeat
                            if not g2875 and v2874 then
                                if type(v2874) == "string" and string.find(v2874, "PrivateImage", 1, true) ~= nil then
                                    g2875 = true
                                end
                            else
                                g2875 = false
                                v2874 = nil
                            end
                        until not g2875

                        n20 = if not v2874 then not (type(v2867) == "string" and string.find(v2867, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                    end

                    g2873 = false

                    if not (n20 < n19) then
                        continue
                    end
                end

                t169[str3] = v2866
            end
        end
        local function v1792(p241, p242)
            local v2878 = p241 and p241.data
            if type(v2878) ~= "table" then
                return
            end
            local g2889
            local g2891
            local g2893
            local g2895
            local n22
            local n21
            for i = 1, #v2878 do
                local v2880 = v2878[i]
                local str4 = tostring(v2880.targetId or (v2880.targetid or ""))

                if str4 == "" then
                    continue
                end

                local v2882 = string.lower((tostring(v2880.state or (v2880.State or ""))))
                local v2883

                if type(v2880) ~= "table" then
                    v2883 = nil
                else
                    local v2884 = string.lower((tostring(v2880.state or (v2880.State or ""))))

                    v2883 = if v2884 == "" or v2884 == "completed" then v1787(v2880.imageUrl or (v2880.imageurl or v2880.ImageUrl)) else nil
                end

                if v2883 then
                    local str5 = tostring(str4 or "")
                    local v2886 = v1787(v2883)

                    if str5 == "" or not v2886 then
                        continue
                    end

                    local v2887 = t169[str5]

                    if v2887 then
                        if v1788(v2886) then
                            n21 = 3
                            g2889 = true
                        end

                        if not g2889 then
                            local v2890 = v1787(v2886)

                            repeat
                                if not g2891 and v2890 then
                                    if type(v2890) == "string" and string.find(v2890, "PrivateImage", 1, true) ~= nil then
                                        g2891 = true
                                    end
                                else
                                    g2891 = false
                                    v2890 = nil
                                end
                            until not g2891

                            n21 = if not v2890 then not (type(v2886) == "string" and string.find(v2886, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                        end

                        g2889 = false

                        if v1788(v2887) then
                            n22 = 3
                            g2893 = true
                        end

                        if not g2893 then
                            local v2894 = v1787(v2887)

                            repeat
                                if not g2895 and v2894 then
                                    if type(v2894) == "string" and string.find(v2894, "PrivateImage", 1, true) ~= nil then
                                        g2895 = true
                                    end
                                else
                                    g2895 = false
                                    v2894 = nil
                                end
                            until not g2895

                            n22 = if not v2894 then not (type(v2887) == "string" and string.find(v2887, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                        end

                        g2893 = false

                        if not (n22 < n21) then
                            continue
                        end
                    end

                    t169[str5] = v2886

                    continue
                end

                if p242 and v2882 == "pending" then
                    p242[#p242 + 1] = str4
                end
            end
        end
        local function v1793(p243)
            if type(p243) ~= "table" or #p243 == 0 then
                return
            end

            local function v2897(p244, p245, p246)
                if type(p244) ~= "table" or #p244 == 0 then
                    return {}
                end

                local t172 = {}
                local v4616, v4617 = v1790("https://thumbnails.roblox.com/v1/" .. p245 .. table.concat(p244, ",") .. "&size=" .. p246 .. "&format=Png&isCircular=false")

                v1791(v4617)
                v1792(v4616, t172)

                if #p244 == 1 and type(v4617) == "string" then
                    local v4618 = v4617:gsub("\\/", "/"):match("\"imageUrl\":\"(https://[^\"]+)\"")

                    if not v4618 then
                        return t172
                    end

                    local str6 = tostring(p244[1] or "")
                    local v4620 = v1787(v4618)

                    if str6 ~= "" then
                        if not v4620 then
                            return t172
                        end
                        local v4621 = t169[str6]
                        local g4622
                        local g4624
                        local g4626
                        local v4625
                        local g4628
                        local g4630
                        local v4629
                        local n24
                        local n23
                        repeat
                            if g4622 or not v4621 then
                                g4622 = false
                                t169[str6] = v4620

                                return t172
                            end

                            if v1788(v4620) then
                                n23 = 3
                                g4624 = true
                            end

                            if not g4624 then
                                v4625 = v1787(v4620)
                            end

                            repeat
                                if g4624 or (g4626 or v4625) then
                                    if g4624 or (g4626 or (type(v4625) ~= "string" or string.find(v4625, "PrivateImage", 1, true) == nil)) then
                                        if not g4624 then
                                            g4626 = false
                                            n23 = if not v4625 then not (type(v4620) == "string" and string.find(v4620, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                        end

                                        g4624 = false

                                        if v1788(v4621) then
                                            n24 = 3
                                            g4628 = true
                                        end

                                        if not g4628 then
                                            v4629 = v1787(v4621)
                                        end

                                        repeat
                                            if g4628 or (g4630 or v4629) then
                                                if g4628 or (g4630 or (type(v4629) ~= "string" or string.find(v4629, "PrivateImage", 1, true) == nil)) then
                                                    if not g4628 then
                                                        g4630 = false
                                                        n24 = if not v4629 then not (type(v4621) == "string" and string.find(v4621, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                                    end

                                                    g4628 = false

                                                    if n24 < n23 then
                                                        g4622 = true
                                                    end

                                                    if not g4622 then
                                                        return t172
                                                    end
                                                end
                                            end

                                            if g4622 then
                                                break
                                            end

                                            v4629 = nil
                                            g4630 = true
                                        until not g4630
                                    end
                                end

                                if g4622 then
                                    break
                                end

                                v4625 = nil
                                g4626 = true
                            until not g4626
                        until not g4622
                    end
                end

                return t172
            end

            local v2898 = v2897(p243, "assets?assetIds=", "150x150")
            local t173 = {}

            for i = 1, #p243 do
                if not v1788(t169[tostring(p243[i])]) then
                    t173[#t173 + 1] = tostring(p243[i])
                end
            end

            if #t173 > 0 then
                v2897(t173, "assets?assetIds=", "420x420")
            end

            if type(v2898) == "table" and #v2898 > 0 then
                task.wait(0.4)
                v2897(v2898, "assets?assetIds=", "150x150")
            end

            local v2901 = (function()
                local t174 = {}
                local t175 = {}

                for i = 1, #p243 do
                    local str7 = tostring(p243[i])

                    if str7 ~= "" and not t175[str7] and type(t169[str7]) ~= "string" then
                        t175[str7] = true
                        t174[#t174 + 1] = str7
                    end
                end

                return t174
            end)()

            if #v2901 > 0 then
                v2897(v2901, "bundles/thumbnails?bundleIds=", "150x150")
            end
        end
        local function v1794(p247, p248, p249)
            local t176 = {}
            local t177 = {}
            local v2907 = v1786(p247, p248)

            if type(v2907) == "string" and (v2907 ~= "" and not t177[v2907]) then
                t177[v2907] = true
                t176[#t176 + 1] = v2907
            end

            if type(p249) == "string" and p249 ~= "" and not t177[p249] then
                t177[p249] = true
                t176[#t176 + 1] = p249
            end

            if type(p247) == "table" then
                local v2908 = v1784(p247.Icon)

                if type(v2908) == "string" and v2908 ~= "" and not t177[v2908] then
                    t177[v2908] = true
                    t176[#t176 + 1] = v2908
                end

                for i = 1, #t170 do
                    local v2910 = v1784(p247[t170[i]])

                    if type(v2910) == "string" and v2910 ~= "" and not t177[v2910] then
                        t177[v2910] = true
                        t176[#t176 + 1] = v2910
                    end
                end
            end

            return t176
        end
        local function v1795(p250, p251, p252)
            local v2914 = v1794(p251, p252, p250)
            local t178 = {}
            local t179 = {}
            local u2917
            local u2918
            local function v2919(p253)
                local v4633 = v1787(p253)
                if not v4633 then
                    return
                end
                local g4644
                local g4646
                local g4648
                local v4647
                local g4651
                local g4653
                local v4652
                local n28
                local n27
                if type(v4633) == "string" and string.find(v4633, "PrivateImage", 1, true) ~= nil then
                    local g4634
                    local g4636
                    local g4638
                    local v4637
                    local g4641
                    local g4643
                    local v4642
                    local n26
                    local n25
                    repeat
                        if g4634 or not u2918 then
                            g4634 = false
                            u2918 = v4633

                            return
                        end

                        if v1788(v4633) then
                            n25 = 3
                            g4636 = true
                        end

                        if not g4636 then
                            v4637 = v1787(v4633)
                        end

                        repeat
                            if g4636 or (g4638 or v4637) then
                                if g4636 or (g4638 or (type(v4637) ~= "string" or string.find(v4637, "PrivateImage", 1, true) == nil)) then
                                    if not g4636 then
                                        n25 = if not v4637 then not (type(v4633) == "string" and string.find(v4633, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                    end

                                    g4636 = false

                                    local v4639 = u2918

                                    if v1788(v4639) then
                                        n26 = 3
                                        g4641 = true
                                    end

                                    if not g4641 then
                                        v4642 = v1787(v4639)
                                    end

                                    repeat
                                        if g4641 or (g4643 or v4642) then
                                            if g4641 or (g4643 or (type(v4642) ~= "string" or string.find(v4642, "PrivateImage", 1, true) == nil)) then
                                                if not g4641 then
                                                    n26 = if not v4642 then not (type(v4639) == "string" and string.find(v4639, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                                end

                                                g4641 = false

                                                if n26 < n25 then
                                                    g4634 = true
                                                end

                                                if not g4634 then
                                                    return
                                                end
                                            end
                                        end

                                        if g4634 then
                                            break
                                        end

                                        v4642 = nil
                                        g4643 = true
                                    until not g4643
                                end
                            end

                            if g4634 then
                                break
                            end

                            v4637 = nil
                            g4638 = true
                        until not g4638
                    until not g4634
                end
                repeat
                    if g4644 or not u2917 then
                        g4644 = false
                        u2917 = v4633

                        return
                    end

                    if v1788(v4633) then
                        n27 = 3
                        g4646 = true
                    end

                    if not g4646 then
                        v4647 = v1787(v4633)
                    end

                    repeat
                        if g4646 or (g4648 or v4647) then
                            if g4646 or (g4648 or (type(v4647) ~= "string" or string.find(v4647, "PrivateImage", 1, true) == nil)) then
                                if not g4646 then
                                    g4648 = false
                                    n27 = if not v4647 then not (type(v4633) == "string" and string.find(v4633, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                end

                                g4646 = false

                                local v4649 = u2917

                                if v1788(v4649) then
                                    n28 = 3
                                    g4651 = true
                                end

                                if not g4651 then
                                    v4652 = v1787(v4649)
                                end

                                repeat
                                    if g4651 or (g4653 or v4652) then
                                        if g4651 or (g4653 or (type(v4652) ~= "string" or string.find(v4652, "PrivateImage", 1, true) == nil)) then
                                            if not g4651 then
                                                g4653 = false
                                                n28 = if not v4652 then not (type(v4649) == "string" and string.find(v4649, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                            end

                                            g4651 = false

                                            if not (n28 < n27) then
                                                return
                                            end

                                            g4644 = true
                                        end
                                    end

                                    if g4644 then
                                        break
                                    end

                                    v4652 = nil
                                    g4653 = true
                                until not g4653
                            end
                        end

                        if g4644 then
                            break
                        end

                        v4647 = nil
                        g4648 = true
                    until not g4648
                until not g4644
            end
            local g2927
            for i = 1, #v2914 do
                local v2921 = v1789(v2914[i])

                if v2921 then
                    if v2921.cdn then
                        v2919(v2921.cdn)
                    end

                    if v2921.id and not t179[v2921.id] then
                        t179[v2921.id] = true
                        t178[#t178 + 1] = v2921.id
                        v2919(t169[v2921.id])
                    end
                end
            end
            v1793(t178)
            for i = 1, #t178 do
                v2919(t169[t178[i]])
            end
            local v2923 = v1788(u2917) or u2917
            if not v1788(v2923) then
                for i = 1, #t178 do
                    local v2925 = v1788(t169[t178[i]])

                    if not v2925 then
                        local v2926 = t169[t178[i]]

                        v2925 = v1787(v2926)

                        repeat
                            if not g2927 and v2925 then
                                if type(v2925) == "string" and string.find(v2925, "PrivateImage", 1, true) ~= nil then
                                    g2927 = true
                                end
                            else
                                g2927 = false
                                v2925 = nil
                            end
                        until not g2927
                    end

                    if v2925 then
                        v2923 = v2925

                        if v1788(v2925) then
                            break
                        end
                    end
                end
            end

            return v2923, t178, u2917, u2918
        end

        local t180 = {}

        local function v1797(p254)
            local str8 = tostring(p254 or "")

            if str8 == "" or str8 == "0" then
                return
            end

            if type(t180[str8]) == "string" then
                return t180[str8]
            end

            local v2930 = v1790("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. str8 .. "&size=150x150&format=Png&isCircular=false")
            local v2931 = v2930 and (v2930.data and v2930.data[1])
            local v2932

            if type(v2931) ~= "table" then
                v2932 = nil
            else
                local v2933 = string.lower((tostring(v2931.state or (v2931.State or ""))))

                v2932 = if v2933 == "" or v2933 == "completed" then v1787(v2931.imageUrl or (v2931.imageurl or v2931.ImageUrl)) else nil
            end

            if v2932 then
                t180[str8] = v2932
            end

            return v2932
        end
        local function v1798(p255, p256)
            local v2936
            if type(p255) == "table" then
                v2936 = tonumber(p255.Weight) or (tonumber(p255.ModelWeight) or (tonumber(p255.Kg) or tonumber(p255.BaseWeight)))
            end
            if (not v2936 or v2936 <= 0) and type(p256) == "table" then
                v2936 = tonumber(p256.Weight) or (tonumber(p256.BaseWeight) or tonumber(p256.ModelWeight))
            end
            if not v2936 or v2936 <= 0 then
                return
            end
            if v2936 >= 100 then
                return string.format("%.0f kg", v2936)
            end

            return string.format("%.1f kg", v2936)
        end
        local function v1799(p257)
            if type(p257) ~= "table" or (type(p257.Mutations) ~= "table" or #p257.Mutations == 0) then
                return
            end

            return table.concat(p257.Mutations, " · ")
        end
        local function v1800()
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local v2939 = PlayerGui and PlayerGui:FindFirstChild("HUD")
            local v2940 = v2939 and v2939:FindFirstChild("GameHUD")
            local v2941 = v2940 and v2940:FindFirstChild("BottomLeft")
            local v2942 = v2941 and v2941:FindFirstChild("Money")
            local v2943 = v2942 and v2942:FindFirstChild("Value")

            if v2943 and ((v2943:IsA("TextLabel") or v2943:IsA("TextButton")) and v2943.Text ~= "") then
                return v2943.Text
            end

            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local v2945 = leaderstats and (leaderstats:FindFirstChild("Money") or (leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")))

            if v2945 and v2945:IsA("ValueBase") then
                return "$" .. v1781(v2945.Value)
            end

            return "—"
        end
        local function v1801()
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local v2947 = leaderstats and (leaderstats:FindFirstChild("Money/s") or leaderstats:FindFirstChild("Income"))

            if v2947 and v2947:IsA("ValueBase") then
                return v1781(v2947.Value) .. "/s"
            end

            return "—"
        end
        local function v1802(p258, p259, p260)
            if p259 == nil or p259 == "" then
                return
            end

            return {
				name = tostring(p258),
				value = tostring(p259),
				inline = p260 ~= false
			}
        end
        local function v1803(...)
            local t181 = {}

            for i = 1, select("#", ...) do
                local v2953 = select(i, ...)

                if v2953 then
                    t181[#t181 + 1] = v2953
                end
            end

            if #t181 == 0 then
                return
            end

            return t181
        end
        local function v1804()
            if Config.HookUsername == true then
                local t182 = {
					name = tostring(LocalPlayer.DisplayName or LocalPlayer.Name),
					url = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile"
				}
                local v2955 = v1797(LocalPlayer.UserId)

                if v2955 then
                    t182.icon_url = v2955
                end

                return t182
            end

            return {
				name = "KOZUA"
			}
        end
        local function v1805(p261)
            if type(p261) ~= "table" then
                return true
            end

            if p261.Success == false or p261.success == false then
                return false
            end

            local num = tonumber(p261.StatusCode or (p261.status_code or p261.Status))

            if num and num >= 400 then
                return false, num
            end

            return true, num
        end
        local function v1806(p262)
            if type(p262) ~= "string" or #p262 < 12 then
                return
            end

            local v2959, v2960, v2961, v2962 = string.byte(p262, 1, 4)

            if v2959 == 137 and v2960 == 80 and v2961 == 78 and v2962 == 71 then
                return "image/png", "png"
            end

            if v2959 == 255 and v2960 == 216 then
                return "image/jpeg", "jpg"
            end

            if v2959 == 71 and v2960 == 73 and v2961 == 70 then
                return "image/gif", "gif"
            end

            if v2959 == 82 and v2960 == 73 and v2961 == 70 and v2962 == 70 and string.sub(p262, 9, 12) == "WEBP" then
                return "image/webp", "webp"
            end
        end
        local function v1807(p263, p264)
            if type(p263) ~= "string" or #p263 < 32 then
                return false
            end

            if p264 == "png" then
                return string.find(p263, "IEND", 1, true) ~= nil
            end

            if p264 == "jpg" then
                local v2965 = #p263

                return string.byte(p263, v2965 - 1) == 255 and string.byte(p263, v2965) == 217
            end

            if p264 == "gif" then
                return #p263 > 64
            end

            return false
        end
        local function v1808(p265, p266)
            local v2968 = p265 and (p265.Headers or p265.headers)

            if type(v2968) ~= "table" then
                return
            end

            local v2969 = string.lower(p266)

            for k, v in pairs(v2968) do
                if v2969 == string.lower((tostring(k))) then
                    return v
                end
            end
        end
        local function v1809(p267)
            if type(p267) ~= "string" then
                return
            end

            local u2973 = p267:gsub("^http://", "https://")

            if not string.find(u2973, "^https://") then
                return
            end

            local function v2974(p268)
                local v4655, v4656 = v1806(p268)

                if v4655 and (v4656 ~= "webp" and v1807(p268, v4656)) then
                    return p268, v4655, v4656
                end
            end

            if string.find(u2973, "rbxcdn.com", 1, true) and type(game.HttpGet) == "function" then
                local ok26, result26 = pcall(game.HttpGet, game, u2973)

                if ok26 then
                    local v2977, v2978 = v1806(result26)

                    if if not v2977 or (v2978 == "webp" or not v1807(result26, v2978)) then nil else result26 then
                        return v2974(result26)
                    end
                end
            end

            local v2979 = syn and syn.request or (http_request or (request or (http and http.request or fluxus and fluxus.request)))

            if v2979 then
                for _ = 1, 5 do
                    local ok27, result27 = pcall(v2979, {
						Url = u2973,
						Method = "GET",
						Headers = {
							Accept = "image/png,image/jpeg,image/*;q=0.8,*/*;q=0.1"
						}
					})

                    if not ok27 or type(result27) ~= "table" then
                        break
                    end

                    local v2983 = result27.Body or result27.body
                    local v2984, v2985 = v1806(v2983)

                    if if not v2984 or (v2985 == "webp" or not v1807(v2983, v2985)) then nil else v2983 then
                        return v2974(v2983)
                    end

                    local v2986 = v1808(result27, "Location")

                    if type(v2986) ~= "string" or v2986 == "" then
                        break
                    end

                    if string.find(v2986, "^https?://") then
                        u2973 = v2986:gsub("^http://", "https://")
                    else
                        if string.sub(v2986, 1, 1) ~= "/" then
                            break
                        end

                        local v2987 = u2973:match("^(https://[^/]+)")

                        if not v2987 then
                            break
                        end

                        u2973 = v2987 .. v2986
                    end
                end
            end

            local ok28, result28 = pcall(function()
                if type(game.HttpGet) == "function" then
                    return game:HttpGet(u2973)
                end
            end)

            if ok28 then
                return v2974(result28)
            end
        end
        local function v1810(p269, p270, p271)
            local v2993 = syn and syn.request or (http_request or (request or (http and http.request or fluxus and fluxus.request)))
            local ok29, result29 = pcall(function()
                return HttpService:JSONEncode(p270)
            end)

            if not ok29 or type(result29) ~= "string" then
                return false, "encode"
            end

            if p271 and p271.bytes then
                local v2996 = "kozua" .. tostring(math.floor(os.clock() * 1000000)) .. tostring(math.random(100000, 999999))
                local v2997 = "--" .. v2996 .. "\r\n" .. "Content-Disposition: form-data; name=\"payload_json\"" .. "\r\n" .. "\r\n" .. result29 .. "\r\n" .. "--" .. v2996 .. "\r\n" .. "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. (p271.name or "icon.png") .. "\"" .. "\r\n" .. "Content-Type: " .. (p271.mime or "image/png") .. "\r\n" .. "Content-Transfer-Encoding: binary" .. "\r\n" .. "\r\n" .. p271.bytes .. "\r\n" .. "--" .. v2996 .. "--\r\n"

                if not string.find(p269, "wait=", 1, true) then
                    p269 ..= (not string.find(p269, "?", 1, true) and "?" or "&") .. "wait=true"
                end

                local ok30, result30 = pcall(v2993, {
					Url = p269,
					Method = "POST",
					Headers = {
						["Content-Type"] = "multipart/form-data; boundary=" .. v2996,
						["Content-Length"] = tostring(#v2997)
					},
					Body = v2997
				})

                if ok30 and select(1, v1805(result30)) then
                    local v3000 = result30 and (result30.Body or result30.body)
                    local v3001

                    if type(v3000) ~= "string" or v3000 == "" then
                        v3001 = false
                    else
                        local num = tonumber(v3000:match("\"code\"%s*:%s*(%d+)"))

                        v3001 = num ~= nil and num >= 10000
                    end

                    if not v3001 then
                        return true, result30
                    end
                end

                return false, "multipart"
            end

            local ok31, result31 = pcall(v2993, {
				Url = p269,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = result29
			})

            if not ok31 then
                return false, (tostring(result31))
            end

            local v3005, v3006

            if type(result31) ~= "table" then
                v3005 = true
                v3006 = nil
            elseif result31.Success == false or result31.success == false then
                v3005 = false
                v3006 = nil
            else
                v3006 = tonumber(result31.StatusCode or (result31.status_code or result31.Status))

                if v3006 and v3006 >= 400 then
                    v3005 = false
                else
                    v3005 = true
                end
            end

            if not v3005 then
                return false, "http " .. tostring(v3006)
            end

            return true, result31
        end
        local function v1811(p272)
            if Config.HookEnabled ~= true then
                return false, "off"
            end
            local HookUrl = Config.HookUrl
            if type(HookUrl) ~= "string" or not string.find(HookUrl, "^https://") then
                return false, "no url"
            end
            if (not syn or not syn.request) and (not http_request and (not request and ((not http or not http.request) and (not fluxus or not fluxus.request)))) then
                return false, "no http"
            end
            local v3009, v3010, v3011, v3012 = v1795(p272.thumbnail, p272.cfg, p272.cat)
            local str9 = tostring(p272.title or "kozua")
            local v3014
            local g3028
            local str10
            local s17
            if #str9 > 256 then
                v3014 = str9
                str9 = string.sub(str9, 1, 253) .. "..."
            end
            local t183 = {
				author = v1804(),
				title = str9,
				color = tonumber(p272.color) or 11393254,
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}
            local t184 = {}
            local Discord = HubInfo.Discord
            local v3018 = tostring(((if type(Discord) == "string" and Discord:match("%S") ~= nil then (if not Discord:find("discord%.", 1) and not Discord:find("http", 1, true) then "discord.gg/" .. Discord else Discord) else nil)) or (HubInfo.Discord or "")):gsub("^https://", "")
            t184.text = v3018 == "" and "KOZUA" or "KOZUA · " .. v3018
            t183.footer = t184
            local v3019 = p272.description and tostring(p272.description) or ""
            if v3014 then
                v3019 = v3019 ~= "" and v3014 .. "\n" .. v3019 or v3014
            end
            if v3019 ~= "" then
                t183.description = v3019
            end
            if p272.fields then
                t183.fields = p272.fields
            end
            if p272.url then
                t183.url = p272.url
            end
            local t186
            local t185 = {}
            local function v3022(p273)
                if type(p273) ~= "string" or p273 == "" or t185[p273] then
                    return
                end

                t185[p273] = true

                local v4661, v4662, v4663 = v1809(p273)

                if v4661 and v4663 then
                    t186 = {
						bytes = v4661,
						mime = v4662,
						name = "icon." .. v4663
					}

                    return true
                end
            end
            local function v3023(p274)
                local v4665 = v1787(p274)

                if not v4665 then
                    return
                end

                local v4666 = v4665:match("(180DAY%-[%w%-]+)") or v4665:match("rbxcdn%.com/([%w%-]+)/")

                if not v4666 then
                    return
                end

                return {
					"https://tr.rbxcdn.com/" .. v4666 .. "/150/150/Image/Png/noFilter",
					"https://tr.rbxcdn.com/" .. v4666 .. "/420/420/Image/Png/noFilter"
				}
            end
            local function v3024(p275)
                if v3022(p275) then
                    return true
                end

                local v4668 = v3023(p275)

                if type(v4668) ~= "table" then
                    return
                end

                for i = 1, #v4668 do
                    if v3022(v4668[i]) then
                        return true
                    end
                end
            end
            local WebhookPayload = {
				username = "KOZUA",
				embeds = { t183 }
			}
            local HookPing = Config.HookPing
            if HookPing == "Here" then
                s17 = "@here"
                g3028 = true
            end
            repeat
                if g3028 or (g3028 or HookPing == "User id") then
                    if not g3028 then
                        if not g3028 then
                            str10 = tostring(Config.HookUserId or "")
                        end
                    end

                    if g3028 or (g3028 or str10 ~= "" and str10 ~= "0") then
                        if not g3028 then
                            if not g3028 then
                                s17 = "<@" .. str10 .. ">"
                            end
                        end

                        g3028 = false

                        if s17 then
                            WebhookPayload.content = s17
                        end

                        local v3030 = v1788(v3011) or v1788(v3009)

                        if not v3030 and type(v3010) == "table" then
                            for i = 1, #v3010 do
                                local v3032 = t169[v3010[i]]

                                v3030 = v1788(v3032)

                                if v3030 then
                                    break
                                end
                            end
                        end

                        if not v3030 then
                            v3030 = v1788(v3012)
                        end

                        if v3030 then
                            t183.thumbnail = {
								url = v3030
							}

                            return v1810(HookUrl, WebhookPayload)
                        end

                        if not t186 then
                            v3024(v3012)
                            v3024(v3009)
                            v3024(v3011)

                            if not t186 and type(v3010) == "table" then
                                for i = 1, math.min(#v3010, 8) do
                                    v3024(t169[v3010[i]])

                                    if t186 then
                                        break
                                    end

                                    local str11 = tostring(v3010[i])

                                    v3022("https://assetdelivery.roblox.com/v1/asset/?id=" .. str11)
                                    v3022("https://www.roblox.com/asset-thumbnail/image?assetId=" .. str11 .. "&width=150&height=150&format=png")

                                    if t186 then
                                        break
                                    end
                                end
                            end
                        end

                        if t186 then
                            t183.thumbnail = {
								url = "attachment://" .. t186.name
							}
                            WebhookPayload.attachments = {{
								id = 0,
								filename = t186.name
							}}

                            if select(1, v1810(HookUrl, WebhookPayload, t186)) then
                                return true
                            end

                            WebhookPayload.attachments = nil
                        end

                        t183.thumbnail = nil

                        return v1810(HookUrl, WebhookPayload)
                    end
                end

                s17 = nil
                g3028 = true
            until not g3028
        end
        local function v1812(p276)
            if type(p276) ~= "table" then
                return nil, nil, nil
            end

            local rec = p276.rec
            local cfg = p276.cfg
            local v3039 = p276.cat or rec and (rec.AssetCategory or rec.Category)

            if type(cfg) ~= "table" and v3039 then
                cfg = if not not Directory and v3039 then Directory[v3039] else nil
            end

            if type(cfg) ~= "table" and type(Directory) == "table" then
                local v3040 = string.lower((tostring(p276.name or (v3039 or ""))))

                if v3040 ~= "" and v3040 ~= "egg" and v3040 ~= "?" then
                    for k, v in pairs(Directory) do
                        if type(v) == "table" and (v3040 == string.lower((tostring(k))) or v3040 == string.lower((tostring(v.DisplayName or "")))) then
                            return rec, v, (tostring(k))
                        end
                    end
                end
            end

            return rec, cfg, v3039
        end
        local function v1813()
            if Config.HookEnabled ~= true or Config.SessionDigest ~= true then
                return
            end

            local elapsed10 = os.clock()

            if elapsed10 - elapsed8 < 600 then
                return
            end

            elapsed8 = elapsed10

            local v3109 = FarmSync and (not not FarmSync.stats and FarmSync.stats()) or {}
            local v3110 = (tonumber(v3109.soldPets) or 0) + (tonumber(v3109.soldEggs) or 0)
            local v3111 = tostring(v3109.soldPets or 0) .. " pets · " .. tostring(v3109.soldEggs or 0) .. " eggs"
            local t188 = {
				kind = "Session recap",
				title = v1783() .. " running",
				description = "Totals since this execute — not just the last 10 minutes.",
				color = 9807270
			}
            local v3113 = v1803
            local str12 = tostring(StealState and StealState.banked or 0)
            local v3115 = if str12 ~= nil and str12 ~= "" then {
				name = tostring("Stolen"),
				value = tostring(str12),
				inline = true
			} else nil
            local str13 = tostring(StealState and StealState.lost or 0)
            local v3117 = if str13 ~= nil and str13 ~= "" then {
				name = tostring("Lost"),
				value = tostring(str13),
				inline = true
			} else nil
            local str14 = tostring(StealState and StealState.regrabs or 0)
            local v3119 = if str14 ~= nil and str14 ~= "" then {
				name = tostring("Re-grabs"),
				value = tostring(str14),
				inline = true
			} else nil
            local str15 = tostring(v3109.hatched or 0)
            local v3121 = if str15 ~= nil and str15 ~= "" then {
				name = tostring("Hatched"),
				value = tostring(str15),
				inline = true
			} else nil
            local v3122 = v3110 > 0 and v3111 or "0"
            local v3123 = if v3122 ~= nil and v3122 ~= "" then {
				name = tostring("Sold"),
				value = tostring(v3122),
				inline = true
			} else nil
            local str16 = tostring(v3109.claimIndex or 0)
            local v3125 = if str16 ~= nil and str16 ~= "" then {
				name = tostring("Index claims"),
				value = tostring(str16),
				inline = true
			} else nil
            local v3126 = v1800()

            t188.fields = v3113(v3115, v3117, v3119, v3121, v3123, v3125, if v3126 ~= nil and v3126 ~= "" then {
				name = tostring("Money"),
				value = tostring(v3126),
				inline = true
			} else nil, v1802("Income", (v1801())))

            if type(t188) ~= "table" then
                return
            end

            task.spawn(function()
                local v4681, v4682 = v1811(t188)

                if not v4681 then
                    KozuaLog("hook", "send fail", tostring(v4682), (tostring(t188.title)))
                end
            end)
        end

        task.spawn(function()
            while IsAlive do
                task.wait(30)
                pcall(v1813)
            end
        end)

        return {
			send = function(p277)
            if type(p277) ~= "table" then
                return false, "bad embed"
            end

            task.spawn(function()
                local v4671, v4672 = v1811(p277)

                if not v4671 then
                    KozuaLog("hook", "send fail", tostring(v4672), (tostring(p277.title)))
                end
            end)

            return true
        end,
			test = function()
            Config.HookEnabled = true

            if WidgetRegistry.HookEnabled and WidgetRegistry.HookEnabled.set then
                pcall(WidgetRegistry.HookEnabled.set, true)
            end

            local v3102 = v1811
            local t189 = {
					kind = "Webhook test",
					title = "Connected",
					description = "Stolen and hatched eggs will post as embeds with the pet icon, $/s, and rarity.",
					color = 11393254
				}
            local v3104 = v1803
            local str17 = tostring(LocalPlayer.DisplayName or LocalPlayer.Name)
            local v3106 = if str17 ~= nil and str17 ~= "" then {
					name = tostring("Player"),
					value = tostring(str17),
					inline = true
				} else nil
            local str18 = tostring(HubInfo.Game or "Roblox")

            t189.fields = v3104(v3106, if str18 ~= nil and str18 ~= "" then {
					name = tostring("Game"),
					value = tostring(str18),
					inline = true
				} else nil, v1802("Session", v1783()))

            return v3102(t189)
        end,
			stolen = function(p278)
            if Config.HookStolen ~= true then
                return
            end

            local v3044 = p278 or StealState and (StealState.hookSnap or StealState.target)
            local v3045, v3046, v3047 = v1812(v3044)
            local v3048 = v3044 and v3044.name

            if type(v3048) ~= "string" or v3048 == "" or v3048 == "egg" or v3048 == "?" then
                v3048 = v3046 and (v3046.DisplayName or v3046._id) or (v3047 and tostring(v3047) or nil)
            end

            local v3049 = v1193(v3045, v3046)

            if (not v3049 or v3049 == 0) and v3044 and tonumber(v3044.earn) then
                v3049 = v3044.earn
            end

            if (not v3049 or v3049 == 0) and type(v3046) == "table" then
                v3049 = if type(v3046) == "table" then tonumber(v3046.EarningRate) or 0 else 0
            end

            local v3050 = if type(v3046) == "table" and type(v3046.Rarity) == "table" then tostring(v3046.Rarity.DisplayName or (v3046.Rarity.Name or (v3046.Rarity._id or "?"))) else "?"

            if (not v3050 or v3050 == "?") and v3044 and type(v3044.rar) == "string" then
                v3050 = v3044.rar
            end

            if (not v3048 or v3048 == "egg") and type(v3046) ~= "table" then
                KozuaLog("hook", "stolen skipped, no egg")

                return
            end

            local v3051 = v3048 or (v3046 and v3046.DisplayName or "egg")
            local v3052 = v1194(Config.HookMinGen)

            if v3052 > 0 and v3052 > (tonumber(v3049) or 0) or not v1782(v3050) then
                return
            end

            local t190 = {
					kind = "Egg stolen",
					title = tostring(v3051),
					color = t171[string.lower((tostring(v3050 or "")))] or 5814783,
					thumbnail = v3044 and v3044.icon or v1786(v3046, v3047, v3051),
					cfg = v3046,
					cat = v3047
				}
            local v3054 = v1803
            local v3055 = "**" .. v1781(v3049) .. "/s**"
            local v3056 = if v3055 ~= nil and v3055 ~= "" then {
					name = tostring("Earns"),
					value = tostring(v3055),
					inline = true
				} else nil
            local v3057 = if v3050 ~= nil and v3050 ~= "" then {
					name = tostring("Rarity"),
					value = tostring(v3050),
					inline = true
				} else nil
            local v3058, v3059 = v1192(v3046, v3045)
            local v3060 = if v3058 ~= nil and v3058 ~= "" then {
					name = tostring("Chance"),
					value = tostring(v3058),
					inline = v3059 ~= false
				} else nil
            local v3061, v3062 = v1798(v3045, v3046)
            local v3063 = if v3061 ~= nil and v3061 ~= "" then {
					name = tostring("Weight"),
					value = tostring(v3061),
					inline = v3062 ~= false
				} else nil
            local v3064, v3065

            if type(v3045) ~= "table" or type(v3045.Mutations) ~= "table" or #v3045.Mutations == 0 then
                v3064 = nil
                v3065 = nil
            else
                v3064, v3065 = table.concat(v3045.Mutations, " · ")
            end

            local v3066 = if v3064 ~= nil and v3064 ~= "" then {
					name = tostring("Mutations"),
					value = tostring(v3064),
					inline = v3065 ~= false
				} else nil
            local v3067 = v3044 and (v3044.area ~= "" and v3044.area) or nil

            t190.fields = v3054(v3056, v3057, v3060, v3063, v3066, if v3067 ~= nil and v3067 ~= "" then {
					name = tostring("Area"),
					value = tostring(v3067),
					inline = true
				} else nil, v1802("This session", tostring(StealState and StealState.banked or 0) .. " stolen · " .. tostring(StealState and StealState.lost or 0) .. " lost"))

            if type(t190) ~= "table" then
                return
            end

            task.spawn(function()
                local v4673, v4674 = v1811(t190)

                if not v4673 then
                    KozuaLog("hook", "send fail", tostring(v4674), (tostring(t190.title)))
                end
            end)
        end,
			hatched = function(p279, p280, p281)
            if Config.HookHatched ~= true then
                return
            end

            local v3071 = type(p279) == "table" and p279 or {
					name = p279,
					earn = p280,
					rar = p281
				}
            local v3072 = v3071.name or "pet"
            local v3073 = v1193(v3071.rec, v3071.cfg)

            if v3073 == 0 and tonumber(v3071.earn) then
                v3073 = v3071.earn
            end

            local rar = v3071.rar

            if not rar then
                local cfg = v3071.cfg

                rar = ((if type(cfg) == "table" and type(cfg.Rarity) == "table" then tostring(cfg.Rarity.DisplayName or (cfg.Rarity.Name or (cfg.Rarity._id or "?"))) else "?")) or "?"
            end

            local v3076 = v1194(Config.HookMinGen)

            if v3076 > 0 and v3076 > (tonumber(v3073) or 0) or not v1782(rar) then
                return
            end

            local t191 = {
					kind = "Egg hatched",
					title = tostring(v3072),
					color = t171[string.lower((tostring(rar or "")))] or 3908956,
					thumbnail = v1786(v3071.cfg, v3071.cat, v3072),
					cfg = v3071.cfg,
					cat = v3071.cat
				}
            local v3078 = v1803
            local v3079 = "**" .. v1781(v3073) .. "/s**"
            local v3080 = if v3079 ~= nil and v3079 ~= "" then {
					name = tostring("Earns"),
					value = tostring(v3079),
					inline = true
				} else nil
            local v3081 = if rar ~= nil and rar ~= "" then {
					name = tostring("Rarity"),
					value = tostring(rar),
					inline = true
				} else nil
            local v3082, v3083 = v1192(v3071.cfg, v3071.rec)
            local v3084 = if v3082 ~= nil and v3082 ~= "" then {
					name = tostring("Chance"),
					value = tostring(v3082),
					inline = v3083 ~= false
				} else nil
            local v3085, v3086 = v1798(v3071.rec, v3071.cfg)

            t191.fields = v3078(v3080, v3081, v3084, if v3085 ~= nil and v3085 ~= "" then {
					name = tostring("Weight"),
					value = tostring(v3085),
					inline = v3086 ~= false
				} else nil, v1802("Mutations", v1799(v3071.rec)))

            if type(t191) ~= "table" then
                return
            end

            task.spawn(function()
                local v4675, v4676 = v1811(t191)

                if not v4675 then
                    KozuaLog("hook", "send fail", tostring(v4676), (tostring(t191.title)))
                end
            end)
        end,
			sold = function(p282, p283, p284)
            if Config.HookSold ~= true then
                return
            end

            local v3090 = type(p282) == "table" and p282 or {
					kind = p282,
					name = p283,
					earn = p284
				}
            local v3091, v3092, v3093 = v1812(v3090)

            v3090.cfg = v3092 or v3090.cfg
            v3090.cat = v3093 or v3090.cat
            v3090.rec = v3091 or v3090.rec

            local v3094 = v3090.kind ~= "egg" and "pet" or "egg"
            local v3095 = v3092 and (if type(v3092) == "table" and type(v3092.Rarity) == "table" then tostring(v3092.Rarity.DisplayName or (v3092.Rarity.Name or (v3092.Rarity._id or "?"))) else "?") or nil
            local name = v3090.name

            if type(name) ~= "string" or name == "" or name == "egg" or name == "pet" then
                name = v3092 and v3092.DisplayName or (v3093 or v3094)
            end

            local t192 = {
					kind = v3094 ~= "egg" and "Sold a pet" or "Sold an egg",
					title = tostring(name),
					color = t171[string.lower((tostring(v3095 or "")))] or 15105570,
					thumbnail = v1786(v3092, v3093, name),
					cfg = v3092,
					cat = v3093
				}
            local v3098 = v1803
            local v3099 = "**" .. v1781(v1193(v3090.rec, v3092)) .. "/s**"

            t192.fields = v3098(if v3099 ~= nil and v3099 ~= "" then {
					name = tostring("Earns"),
					value = tostring(v3099),
					inline = true
				} else nil, if v3095 ~= nil and v3095 ~= "" then {
					name = tostring("Rarity"),
					value = tostring(v3095),
					inline = true
				} else nil, v1802("Chance", v1192(v3092, v3090.rec)))

            if type(t192) ~= "table" then
                return
            end

            task.spawn(function()
                local v4677, v4678 = v1811(t192)

                if not v4677 then
                    KozuaLog("hook", "send fail", tostring(v4678), (tostring(t192.title)))
                end
            end)
        end,
			rewards = function(p285)
            if Config.HookRewards ~= true then
                return
            end

            local t193 = {
					kind = "Rewards claimed",
					title = "Index rewards",
					description = "Claimed **" .. tostring(p285) .. "** " .. (tonumber(p285) ~= 1 and "entries" or "entry"),
					color = 3447003
				}

            if type(t193) ~= "table" then
                return
            end

            task.spawn(function()
                local v4679, v4680 = v1811(t193)

                if not v4679 then
                    KozuaLog("hook", "send fail", tostring(v4680), (tostring(t193.title)))
                end
            end)
        end
		}
    end)()
    local function v1196(p286)
        local t194 = {}

        if type(p286) ~= "table" then
            return t194
        end

        for _, v in ipairs(p286) do
            t194[string.lower((tostring(v)))] = true
        end

        return t194
    end
    local t195 = {}
    local n29 = 0
    local t202
    local n30 = 0
    local u1201
    local u1202 = false
    local function v1203()
        local v1820 = workspace:GetServerTimeNow() or 0
        local AreaEggCycleDisabledAt = workspace:GetAttribute("AreaEggCycleDisabledAt")

        if type(AreaEggCycleDisabledAt) == "number" then
            v1820 = math.min(v1820, AreaEggCycleDisabledAt)
        end

        local AreaEggCycleAnchorAt = workspace:GetAttribute("AreaEggCycleAnchorAt")
        local AreaEggCycleAnchorIndex = workspace:GetAttribute("AreaEggCycleAnchorIndex")

        if type(AreaEggCycleAnchorAt) ~= "number" then
            AreaEggCycleAnchorAt = 0
        end

        if type(AreaEggCycleAnchorIndex) ~= "number" then
            AreaEggCycleAnchorIndex = 0
        end

        return math.max(0, AreaEggCycleAnchorIndex + math.floor((v1820 - AreaEggCycleAnchorAt) / 300))
    end
    local function v1204(p287)
        local elapsed11 = os.clock()
        local v1826 = v1203()

        if v1826 ~= u1201 then
            u1201 = v1826
            p287 = true
            u1202 = true
            n30 = 0
            t195 = {}

            if StealState then
                StealState.eggResetAt = os.clock()
                StealState.eggResetN = 0
                StealState.eggResetGrew = 0
            end
        end

        if not p287 and type(t195) == "table" and elapsed11 - n29 < 0.4 then
            return t195
        end

        if not EggState then
            return t195
        end

        local v1827 = EggState.ReadFieldEggs or EggState.SyncFieldEggs

        if type(v1827) ~= "function" then
            return t195
        end

        local ok32, result32, _, _ = pcall(v1827)

        if not ok32 then
            KozuaLog("eggs", "ERR", "ReadFieldEggs", (tostring(result32)))
            result32 = nil
        end

        if type(result32) ~= "table" or type(result32.Records) ~= "table" then
            n29 = elapsed11 - 0.28

            return t195
        end

        local t196 = {}
        local t197 = {}

        for _, v in pairs(result32.Records) do
            if type(v) == "table" and v.Uid and not t197[v.Uid] then
                t197[v.Uid] = true
                t196[#t196 + 1] = v
            end
        end

        if #t196 == 0 and #t195 > 0 and elapsed11 - n30 < 2.5 then
            n29 = elapsed11

            return t195
        end

        t195 = t196
        n29 = elapsed11

        if #t196 > 0 then
            n30 = elapsed11
        end

        if StealState and (StealState.eggResetAt or 0) > 0 and (StealState.eggResetN or 0) < #t196 then
            StealState.eggResetN = #t196
            StealState.eggResetGrew = elapsed11
        end

        return t196
    end
    pcall(function()
        local v1836 = EggState and EggState.FieldRefreshed

        if type(v1836) == "table" and type(v1836.Connect) == "function" then
            local connection10 = v1836:Connect(function()
                local v3127 = type(t195) == "table" and #t195 or 0

                n29 = 0
                n30 = 0
                u1202 = true

                if StealState and v3127 > 6 then
                    StealState.eggResetAt = os.clock()
                    StealState.eggResetN = 0
                    StealState.eggResetGrew = 0
                end
            end)

            if connection10 then
                ConnList[connection10] = true
            end
        end
    end)
    local function v1205(p288, p289)
        local t198 = {}

        for _, v in ipairs(p288) do
            t198[string.lower((tostring(v)))] = true
        end

        local t199 = {}

        for _, v in ipairs(p289) do
            local str19 = tostring(v or "")

            if str19 ~= "" and str19 ~= "nil" and not t198[string.lower(str19)] then
                p288[#p288 + 1] = str19
                t198[string.lower(str19)] = true
                t199[#t199 + 1] = str19
            end
        end

        return t199
    end
    local function v1206(p290, p291)
        if type(p291) ~= "table" or #p291 == 0 then
            return
        end

        local v1849 = Config[p290]

        if type(v1849) ~= "table" then
            return
        end

        local t200 = {}
        local t201 = {}

        for i = 1, #v1849 do
            local str20 = tostring(v1849[i])

            t201[#t201 + 1] = v1849[i]
            t200[str20] = true
        end

        local v1854 = false

        for i = 1, #p291 do
            local str21 = tostring(p291[i])

            if str21 ~= "" and str21 ~= "nil" and not t200[str21] then
                t201[#t201 + 1] = str21
                t200[str21] = true
                v1854 = true
            end
        end

        if not v1854 then
            return
        end

        Config[p290] = t201

        local v1857 = WidgetRegistry[p290]

        if v1857 and v1857.set then
            v1857.set(t201)
        end
    end
    local function v1207(p292, p293, p294)
        local v1861 = WidgetRegistry[p292]
        local v1862 = v1861 and v1861.options

        if type(v1862) ~= "table" then
            return
        end

        local v1863 = Config[p292]

        for i = #v1862, 1, -1 do
            v1862[i] = nil
        end

        for _, v in ipairs(p293) do
            v1862[#v1862 + 1] = v
        end

        for _, v in ipairs(p294) do
            v1862[#v1862 + 1] = v
        end

        if v1861.refresh then
            v1861.refresh()
        end

        if v1863 ~= nil and v1861.set then
            v1861.set(v1863)
        end
    end
    local function SyncGameData()
        if not t202 then
            t202 = {
				a = {},
				r = {},
				m = {},
				adopted = false
			}

            for _, v in ipairs(BiomeList) do
                t202.a[v] = true
            end

            for _, v in ipairs(RarityList) do
                t202.r[v] = true
            end

            for _, v in ipairs(TraitList) do
                t202.m[v] = true
            end
        end

        local t203 = {}
        local t204 = {}
        local t205 = {}

        local function v1878(p295, p296)
            local str22 = tostring(p295 or "")

            if str22 == "" or (str22 == "?" or str22 == "nil" or t205[str22]) then
                return
            end

            t205[str22] = true
            t204[#t204 + 1] = {
				name = str22,
				n = tonumber(p296) or 999
			}
        end

        if type(Directory2) == "table" then
            local t206 = {}

            for k, v in pairs(Directory2) do
                local str23 = tostring(k)
                local n31 = 999

                if type(v) == "table" then
                    str23 = tostring(v.DisplayName or (v._id or k))

                    if type(v.Rarity) == "table" then
                        n31 = tonumber(v.Rarity.RarityNumber) or 999
                        v1878(v.Rarity.DisplayName or (v.Rarity.Name or v.Rarity._id), n31)
                    end
                end

                t206[#t206 + 1] = {
					name = str23,
					n = n31
				}
            end

            table.sort(t206, function(p297, p298)
                if p297.n ~= p298.n then
                    return p297.n < p298.n
                end

                return p297.name < p298.name
            end)

            for _, v in ipairs(t206) do
                t203[#t203 + 1] = v.name
            end
        end

        pcall(function()
            for _, v in ipairs(t195) do
                if type(v) == "table" then
                    if v.AreaId then
                        t203[#t203 + 1] = tostring(v.AreaId)
                    end

                    local AssetCategory = v.AssetCategory
                    local v3136 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil

                    if type(v3136) == "table" and type(v3136.Rarity) == "table" then
                        v1878(v3136.Rarity.DisplayName or (v3136.Rarity.Name or v3136.Rarity._id), v3136.Rarity.RarityNumber)
                    end
                end
            end
        end)

        if type(Directory) == "table" then
            for _, v in pairs(Directory) do
                if type(v) == "table" and type(v.Rarity) == "table" then
                    v1878(v.Rarity.DisplayName or (v.Rarity.Name or v.Rarity._id), v.Rarity.RarityNumber)
                end
            end
        end

        table.sort(t204, function(p299, p300)
            if p299.n ~= p300.n then
                return p299.n < p300.n
            end

            return p299.name < p300.name
        end)

        local t207 = {}

        for _, v in ipairs(t204) do
            t207[#t207 + 1] = v.name
        end

        local t208 = {}

        if type(Directory) == "table" then
            for _, v in pairs(Directory) do
                if type(v) == "table" then
                    if type(v.Mutations) == "table" then
                        for _, v15 in pairs(v.Mutations) do
                            if type(v15) == "string" then
                                t208[#t208 + 1] = v15
                            end
                        end
                    end

                    if type(v.Mutation) == "string" then
                        t208[#t208 + 1] = v.Mutation
                    end
                end
            end
        end

        pcall(function()
            for _, v in ipairs(t195) do
                if type(v) == "table" and type(v.Mutations) == "table" then
                    for _, v16 in ipairs(v.Mutations) do
                        t208[#t208 + 1] = tostring(v16)
                    end
                end
            end
        end)

        local v1896 = v1205(BiomeList, t203)
        local v1897 = v1205(RarityList, t207)
        local v1898 = v1205(TraitList, t208)
        local t209 = {
			common = 1,
			uncommon = 2,
			rare = 3,
			epic = 4,
			legendary = 5,
			mythic = 6,
			cosmic = 7,
			secret = 8,
			eternal = 9,
			divine = 10,
			titan = 11
		}
        local t210 = {}

        for i = 1, #t204 do
            local v1902 = t204[i]

            if v1902 and v1902.name then
                t210[string.lower(v1902.name)] = tonumber(v1902.n) or 999
            end
        end

        table.sort(RarityList, function(p301, p302)
            local v3145 = string.lower((tostring(p301)))
            local v3146 = string.lower((tostring(p302)))
            local v3147 = t209[v3145] or 100 + (t210[v3145] or 999)
            local v3148 = t209[v3146] or 100 + (t210[v3146] or 999)

            if v3147 ~= v3148 then
                return v3147 < v3148
            end

            return tostring(p301) < tostring(p302)
        end)

        if #v1896 > 0 then
            KozuaLog("modules", "new zones", table.concat(v1896, ", "), "·", #BiomeList, "total")
        end

        if #v1897 > 0 then
            KozuaLog("modules", "new rarities", table.concat(v1897, ", "))
        end

        if #v1898 > 0 then
            KozuaLog("modules", "new mutations", table.concat(v1898, ", "))
        end

        pcall(function()
            local t211 = {}
            local t212 = {}
            local t213 = {}

            if not t202.adopted then
                t202.adopted = true

                for _, v in ipairs(BiomeList) do
                    if not t202.a[v] then
                        t211[#t211 + 1] = v
                    end
                end

                for _, v in ipairs(RarityList) do
                    if not t202.r[v] then
                        t212[#t212 + 1] = v
                    end
                end

                for _, v in ipairs(TraitList) do
                    if not t202.m[v] then
                        t213[#t213 + 1] = v
                    end
                end
            else
                t211 = v1896
                t212 = v1897
                t213 = v1898
            end

            pcall(v1206, "Areas", t211)
            pcall(v1206, "Rarities", t212)
            pcall(v1206, "Mutations", t213)
            pcall(v1207, "HookRarityFloor", { "Any" }, RarityList)
            pcall(v1207, "NeverPlaceRarity", { "place everything" }, RarityList)

            for _, v in ipairs({
				"Areas",
				"Rarities",
				"Mutations"
			}) do
                local v3160 = WidgetRegistry[v]

                if v3160 and v3160.refresh then
                    pcall(v3160.refresh)
                end
            end
        end)
    end
    --[[Inner opener restores truncated v1209 header (original line 10999: local function v1209(p303))]]
    local function PlotBottomPos(PlotRecord)
        local BottomCFrame = PlotRecord.BottomCFrame
        local VarV1905

        if BottomCFrame == nil then
            VarV1905 = nil
        else
            local Num32 = 4
            local Ok33, Ret33 = pcall(function()
                if typeof(BottomCFrame) == "Vector3" then
                    return Num32 and BottomCFrame + Vector3.new(0, Num32, 0) or BottomCFrame
                end

                if Num32 then
                    return BottomCFrame.Position + Vector3.new(0, Num32, 0)
                end

                return BottomCFrame.Position
            end)

            VarV1905 = if not Ok33 then nil else Ret33
        end

        if not VarV1905 then
            local BoundsCFrame = PlotRecord.BoundsCFrame

            if BoundsCFrame == nil then
                VarV1905 = nil
            else
                local Num33 = 0
                local Ok34, Ret34 = pcall(function()
                    if typeof(BoundsCFrame) == "Vector3" then
                        return Num33 and BoundsCFrame + Vector3.new(0, Num33, 0) or BoundsCFrame
                    end

                    if Num33 then
                        return BoundsCFrame.Position + Vector3.new(0, Num33, 0)
                    end

                    return BoundsCFrame.Position
                end)

                VarV1905 = if not Ok34 then nil else Ret34
            end

            if not VarV1905 then
                local p303CFrame = PlotRecord.CFrame

                if p303CFrame == nil then
                    VarV1905 = nil
                else
                    local Num34 = 0
                    local Ok35, Ret35 = pcall(function()
                        if typeof(p303CFrame) == "Vector3" then
                            return Num34 and p303CFrame + Vector3.new(0, Num34, 0) or p303CFrame
                        end

                        if Num34 then
                            return p303CFrame.Position + Vector3.new(0, Num34, 0)
                        end

                        return p303CFrame.Position
                    end)

                    VarV1905 = if not Ok35 then nil else Ret35
                end

                if not VarV1905 then
                    local WorldCFrame = PlotRecord.WorldCFrame

                    if WorldCFrame == nil then
                        VarV1905 = nil
                    else
                        local Num35 = 0
                        local Ok36, Ret36 = pcall(function()
                            if typeof(WorldCFrame) == "Vector3" then
                                return Num35 and WorldCFrame + Vector3.new(0, Num35, 0) or WorldCFrame
                            end

                            if Num35 then
                                return WorldCFrame.Position + Vector3.new(0, Num35, 0)
                            end

                            return WorldCFrame.Position
                        end)

                        VarV1905 = if not Ok36 then nil else Ret36
                    end

                    if not VarV1905 then
                        local PivotCFrame = PlotRecord.PivotCFrame

                        if PivotCFrame == nil then
                            VarV1905 = nil
                        else
                            local Num36 = 0
                            local Ok37, Ret37 = pcall(function()
                                if typeof(PivotCFrame) == "Vector3" then
                                    return Num36 and PivotCFrame + Vector3.new(0, Num36, 0) or PivotCFrame
                                end

                                if Num36 then
                                    return PivotCFrame.Position + Vector3.new(0, Num36, 0)
                                end

                                return PivotCFrame.Position
                            end)

                            VarV1905 = if not Ok37 then nil else Ret37
                        end

                        if not VarV1905 then
                            local p303Position = PlotRecord.Position

                            if p303Position == nil then
                                return nil
                            end

                            local Num37 = 4
                            local Ok38, Ret38 = pcall(function()
                                if typeof(p303Position) == "Vector3" then
                                    return Num37 and p303Position + Vector3.new(0, Num37, 0) or p303Position
                                end

                                if Num37 then
                                    return p303Position.Position + Vector3.new(0, Num37, 0)
                                end

                                return p303Position.Position
                            end)

                            if Ok38 then
                                return Ret38
                            end

                            VarV1905 = nil
                        end
                    end
                end
            end
        end

        return VarV1905
    end
    local Num38 = 0
    local VarU1211
    local function PlotInRadius(CheckPos)
        if typeof(CheckPos) ~= "Vector3" then
            return false
        end

        local Clock12 = os.clock()

        if not VarU1211 or Clock12 - Num38 > 2 then
            local Tab214 = {}
            local Plots = workspace:FindFirstChild("Plots")

            if Plots then
                for _, child in ipairs(Plots:GetChildren()) do
                    local VarV1935 = child:FindFirstChild("CenterPoint", true) or child:FindFirstChild("SpawnPoint", true)

                    if VarV1935 and VarV1935:IsA("BasePart") then
                        Tab214[#Tab214 + 1] = {
							pos = VarV1935.Position,
							r = 48
						}
                    else
                        local Ok39, Ret39 = pcall(function()
                            return child:GetPivot()
                        end)

                        if Ok39 and typeof(Ret39) == "CFrame" then
                            Tab214[#Tab214 + 1] = {
								pos = Ret39.Position,
								r = 48
							}
                        end
                    end
                end
            end

            VarU1211 = Tab214
            Num38 = Clock12
        end

        for i = 1, #VarU1211 do
            local VarV1939 = VarU1211[i]

            if Vector3.new(CheckPos.X - VarV1939.pos.X, 0, CheckPos.Z - VarV1939.pos.Z).Magnitude <= VarV1939.r then
                return true
            end
        end

        return false
    end
    local function PlotIsOwnedPlaced(EggRec, EggPos)
        if type(EggRec) ~= "table" then
            return false
        end

        if EggRec.Placement ~= nil then
            return true
        end

        if EggRec.OwnerUserId and EggRec.State ~= "Dropped" then
            return true
        end

        local VarV1942 = string.lower((tostring(EggRec.Uid or "")))

        if VarV1942:find("plot", 1, true) or VarV1942:find(":pen", 1, true) or VarV1942:find("hatch", 1, true) then
            return true
        end

        if EggRec.State == "Slot" or EggRec.State == "Dropped" then
            return false
        end

        if typeof(EggPos) ~= "Vector3" then
            EggPos = PlotBottomPos(EggRec)
        end

        return (PlotInRadius(EggPos))
    end
    local function PlotHasParasite(EggRecCheck)
        if type(EggRecCheck) ~= "table" then
            return false
        end

        if EggRecCheck.HasParasite == true then
            return true
        end

        local BaseMutation = EggRecCheck.BaseMutation
        local VarV1945 = string.lower((tostring(BaseMutation or "")))

        if VarV1945 == "monstrous" or (VarV1945 == "parasite" or VarV1945:find("infest", 1, true) ~= nil) then
            return true
        end

        local Mutations = EggRecCheck.Mutations

        if type(Mutations) ~= "table" and type(EggRecCheck.ItemData) == "table" then
            Mutations = EggRecCheck.ItemData.Mutations
        end

        if type(Mutations) == "table" then
            for _, v in ipairs(Mutations) do
                local VarV1949 = string.lower((tostring(v or "")))

                if VarV1949 == "monstrous" or (VarV1949 == "parasite" or VarV1949:find("infest", 1, true) ~= nil) then
                    return true
                end
            end
        end

        return false
    end
    local function PlotPassesFilter(FilterRec, FilterCfg, FilterBypass)
        local StrId24 = tostring(FilterRec.AreaId or "")
        local VarV1954 = v1196(Config.Areas)

        if next(VarV1954) and not if next(VarV1954) then VarV1954[string.lower((tostring(StrId24 or "")))] == true else false then
            return false
        end

        if FilterBypass then
            return true
        end

        if Config.UseRarity then
            local VarV1955 = v1196(Config.Rarities)

            if next(VarV1955) then
                local VarV1956 = if type(FilterCfg) == "table" and type(FilterCfg.Rarity) == "table" then tostring(FilterCfg.Rarity.DisplayName or (FilterCfg.Rarity.Name or (FilterCfg.Rarity._id or "?"))) else "?"

                if not if next(VarV1955) then VarV1955[string.lower((tostring(VarV1956 or "")))] == true else false then
                    return false
                end
            end
        end

        if Config.UseMutation then
            local VarV1957 = v1196(Config.Mutations)

            if next(VarV1957) then
                local VarV1958 = false

                if type(FilterRec.Mutations) == "table" then
                    for _, v in ipairs(FilterRec.Mutations) do
                        if if next(VarV1957) then VarV1957[string.lower((tostring(v or "")))] == true else false then
                            VarV1958 = true

                            break
                        end
                    end
                end

                if not VarV1958 then
                    return false
                end
            end
        end

        local num = tonumber(Config.MinWeight)

        if num and num > 0 and FilterCfg and tonumber(FilterCfg.ModelWeight) and num > FilterCfg.ModelWeight then
            return false
        end

        return true
    end
    local function CollectStealTargets()
        local VarV1965 = v1204()
        local VarV1966 = Config.StealMode or "Best value"

        local function Steal_Fn_1967(StealCandidate)
            if type(StealCandidate) ~= "table" or not StealCandidate.Uid then
                return
            end

            local num = tonumber(StealCandidate and StealCandidate.CarrierUserId)

            if num and (num ~= 0 and num ~= LocalPlayer.UserId) then
                return
            end

            local State = StealCandidate.State

            if State ~= "Slot" and State ~= "Dropped" then
                return
            end

            local AssetCategory = StealCandidate.AssetCategory
            local VarV3173 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
            local VarV3174 = PlotBottomPos(StealCandidate)

            if not VarV3174 or PlotIsOwnedPlaced(StealCandidate, VarV3174) then
                return
            end

            return {
				rec = StealCandidate,
				cfg = VarV3173,
				pos = VarV3174,
				earn = v1193(StealCandidate, VarV3173),
				rar = if type(VarV3173) == "table" and type(VarV3173.Rarity) == "table" then tonumber(VarV3173.Rarity.RarityNumber) or 0 else 0,
				infested = PlotHasParasite(StealCandidate),
				name = VarV3173 and (VarV3173.DisplayName or StealCandidate.AssetCategory) or tostring(StealCandidate.AssetCategory),
				area = tostring(StealCandidate.AreaId or "")
			}
        end

        local VarV1968 = StealState.lockUid or StealState.heldUid

        if type(VarV1968) == "string" then
            local VarV1969
            for _, v in ipairs(VarV1965) do
                if type(v) == "table" and VarV1968 == v.Uid then
                    VarV1969 = Steal_Fn_1967(v)

                    break
                end
            end
            if VarV1969 then
                local rec = VarV1969.rec
                local VarV1973 = PlotPassesFilter(rec, VarV1969.cfg)

                if VarV1973 then
                    local cfg = VarV1969.cfg

                    if (Config.StealMode or "Best value") == "Gen ($/s) snipe" then
                        local VarV1975 = v1194(Config.GenSnipeFloor)

                        VarV1973 = not (VarV1975 > 0) or not (VarV1975 > v1193(rec, cfg))
                    else
                        VarV1973 = true
                    end
                end

                local VarV1976 = rec and rec.State == "Dropped"

                if VarV1973 or VarV1976 then
                    VarV1969.matched = true

                    if typeof(VarV1969.pos) == "Vector3" then
                        StealState.lockPos = VarV1969.pos
                        StealState.lockAt = os.clock()
                    end

                    return VarV1969
                end

                StealState.lockUid = nil
                StealState.lockPos = nil
            else
                if typeof(StealState.lockPos) == "Vector3" and os.clock() - (StealState.lockAt or 0) < 5 then
                    return {
						rec = {
							Uid = VarV1968,
							State = "Dropped"
						},
						pos = StealState.lockPos,
						name = StealState.target and StealState.target.name or "egg",
						area = StealState.target and StealState.target.area or "",
						matched = true,
						event = StealState.eventFromField == true
					}
                end

                StealState.lockUid = nil

                if VarV1968 == StealState.heldUid then
                    StealState.heldUid = nil
                end

                if StealState.target and StealState.target.rec and VarV1968 == StealState.target.rec.Uid then
                    StealState.target = nil
                end
            end
        end

        local Tab215 = {}

        for _, v in ipairs(VarV1965) do
            if type(v) == "table" then
                local VarV1980 = Steal_Fn_1967(v)

                if VarV1980 then
                    local VarV1981 = PlotPassesFilter(v, VarV1980.cfg)

                    if VarV1981 then
                        local cfg = VarV1980.cfg

                        if (Config.StealMode or "Best value") == "Gen ($/s) snipe" then
                            local VarV1983 = v1194(Config.GenSnipeFloor)

                            VarV1981 = not (VarV1983 > 0) or not (VarV1983 > v1193(v, cfg))
                        else
                            VarV1981 = true
                        end
                    end

                    local VarV1984 = false

                    if Config.AutoEvent == true then
                        VarV1984 = false

                        if VarV1980.infested == true then
                            local _ = VarV1980.cfg
                            local StrId25 = tostring(v.AreaId or "")
                            local VarV1987 = v1196(Config.Areas)

                            VarV1984 = not next(VarV1987) or (((if next(VarV1987) then VarV1987[string.lower((tostring(StrId25 or "")))] == true else false)) and true or false)
                        end
                    end

                    if VarV1984 then
                        local VarV1988 = v1194(Config.EventKeepGen)

                        if VarV1988 > 0 and VarV1988 <= (VarV1980.earn or 0) then
                            VarV1984 = false
                        end
                    end

                    if VarV1984 then
                        VarV1980.matched = false
                        VarV1980.event = true
                        Tab215[#Tab215 + 1] = VarV1980
                    elseif VarV1981 then
                        VarV1980.matched = true
                        VarV1980.event = false
                        Tab215[#Tab215 + 1] = VarV1980
                    end
                end
            end
        end

        table.sort(Tab215, function(Arg312, Arg313)
            if Arg312.matched ~= Arg313.matched then
                return Arg312.matched == true
            end

            if VarV1966 == "Egg type filter" or VarV1966 == "Rarity snipe" then
                if Arg312.rar ~= Arg313.rar then
                    return Arg312.rar > Arg313.rar
                end

                if Arg312.earn ~= Arg313.earn then
                    return Arg312.earn > Arg313.earn
                end
            else
                if Arg312.earn ~= Arg313.earn then
                    return Arg312.earn > Arg313.earn
                end

                if Arg312.rar ~= Arg313.rar then
                    return Arg312.rar > Arg313.rar
                end
            end

            return Arg312.name < Arg313.name
        end)

        return Tab215[1]
    end
    local function ResolvePlotSpawn()
        local VarU1989
        pcall(function()
            VarU1989 = require(ReplicatedStorage.Client.PlotState).ResolvePlot()
        end)
        if type(VarU1989) == "table" and VarU1989.PlotFolder then
            local PlotFolder = VarU1989.PlotFolder
            local CenterPoint = VarU1989.CenterPoint
            local RespawnPointCFrame = VarU1989.RespawnPointCFrame

            if typeof(RespawnPointCFrame) == "CFrame" then
                return RespawnPointCFrame.Position + Vector3.new(0, 4, 0), RespawnPointCFrame, PlotFolder, CenterPoint
            end

            local SpawnPoint = PlotFolder:FindFirstChild("SpawnPoint", true)

            if SpawnPoint and SpawnPoint:IsA("BasePart") then
                return SpawnPoint.Position + Vector3.new(0, 4, 0), SpawnPoint.CFrame, PlotFolder, CenterPoint
            end

            return PlotFolder:GetPivot().Position, PlotFolder:GetPivot(), PlotFolder, CenterPoint
        end
        local Plots = workspace:FindFirstChild("Plots")
        if not Plots then
            return
        end
        for _, child in ipairs(Plots:GetChildren()) do
            local VarV1997 = false

            for _, descendant in ipairs(child:GetDescendants()) do
                if descendant:IsA("TextLabel") and string.find(descendant.Text, LocalPlayer.Name, 1, true) then
                    VarV1997 = true

                    break
                end
            end

            if VarV1997 then
                local SpawnPoint = child:FindFirstChild("SpawnPoint", true)
                local CenterPoint = child:FindFirstChild("CenterPoint", true)

                if SpawnPoint and SpawnPoint:IsA("BasePart") then
                    return SpawnPoint.Position + Vector3.new(0, 4, 0), SpawnPoint.CFrame, child, CenterPoint
                end

                return child:GetPivot().Position, child:GetPivot(), child, CenterPoint
            end
        end
        if EggState and type(EggState.ReadOwnedEggs) == "function" then
            local Ok40, Ret40 = pcall(EggState.ReadOwnedEggs)

            if Ok40 and type(Ret40) == "table" then
                for k, v in pairs(Ret40) do
                    if type(v) ~= "table" or tonumber(v.OwnerUserId) ~= LocalPlayer.UserId then
                        continue
                    end

                    local VarV2006 = Plots:FindFirstChild((tostring(k)))

                    if VarV2006 then
                        local SpawnPoint = VarV2006:FindFirstChild("SpawnPoint", true)
                        local CenterPoint = VarV2006:FindFirstChild("CenterPoint", true)

                        if SpawnPoint and SpawnPoint:IsA("BasePart") then
                            return SpawnPoint.Position + Vector3.new(0, 4, 0), SpawnPoint.CFrame, VarV2006, CenterPoint
                        end

                        return VarV2006:GetPivot().Position, VarV2006:GetPivot(), VarV2006, CenterPoint
                    end
                end
            end
        end
    end
    local function IsAtOwnPlot(PlotPos)
        if typeof(PlotPos) ~= "Vector3" then
            return false
        end
        local _, _, VarV2012, VarV2013 = ResolvePlotSpawn()
        local Position2
        if VarV2013 and typeof(VarV2013) == "Instance" and VarV2013:IsA("BasePart") then
            Position2 = VarV2013.Position
        elseif VarV2012 then
            local VarV2015 = VarV2012:FindFirstChild("CenterPoint", true) or VarV2012:FindFirstChild("SpawnPoint", true)

            if VarV2015 and VarV2015:IsA("BasePart") then
                Position2 = VarV2015.Position
            else
                pcall(function()
                    Position2 = VarV2012:GetPivot().Position
                end)
            end
        end
        if typeof(Position2) ~= "Vector3" then
            return false
        end

        return Vector3.new(PlotPos.X - Position2.X, 0, PlotPos.Z - Position2.Z).Magnitude <= 56
    end
    local function ResolveSpawnFallback()
        local SpawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")

        if SpawnLocation and SpawnLocation:IsA("BasePart") then
            return SpawnLocation.Position + Vector3.new(0, 4, 0), SpawnLocation.CFrame, SpawnLocation
        end

        local SpawnTarget = workspace:FindFirstChild("SpawnTarget", true)

        if SpawnTarget and SpawnTarget:IsA("BasePart") then
            return SpawnTarget.Position + Vector3.new(0, 4, 0), SpawnTarget.CFrame, SpawnTarget
        end

        return ResolvePlotSpawn()
    end
    local function FindTreadmillBottom(BeltSearchPos)
        if typeof(BeltSearchPos) ~= "Vector3" then
            BeltSearchPos = Vector3.zero
        end
        local VarU2020
        local VarU2021
        local function Fn_2022(BeltPart)
            if not BeltPart or not BeltPart:IsA("BasePart") then
                return
            end

            local VarV3178 = string.lower(BeltPart.Name)
            local VarV3179 = BeltPart.Parent and string.lower(BeltPart.Parent.Name) or ""
            local VarV3180 = VarV3178:find("treadmill", 1, true) or (VarV3178:find("belt", 1, true) or (VarV3179:find("treadmill", 1, true) or VarV3179:find("belt", 1, true)))

            if not VarV3180 and VarV3178 ~= "bottom" then
                return
            end

            if VarV3178 == "bottom" and not VarV3180 then
                return
            end

            local Magnitude = (BeltPart.Position - BeltSearchPos).Magnitude

            if not VarU2021 or Magnitude < VarU2021 then
                VarU2020 = BeltPart
                VarU2021 = Magnitude
            end
        end
        pcall(function()
            local _, _, VarV3184 = ResolvePlotSpawn()

            if VarV3184 then
                Fn_2022(VarV3184:FindFirstChild("TreadmillBottom", true))

                for _, descendant in ipairs(VarV3184:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        Fn_2022(descendant)
                    end
                end
            end
        end)
        local VarV2023 = select(1, ResolvePlotSpawn())
        local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
        if __ClientTreadmillRenders then
            for _, descendant in ipairs(__ClientTreadmillRenders:GetDescendants()) do
                if descendant:IsA("BasePart") and typeof(VarV2023) == "Vector3" and (descendant.Position - VarV2023).Magnitude < 90 then
                    Fn_2022(descendant)
                end
            end
        end

        return VarU2020
    end
    local function FindPenPad(Arg317)
        local VarU2028
        local VarU2029
        local VarU2030
        local VarU2031
        local Num39 = 0
        local Num40 = 0
        local function Fn_2034(Arg318)
            if not Arg318 or not Arg318:IsA("BasePart") then
                return
            end

            local VarV3188 = string.lower(Arg318.Name)
            local VarV3189 = Arg318.Parent and string.lower(Arg318.Parent.Name) or ""

            if not VarV3188:find("treadmill", 1, true) and not VarV3188:find("belt", 1, true) and not VarV3189:find("treadmill", 1, true) and not VarV3189:find("belt", 1, true) and VarV3188 ~= "treadmillbottom" then
                return
            end

            local p318CFrame = Arg318.CFrame
            local p318Size = Arg318.Size
            local VarV3192 = p318Size.X * 0.5
            local VarV3193 = p318Size.Z * 0.5
            local VarV3194 = math.abs(p318CFrame.RightVector.X) * VarV3192 + math.abs(p318CFrame.LookVector.X) * VarV3193 + math.abs(p318CFrame.UpVector.X) * (p318Size.Y * 0.5)
            local VarV3195 = math.abs(p318CFrame.RightVector.Z) * VarV3192 + math.abs(p318CFrame.LookVector.Z) * VarV3193 + math.abs(p318CFrame.UpVector.Z) * (p318Size.Y * 0.5)
            local PositionX = p318CFrame.Position.X
            local PositionZ = p318CFrame.Position.Z

            VarU2028 = VarU2028 and math.min(VarU2028, PositionX - VarV3194) or PositionX - VarV3194
            VarU2029 = VarU2029 and math.max(VarU2029, PositionX + VarV3194) or PositionX + VarV3194
            VarU2030 = VarU2030 and math.min(VarU2030, PositionZ - VarV3195) or PositionZ - VarV3195
            VarU2031 = VarU2031 and math.max(VarU2031, PositionZ + VarV3195) or PositionZ + VarV3195
            Num39 += p318CFrame.Position.Y
            Num40 += 1
        end
        pcall(function()
            local _, _, VarV3200 = ResolvePlotSpawn()

            if VarV3200 then
                Fn_2034(VarV3200:FindFirstChild("TreadmillBottom", true))

                for _, descendant in ipairs(VarV3200:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        Fn_2034(descendant)
                    end
                end
            end
        end)
        local VarV2035 = select(1, ResolvePlotSpawn())
        local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
        if __ClientTreadmillRenders then
            for _, descendant in ipairs(__ClientTreadmillRenders:GetDescendants()) do
                if descendant:IsA("BasePart") and (typeof(VarV2035) ~= "Vector3" or (descendant.Position - VarV2035).Magnitude < 90) then
                    Fn_2034(descendant)
                end
            end
        end
        local VarV2039 = FindTreadmillBottom(Arg317)
        if VarV2039 then
            Fn_2034(VarV2039)
        end
        if Num40 == 0 or not VarU2028 then
            return
        end

        return {
			cx = (VarU2028 + VarU2029) * 0.5,
			cz = (VarU2030 + VarU2031) * 0.5,
			hx = (VarU2029 - VarU2028) * 0.5,
			hz = (VarU2031 - VarU2030) * 0.5,
			y = Num39 / Num40
		}
    end
    local function PlotScanNests(Arg319, Arg320, Arg321)
        if not Arg319 or typeof(Arg320) ~= "Vector3" then
            return false
        end

        local VarV2043 = Arg321 or 0

        return math.abs(Arg320.X - Arg319.cx) <= Arg319.hx + VarV2043 and math.abs(Arg320.Z - Arg319.cz) <= Arg319.hz + VarV2043
    end
    local function ResolveOwnPlot(Arg322, Arg323, Arg324, Arg325)
        if not Arg322 or (typeof(Arg323) ~= "Vector3" or typeof(Arg324) ~= "Vector3") then
            return false
        end

        local VarV2048 = Arg325 or 0
        local p323X = Arg323.X
        local p323Z = Arg323.Z
        local p324X = Arg324.X
        local p324Z = Arg324.Z
        local VarV2053 = Arg322.cx - Arg322.hx - VarV2048
        local VarV2054 = Arg322.cx + Arg322.hx + VarV2048
        local VarV2055 = Arg322.cz - Arg322.hz - VarV2048
        local VarV2056 = Arg322.cz + Arg322.hz + VarV2048

        if p323X < VarV2053 and p324X < VarV2053 or VarV2054 < p323X and VarV2054 < p324X or p323Z < VarV2055 and p324Z < VarV2055 or VarV2056 < p323Z and VarV2056 < p324Z then
            return false
        end

        if PlotScanNests(Arg322, Arg323, VarV2048) or PlotScanNests(Arg322, Arg324, VarV2048) then
            return true
        end

        local VarV2057 = p324X - p323X
        local VarV2058 = p324Z - p323Z

        for i = 1, 8 do
            local VarV2060 = i / 9
            local vector3 = Vector3.new(p323X + VarV2057 * VarV2060, 0, p323Z + VarV2058 * VarV2060)

            if PlotScanNests(Arg322, vector3, VarV2048) then
                return true
            end
        end

        return false
    end
    local function IsInPlotBounds(Arg326, Arg327)
        if typeof(Arg326) ~= "Vector3" then
            return Arg327
        end

        local VarV2066 = select(1, ResolveSpawnFallback())
        local VarV2067 = select(1, ResolvePlotSpawn())
        local VarV2068 = FindPenPad(Arg326)
        local VarV2069 = VarV2068 and PlotScanNests(VarV2068, Arg326, 12)
        local VarV2070 = VarV2068 and (typeof(Arg327) == "Vector3" and ResolveOwnPlot(VarV2068, Arg326, Arg327, 8))

        if VarV2066 and Vector3.new(VarV2066.X - Arg326.X, 0, VarV2066.Z - Arg326.Z).Magnitude <= 62 then
            return Arg327
        end

        if not IsAtOwnPlot(Arg326) and not VarV2069 and not VarV2070 then
            return Arg327
        end

        if typeof(VarV2066) ~= "Vector3" then
            return Arg327
        end

        local VarV2071 = VarV2068 and Vector3.new(VarV2068.cx, Arg326.Y, VarV2068.cz) or (typeof(VarV2067) == "Vector3" and VarV2067 or Arg326)
        local vector3 = Vector3.new(VarV2066.X - VarV2071.X, 0, VarV2066.Z - VarV2071.Z)

        if vector3.Magnitude < 2 then
            vector3 = Vector3.new(VarV2066.X - Arg326.X, 0, VarV2066.Z - Arg326.Z)
        end

        if vector3.Magnitude < 0.1 then
            return Arg327
        end

        local Unit = vector3.Unit

        if Vector3.new(Arg326.X - VarV2071.X, 0, Arg326.Z - VarV2071.Z):Dot(Unit) > 18 and not VarV2069 then
            return Arg327
        end

        local p326Y = Arg326.Y
        local vector3_6 = Vector3.new(VarV2071.X + Unit.X * 32, p326Y, VarV2071.Z + Unit.Z * 32)

        if Vector3.new(Arg326.X - vector3_6.X, 0, Arg326.Z - vector3_6.Z).Magnitude < 12 then
            return Arg327
        end

        return vector3_6
    end
    local function PickTravelDest(Arg328, Arg329, Arg330)
        if typeof(Arg328) ~= "Vector3" then
            return Arg328
        end

        if typeof(Arg329) ~= "Vector3" then
            return Arg328
        end

        local VarV2079 = select(1, ResolveSpawnFallback())

        if VarV2079 and Vector3.new(VarV2079.X - Arg329.X, 0, VarV2079.Z - Arg329.Z).Magnitude <= 62 then
            Arg330 = true
        end

        if Arg330 then
            return Arg328
        end

        local VarV2080 = FindPenPad(Arg329)
        local VarV2081 = IsAtOwnPlot(Arg329) or (VarV2080 and PlotScanNests(VarV2080, Arg329, 12) or VarV2080 and ResolveOwnPlot(VarV2080, Arg329, Arg328, 8))

        if IsFlying() then
            return Arg328
        end

        if VarV2081 then
            return (IsInPlotBounds(Arg329, Arg328))
        end

        return Arg328
    end
    local function IsInSafeZone(Arg331)
        local VarV2083 = select(1, ResolveSpawnFallback())

        if typeof(VarV2083) ~= "Vector3" then
            return VarV2083, VarV2083
        end

        if typeof(Arg331) ~= "Vector3" then
            return VarV2083, VarV2083
        end

        if IsFlying() then
            return Vector3.new(VarV2083.X, Arg331.Y, VarV2083.Z), VarV2083
        end

        return IsInPlotBounds(Arg331, VarV2083), VarV2083
    end
    StealState = {
		state = "Idle",
		since = 0,
		target = nil,
		hookSnap = nil,
		carrying = false,
		carryUid = nil,
		heldUid = nil,
		countedUid = nil,
		banked = 0,
		lost = 0,
		regrabs = 0,
		lastGrab = 0,
		lastBankTry = 0,
		lastBankAt = 0,
		lastErrAt = 0,
		lockUid = nil,
		lockPos = nil,
		lockAt = 0,
		haltUntil = 0,
		running = false,
		conn = nil,
		pendingCarry = nil,
		lastPos = nil,
		stillFor = 0,
		bat = nil,
		fed = 0,
		chests = 0,
		eventUid = nil,
		eventFromField = false,
		lastFeed = 0,
		lastChestTake = 0,
		feedLockUntil = 0,
		feedWasWait = false,
		eventSkip = {}
	}
    function StealState.wallUp()
        local resetWall = StealState.resetWall

        if resetWall == nil then
            local Ok41, Ret41 = pcall(require, ReplicatedStorage.Client.AreaEggResetWall)

            StealState.resetWall = not not Ok41 and (type(Ret41) == "table" and (Ret41 or false))
            resetWall = StealState.resetWall
        end

        local Clock13 = os.clock()
        local VarV2088 = false

        if type(resetWall) == "table" and type(resetWall.IsSealed) == "function" then
            local Ok42, Ret42 = pcall(resetWall.IsSealed)

            VarV2088 = Ok42 and Ret42 == true
        end

        if VarV2088 then
            StealState.wallSealedAt = Clock13

            return true
        end

        local Num41 = 0.5

        if type(resetWall) == "table" then
            local num = tonumber(resetWall.CollapseSeconds)

            if num and num > 0 then
                Num41 = math.clamp(num, 0.15, 2)
            end
        end

        local VarV2093 = StealState.wallSealedAt or 0

        if VarV2093 > 0 and Clock13 - VarV2093 < Num41 + 0.12 then
            return true
        end

        if VarV2093 > 0 then
            StealState.wallSealedAt = 0
        end

        local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
        local VarV2095 = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
        local VarV2096 = VarV2095 and VarV2095:FindFirstChild("WallStartVisual")

        if VarV2096 and VarV2096:IsA("BasePart") and VarV2096.Transparency < 0.85 then
            local SizeY = VarV2096.Size.Y
            local wallRestY = StealState.wallRestY

            if wallRestY == nil or wallRestY > SizeY + 0.05 then
                StealState.wallRestY = SizeY
                wallRestY = SizeY
            end

            if SizeY > wallRestY + 3 then
                return true
            end
        end

        return false
    end
    StealState.bat = (function()
        local Num42 = 0
        local Num43 = 0
        local Num44 = 0
        local Num45 = 17
        local State18 = "IsBat"
        local VarU2104
        local VarU2105
        pcall(function()
            local VarV3203 = RequireShared({
				"Modules",
				"BatController",
				"Config"
			})

            if type(VarV3203) == "table" then
                Num45 = (tonumber(VarV3203.Range) or 15) + (tonumber(VarV3203.HitTolerance) or 2)

                if type(VarV3203.GetHitboxScalar) == "function" then
                    local Ok43, Ret43 = pcall(VarV3203.GetHitboxScalar)

                    if Ok43 and type(Ret43) == "number" and Ret43 > 0 then
                        Num45 *= Ret43
                    end
                end
            end
        end)
        pcall(function()
            local Sakura = require(ReplicatedStorage.Data.Sakura)

            if type(Sakura) == "table" and type(Sakura.BatToolAttribute) == "string" then
                State18 = Sakura.BatToolAttribute
            end
        end)
        local function BatCharParts(BatPlayer)
            local VarV3209 = BatPlayer and BatPlayer.Character

            if not VarV3209 then
                return
            end

            local HumanoidRootPart = VarV3209:FindFirstChild("HumanoidRootPart")
            local Humanoid = VarV3209:FindFirstChildOfClass("Humanoid")

            if HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
                return HumanoidRootPart, Humanoid, VarV3209
            end
        end
        local function BatHasTool(Arg333)
            if not Arg333 then
                return
            end

            for _, child in ipairs(Arg333:GetChildren()) do
                if child:IsA("Tool") and child:GetAttribute(State18) == true then
                    return child
                end
            end
        end
        local function BatEnsureTool()
            return BatHasTool(LocalPlayer.Character)
        end
        local function BatAutoEquip()
            local VarV3215 = BatHasTool(LocalPlayer.Character)

            if VarV3215 then
                return VarV3215
            end

            if not Config.BatAura or not Config.AutoSteal or StealState.carrying then
                return
            end

            local Clock14 = os.clock()

            if Clock14 - Num44 < 0.35 then
                return
            end

            Num44 = Clock14

            local VarV3217 = BatHasTool(LocalPlayer:FindFirstChild("Backpack"))

            if not VarV3217 then
                return
            end

            local VarV3218 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

            if not VarV3218 then
                return
            end

            pcall(function()
                VarV3218:EquipTool(VarV3217)
            end)

            return BatEnsureTool()
        end
        local function BatRangeCalc()
            Num42 += 1

            return string.format("%d:%d:%d", LocalPlayer.UserId, Num42, math.floor(workspace:GetServerTimeNow() * 1000))
        end
        local function BatSwingAt(BatTarget)
            if not Config.BatAura or (not BatTarget or BatTarget == LocalPlayer) then
                return false
            end

            local Clock15 = os.clock()

            if Clock15 - Num43 < 0.7 then
                return false
            end

            local VarV3221 = select(1, BatCharParts(LocalPlayer))
            local VarV3222 = select(1, BatCharParts(BatTarget))

            if not VarV3221 or not VarV3222 then
                return false
            end

            if (VarV3221.Position - VarV3222.Position).Magnitude > Num45 then
                return false
            end

            if not BatAutoEquip() and not BatHasTool(LocalPlayer.Character) then
                return false
            end

            local VarV3223

            if VarU2104 and VarU2104.Parent then
                VarV3223 = VarU2104
            else
                local VarV3224 = RequireShared({ "Remotes" })

                VarU2104 = VarV3224 and UnwrapRemote(VarV3224.BatSwing and VarV3224.BatSwing.Trigger)
                VarV3223 = VarU2104
            end

            local VarV3225 = VarV3223

            if not VarV3225 then
                return false
            end

            Num43 = Clock15
            pcall(function()
                VarV3225:FireServer(BatTarget, BatRangeCalc())
            end)

            return true
        end
        local function BatFindTarget(BatFromPos)
            local Tab217 = {}
            local VarU3228 = StealState.running and (StealState.target and tonumber(StealState.target.carrier))
            pcall(function()
                for _, v in ipairs((v1204())) do
                    if type(v) == "table" and v.State == "Carried" then
                        local num = tonumber(v.CarrierUserId)

                        if num then
                            Tab217[num] = true

                            if StealState.heldUid and v.Uid == StealState.heldUid then
                                VarU3228 = VarU3228 or num
                            end
                        end
                    end
                end
            end)
            local VarV3229
            local VarV3230
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local VarV3233 = select(1, BatCharParts(player))

                    if VarV3233 then
                        local Magnitude = (VarV3233.Position - BatFromPos).Magnitude

                        if Magnitude <= Num45 then
                            if VarU3228 and player.UserId == VarU3228 then
                                Magnitude -= 80
                            elseif Tab217[player.UserId] then
                                Magnitude -= 40
                            end

                            if not VarV3230 or Magnitude < VarV3230 then
                                VarV3229 = player
                                VarV3230 = Magnitude
                            end
                        end
                    end
                end
            end

            return VarV3229
        end
        local function BatAuraTick()
            if not IsAlive or not Config.BatAura then
                return
            end

            if Config.AutoSteal then
                BatAutoEquip()
            end

            local VarV3235 = select(1, BatCharParts(LocalPlayer))

            if not VarV3235 then
                return
            end

            BatSwingAt((BatFindTarget(VarV3235.Position)))
        end
        local function BatSetLive(BatLiveFlag)
            if not not BatLiveFlag then
                if not VarU2105 then
                    local connection11 = RunService.Heartbeat:Connect(function()
                        pcall(BatAuraTick)
                    end)

                    if connection11 then
                        ConnList[connection11] = true
                    end

                    VarU2105 = connection11

                    return
                end
            elseif VarU2105 then
                VarU2105:Disconnect()
                VarU2105 = nil
            end
        end

        return {
			range = function()
            return Num45
        end,
			swingAt = BatSwingAt,
			posOf = function(Arg337)
            local VarV3239 = type(Arg337) == "number" and Players:GetPlayerByUserId(Arg337)
            local VarV3240 = VarV3239 and select(1, BatCharParts(VarV3239))

            return VarV3240 and VarV3240.Position, VarV3239
        end,
			setLive = BatSetLive,
			stop = function()
            BatSetLive(false)
        end
		}
    end)()
    PanelCtl = (function()
        local EspState = {
			folder = nil,
			beamObj = nil,
			pool = {},
			uidPart = {},
			plotAt = 0,
			plotList = {},
			optSaved = nil,
			lastTick = 0,
			iconBy = {},
			iconScanAt = 0,
			sessionAt = os.clock()
		}
        local VarU2116
        local function FmtAbbrev(AbbrevNum)
            local VarV3242 = tonumber(AbbrevNum) or 0
            local VarV3243 = math.abs(VarV3242)

            if VarV3243 >= 1000000000000 then
                return string.format("%.2fT", VarV3242 / 1000000000000)
            end

            if VarV3243 >= 1000000000 then
                return string.format("%.2fB", VarV3242 / 1000000000)
            end

            if VarV3243 >= 1000000 then
                return string.format("%.2fm", VarV3242 / 1000000)
            end

            if VarV3243 >= 1000 then
                return string.format("%.1fk", VarV3242 / 1000)
            end

            if VarV3243 >= 10 then
                return string.format("%.0f", VarV3242)
            end

            return string.format("%.1f", VarV3242)
        end
        pcall(function()
            local FormatAbbreviated = require(ReplicatedStorage.UserGenerated.Strings.FormatAbbreviated)

            if type(FormatAbbreviated) == "function" then
                function FmtAbbrev(Arg339)
                    local VarV4687 = tonumber(Arg339) or 0
                    local Ok44, Ret44 = pcall(FormatAbbreviated, VarV4687)

                    if Ok44 and type(Ret44) == "string" and Ret44 ~= "" then
                        return Ret44
                    end

                    if math.abs(VarV4687) >= 1000000 then
                        return string.format("%.2fm", VarV4687 / 1000000)
                    end

                    return string.format("%.0f", VarV4687)
                end
            end
        end)
        local function RarityColor(RarityNum)
            local VarV3246 = tonumber(RarityNum) or 0

            if VarV3246 >= 11 then
                return Color3.fromRGB(255, 236, 150)
            end

            if VarV3246 >= 10 then
                return Color3.fromRGB(255, 90, 210)
            end

            if VarV3246 >= 9 then
                return Color3.fromRGB(120, 210, 255)
            end

            if VarV3246 >= 8 then
                return Color3.fromRGB(255, 80, 110)
            end

            if VarV3246 >= 7 then
                return Color3.fromRGB(255, 186, 70)
            end

            if VarV3246 >= 6 then
                return Color3.fromRGB(186, 120, 255)
            end

            if VarV3246 >= 5 then
                return Color3.fromRGB(255, 220, 90)
            end

            if VarV3246 >= 4 then
                return Color3.fromRGB(160, 120, 255)
            end

            if VarV3246 >= 3 then
                return Color3.fromRGB(90, 170, 255)
            end

            if VarV3246 >= 2 then
                return Color3.fromRGB(120, 200, 120)
            end

            return Color3.fromRGB(210, 210, 210)
        end
        local function EggIconInit()
            local KozuaEsp = workspace:FindFirstChild("KozuaEsp")

            if KozuaEsp and KozuaEsp:IsA("Folder") then
                EspState.folder = KozuaEsp

                return KozuaEsp
            end

            if EspState.folder and EspState.folder.Parent == workspace then
                return EspState.folder
            end

            if EspState.folder then
                pcall(function()
                    EspState.folder:Destroy()
                end)
            end

            local Folder = Instance.new("Folder")

            Folder.Name = "KozuaEsp"
            Folder.Parent = workspace
            EspState.folder = Folder

            return Folder
        end
        local function EggIconResolve()
            local Parent = ScreenGui.Parent
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

            if PlayerGui then
                local VarV3251 = PlayerGui:FindFirstChild(WorldGuiTag) or PlayerGui:FindFirstChild("KozuaWorldGui")

                if VarV3251 and VarV3251 ~= EspState.world then
                    pcall(function()
                        VarV3251:Destroy()
                    end)
                end
            end

            if not Parent then
                Parent = PlayerGui or ScreenGui
            end

            local world = EspState.world

            if not world or not world.Parent or not world:IsA("ScreenGui") then
                world = Parent:FindFirstChild(WorldGuiTag)
            end

            if world and world:IsA("ScreenGui") then
                if Parent ~= world.Parent and Parent then
                    world.Parent = Parent
                end

                world.Enabled = true
                world.ResetOnSpawn = false
                EspState.world = world

                return world
            end

            local ScreenGui = Instance.new("ScreenGui")

            ScreenGui.Name = WorldGuiTag
            ScreenGui.ResetOnSpawn = false
            ScreenGui.IgnoreGuiInset = true
            ScreenGui.DisplayOrder = 80
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ScreenGui.Parent = Parent
            EspState.world = ScreenGui

            return ScreenGui
        end
        local function ResolveEggIcon(IconKey)
            if IconKey == nil then
                return
            end

            local VarV3255 = typeof(IconKey)

            if VarV3255 == "number" then
                if IconKey > 100 then
                    return "rbxassetid://" .. tostring(math.floor(IconKey))
                end

                return
            end

            if VarV3255 == "string" then
                if IconKey == "" or IconKey == "0" or IconKey == "rbxassetid://0" then
                    return
                end

                if string.find(IconKey, "http", 1, true) or string.find(IconKey, "rbxasset", 1, true) or string.find(IconKey, "rbxthumb", 1, true) then
                    return IconKey
                end

                local num = tonumber(IconKey)

                if num and num > 100 then
                    return "rbxassetid://" .. tostring(math.floor(num))
                end

                return
            end

            if VarV3255 == "Instance" then
                if IconKey:IsA("ImageLabel") or IconKey:IsA("ImageButton") then
                    return ResolveEggIcon(IconKey.Image)
                end

                if IconKey:IsA("Decal") or IconKey:IsA("Texture") then
                    return ResolveEggIcon(IconKey.Texture)
                end

                local VarV3257 = IconKey:FindFirstChildWhichIsA("ImageLabel", true) or (IconKey:FindFirstChildWhichIsA("ImageButton", true) or IconKey:FindFirstChildWhichIsA("Decal", true))

                if VarV3257 then
                    return ResolveEggIcon(VarV3257)
                end

                return
            end

            if VarV3255 == "table" then
                return ResolveEggIcon(IconKey.Image) or (ResolveEggIcon(IconKey.ImageId) or (ResolveEggIcon(IconKey.Icon) or ResolveEggIcon(IconKey.Id)))
            end
        end
        local Tab219 = {
			"IndexImage",
			"IndexIcon",
			"Icon",
			"Image",
			"ImageId",
			"IconImage",
			"Thumbnail",
			"AssetImage",
			"PetImage",
			"EggImage",
			"RenderImage",
			"Picture"
		}
        local function EggTooltipBind(TipText, TipData)
            if type(TipData) ~= "table" then
                return
            end
            local VarV3264
            for i = 1, #Tab219 do
                VarV3264 = ResolveEggIcon(TipData[Tab219[i]])

                if VarV3264 then
                    break
                end
            end
            if not VarV3264 and type(TipData.Egg) == "table" then
                for i = 1, #Tab219 do
                    VarV3264 = ResolveEggIcon(TipData.Egg[Tab219[i]])

                    if VarV3264 then
                        break
                    end
                end
            end
            if not VarV3264 then
                return
            end
            if type(TipText) == "string" and TipText ~= "" and VarV3264 then
                local VarV3267 = string.lower(TipText)

                EspState.iconBy[VarV3267] = VarV3264

                local VarV3268 = VarV3267:gsub("[%s_%-]+", "")

                if VarV3268 ~= VarV3267 then
                    EspState.iconBy[VarV3268] = VarV3264
                end
            end
            local DisplayName = TipData.DisplayName
            if type(DisplayName) == "string" and DisplayName ~= "" and VarV3264 then
                local VarV3270 = string.lower(DisplayName)

                EspState.iconBy[VarV3270] = VarV3264

                local VarV3271 = VarV3270:gsub("[%s_%-]+", "")

                if VarV3271 ~= VarV3270 then
                    EspState.iconBy[VarV3271] = VarV3264
                end
            end
            local _id = TipData._id
            if type(_id) == "string" and _id ~= "" and VarV3264 then
                local VarV3273 = string.lower(_id)

                EspState.iconBy[VarV3273] = VarV3264

                local VarV3274 = VarV3273:gsub("[%s_%-]+", "")

                if VarV3274 ~= VarV3273 then
                    EspState.iconBy[VarV3274] = VarV3264
                end
            end
            if type(TipData.Egg) == "table" then
                local DisplayName2 = TipData.Egg.DisplayName

                if type(DisplayName2) == "string" and DisplayName2 ~= "" then
                    if not VarV3264 then
                        return
                    end

                    local VarV3276 = string.lower(DisplayName2)

                    EspState.iconBy[VarV3276] = VarV3264

                    local VarV3277 = VarV3276:gsub("[%s_%-]+", "")

                    if VarV3277 ~= VarV3276 then
                        EspState.iconBy[VarV3277] = VarV3264
                    end
                end
            end
        end
        local function EggListAll()
            local Tab220 = {}

            if type(Directory) ~= "table" then
                return Tab220
            end

            for k, v in pairs(Directory) do
                local StrId26 = tostring(k)

                Tab220[string.lower(StrId26)] = StrId26

                if type(v) == "table" then
                    if v.DisplayName then
                        Tab220[string.lower((tostring(v.DisplayName)))] = StrId26
                    end

                    if v._id then
                        Tab220[string.lower((tostring(v._id)))] = StrId26
                    end

                    if type(v.Egg) == "table" and v.Egg.DisplayName then
                        Tab220[string.lower((tostring(v.Egg.DisplayName)))] = StrId26
                    end
                end
            end

            return Tab220
        end
        local function EggTooltipText(Arg344, Arg345)
            if not Arg344 then
                return
            end

            local Ok45, Ret45 = pcall(function()
                return Arg344:GetDescendants()
            end)

            if not Ok45 or type(Ret45) ~= "table" then
                return
            end

            local Num46 = 0

            for i = 1, #Ret45 do
                Num46 += 1

                if Arg345 < Num46 then
                    return
                end

                local VarV3288 = Ret45[i]
                local VarU3289 = false

                pcall(function()
                    VarU3289 = VarV3288:IsA("ImageLabel") or VarV3288:IsA("ImageButton")
                end)

                if VarU3289 then
                    local VarV3290 = ResolveEggIcon(VarV3288)

                    if VarV3290 then
                        local Name = VarV3288.Name

                        if type(Name) == "string" and Name ~= "" and VarV3290 then
                            local VarV3292 = string.lower(Name)

                            EspState.iconBy[VarV3292] = VarV3290

                            local VarV3293 = VarV3292:gsub("[%s_%-]+", "")

                            if VarV3293 ~= VarV3292 then
                                EspState.iconBy[VarV3293] = VarV3290
                            end
                        end

                        if VarV3288.Parent then
                            local ParentName = VarV3288.Parent.Name

                            if type(ParentName) == "string" and ParentName ~= "" and VarV3290 then
                                local VarV3295 = string.lower(ParentName)

                                EspState.iconBy[VarV3295] = VarV3290

                                local VarV3296 = VarV3295:gsub("[%s_%-]+", "")

                                if VarV3296 ~= VarV3295 then
                                    EspState.iconBy[VarV3296] = VarV3290
                                end
                            end
                        end

                        pcall(function()
                            local AssetCategory = VarV3288:GetAttribute("AssetCategory")
                            local VarV4691 = VarV3290

                            if type(AssetCategory) == "string" and (AssetCategory ~= "" and VarV4691) then
                                local VarV4692 = string.lower(AssetCategory)

                                EspState.iconBy[VarV4692] = VarV4691

                                local VarV4693 = VarV4692:gsub("[%s_%-]+", "")

                                if VarV4693 ~= VarV4692 then
                                    EspState.iconBy[VarV4693] = VarV4691
                                end
                            end

                            local Id = VarV3288:GetAttribute("Id")
                            local VarV4695 = VarV3290

                            if type(Id) == "string" and Id ~= "" and VarV4695 then
                                local VarV4696 = string.lower(Id)

                                EspState.iconBy[VarV4696] = VarV4695

                                local VarV4697 = VarV4696:gsub("[%s_%-]+", "")

                                if VarV4697 ~= VarV4696 then
                                    EspState.iconBy[VarV4697] = VarV4695
                                end
                            end

                            if VarV3288.Parent then
                                local AssetCategory2 = VarV3288.Parent:GetAttribute("AssetCategory")
                                local VarV4699 = VarV3290

                                if type(AssetCategory2) == "string" and AssetCategory2 ~= "" then
                                    if not VarV4699 then
                                        return
                                    end

                                    local VarV4700 = string.lower(AssetCategory2)

                                    EspState.iconBy[VarV4700] = VarV4699

                                    local VarV4701 = VarV4700:gsub("[%s_%-]+", "")

                                    if VarV4701 ~= VarV4700 then
                                        EspState.iconBy[VarV4701] = VarV4699
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
        local function BuildEspBillboard(Arg346, Arg347, Arg348)
            if not Arg346 or not Arg347 then
                return
            end

            local Ok46, Ret46 = pcall(function()
                return Arg346:GetDescendants()
            end)

            if not Ok46 or type(Ret46) ~= "table" then
                return
            end

            local Num47 = 0

            for i = 1, #Ret46 do
                Num47 += 1

                if Arg348 < Num47 then
                    return
                end

                local VarV3304 = Ret46[i]
                local VarU3305 = false

                pcall(function()
                    VarU3305 = VarV3304:IsA("TextLabel") or VarV3304:IsA("TextButton")
                end)

                if VarU3305 then
                    local Text = VarV3304.Text

                    if type(Text) == "string" and Text ~= "" then
                        local VarV3307 = Arg347[string.lower(Text)]

                        if VarV3307 then
                            local Parent = VarV3304.Parent

                            if Parent then
                                local descendants = Parent:GetDescendants()

                                for j = 1, #descendants do
                                    local VarV3311 = descendants[j]
                                    local VarU3312 = false

                                    pcall(function()
                                        VarU3312 = VarV3311:IsA("ImageLabel") or VarV3311:IsA("ImageButton")
                                    end)

                                    if VarU3312 then
                                        local VarV3313 = ResolveEggIcon(VarV3311)

                                        if VarV3313 then
                                            if type(VarV3307) == "string" and VarV3307 ~= "" and VarV3313 then
                                                local VarV3314 = string.lower(VarV3307)

                                                EspState.iconBy[VarV3314] = VarV3313

                                                local VarV3315 = VarV3314:gsub("[%s_%-]+", "")

                                                if VarV3315 ~= VarV3314 then
                                                    EspState.iconBy[VarV3315] = VarV3313
                                                end
                                            end

                                            if type(Text) == "string" and Text ~= "" and VarV3313 then
                                                local VarV3316 = string.lower(Text)

                                                EspState.iconBy[VarV3316] = VarV3313

                                                local VarV3317 = VarV3316:gsub("[%s_%-]+", "")

                                                if VarV3317 ~= VarV3316 then
                                                    EspState.iconBy[VarV3317] = VarV3313
                                                end
                                            end

                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        local function ThemeIsLight(Arg349)
            local VarV3319 = string.lower((tostring(Arg349 or "")))

            return string.find(VarV3319, "index", 1, true) or (string.find(VarV3319, "bestiary", 1, true) or (string.find(VarV3319, "collection", 1, true) or string.find(VarV3319, "pedia", 1, true)))
        end
        local function ThemeGet(Arg350)
            local Clock16 = os.clock()

            if not Arg350 and Clock16 - (EspState.iconScanAt or 0) < 8 then
                return
            end

            EspState.iconScanAt = Clock16

            if type(Directory) == "table" then
                for k, v in pairs(Directory) do
                    EggTooltipBind(k, v)
                end
            end

            local VarV3324 = EggListAll()
            local Assets = ReplicatedStorage:FindFirstChild("Assets")

            pcall(EggTooltipText, Assets and Assets:FindFirstChild("UI"), 6000)
            pcall(EggTooltipText, ReplicatedStorage:FindFirstChild("Directory"), 8000)
            pcall(EggTooltipText, ReplicatedStorage:FindFirstChild("Data"), 4000)

            local function Theme_Fn_3326(Arg351)
                if not Arg351 then
                    return
                end

                for _, child in ipairs(Arg351:GetChildren()) do
                    if child ~= ScreenGui and ThemeIsLight(child.Name) then
                        pcall(EggTooltipText, child, 8000)
                        pcall(BuildEspBillboard, child, VarV3324, 8000)
                    end
                end
            end

            Theme_Fn_3326(LocalPlayer:FindFirstChild("PlayerGui"))
            pcall(Theme_Fn_3326, game:GetService("StarterGui"))
        end
        local function ThemeApply(Arg352, Arg353)
            local Tab221 = {}
            local Tab222 = {}

            local function Theme_Fn_3331(Arg354)
                if type(Arg354) ~= "string" or Arg354 == "" then
                    return
                end

                local VarV4706 = string.lower(Arg354)

                if VarV4706 ~= "" and not Tab222[VarV4706] then
                    Tab222[VarV4706] = true
                    Tab221[#Tab221 + 1] = VarV4706
                end

                local VarV4707 = VarV4706:gsub("[%s_%-]+", "")

                if VarV4707 ~= "" and not Tab222[VarV4707] then
                    Tab222[VarV4707] = true
                    Tab221[#Tab221 + 1] = VarV4707
                end

                local VarV4708 = VarV4706:gsub("[%s%-]+", "_")

                if VarV4708 ~= "" and not Tab222[VarV4708] then
                    Tab222[VarV4708] = true
                    Tab221[#Tab221 + 1] = VarV4708
                end
            end

            Theme_Fn_3331(Arg353)

            if type(Arg352) == "table" then
                Theme_Fn_3331(Arg352.DisplayName)
                Theme_Fn_3331(Arg352._id)

                if type(Arg352.Egg) == "table" then
                    Theme_Fn_3331(Arg352.Egg.DisplayName)
                end
            end

            return Tab221
        end
        local function EspMakeLabel(Arg355, Arg356)
            local VarV3353 = Config.Theme == "Light"
            local VarV3354 = Arg356 and Arg356.target

            if VarV3353 then
                Arg355.card.BackgroundColor3 = Color3.fromRGB(252, 250, 246)
                Arg355.card.BackgroundTransparency = 0.28
                Arg355.title.TextColor3 = Color3.fromRGB(28, 24, 20)
                Arg355.sub.TextColor3 = Color3.fromRGB(92, 84, 74)
                Arg355.stroke.Color = VarV3354 and Theme.accent or Color3.fromRGB(188, 178, 164)
                Arg355.stroke.Transparency = not VarV3354 and 0.32 or 0.12

                if Arg355.icon then
                    Arg355.icon.BackgroundColor3 = Color3.fromRGB(232, 226, 216)
                    Arg355.icon.BackgroundTransparency = not Arg355.icon.Visible and 1 or 0.42
                end
            else
                Arg355.card.BackgroundColor3 = Color3.fromRGB(16, 15, 14)
                Arg355.card.BackgroundTransparency = 0.34
                Arg355.title.TextColor3 = Color3.fromRGB(246, 242, 234)
                Arg355.sub.TextColor3 = Color3.fromRGB(168, 158, 144)
                Arg355.stroke.Color = VarV3354 and Theme.accent or Color3.fromRGB(58, 53, 46)
                Arg355.stroke.Transparency = not VarV3354 and 0.38 or 0.08

                if Arg355.icon then
                    Arg355.icon.BackgroundColor3 = Color3.fromRGB(28, 26, 24)
                    Arg355.icon.BackgroundTransparency = not Arg355.icon.Visible and 1 or 0.5
                end
            end

            Arg355.stroke.Thickness = not VarV3354 and 1 or 1.5
        end
        local function EspClearPool()
            local BillboardGui = Instance.new("BillboardGui")

            BillboardGui.AlwaysOnTop = true
            BillboardGui.LightInfluence = 0
            BillboardGui.MaxDistance = 1000000
            BillboardGui.Size = UDim2.fromOffset(152, 34)
            BillboardGui.StudsOffset = Vector3.new(0, 2.2, 0)
            BillboardGui.ResetOnSpawn = false
            BillboardGui.Active = false
            BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            BillboardGui.Parent = EggIconResolve()

            local Tab223 = {
				BackgroundColor3 = Color3.fromRGB(16, 15, 14),
				BackgroundTransparency = 0.34,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				ClipsDescendants = true,
				ZIndex = 1,
				Active = false
			}
            local Frame = Instance.new("Frame")

            if Tab223 then
                for k, v in pairs(Tab223) do
                    Frame[k] = v
                end
            end

            if BillboardGui then
                Frame.Parent = BillboardGui
            end

            local Tab224 = {
				CornerRadius = UDim.new(0, 8)
			}
            local UICorner = Instance.new("UICorner")

            if Tab224 then
                for k, v in pairs(Tab224) do
                    UICorner[k] = v
                end
            end

            if Frame then
                UICorner.Parent = Frame
            end

            local Tab225 = {
				Color = Color3.fromRGB(70, 64, 56),
				Transparency = 0.38,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke = Instance.new("UIStroke")

            if Tab225 then
                for k, v in pairs(Tab225) do
                    UIStroke[k] = v
                end
            end

            if Frame then
                UIStroke.Parent = Frame
            end

            local Tab226 = {
				BackgroundColor3 = Color3.fromRGB(210, 210, 210),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 2, 1, -8),
				Position = UDim2.fromOffset(3, 4),
				ZIndex = 2,
				Active = false
			}
            local Frame27 = Instance.new("Frame")

            if Tab226 then
                for k, v in pairs(Tab226) do
                    Frame27[k] = v
                end
            end

            if Frame then
                Frame27.Parent = Frame
            end

            local Tab227 = {
				CornerRadius = UDim.new(0, 2)
			}
            local UICorner12 = Instance.new("UICorner")

            if Tab227 then
                for k, v in pairs(Tab227) do
                    UICorner12[k] = v
                end
            end

            if Frame27 then
                UICorner12.Parent = Frame27
            end

            local Tab228 = {
				BackgroundColor3 = Color3.fromRGB(28, 26, 24),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 6),
				Size = UDim2.fromOffset(22, 22),
				Image = "",
				ScaleType = Enum.ScaleType.Fit,
				Visible = false,
				ZIndex = 2,
				Active = false
			}
            local ImageLabel = Instance.new("ImageLabel")

            if Tab228 then
                for k, v in pairs(Tab228) do
                    ImageLabel[k] = v
                end
            end

            if Frame then
                ImageLabel.Parent = Frame
            end

            local Tab229 = {
				CornerRadius = UDim.new(0, 5)
			}
            local UICorner13 = Instance.new("UICorner")

            if Tab229 then
                for k, v in pairs(Tab229) do
                    UICorner13[k] = v
                end
            end

            if ImageLabel then
                UICorner13.Parent = ImageLabel
            end

            local Tab230 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 2),
				Size = UDim2.new(1, -12, 0, 14),
				Font = Fonts.mid,
				Text = "",
				TextColor3 = Color3.fromRGB(246, 242, 234),
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 2,
				Active = false
			}
            local TextLabel = Instance.new("TextLabel")

            if Tab230 then
                for k, v in pairs(Tab230) do
                    TextLabel[k] = v
                end
            end

            if Frame then
                TextLabel.Parent = Frame
            end

            local Tab231 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 16),
				Size = UDim2.new(1, -12, 0, 14),
				Font = Fonts.mono,
				Text = "",
				TextColor3 = Color3.fromRGB(168, 158, 144),
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = false,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 2,
				Active = false
			}
            local TextLabel11 = Instance.new("TextLabel")

            if Tab231 then
                for k, v in pairs(Tab231) do
                    TextLabel11[k] = v
                end
            end

            if Frame then
                TextLabel11.Parent = Frame
            end

            return {
				bb = BillboardGui,
				card = Frame,
				stroke = UIStroke,
				accent = Frame27,
				icon = ImageLabel,
				title = TextLabel,
				sub = TextLabel11
			}
        end
        local function EspSpawnEggTag(Arg357, Arg358, Arg359)
            if not Arg358 then
                return
            end

            local VarU3395 = EspState.pool[Arg357]

            if VarU3395 and (not VarU3395.bb or not VarU3395.bb.Parent) then
                if VarU3395.dummy then
                    pcall(function()
                        VarU3395.dummy:Destroy()
                    end)
                end

                VarU3395 = nil
                EspState.pool[Arg357] = nil
            end

            if not VarU3395 then
                VarU3395 = EspClearPool()
                EspState.pool[Arg357] = VarU3395
            end

            VarU3395.alive = true
            VarU3395.pos = Arg358

            local VarV3396 = EggIconInit()

            if not VarU3395.dummy or not VarU3395.dummy.Parent then
                if VarU3395.dummy then
                    pcall(function()
                        VarU3395.dummy:Destroy()
                    end)
                end

                local Part = Instance.new("Part")

                Part.Name = "KozuaEspAdorn"
                Part.Anchored = true
                Part.CanCollide = false
                Part.CanQuery = false
                Part.CanTouch = false
                Part.CastShadow = false
                Part.Transparency = 1
                Part.Size = Vector3.new(0.15, 0.15, 0.15)
                Part.Parent = VarV3396
                VarU3395.dummy = Part
            end

            pcall(function()
                VarU3395.dummy.CFrame = CFrame.new(Arg358)
            end)
            VarU3395.bb.Adornee = VarU3395.dummy
            VarU3395.bb.Parent = EggIconResolve()
            VarU3395.bb.Enabled = true

            local VarV3398 = Arg359.color or Color3.fromRGB(210, 210, 210)

            VarU3395.title.Text = tostring(Arg359.name or "")
            VarU3395.sub.Text = tostring(Arg359.sub or "")
            VarU3395.accent.BackgroundColor3 = VarV3398

            local VarV3399 = not Arg359.tall and 34 or 46
            local icon = Arg359.icon
            local VarV3401 = not icon and 152 or 180

            if VarU3395.icon then
                if icon then
                    VarU3395.icon.Image = icon
                    VarU3395.icon.Visible = true

                    local VarV3402 = tostring(Arg359.name or ""):gsub("^▸%s*", ""):gsub("^>%s*", "")

                    if type(VarV3402) == "string" and VarV3402 ~= "" and icon then
                        local VarV3403 = string.lower(VarV3402)

                        EspState.iconBy[VarV3403] = icon

                        local VarV3404 = VarV3403:gsub("[%s_%-]+", "")

                        if VarV3404 ~= VarV3403 then
                            EspState.iconBy[VarV3404] = icon
                        end
                    end

                    VarU3395.title.Position = UDim2.fromOffset(34, 2)
                    VarU3395.title.Size = UDim2.new(1, -40, 0, 14)
                    VarU3395.sub.Position = UDim2.fromOffset(34, 16)
                    VarU3395.sub.Size = UDim2.new(1, -40, 0, not Arg359.tall and 14 or 26)
                    VarU3395.sub.TextWrapped = Arg359.tall == true
                else
                    VarU3395.icon.Image = ""
                    VarU3395.icon.Visible = false
                    VarU3395.title.Position = UDim2.fromOffset(8, 2)
                    VarU3395.title.Size = UDim2.new(1, -12, 0, 14)
                    VarU3395.sub.Position = UDim2.fromOffset(8, 16)
                    VarU3395.sub.Size = UDim2.new(1, -12, 0, not Arg359.tall and 14 or 26)
                    VarU3395.sub.TextWrapped = Arg359.tall == true
                end
            end

            EspMakeLabel(VarU3395, Arg359)
            VarU3395.bb.Size = UDim2.fromOffset(VarV3401, VarV3399)
        end
        local function EspOwnedSnapshot()
            for k, v in pairs(EspState.pool) do
                if not v.alive then
                    if v.bb then
                        v.bb:Destroy()
                    end

                    if v.dummy then
                        pcall(function()
                            v.dummy:Destroy()
                        end)
                    end

                    EspState.pool[k] = nil
                else
                    v.alive = false
                end
            end
        end
        local function EspEggStats(Arg360, Arg361)
            if type(Arg360) == "table" then
                local num = tonumber(Arg360.Weight)
                local VarV3410 = if not num or not (num > 0) then nil else num

                if not VarV3410 then
                    local num3 = tonumber(Arg360.ModelWeight)

                    VarV3410 = if not num3 or not (num3 > 0) then nil else num3

                    if not VarV3410 then
                        local num4 = tonumber(Arg360.Kg)

                        VarV3410 = if not num4 or not (num4 > 0) then nil else num4

                        if not VarV3410 then
                            local num5 = tonumber(Arg360.BaseWeight)

                            VarV3410 = if not num5 or not (num5 > 0) then nil else num5
                        end
                    end
                end

                if VarV3410 then
                    return VarV3410
                end
            end

            if type(Arg361) == "table" then
                local num = tonumber(Arg361.ModelWeight)
                local VarV3415 = if not num or not (num > 0) then nil else num

                if not VarV3415 then
                    local num6 = tonumber(Arg361.Weight)

                    VarV3415 = if not num6 or not (num6 > 0) then nil else num6

                    if not VarV3415 then
                        local num7 = tonumber(Arg361.BaseWeight)

                        VarV3415 = if not num7 or not (num7 > 0) then nil else num7
                    end
                end

                if VarV3415 then
                    return VarV3415
                end

                if type(Arg361.Egg) == "table" then
                    local num8 = tonumber(Arg361.Egg.ModelWeight)
                    local VarV3419 = if not num8 or not (num8 > 0) then nil else num8

                    if not VarV3419 then
                        local num9 = tonumber(Arg361.Egg.Weight)

                        if num9 and num9 > 0 then
                            return num9
                        end

                        VarV3419 = nil
                    end

                    return VarV3419
                end
            end
        end
        local function EspPlotTag(Arg362, Arg363, Arg364)
            local VarV3426 = Arg363 and (Arg363.DisplayName or type(Arg363.Egg) == "table" and Arg363.Egg.DisplayName) or tostring(Arg362.AssetCategory or "?")
            local Flag3440
            local VarV3439
            if Arg364 then
                VarV3426 = "▸ " .. tostring(VarV3426)
            end
            local VarV3427 = FmtAbbrev(v1193(Arg362, Arg363)) .. "/s"
            local VarV3428 = if type(Arg363) == "table" and type(Arg363.Rarity) == "table" then tostring(Arg363.Rarity.DisplayName or (Arg363.Rarity.Name or (Arg363.Rarity._id or "?"))) else "?"
            local num = tonumber((EspEggStats(Arg362, Arg363)))
            local VarV3430 = if num then if not (num >= 100) then string.format("%.1fkg", num) else string.format("%.0fkg", num) else nil
            local Tab232 = {
				VarV3427,
				VarV3428
			}
            local VarV3432 = v1192(Arg363, Arg362)
            if VarV3432 then
                Tab232[#Tab232 + 1] = VarV3432
            end
            if VarV3430 then
                Tab232[#Tab232 + 1] = VarV3430
            end
            local State19 = ""
            if type(Arg362.Mutations) == "table" and #Arg362.Mutations > 0 then
                State19 = table.concat(Arg362.Mutations, " · ")
            end
            local VarV3434 = table.concat(Tab232, " · ")
            if State19 ~= "" then
                VarV3434 ..= "\n" .. State19
            end
            local Tab233 = {
				name = VarV3426,
				sub = VarV3434,
				color = RarityColor(if type(Arg363) == "table" and type(Arg363.Rarity) == "table" then tonumber(Arg363.Rarity.RarityNumber) or 0 else 0),
				target = Arg364,
				tall = State19 ~= ""
			}
            local VarV3436 = Arg362 and Arg362.AssetCategory
            EggTooltipBind(VarV3436, Arg363)
            local VarV3437 = ThemeApply(Arg363, VarV3436)
            for i = 1, #VarV3437 do
                VarV3439 = EspState.iconBy[VarV3437[i]]

                if VarV3439 then
                    Flag3440 = true
                end

                if Flag3440 then
                    break
                end
            end
            if not Flag3440 then
                VarV3439 = nil
            end
            Tab233.icon = VarV3439

            return Tab233
        end
        local function ListPlotFolders()
            if not EggState then
                return nil
            end

            if type(EggState.ReadOwnerEggs) == "function" then
                local Ok47, Ret47, _, _ = pcall(function()
                    return EggState.ReadOwnerEggs(LocalPlayer.UserId)
                end)

                if not Ok47 then
                    KozuaLog("esp", "ERR", "ReadOwnerEggs", (tostring(Ret47)))
                    Ret47 = nil
                end

                if type(Ret47) == "table" then
                    return Ret47
                end
            end

            if type(EggState.ReadOwnedEggs) == "function" then
                local ReadOwnedEggs = EggState.ReadOwnedEggs
                local Ok48, Ret48, _, _ = pcall(ReadOwnedEggs)

                if not Ok48 then
                    KozuaLog("esp", "ERR", "ReadOwnedEggs", (tostring(Ret48)))
                    Ret48 = nil
                end

                if type(Ret48) == "table" then
                    for _, v in pairs(Ret48) do
                        if type(v) == "table" and tonumber(v.OwnerUserId) == LocalPlayer.UserId then
                            return v.Records
                        end
                    end
                end
            end
        end
        local function FmtTime(Arg365, Arg366)
            if type(Arg365) ~= "table" then
                return nil, false
            end

            local VarV3459 = Arg366 or Arg365.Uid

            if VarV3459 and EggState and type(EggState.IsReadyToHatch) == "function" then
                local Ok49, Ret49 = pcall(EggState.IsReadyToHatch, VarV3459)

                if Ok49 and Ret49 then
                    return 0, true
                end
            end

            local eggRec

            if EspState.eggRec ~= nil then
                eggRec = EspState.eggRec
            else
                local EggRecords
                pcall(function()
                    EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
                end)
                EspState.eggRec = type(EggRecords) == "table" and (EggRecords or false)
                eggRec = EspState.eggRec
            end

            local VarV3464 = eggRec

            if type(VarV3464) == "table" and type(Arg365.Placement) == "table" then
                local ServerTimeNow = workspace:GetServerTimeNow()
                local VarU3466 = tonumber(Arg365.GrowthSpeedMultiplier) or 1
                if VarU3466 <= 0 then
                    VarU3466 = 1
                end
                local VarU3467
                pcall(function()
                    VarU3467 = VarV3464.CurrentNightCredit(Arg365, ServerTimeNow, VarU3466)
                end)
                local VarU3468 = false
                pcall(function()
                    VarU3468 = VarV3464.IsGrown(Arg365, ServerTimeNow, VarU3466, VarU3467, LocalPlayer) == true
                end)
                if VarU3468 then
                    return 0, true
                end
                local VarU3469
                pcall(function()
                    VarU3469 = VarV3464.WallSecondsRemaining(Arg365, ServerTimeNow, VarU3466, VarU3467)
                end)
                if type(VarU3469) == "number" then
                    return VarU3469, VarU3469 <= 0
                end
            end

            if Arg365.IsReady == true or Arg365.Ready == true then
                return 0, true
            end

            local VarV3470 = Arg365.HatchEndsAt or (Arg365.ReadyAt or Arg365.GrowEndsAt)

            if type(VarV3470) == "number" then
                local VarV3471 = VarV3470 - workspace.DistributedGameTime

                return VarV3471, VarV3471 <= 0
            end

            local VarV3472 = tonumber(Arg365.TimeLeft) or tonumber(Arg365.HatchTimeLeft)

            if VarV3472 then
                return VarV3472, VarV3472 <= 0
            end

            local Placement = Arg365.Placement

            if type(Placement) == "table" then
                if Placement.IsReady == true then
                    return 0, true
                end

                local VarV3474 = Placement.HatchEndsAt or Placement.ReadyAt

                if type(VarV3474) == "number" then
                    local VarV3475 = VarV3474 - workspace.DistributedGameTime

                    return VarV3475, VarV3475 <= 0
                end
            end

            return nil, false
        end
        local function FmtClock(Arg367)
            local VarV3477 = math.max(0, math.floor(tonumber(Arg367) or 0))
            local VarV3478 = math.floor(VarV3477 / 3600)
            local VarV3479 = math.floor(VarV3477 % 3600 / 60)
            local VarV3480 = VarV3477 % 60

            if VarV3478 > 0 then
                return string.format("%d:%02d:%02d", VarV3478, VarV3479, VarV3480)
            end

            return string.format("%d:%02d", VarV3479, VarV3480)
        end
        local function EspCollectPlots()
            local Clock17 = os.clock()

            if Clock17 - (EspState.plotAt or 0) < 0.5 then
                return EspState.plotList
            end

            EspState.plotAt = Clock17

            local Tab234 = {}
            local VarV3483 = ListPlotFolders()
            local _, _, VarV3486, VarV3487 = ResolvePlotSpawn()
            local cFrame = CFrame.new()

            if VarV3487 and typeof(VarV3487) == "Instance" and VarV3487:IsA("BasePart") then
                cFrame = VarV3487.CFrame
            elseif VarV3486 then
                local CenterPoint = VarV3486:FindFirstChild("CenterPoint", true)

                if CenterPoint and CenterPoint:IsA("BasePart") then
                    cFrame = CenterPoint.CFrame
                else
                    pcall(function()
                        cFrame = VarV3486:GetPivot()
                    end)
                end
            end

            if type(VarV3483) == "table" then
                for k, v in pairs(VarV3483) do
                    if type(v) == "table" and v.AssetCategory then
                        local VarV3492 = v.Uid or k
                        local AssetCategory = v.AssetCategory
                        local VarV3494 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                        local VarV3495
                        local Placement = v.Placement
                        if type(Placement) == "table" and Placement.LocalCFrame then
                            local Ok50, Ret50 = pcall(function()
                                return cFrame * Placement.LocalCFrame
                            end)

                            if Ok50 and Ret50 then
                                VarV3495 = Ret50.Position + Vector3.new(0, 3, 0)
                            end
                        end
                        if VarV3495 then
                            local VarV3499, VarV3500 = FmtTime(v, VarV3492)

                            Tab234[#Tab234 + 1] = {
								key = "p:" .. tostring(v.Uid or k),
								pos = VarV3495,
								cfg = VarV3494,
								rec = v,
								left = VarV3499,
								ready = VarV3500
							}
                        end
                    end
                end
            end

            if #Tab234 == 0 and VarV3486 then
                for _, descendant in ipairs(VarV3486:GetDescendants()) do
                    local VarU3503 = false

                    pcall(function()
                        if descendant:IsA("ProximityPrompt") then
                            VarU3503 = string.lower(tostring(descendant.Name) .. " " .. tostring(descendant.ActionText) .. " " .. tostring(descendant.ObjectText)):find("hatch", 1, true) ~= nil
                        end
                    end)

                    if VarU3503 then
                        local descendantParent = descendant.Parent
                        local VarU3505
                        pcall(function()
                            if descendantParent:IsA("BasePart") then
                                VarU3505 = descendantParent.Position + Vector3.new(0, 3, 0)

                                return
                            end

                            if descendantParent:IsA("Model") then
                                VarU3505 = descendantParent:GetPivot().Position + Vector3.new(0, 3, 0)
                            end
                        end)
                        if VarU3505 then
                            local VarU3506 = false

                            pcall(function()
                                VarU3506 = string.lower(tostring(descendant.ObjectText) .. " " .. tostring(descendant.ActionText)):find("ready", 1, true) ~= nil
                            end)
                            Tab234[#Tab234 + 1] = {
								key = "p:" .. tostring(descendant),
								pos = VarU3505,
								ready = VarU3506,
								left = nil
							}
                        end
                    end
                end
            end

            EspState.plotList = Tab234

            return Tab234
        end
        local function EspUpdateBillboard(Arg368, Arg369)
            if not Arg368 or not Arg369 then
                if EspState.beamObj then
                    EspState.beamObj.Enabled = false
                end

                return
            end

            local VarV3509 = EggIconInit()

            if not VarV3509 then
                if EspState.beamObj then
                    EspState.beamObj.Enabled = false
                end

                return
            end

            if not EspState.att0 or Arg368 ~= EspState.att0.Parent then
                if EspState.att0 then
                    pcall(function()
                        EspState.att0:Destroy()
                    end)
                end

                local Attachment = Instance.new("Attachment")

                Attachment.Name = "KozuaBeamA"
                Attachment.Parent = Arg368
                EspState.att0 = Attachment
            end

            if not EspState.tip or not EspState.tip.Parent then
                local Part = Instance.new("Part")

                Part.Name = "KozuaBeamTip"
                Part.Anchored = true
                Part.CanCollide = false
                Part.CanQuery = false
                Part.CanTouch = false
                Part.Transparency = 1
                Part.Size = Vector3.new(0.2, 0.2, 0.2)
                Part.Parent = VarV3509
                EspState.tip = Part
            end

            pcall(function()
                EspState.tip.CFrame = CFrame.new(Arg369)
            end)

            if not EspState.att1 or EspState.att1.Parent ~= EspState.tip then
                if EspState.att1 then
                    pcall(function()
                        EspState.att1:Destroy()
                    end)
                end

                local Attachment = Instance.new("Attachment")

                Attachment.Name = "KozuaBeamB"
                Attachment.Parent = EspState.tip
                EspState.att1 = Attachment
            end

            if not EspState.beamObj or not EspState.beamObj.Parent then
                local Beam = Instance.new("Beam")

                Beam.Name = "KozuaBeam"
                Beam.FaceCamera = true
                Beam.Width0 = 0.16
                Beam.Width1 = 0.05
                Beam.LightEmission = 0.7
                Beam.Transparency = NumberSequence.new(0.15)
                Beam.Parent = VarV3509
                EspState.beamObj = Beam
            end

            EspState.beamObj.Attachment0 = EspState.att0
            EspState.beamObj.Attachment1 = EspState.att1
            EspState.beamObj.Color = ColorSequence.new(Theme.accent)
            EspState.beamObj.Enabled = true
        end
        local function EspTick()
            if not Config.EggESP and (not Config.PlotESP and not Config.ESPBeam) then
                for _, v in pairs(EspState.pool) do
                    if v.bb then
                        v.bb.Enabled = false
                    end
                end

                if EspState.beamObj then
                    EspState.beamObj.Enabled = false
                end

                if Config.StatsPanel then
                    pcall(v1204)
                end

                return
            end

            local Clock18 = os.clock()

            if Clock18 - (EspState.lastTick or 0) < 0.08 then
                return
            end

            EspState.lastTick = Clock18

            if Config.EggESP then
                local VarV3517 = v1204()
                local VarV3518 = Config.AutoSteal and (StealState.running and (StealState.target and (StealState.target.rec and StealState.target.rec.Uid)))

                for _, v in ipairs(VarV3517) do
                    pcall(function()
                        if type(v) ~= "table" or not v.Uid then
                            return
                        end

                        local State = v.State

                        if State ~= "Slot" and State ~= "Dropped" then
                            return
                        end

                        local AssetCategory = v.AssetCategory
                        local VarV4715 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                        local VarV4716 = v
                        local VarV4717 = Config.ESPFilter or "All eggs"
                        local VarV4719

                        if VarV4717 == "Stolen target only" then
                            local target = StealState.target

                            VarV4719 = target and (target.rec and target.rec.Uid == VarV4716.Uid)
                        else
                            VarV4719 = VarV4717 ~= "Eggs matching my filters" or PlotPassesFilter(VarV4716, VarV4715)
                        end

                        if not VarV4719 then
                            return
                        end

                        local VarV4720 = PlotBottomPos(v)

                        if not VarV4720 then
                            local VarV4721 = EspState.pool["f:" .. v.Uid]

                            VarV4720 = VarV4721 and VarV4721.pos
                        end

                        if VarV4720 then
                            local VarV4722 = v.Uid == VarV3518

                            EspSpawnEggTag("f:" .. v.Uid, VarV4720, (EspPlotTag(v, VarV4715, VarV4722)))
                        end
                    end)
                end
            end

            if Config.PlotESP then
                pcall(function()
                    local Flag4739
                    local VarV4738
                    for _, v in ipairs((EspCollectPlots())) do
                        local cfg = v.cfg
                        local VarV4726 = FmtAbbrev(v1193(v.rec, cfg)) .. "/s"
                        local VarV4727 = cfg and (cfg.DisplayName or not not v.rec and v.rec.AssetCategory) or "plot egg"
                        local VarV4728 = if not v.ready then v.left and FmtClock(v.left) or "hatching" else "ready"
                        local VarV4729 = v.rec and v.rec.AssetCategory
                        local VarV4730 = v1192(cfg, v.rec)
                        local VarV4731 = VarV4726 .. "  ·  " .. VarV4728

                        if VarV4730 then
                            VarV4731 = VarV4726 .. "  ·  " .. VarV4730 .. "  ·  " .. VarV4728
                        end

                        local VarV4732 = EspSpawnEggTag
                        local key = v.key
                        local pos = v.pos
                        local Tab235 = {
							name = tostring(VarV4727),
							sub = VarV4731,
							color = v.ready and Theme.ok or Theme.dim,
							target = v.ready == true
						}

                        EggTooltipBind(VarV4729, cfg)

                        local VarV4736 = ThemeApply(cfg, VarV4729)

                        for i = 1, #VarV4736 do
                            VarV4738 = EspState.iconBy[VarV4736[i]]

                            if VarV4738 then
                                Flag4739 = true
                            end

                            if Flag4739 then
                                break
                            end
                        end

                        if not Flag4739 then
                            VarV4738 = nil
                        end

                        Flag4739 = false
                        Tab235.icon = VarV4738
                        VarV4732(key, pos, Tab235)
                    end
                end)
            end

            if Config.ESPBeam and Config.AutoSteal and StealState.running then
                local Character5 = LocalPlayer.Character
                local VarV3522

                if not Character5 then
                    VarV3522 = nil
                else
                    local Humanoid = Character5:FindFirstChildOfClass("Humanoid")
                    local HumanoidRootPart = Character5:FindFirstChild("HumanoidRootPart")

                    VarV3522 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
                end

                local target = StealState.target

                if VarV3522 and target and target.pos and (target.cfg or target.earn) then
                    EspUpdateBillboard(VarV3522, target.pos)
                elseif EspState.beamObj then
                    EspState.beamObj.Enabled = false
                end
            elseif EspState.beamObj then
                EspState.beamObj.Enabled = false
            end

            EspOwnedSnapshot()
        end
        local Tab236 = {
			ParticleEmitter = true,
			Trail = true,
			Beam = true,
			Fire = true,
			Smoke = true,
			Sparkles = true,
			Highlight = true,
			PointLight = true,
			SpotLight = true,
			SurfaceLight = true,
			Clouds = true
		}
        local function PenSnapshot(Arg370)
            if Arg370 then
                local VarV3530

                if not Arg370 then
                    VarV3530 = true
                elseif ScreenGui and Arg370:IsDescendantOf(ScreenGui) then
                    VarV3530 = true
                elseif EspState.world and Arg370:IsDescendantOf(EspState.world) then
                    VarV3530 = true
                else
                    local p370Name = Arg370.Name

                    VarV3530 = p370Name == "KozuaSupport" or (p370Name == "Hub45Support" or (p370Name == "KozuaWorldGui" or (p370Name == WorldGuiTag or p370Name == GuiTag)))
                end

                if not VarV3530 then
                    if Arg370:IsA("ScreenGui") or Arg370:FindFirstAncestorOfClass("ScreenGui") then
                        return
                    end

                    if not Tab236[Arg370.ClassName] then
                        return
                    end

                    if not EspState.optInst then
                        EspState.optInst = {}
                    end

                    if EspState.optInst[Arg370] == nil then
                        local Tab237 = {}

                        pcall(function()
                            if Arg370:IsA("Light") then
                                Tab237.Enabled = Arg370.Enabled
                                Tab237.Brightness = Arg370.Brightness

                                return
                            end

                            if Arg370:IsA("ParticleEmitter") or Arg370:IsA("Trail") or Arg370:IsA("Beam") then
                                Tab237.Enabled = Arg370.Enabled

                                if Arg370:IsA("ParticleEmitter") then
                                    Tab237.Rate = Arg370.Rate

                                    return
                                end
                            else
                                Tab237.Enabled = Arg370.Enabled
                            end
                        end)
                        EspState.optInst[Arg370] = Tab237
                    end

                    pcall(function()
                        Arg370.Enabled = false

                        if Arg370:IsA("Light") then
                            Arg370.Brightness = 0

                            return
                        end

                        if Arg370:IsA("ParticleEmitter") then
                            Arg370.Rate = 0
                        end
                    end)

                    return
                end
            end
        end
        local function PenFetchSave()
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local VarV3549 = PlayerGui and PlayerGui:FindFirstChild("HUD")
            local VarV3550 = VarV3549 and VarV3549:FindFirstChild("GameHUD")
            local VarV3551 = VarV3550 and VarV3550:FindFirstChild("BottomLeft")
            local VarV3552 = VarV3551 and VarV3551:FindFirstChild("Money")
            local VarV3553 = VarV3552 and VarV3552:FindFirstChild("Value")

            if VarV3553 and ((VarV3553:IsA("TextLabel") or VarV3553:IsA("TextButton")) and VarV3553.Text ~= "") then
                return VarV3553.Text
            end

            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local VarV3555 = leaderstats and (leaderstats:FindFirstChild("Money") or (leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")))

            if VarV3555 and VarV3555:IsA("ValueBase") then
                return "$" .. FmtAbbrev(VarV3555.Value)
            end

            return "—"
        end
        local function PenReadOwned()
            local Clock19 = os.clock()

            if EspState.penSnap and Clock19 - (EspState.penAt or 0) < 2.5 then
                return EspState.penSnap
            end

            if EspState.penBusy then
                return EspState.penSnap
            end

            EspState.penAt = Clock19
            EspState.penBusy = true
            task.spawn(function()
                local VarU4748
                pcall(function()
                    local VarV4887 = RequireShared({ "Remotes" })
                    local VarV4888 = VarV4887 and (VarV4887.PenRoster and UnwrapRemote(VarV4887.PenRoster.AskLiveSnapshot))

                    if not VarV4888 then
                        return
                    end

                    local VarV4889 = VarV4888:InvokeServer()

                    if type(VarV4889) ~= "table" then
                        return
                    end

                    for _, v in pairs(VarV4889) do
                        if type(v) == "table" and tonumber(v.OwnerUserId) == LocalPlayer.UserId then
                            VarU4748 = v

                            return
                        end
                    end
                end)
                if VarU4748 then
                    EspState.penSnap = VarU4748
                end
                EspState.penBusy = false
            end)

            return EspState.penSnap
        end
        local Tab238 = {
			"Money",
			"Income",
			"Pen",
			"Best pet",
			"Best egg",
			"Speed",
			"Session"
		}
        local function StatsPanelRefresh()
            if EspState.statsFrame and EspState.statsFrame.Parent then
                local statsRows = EspState.statsRows

                if type(statsRows) == "table" and statsRows.Money and statsRows.Money.Parent and statsRows.Session and statsRows.Session.Parent and EspState.statsFrame.Size.X.Offset >= 240 then
                    return EspState.statsFrame
                end

                pcall(function()
                    EspState.statsFrame:Destroy()
                end)
                EspState.statsFrame = nil
                EspState.statsRows = nil
            end
            local StatsPanel = ScreenGui:FindFirstChild("StatsPanel")
            if StatsPanel then
                pcall(function()
                    StatsPanel:Destroy()
                end)
            end
            local Tab239 = {
				Name = "StatsPanel",
				BackgroundColor3 = Theme.card,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(16, 72),
				Size = UDim2.fromOffset(248, 222),
				ZIndex = 40,
				Active = true,
				Visible = false,
				ClipsDescendants = false
			}
            local VarV3560 = ScreenGui
            local Frame = Instance.new("Frame")
            if Tab239 then
                for k, v in pairs(Tab239) do
                    Frame[k] = v
                end
            end
            if VarV3560 then
                Frame.Parent = VarV3560
            end
            local VarV3564 = Frame
            local Tab240 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner = Instance.new("UICorner")
            if Tab240 then
                for k, v in pairs(Tab240) do
                    UICorner[k] = v
                end
            end
            if VarV3564 then
                UICorner.Parent = VarV3564
            end
            local State20 = "line"
            local Tab241 = {
				Color = Theme.line or Theme.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke = Instance.new("UIStroke")
            if Tab241 then
                for k, v in pairs(Tab241) do
                    UIStroke[k] = v
                end
            end
            if VarV3564 then
                UIStroke.Parent = VarV3564
            end
            if State20 then
                UIStroke:SetAttribute("th_stroke", State20)
            end
            if VarV3564 then
                VarV3564:SetAttribute("th_bg", "card")

                local card = Theme.card

                if card and VarV3564:IsA("GuiObject") then
                    VarV3564.BackgroundColor3 = card
                end
            end
            local Tab242 = {
				BackgroundColor3 = Theme.rail,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				Font = Fonts.mid,
				Text = "  Stats",
				TextColor3 = Theme.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 9,
				Active = true
			}
            local TextLabel = Instance.new("TextLabel")
            if Tab242 then
                for k, v in pairs(Tab242) do
                    TextLabel[k] = v
                end
            end
            if VarV3564 then
                TextLabel.Parent = VarV3564
            end
            local Tab243 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner14 = Instance.new("UICorner")
            if Tab243 then
                for k, v in pairs(Tab243) do
                    UICorner14[k] = v
                end
            end
            if TextLabel then
                UICorner14.Parent = TextLabel
            end
            if TextLabel then
                TextLabel:SetAttribute("th_bg", "rail")

                local rail = Theme.rail

                if rail and TextLabel:IsA("GuiObject") then
                    TextLabel.BackgroundColor3 = rail
                end
            end
            if TextLabel then
                TextLabel:SetAttribute("th_text", "text")

                local text = Theme.text

                if text then
                    TextLabel.TextColor3 = text
                end
            end
            local Tab244 = {
				BackgroundColor3 = Theme.rail,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 16),
				Size = UDim2.new(1, 0, 0, 10),
				ZIndex = 9
			}
            local Frame28 = Instance.new("Frame")
            if Tab244 then
                for k, v in pairs(Tab244) do
                    Frame28[k] = v
                end
            end
            if TextLabel then
                Frame28.Parent = TextLabel
            end
            local Frame29 = TextLabel:FindFirstChildOfClass("Frame")
            if Frame29 then
                Frame29:SetAttribute("th_bg", "rail")

                local rail = Theme.rail

                if rail and Frame29:IsA("GuiObject") then
                    Frame29.BackgroundColor3 = rail
                end
            end
            local Tab245 = {}
            local Num48 = 28
            for _, v in ipairs(Tab238) do
                local VarV3595 = v == "Best pet" or v == "Best egg"
                local VarV3596 = not VarV3595 and 18 or 34
                local Tab246 = {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(10, Num48),
					Size = UDim2.fromOffset(72, VarV3596),
					Font = Fonts.body,
					Text = v,
					TextColor3 = Theme.dim,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					ZIndex = 9
				}
                local TextLabel12 = Instance.new("TextLabel")

                if Tab246 then
                    for k, VarV17 in pairs(Tab246) do
                        TextLabel12[k] = VarV17
                    end
                end

                if VarV3564 then
                    TextLabel12.Parent = VarV3564
                end

                if TextLabel12 then
                    TextLabel12:SetAttribute("th_text", "dim")

                    local dim = Theme.dim

                    if dim then
                        TextLabel12.TextColor3 = dim
                    end
                end

                local Tab247 = {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(82, Num48),
					Size = UDim2.fromOffset(156, VarV3596),
					Font = Fonts.mono,
					Text = "—",
					TextColor3 = Theme.text,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = VarV3595,
					TextTruncate = VarV3595 and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd,
					ZIndex = 9
				}
                local TextLabel13 = Instance.new("TextLabel")

                if Tab247 then
                    for k, VarV19 in pairs(Tab247) do
                        TextLabel13[k] = VarV19
                    end
                end

                if VarV3564 then
                    TextLabel13.Parent = VarV3564
                end

                if TextLabel13 then
                    TextLabel13:SetAttribute("th_text", "text")

                    local text = Theme.text

                    if text then
                        TextLabel13.TextColor3 = text
                    end
                end

                Tab245[v] = TextLabel13
                Num48 += not VarV3595 and 21 or 38
            end
            VarV3564.Size = UDim2.fromOffset(248, Num48 + 8)
            local VarU3607
            local inputPosition2
            local Position3
            TextLabel.InputBegan:Connect(function(input)
                local UserInputType = input.UserInputType

                if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                    VarU3607 = true
                    inputPosition2 = input.Position
                    Position3 = VarV3564.Position
                end
            end)
            if not EspState.statsDrag then
                local VarV3610 = EspState
                local connection12 = UserInputService.InputChanged:Connect(function(input)
                    if not VarU3607 then
                        return
                    end

                    local UserInputType = input.UserInputType

                    if UserInputType ~= Enum.UserInputType.MouseMovement and UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    if not EspState.statsFrame or not EspState.statsFrame.Parent then
                        VarU3607 = false

                        return
                    end

                    local VarV4753 = input.Position - inputPosition2

                    EspState.statsFrame.Position = UDim2.new(Position3.X.Scale, Position3.X.Offset + VarV4753.X, Position3.Y.Scale, Position3.Y.Offset + VarV4753.Y)

                    if EspState.sellFrame and EspState.sellFrame.Visible and not EspState.sellMoved then
                        VarU2116(EspState.sellFrame)
                    end
                end)

                if connection12 then
                    ConnList[connection12] = true
                end

                VarV3610.statsDrag = connection12

                local VarV3612 = EspState
                local connection13 = UserInputService.InputEnded:Connect(function(input)
                    local UserInputType = input.UserInputType

                    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                        VarU3607 = false
                    end
                end)

                if connection13 then
                    ConnList[connection13] = true
                end

                VarV3612.statsEnd = connection13
            end
            EspState.statsFrame = VarV3564
            EspState.statsRows = Tab245

            return VarV3564
        end
        local function StatsLeaderVals(Arg371)
            if not Arg371 then
                if EspState.statsFrame then
                    EspState.statsFrame.Visible = false
                end

                return
            end

            local VarV3615 = StatsPanelRefresh()

            if VarV3615 then
                VarV3615.Visible = true
            end
        end
        local function StatsEnsurePanel()
            if not Config.StatsPanel then
                if EspState.statsFrame and EspState.statsFrame.Visible then
                    EspState.statsFrame.Visible = false
                end

                return
            end
            local Clock20 = os.clock()
            if u1202 then
                u1202 = false
                EspState.statsAt = 0
                EspState.ownerAt = 0
                pcall(v1204, true)
            elseif Clock20 - (EspState.statsAt or 0) < 0.35 then
                return
            end
            EspState.statsAt = Clock20
            local VarV3617 = StatsPanelRefresh()
            if not VarV3617 then
                return
            end
            VarV3617.Visible = true
            if EspState.sellFrame and EspState.sellFrame.Visible and not EspState.sellMoved then
                VarU2116(EspState.sellFrame)
            end
            local statsRows = EspState.statsRows
            if type(statsRows) ~= "table" then
                return
            end
            local VarV3619 = math.max(0, math.floor(Clock20 - (EspState.sessionAt or Clock20)))
            local VarV3620 = math.floor(VarV3619 / 3600)
            local VarV3621 = math.floor(VarV3619 % 3600 / 60)
            local VarV3622 = VarV3619 % 60
            local VarV3623 = VarV3620 > 0 and string.format("%d:%02d:%02d", VarV3620, VarV3621, VarV3622) or string.format("%d:%02d", VarV3621, VarV3622)
            local Num49 = 0
            pcall(function()
                Num49 = tonumber(StealState.banked) or 0
            end)
            local VarV3625 = VarV3623 .. " · " .. tostring(Num49) .. " stolen"
            local Session = statsRows.Session
            if Session and Session.Parent then
                Session.Text = tostring(VarV3625)
            end
            pcall(function()
                local VarV4759 = PenFetchSave()
                local Money = statsRows.Money

                if Money and Money.Parent then
                    Money.Text = tostring(VarV4759)
                end
            end)
            pcall(function()
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                local VarV4762 = leaderstats and leaderstats:FindFirstChild("Money/s")
                local VarV4763 = leaderstats and leaderstats:FindFirstChild("Speed")
                local VarV4764 = VarV4762 and FmtAbbrev(VarV4762.Value) .. "/s" or "—"
                local Income = statsRows.Income

                if Income and Income.Parent then
                    Income.Text = tostring(VarV4764)
                end

                local VarV4766 = VarV4763 and FmtAbbrev(VarV4763.Value) or "—"
                local statsRowsSpeed = statsRows.Speed

                if statsRowsSpeed and statsRowsSpeed.Parent then
                    statsRowsSpeed.Text = tostring(VarV4766)
                end
            end)
            if not EspState.ownerBusy and Clock20 - (EspState.ownerAt or 0) > 1.5 then
                EspState.ownerAt = Clock20
                EspState.ownerBusy = true
                task.spawn(function()
                    local Num50 = 0
                    local Num51 = 0

                    pcall(function()
                        local VarV4892 = ListPlotFolders()

                        if type(VarV4892) == "table" then
                            for _, v in pairs(VarV4892) do
                                if type(v) == "table" then
                                    Num51 += 1

                                    if v.Placement then
                                        Num50 += 1
                                    end
                                end
                            end
                        end
                    end)

                    local VarV4770 = EspState
                    local VarV4771 = EspState

                    VarV4770.ownedN = Num51
                    VarV4771.placedN = Num50
                    EspState.ownerBusy = false
                end)
            end
            local Num52 = 0
            local VarU3628
            local Num53 = 0
            pcall(function()
                local VarV4772 = PenReadOwned()

                if VarV4772 and type(VarV4772.Records) == "table" then
                    for _, v in pairs(VarV4772.Records) do
                        if type(v) == "table" then
                            Num52 += 1

                            local VarV4775 = v1193
                            local VarV4776

                            if type(v) ~= "table" then
                                VarV4776 = nil
                            elseif v.AssetCategory then
                                VarV4776 = v.AssetCategory
                            else
                                local ItemData = v.ItemData

                                VarV4776 = if type(ItemData) ~= "table" then nil else ItemData.Category or (ItemData.AssetCategory or (ItemData.Name or ItemData.DisplayName))
                            end

                            local VarV4778 = VarV4775(v, if not not Directory and VarV4776 then Directory[VarV4776] else nil)

                            if VarV4778 > Num53 then
                                Num53 = VarV4778

                                local VarV4779

                                if type(v) ~= "table" then
                                    VarV4779 = nil
                                elseif v.AssetCategory then
                                    VarV4779 = v.AssetCategory
                                else
                                    local ItemData = v.ItemData

                                    VarV4779 = if type(ItemData) ~= "table" then nil else ItemData.Category or (ItemData.AssetCategory or (ItemData.Name or ItemData.DisplayName))
                                end

                                local State21

                                if not VarV4779 then
                                    State21 = "?"
                                else
                                    local VarV4782 = if not not Directory and VarV4779 then Directory[VarV4779] else nil

                                    State21 = VarV4782 and (VarV4782.DisplayName or type(VarV4782.Egg) == "table" and VarV4782.Egg.DisplayName) or tostring(VarV4779)
                                end

                                VarU3628 = State21
                            end
                        end
                    end
                end
            end)
            local VarV3630 = tonumber(EspState.placedN) or 0
            if Num52 > 0 then
                local VarV3631 = tostring(Num52) .. " pets · " .. tostring(VarV3630) .. " eggs"
                local Pen = statsRows.Pen

                if Pen and Pen.Parent then
                    Pen.Text = tostring(VarV3631)
                end
            else
                local VarV3633 = tostring(VarV3630) .. " placed"
                local Pen = statsRows.Pen

                if Pen and Pen.Parent then
                    Pen.Text = tostring(VarV3633)
                end
            end
            if VarU3628 then
                local VarV3635 = tostring(VarU3628) .. "\n" .. FmtAbbrev(Num53) .. "/s"
                local VarV3636 = statsRows["Best pet"]

                if VarV3636 and VarV3636.Parent then
                    VarV3636.Text = tostring(VarV3635)
                end
            else
                local VarV3637 = statsRows["Best pet"]

                if VarV3637 and VarV3637.Parent then
                    VarV3637.Text = tostring("—")
                end
            end
            local VarU3638
            local Num54 = 0
            pcall(function()
                local VarV4783 = v1204()

                if type(VarV4783) ~= "table" then
                    VarV4783 = t195
                end

                for _, v in ipairs(VarV4783) do
                    if type(v) == "table" and ((v.State == "Slot" or v.State == "Dropped") and not PlotIsOwnedPlaced(v)) then
                        local AssetCategory = v.AssetCategory
                        local VarV4787 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                        local VarV4788 = v1193(v, VarV4787)

                        if VarV4788 > Num54 then
                            Num54 = VarV4788
                            VarU3638 = VarV4787 and (VarV4787.DisplayName or type(VarV4787.Egg) == "table" and VarV4787.Egg.DisplayName) or v.AssetCategory
                        end
                    end
                end
            end)
            if VarU3638 then
                local VarV3640 = tostring(VarU3638) .. "\n" .. FmtAbbrev(Num54) .. "/s"
                local VarV3641 = statsRows["Best egg"]

                if VarV3641 and VarV3641.Parent then
                    VarV3641.Text = tostring(VarV3640)
                end
            else
                local VarV3642 = statsRows["Best egg"]

                if VarV3642 and VarV3642.Parent then
                    VarV3642.Text = tostring("—")
                end
            end
        end
        local function SellPreviewFill(Arg372)
            local cfg = Arg372.cfg
            local VarV3648
            if type(cfg) == "table" then
                VarV3648 = cfg.DisplayName or (type(cfg.Egg) ~= "table" or cfg.Egg.DisplayName)
            end
            if not VarV3648 or VarV3648 == "" then
                VarV3648 = Arg372.cat or "?"
            end
            local StrId27 = tostring(VarV3648)
            local cfg2 = Arg372.cfg
            local VarV3651 = if type(cfg2) == "table" and type(cfg2.Rarity) == "table" then tostring(cfg2.Rarity.DisplayName or (cfg2.Rarity.Name or (cfg2.Rarity._id or "?"))) else "?"
            local num = tonumber((EspEggStats(Arg372.rec, Arg372.cfg)))
            local VarV3653 = if num then if not (num >= 100) then string.format("%.1fkg", num) else string.format("%.0fkg", num) else nil
            local State22 = ""
            local rec = Arg372.rec
            if type(rec) == "table" and type(rec.Mutations) == "table" and #rec.Mutations > 0 then
                State22 = table.concat(rec.Mutations, " · ")
            end
            local VarV3656 = FmtAbbrev(Arg372.earn) .. "/s · " .. VarV3651
            if VarV3653 then
                VarV3656 ..= " · " .. VarV3653
            end
            local VarV3657 = VarV3656 .. " · " .. tostring(Arg372.kind)
            local VarV3658 = "×" .. tostring(Arg372.n or 1)
            if (Arg372.price or 0) > 0 then
                VarV3658 ..= " · $" .. FmtAbbrev(Arg372.price)
            end
            if State22 ~= "" then
                VarV3658 ..= " · " .. State22
            end

            return StrId27, VarV3657, VarV3658
        end
        local function SellPreviewEnsure()
            if EspState.sellDrag then
                pcall(function()
                    EspState.sellDrag:Disconnect()
                end)
                EspState.sellDrag = nil
            end

            if EspState.sellEnd then
                pcall(function()
                    EspState.sellEnd:Disconnect()
                end)
                EspState.sellEnd = nil
            end

            if EspState.sellFrame then
                pcall(function()
                    EspState.sellFrame:Destroy()
                end)
                EspState.sellFrame = nil
            end

            EspState.sellTips = nil
            EspState.sellMoved = nil
            EspState.sellPos = nil

            local SellPreviewPanel = ScreenGui:FindFirstChild("SellPreviewPanel")

            if SellPreviewPanel then
                pcall(function()
                    SellPreviewPanel:Destroy()
                end)
            end

            local statsFrame = EspState.statsFrame

            if statsFrame then
                local VarV3661 = statsFrame:FindFirstChild("SellPreviewPanel") or statsFrame:FindFirstChild("SellPreview")

                if VarV3661 then
                    pcall(function()
                        VarV3661:Destroy()
                    end)
                end
            end
        end
        function VarU2116(Arg373)
            local VarV3663 = Arg373 or EspState.sellFrame

            if not VarV3663 or not VarV3663.Parent then
                return
            end

            if VarV3663.Parent ~= ScreenGui then
                VarV3663.Parent = ScreenGui
            end

            VarV3663.AnchorPoint = Vector2.new(0, 0)
            VarV3663.Size = UDim2.fromOffset(248, 348)
            VarV3663.ZIndex = 90
            VarV3663.Visible = true

            if EspState.sellMoved and EspState.sellPos then
                VarV3663.Position = EspState.sellPos

                return
            end

            local statsFrame = EspState.statsFrame

            if statsFrame and statsFrame.Parent and statsFrame.Visible then
                local AbsolutePosition = ScreenGui.AbsolutePosition
                local AbsolutePosition2 = statsFrame.AbsolutePosition
                local AbsoluteSize2 = statsFrame.AbsoluteSize

                VarV3663.Position = UDim2.fromOffset(AbsolutePosition2.X - AbsolutePosition.X, AbsolutePosition2.Y - AbsolutePosition.Y + AbsoluteSize2.Y + 8)

                return
            end

            VarV3663.Position = UDim2.fromOffset(16, 258)
        end
        local function SellPreviewHide()
            if EspState.sellFrame and (EspState.sellFrame.Parent and EspState.sellTips and EspState.sellTips.pets and EspState.sellTips.eggs) then
                if not ((EspState.sellFrame.AbsoluteSize.Y or 0) < 320) then
                    VarU2116(EspState.sellFrame)

                    return EspState.sellFrame
                end

                SellPreviewEnsure()
            end
            SellPreviewEnsure()
            local Tab248 = {
				Name = "SellPreviewPanel",
				BackgroundColor3 = Theme.card,
				BorderSizePixel = 0,
				BackgroundTransparency = 0,
				ClipsDescendants = true,
				Size = UDim2.fromOffset(248, 348),
				ZIndex = 90,
				Active = true,
				Visible = true
			}
            local VarV3669 = ScreenGui
            local Frame = Instance.new("Frame")
            if Tab248 then
                for k, v in pairs(Tab248) do
                    Frame[k] = v
                end
            end
            if VarV3669 then
                Frame.Parent = VarV3669
            end
            local VarV3673 = Frame
            local Tab249 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner = Instance.new("UICorner")
            if Tab249 then
                for k, v in pairs(Tab249) do
                    UICorner[k] = v
                end
            end
            if VarV3673 then
                UICorner.Parent = VarV3673
            end
            local State23 = "line"
            local Tab250 = {
				Color = Theme.line or Theme.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke = Instance.new("UIStroke")
            if Tab250 then
                for k, v in pairs(Tab250) do
                    UIStroke[k] = v
                end
            end
            if VarV3673 then
                UIStroke.Parent = VarV3673
            end
            if State23 then
                UIStroke:SetAttribute("th_stroke", State23)
            end
            if VarV3673 then
                VarV3673:SetAttribute("th_bg", "card")

                local card = Theme.card

                if card and VarV3673:IsA("GuiObject") then
                    VarV3673.BackgroundColor3 = card
                end
            end
            VarU2116(VarV3673)
            local Tab251 = {
				BackgroundColor3 = Theme.rail,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				Font = Fonts.mid,
				Text = "  Sell preview",
				TextColor3 = Theme.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				ZIndex = 60,
				Active = true
			}
            local TextButton = Instance.new("TextButton")
            if Tab251 then
                for k, v in pairs(Tab251) do
                    TextButton[k] = v
                end
            end
            if VarV3673 then
                TextButton.Parent = VarV3673
            end
            local Tab252 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner15 = Instance.new("UICorner")
            if Tab252 then
                for k, v in pairs(Tab252) do
                    UICorner15[k] = v
                end
            end
            if TextButton then
                UICorner15.Parent = TextButton
            end
            if TextButton then
                TextButton:SetAttribute("th_bg", "rail")

                local rail = Theme.rail

                if rail and TextButton:IsA("GuiObject") then
                    TextButton.BackgroundColor3 = rail
                end
            end
            if TextButton then
                TextButton:SetAttribute("th_text", "text")

                local text = Theme.text

                if text then
                    TextButton.TextColor3 = text
                end
            end
            local Tab253 = {
				BackgroundColor3 = Theme.rail,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 16),
				Size = UDim2.new(1, 0, 0, 10),
				ZIndex = 60,
				Active = false
			}
            local Frame30 = Instance.new("Frame")
            if Tab253 then
                for k, v in pairs(Tab253) do
                    Frame30[k] = v
                end
            end
            if TextButton then
                Frame30.Parent = TextButton
            end
            local Frame31 = TextButton:FindFirstChildOfClass("Frame")
            if Frame31 then
                Frame31:SetAttribute("th_bg", "rail")

                local rail = Theme.rail

                if rail and Frame31:IsA("GuiObject") then
                    Frame31.BackgroundColor3 = rail
                end
            end
            local Tab254 = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme.fill,
				Position = UDim2.new(1, -6, 0.5, 0),
				Size = UDim2.fromOffset(20, 20),
				Font = Fonts.mid,
				Text = "×",
				TextColor3 = Theme.text,
				TextSize = 14,
				AutoButtonColor = false,
				ZIndex = 61,
				Active = true
			}
            local TextButton2 = Instance.new("TextButton")
            if Tab254 then
                for k, v in pairs(Tab254) do
                    TextButton2[k] = v
                end
            end
            if TextButton then
                TextButton2.Parent = TextButton
            end
            local VarV3704 = TextButton2
            local Tab255 = {
				CornerRadius = UDim.new(0, 6)
			}
            local UICorner16 = Instance.new("UICorner")
            if Tab255 then
                for k, v in pairs(Tab255) do
                    UICorner16[k] = v
                end
            end
            if VarV3704 then
                UICorner16.Parent = VarV3704
            end
            local State24 = "line"
            local Tab256 = {
				Color = Theme.line or Theme.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke12 = Instance.new("UIStroke")
            if Tab256 then
                for k, v in pairs(Tab256) do
                    UIStroke12[k] = v
                end
            end
            if VarV3704 then
                UIStroke12.Parent = VarV3704
            end
            if State24 then
                UIStroke12:SetAttribute("th_stroke", State24)
            end
            if VarV3704 then
                VarV3704:SetAttribute("th_bg", "fill")

                local fill = Theme.fill

                if fill and VarV3704:IsA("GuiObject") then
                    VarV3704.BackgroundColor3 = fill
                end
            end
            if VarV3704 then
                VarV3704:SetAttribute("th_text", "text")

                local text = Theme.text

                if text then
                    VarV3704.TextColor3 = text
                end
            end
            bindHoverTheme(VarV3704, "fill", "lift")
            VarV3704.MouseButton1Click:Connect(function()
                if EspState.sellFrame then
                    EspState.sellFrame.Visible = false
                end
            end)
            local Tab257 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(10, 28),
				Size = UDim2.new(1, -20, 0, 16),
				Font = Fonts.body,
				Text = "",
				TextColor3 = Theme.dim,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 41
			}
            local TextLabel = Instance.new("TextLabel")
            if Tab257 then
                for k, v in pairs(Tab257) do
                    TextLabel[k] = v
                end
            end
            if VarV3673 then
                TextLabel.Parent = VarV3673
            end
            if TextLabel then
                TextLabel:SetAttribute("th_text", "dim")

                local dim = Theme.dim

                if dim then
                    TextLabel.TextColor3 = dim
                end
            end
            local Tab258 = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(8, 46),
				Size = UDim2.new(1, -16, 1, -102),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 4,
				ScrollBarImageColor3 = Theme.line,
				ClipsDescendants = true,
				ZIndex = 41
			}
            local ScrollingFrame = Instance.new("ScrollingFrame")
            if Tab258 then
                for k, v in pairs(Tab258) do
                    ScrollingFrame[k] = v
                end
            end
            if VarV3673 then
                ScrollingFrame.Parent = VarV3673
            end
            local VarV3725 = ScrollingFrame
            local Tab259 = {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			}
            local UIListLayout = Instance.new("UIListLayout")
            if Tab259 then
                for k, v in pairs(Tab259) do
                    UIListLayout[k] = v
                end
            end
            if VarV3725 then
                UIListLayout.Parent = VarV3725
            end
            local function Fn_3730(Arg374, Arg375)
                local Tab260 = {
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					LayoutOrder = Arg374,
					ZIndex = 42
				}
                local VarV4792 = VarV3725
                local Frame32 = Instance.new("Frame")

                if Tab260 then
                    for k, v in pairs(Tab260) do
                        Frame32[k] = v
                    end
                end

                if VarV4792 then
                    Frame32.Parent = VarV4792
                end

                local Tab261 = {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder
				}
                local UIListLayout3 = Instance.new("UIListLayout")

                if Tab261 then
                    for k, v in pairs(Tab261) do
                        UIListLayout3[k] = v
                    end
                end

                if Frame32 then
                    UIListLayout3.Parent = Frame32
                end

                local Tab262 = {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 14),
					Font = Fonts.mono,
					Text = Arg375,
					TextColor3 = Theme.dim,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 1,
					ZIndex = 42
				}
                local TextLabel14 = Instance.new("TextLabel")

                if Tab262 then
                    for k, v in pairs(Tab262) do
                        TextLabel14[k] = v
                    end
                end

                if Frame32 then
                    TextLabel14.Parent = Frame32
                end

                if TextLabel14 then
                    TextLabel14:SetAttribute("th_text", "dim")

                    local dim = Theme.dim

                    if dim then
                        TextLabel14.TextColor3 = dim
                    end
                end

                local Tab263 = {
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					LayoutOrder = 2,
					ZIndex = 42
				}
                local Frame33 = Instance.new("Frame")

                if Tab263 then
                    for k, v in pairs(Tab263) do
                        Frame33[k] = v
                    end
                end

                if Frame32 then
                    Frame33.Parent = Frame32
                end

                local VarV4809 = Frame33
                local Tab264 = {
					CellPadding = UDim2.fromOffset(4, 4),
					CellSize = UDim2.fromOffset(40, 40),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder
				}
                local UIGridLayout = Instance.new("UIGridLayout")

                if Tab264 then
                    for k, v in pairs(Tab264) do
                        UIGridLayout[k] = v
                    end
                end

                if VarV4809 then
                    UIGridLayout.Parent = VarV4809
                end

                local UIGridLayout2 = VarV4809:FindFirstChildOfClass("UIGridLayout")

                local function Fn_4815()
                    if not VarV4809 or not UIGridLayout2 then
                        return
                    end

                    local VarV4895 = math.max(0, math.ceil(UIGridLayout2.AbsoluteContentSize.Y))

                    VarV4809.AutomaticSize = Enum.AutomaticSize.None
                    VarV4809.Size = UDim2.new(1, 0, 0, VarV4895)
                end

                if UIGridLayout2 then
                    UIGridLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Fn_4815)
                end

                return {
					lab = TextLabel14,
					grid = VarV4809,
					title = Arg375,
					fit = Fn_4815
				}
            end
            local VarV3731 = Fn_3730(1, "Pets")
            local VarV3732 = Fn_3730(2, "Eggs")
            local Tab265 = {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = Theme.card,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0, 56),
				ClipsDescendants = true,
				ZIndex = 50
			}
            local Frame34 = Instance.new("Frame")
            if Tab265 then
                for k, v in pairs(Tab265) do
                    Frame34[k] = v
                end
            end
            if VarV3673 then
                Frame34.Parent = VarV3673
            end
            if Frame34 then
                Frame34:SetAttribute("th_bg", "card")

                local card = Theme.card

                if card and Frame34:IsA("GuiObject") then
                    Frame34.BackgroundColor3 = card
                end
            end
            local Tab266 = {
				BackgroundColor3 = Theme.line,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 51
			}
            local Frame35 = Instance.new("Frame")
            if Tab266 then
                for k, v in pairs(Tab266) do
                    Frame35[k] = v
                end
            end
            if Frame34 then
                Frame35.Parent = Frame34
            end
            if Frame35 then
                Frame35:SetAttribute("th_bg", "line")

                local line = Theme.line

                if line and Frame35:IsA("GuiObject") then
                    Frame35.BackgroundColor3 = line
                end
            end
            local Tab267 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 1),
				Size = UDim2.new(1, 0, 1, -1),
				ZIndex = 51
			}
            local Frame36 = Instance.new("Frame")
            if Tab267 then
                for k, v in pairs(Tab267) do
                    Frame36[k] = v
                end
            end
            if Frame34 then
                Frame36.Parent = Frame34
            end
            local Tab268 = {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6)
			}
            local UIPadding = Instance.new("UIPadding")
            if Tab268 then
                for k, v in pairs(Tab268) do
                    UIPadding[k] = v
                end
            end
            if Frame36 then
                UIPadding.Parent = Frame36
            end
            local Tab269 = {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			}
            local UIListLayout4 = Instance.new("UIListLayout")
            if Tab269 then
                for k, v in pairs(Tab269) do
                    UIListLayout4[k] = v
                end
            end
            if Frame36 then
                UIListLayout4.Parent = Frame36
            end
            local Tab270 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 14),
				Font = Fonts.mid,
				Text = "Hover icon to display stats",
				TextColor3 = Theme.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				LayoutOrder = 1,
				ZIndex = 52
			}
            local TextLabel15 = Instance.new("TextLabel")
            if Tab270 then
                for k, v in pairs(Tab270) do
                    TextLabel15[k] = v
                end
            end
            if Frame36 then
                TextLabel15.Parent = Frame36
            end
            if TextLabel15 then
                TextLabel15:SetAttribute("th_text", "text")

                local text = Theme.text

                if text then
                    TextLabel15.TextColor3 = text
                end
            end
            local Tab271 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 13),
				Font = Fonts.mono,
				Text = "",
				TextColor3 = Theme.dim,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				LayoutOrder = 2,
				ZIndex = 52
			}
            local TextLabel16 = Instance.new("TextLabel")
            if Tab271 then
                for k, v in pairs(Tab271) do
                    TextLabel16[k] = v
                end
            end
            if Frame36 then
                TextLabel16.Parent = Frame36
            end
            if TextLabel16 then
                TextLabel16:SetAttribute("th_text", "dim")

                local dim = Theme.dim

                if dim then
                    TextLabel16.TextColor3 = dim
                end
            end
            local Tab272 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 13),
				Font = Fonts.body,
				Text = "",
				TextColor3 = Theme.mute,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				LayoutOrder = 3,
				ZIndex = 52
			}
            local TextLabel17 = Instance.new("TextLabel")
            if Tab272 then
                for k, v in pairs(Tab272) do
                    TextLabel17[k] = v
                end
            end
            if Frame36 then
                TextLabel17.Parent = Frame36
            end
            if TextLabel17 then
                TextLabel17:SetAttribute("th_text", "mute")

                local mute = Theme.mute

                if mute then
                    TextLabel17.TextColor3 = mute
                end
            end
            EspState.sellTips = {
				name = TextLabel15,
				a = TextLabel16,
				b = TextLabel17,
				sub = TextLabel,
				pets = VarV3731,
				eggs = VarV3732
			}
            local VarU3770
            local inputPosition3
            local Position4
            TextButton.InputBegan:Connect(function(input)
                local UserInputType = input.UserInputType

                if UserInputType ~= Enum.UserInputType.MouseButton1 and UserInputType ~= Enum.UserInputType.Touch then
                    return
                end

                local inputPosition4 = input.Position
                local AbsolutePosition = VarV3704.AbsolutePosition
                local AbsoluteSize3 = VarV3704.AbsoluteSize

                if inputPosition4.X >= AbsolutePosition.X and inputPosition4.X <= AbsolutePosition.X + AbsoluteSize3.X and inputPosition4.Y >= AbsolutePosition.Y and inputPosition4.Y <= AbsolutePosition.Y + AbsoluteSize3.Y then
                    return
                end

                VarU3770 = true
                inputPosition3 = input.Position
                Position4 = VarV3673.Position
                EspState.sellMoved = true
                EspState.sellPos = Position4
            end)
            if not EspState.sellDrag then
                local VarV3773 = EspState
                local connection14 = UserInputService.InputChanged:Connect(function(input)
                    if not VarU3770 then
                        return
                    end

                    local UserInputType = input.UserInputType

                    if UserInputType ~= Enum.UserInputType.MouseMovement and UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    if not EspState.sellFrame or not EspState.sellFrame.Parent or not Position4 or not inputPosition3 then
                        VarU3770 = false

                        return
                    end

                    local VarV4823 = input.Position - inputPosition3
                    local uDim2 = UDim2.new(Position4.X.Scale, Position4.X.Offset + VarV4823.X, Position4.Y.Scale, Position4.Y.Offset + VarV4823.Y)

                    EspState.sellFrame.Position = uDim2
                    EspState.sellPos = uDim2
                end)

                if connection14 then
                    ConnList[connection14] = true
                end

                VarV3773.sellDrag = connection14

                local VarV3775 = EspState
                local connection15 = UserInputService.InputEnded:Connect(function(input)
                    local UserInputType = input.UserInputType

                    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                        VarU3770 = false

                        if EspState.sellFrame then
                            EspState.sellPos = EspState.sellFrame.Position
                        end
                    end
                end)

                if connection15 then
                    ConnList[connection15] = true
                end

                VarV3775.sellEnd = connection15
            end
            EspState.sellFrame = VarV3673

            return VarV3673
        end
        local function Esp_Fn_2153(Arg376, Arg377, Arg378)
            local Flag3804
            local VarV3803
            for _, child in ipairs(Arg376.grid:GetChildren()) do
                if child:IsA("GuiObject") then
                    child:Destroy()
                end
            end
            if #Arg377 == 0 then
                Arg376.lab.Text = Arg376.title .. " · none"

                return
            end
            local Num55 = 0
            for i = 1, #Arg377 do
                Num55 += Arg377[i].n or 1
            end
            Arg376.lab.Text = Arg376.title .. " · " .. tostring(Num55)
            for i = 1, #Arg377 do
                local VarV3785 = Arg377[i]
                local VarV3786, VarV3787, VarV3788 = SellPreviewFill(VarV3785)
                local Tab273 = {
					BackgroundColor3 = Theme.fill,
					Text = "",
					AutoButtonColor = false,
					LayoutOrder = i,
					ZIndex = 43
				}
                local grid = Arg376.grid
                local TextButton = Instance.new("TextButton")

                if Tab273 then
                    for k, v in pairs(Tab273) do
                        TextButton[k] = v
                    end
                end

                if grid then
                    TextButton.Parent = grid
                end

                local Tab274 = {
					CornerRadius = UDim.new(0, 8)
				}
                local UICorner = Instance.new("UICorner")

                if Tab274 then
                    for k, v in pairs(Tab274) do
                        UICorner[k] = v
                    end
                end

                if TextButton then
                    UICorner.Parent = TextButton
                end

                if TextButton then
                    TextButton:SetAttribute("th_bg", "fill")

                    local fill = Theme.fill

                    if fill and TextButton:IsA("GuiObject") then
                        TextButton.BackgroundColor3 = fill
                    end
                end

                applyStroke(TextButton, VarV3785.kind ~= "egg" and "line" or "accent", 1)

                local cfg = VarV3785.cfg
                local cat = VarV3785.cat

                EggTooltipBind(cat, cfg)

                local VarV3801 = ThemeApply(cfg, cat)

                for j = 1, #VarV3801 do
                    VarV3803 = EspState.iconBy[VarV3801[j]]

                    if VarV3803 then
                        Flag3804 = true
                    end

                    if Flag3804 then
                        break
                    end
                end

                if not Flag3804 then
                    VarV3803 = nil
                end

                Flag3804 = false

                if VarV3803 then
                    local Tab275 = {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(4, 4),
						Size = UDim2.fromOffset(32, 32),
						Image = VarV3803,
						ScaleType = Enum.ScaleType.Fit,
						ZIndex = 44
					}
                    local ImageLabel = Instance.new("ImageLabel")

                    if Tab275 then
                        for k, v in pairs(Tab275) do
                            ImageLabel[k] = v
                        end
                    end

                    if TextButton then
                        ImageLabel.Parent = TextButton
                    end

                    ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
                else
                    local VarV3809 = string.sub(VarV3786, 1, 1)

                    if VarV3809 == "" then
                        VarV3809 = "?"
                    end

                    local Tab276 = {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						Font = Fonts.mid,
						Text = string.upper(VarV3809),
						TextColor3 = Theme.dim,
						TextSize = 14,
						ZIndex = 44
					}
                    local TextLabel = Instance.new("TextLabel")

                    if Tab276 then
                        for k, v in pairs(Tab276) do
                            TextLabel[k] = v
                        end
                    end

                    if TextButton then
                        TextLabel.Parent = TextButton
                    end

                    if TextLabel then
                        TextLabel:SetAttribute("th_text", "dim")

                        local dim = Theme.dim

                        if dim then
                            TextLabel.TextColor3 = dim
                        end
                    end
                end

                if (VarV3785.n or 1) > 1 then
                    local Tab277 = {
						AnchorPoint = Vector2.new(1, 1),
						BackgroundColor3 = Theme.accent,
						Position = UDim2.new(1, 2, 1, 2),
						Size = UDim2.fromOffset(16, 12),
						Font = Fonts.mono,
						Text = if not (VarV3785.n > 9) then tostring(VarV3785.n) else "9+",
						TextColor3 = Theme.ink,
						TextSize = 8,
						ZIndex = 45
					}
                    local TextLabel = Instance.new("TextLabel")

                    if Tab277 then
                        for k, v in pairs(Tab277) do
                            TextLabel[k] = v
                        end
                    end

                    if TextButton then
                        TextLabel.Parent = TextButton
                    end

                    local Tab278 = {
						CornerRadius = UDim.new(0, 4)
					}
                    local UICorner17 = Instance.new("UICorner")

                    if Tab278 then
                        for k, v in pairs(Tab278) do
                            UICorner17[k] = v
                        end
                    end

                    if TextLabel then
                        UICorner17.Parent = TextLabel
                    end

                    if TextLabel then
                        TextLabel:SetAttribute("th_bg", "accent")

                        local accent = Theme.accent

                        if accent and TextLabel:IsA("GuiObject") then
                            TextLabel.BackgroundColor3 = accent
                        end
                    end

                    if TextLabel then
                        TextLabel:SetAttribute("th_text", "ink")

                        local ink = Theme.ink

                        if ink then
                            TextLabel.TextColor3 = ink
                        end
                    end
                end

                TextButton.MouseEnter:Connect(function()
                    Arg378.name.Text = VarV3786
                    Arg378.a.Text = VarV3787
                    Arg378.b.Text = VarV3788
                end)
                TextButton.MouseLeave:Connect(function()
                    Arg378.name.Text = "Hover icon to display stats"
                    Arg378.a.Text = ""
                    Arg378.b.Text = ""
                end)
            end
            if Arg376.fit then
                pcall(Arg376.fit)
                task.defer(Arg376.fit)
            end
        end
        local connection16 = RunService.Stepped:Connect(function()
            if not IsAlive or EngineOn then
                return
            end

            pcall(EspTick)
        end)
        if connection16 then
            ConnList[connection16] = true
        end
        EspState.conn = connection16
        local connection17 = RunService.RenderStepped:Connect(function()
            if not IsAlive then
                return
            end

            pcall(StatsEnsurePanel)
        end)
        if connection17 then
            ConnList[connection17] = true
        end
        EspState.dieConn = connection17
        task.defer(function()
            pcall(ThemeGet)
        end)

        return {
			fps = function()
            local VarV3526 = tonumber(Config.FPSCap) or 0

            if not setfpscap then
                return
            end

            pcall(setfpscap, VarV3526 > 0 and VarV3526 or 0)
        end,
			opt = function(Arg379)
            local Lighting = game:GetService("Lighting")
            local Terrain = workspace:FindFirstChildOfClass("Terrain")

            if Arg379 then
                if not EspState.optSaved then
                    EspState.optSaved = {}
                    pcall(function()
                        EspState.optSaved.quality = settings().Rendering.QualityLevel
                    end)
                    pcall(function()
                        EspState.optSaved.savedQuality = UserSettings().GameSettings.SavedQualityLevel
                    end)
                    pcall(function()
                        EspState.optSaved.meshDetail = settings().Rendering.MeshPartDetailLevel
                    end)
                    pcall(function()
                        local GameSettings = UserSettings().GameSettings

                        EspState.optSaved.savedGfx = GameSettings.SavedQualityLevel
                    end)
                    pcall(function()
                        EspState.optSaved.shadows = Lighting.GlobalShadows
                        EspState.optSaved.brightness = Lighting.Brightness
                        EspState.optSaved.envDiff = Lighting.EnvironmentDiffuseScale
                        EspState.optSaved.envSpec = Lighting.EnvironmentSpecularScale
                        EspState.optSaved.fogEnd = Lighting.FogEnd
                        EspState.optSaved.fogStart = Lighting.FogStart
                        EspState.optSaved.clock = Lighting.ClockTime
                        EspState.optSaved.ambient = Lighting.Ambient
                        EspState.optSaved.outdoor = Lighting.OutdoorAmbient
                        EspState.optSaved.exposure = Lighting.ExposureCompensation
                    end)

                    if Terrain then
                        pcall(function()
                            EspState.optSaved.waterWave = Terrain.WaterWaveSize
                            EspState.optSaved.waterSpeed = Terrain.WaterWaveSpeed
                            EspState.optSaved.waterReflect = Terrain.WaterReflectance
                            EspState.optSaved.decoration = Terrain.Decoration
                        end)
                    end
                end

                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                end)
                pcall(function()
                    UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualityLevel.QualityLevel1
                end)
                pcall(function()
                    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
                end)
                pcall(function()
                    Lighting.GlobalShadows = false
                    Lighting.Brightness = 1
                    Lighting.EnvironmentDiffuseScale = 0
                    Lighting.EnvironmentSpecularScale = 0
                    Lighting.FogEnd = 250
                    Lighting.FogStart = 0
                    Lighting.ExposureCompensation = -0.4
                end)

                if Terrain then
                    pcall(function()
                        Terrain.WaterWaveSize = 0
                        Terrain.WaterWaveSpeed = 0
                        Terrain.WaterReflectance = 0
                        Terrain.Decoration = false
                    end)
                end

                if not EspState.optFx then
                    EspState.optFx = {}
                end

                for _, child in ipairs(Lighting:GetChildren()) do
                    if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") then
                        if EspState.optFx[child] == nil then
                            if child:IsA("PostEffect") or child:IsA("Clouds") then
                                EspState.optFx[child] = {
										Enabled = child.Enabled
									}
                            elseif child:IsA("Atmosphere") then
                                EspState.optFx[child] = {
										Density = child.Density,
										Offset = child.Offset,
										Glare = child.Glare,
										Haze = child.Haze
									}
                            elseif child:IsA("Sky") then
                                EspState.optFx[child] = {
										Parent = child.Parent
									}
                            end
                        end

                        pcall(function()
                            if child:IsA("PostEffect") or child:IsA("Clouds") then
                                child.Enabled = false

                                return
                            end

                            if child:IsA("Atmosphere") then
                                child.Density = 0
                                child.Glare = 0
                                child.Haze = 0
                            end
                        end)
                    end
                end

                pcall(function()
                    for _, descendant in ipairs(workspace:GetDescendants()) do
                        PenSnapshot(descendant)
                    end
                end)

                if EspState.optAdd then
                    pcall(function()
                        EspState.optAdd:Disconnect()
                    end)
                    EspState.optAdd = nil
                end

                EspState.optAdd = workspace.DescendantAdded:Connect(function(descendant)
                    if Config.Optimizer then
                        PenSnapshot(descendant)
                    end
                end)

                return
            end

            if EspState.optSaved then
                if EspState.optAdd then
                    pcall(function()
                        EspState.optAdd:Disconnect()
                    end)
                    EspState.optAdd = nil
                end

                pcall(function()
                    if EspState.optSaved.quality then
                        settings().Rendering.QualityLevel = EspState.optSaved.quality
                    end

                    if EspState.optSaved.savedQuality then
                        UserSettings().GameSettings.SavedQualityLevel = EspState.optSaved.savedQuality
                    end

                    if EspState.optSaved.meshDetail then
                        settings().Rendering.MeshPartDetailLevel = EspState.optSaved.meshDetail
                    end

                    Lighting.GlobalShadows = EspState.optSaved.shadows

                    if EspState.optSaved.brightness then
                        Lighting.Brightness = EspState.optSaved.brightness
                    end

                    if EspState.optSaved.envDiff then
                        Lighting.EnvironmentDiffuseScale = EspState.optSaved.envDiff
                    end

                    if EspState.optSaved.envSpec then
                        Lighting.EnvironmentSpecularScale = EspState.optSaved.envSpec
                    end

                    if EspState.optSaved.fogEnd then
                        Lighting.FogEnd = EspState.optSaved.fogEnd
                    end

                    if EspState.optSaved.fogStart then
                        Lighting.FogStart = EspState.optSaved.fogStart
                    end

                    if EspState.optSaved.exposure then
                        Lighting.ExposureCompensation = EspState.optSaved.exposure
                    end

                    if Terrain then
                        if EspState.optSaved.waterWave ~= nil then
                            Terrain.WaterWaveSize = EspState.optSaved.waterWave
                        end

                        if EspState.optSaved.waterSpeed ~= nil then
                            Terrain.WaterWaveSpeed = EspState.optSaved.waterSpeed
                        end

                        if EspState.optSaved.waterReflect ~= nil then
                            Terrain.WaterReflectance = EspState.optSaved.waterReflect
                        end

                        if EspState.optSaved.decoration ~= nil then
                            Terrain.Decoration = EspState.optSaved.decoration
                        end
                    end

                    if EspState.optFx then
                        for k, v in pairs(EspState.optFx) do
                            if k.Parent and type(v) == "table" then
                                pcall(function()
                                    if v.Enabled ~= nil then
                                        k.Enabled = v.Enabled
                                    end

                                    if v.Density then
                                        k.Density = v.Density
                                    end

                                    if v.Glare then
                                        k.Glare = v.Glare
                                    end

                                    if v.Haze then
                                        k.Haze = v.Haze
                                    end
                                end)
                            end
                        end

                        EspState.optFx = nil
                    end

                    if EspState.optInst then
                        for k, v in pairs(EspState.optInst) do
                            if k.Parent and type(v) == "table" then
                                pcall(function()
                                    if v.Enabled ~= nil then
                                        k.Enabled = v.Enabled
                                    end

                                    if v.Brightness ~= nil then
                                        k.Brightness = v.Brightness
                                    end

                                    if v.Rate ~= nil then
                                        k.Rate = v.Rate
                                    end
                                end)
                            end
                        end

                        EspState.optInst = nil
                    end
                end)
                EspState.optSaved = nil
            end
        end,
			clear = function()
            if EspState.optAdd then
                pcall(function()
                    EspState.optAdd:Disconnect()
                end)
                EspState.optAdd = nil
            end

            if EspState.conn then
                EspState.conn:Disconnect()
                EspState.conn = nil
            end

            if EspState.dieConn then
                EspState.dieConn:Disconnect()
                EspState.dieConn = nil
            end

            if EspState.statsDrag then
                pcall(function()
                    EspState.statsDrag:Disconnect()
                end)
                EspState.statsDrag = nil
            end

            if EspState.statsEnd then
                pcall(function()
                    EspState.statsEnd:Disconnect()
                end)
                EspState.statsEnd = nil
            end

            if EspState.statsFrame then
                pcall(function()
                    EspState.statsFrame:Destroy()
                end)
                EspState.statsFrame = nil
                EspState.statsRows = nil
            end

            SellPreviewEnsure()

            for _, v in pairs(EspState.pool) do
                if v.bb then
                    v.bb:Destroy()
                end

                if v.dummy then
                    pcall(function()
                        v.dummy:Destroy()
                    end)
                end
            end

            for k in pairs(EspState.pool) do
                EspState.pool[k] = nil
            end

            for _, v in ipairs({
					"att0",
					"att1",
					"beamObj",
					"tip",
					"folder",
					"world"
				}) do
                local VarV3839 = EspState[v]

                if VarV3839 then
                    pcall(function()
                        VarV3839:Destroy()
                    end)
                    EspState[v] = nil
                end
            end
        end,
			tick = EspTick,
			stats = StatsLeaderVals,
			sellPreview = function(Arg380, Arg381, Arg382)
            local VarV3828 = type(Arg380) == "table" and Arg380 or {}
            local VarV3829 = type(Arg381) == "table" and Arg381 or {}

            Config.StatsPanel = true
            pcall(StatsLeaderVals, true)
            pcall(StatsPanelRefresh)

            if EspState.statsFrame then
                EspState.statsFrame.Visible = true
                pcall(function()
                    EspState.statsFrame.ClipsDescendants = false
                end)
            end

            local Ok51, Ret51 = pcall(SellPreviewHide)
            local VarV3832 = Ok51 and Ret51 or EspState.sellFrame

            if not Ok51 then
                KozuaLog("esp", "preview build ERR", (tostring(Ret51)))
            end

            if not VarV3832 or not VarV3832.Parent then
                KozuaLog("esp", "preview missing panel")

                return false
            end

            VarU2116(VarV3832)
            VarV3832.Visible = true

            local sellTips = EspState.sellTips

            if sellTips then
                if sellTips.sub then
                    sellTips.sub.Text = tostring(Arg382 or "")
                end

                if sellTips.name then
                    sellTips.name.Text = "Hover icon to display stats"
                end

                if sellTips.a then
                    sellTips.a.Text = ""
                end

                if sellTips.b then
                    sellTips.b.Text = ""
                end

                if sellTips.pets then
                    pcall(Esp_Fn_2153, sellTips.pets, VarV3828, sellTips)
                end

                if sellTips.eggs then
                    pcall(Esp_Fn_2153, sellTips.eggs, VarV3829, sellTips)
                end
            end

            return true
        end,
			closeSellPreview = function()
            if EspState.sellFrame then
                EspState.sellFrame.Visible = false
            end
        end,
			icon = function(Arg383, Arg384)
            EggTooltipBind(Arg384, Arg383)

            local VarV3334 = ThemeApply(Arg383, Arg384)

            for i = 1, #VarV3334 do
                local VarV3336 = EspState.iconBy[VarV3334[i]]

                if VarV3336 then
                    return VarV3336
                end
            end
        end,
			liveIcon = function(Arg385, Arg386, Arg387)
            local VarV3340 = ThemeApply(Arg385, Arg386)

            if type(Arg387) == "string" and Arg387 ~= "" then
                if type(Arg387) == "string" and Arg387 ~= "" then
                    local VarV3341 = string.lower(Arg387)

                    VarV3340[#VarV3340 + 1] = VarV3341
                    VarV3340[#VarV3340 + 1] = VarV3341:gsub("[%s_%-]+", "")
                end
            end

            local Tab279 = {}

            for i = 1, #VarV3340 do
                Tab279[VarV3340[i]] = true
            end

            for _, v in pairs(EspState.pool) do
                local VarV3346 = v.icon and v.icon.Image

                if type(VarV3346) ~= "string" or VarV3346 == "" then
                    continue
                end

                local VarV3347 = string.lower((tostring(v.title and v.title.Text or ""))):gsub("^▸%s*", ""):gsub("^>%s*", "")
                local VarV3348 = VarV3347:gsub("[%s_%-]+", "")

                if VarV3347 ~= "" and Tab279[VarV3347] or VarV3348 ~= "" and Tab279[VarV3348] then
                    return VarV3346
                end
            end

            for i = 1, #VarV3340 do
                local VarV3350 = EspState.iconBy[VarV3340[i]]

                if VarV3350 then
                    return VarV3350
                end
            end
        end,
			scanIcons = ThemeGet,
			bumpPlot = function()
            EspState.plotAt = 0
        end
		}
    end)()
    local function IsAtSpawn(SpawnPos)
        local VarV2157 = select(1, ResolveSpawnFallback())

        if not SpawnPos then
            return false, VarV2157
        end

        if VarV2157 and Vector3.new(VarV2157.X - SpawnPos.Position.X, 0, VarV2157.Z - SpawnPos.Position.Z).Magnitude <= 28 then
            return true, VarV2157
        end

        return false, VarV2157
    end
    local function EggCycleCountdown()
        local ServerTimeNow = workspace:GetServerTimeNow()
        local AreaEggCycleDisabledAt = workspace:GetAttribute("AreaEggCycleDisabledAt")

        if type(AreaEggCycleDisabledAt) == "number" then
            ServerTimeNow = math.min(ServerTimeNow, AreaEggCycleDisabledAt)
        end

        local AreaEggCycleAnchorAt = workspace:GetAttribute("AreaEggCycleAnchorAt")
        local AreaEggCycleAnchorIndex = workspace:GetAttribute("AreaEggCycleAnchorIndex")

        if type(AreaEggCycleAnchorAt) ~= "number" then
            AreaEggCycleAnchorAt = 0
        end

        if type(AreaEggCycleAnchorIndex) ~= "number" then
            AreaEggCycleAnchorIndex = 0
        end

        local VarV2165 = AreaEggCycleAnchorAt + (math.max(0, AreaEggCycleAnchorIndex + math.floor((ServerTimeNow - AreaEggCycleAnchorAt) / 300)) + 1) * 300

        return math.max(0, VarV2165 - ServerTimeNow)
    end
    local function EggCycleCountdownRounded()
        local Ok52, Ret52 = pcall(EggCycleCountdown)

        if Ok52 and type(Ret52) == "number" then
            return math.max(0, math.floor(Ret52 + 0.5))
        end

        return 0
    end
    local VarU1230 = (function()
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        local Clock21 = os.clock()
        local HopCount = 0
        local HopStatus = "off"
        local HopList = {}
        local HopTeleporting = false
        local HopFetching = false
        local HopLastReqAt = 0
        local HopRateAt = 0
        local HopBackoffUntil = 0
        local HopBackoffSec = 10
        local HopFailCount = 0
        local HopIdleSec = 0
        local Clock22 = os.clock()
        local VarU2187 = tonumber(StealState and StealState.banked) or 0
        local HopPhase = "idle"
        local HopNeedSettle = false
        local HopNeedCarryWait = false
        local GlobalEnv = getgenv and getgenv() or _G
        GlobalEnv.KozuaHopUsed = type(GlobalEnv.KozuaHopUsed) == "table" and GlobalEnv.KozuaHopUsed or {}
        GlobalEnv.KozuaHopRing = type(GlobalEnv.KozuaHopRing) == "table" and GlobalEnv.KozuaHopRing or {}
        GlobalEnv.KozuaHopCache = type(GlobalEnv.KozuaHopCache) == "table" and GlobalEnv.KozuaHopCache or {}
        if type(GlobalEnv.KozuaHopUntil) == "number" then
            local Ok53, Ret53 = pcall(function()
                local VarV3842 = EggCycleCountdown()
                local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

                if type(AreaEggCycleNightSeconds) ~= "number" then
                    AreaEggCycleNightSeconds = 10
                end

                return VarV3842 - math.clamp(AreaEggCycleNightSeconds, 1, 300)
            end)
            local VarV2195 = (not Ok53 or type(Ret53) ~= "number") and 0 or math.max(0, Ret53)

            if math.abs(VarV2195 - GlobalEnv.KozuaHopUntil) < 10 then
            end
        end
        local function HopNormalizeId(HopCursor)
            if type(HopCursor) ~= "string" then
                return 0
            end

            local VarV3845 = string.lower(HopCursor:gsub(",", ""):gsub("%s+", ""))

            if VarV3845 == "" or VarV3845 == "off" or VarV3845:find("blank", 1, true) then
                return 0
            end

            return tonumber(VarV3845:match("([%d%.]+)")) or 0
        end
        local function HopIsUsed(HopPageNo)
            if type(HopPageNo) ~= "string" or HopPageNo == "" then
                return
            end

            local KozuaHopRing = GlobalEnv.KozuaHopRing

            for i = #KozuaHopRing, 1, -1 do
                if HopPageNo == KozuaHopRing[i] then
                    table.remove(KozuaHopRing, i)
                end
            end

            KozuaHopRing[#KozuaHopRing + 1] = HopPageNo

            while #KozuaHopRing > 48 do
                table.remove(KozuaHopRing, 1)
            end
        end
        local function HopMarkUsed(HopFilter)
            local StrId28 = tostring(HopFilter or "")
            if StrId28 == "" or StrId28 == tostring(game.JobId) then
                return true
            end
            local KozuaHopRing = GlobalEnv.KozuaHopRing
            local Flag3859
            local VarV3858
            for i = 1, #KozuaHopRing do
                if StrId28 == KozuaHopRing[i] then
                    VarV3858 = true
                    Flag3859 = true
                end

                if Flag3859 then
                    break
                end
            end
            if not Flag3859 then
                VarV3858 = false
            end
            Flag3859 = false
            if VarV3858 then
                return true
            end
            local VarV3860 = GlobalEnv.KozuaHopUsed[StrId28]
            if type(VarV3860) ~= "number" then
                return false
            end
            if os.time() - VarV3860 > 2100 then
                GlobalEnv.KozuaHopUsed[StrId28] = nil

                return false
            end

            return true
        end
        local function HopLoadUsedFile()
            if type(readfile) ~= "function" then
                return
            end
            local Ok54, Ret54 = pcall(readfile, (("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/hop-used.json")
            if not Ok54 or type(Ret54) ~= "string" or Ret54 == "" then
                return
            end
            local data
            if not pcall(function()
                data = HttpService:JSONDecode(Ret54)
            end) or type(data) ~= "table" then
                return
            end
            if tonumber(data.place) and tonumber(data.place) ~= PlaceId then
                return
            end
            local timestamp = os.time()
            if type(data.jobs) == "table" then
                for k, v in pairs(data.jobs) do
                    local VarV3867 = type(v) == "number" and v or type(v) == "table" and tonumber(v.t)
                    local StrId29 = tostring(k)

                    if VarV3867 and timestamp - VarV3867 <= 2100 and VarV3867 > (tonumber(GlobalEnv.KozuaHopUsed[StrId29]) or 0) then
                        GlobalEnv.KozuaHopUsed[StrId29] = VarV3867
                    end
                end
            end
            if type(data.ring) == "table" then
                local Tab281 = {}
                local Tab282 = {}

                for i = 1, #data.ring do
                    local VarV3872 = data.ring[i]

                    if type(VarV3872) == "table" then
                        VarV3872 = VarV3872.id
                    end

                    if type(VarV3872) == "string" and VarV3872 ~= "" and not Tab281[VarV3872] then
                        Tab281[VarV3872] = true
                        Tab282[#Tab282 + 1] = VarV3872
                    end
                end

                for i = 1, #GlobalEnv.KozuaHopRing do
                    local VarV3874 = GlobalEnv.KozuaHopRing[i]

                    if type(VarV3874) == "table" then
                        VarV3874 = VarV3874.id
                    end

                    if type(VarV3874) == "string" and VarV3874 ~= "" and not Tab281[VarV3874] then
                        Tab281[VarV3874] = true
                        Tab282[#Tab282 + 1] = VarV3874
                    end
                end

                GlobalEnv.KozuaHopRing = Tab282

                while #GlobalEnv.KozuaHopRing > 48 do
                    table.remove(GlobalEnv.KozuaHopRing, 1)
                end
            end
        end
        local function HopPruneUsed()
            if type(writefile) ~= "function" then
                return
            end

            if type(makefolder) == "function" then
                pcall(makefolder, "kozua")
            end

            local VarV3875 = "kozua" .. "/" .. sanitizeFileName(HubInfo.Game)

            if type(makefolder) == "function" then
                pcall(makefolder, VarV3875)
            end

            local VarV3876 = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache"

            if type(makefolder) == "function" then
                pcall(makefolder, VarV3876)
            end

            local VarV3877 = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/configs"

            if type(makefolder) == "function" then
                pcall(makefolder, VarV3877)
            end

            local Tab283 = {}
            local timestamp = os.time()

            for k, v in pairs(GlobalEnv.KozuaHopUsed) do
                if type(v) == "number" and timestamp - v <= 2100 then
                    Tab283[tostring(k)] = {
						t = v,
						by = UserIdStr
					}
                end
            end

            local Tab284 = {
				v = 1,
				place = PlaceId,
				jobs = Tab283,
				ring = GlobalEnv.KozuaHopRing
			}
            local Ok55, Ret55 = pcall(function()
                return HttpService:JSONEncode(Tab284)
            end)

            if Ok55 and type(Ret55) == "string" then
                pcall(writefile, (("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/hop-used.json", Ret55)
            end
        end
        HopLoadUsedFile()
        local StrId30 = tostring(tostring(game.JobId) or "")
        if StrId30 ~= "" then
            GlobalEnv.KozuaHopUsed[StrId30] = os.time()
            HopIsUsed(StrId30)
        end
        HopPruneUsed()
        local function HopFetchPage(HopPageArg, HopLimit)
            local VarV3889 = tonumber(HopLimit) or 2.2
            local VarV3890 = syn and syn.request or (http_request or (request or (http and http.request or fluxus and fluxus.request)))
            local VarU3891
            local VarU3892
            local VarU3893
            if VarV3890 then
                task.spawn(function()
                    local Ok56, Ret56 = pcall(VarV3890, {
						Url = HopPageArg,
						Method = "GET",
						Headers = {
							Accept = "application/json"
						}
					})

                    VarU3891 = true

                    if Ok56 then
                        VarU3892 = Ret56

                        return
                    end

                    VarU3893 = Ret56
                end)
            else
                if type(game.HttpGet) ~= "function" then
                    return nil, "no http"
                end

                task.spawn(function()
                    local Ok57, Ret57 = pcall(game.HttpGet, game, HopPageArg)

                    VarU3891 = true

                    if Ok57 then
                        VarU3892 = {
							StatusCode = 200,
							Body = Ret57
						}

                        return
                    end

                    VarU3893 = Ret57
                end)
            end
            local Clock23 = os.clock()
            while not VarU3891 and VarV3889 > os.clock() - Clock23 do
                task.wait(0.05)
            end
            if not VarU3891 then
                return nil, "slow"
            end
            if VarU3893 then
                return nil, (tostring(VarU3893))
            end
            local VarV3895 = VarU3892 and tonumber(VarU3892.StatusCode or (VarU3892.status_code or VarU3892.Status))
            local VarV3896 = VarU3892 and (VarU3892.Body or VarU3892.body)
            if VarV3895 == 429 then
                local VarV3897 = HopBackoffSec
                local VarV3898 = VarU3892 and (VarU3892.Headers or VarU3892.headers)

                if type(VarV3898) == "table" then
                    local num = tonumber(VarV3898["Retry-After"] or (VarV3898["retry-after"] or VarV3898["Retry-after"]))

                    if num and num > 0 then
                        VarV3897 = math.max(VarV3897, num)
                    end
                end

                HopBackoffUntil = os.clock() + VarV3897
                HopBackoffSec = math.min(60, math.max(12, HopBackoffSec * 2))

                return nil, "rate limited"
            end
            if VarV3895 and VarV3895 >= 400 then
                return nil, "http " .. tostring(VarV3895)
            end
            if type(VarV3896) ~= "string" or VarV3896 == "" then
                return nil, "empty"
            end
            HopBackoffSec = 10

            return VarV3896
        end
        local function HopCacheKey()
            local VarV3900 = math.clamp(math.floor(tonumber(Config.HopPages) or 3), 1, 10)
            local VarV3901 = Config.HopSkipFull ~= false
            local VarV3902 = Config.HopPlayers == "Highest"

            return tostring(PlaceId) .. ":" .. (not VarV3902 and "A" or "D") .. ":" .. (not VarV3901 and "0" or "1") .. ":" .. tostring(VarV3900)
        end
        local function HopApiUrl(HopUrlArg)
            HopList = {}

            if type(HopUrlArg) ~= "table" then
                return HopList
            end

            HopLoadUsedFile()

            local StrId31 = tostring(game.JobId)

            for i = 1, #HopUrlArg do
                local VarV3906 = HopUrlArg[i]
                local VarV3907 = VarV3906 and tostring(VarV3906.id)

                if VarV3907 and VarV3907 ~= "" and VarV3907 ~= StrId31 and not HopMarkUsed(VarV3907) then
                    HopList[#HopList + 1] = {
						id = VarV3906.id,
						playing = tonumber(VarV3906.playing) or 0,
						maxPlayers = tonumber(VarV3906.maxPlayers) or 0
					}
                end
            end

            return HopList
        end
        local function HopLoadCache(HopCacheArg)
            local KozuaHopCache = GlobalEnv.KozuaHopCache

            if type(KozuaHopCache) ~= "table" or (KozuaHopCache.key ~= HopCacheKey() or type(KozuaHopCache.list) ~= "table" or #KozuaHopCache.list == 0) then
                KozuaHopCache = nil

                if type(readfile) == "function" then
                    local Ok58, Ret58 = pcall(readfile, (("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/hop-list.json")

                    if Ok58 and type(Ret58) == "string" and Ret58 ~= "" then
                        local data
                        pcall(function()
                            data = HttpService:JSONDecode(Ret58)
                        end)
                        if type(data) == "table" and data.key == HopCacheKey() and type(data.list) == "table" and #data.list > 0 then
                            KozuaHopCache = data
                            GlobalEnv.KozuaHopCache = data
                        end
                    end
                end
            end

            if type(KozuaHopCache) ~= "table" or type(KozuaHopCache.list) ~= "table" or #KozuaHopCache.list == 0 then
                return
            end

            local VarV3913 = os.time() - (tonumber(KozuaHopCache.at) or 0)

            if VarV3913 > 90 and not HopCacheArg then
                return
            end

            HopApiUrl(KozuaHopCache.list)

            if #HopList > 0 then
                return HopList, VarV3913
            end
        end
        local function HopFilterServers(HopRawList)
            if type(HopRawList) ~= "table" or #HopRawList == 0 then
                return
            end

            local Tab285 = {
				key = HopCacheKey(),
				at = os.time(),
				list = HopRawList
			}

            GlobalEnv.KozuaHopCache = Tab285

            if type(writefile) == "function" then
                if type(makefolder) == "function" then
                    pcall(makefolder, "kozua")
                end

                local VarV3916 = "kozua" .. "/" .. sanitizeFileName(HubInfo.Game)

                if type(makefolder) == "function" then
                    pcall(makefolder, VarV3916)
                end

                local VarV3917 = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache"

                if type(makefolder) == "function" then
                    pcall(makefolder, VarV3917)
                end

                local VarV3918 = ("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/configs"

                if type(makefolder) == "function" then
                    pcall(makefolder, VarV3918)
                end

                local Ok59, Ret59 = pcall(function()
                    return HttpService:JSONEncode(Tab285)
                end)

                if Ok59 and type(Ret59) == "string" then
                    pcall(writefile, (("kozua" .. "/" .. sanitizeFileName(HubInfo.Game)) .. "/cache") .. "/hop-list.json", Ret59)
                end
            end
        end
        local function HopLoadCombined()
            if HopLoadCache(false) then
                return HopList, "cached"
            end

            if os.clock() < HopBackoffUntil then
                if HopLoadCache(true) then
                    return HopList, "cached"
                end

                return HopList, "rate limited"
            end

            HopRateAt = os.clock()

            local VarV3921 = math.clamp(math.floor(tonumber(Config.HopPages) or 3), 1, 10)
            local VarV3922 = Config.HopSkipFull ~= false
            local VarV3923 = Config.HopPlayers == "Highest"
            local Tab286 = {}
            local State27 = ""

            for i = 1, VarV3921 do
                if i > 1 then
                    task.wait(0.12)
                end
                local VarV3927 = "https://games.roblox.com/v1/games/" .. tostring(PlaceId) .. "/servers/Public?sortOrder=" .. (not VarV3923 and "Asc" or "Desc") .. "&excludeFullGames=" .. (not VarV3922 and "false" or "true") .. "&limit=100"
                if State27 ~= "" then
                    local VarU3928 = State27

                    pcall(function()
                        VarU3928 = HttpService:UrlEncode(State27)
                    end)
                    VarV3927 ..= "&cursor=" .. VarU3928
                end
                local VarV3929, VarV3930 = HopFetchPage(VarV3927, 2.2)
                if not VarV3929 then
                    if #Tab286 > 0 then
                        break
                    end

                    if HopLoadCache(true) then
                        return HopList, "cached"
                    end

                    return nil, VarV3930 or "fetch"
                end
                local data
                local VarV3932 = pcall(function()
                    data = HttpService:JSONDecode(VarV3929)
                end) and (data and data.data)
                if type(VarV3932) ~= "table" then
                    if #Tab286 > 0 then
                        break
                    end

                    if HopLoadCache(true) then
                        return HopList, "cached"
                    end

                    return nil, "bad json"
                end
                for j = 1, #VarV3932 do
                    local VarV3934 = VarV3932[j]

                    if type(VarV3934) == "table" and type(VarV3934.id) == "string" then
                        Tab286[#Tab286 + 1] = {
							id = VarV3934.id,
							playing = tonumber(VarV3934.playing) or 0,
							maxPlayers = tonumber(VarV3934.maxPlayers) or 0
						}
                    end
                end
                State27 = type(data.nextPageCursor) == "string" and data.nextPageCursor or ""
                if State27 == "" then
                    break
                end
            end

            table.sort(Tab286, function(Arg397, Arg398)
                if VarV3923 then
                    return Arg397.playing > Arg398.playing
                end

                return Arg397.playing < Arg398.playing
            end)
            HopFilterServers(Tab286)
            HopApiUrl(Tab286)

            return HopList
        end
        local function HopPickNext()
            local KozuaHopRing = GlobalEnv.KozuaHopRing
            local Tab287 = {}
            local Tab288 = {}

            for i = math.max(1, #KozuaHopRing - 7), #KozuaHopRing do
                local VarV3939 = KozuaHopRing[i]

                if type(VarV3939) == "string" and not Tab288[VarV3939] then
                    Tab288[VarV3939] = true
                    Tab287[#Tab287 + 1] = VarV3939
                end
            end

            local StrId32 = tostring(game.JobId)

            if not Tab288[StrId32] then
                Tab287[#Tab287 + 1] = StrId32
            end

            GlobalEnv.KozuaHopRing = Tab287

            local timestamp = os.time()

            for k, v in pairs(GlobalEnv.KozuaHopUsed) do
                if k ~= StrId32 and type(v) == "number" and timestamp - v > 480 then
                    GlobalEnv.KozuaHopUsed[k] = nil
                end
            end

            HopPruneUsed()
        end
        local function HopBeginTeleport()
            HopLoadUsedFile()

            local VarV3944 = Config.HopSkipFull ~= false
            local StrId33 = tostring(game.JobId)
            local Tab289 = {}
            local Tab290 = {}

            while #HopList > 0 do
                local VarV3948 = table.remove(HopList, 1)
                local VarV3949 = VarV3948 and tostring(VarV3948.id)

                if VarV3949 and VarV3949 ~= "" and VarV3949 ~= StrId33 and not HopMarkUsed(VarV3949) then
                    local VarV3950 = tonumber(VarV3948.maxPlayers) or 0

                    if not VarV3944 or VarV3950 <= 0 or VarV3950 > (tonumber(VarV3948.playing) or 0) then
                        if #Tab289 < 12 then
                            Tab289[#Tab289 + 1] = VarV3948
                        else
                            Tab290[#Tab290 + 1] = VarV3948
                        end
                    end
                end
            end

            HopList = Tab290

            local VarV3952, StrId34

            repeat
                if not (#Tab289 > 0) then
                    return
                end

                local VarV3951 = math.random(1, #Tab289)

                VarV3952 = table.remove(Tab289, VarV3951)
                StrId34 = tostring(VarV3952.id)
                HopLoadUsedFile()
            until StrId34 ~= StrId33 and not HopMarkUsed(StrId34)

            local StrId35 = tostring(StrId34 or "")

            if StrId35 ~= "" then
                GlobalEnv.KozuaHopUsed[StrId35] = os.time()
                HopIsUsed(StrId35)
            end

            HopPruneUsed()

            for i = #Tab289, 1, -1 do
                table.insert(HopList, 1, Tab289[i])
            end

            return VarV3952
        end
        local function HopTickAuto()
            if Config.AutoEvent == true then
                local VarV3956 = StealState and StealState.state

                if VarV3956 == "FeedGo" or VarV3956 == "Feed" or VarV3956 == "ChestGo" or VarV3956 == "ChestOpen" then
                    return true
                end

                if StealState and StealState.findChestTool and StealState.findChestTool() then
                    return true
                end

                if StealState and StealState.target and StealState.target.event then
                    return true
                end

                if StealState and StealState.pickSatchelEvent then
                    local Ok60, Ret60 = pcall(StealState.pickSatchelEvent)

                    if Ok60 and type(Ret60) == "table" then
                        return Ret60
                    end
                end
            end

            if type(CollectStealTargets) ~= "function" then
                return
            end

            local Ok61, Ret61 = pcall(CollectStealTargets)

            if Ok61 and type(Ret61) == "table" and Ret61.matched == true and (Ret61.cfg or Ret61.earn) then
                return Ret61
            end
        end
        local function HopSetStatus(HopReason)
            if HopFetching or HopTeleporting then
                return false
            end

            if os.clock() - HopLastReqAt < 2.4 then
                return false
            end

            HopFetching = true
            HopLastReqAt = os.clock()
            pcall(saveConfig, true)
            HopStatus = HopReason or "hopping"

            local VarV3974 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
            local AutoHop = WidgetRegistry.AutoHop

            if AutoHop and AutoHop.status then
                pcall(function()
                    AutoHop.status.Text = VarV3974 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                end)
            end

            if #HopList == 0 then
                local _, VarV3977 = HopLoadCombined()

                if #HopList == 0 then
                    HopPickNext()
                    HopLoadCache(true)

                    if #HopList == 0 then
                        HopFetching = false
                        HopStatus = tostring(VarV3977 or "no servers")

                        local VarV3978 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                        local AutoHop2 = WidgetRegistry.AutoHop

                        if AutoHop2 and AutoHop2.status then
                            pcall(function()
                                AutoHop2.status.Text = VarV3978 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                            end)
                        end

                        local HopNow = WidgetRegistry.HopNow

                        if HopNow and HopNow.status then
                            HopNow.status.Text = HopStatus
                        end

                        return false
                    end
                end
            end

            HopCount += 1

            local StrId36 = tostring(game.JobId)
            local VarV3982 = false

            while IsAlive and HopFetching do
                local VarU3983 = HopBeginTeleport()

                if not VarU3983 then
                    HopPickNext()
                    HopLoadCache(true)
                    VarU3983 = HopBeginTeleport()
                end

                if not VarU3983 then
                    break
                end

                local VarV3984 = GlobalEnv
                local Ok62, Ret62 = pcall(function()
                    local VarV4836 = EggCycleCountdown()
                    local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

                    if type(AreaEggCycleNightSeconds) ~= "number" then
                        AreaEggCycleNightSeconds = 10
                    end

                    return VarV4836 - math.clamp(AreaEggCycleNightSeconds, 1, 300)
                end)

                VarV3984.KozuaHopUntil = (not Ok62 or type(Ret62) ~= "number") and 0 or math.max(0, Ret62)
                HopTeleporting = true
                HopStatus = (HopReason or "hop") .. " · " .. tostring(#HopList) .. " left"

                local VarV3987 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                local AutoHop3 = WidgetRegistry.AutoHop

                if AutoHop3 and AutoHop3.status then
                    pcall(function()
                        AutoHop3.status.Text = VarV3987 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                local Ok63, Ret63 = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, tostring(VarU3983.id), LocalPlayer)
                end)

                if not Ok63 then
                    HopTeleporting = false
                    HopFailCount += 1
                    KozuaLog("hop", "fail", (tostring(Ret63)))
                else
                    local Clock24 = os.clock()

                    while IsAlive and HopTeleporting and os.clock() - Clock24 < 2.2 do
                        if StrId36 ~= tostring(game.JobId) then
                            VarV3982 = true

                            break
                        end

                        task.wait(0.1)
                    end

                    if StrId36 ~= tostring(game.JobId) then
                        VarV3982 = true

                        break
                    end

                    pcall(function()
                        TeleportService:TeleportCancel()
                    end)
                    HopTeleporting = false
                    HopFailCount += 1
                end
            end

            HopFetching = false
            HopTeleporting = false

            if VarV3982 then
                return true
            end

            HopStatus = "no servers"

            local VarV3992 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
            local AutoHop4 = WidgetRegistry.AutoHop

            if AutoHop4 and AutoHop4.status then
                pcall(function()
                    AutoHop4.status.Text = VarV3992 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                end)
            end

            return false
        end
        local connection18 = TeleportService.TeleportInitFailed:Connect(function(Arg400)
            if Arg400 ~= LocalPlayer then
                return
            end

            HopTeleporting = false
            HopFailCount += 1
        end)
        if connection18 then
            ConnList[connection18] = true
        end
        local function HopIdleTick()
            if not IsAlive then
                return
            end

            local Clock25 = os.clock()
            local VarV3996 = Clock25 - Clock22

            Clock22 = Clock25

            if StealState and StealState.banked ~= VarU2187 then
                VarU2187 = StealState.banked
                HopIdleSec = 0
            end

            local VarV3997 = EggCycleCountdown()
            local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

            if type(AreaEggCycleNightSeconds) ~= "number" then
                AreaEggCycleNightSeconds = 10
            end

            local VarV3999 = VarV3997 <= math.clamp(AreaEggCycleNightSeconds, 1, 300)
            local VarV4000 = false

            if not VarV3999 then
                VarV4000 = not not HopTickAuto()
            end

            if Config.AutoSteal and StealState and StealState.running and not VarV3999 then
                if VarV4000 then
                    HopIdleSec = 0
                else
                    HopIdleSec += VarV3996
                end
            end

            if not Config.AutoHop then
                if HopPhase ~= "idle" or HopNeedSettle or HopNeedCarryWait then
                    HopPhase = "idle"
                    HopNeedSettle = false
                    HopNeedCarryWait = false
                end

                HopStatus = "off"

                local VarV4001 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                local AutoHop = WidgetRegistry.AutoHop

                if AutoHop and AutoHop.status then
                    pcall(function()
                        AutoHop.status.Text = VarV4001 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                return
            end

            if HopTeleporting or HopFetching then
                local VarV4003 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                local AutoHop = WidgetRegistry.AutoHop

                if AutoHop and AutoHop.status then
                    pcall(function()
                        AutoHop.status.Text = VarV4003 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                return
            end

            if Clock25 < Clock21 + 1.6 then
                HopStatus = "settling"

                local VarV4005 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                local AutoHop = WidgetRegistry.AutoHop

                if AutoHop and AutoHop.status then
                    pcall(function()
                        AutoHop.status.Text = VarV4005 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                return
            end

            if StealState and StealState.carrying == true then
                HopStatus = "carrying"

                local VarV4007 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                local AutoHop = WidgetRegistry.AutoHop

                if AutoHop and AutoHop.status then
                    pcall(function()
                        AutoHop.status.Text = VarV4007 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                return
            end

            HopPhase = "idle"
            HopNeedSettle = false
            HopNeedCarryWait = false

            local VarV4009 = HopNormalizeId(Config.HopIdle)

            if VarV4009 > 0 then
                if VarV4009 < 5 then
                    VarV4009 = 5
                end

                if Config.AutoSteal and StealState and StealState.running then
                    if HopTickAuto() then
                        HopStatus = "eggs · grabbing"

                        local VarV4010 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                        local AutoHop = WidgetRegistry.AutoHop

                        if AutoHop and AutoHop.status then
                            pcall(function()
                                AutoHop.status.Text = VarV4010 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                            end)
                        end

                        return
                    end

                    HopStatus = "idle " .. tostring(math.floor(HopIdleSec)) .. "/" .. tostring(math.floor(VarV4009)) .. "s"

                    if VarV4009 <= HopIdleSec then
                        local VarV4012 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                        local AutoHop = WidgetRegistry.AutoHop

                        if AutoHop and AutoHop.status then
                            pcall(function()
                                AutoHop.status.Text = VarV4012 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                            end)
                        end

                        HopSetStatus("idle")

                        return
                    end
                end
            end

            local VarV4014 = HopNormalizeId(Config.HopAfter)

            if VarV4014 > 0 then
                if VarV4014 < 1 then
                    VarV4014 = 1
                end

                if VarV4014 <= (Clock25 - Clock21) / 60 then
                    HopStatus = "time"

                    local VarV4015 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
                    local AutoHop = WidgetRegistry.AutoHop

                    if AutoHop and AutoHop.status then
                        pcall(function()
                            AutoHop.status.Text = VarV4015 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                        end)
                    end

                    HopSetStatus("time")

                    return
                end
            end

            if HopTickAuto() then
                HopStatus = "eggs · grabbing"
            elseif VarV4009 > 0 and Config.AutoSteal and StealState and StealState.running then
                HopStatus = "idle " .. tostring(math.floor(HopIdleSec)) .. "/" .. tostring(math.floor(VarV4009)) .. "s"
            elseif HopNeedCarryWait then
                HopStatus = "eggs · staying"
            elseif VarV4009 > 0 and Config.AutoHop then
                HopStatus = "idle needs Auto Steal"
            else
                HopStatus = "on"
            end

            local VarV4017 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
            local AutoHop = WidgetRegistry.AutoHop

            if AutoHop and AutoHop.status then
                pcall(function()
                    AutoHop.status.Text = VarV4017 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
                end)
            end
        end
        task.spawn(function()
            while IsAlive do
                task.wait(0.4)
                pcall(HopIdleTick)
            end
        end)
        local VarV2214 = not Config.AutoHop and "off" or (HopStatus ~= "" and HopStatus or "on")
        local AutoHop = WidgetRegistry.AutoHop
        if AutoHop and AutoHop.status then
            pcall(function()
                AutoHop.status.Text = VarV2214 .. " · " .. tostring(HopCount) .. (HopCount ~= 1 and " hops this session" or " hop this session")
            end)
        end

        return {
			now = function()
            local HopNow = WidgetRegistry.HopNow

            if HopNow and HopNow.status then
                HopNow.status.Text = "going…"
            end

            local VarV4020 = HopSetStatus("now")

            if HopNow and HopNow.status then
                HopNow.status.Text = if not VarV4020 then HopStatus else "going…"
            end

            return VarV4020
        end,
			stop = function()
            HopFetching = false
            HopTeleporting = false
            pcall(function()
                TeleportService:TeleportCancel()
            end)
        end,
			hops = function()
            return HopCount
        end
		}
    end)()
    FarmSync = (function()
        local FarmState = {
			placed = 0,
			hatched = 0,
			bought = 0,
			sold = 0,
			soldPets = 0,
			soldEggs = 0,
			trainEarned = 0,
			trainRate = 0,
			claimCash = 0,
			claimIndex = 0,
			training = false,
			conn = nil,
			busy = false,
			lastPlace = 0,
			lastHatch = 0,
			lastEquip = 0,
			lastSell = 0,
			lastWear = 0,
			lastUpg = 0,
			lastClaim = 0,
			lastPaint = 0,
			lastTrain = 0,
			lastPower = nil,
			lastPowerAt = 0,
			job = "idle",
			info = nil,
			infoAt = 0,
			lastPlaceWhy = nil,
			previewQueued = false
		}
        local function FmtTrainRate(HopSortKey)
            local VarV4022 = tonumber(HopSortKey) or 0
            local VarV4023 = math.abs(VarV4022)

            if VarV4023 >= 1000000000000 then
                return string.format("%.2fT", VarV4022 / 1000000000000)
            end

            if VarV4023 >= 1000000000 then
                return string.format("%.2fB", VarV4022 / 1000000000)
            end

            if VarV4023 >= 1000000 then
                return string.format("%.2fm", VarV4022 / 1000000)
            end

            if VarV4023 >= 1000 then
                return string.format("%.1fk", VarV4022 / 1000)
            end

            return string.format("%.0f", VarV4022)
        end
        local function GetRemote(RemoteCat, RemoteName)
            local VarV4029 = RequireShared({ "Remotes" })
            local VarV4030 = VarV4029 and (VarV4029[RemoteCat] and VarV4029[RemoteCat][RemoteName])

            return UnwrapRemote(VarV4030) or typeof(VarV4030) == "Instance" and VarV4030
        end
        local function InvokeRemote(InvokeCat, InvokeName, ...)
            local VarV4033 = GetRemote(InvokeCat, InvokeName)

            if not VarV4033 then
                return false, "no remote"
            end

            return VarV4033:InvokeServer(...)
        end
        local function FireRemote(FireCat, FireName, ...)
            local VarV4036 = select("#", ...)
            local VarV4037, VarV4038, VarV4039 = ...
            local VarV4040 = RequireShared({ "Remotes" })
            local VarV4041 = VarV4040 and (VarV4040[FireCat] and VarV4040[FireCat][FireName])

            if VarV4041 == nil then
                return false
            end

            local function Farm_Fn_4042(FireTarget)
                if VarV4036 <= 0 then
                    FireTarget:FireServer()

                    return
                end

                if VarV4036 == 1 then
                    FireTarget:FireServer(VarV4037)

                    return
                end

                if VarV4036 == 2 then
                    FireTarget:FireServer(VarV4037, VarV4038)

                    return
                end

                FireTarget:FireServer(VarV4037, VarV4038, VarV4039)
            end

            if pcall(Farm_Fn_4042, VarV4041) then
                return true
            end

            local VarV4043 = UnwrapRemote(VarV4041) or typeof(VarV4041) == "Instance" and VarV4041

            return VarV4043 ~= nil and pcall(Farm_Fn_4042, VarV4043)
        end
        local function FarmGetSave()
            local Save = ReplicatedStorage.Shared.Save
            local VarV4049

            if FarmState.saveMod == false then
                VarV4049 = nil
            elseif FarmState.saveMod ~= nil then
                VarV4049 = FarmState.saveMod
            else
                local Ok64, Ret64 = pcall(require, Save)

                FarmState.saveMod = not not Ok64 and (type(Ret64) == "table" and (Ret64 or false))
                VarV4049 = if FarmState.saveMod ~= false then FarmState.saveMod else nil
            end

            if type(VarV4049) == "table" and type(VarV4049.Get) == "function" then
                local Ok65, Ret65 = pcall(VarV4049.Get, LocalPlayer, false)

                if Ok65 and type(Ret65) == "table" then
                    return Ret65
                end

                local Ok66, Ret66 = pcall(VarV4049.Get)

                if Ok66 and type(Ret66) == "table" then
                    return Ret66
                end
            end
        end
        local function NormRarity(RarityName)
            local VarV4061 = string.lower((tostring(RarityName or "")))

            if VarV4061 == "" or VarV4061 == "?" then
                return 0
            end

            for i, v in ipairs(RarityList) do
                if VarV4061 == string.lower(v) then
                    return i
                end
            end

            return 0
        end
        local function FarmOwnPlot()
            local Clock26 = os.clock()
            if FarmState.info and Clock26 - (FarmState.infoAt or 0) < 0.45 then
                return FarmState.info
            end
            local PlotState = ReplicatedStorage.Client.PlotState
            local VarV4072
            if FarmState.plotMod == false then
                VarV4072 = nil
            elseif FarmState.plotMod ~= nil then
                VarV4072 = FarmState.plotMod
            else
                local Ok67, Ret67 = pcall(require, PlotState)

                FarmState.plotMod = not not Ok67 and (type(Ret67) == "table" and (Ret67 or false))
                VarV4072 = if FarmState.plotMod ~= false then FarmState.plotMod else nil
            end
            local VarV4075 = VarV4072
            local VarU4076
            if VarV4075 and type(VarV4075.ResolvePlot) == "function" then
                pcall(function()
                    VarU4076 = VarV4075.ResolvePlot()
                end)
            end
            FarmState.info = type(VarU4076) == "table" and VarU4076 or nil
            FarmState.infoAt = Clock26

            return FarmState.info
        end
        local function InBoundsXZ(BoundsPart, BoundsPoint, BoundsPad)
            if not BoundsPart or (not BoundsPart:IsA("BasePart") or typeof(BoundsPoint) ~= "Vector3") then
                return false
            end

            local VarV4080 = BoundsPart.CFrame:PointToObjectSpace(BoundsPoint)
            local VarV4081 = BoundsPart.Size.X * 0.5 - (BoundsPad or 0)
            local VarV4082 = BoundsPart.Size.Z * 0.5 - (BoundsPad or 0)

            return math.abs(VarV4080.X) <= math.max(VarV4081, 0.5) and math.abs(VarV4080.Z) <= math.max(VarV4082, 0.5)
        end
        local function FarmBeltPart()
            local Clock27 = os.clock()
            if FarmState.beltPart and (FarmState.beltPart.Parent and Clock27 - (FarmState.beltAt or 0) < 0.85) then
                return FarmState.beltPart
            end
            local TreadmillBottom
            local VarV4085 = FarmOwnPlot()
            local VarV4086 = VarV4085 and VarV4085.PlotFolder
            if VarV4086 then
                TreadmillBottom = VarV4086:FindFirstChild("TreadmillBottom", true)

                if not (TreadmillBottom and TreadmillBottom:IsA("BasePart"))then
                    TreadmillBottom = nil
                    local VarV4087
                    for _, descendant in ipairs(VarV4086:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            local VarV4090 = string.lower(descendant.Name)

                            if VarV4090:find("treadmill", 1, true) or VarV4090 == "bottom" or VarV4090:find("belt", 1, true) then
                                local VarV4091 = descendant.Size.X * descendant.Size.Y * descendant.Size.Z

                                if not VarV4087 or VarV4087 < VarV4091 then
                                    TreadmillBottom = descendant
                                    VarV4087 = VarV4091
                                end
                            end
                        end
                    end
                end
            end
            if not TreadmillBottom then
                local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")

                if __ClientTreadmillRenders then
                    local VarV4093 = __ClientTreadmillRenders:FindFirstChild("TreadmillBottom", true) or __ClientTreadmillRenders:FindFirstChild("Bottom", true)

                    if VarV4093 and VarV4093:IsA("BasePart") then
                        TreadmillBottom = VarV4093
                    end
                end
            end
            FarmState.beltPart = TreadmillBottom
            FarmState.beltAt = Clock27

            return TreadmillBottom
        end
        local function FarmFreeSlots()
            local VarV4094 = FarmOwnPlot()
            local VarV4095 = VarV4094 and VarV4094.PetArea
            local VarV4096 = FarmBeltPart()

            if VarV4095 and VarV4095:IsA("BasePart") then
                local Position5 = VarV4095.Position

                if VarV4096 then
                    local vector3 = Vector3.new(Position5.X - VarV4096.Position.X, 0, Position5.Z - VarV4096.Position.Z)

                    if vector3.Magnitude > 1 then
                        Position5 += vector3.Unit * math.min(12, vector3.Magnitude * 0.15)
                    end
                end

                return Vector3.new(Position5.X, VarV4095.Position.Y + 4.5, Position5.Z), VarV4095
            end

            return select(1, ResolvePlotSpawn()), nil
        end
        local function FarmClaimPad(PadA, PadPos, PadR)
            if typeof(PadA) ~= "Vector3" or typeof(PadPos) ~= "Vector3" then
                return PadA
            end

            if PadR then
                return PadA
            end

            if Vector3.new(PadA.X - PadPos.X, 0, PadA.Z - PadPos.Z).Magnitude > 14 then
                return Vector3.new(PadA.X, PadA.Y + 18, PadA.Z)
            end

            return PadA
        end
        local function IsSafeForFarm(SafeCharPart)
            local VarV4104 = FarmBeltPart()

            if not VarV4104 or not SafeCharPart then
                return false
            end

            local p416Position = SafeCharPart.Position

            if InBoundsXZ(VarV4104, p416Position, -2) then
                return true
            end

            return Vector3.new(p416Position.X - VarV4104.Position.X, 0, p416Position.Z - VarV4104.Position.Z).Magnitude < 6
        end
        local function FarmNeedTreadmill()
            local VarV4112 = FarmOwnPlot()
            local VarV4113 = VarV4112 and VarV4112.PetArea
            local VarV4114 = VarV4112 and VarV4112.CenterPoint
            local VarV4115 = FarmBeltPart()
            if not VarV4113 or (not VarV4113:IsA("BasePart") or not VarV4114) then
                local _, VarV4117 = ResolvePlotSpawn()

                if VarV4117 and VarV4114 then
                    return VarV4114.CFrame:ToObjectSpace(VarV4117)
                end

                return VarV4117
            end
            local VarV4118
            for _ = 1, 8 do
                local VarV4120 = (math.random() - 0.5) * math.min(VarV4113.Size.X - 8, 28)
                local VarV4121 = (math.random() - 0.5) * math.min(VarV4113.Size.Z - 8, 22)

                VarV4118 = VarV4113.CFrame * CFrame.new(VarV4120, 0.5, VarV4121)

                if not VarV4115 or not (Vector3.new(VarV4118.X - VarV4115.Position.X, 0, VarV4118.Z - VarV4115.Position.Z).Magnitude < 14) then
                    return VarV4114.CFrame:ToObjectSpace(VarV4118)
                end
            end

            return VarV4114.CFrame:ToObjectSpace(VarV4118)
        end
        local function FarmReadOwnerFiltered()
            local Flag4124
            local Ok68
            local VarV4123
            if not EggState then
                VarV4123 = nil
                Flag4124 = true
            end
            repeat
                if Flag4124 or (Flag4124 or type(EggState.ReadOwnerEggs) == "function") then
                    if not Flag4124 then
                        if not Flag4124 then
                            Ok68, VarV4123 = pcall(EggState.ReadOwnerEggs, LocalPlayer.UserId)
                        end
                    end

                    if Flag4124 or (Flag4124 or Ok68 and type(VarV4123) == "table") then

                        if type(VarV4123) ~= "table" then
                            return {}
                        end
                        local VarV4126 = v1194(Config.PlaceMinGen)
                        local Tab292 = {}
                        local Num63 = 0
                        for k, v in pairs(VarV4123) do
                            if type(v) == "table" then
                                if v.Placement ~= nil then
                                    Num63 += 1
                                else
                                    local AssetCategory = v.AssetCategory
                                    local VarV4132 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                                    local VarV4133 = v1193(v, VarV4132)

                                    if VarV4126 <= 0 or VarV4126 <= VarV4133 then
                                        local NeverPlaceRarity = Config.NeverPlaceRarity
                                        local VarV4135

                                        if type(NeverPlaceRarity) ~= "string" or NeverPlaceRarity == "place everything" then
                                            VarV4135 = false
                                        else
                                            local VarV4136 = NormRarity(if type(VarV4132) == "table" and type(VarV4132.Rarity) == "table" then tostring(VarV4132.Rarity.DisplayName or (VarV4132.Rarity.Name or (VarV4132.Rarity._id or "?"))) else "?")
                                            local VarV4137 = NormRarity(NeverPlaceRarity)

                                            VarV4135 = VarV4136 > 0 and (VarV4137 > 0 and VarV4137 <= VarV4136)
                                        end

                                        if not VarV4135 then
                                            Tab292[#Tab292 + 1] = {
												uid = v.Uid or k,
												earn = VarV4133
											}
                                        end
                                    end
                                end
                            end
                        end
                        table.sort(Tab292, function(Arg417, Arg418)
                            return Arg417.earn > Arg418.earn
                        end)

                        return Tab292, Num63
                    end
                end

                VarV4123 = nil
                Flag4124 = true
            until not Flag4124
        end
        local function FarmMaxSlots()
            local VarV4138 = FarmGetSave()
            local Bases = ReplicatedStorage.Data.Bases
            local VarV4140

            if FarmState.basesMod == false then
                VarV4140 = nil
            elseif FarmState.basesMod ~= nil then
                VarV4140 = FarmState.basesMod
            else
                local Ok69, Ret68 = pcall(require, Bases)

                FarmState.basesMod = not not Ok69 and (type(Ret68) == "table" and (Ret68 or false))
                VarV4140 = if FarmState.basesMod ~= false then FarmState.basesMod else nil
            end

            local VarV4143 = tonumber(VarV4138 and VarV4138.BaseUpgradeLevel) or 0
            local VarV4144 = VarV4140 and (VarV4140.BASES and (VarV4140.BASES[VarV4143] or VarV4140.BASES[VarV4143 + 1]))

            return tonumber(VarV4144 and VarV4144.MaxAssets) or 99
        end
        local function FarmHatchReady()
            if Config.AutoHatch ~= true or (not EggState or type(EggState.IsReadyToHatch) ~= "function") then
                return false
            end
            local Flag4146
            local Ok70
            local VarV4145
            if not EggState then
                VarV4145 = nil
                Flag4146 = true
            end
            repeat
                if Flag4146 or (Flag4146 or type(EggState.ReadOwnerEggs) == "function") then
                    if not Flag4146 then
                        if not Flag4146 then
                            Ok70, VarV4145 = pcall(EggState.ReadOwnerEggs, LocalPlayer.UserId)
                        end
                    end

                    if Flag4146 or (Flag4146 or Ok70 and type(VarV4145) == "table") then
                        Flag4146 = false

                        if type(VarV4145) ~= "table" then
                            return false
                        end

                        for k, v in pairs(VarV4145) do
                            if type(v) ~= "table" or v.Placement == nil then
                                continue
                            end

                            local Ok71, Ret69 = pcall(EggState.IsReadyToHatch, v.Uid or k)

                            if Ok71 and Ret69 == true then
                                return true
                            end
                        end

                        return false
                    end
                end

                VarV4145 = nil
                Flag4146 = true
            until not Flag4146
        end
        local function FarmPlotInfo(ClaimA, ClaimR)
            local Character6 = LocalPlayer.Character
            local VarV4157

            if not Character6 then
                VarV4157 = nil
            else
                local Humanoid = Character6:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character6:FindFirstChild("HumanoidRootPart")

                VarV4157 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            if not VarV4157 or typeof(ClaimA) ~= "Vector3" then
                return false
            end

            StealDest = FarmClaimPad(ClaimA, VarV4157.Position, ClaimR)
            StealActive = true

            return Vector3.new(ClaimA.X - VarV4157.Position.X, 0, ClaimA.Z - VarV4157.Position.Z).Magnitude < 10 and math.abs(ClaimA.Y - VarV4157.Position.Y) < 10
        end
        local function FarmDoTreadmill(TreadActive)
            local Character7 = LocalPlayer.Character
            local VarV4162, VarV4163

            if not Character7 then
                VarV4162 = nil
                VarV4163 = nil
            else
                VarV4162 = Character7:FindFirstChildOfClass("Humanoid")
                VarV4163 = Character7:FindFirstChild("HumanoidRootPart")

                if not VarV4162 or not VarV4163 or VarV4162.Health <= 0 then
                    VarV4162 = nil
                    VarV4163 = nil
                end
            end

            local VarV4164 = VarV4162
            local VarV4165 = VarV4163

            if not VarV4164 or not VarV4165 then
                return
            end

            if not TreadActive then
                StealActive = false
                StealDest = nil
            end

            v1146(VarV4164, VarV4165, false)

            local VarV4166 = TreadActive and (typeof(StealDest) == "Vector3" and StealDest) or FarmFreeSlots()
            local VarV4167 = FarmBeltPart()
            local zero = Vector3.zero

            if VarV4166 then
                zero = Vector3.new(VarV4166.X - VarV4165.Position.X, 0, VarV4166.Z - VarV4165.Position.Z)
            end

            if zero.Magnitude < 0.5 and VarV4167 then
                zero = Vector3.new(VarV4165.Position.X - VarV4167.Position.X, 0, VarV4165.Position.Z - VarV4167.Position.Z)
            end

            local VarU4169 = if not (zero.Magnitude > 0.5) then Vector3.zero else zero.Unit

            pcall(function()
                VarV4164.PlatformStand = false
                VarV4164.Sit = false
                VarV4164.AutoRotate = true

                if type(VarV4164.JumpHeight) == "number" and VarV4164.JumpHeight < 0.5 then
                    VarV4164.JumpHeight = n15
                end

                if type(VarV4164.JumpPower) == "number" then
                    VarV4164.JumpPower = math.max(VarV4164.JumpPower, 50)
                end

                VarV4164:ChangeState(Enum.HumanoidStateType.Jumping)
                VarV4164.Jump = true

                if VarU4169.Magnitude > 0.5 then
                    VarV4164:Move(VarU4169, false)
                end
            end)
            pcall(function()
                VarV4165.Anchored = false
                VarV4165.AssemblyLinearVelocity = Vector3.new(VarU4169.X * 46, 78, VarU4169.Z * 46)
            end)
        end
        local function FarmLeaveBelt()
            FarmState.training = false

            local Character8 = LocalPlayer.Character
            local VarV4179

            if not Character8 then
                VarV4179 = nil
            else
                local Humanoid = Character8:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character8:FindFirstChild("HumanoidRootPart")

                VarV4179 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            local VarV4182

            if not StealState or not StealState.running then
                VarV4182 = false
            else
                local state = StealState.state

                VarV4182 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
            end

            if VarV4179 and IsSafeForFarm(VarV4179) then
                FarmState.job = "leave"
                FarmDoTreadmill(VarV4182)

                return
            end

            if FarmState.job == "belt" or FarmState.job == "leave" then
                FarmState.job = "idle"

                if not VarV4182 and (not StealState or not StealState.running) then
                    StealActive = false
                    StealDest = nil
                end
            end
        end
        local function AutoPlaceEggs_Run()
            if Config.AutoPlaceEggs ~= true or (not EggState or type(EggState.PlantEgg) ~= "function") then
                return
            end

            local VarV4184

            if not StealState or not StealState.running then
                VarV4184 = false
            else
                local state = StealState.state

                VarV4184 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
            end

            if VarV4184 then
                return
            end

            local Character9 = LocalPlayer.Character
            local VarV4187

            if not Character9 then
                VarV4187 = nil
            else
                local Humanoid = Character9:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character9:FindFirstChild("HumanoidRootPart")

                VarV4187 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            local VarV4190 = FarmOwnPlot()
            local VarV4191 = VarV4190 and VarV4190.PetArea
            local VarV4192

            if not VarV4191 or not VarV4187 then
                VarV4192 = false
            else
                local VarV4193 = FarmBeltPart()

                VarV4192 = not (not not VarV4193 and not not VarV4187 and (if IsSafeForFarm(VarV4187) then math.abs(VarV4187.Position.Y - VarV4193.Position.Y) < 10 else false)) and InBoundsXZ(VarV4191, VarV4187.Position, 2)
            end

            if not VarV4192 or u1119 then
                return
            end

            local Clock28 = os.clock()

            if Clock28 - FarmState.lastPlace < 1.15 then
                return
            end

            local VarV4195, VarV4196 = FarmReadOwnerFiltered()

            if #VarV4195 == 0 then
                return
            end

            if VarV4196 >= FarmMaxSlots() then
                FarmState.lastPlaceWhy = "pen full"

                return
            end

            local VarV4197 = FarmNeedTreadmill()

            if not VarV4197 then
                FarmState.lastPlaceWhy = "no pad"

                return
            end

            FarmState.lastPlace = Clock28

            local uid = VarV4195[1].uid

            if type(EggState.WearEggTool) == "function" then
                pcall(EggState.WearEggTool, uid)
            end

            local Ok72, Ret70, VarV4201 = pcall(function()
                return EggState.PlantEgg(uid, VarV4197)
            end)

            if type(EggState.DoffEggTool) == "function" then
                pcall(EggState.DoffEggTool, uid)
            end

            if Ok72 and Ret70 == true then
                local VarV4202 = FarmState

                VarV4202.placed = VarV4202.placed + 1
                FarmState.lastPlaceWhy = nil
                KozuaLog("plot", "placed", uid)

                if PanelCtl and PanelCtl.bumpPlot then
                    PanelCtl.bumpPlot()
                end

                return
            end

            FarmState.lastPlaceWhy = tostring(VarV4201 or Ret70 or (not Ok72 and "err" or "rejected"))
            KozuaLog("plot", "place fail", uid, FarmState.lastPlaceWhy)
        end
        local function AutoHatch_Run()
            if Config.AutoHatch ~= true or not EggState then
                return
            end
            local Character10 = LocalPlayer.Character
            local Flag4213
            local Ok73
            local VarV4212
            local VarV4204
            if not Character10 then
                VarV4204 = nil
            else
                local Humanoid = Character10:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character10:FindFirstChild("HumanoidRootPart")

                VarV4204 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end
            local VarV4207 = FarmOwnPlot()
            local VarV4208 = VarV4207 and VarV4207.PetArea
            local VarV4209
            if not VarV4208 or not VarV4204 then
                VarV4209 = false
            else
                local VarV4210 = FarmBeltPart()

                VarV4209 = not (not not VarV4210 and not not VarV4204 and (if IsSafeForFarm(VarV4204) then math.abs(VarV4204.Position.Y - VarV4210.Position.Y) < 10 else false)) and InBoundsXZ(VarV4208, VarV4204.Position, 2)
            end
            if not VarV4209 or u1119 then
                return
            end
            local Clock29 = os.clock()
            if Clock29 - FarmState.lastHatch < 0.9 then
                return
            end
            if not EggState then
                VarV4212 = nil
                Flag4213 = true
            end
            repeat
                if Flag4213 or (Flag4213 or type(EggState.ReadOwnerEggs) == "function") then
                    if not Flag4213 then
                        if not Flag4213 then
                            Ok73, VarV4212 = pcall(EggState.ReadOwnerEggs, LocalPlayer.UserId)
                        end
                    end

                    if Flag4213 or (Flag4213 or Ok73 and type(VarV4212) == "table") then
                        Flag4213 = false

                        if type(VarV4212) ~= "table" then
                            return
                        end

                        for k, v in pairs(VarV4212) do
                            if type(v) ~= "table" or v.Placement == nil then
                                continue
                            end

                            local VarV4217 = v.Uid or k
                            local VarV4218 = false

                            if type(EggState.IsReadyToHatch) == "function" then
                                local Ok74, Ret71 = pcall(EggState.IsReadyToHatch, VarV4217)

                                VarV4218 = Ok74 and Ret71 == true
                            end

                            if VarV4218 then
                                FarmState.lastHatch = Clock29

                                if pcall(function()
                                    if type(EggState.BeginHatch) == "function" then
                                        EggState.BeginHatch(VarV4217)
                                    end

                                    if type(EggState.FinishHatch) == "function" then
                                        EggState.FinishHatch(VarV4217)
                                    end
                                end) then
                                    local VarV4221 = FarmState

                                    VarV4221.hatched = VarV4221.hatched + 1
                                    KozuaLog("plot", "hatched", VarV4217)

                                    if u1195 and u1195.hatched then
                                        local VarV4222 = v.AssetCategory or v.Category
                                        local VarV4223 = if not not Directory and VarV4222 then Directory[VarV4222] else nil
                                        local VarV4224 = v1193(v, VarV4223)

                                        pcall(u1195.hatched, {
											name = VarV4223 and VarV4223.DisplayName or v.AssetCategory,
											earn = VarV4224,
											rar = if type(VarV4223) == "table" and type(VarV4223.Rarity) == "table" then tostring(VarV4223.Rarity.DisplayName or (VarV4223.Rarity.Name or (VarV4223.Rarity._id or "?"))) else "?",
											cfg = VarV4223,
											cat = v.AssetCategory or v.Category,
											rec = v
										})
                                    end

                                    if PanelCtl and PanelCtl.bumpPlot then
                                        PanelCtl.bumpPlot()
                                    end
                                end

                                return
                            end
                        end

                        return
                    end
                end

                VarV4212 = nil
                Flag4213 = true
            until not Flag4213
        end
        local function UpgTrails_Run()
            if Config.UpgTrails ~= true then
                return
            end
            local Trails = ReplicatedStorage.Data.Trails
            local VarV4227
            if FarmState.trailsMod == false then
                VarV4227 = nil
            elseif FarmState.trailsMod ~= nil then
                VarV4227 = FarmState.trailsMod
            else
                local Ok75, Ret72 = pcall(require, Trails)

                FarmState.trailsMod = not not Ok75 and (type(Ret72) == "table" and (Ret72 or false))
                VarV4227 = if FarmState.trailsMod ~= false then FarmState.trailsMod else nil
            end
            local VarV4230 = VarV4227 and (VarV4227.Directory or VarV4227)
            local VarV4231 = FarmGetSave()
            if type(VarV4230) ~= "table" or type(VarV4231) ~= "table" then
                return
            end
            local VarV4232 = type(VarV4231.TrailInventory) == "table" and VarV4231.TrailInventory or {}
            local Tab293 = {}
            for _, v in pairs(VarV4230) do
                if type(v) == "table" and type(v._id) == "string" then
                    Tab293[#Tab293 + 1] = v
                end
            end
            table.sort(Tab293, function(Arg422, Arg423)
                return (tonumber(Arg422.Price) or 0) < (tonumber(Arg423.Price) or 0)
            end)
            for i = 1, #Tab293 do
                local VarV4237 = Tab293[i]

                if VarV4232[VarV4237._id] ~= true then
                    local VarV4238 = tonumber(VarV4237.Price) or 0

                    if VarV4238 > 0 then
                        local VarV4239 = tonumber(VarV4238) or 0
                        local VarV4240 = FarmGetSave()

                        if (tonumber(VarV4240 and VarV4240.Money) or 0) - VarV4239 >= v1194(Config.KeepMoney) then
                            local Ok76, Ret73 = pcall(InvokeRemote, "Trailwear", "AskPurchase", VarV4237._id)

                            if Ok76 and Ret73 == true then
                                local VarV4243 = FarmState

                                VarV4243.bought = VarV4243.bought + 1
                                KozuaLog("plot", "trail bought", VarV4237._id)
                                pcall(InvokeRemote, "Trailwear", "AskChoose", VarV4237._id)
                            end
                        end
                    end

                    return
                end
            end
            local VarV4244
            for i = 1, #Tab293 do
                local VarV4246 = Tab293[i]

                if VarV4232[VarV4246._id] == true then
                    VarV4244 = VarV4246
                end
            end
            if VarV4244 and VarV4231.EquippedTrail ~= VarV4244._id then
                pcall(InvokeRemote, "Trailwear", "AskChoose", VarV4244._id)
            end
        end
        local function UpgTreadmill_Run()
            if Config.UpgTreadmill ~= true then
                return
            end
            local Treadmills = ReplicatedStorage.Data.Treadmills
            local VarV4248
            if FarmState.tmsMod == false then
                VarV4248 = nil
            elseif FarmState.tmsMod ~= nil then
                VarV4248 = FarmState.tmsMod
            else
                local Ok77, Ret74 = pcall(require, Treadmills)

                FarmState.tmsMod = not not Ok77 and (type(Ret74) == "table" and (Ret74 or false))
                VarV4248 = if FarmState.tmsMod ~= false then FarmState.tmsMod else nil
            end
            local VarV4251 = VarV4248
            local VarV4252 = FarmGetSave()
            if type(VarV4251) ~= "table" or type(VarV4252) ~= "table" then
                return
            end
            local VarV4253 = (tonumber(VarV4252.TreadmillUpgradeLevel) or 0) + 1
            local VarU4254
            if type(VarV4251.GetByUpgradeLevel) == "function" then
                pcall(function()
                    VarU4254 = VarV4251.GetByUpgradeLevel(VarV4253)
                end)
            end
            if type(VarU4254) ~= "table" then
                return
            end
            local VarV4255 = tonumber(VarU4254.Price) or 0
            if VarV4255 > 0 then
                local VarV4256 = tonumber(VarV4255) or 0
                local VarV4257 = FarmGetSave()

                if not ((tonumber(VarV4257 and VarV4257.Money) or 0) - VarV4256 >= v1194(Config.KeepMoney)) then
                    return
                end
            end
            local Ok78, Ret75 = pcall(InvokeRemote, "Treadmill", "AskTierRaise", VarU4254._id)
            if Ok78 and Ret75 == true then
                KozuaLog("plot", "treadmill", VarU4254._id)
            end
        end
        local function UpgPen_Run()
            if Config.UpgPen ~= true then
                return
            end

            local VarV4260 = FarmGetSave()

            if type(VarV4260) ~= "table" then
                return
            end

            local Bases = ReplicatedStorage.Data.Bases
            local VarV4262

            if FarmState.basesMod == false then
                VarV4262 = nil
            elseif FarmState.basesMod ~= nil then
                VarV4262 = FarmState.basesMod
            else
                local Ok79, Ret76 = pcall(require, Bases)

                FarmState.basesMod = not not Ok79 and (type(Ret76) == "table" and (Ret76 or false))
                VarV4262 = if FarmState.basesMod ~= false then FarmState.basesMod else nil
            end

            local VarV4265 = (tonumber(VarV4260.BaseUpgradeLevel) or 0) + 1
            local VarV4266 = VarV4262 and (VarV4262.BASES and VarV4262.BASES[VarV4265])
            local VarV4267 = type(VarV4266) == "table" and tonumber(VarV4266.Cost) or 0

            if type(VarV4266) ~= "table" then
                return
            end

            if VarV4267 > 0 then
                local VarV4268 = tonumber(VarV4267) or 0
                local VarV4269 = FarmGetSave()

                if not ((tonumber(VarV4269 and VarV4269.Money) or 0) - VarV4268 >= v1194(Config.KeepMoney)) then
                    return
                end
            end

            FireRemote("Homestead", "AskBaseTierRaise")
            KozuaLog("plot", "pen tier", VarV4265)
        end
        local function EquipBest_Pick(EquipRec)
            local Tab294 = {}
            local VarV4273 = EquipRec and EquipRec.EquippedAssets

            if type(VarV4273) == "table" then
                for _, v in pairs(VarV4273) do
                    Tab294[tostring(v)] = true
                end
            end

            return Tab294
        end
        local function EquipBest_Run()
            local VarV4305 = v1194(Config.SellUnderGen)
            local Tab295 = {}
            local Tab296 = {}
            if VarV4305 <= 0 then
                local VarV4308 = FarmState
                local VarV4309 = FarmState
                local VarV4310 = FarmState

                VarV4308.sellPets = Tab295
                VarV4309.sellEggs = Tab296
                VarV4310.sellFloor = VarV4305

                return Tab295, Tab296, VarV4305
            end
            local VarV4311 = FarmGetSave()
            local VarV4312 = EquipBest_Pick(VarV4311)
            local VarV4313 = VarV4311 and VarV4311.Inventory
            local Flag4322
            local Ok80
            local VarV4321
            if type(VarV4313) == "table" then
                for k, v in pairs(VarV4313) do
                    if type(v) == "table" then
                        local StrId37 = tostring(k)
                        local VarV4317 = v.IsFavorite == true

                        if not VarV4312[StrId37] and not VarV4317 and v.InFuse ~= true then
                            local VarV4318 = v.Category or v.AssetCategory
                            local VarV4319 = if not not Directory and VarV4318 then Directory[VarV4318] else nil
                            local VarV4320 = v1193(v, VarV4319)

                            if VarV4320 < VarV4305 then
                                Tab295[#Tab295 + 1] = {
									uid = StrId37,
									cat = VarV4318,
									cfg = VarV4319,
									earn = VarV4320,
									rec = v,
									price = 0
								}
                            end
                        end
                    end
                end
            end
            if not EggState then
                VarV4321 = nil
                Flag4322 = true
            end
            repeat
                if Flag4322 or (Flag4322 or type(EggState.ReadOwnerEggs) == "function") then
                    if not Flag4322 then
                        if not Flag4322 then
                            Ok80, VarV4321 = pcall(EggState.ReadOwnerEggs, LocalPlayer.UserId)
                        end
                    end

                    if Flag4322 or (Flag4322 or Ok80 and type(VarV4321) == "table") then
                        Flag4322 = false

                        if type(VarV4321) ~= "table" then
                            VarV4321 = VarV4311 and VarV4311.EggInventory
                        end

                        if type(VarV4321) == "table" then
                            for k, v in pairs(VarV4321) do
                                if type(v) == "table" and v.Placement == nil then
                                    local VarV4326 = v.AssetCategory or v.Category
                                    local VarV4327 = if not not Directory and VarV4326 then Directory[VarV4326] else nil
                                    local VarV4328 = v1193(v, VarV4327)

                                    if VarV4328 < VarV4305 then
                                        Tab296[#Tab296 + 1] = {
											uid = tostring(v.Uid or k),
											cat = VarV4326,
											cfg = VarV4327,
											earn = VarV4328,
											rec = v,
											price = 0
										}
                                    end
                                end
                            end
                        end

                        local VarV4329 = FarmState
                        local VarV4330 = FarmState
                        local VarV4331 = FarmState

                        VarV4329.sellPets = Tab295
                        VarV4330.sellEggs = Tab296
                        VarV4331.sellFloor = VarV4305

                        return Tab295, Tab296, VarV4305
                    end
                end

                VarV4321 = nil
                Flag4322 = true
            until not Flag4322
        end
        local function SellFindPrompt()
            local Stands = workspace:FindFirstChild("Stands")
            local VarV4333 = Stands and Stands:FindFirstChild("Prompts")
            local VarV4334 = VarV4333 and (VarV4333:FindFirstChild("SellHeldAsset") or VarV4333:FindFirstChild("SellAll"))

            if not VarV4334 or not VarV4334:IsA("BasePart") then
                return
            end

            local ProximityPrompt = VarV4334:FindFirstChildWhichIsA("ProximityPrompt")

            if ProximityPrompt then
                pcall(function()
                    ProximityPrompt.HoldDuration = 0
                    ProximityPrompt.RequiresLineOfSight = false
                    ProximityPrompt.MaxActivationDistance = 14
                    ProximityPrompt.ClickablePrompt = true
                end)
            end

            local vector3 = Vector3.new(VarV4334.CFrame.LookVector.X, 0, VarV4334.CFrame.LookVector.Z)

            if vector3.Magnitude < 0.15 then
                vector3 = Vector3.new(VarV4334.CFrame.RightVector.X, 0, VarV4334.CFrame.RightVector.Z)
            end

            local VarV4337 = vector3.Magnitude > 0.15 and vector3.Unit or Vector3.new(1, 0, 0)
            local VarV4338 = VarV4334.Position + VarV4337 * 7
            local VarV4339 = VarV4334.Position - VarV4337 * 7
            local Character11 = LocalPlayer.Character
            local VarV4341

            if not Character11 then
                VarV4341 = nil
            else
                local Humanoid = Character11:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character11:FindFirstChild("HumanoidRootPart")

                VarV4341 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            local VarU4344 = VarV4338

            if VarV4341 and Vector3.new(VarV4341.Position.X - VarV4338.X, 0, VarV4341.Position.Z - VarV4338.Z).Magnitude > Vector3.new(VarV4341.Position.X - VarV4339.X, 0, VarV4341.Position.Z - VarV4339.Z).Magnitude + 1.5 then
                VarU4344 = VarV4339
            end

            local VarU4345 = VarV4334.Position.Y + 3.2

            pcall(function()
                local vector3_7 = Vector3.new(VarU4344.X, VarV4334.Position.Y + 16, VarU4344.Z)
                local raycastParams = RaycastParams.new()

                raycastParams.FilterType = Enum.RaycastFilterType.Exclude

                local Tab297 = {
					LocalPlayer.Character,
					VarV4334
				}

                if u1119 then
                    Tab297[#Tab297 + 1] = u1119
                end

                raycastParams.FilterDescendantsInstances = Tab297

                local raycastResult = workspace:Raycast(vector3_7, Vector3.new(0, -80, 0), raycastParams)

                if raycastResult then
                    VarU4345 = raycastResult.Position.Y + 3
                end
            end)

            if VarV4341 and Vector3.new(VarV4341.Position.X - VarU4344.X, 0, VarV4341.Position.Z - VarU4344.Z).Magnitude < 6 then
                VarU4345 = math.min(VarU4345, VarV4341.Position.Y)
            end

            return Vector3.new(VarU4344.X, VarU4345, VarU4344.Z), VarV4334, ProximityPrompt
        end
        local function SellIsNear(SellProx)
            local VarV4359

            if not SellProx then
                VarV4359 = nil
            else
                local VarV4360 = SellProx:GetAttribute("UID") or SellProx:GetAttribute("Uid")

                VarV4359 = if type(VarV4360) ~= "string" or VarV4360 == "" then nil else VarV4360
            end

            local VarV4361 = SellProx and SellProx:GetAttribute("ItemType")

            if VarV4361 == "AssetEgg" and VarV4359 then
                InvokeRemote("EggWorld", "AskDoffTool", VarV4359)

                return
            end

            if VarV4361 == "Asset" and VarV4359 then
                InvokeRemote("PenRoster", "AskDoff", VarV4359)

                return
            end

            local VarV4362 = select(1, GetCharParts())

            if VarV4362 then
                pcall(function()
                    VarV4362:UnequipTools()
                end)
            end
        end
        local function SellWearCheck(WearInfo)
            local VarV4364 = WearInfo and (WearInfo.uid and tostring(WearInfo.uid))

            if not VarV4364 then
                return false
            end

            local Character12 = LocalPlayer.Character
            local VarV4366 = Character12 and Character12:FindFirstChildWhichIsA("Tool")
            local VarV4367

            if not VarV4366 then
                VarV4367 = nil
            elseif VarV4366:GetAttribute("ItemType") == "Gear" then
                VarV4367 = nil
            elseif not VarV4366 then
                VarV4367 = nil
            else
                local VarV4368 = VarV4366:GetAttribute("UID") or VarV4366:GetAttribute("Uid")

                VarV4367 = if type(VarV4368) ~= "string" or VarV4368 == "" then nil else VarV4368
            end

            if VarV4367 == VarV4364 then
                return true
            end

            local Clock30 = os.clock()

            if Clock30 - (FarmState.lastWear or 0) < 0.4 then
                return false
            end

            local VarV4370 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")

            if VarV4370 then
                local VarV4371

                if not VarV4370 then
                    VarV4371 = nil
                else
                    local VarV4372 = VarV4370:GetAttribute("UID") or VarV4370:GetAttribute("Uid")

                    VarV4371 = if type(VarV4372) ~= "string" or VarV4372 == "" then nil else VarV4372
                end

                if VarV4371 ~= VarV4364 then
                    FarmState.lastWear = Clock30
                    SellIsNear(VarV4370)

                    return false
                end
            end

            local StrId38 = tostring(VarV4364)

            local function AutoSellPets_Fn_4374(SellUid)
                if not SellUid then
                    return
                end

                for _, child in ipairs(SellUid:GetChildren()) do
                    if not child:IsA("Tool") then
                        continue
                    end

                    local VarV4855

                    if not child then
                        VarV4855 = nil
                    else
                        local VarV4856 = child:GetAttribute("UID") or child:GetAttribute("Uid")

                        VarV4855 = if type(VarV4856) ~= "string" or VarV4856 == "" then nil else VarV4856
                    end

                    if VarV4855 == StrId38 then
                        return child
                    end
                end
            end

            local VarV4375 = AutoSellPets_Fn_4374(LocalPlayer.Character) or AutoSellPets_Fn_4374(LocalPlayer:FindFirstChild("Backpack"))
            local VarV4376 = select(1, GetCharParts())

            if VarV4375 and VarV4376 then
                FarmState.lastWear = Clock30

                if VarV4375.Parent ~= LocalPlayer.Character then
                    pcall(function()
                        VarV4376:EquipTool(VarV4375)
                    end)
                end

                local VarV4377 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                local VarV4378

                if not VarV4377 then
                    VarV4378 = nil
                else
                    local VarV4379 = VarV4377:GetAttribute("UID") or VarV4377:GetAttribute("Uid")

                    VarV4378 = if type(VarV4379) ~= "string" or VarV4379 == "" then nil else VarV4379
                end

                return VarV4378 == VarV4364
            end

            FarmState.lastWear = Clock30

            if WearInfo.kind == "egg" then
                InvokeRemote("EggWorld", "AskWearTool", VarV4364)
            else
                InvokeRemote("PenRoster", "AskWear", VarV4364)
            end

            return false
        end
        local function SellSingle(SellSingleUid)
            FireRemote("PetSatchel", "SellPet", { SellSingleUid })

            local _, VarV4382, VarV4383 = SellFindPrompt()

            if VarV4383 then
                v1190(VarV4383)

                return
            end

            if VarV4382 then
                local ProximityPrompt = VarV4382:FindFirstChildWhichIsA("ProximityPrompt")

                if ProximityPrompt then
                    v1190(ProximityPrompt)
                end
            end
        end
        local function SellTickPets()
            local VarV4385, VarV4386 = EquipBest_Run()

            if Config.AutoSellPets == true and #VarV4385 > 0 then
                table.sort(VarV4385, function(Arg429, Arg430)
                    return Arg429.earn < Arg430.earn
                end)
                VarV4385[1].kind = "pet"

                return VarV4385[1]
            end

            if Config.AutoSellEggs == true and #VarV4386 > 0 then
                table.sort(VarV4386, function(Arg431, Arg432)
                    return Arg431.earn < Arg432.earn
                end)
                VarV4386[1].kind = "egg"

                return VarV4386[1]
            end
        end
        local function SellTickEggs()
            if not Config.AutoSellPets and not Config.AutoSellEggs then
                return
            end

            if FarmState.expectSold then
                local Character13 = LocalPlayer.Character
                local VarV4388 = Character13 and Character13:FindFirstChildWhichIsA("Tool")
                local VarV4389

                if not VarV4388 then
                    VarV4389 = nil
                elseif VarV4388:GetAttribute("ItemType") == "Gear" then
                    VarV4389 = nil
                elseif not VarV4388 then
                    VarV4389 = nil
                else
                    local VarV4390 = VarV4388:GetAttribute("UID") or VarV4388:GetAttribute("Uid")

                    VarV4389 = if type(VarV4390) ~= "string" or VarV4390 == "" then nil else VarV4390
                end

                if VarV4389 ~= FarmState.expectSold.uid then
                    if FarmState.expectSold.kind == "egg" then
                        local VarV4391 = FarmState

                        VarV4391.soldEggs = VarV4391.soldEggs + 1
                    else
                        local VarV4392 = FarmState

                        VarV4392.soldPets = VarV4392.soldPets + 1
                    end

                    if u1195 and u1195.sold then
                        pcall(u1195.sold, FarmState.expectSold)
                    end

                    FarmState.expectSold = nil
                end
            end

            local Character14 = LocalPlayer.Character
            local VarV4394

            if not Character14 then
                VarV4394 = nil
            else
                local Humanoid = Character14:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character14:FindFirstChild("HumanoidRootPart")

                VarV4394 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            if SellFindPrompt() then
                local VarV4397 = SellFindPrompt()

                if not VarV4394 or (typeof(VarV4397) ~= "Vector3" or not (Vector3.new(VarV4394.Position.X - VarV4397.X, 0, VarV4394.Position.Z - VarV4397.Z).Magnitude < 5.5)) then
                    return
                end
            end

            local VarV4398 = SellTickPets()

            if not VarV4398 then
                return
            end

            if not SellWearCheck(VarV4398) then
                FarmState.sellWhy = "equipping"

                return
            end

            local Clock31 = os.clock()

            if Clock31 - FarmState.lastSell < 0.55 then
                return
            end

            FarmState.lastSell = Clock31
            FarmState.sellWhy = "selling"
            SellSingle(VarV4398.uid)
            FarmState.expectSold = {
				uid = VarV4398.uid,
				kind = VarV4398.kind,
				name = VarV4398.cfg and VarV4398.cfg.DisplayName or VarV4398.cat,
				earn = VarV4398.earn,
				cfg = VarV4398.cfg,
				cat = VarV4398.cat
			}
            KozuaLog("plot", "sell held", VarV4398.kind, VarV4398.uid)
        end
        local function TreadmillTick()
            if Config.ClaimIndex ~= true then
                return
            end

            if FarmState.claimBusy or FarmState.job == "sell" then
                return
            end

            local Clock32 = os.clock()

            if Clock32 - (FarmState.lastClaim or 0) < 8 then
                return
            end

            FarmState.lastClaim = Clock32
            FarmState.claimBusy = true

            local VarV4401 = GetRemote("Codex", "AskRedeemAll")

            if not VarV4401 then
                FarmState.claimWhy = "no remote"
                FarmState.claimBusy = false

                return
            end

            local Ok81, Ret77, VarV4404, VarV4405 = pcall(function()
                return VarV4401:InvokeServer()
            end)

            if not Ok81 then
                FarmState.claimWhy = tostring(Ret77)
            elseif Ret77 == true then
                local Num64 = 0

                if type(VarV4405) == "table" then
                    for _ in ipairs(VarV4405) do
                        Num64 += 1
                    end

                    if Num64 == 0 then
                        for _ in pairs(VarV4405) do
                            Num64 += 1
                        end
                    end
                end

                if Num64 > 0 then
                    local VarV4409 = FarmState

                    VarV4409.claimIndex = VarV4409.claimIndex + Num64
                    FarmState.claimWhy = "claimed " .. Num64

                    if u1195 and u1195.rewards then
                        pcall(u1195.rewards, Num64)
                    end
                else
                    FarmState.claimWhy = "nothing to claim"
                end
            else
                FarmState.claimWhy = tostring(VarV4404 or "nothing to claim")
            end

            FarmState.claimBusy = false
        end
        local function ClaimIndexTick()
            if Config.AutoTreadmill ~= true then
                FarmLeaveBelt()

                return
            end
            if StealState and StealState.running and StealState.allowTrain and not StealState.allowTrain() then
                return
            end
            local Flag4410
            local Flag4411
            local VarV4412
            local VarV4413
            local VarV4414
            local Flag4433
            local VarV4432
            repeat
                if Flag4410 or ((tonumber(Config.ReadyEarly) or 4) >= EggCycleCountdown() or Config.AutoSteal == true and (StealState and (StealState.running and (not StealState.allowTrain or StealState.allowTrain() ~= true)))) then
                    Flag4410 = false

                    if FarmState.training or FarmState.job == "belt" then
                        FarmLeaveBelt()
                    end

                    return
                end

                repeat
                    if Flag4411 or Config.AutoPlaceEggs == true then
                        if not Flag4411 then
                            VarV4412, VarV4413 = FarmReadOwnerFiltered()
                        end

                        if Flag4411 or #VarV4412 > 0 and VarV4413 < FarmMaxSlots() then
                            if not Flag4411 then
                                VarV4414 = true
                            end

                            Flag4411 = false

                            if VarV4414 then
                                Flag4410 = true
                            end

                            if not Flag4410 then
                                local Clock33 = os.clock()
                                local VarV4416 = FarmGetSave()
                                local VarV4417 = tonumber(VarV4416 and VarV4416.SpeedPower) or 0

                                if FarmState.lastPower and Clock33 > FarmState.lastPowerAt then
                                    local VarV4418 = Clock33 - FarmState.lastPowerAt

                                    if VarV4418 > 0.2 then
                                        local VarV4419 = math.max(0, VarV4417 - FarmState.lastPower)
                                        local VarV4420 = FarmState

                                        VarV4420.trainEarned = VarV4420.trainEarned + VarV4419
                                        FarmState.trainRate = VarV4419 / VarV4418
                                    end
                                end

                                FarmState.lastPower = VarV4417
                                FarmState.lastPowerAt = Clock33

                                local VarV4421 = FarmBeltPart()
                                local VarV4422 = if VarV4421 then VarV4421.Position + Vector3.new(0, VarV4421.Size.Y * 0.5 + 3.2, 0) else nil
                                local Character15 = LocalPlayer.Character
                                local VarV4424

                                if not Character15 then
                                    VarV4424 = nil
                                else
                                    local Humanoid = Character15:FindFirstChildOfClass("Humanoid")
                                    local HumanoidRootPart = Character15:FindFirstChild("HumanoidRootPart")

                                    VarV4424 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
                                end

                                if not VarV4422 or not VarV4424 then
                                    return
                                end

                                FarmState.job = "belt"

                                local VarV4427 = FarmBeltPart()

                                if not VarV4427 or not VarV4424 or not if IsSafeForFarm(VarV4424) then math.abs(VarV4424.Position.Y - VarV4427.Position.Y) < 10 else false then
                                    FarmState.training = false
                                    FarmPlotInfo(VarV4422)

                                    return
                                end

                                StealActive = false
                                StealDest = nil

                                if u1119 or Clock33 - FarmState.lastTrain < 1.2 then
                                    return
                                end

                                FarmState.lastTrain = Clock33

                                local Ok82, Ret78, VarV4430 = pcall(function()
                                    return InvokeRemote("Treadmill", "AskWearStill")
                                end)
                                local VarV4431 = FarmState

                                if Ok82 then
                                    VarV4432 = true

                                    if Ret78 == true then
                                        Flag4433 = true
                                    end
                                end

                                if not Flag4433 then
                                    local VarV4434 = FarmBeltPart()

                                    VarV4432 = not not VarV4434 and not not VarV4424 and if IsSafeForFarm(VarV4424) then math.abs(VarV4424.Position.Y - VarV4434.Position.Y) < 10 else false
                                end

                                Flag4433 = false
                                VarV4431.training = VarV4432

                                if not Ok82 or Ret78 ~= true then
                                    KozuaLog("plot", "wear fail", (tostring(VarV4430 or Ret78)))
                                end

                                return
                            end
                        end
                    end

                    if Flag4410 then
                        break
                    end

                    VarV4414 = FarmHatchReady()
                    Flag4411 = true
                until not Flag4411
            until not Flag4410
        end
        local function FarmStatusTick()
            local Clock34 = os.clock()
            if Clock34 - FarmState.lastPaint < 0.45 then
                return
            end
            FarmState.lastPaint = Clock34
            local PlaceStatus = "idle"
            local Flag4447
            if Config.AutoPlaceEggs then
                PlaceStatus = if FarmState.job ~= "pad" then not FarmState.lastPlaceWhy and "running" or tostring(FarmState.lastPlaceWhy) else "flying to plot"
            end
            local VarV4437 = PlaceStatus .. " · placed " .. FarmState.placed .. " · hatched " .. FarmState.hatched
            local AutoPlaceEggs = WidgetRegistry.AutoPlaceEggs
            if AutoPlaceEggs and AutoPlaceEggs.status then
                pcall(function()
                    AutoPlaceEggs.status.Text = VarV4437
                end)
            end
            local VarV4439 = (not Config.UpgTrails and "idle" or "running") .. " · bought " .. FarmState.bought
            local UpgTrails = WidgetRegistry.UpgTrails
            if UpgTrails and UpgTrails.status then
                pcall(function()
                    UpgTrails.status.Text = VarV4439
                end)
            end
            local VarV4441, VarV4442, VarV4443 = EquipBest_Run()
            local VarV4444 = #VarV4441
            local VarV4445 = #VarV4442
            local SellStatus = "off"
            if Config.AutoSellPets or Config.AutoSellEggs then
                if VarV4443 <= 0 then
                    SellStatus = "set a $/s floor"
                    Flag4447 = true
                end

                if not Flag4447 then
                    if FarmState.job ~= "sell" then
                        SellStatus = VarV4444 + VarV4445 ~= 0 and "selling" or "nothing under the floor"
                        Flag4447 = true
                    end

                    if not Flag4447 then
                        local Character16 = LocalPlayer.Character
                        local VarV4449

                        if not Character16 then
                            VarV4449 = nil
                        else
                            local Humanoid = Character16:FindFirstChildOfClass("Humanoid")
                            local HumanoidRootPart = Character16:FindFirstChild("HumanoidRootPart")

                            VarV4449 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
                        end

                        if VarV4449 then
                            local VarV4452 = SellFindPrompt()

                            if VarV4449 and (typeof(VarV4452) == "Vector3" and Vector3.new(VarV4449.Position.X - VarV4452.X, 0, VarV4449.Position.Z - VarV4452.Z).Magnitude < 5.5) then
                                SellStatus = FarmState.sellWhy or "equipping"
                                Flag4447 = true
                            end
                        end

                        if not Flag4447 then
                            SellStatus = "flying to seller"
                            Flag4447 = true
                        end
                    end
                end
            end
            Flag4447 = false
            local VarV4453 = SellStatus .. " · sold " .. FarmState.soldPets .. " · " .. VarV4444 .. " waiting"
            local AutoSellPets = WidgetRegistry.AutoSellPets
            if AutoSellPets and AutoSellPets.status then
                pcall(function()
                    AutoSellPets.status.Text = VarV4453
                end)
            end
            local VarV4455 = SellStatus .. " · sold " .. FarmState.soldEggs .. " · " .. VarV4445 .. " waiting"
            local AutoSellEggs = WidgetRegistry.AutoSellEggs
            if AutoSellEggs and AutoSellEggs.status then
                pcall(function()
                    AutoSellEggs.status.Text = VarV4455
                end)
            end
            local VarV4457 = (not Config.ClaimIndex and "off" or (FarmState.claimWhy or "running")) .. " · claimed " .. FarmState.claimIndex
            local ClaimIndex = WidgetRegistry.ClaimIndex
            if ClaimIndex and ClaimIndex.status then
                pcall(function()
                    ClaimIndex.status.Text = VarV4457
                end)
            end
            if FarmState.job == "leave" then
                local VarV4459 = "leaving · " .. FmtTrainRate(FarmState.trainRate) .. "/s · earned " .. FmtTrainRate(FarmState.trainEarned) .. " this session"
                local AutoTreadmill = WidgetRegistry.AutoTreadmill

                if AutoTreadmill and AutoTreadmill.status then
                    pcall(function()
                        AutoTreadmill.status.Text = VarV4459
                    end)

                    return
                end
            elseif FarmState.job == "belt" and not FarmState.training then
                local VarV4461 = "flying to treadmill · " .. FmtTrainRate(FarmState.trainRate) .. "/s · earned " .. FmtTrainRate(FarmState.trainEarned) .. " this session"
                local AutoTreadmill = WidgetRegistry.AutoTreadmill

                if AutoTreadmill and AutoTreadmill.status then
                    pcall(function()
                        AutoTreadmill.status.Text = VarV4461
                    end)

                    return
                end
            elseif FarmState.training then
                local VarV4463 = "training · " .. FmtTrainRate(FarmState.trainRate) .. "/s · earned " .. FmtTrainRate(FarmState.trainEarned) .. " this session"
                local AutoTreadmill = WidgetRegistry.AutoTreadmill

                if AutoTreadmill and AutoTreadmill.status then
                    pcall(function()
                        AutoTreadmill.status.Text = VarV4463
                    end)

                    return
                end
            else
                local VarV4465 = "not training · " .. FmtTrainRate(FarmState.trainRate) .. "/s · earned " .. FmtTrainRate(FarmState.trainEarned) .. " this session"
                local AutoTreadmill = WidgetRegistry.AutoTreadmill

                if AutoTreadmill and AutoTreadmill.status then
                    pcall(function()
                        AutoTreadmill.status.Text = VarV4465
                    end)
                end
            end
        end
        local function FlightTick()
            local Character17 = LocalPlayer.Character
            local Flag4483
            local VarV4484
            local VarV4485
            local VarV4486
            local VarV4468
            if not Character17 then
                VarV4468 = nil
            else
                local Humanoid = Character17:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character17:FindFirstChild("HumanoidRootPart")

                VarV4468 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end
            if StealState and type(StealState.haltUntil) == "number" and os.clock() < StealState.haltUntil and not StealState.running then
                FarmState.job = "idle"
                FarmState.training = false
                StealActive = false
                StealDest = nil

                return
            end
            if FarmState.job == "leave" then
                FarmState.training = false

                if VarV4468 and IsSafeForFarm(VarV4468) then
                    local VarV4471 = FarmDoTreadmill
                    local VarV4472

                    if not StealState or not StealState.running then
                        VarV4472 = false
                    else
                        local state = StealState.state

                        VarV4472 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
                    end

                    VarV4471(VarV4472)

                    return
                end

                FarmState.job = "idle"

                local VarV4474

                if not StealState or not StealState.running then
                    VarV4474 = false
                else
                    local state = StealState.state

                    VarV4474 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
                end

                if not VarV4474 and (not StealState or not StealState.running) then
                    StealActive = false
                    StealDest = nil
                end

                EngineRefresh((EngineWantsFlight()))

                if not EngineOn then
                    return
                end

                if (Config.Flight or Config.BypassSpeed) and true or (Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                    FlightEnable()
                    FlightDisable()
                    FlightSetWrap(true)

                    return
                end

                if next(MoveWraps) then
                    FlightSetWrap(false)
                end

                return
            end
            local VarV4476
            if not StealState or not StealState.running then
                VarV4476 = false
            else
                local state = StealState.state

                VarV4476 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
            end
            if VarV4476 then
                if FarmState.job == "sell" then
                    FarmState.job = "idle"
                end

                if VarV4468 and IsSafeForFarm(VarV4468) then
                    FarmState.job = "leave"
                    FarmDoTreadmill(true)
                end

                return
            end
            if (Config.AutoSellPets or Config.AutoSellEggs) and v1194(Config.SellUnderGen) > 0 then
                local VarV4478, VarV4479 = EquipBest_Run()

                if (Config.AutoSellPets and #VarV4478 or 0) + (Config.AutoSellEggs and #VarV4479 or 0) > 0 then
                    if VarV4468 and IsSafeForFarm(VarV4468) then
                        FarmState.job = "leave"
                        FarmDoTreadmill()

                        return
                    end

                    local VarV4480 = SellFindPrompt()

                    if VarV4468 then
                        local VarV4481 = SellFindPrompt()

                        if not VarV4468 or (typeof(VarV4481) ~= "Vector3" or not (Vector3.new(VarV4468.Position.X - VarV4481.X, 0, VarV4468.Position.Z - VarV4481.Z).Magnitude < 5.5)) then
                            FarmState.job = "sell"

                            if VarV4480 then
                                FarmPlotInfo(VarV4480, true)
                            end

                            return
                        end
                    end

                    FarmState.job = "sell"

                    if StealActive or StealDest then
                        StealActive = false
                        StealDest = nil

                        if not Config.Flight then
                            local VarV4482 = select(1, GetCharParts())

                            v1146(VarV4482, VarV4468, true)
                            u1145 = false
                        end
                    end

                    return
                end

                if FarmState.job == "sell" then
                    FarmState.job = "idle"
                    StealActive = false
                    StealDest = nil
                end
            elseif FarmState.job == "sell" then
                FarmState.job = "idle"
                StealActive = false
                StealDest = nil
            end
            repeat
                if Flag4483 or Config.AutoPlaceEggs == true then
                    if not Flag4483 then
                        VarV4484, VarV4485 = FarmReadOwnerFiltered()
                    end

                    if Flag4483 or #VarV4484 > 0 and VarV4485 < FarmMaxSlots() then
                        if not Flag4483 then
                            VarV4486 = true
                        end
                        if VarV4486 then
                            if VarV4468 and IsSafeForFarm(VarV4468) then
                                FarmState.job = "leave"
                                FarmDoTreadmill()

                                return
                            end

                            FarmState.job = "pad"

                            local VarV4487 = FarmFreeSlots()

                            if VarV4487 then
                                if VarV4468 then
                                    local VarV4488 = FarmOwnPlot()
                                    local VarV4489 = VarV4488 and VarV4488.PetArea
                                    local VarV4490

                                    if not VarV4489 or not VarV4468 then
                                        VarV4490 = false
                                    else
                                        local VarV4491 = FarmBeltPart()

                                        VarV4490 = not (not not VarV4491 and not not VarV4468 and (if IsSafeForFarm(VarV4468) then math.abs(VarV4468.Position.Y - VarV4491.Position.Y) < 10 else false)) and InBoundsXZ(VarV4489, VarV4468.Position, 2)
                                    end

                                    if VarV4490 then
                                        StealActive = false
                                        StealDest = nil

                                        return
                                    end
                                end

                                FarmPlotInfo(VarV4487)
                            end

                            return
                        end
                        if StealState and StealState.running then
                            FarmState.training = false

                            if FarmState.job == "belt" then
                                FarmState.job = "idle"
                            end
                        end
                        if Config.AutoTreadmill == true and (Config.AutoSteal ~= true or (not StealState or (not StealState.running or StealState.allowTrain and StealState.allowTrain() == true))) then
                            ClaimIndexTick()

                            return
                        end
                        if FarmState.job == "pad" or FarmState.job == "belt" or FarmState.job == "sell" then
                            FarmState.job = "idle"
                        end
                        if not StealState or not StealState.running then
                            StealActive = false
                            StealDest = nil
                        end

                        return
                    end
                end

                VarV4486 = FarmHatchReady()
                Flag4483 = true
            until not Flag4483
        end
        local VarU2253
        local function SellPreviewCalc(PreviewA, PreviewB)
            local Tab298 = {}

            for i = 1, #PreviewA do
                local VarV4499 = PreviewA[i]
                local StrId39 = tostring(VarV4499.cat or "?")
                local VarV4501 = PreviewB .. ":" .. StrId39
                local VarV4502 = Tab298[VarV4501]

                if not VarV4502 then
                    VarV4502 = {
						kind = PreviewB,
						cat = StrId39,
						cfg = VarV4499.cfg,
						earn = VarV4499.earn,
						rec = VarV4499.rec,
						price = 0,
						n = 0
					}
                    Tab298[VarV4501] = VarV4502
                end

                VarV4502.n = VarV4502.n + 1
                VarV4502.price = VarV4502.price + (tonumber(VarV4499.price) or 0)

                if (VarV4499.earn or 0) < (VarV4502.earn or 0) then
                    VarV4502.earn = VarV4499.earn
                end
            end

            local Tab299 = {}

            for _, v in pairs(Tab298) do
                Tab299[#Tab299 + 1] = v
            end

            table.sort(Tab299, function(Arg435, Arg436)
                if Arg435.earn ~= Arg436.earn then
                    return Arg435.earn < Arg436.earn
                end

                return tostring(Arg435.cat) < tostring(Arg436.cat)
            end)

            return Tab299
        end
        local function SellPreviewRender(PrevPets, PrevEggs, PrevFloor, PrevMsg)
            local VarV4510 = type(PrevPets) == "table" and PrevPets or {}
            local VarV4511 = type(PrevEggs) == "table" and PrevEggs or {}
            local VarV4512 = tonumber(PrevFloor) or 0
            local Tab300 = {}
            local Tab301 = {}

            if type(PrevMsg) == "string" and PrevMsg ~= "" then
            elseif VarV4512 <= 0 then
                PrevMsg = "set a $/s floor or nothing sells"
            else
                Tab300 = SellPreviewCalc(VarV4510, "pet")
                Tab301 = SellPreviewCalc(VarV4511, "egg")
                PrevMsg = if #VarV4510 + #VarV4511 ~= 0 then #VarV4510 .. " pets · " .. #VarV4511 .. " eggs under " .. FmtTrainRate(VarV4512) .. "/s" else "nothing under " .. FmtTrainRate(VarV4512) .. "/s — plot/pen pets stay"
            end

            local VarV4515 = PrevMsg
            local SellPreview = WidgetRegistry.SellPreview

            if SellPreview and SellPreview.status then
                pcall(function()
                    SellPreview.status.Text = VarV4515
                end)
            end

            if not PanelCtl or not PanelCtl.sellPreview then
                local SellPreview2 = WidgetRegistry.SellPreview

                if SellPreview2 and SellPreview2.status then
                    local State30 = "preview missing"

                    pcall(function()
                        SellPreview2.status.Text = State30
                    end)
                end

                KozuaLog("plot", "preview missing espApi.sellPreview")

                return
            end

            local Ok83, Ret79 = pcall(PanelCtl.sellPreview, Tab300, Tab301, PrevMsg)

            if not Ok83 then
                local VarV4521 = "failed · " .. tostring(Ret79)
                local SellPreview3 = WidgetRegistry.SellPreview

                if SellPreview3 and SellPreview3.status then
                    pcall(function()
                        SellPreview3.status.Text = VarV4521
                    end)
                end

                KozuaLog("plot", "preview ERR", (tostring(Ret79)))

                return
            end

            if Ret79 ~= true then
                local SellPreview4 = WidgetRegistry.SellPreview

                if SellPreview4 and SellPreview4.status then
                    local State31 = "failed to open"

                    pcall(function()
                        SellPreview4.status.Text = State31
                    end)
                end
            end
        end
        local function SellPreviewQueue()
            local Tab302 = {}
            local VarV4526, VarV4527, VarV4528

            if pcall(function()
                local VarV4863 = Tab302
                local VarV4864 = Tab302
                local VarV4865 = Tab302
                local VarV4866, VarV4867, VarV4868 = EquipBest_Run()

                VarV4863[1] = VarV4866
                VarV4864[2] = VarV4867
                VarV4865[3] = VarV4868
            end) then
                VarV4526 = Tab302[1]
                VarV4527 = Tab302[2]
                VarV4528 = Tab302[3]
            else
                VarV4526 = FarmState.sellPets or {}
                VarV4527 = FarmState.sellEggs or {}
                VarV4528 = FarmState.sellFloor or v1194(Config.SellUnderGen)
            end

            SellPreviewRender(VarV4526, VarV4527, VarV4528)
        end

        return {
			sync = function()
            if not (Config.AutoPlaceEggs or (Config.AutoHatch or (Config.EquipBest or (Config.UpgTrails or (Config.UpgTreadmill or (Config.UpgPen or (Config.AutoSellPets or (Config.AutoSellEggs or (Config.AutoTreadmill or Config.ClaimIndex))))))))) then
                FarmLeaveBelt()
            end

            EngineRefresh((EngineWantsFlight()))

            if not EngineOn then
                return
            end

            if (Config.Flight or Config.BypassSpeed) and true or (not not Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                FlightEnable()
                FlightDisable()
                FlightSetWrap(true)

                return
            end

            if next(MoveWraps) then
                FlightSetWrap(false)
            end
        end,
			stop = function()
            FarmState.training = false
            FarmState.job = "idle"

            if not StealState or not StealState.running then
                StealActive = false
                StealDest = nil
            end

            EngineRefresh((EngineWantsFlight()))

            if not EngineOn then
                return
            end

            if (Config.Flight or Config.BypassSpeed) and true or (Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                FlightEnable()
                FlightDisable()
                FlightSetWrap(true)

                return
            end

            if next(MoveWraps) then
                FlightSetWrap(false)
            end
        end,
			tick = function()
            if not IsAlive then
                return
            end

            FlightTick()
            AutoPlaceEggs_Run()
            AutoHatch_Run()

            if Config.EquipBest == true then
                local Clock35 = os.clock()

                if not (Clock35 - FarmState.lastEquip < 4) then
                    FarmState.lastEquip = Clock35
                    pcall(function()
                        InvokeRemote("Haul", "WearBest")
                    end)
                end
            end

            local Clock36 = os.clock()

            if not (Clock36 - FarmState.lastUpg < 4) and (Config.UpgTrails or Config.UpgTreadmill or Config.UpgPen) then
                FarmState.lastUpg = Clock36
                UpgTrails_Run()
                UpgTreadmill_Run()
                UpgPen_Run()
            end

            SellTickEggs()
            TreadmillTick()
            FarmStatusTick()
        end,
			wanted = function()
            return Config.AutoPlaceEggs or (Config.AutoHatch or (Config.EquipBest or (Config.UpgTrails or (Config.UpgTreadmill or (Config.UpgPen or (Config.AutoSellPets or (Config.AutoSellEggs or (Config.AutoTreadmill or Config.ClaimIndex))))))))
        end,
			driving = function()
            return StealActive == true and (FarmState.job == "pad" or (FarmState.job == "belt" or FarmState.job == "sell"))
        end,
			leaving = function()
            return FarmState.job == "leave"
        end,
			leave = FarmLeaveBelt,
			kickBelt = function()
            local Character18 = LocalPlayer.Character
            local VarV4171

            if not Character18 then
                VarV4171 = nil
            else
                local Humanoid = Character18:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character18:FindFirstChild("HumanoidRootPart")

                VarV4171 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            if not VarV4171 or not IsSafeForFarm(VarV4171) then
                if FarmState.training or FarmState.job == "belt" then
                    FarmState.training = false
                    FarmState.job = "idle"
                end

                return
            end

            local Clock37 = os.clock()

            if Clock37 - (FarmState.lastKick or 0) < 0.55 then
                return
            end

            FarmState.lastKick = Clock37
            FarmState.training = false
            FarmState.job = "leave"

            local VarV4175 = FarmDoTreadmill
            local VarV4176

            if not StealState or not StealState.running then
                VarV4176 = false
            else
                local state = StealState.state

                VarV4176 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
            end

            if not VarV4176 then
                VarV4176 = (StealState and StealState.running) == true
            end

            VarV4175(VarV4176)
        end,
			holding = function()
            return FarmState.training == true or FarmState.job == "sell"
        end,
			preview = SellPreviewQueue,
			queuePreview = function()
            local VarV4530 = type(FarmState.sellPets) == "table" and FarmState.sellPets or {}
            local VarV4531 = type(FarmState.sellEggs) == "table" and FarmState.sellEggs or {}
            local num = tonumber(FarmState.sellFloor)

            if num == nil then
                local VarV4533 = v1194(Config.SellUnderGen)

                SellPreviewRender(VarV4530, VarV4531, VarV4533, "opening…")
            else
                SellPreviewRender(VarV4530, VarV4531, num)
            end

            FarmState.previewQueued = true

            if VarU2253 then
                return
            end

            local connection19 = RunService.Stepped:Connect(function()
                if not IsAlive then
                    return
                end

                if not FarmState.previewQueued then
                    return
                end

                FarmState.previewQueued = false

                local VarV4874 = VarU2253

                VarU2253 = nil

                local Ok84, Ret80 = pcall(SellPreviewQueue)

                if not Ok84 then
                    local VarV4877 = "failed · " .. tostring(Ret80)
                    local SellPreview = WidgetRegistry.SellPreview

                    if SellPreview and SellPreview.status then
                        pcall(function()
                            SellPreview.status.Text = VarV4877
                        end)
                    end

                    KozuaLog("plot", "preview ERR", (tostring(Ret80)))
                end

                if VarV4874 then
                    pcall(function()
                        VarV4874:Disconnect()
                    end)
                end
            end)

            if connection19 then
                ConnList[connection19] = true
            end

            VarU2253 = connection19
        end,
			stats = function()
            return {
					hatched = FarmState.hatched,
					soldPets = FarmState.soldPets,
					soldEggs = FarmState.soldEggs,
					placed = FarmState.placed,
					claimIndex = FarmState.claimIndex,
					claimCash = FarmState.claimCash
				}
        end
		}
    end)()
    local function RefreshSteal()
        local AutoSteal = WidgetRegistry.AutoSteal

        if not AutoSteal or not AutoSteal.status then
            return
        end

        local target = StealState.target
        local state = StealState.state
        local TrainStatus = "idle"

        if state == "Night" then
            TrainStatus = "night · " .. tostring(EggCycleCountdownRounded()) .. "s left"
        elseif state == "Scan" then
            TrainStatus = "looking"

            if type(StealState.lookWhy) == "string" and StealState.lookWhy ~= "" then
                TrainStatus = "looking · " .. StealState.lookWhy
            end
        elseif state == "Safe" then
            TrainStatus = "going to safe zone"
        elseif state == "Return" then
            TrainStatus = "bringing back"
        elseif state == "Bank" then
            TrainStatus = "banking"
        elseif state == "Chase" then
            TrainStatus = target and (not not target.name and "chasing · " .. tostring(target.name)) or "chasing"
        elseif state == "GoEgg" or state == "Grab" then
            local VarV2261 = state ~= "Grab" and "going to" or "grabbing"
            local VarV2262 = target and (not not target.area and tostring(target.area)) or ""
            local VarV2263 = target and (not not target.name and tostring(target.name)) or ""

            TrainStatus = if VarV2262 == "" or VarV2263 == "" then if VarV2263 == "" and VarV2262 == "" then VarV2261 else VarV2261 .. " · " .. (VarV2263 ~= "" and VarV2263 or VarV2262) else VarV2261 .. " · " .. VarV2262 .. " · " .. VarV2263
        elseif state == "FeedGo" then
            TrainStatus = StealState.lookWhy ~= "need infested" and (StealState.lookWhy ~= "equip infested" and StealState.lookWhy ~= "pocket infested") and "going to monster" or StealState.lookWhy
        elseif state == "Feed" then
            TrainStatus = "feeding monster"
        elseif state == "ChestGo" then
            TrainStatus = "picking up chest"
        elseif state == "ChestOpen" then
            TrainStatus = "opening chest"
        elseif type(state) == "string" and state ~= "" and state ~= "Idle" then
            TrainStatus = string.lower(state)
        end

        pcall(function()
            AutoSteal.status.Text = string.format("%s · took %d · lost %d · re-grabbed %d", TrainStatus, StealState.banked, StealState.lost, StealState.regrabs)
        end)

        local AutoEvent = WidgetRegistry.AutoEvent

        if AutoEvent and AutoEvent.status then
            pcall(function()
                local State33 = "off"

                if Config.AutoEvent then
                    State33 = if StealState.lookWhy ~= "need infested" and (StealState.lookWhy ~= "pocket infested" and StealState.lookWhy ~= "equip infested") then if state ~= "FeedGo" then if state ~= "Feed" then if state ~= "ChestGo" then if state ~= "ChestOpen" then (not StealState.target or not StealState.target.event) and "waiting for filters" or "grabbing infested" else "opening chest" else "picking up chest" else "feeding" else "going to monster" else "waiting for egg"
                end

                AutoEvent.status.Text = State33 .. " · fed " .. tostring(StealState.fed or 0) .. " · chests " .. tostring(StealState.chests or 0)
            end)
        end
    end
    function StealState.keepHook(HookEgg)
        if type(HookEgg) ~= "table" then
            return
        end

        local rec = HookEgg.rec
        local cfg = HookEgg.cfg

        if type(cfg) ~= "table" and rec then
            local VarV2268 = rec.AssetCategory or rec.Category

            cfg = if not not Directory and VarV2268 then Directory[VarV2268] else nil
        end

        local VarV2269 = HookEgg.cat or rec and (rec.AssetCategory or rec.Category)
        local name = HookEgg.name

        if type(name) ~= "string" or name == "" or name == "egg" or name == "?" then
            name = cfg and cfg.DisplayName or VarV2269
        end

        local icon = HookEgg.icon

        if type(icon) ~= "string" or icon == "" then
            if PanelCtl and PanelCtl.liveIcon then
                local Ok85, Ret81 = pcall(PanelCtl.liveIcon, cfg, VarV2269, name)

                if Ok85 and type(Ret81) == "string" and Ret81 ~= "" then
                    icon = Ret81
                end
            end

            if (type(icon) ~= "string" or icon == "") and PanelCtl and PanelCtl.icon then
                local Ok86, Ret82 = pcall(PanelCtl.icon, cfg, VarV2269)

                if Ok86 and type(Ret82) == "string" and Ret82 ~= "" then
                    icon = Ret82
                end
            end
        end

        local VarV2276 = StealState
        local Tab303 = {
			rec = rec,
			cfg = cfg,
			cat = VarV2269,
			name = name,
			area = HookEgg.area or "",
			earn = tonumber(HookEgg.earn) or v1193(rec, cfg)
		}

        Tab303.rar = if type(cfg) == "table" and type(cfg.Rarity) == "table" then tostring(cfg.Rarity.DisplayName or (cfg.Rarity.Name or (cfg.Rarity._id or "?"))) else "?"
        Tab303.uid = rec and rec.Uid or HookEgg.uid
        Tab303.icon = icon
        VarV2276.hookSnap = Tab303
    end
    local function HookDigestCheck(PickArea)
        local VarV2279 = StealState.heldUid or StealState.carryUid

        if not VarV2279 or VarV2279 == StealState.countedUid then
            return false
        end

        local VarV2280 = StealState.hookSnap or StealState.target

        StealState.countedUid = VarV2279

        local VarV2281 = StealState

        VarV2281.banked = VarV2281.banked + 1
        StealState.lastBankAt = os.clock()
        StealState.heldUid = nil
        StealState.lockUid = nil
        StealState.lockPos = nil
        StealState.target = nil
        KozuaLog("steal", "took +1", StealState.banked, PickArea or "", tostring(VarV2279):sub(1, 12))
        RefreshSteal()

        if u1195 and u1195.stolen then
            pcall(u1195.stolen, VarV2280)
        end

        StealState.hookSnap = nil

        return true
    end
    local function StealPickTarget(PickRec, PickCfg)
        if type(PickRec) == "table" then
            StealState.target = PickRec

            if StealState.keepHook then
                StealState.keepHook(PickRec)
            end

            if PickRec.rec and PickRec.rec.Uid then
                StealState.lockUid = PickRec.rec.Uid
                StealState.lockAt = os.clock()
            end

            if typeof(PickRec.pos) == "Vector3" then
                StealState.lockPos = PickRec.pos
            end
        end

        StealActive = true

        local Character19 = LocalPlayer.Character
        local VarV2287

        if not Character19 then
            VarV2287 = nil
        else
            local Humanoid = Character19:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = Character19:FindFirstChild("HumanoidRootPart")

            VarV2287 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
        end

        if VarV2287 and StealState.target and typeof(StealState.target.pos) == "Vector3" then
            if PlotIsOwnedPlaced(StealState.target.rec, StealState.target.pos) then
                StealState.target = nil
                StealState.lockUid = nil

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "plot egg", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            if (VarV2287.Position - StealState.target.pos).Magnitude <= 28 then
                local VarV2290 = PickCfg or "egg"

                if StealState.state ~= "GoEgg" then
                    KozuaLog("steal", StealState.state, "->", "GoEgg", VarV2290 or "", StealState.target and StealState.target.name or "")
                    StealState.state = "GoEgg"
                    StealState.since = os.clock()
                else
                    StealState.state = "GoEgg"
                end

                RefreshSteal()

                return
            end
        end

        if VarV2287 and IsAtSpawn(VarV2287) then
            local VarV2291 = PickCfg or "egg"

            if StealState.state ~= "GoEgg" then
                KozuaLog("steal", StealState.state, "->", "GoEgg", VarV2291 or "", StealState.target and StealState.target.name or "")
                StealState.state = "GoEgg"
                StealState.since = os.clock()
            else
                StealState.state = "GoEgg"
            end

            RefreshSteal()

            return
        end

        if VarV2287 then
            local VarV2292 = FindPenPad(VarV2287.Position)

            if IsAtOwnPlot(VarV2287.Position) or VarV2292 and PlotScanNests(VarV2292, VarV2287.Position, 18) then
                if StealState.state ~= "Safe" then
                    KozuaLog("steal", StealState.state, "->", "Safe", "pad first", StealState.target and StealState.target.name or "")
                    StealState.state = "Safe"
                    StealState.since = os.clock()
                else
                    StealState.state = "Safe"
                end

                RefreshSteal()

                return
            end
        end

        local VarV2293 = PickCfg or "egg"

        if StealState.state ~= "GoEgg" then
            KozuaLog("steal", StealState.state, "->", "GoEgg", VarV2293 or "", StealState.target and StealState.target.name or "")
            StealState.state = "GoEgg"
            StealState.since = os.clock()
        else
            StealState.state = "GoEgg"
        end

        RefreshSteal()
    end
    local function StealValidateTarget(ValidTarget)
        local pendingCarry = StealState.pendingCarry

        if not pendingCarry then
            return
        end

        StealState.pendingCarry = nil
        n29 = 0
        StealState.stillFor = 0

        local carrying = StealState.carrying

        StealState.carrying = pendingCarry.carrying == true

        if type(pendingCarry.uid) == "string" then
            StealState.carryUid = pendingCarry.uid
        elseif not StealState.carrying then
            StealState.carryUid = nil
        end

        if StealState.carrying then
            StealState.heldUid = pendingCarry.uid or StealState.heldUid
            StealState.lockUid = StealState.heldUid or StealState.lockUid

            if StealState.target then
                StealState.keepHook(StealState.target)
            end

            if StealState.state == "Grab" or StealState.state == "GoEgg" or StealState.state == "Chase" then
                if StealState.target and StealState.target.event then
                    StealState.eventUid = StealState.heldUid or StealState.carryUid
                    StealState.eventFromField = true

                    local eventUid = StealState.eventUid

                    if eventUid then
                        StealState.wearEventEgg(eventUid)
                    end

                    if eventUid and StealState.findEventEggTool(eventUid) then
                        if StealState.state ~= "FeedGo" then
                            KozuaLog("steal", StealState.state, "->", "FeedGo", "got infested", StealState.target and StealState.target.name or "")
                            StealState.feedDropped = false
                            StealState.feedPad = 5
                            StealState.state = "FeedGo"
                            StealState.since = os.clock()
                        else
                            StealState.state = "FeedGo"
                        end

                        RefreshSteal()

                        return
                    end

                    StealState.lookWhy = "pocket infested"
                    RefreshSteal()

                    return
                end

                if StealState.state ~= "Return" then
                    KozuaLog("steal", StealState.state, "->", "Return", "got egg", StealState.target and StealState.target.name or "")
                    StealState.state = "Return"
                    StealState.since = os.clock()
                else
                    StealState.state = "Return"
                end

                RefreshSteal()
            end

            return
        end

        if not carrying or not Config.AutoSteal then
            return
        end

        local VarV2298 = IsAtSpawn(ValidTarget)

        if StealState.state == "Bank" or StealState.state == "Return" and VarV2298 then
            HookDigestCheck("carry-ended-at-safe")

            if StealState.state ~= "Scan" then
                KozuaLog("steal", StealState.state, "->", "Scan", "took", StealState.target and StealState.target.name or "")
                StealState.state = "Scan"
                StealState.since = os.clock()
            else
                StealState.state = "Scan"
            end

            RefreshSteal()
            StealDest = nil

            return
        end

        if StealState.state == "FeedGo" or StealState.state == "Feed" then
            if StealState.findEventEggTool and StealState.findEventEggTool(StealState.eventUid or StealState.heldUid) then
                return
            end

            local VarV2299 = StealState

            VarV2299.lost = VarV2299.lost + 1

            local VarV2300 = StealState

            VarV2300.regrabs = VarV2300.regrabs + 1
            StealState.lockUid = pendingCarry.uid or (StealState.heldUid or StealState.lockUid)
            StealState.lockAt = os.clock()

            if ValidTarget then
                StealState.lockPos = ValidTarget.Position
            end

            if StealState.state ~= "GoEgg" then
                KozuaLog("steal", StealState.state, "->", "GoEgg", "drop at monster", StealState.target and StealState.target.name or "")
                StealState.state = "GoEgg"
                StealState.since = os.clock()
            else
                StealState.state = "GoEgg"
            end

            RefreshSteal()

            return
        end

        if StealState.state == "Return" or StealState.state == "GoEgg" or StealState.state == "Grab" or StealState.state == "Chase" then
            local VarV2301 = StealState

            VarV2301.lost = VarV2301.lost + 1

            local VarV2302 = StealState

            VarV2302.regrabs = VarV2302.regrabs + 1
            StealState.lockUid = pendingCarry.uid or (StealState.heldUid or StealState.lockUid)
            StealState.lockAt = os.clock()

            if ValidTarget then
                StealState.lockPos = ValidTarget.Position
            end

            KozuaLog("steal", "dropped — re-grab", (tostring(StealState.lockUid or "?")))

            if StealState.state ~= "GoEgg" then
                KozuaLog("steal", StealState.state, "->", "GoEgg", "drop", StealState.target and StealState.target.name or "")
                StealState.state = "GoEgg"
                StealState.since = os.clock()
            else
                StealState.state = "GoEgg"
            end

            RefreshSteal()
        end
    end
    local function StealByUid(UidTarget)
        if not UidTarget or not UidTarget.rec then
            return nil, "no-target"
        end
        local Uid = UidTarget.rec.Uid
        if not Uid then
            return nil, "no-uid"
        end
        local VarV2305
        for _, v in ipairs((v1204())) do
            if type(v) == "table" and Uid == v.Uid then
                VarV2305 = v

                break
            end
        end
        if not VarV2305 then
            for _, v in ipairs((v1204(true))) do
                if type(v) == "table" and Uid == v.Uid then
                    VarV2305 = v

                    break
                end
            end
        end
        if not VarV2305 then
            return nil, "gone"
        end
        if PlotIsOwnedPlaced(VarV2305, (PlotBottomPos(VarV2305))) then
            return nil, "plot"
        end
        UidTarget.rec = VarV2305
        UidTarget.carrier = tonumber(VarV2305.CarrierUserId)
        local State = VarV2305.State
        if State == "Slot" or State == "Dropped" then
            local VarV2311 = PlotBottomPos(VarV2305)

            if VarV2311 then
                UidTarget.pos = VarV2311
            end

            UidTarget.carrier = nil

            if not UidTarget.pos then
                return nil, "no-pos"
            end

            return UidTarget
        end
        if State == "Carried" then
            UidTarget.pos = PlotBottomPos(VarV2305) or UidTarget.pos

            return UidTarget, "Carried"
        end

        return nil, (tostring(State or "bad-state"))
    end
    function StealState.promptIsTarget(PromptA, PromptB, PromptC)
        if not PromptA or (not PromptA.Parent or not v1189(PromptA)) then
            return false
        end
        if not PromptB then
            return false
        end
        local VarV2315 = tonumber(PromptC) or 5
        local VarV2316 = PromptB.rec and (PromptB.rec.Uid and tostring(PromptB.rec.Uid))
        if VarV2316 and VarV2316 ~= "" then
            local VarU2317 = PromptA

            for _ = 1, 6 do
                if not VarU2317 then
                    break
                end
                local VarU2319
                pcall(function()
                    for _, v in ipairs({
						"Uid",
						"EggUid",
						"RecordUid",
						"AssetUid",
						"EggId"
					}) do
                        local VarV22 = VarU2317:GetAttribute(v)

                        if VarV22 ~= nil and tostring(VarV22) == VarV2316 then
                            VarU2319 = true

                            return
                        end
                    end

                    local StrId40 = tostring(VarU2317.Name or "")

                    if StrId40 ~= "" and StrId40 ~= "CarryAreaEgg" and StrId40 ~= "SmartPromptPart" and StrId40 == VarV2316 then
                        VarU2319 = true
                    end
                end)
                if VarU2319 then
                    return true
                end
                VarU2317 = VarU2317.Parent
            end
        end
        if typeof(PromptB.pos) ~= "Vector3" then
            return false
        end
        local p447Parent = PromptA.Parent
        local p447ParentPosition
        if p447Parent:IsA("BasePart") then
            p447ParentPosition = p447Parent.Position
        elseif p447Parent:IsA("Model") then
            local Ok87, Ret83 = pcall(function()
                return p447Parent:GetPivot()
            end)

            p447ParentPosition = Ok87 and (not not Ret83 and Ret83.Position) or nil
        elseif p447Parent.Parent and p447Parent.Parent:IsA("BasePart") then
            p447ParentPosition = p447Parent.Parent.Position
        end
        if typeof(p447ParentPosition) ~= "Vector3" then
            return false
        end

        return VarV2315 >= Vector3.new(p447ParentPosition.X - PromptB.pos.X, 0, p447ParentPosition.Z - PromptB.pos.Z).Magnitude
    end
    function StealState.muteHazards(HazFlag)
        StealState.hazardSaved = StealState.hazardSaved or {}

        local function AutoTreadmill_Fn_2325(HazKey)
            if not HazKey or not HazKey:IsA("BasePart") then
                return
            end

            if StealState.hazardSaved[HazKey] == nil then
                StealState.hazardSaved[HazKey] = {
					c = HazKey.CanCollide,
					t = HazKey.CanTouch
				}
            end

            if HazKey.CanCollide ~= false then
                HazKey.CanCollide = false
            end

            if HazKey.CanTouch ~= false then
                HazKey.CanTouch = false
            end
        end

        if HazFlag then
            local Clock38 = os.clock()

            if StealState.hazardOn and Clock38 - (StealState.hazardAt or 0) < 2.4 then
                return
            end

            StealState.hazardOn = true
            StealState.hazardAt = Clock38

            local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
            local VarV2328 = __OBJECTS and __OBJECTS:FindFirstChild("Machines")
            local VarV2329 = VarV2328 and VarV2328:FindFirstChild("FuseMachine")

            if VarV2329 then
                AutoTreadmill_Fn_2325(VarV2329)

                for _, descendant in ipairs(VarV2329:GetDescendants()) do
                    AutoTreadmill_Fn_2325(descendant)
                end
            end

            if VarV2328 then
                for _, descendant in ipairs(VarV2328:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.CanCollide == true then
                        AutoTreadmill_Fn_2325(descendant)
                    end
                end
            end

            return
        end

        StealState.hazardOn = false
        StealState.hazardAt = 0

        for k, _ in pairs(StealState.hazardSaved) do
            if k.Parent then
                local VarV2336 = StealState.hazardSaved[k]

                pcall(function()
                    if type(VarV2336) == "table" then
                        k.CanCollide = VarV2336.c == true
                        k.CanTouch = VarV2336.t == true

                        return
                    end

                    k.CanCollide = VarV2336 == true
                end)
            end
        end

        StealState.hazardSaved = {}
    end
    function StealState.allowTrain()
        if Config.AutoTreadmill ~= true then
            return false
        end

        if Config.AutoSteal == true and StealState.running then
            return false
        end

        if Config.TrainWhenIdle ~= true then
            return false
        end

        return true
    end
    function StealState.muteBelt(BeltFlag)
        StealState.beltSaved = StealState.beltSaved or {}

        local function Steal_Fn_2338(BeltKey)
            if not BeltKey or not BeltKey:IsA("BasePart") then
                return false
            end

            local VarV4542 = string.lower(BeltKey.Name)
            local VarV4543 = BeltKey.Parent and string.lower(BeltKey.Parent.Name) or ""
            local VarU4544 = VarV4542

            pcall(function()
                VarU4544 = string.lower(BeltKey:GetFullName())
            end)

            if VarV4542 == "treadmillbottom" or VarV4542 == "bottom" and (VarV4543:find("treadmill", 1, true) or VarU4544:find("treadmill", 1, true)) then
                return true
            end

            if (VarV4542:find("wear", 1, true) or (VarV4542:find("sensor", 1, true) or (VarV4542:find("trigger", 1, true) or (VarV4542:find("hitbox", 1, true) or (VarV4542:find("activate", 1, true) or (VarV4542:find("detector", 1, true) or VarV4543:find("wear", 1, true))))))) and (VarU4544:find("treadmill", 1, true) or VarU4544:find("belt", 1, true) or VarV4543:find("treadmill", 1, true)) then
                return true
            end

            if BeltKey.CanTouch == true and BeltKey.Size.Y <= 6 and (VarV4542:find("treadmill", 1, true) or VarV4543:find("treadmill", 1, true) or VarU4544:find("clienttreadmill", 1, true)) then
                return true
            end

            return false
        end
        local function AutoSteal_Fn_2339(BeltSaveKey)
            local VarU4546 = StealState.beltSaved[BeltSaveKey]

            if type(VarU4546) ~= "table" then
                VarU4546 = {
					cf = BeltSaveKey.CFrame,
					anchored = BeltSaveKey.Anchored,
					t = BeltSaveKey.CanTouch,
					c = BeltSaveKey.CanCollide
				}
                StealState.beltSaved[BeltSaveKey] = VarU4546
            end

            pcall(function()
                BeltSaveKey.Anchored = true
                BeltSaveKey.CanTouch = false
                BeltSaveKey.CFrame = VarU4546.cf * CFrame.new(0, -80, 0)
            end)
        end

        if BeltFlag then
            StealState.beltSunk = true

            local Clock39 = os.clock()

            if not StealState.beltOn or Clock39 - (StealState.beltAt or 0) >= 2.4 then
                StealState.beltOn = true
                StealState.beltAt = Clock39
                pcall(function()
                    local _, _, VarV4549 = ResolvePlotSpawn()

                    if VarV4549 then
                        for _, descendant in ipairs(VarV4549:GetDescendants()) do
                            if Steal_Fn_2338(descendant) then
                                AutoSteal_Fn_2339(descendant)
                            end
                        end
                    end

                    local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")

                    if __ClientTreadmillRenders then
                        for _, descendant in ipairs(__ClientTreadmillRenders:GetDescendants()) do
                            if Steal_Fn_2338(descendant) then
                                AutoSteal_Fn_2339(descendant)
                            end
                        end
                    end
                end)
            end

            for k in pairs(StealState.beltSaved) do
                if k.Parent then
                    AutoSteal_Fn_2339(k)
                end
            end

            return
        end

        StealState.beltSunk = false
        StealState.beltOn = false
        StealState.beltAt = 0

        for k, v in pairs(StealState.beltSaved) do
            if k.Parent and type(v) == "table" then
                pcall(function()
                    k.CFrame = v.cf
                    k.Anchored = v.anchored == true
                    k.CanTouch = v.t == true
                    k.CanCollide = v.c == true
                end)
            end
        end

        StealState.beltSaved = {}
    end
    function StealState.floorY()
        local VarV2344 = select(1, ResolveSpawnFallback())

        if typeof(VarV2344) == "Vector3" then
            return VarV2344.Y
        end

        return 70
    end
    function StealState.rescueVoid(VoidY, VoidPos)
        if not Config.AutoSteal or not StealState.running then
            return false
        end

        if not VoidY then
            return false
        end

        local VarV2347 = StealState.floorY()

        if VoidY.Position.Y >= VarV2347 - 8 then
            return false
        end

        local Clock40 = os.clock()

        if Clock40 - (StealState.voidAt or 0) < 0.4 then
            return true
        end

        StealState.voidAt = Clock40

        local VarV2349 = select(1, ResolveSpawnFallback())

        pcall(function()
            VoidY.Anchored = false

            if typeof(VarV2349) == "Vector3" and VarV2349.Y >= 58 then
                VoidY.CFrame = CFrame.new(VarV2349.X, VarV2349.Y + 6, VarV2349.Z)
            else
                VoidY.CFrame = CFrame.new(0, 74, 0)
            end

            VoidY.AssemblyLinearVelocity = Vector3.zero
            VoidY.AssemblyAngularVelocity = Vector3.zero

            if VoidPos then
                VoidPos.Sit = false
                VoidPos.PlatformStand = IsFlying() == true
            end
        end)
        StealDest = nil
        KozuaLog("steal", "void rescue")

        return true
    end
    function StealState.resetStuck(StuckA, StuckB)
        local Clock41 = os.clock()

        if Clock41 - (StealState.unstuckAt or 0) < 2.5 then
            return
        end

        StealState.unstuckAt = Clock41
        StealState.stillFor = 0

        local VarV2353 = select(1, ResolveSpawnFallback())
        local VarV2354 = StealState.floorY()
        local VarV2355 = type(VarV2354) == "number" and VarV2354 + 3 or StuckA.Position.Y
        local VarU2356 = StuckA.Position.X + 6
        local VarU2357 = VarV2355
        local PositionZ = StuckA.Position.Z
        local VarV2359 = StealState.target and StealState.target.pos

        if typeof(VarV2359) ~= "Vector3" then
            VarV2359 = StealState.lockPos
        end

        if typeof(VarV2359) == "Vector3" then
            local vector3 = Vector3.new(VarV2359.X - StuckA.Position.X, 0, VarV2359.Z - StuckA.Position.Z)

            if vector3.Magnitude > 8 then
                local Unit = vector3.Unit

                VarU2356 = StuckA.Position.X + Unit.X * 16
                PositionZ = StuckA.Position.Z + Unit.Z * 16
            end
        end

        if StealState.carrying or StuckA.Position.Y < (type(VarV2354) == "number" and VarV2354 - 4 or -1000000000) then
            if typeof(VarV2353) == "Vector3" then
                VarU2356 = VarV2353.X
                VarU2357 = VarV2353.Y + 3
                PositionZ = VarV2353.Z
            else
                VarU2357 = VarV2355
            end
        end

        pcall(function()
            StuckA.Anchored = false
            StuckA.CFrame = CFrame.new(VarU2356, VarU2357, PositionZ)
            StuckA.AssemblyLinearVelocity = Vector3.zero
            StuckA.AssemblyAngularVelocity = Vector3.zero

            if StuckB then
                StuckB.Sit = false
                StuckB.PlatformStand = IsFlying() == true
            end
        end)
        KozuaLog("steal", "unstuck reset", StealState.state or "")
    end
    function StealState.liveCarry()
        local VarV2362 = v1204()

        if type(VarV2362) ~= "table" then
            return false, nil
        end

        for i = 1, #VarV2362 do
            local VarV2364 = VarV2362[i]

            if type(VarV2364) == "table" and tonumber(VarV2364.CarrierUserId) == LocalPlayer.UserId then
                return true, VarV2364.Uid
            end
        end

        return false, nil
    end
    function StealState.adoptCarry()
        local VarV2365, VarV2366 = StealState.liveCarry()

        if VarV2365 then
            StealState.carrying = true

            if VarV2366 then
                StealState.carryUid = VarV2366
                StealState.heldUid = VarV2366
                StealState.lockUid = VarV2366
            end

            local state = StealState.state

            if state == "Return" or state == "Bank" or state == "FeedGo" or state == "Feed" or state == "ChestGo" or state == "ChestOpen" then
                return
            end

            local target = StealState.target

            if target and target.event then
                StealState.eventUid = StealState.heldUid or (StealState.carryUid or StealState.eventUid)
                StealState.eventFromField = true

                local eventUid = StealState.eventUid

                if eventUid and StealState.findEventEggTool(eventUid) then
                    if StealState.state ~= "FeedGo" then
                        KozuaLog("steal", StealState.state, "->", "FeedGo", "got infested", StealState.target and StealState.target.name or "")
                        StealState.feedDropped = false
                        StealState.feedPad = 5
                        StealState.state = "FeedGo"
                        StealState.since = os.clock()
                    else
                        StealState.state = "FeedGo"
                    end

                    RefreshSteal()

                    return
                end

                if StealState.state ~= "Return" then
                    KozuaLog("steal", StealState.state, "->", "Return", "got egg", StealState.target and StealState.target.name or "")
                    StealState.state = "Return"
                    StealState.since = os.clock()
                else
                    StealState.state = "Return"
                end

                RefreshSteal()

                return
            end

            if StealState.state ~= "Return" then
                KozuaLog("steal", StealState.state, "->", "Return", "got egg", StealState.target and StealState.target.name or "")
                StealState.state = "Return"
                StealState.since = os.clock()
            else
                StealState.state = "Return"
            end

            RefreshSteal()

            return
        end

        StealState.carrying = false

        local state = StealState.state

        if state == "Return" or state == "Bank" then
            StealState.lockAt = os.clock()

            if StealState.lockUid and typeof(StealState.lockPos) == "Vector3" then
                if StealState.state ~= "GoEgg" then
                    KozuaLog("steal", StealState.state, "->", "GoEgg", "empty return", StealState.target and StealState.target.name or "")
                    StealState.state = "GoEgg"
                    StealState.since = os.clock()
                else
                    StealState.state = "GoEgg"
                end

                RefreshSteal()

                return
            end

            if StealState.state ~= "Scan" then
                KozuaLog("steal", StealState.state, "->", "Scan", "empty return", StealState.target and StealState.target.name or "")
                StealState.state = "Scan"
                StealState.since = os.clock()
            else
                StealState.state = "Scan"
            end

            RefreshSteal()

            return
        end

        if state == "FeedGo" or state == "Feed" then
            local VarV2371 = StealState.eventUid or StealState.heldUid

            if StealState.findEventEggTool and StealState.findEventEggTool(VarV2371) then
                return
            end

            if StealState.lookWhy == "need infested" or StealState.lookWhy == "equip infested" or StealState.lookWhy == "pocket infested" then
                return
            end

            if StealState.lockUid and typeof(StealState.lockPos) == "Vector3" then
                if StealState.state ~= "GoEgg" then
                    KozuaLog("steal", StealState.state, "->", "GoEgg", "empty monster", StealState.target and StealState.target.name or "")
                    StealState.state = "GoEgg"
                    StealState.since = os.clock()
                else
                    StealState.state = "GoEgg"
                end

                RefreshSteal()

                return
            end

            if StealState.state ~= "Scan" then
                KozuaLog("steal", StealState.state, "->", "Scan", "empty monster", StealState.target and StealState.target.name or "")
                StealState.state = "Scan"
                StealState.since = os.clock()
            else
                StealState.state = "Scan"
            end

            RefreshSteal()
        end
    end
    local function EventKeepCheck(KeepRec)
        if StealState.carrying then
            return
        end

        local Clock42 = os.clock()

        if Clock42 - StealState.lastGrab < 0.03 then
            return
        end

        StealState.lastGrab = Clock42

        local VarV2374 = KeepRec and KeepRec.rec
        local VarV2375 = VarV2374 and VarV2374.Uid

        if VarV2375 then
            StealState.heldUid = VarV2375
            StealState.lockUid = VarV2375
            StealState.lockAt = os.clock()

            if KeepRec then
                StealState.keepHook(KeepRec)
            end

            if typeof(KeepRec.pos) == "Vector3" then
                StealState.lockPos = KeepRec.pos
            end

            if EggState and type(EggState.CarryFieldEgg) == "function" then
                local VarV2376 = VarV2374.FirstAreaSlotKey or (VarV2374.AreaId or VarV2374.SlotKey)

                pcall(EggState.CarryFieldEgg, VarV2375, VarV2376)
            end
        end

        local VarV2377 = v1191()
        local Character20 = LocalPlayer.Character
        local VarV2379

        if not Character20 then
            VarV2379 = nil
        else
            local Humanoid = Character20:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = Character20:FindFirstChild("HumanoidRootPart")

            VarV2379 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
        end

        local VarV2382 = false

        if VarV2379 and typeof(KeepRec.pos) == "Vector3" then
            VarV2382 = Vector3.new(VarV2379.Position.X - KeepRec.pos.X, 0, VarV2379.Position.Z - KeepRec.pos.Z).Magnitude <= 7
        end

        if VarV2382 and StealState.promptIsTarget(VarV2377, KeepRec, 5) then
            v1190(VarV2377)
        end
    end
    function StealState.pickSatchelEvent()
        if not EggState or type(EggState.ReadOwnerEggs) ~= "function" then
            return
        end
        local VarU2383
        pcall(function()
            VarU2383 = EggState.ReadOwnerEggs(LocalPlayer.UserId)
        end)
        if type(VarU2383) ~= "table" then
            return
        end
        local VarV2384 = v1194(Config.EventKeepGen)
        local Tab304
        local VarV2386
        for k, v in pairs(VarU2383) do
            if type(v) == "table" and v.HasParasite == true and v.Placement == nil then
                local VarV2389 = v.Uid or k

                if not StealState.eventSkip or not StealState.eventSkip[VarV2389] then
                    local AssetCategory = v.AssetCategory
                    local VarV2391 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                    local VarV2392 = v1193(v, VarV2391)

                    if not (VarV2384 > 0) or not (VarV2384 <= VarV2392) then
                        if StealState.findEventEggTool(VarV2389) then
                            if not Tab304 or VarV2392 < Tab304.earn then
                                Tab304 = {
									uid = VarV2389,
									earn = VarV2392,
									name = VarV2391 and (VarV2391.DisplayName or v.AssetCategory) or tostring(v.AssetCategory)
								}
                            end
                        else
                            VarV2386 = VarV2386 or VarV2389
                        end
                    end
                end
            end
        end
        if not Tab304 and VarV2386 then
            StealState.wearEventEgg(VarV2386)
        end

        return Tab304
    end
    function StealState.monsterStand()
        local MonsterParasiteMonsters = workspace:FindFirstChild("MonsterParasiteMonsters")
        if not MonsterParasiteMonsters then
            return
        end
        local VarV2394
        for _, child in ipairs(MonsterParasiteMonsters:GetChildren()) do
            if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                VarV2394 = child

                break
            end
        end
        local VarV2397 = VarV2394 or MonsterParasiteMonsters:FindFirstChildWhichIsA("Model")
        if not VarV2397 then
            return
        end
        local VarV2398 = VarV2397:FindFirstChild("RootPart") or VarV2397.PrimaryPart
        if not VarV2398 or not VarV2398:IsA("BasePart") then
            return
        end
        local vector3 = Vector3.new(VarV2398.CFrame.LookVector.X, 0, VarV2398.CFrame.LookVector.Z)
        local VarV2400 = if not (vector3.Magnitude < 0.05) then vector3.Unit else Vector3.new(0, 0, -1)
        local VarV2401 = tonumber(StealState.feedPad) or 5
        if VarV2401 < 1.2 then
            VarV2401 = 1.2
        end
        local VarV2402 = VarV2398.Position + VarV2400 * VarV2401
        local VarV2403 = VarV2398.Position.Y + 2
        if type(IsFlying) ~= "function" or not IsFlying() then
            local VarV2404 = v1147(Vector3.new(VarV2402.X, VarV2398.Position.Y + 8, VarV2402.Z))

            VarV2403 = if type(VarV2404) ~= "number" or not (VarV2404 < VarV2398.Position.Y + 10) then VarV2398.Position.Y + 3 else VarV2404 + 3
        end
        local VarV2405 = VarV2398:FindFirstChild("FeedPrompt") or VarV2397:FindFirstChild("FeedPrompt", true)

        return Vector3.new(VarV2402.X, VarV2403, VarV2402.Z), VarV2397, VarV2405, VarV2398
    end
    function StealState.eventToolUid()
        local Character21 = LocalPlayer.Character
        local VarV2407 = Character21 and Character21:FindFirstChildWhichIsA("Tool")

        if not VarV2407 or VarV2407:GetAttribute("ItemType") ~= "AssetEgg" then
            return
        end

        local VarV2408 = VarV2407:GetAttribute("UID") or VarV2407:GetAttribute("Uid")

        if type(VarV2408) == "string" and VarV2408 ~= "" then
            return VarV2408, VarV2407
        end
    end
    function StealState.findEventEggTool(EvtTool)
        local VarU2410 = type(EvtTool) == "string" and (EvtTool ~= "" and EvtTool) or nil
        local function Steal_Fn_2411(EvtUid)
            if not EvtUid then
                return
            end

            for _, child in ipairs(EvtUid:GetChildren()) do
                if not child:IsA("Tool") or child:GetAttribute("ItemType") ~= "AssetEgg" then
                    continue
                end

                local VarV4558 = child:GetAttribute("UID") or child:GetAttribute("Uid")

                if type(VarV4558) == "string" and VarV4558 ~= "" then
                    if VarU2410 then
                        if VarV4558 ~= VarU2410 then
                            continue
                        end

                        return child, VarV4558
                    end

                    if child:GetAttribute("HasParasite") ~= true then
                        continue
                    end

                    return child, VarV4558
                end
            end
        end
        local VarV2412, VarV2413 = Steal_Fn_2411(LocalPlayer.Character)
        if VarV2412 then
            return VarV2412, VarV2413
        end
        local VarV2414, VarV2415 = Steal_Fn_2411(LocalPlayer:FindFirstChild("Backpack"))
        if VarV2414 then
            return VarV2414, VarV2415
        end
        if VarU2410 then
            return
        end
        local VarU2416
        pcall(function()
            VarU2416 = EggState and EggState.ReadOwnerEggs(LocalPlayer.UserId)
        end)
        if type(VarU2416) ~= "table" then
            return
        end
        local function Steal_Fn_2417(EvtRec)
            if not EvtRec then
                return
            end

            for _, child in ipairs(EvtRec:GetChildren()) do
                if not child:IsA("Tool") or child:GetAttribute("ItemType") ~= "AssetEgg" then
                    continue
                end

                local VarV4562 = child:GetAttribute("UID") or child:GetAttribute("Uid")
                local VarV4563 = type(VarV4562) == "string" and (VarU2416[VarV4562] or VarU2416[tostring(VarV4562)])

                if type(VarV4563) ~= "table" then
                    for k, v in pairs(VarU2416) do
                        if type(v) == "table" and (VarV4562 == v.Uid or k == VarV4562) then
                            VarV4563 = v

                            break
                        end
                    end
                end

                if type(VarV4563) == "table" and VarV4563.HasParasite == true and VarV4563.Placement == nil then
                    return child, VarV4562
                end
            end
        end

        return Steal_Fn_2417(LocalPlayer.Character) or Steal_Fn_2417(LocalPlayer:FindFirstChild("Backpack"))
    end
    function StealState.wearEventEgg(WearUid)
        local StrId41 = tostring(WearUid or "")

        if StrId41 == "" then
            return false
        end

        if StealState.eventToolUid() == StrId41 then
            return true
        end

        local Clock43 = os.clock()

        if Clock43 - (StealState.lastWear or 0) < 0.4 then
            return false
        end

        StealState.lastWear = Clock43

        local VarV2421 = select(1, GetCharParts())

        local function Steal_Fn_2422(MpCat)
            if not MpCat then
                return
            end

            for _, child in ipairs(MpCat:GetChildren()) do
                if child:IsA("Tool") and (child:GetAttribute("UID") or child:GetAttribute("Uid")) == StrId41 then
                    return child
                end
            end
        end

        local VarU2423 = Steal_Fn_2422(LocalPlayer.Character) or Steal_Fn_2422(LocalPlayer:FindFirstChild("Backpack"))

        if VarU2423 and VarU2423:GetAttribute("ItemType") ~= "AssetEgg" then
            VarU2423 = nil
        end

        if VarU2423 and VarV2421 and VarU2423.Parent ~= LocalPlayer.Character then
            pcall(function()
                VarV2421:EquipTool(VarU2423)
            end)
        end

        if EggState and type(EggState.WearEggTool) == "function" then
            pcall(EggState.WearEggTool, StrId41)
        end

        return StealState.eventToolUid() == StrId41
    end
    function StealState.mpInvoke(MpName, ...)
        local VarV2425 = RequireShared({ "Remotes" })
        local VarV2426 = VarV2425 and (VarV2425.MonsterParasite and VarV2425.MonsterParasite[MpName])

        if VarV2426 == nil then
            return false, "no remote"
        end

        local VarV2427 = UnwrapRemote(VarV2426) or (typeof(VarV2426) == "Instance" and VarV2426 or VarV2426)
        local VarV2428 = (type(VarV2427) == "table" or typeof(VarV2427) == "Instance") and VarV2427.InvokeServer

        if type(VarV2428) ~= "function" then
            return false, "no invoke"
        end

        local Ok88, Ret84

        if select("#", ...) <= 0 then
            Ok88, Ret84 = pcall(VarV2428, VarV2427)
        else
            Ok88, Ret84 = pcall(VarV2428, VarV2427, (...))
        end

        if not Ok88 then
            return false, (tostring(Ret84))
        end

        if type(Ret84) == "table" then
            return Ret84.Success == true, tostring(Ret84.Message or ""), Ret84
        end

        return Ret84 == true, tostring(Ret84), Ret84
    end
    function StealState.feedWaitMsg(FeedA, FeedB)
        local VarV2433 = string.lower((tostring(FeedA or "")))

        if type(FeedB) == "table" then
            VarV2433 ..= " " .. string.lower((tostring(FeedB.Message or "")))
        end

        return VarV2433:find("wait", 1, true) ~= nil or VarV2433:find("cooldown", 1, true) ~= nil
    end
    function StealState.askFeed(FeedReq)
        if type(FeedReq) ~= "string" or FeedReq == "" then
            return false, "no egg"
        end

        if FeedReq ~= StealState.eventToolUid() then
            StealState.wearEventEgg(FeedReq)
        end

        if FeedReq ~= StealState.eventToolUid() then
            return false, "no egg"
        end

        local VarV2435, VarV2436, VarV2437 = StealState.mpInvoke("AskFeed")

        StealState.lastFeedRes = VarV2437

        return VarV2435, VarV2436, VarV2437
    end
    function StealState.isChestTool(ChestTool)
        if not ChestTool or not ChestTool:IsA("Tool") then
            return false
        end

        if ChestTool:GetAttribute("ItemType") == "MonsterChest" then
            return true
        end

        return ChestTool.Name == "Monster Chest"
    end
    function StealState.findChestTool()
        local function Steal_Fn_2439(ChestRec)
            if not ChestRec then
                return
            end

            for _, child in ipairs(ChestRec:GetChildren()) do
                if StealState.isChestTool(child) then
                    return child
                end
            end
        end

        return Steal_Fn_2439(LocalPlayer.Character) or Steal_Fn_2439(LocalPlayer:FindFirstChild("Backpack"))
    end
    function StealState.worldChest()
        for _, child in ipairs(workspace:GetChildren()) do
            if child.Name ~= "MonsterChest" or not child:IsA("Model") then
                continue
            end

            local VarV2442, VarV2443, VarV2444

            if not child or not child.Parent then
                VarV2442 = nil
                VarV2443 = nil
                VarV2444 = nil
            else
                local VarV2445 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)

                VarV2444 = child:FindFirstChild("ChestPrompt", true)

                if VarV2445 then
                    VarV2442 = VarV2445.Position
                    VarV2443 = child
                else
                    VarV2442 = nil
                    VarV2443 = nil
                    VarV2444 = nil
                end
            end

            if VarV2442 then
                return VarV2442, VarV2443, VarV2444
            end
        end

        local MonsterParasiteMonsters = workspace:FindFirstChild("MonsterParasiteMonsters")

        if MonsterParasiteMonsters then
            for _, child in ipairs(MonsterParasiteMonsters:GetChildren()) do
                if child.Name ~= "MonsterChest" then
                    continue
                end

                local VarV2449, VarV2450, VarV2451

                if not child or not child.Parent then
                    VarV2449 = nil
                    VarV2450 = nil
                    VarV2451 = nil
                else
                    local VarV2452 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)

                    VarV2451 = child:FindFirstChild("ChestPrompt", true)

                    if VarV2452 then
                        VarV2449 = VarV2452.Position
                        VarV2450 = child
                    else
                        VarV2449 = nil
                        VarV2450 = nil
                        VarV2451 = nil
                    end
                end

                if VarV2449 then
                    return VarV2449, VarV2450, VarV2451
                end
            end
        end
    end
    function StealState.equipChest()
        local VarV2453 = StealState.findChestTool()

        if not VarV2453 then
            return false
        end

        if VarV2453.Parent == LocalPlayer.Character then
            return true
        end

        local VarV2454 = select(1, GetCharParts())

        if VarV2454 then
            pcall(function()
                VarV2454:EquipTool(VarV2453)
            end)
        end

        return StealState.findChestTool() and StealState.findChestTool().Parent == LocalPlayer.Character
    end
    function StealState.noChestMsg(ChestA, ChestB)
        local VarV2457 = string.lower((tostring(ChestA or "")))

        if type(ChestB) == "table" then
            VarV2457 ..= " " .. string.lower((tostring(ChestB.Message or "")))
        end

        return VarV2457:find("chest", 1, true) ~= nil and (VarV2457:find("no", 1, true) ~= nil or (VarV2457:find("don't", 1, true) ~= nil or (VarV2457:find("dont", 1, true) ~= nil or (VarV2457:find("any", 1, true) ~= nil or VarV2457:find("have", 1, true) ~= nil)))) or VarV2457:find("no chest", 1, true) ~= nil
    end
    function StealState.openChest()
        local VarV2458 = StealState.findChestTool()

        if not VarV2458 then
            return false, "no chest"
        end

        pcall(function()
            VarV2458:Activate()
        end)

        local guid = HttpService:GenerateGUID(false)
        local VarV2460, VarV2461, VarV2462 = StealState.mpInvoke("AskChestClaim", guid)

        if VarV2460 and type(VarV2462) == "table" and type(VarV2462.OpeningId) == "string" then
            StealState.mpInvoke("AskChestRevealComplete", VarV2462.OpeningId)

            return true, VarV2461
        end

        if VarV2460 then
            return true, VarV2461
        end

        return false, VarV2461
    end
    function StealState.runEvent(EvtPos, EvtElapsed)
        if StealState.state ~= "FeedGo" and (StealState.state ~= "Feed" and StealState.state ~= "ChestGo" and StealState.state ~= "ChestOpen") then
            return false
        end

        StealActive = true

        local VarV2465, _, _, VarV2468 = StealState.monsterStand()
        local VarV2469, _, _ = StealState.worldChest()

        if StealState.state == "ChestGo" or StealState.state == "ChestOpen" then
            local VarV2472 = typeof(VarV2469) == "Vector3" and VarV2469 or VarV2465

            if typeof(VarV2472) == "Vector3" then
                StealDest = PickTravelDest(VarV2472, EvtPos.Position, true)
            end

            if StealState.state == "ChestGo" then
                if StealState.findChestTool() then
                    StealState.chestAsked = false
                    StealState.chestClaimed = false

                    if StealState.state ~= "ChestOpen" then
                        KozuaLog("steal", StealState.state, "->", "ChestOpen", "got chest", StealState.target and StealState.target.name or "")
                        StealState.chestClaimed = false
                        StealState.state = "ChestOpen"
                        StealState.since = os.clock()
                    else
                        StealState.state = "ChestOpen"
                    end

                    RefreshSteal()

                    return true
                end

                if typeof(VarV2469) ~= "Vector3" then
                    if EvtElapsed > 10 then
                        StealState.chestSkip = true

                        if StealState.state ~= "Scan" then
                            KozuaLog("steal", StealState.state, "->", "Scan", "no world chest", StealState.target and StealState.target.name or "")
                            StealState.state = "Scan"
                            StealState.since = os.clock()
                        else
                            StealState.state = "Scan"
                        end

                        RefreshSteal()
                        StealDest = nil
                    end

                    return true
                end

                if not StealState.chestAsked then
                    StealState.chestAsked = true
                    StealState.lastChestTake = os.clock()

                    local VarV2473, VarV2474, VarV2475 = StealState.mpInvoke("AskChestTake")

                    if StealState.findChestTool() then
                        StealState.chestClaimed = false

                        if StealState.state ~= "ChestOpen" then
                            KozuaLog("steal", StealState.state, "->", "ChestOpen", "got chest", StealState.target and StealState.target.name or "")
                            StealState.chestClaimed = false
                            StealState.state = "ChestOpen"
                            StealState.since = os.clock()
                        else
                            StealState.state = "ChestOpen"
                        end

                        RefreshSteal()

                        return true
                    end

                    if not VarV2473 or StealState.noChestMsg(VarV2474, VarV2475) then
                        StealState.chestSkip = true
                        KozuaLog("steal", "no chest", (tostring(VarV2474)))

                        if StealState.state ~= "Scan" then
                            KozuaLog("steal", StealState.state, "->", "Scan", "no chest", StealState.target and StealState.target.name or "")
                            StealState.state = "Scan"
                            StealState.since = os.clock()
                        else
                            StealState.state = "Scan"
                        end

                        RefreshSteal()
                        StealDest = nil

                        return true
                    end
                end

                if EvtElapsed > 12 then
                    StealState.chestSkip = true

                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", "chest pickup timeout", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()
                    StealDest = nil
                end

                return true
            end

            if not StealState.findChestTool() then
                StealState.chestSkip = true

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "no chest", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
                StealDest = nil

                return true
            end

            StealState.equipChest()

            if not StealState.chestClaimed then
                StealState.chestClaimed = true

                local VarV2476, VarV2477 = StealState.openChest()

                if VarV2476 then
                    StealState.chests = (StealState.chests or 0) + 1
                    StealState.chestSkip = false
                    KozuaLog("steal", "opened monster chest", VarV2477 or "")
                    StealState.eventUid = nil

                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", "chest opened", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()
                    StealDest = nil

                    return true
                end

                StealState.chestSkip = true
                KozuaLog("steal", "chest open fail", (tostring(VarV2477)))

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "chest open fail", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
                StealDest = nil

                return true
            end

            if EvtElapsed > 8 then
                StealState.chestSkip = true

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "chest open timeout", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
                StealDest = nil
            end

            return true
        end

        if typeof(VarV2465) ~= "Vector3" then
            StealState.lookWhy = "no monster"

            if StealState.state ~= "Scan" then
                KozuaLog("steal", StealState.state, "->", "Scan", "no monster", StealState.target and StealState.target.name or "")
                StealState.state = "Scan"
                StealState.since = os.clock()
            else
                StealState.state = "Scan"
            end

            RefreshSteal()
            StealDest = nil

            return true
        end

        local VarV2478 = StealState.eventUid or (StealState.heldUid or StealState.carryUid)
        local VarV2479, VarV2480 = StealState.findEventEggTool(VarV2478)

        if VarV2480 then
            VarV2478 = VarV2480
            StealState.eventUid = VarV2480
        end

        if StealState.state == "FeedGo" then
            local VarV2481 = VarV2468 and (not not VarV2468:IsA("BasePart") and VarV2468.Position) or VarV2465
            local vector3 = Vector3.new(EvtPos.Position.X - VarV2481.X, 0, EvtPos.Position.Z - VarV2481.Z)

            if not VarV2479 then
                if VarV2478 then
                    StealState.wearEventEgg(VarV2478)
                end

                StealState.lookWhy = "need infested"
                StealDest = PickTravelDest(VarV2465, EvtPos.Position, true)

                if EvtElapsed > 10 then
                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", "no infested tool", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()
                    StealDest = nil
                else
                    RefreshSteal()
                end

                return true
            end

            if VarV2478 ~= StealState.eventToolUid() then
                StealState.wearEventEgg(VarV2478)
            end

            StealDest = PickTravelDest(VarV2465, EvtPos.Position, true)

            if vector3.Magnitude < 8 then
                if VarV2478 == StealState.eventToolUid() then
                    if StealState.state ~= "Feed" then
                        KozuaLog("steal", StealState.state, "->", "Feed", "at monster", StealState.target and StealState.target.name or "")
                        StealState.state = "Feed"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Feed"
                    end

                    RefreshSteal()
                else
                    StealState.lookWhy = "equip infested"
                    StealState.wearEventEgg(VarV2478)
                    RefreshSteal()
                end
            elseif EvtElapsed > 36 then
                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "monster timeout", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
                StealDest = nil
            end

            return true
        end

        if not VarV2479 or VarV2478 ~= StealState.eventToolUid() then
            if VarV2478 then
                StealState.wearEventEgg(VarV2478)
            end

            StealState.lookWhy = "equip infested"

            if EvtElapsed > 8 then
                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "no infested tool", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
                StealDest = nil
            else
                RefreshSteal()
            end

            return true
        end

        StealDest = PickTravelDest(VarV2465, EvtPos.Position, true)

        local VarV2483 = VarV2468 and (not not VarV2468:IsA("BasePart") and VarV2468.Position) or VarV2465

        if Vector3.new(EvtPos.Position.X - VarV2483.X, 0, EvtPos.Position.Z - VarV2483.Z).Magnitude > 7 then
            StealState.lookWhy = "getting closer"
            RefreshSteal()

            return true
        end

        local Clock44 = os.clock()

        if Clock44 < (StealState.feedLockUntil or 0) then
            StealState.lookWhy = "feed wait"
            RefreshSteal()

            return true
        end

        if Clock44 - (StealState.lastFeed or 0) >= 1.6 then
            StealState.lastFeed = Clock44
            StealState.feedLockUntil = Clock44 + 1.6

            local VarV2485, VarV2486, VarV2487 = StealState.askFeed(VarV2478)

            if VarV2485 then
                local VarV2488 = StealState

                VarV2488.fed = VarV2488.fed + 1
                StealState.feedWasWait = false
                StealState.feedLockUntil = Clock44 + 2.2

                if StealState.eventFromField then
                    HookDigestCheck("fed monster")
                end

                StealState.eventUid = nil
                StealState.eventFromField = false
                StealState.target = nil
                StealState.lockUid = nil

                local VarV2489 = type(VarV2487) == "table" and tonumber(VarV2487.Charge) or 0
                local VarV2490 = type(VarV2487) == "table" and tonumber(VarV2487.PendingChests) or 0

                KozuaLog("steal", "fed monster", VarV2486 or "", "charge", VarV2489, "pending", VarV2490)

                if StealState.findChestTool() then
                    if StealState.state ~= "ChestOpen" then
                        KozuaLog("steal", StealState.state, "->", "ChestOpen", "got chest", StealState.target and StealState.target.name or "")
                        StealState.chestClaimed = false
                        StealState.state = "ChestOpen"
                        StealState.since = os.clock()
                    else
                        StealState.state = "ChestOpen"
                    end

                    RefreshSteal()
                elseif StealState.worldChest() then
                    if StealState.state ~= "ChestGo" then
                        KozuaLog("steal", StealState.state, "->", "ChestGo", "chest", StealState.target and StealState.target.name or "")
                        StealState.chestAsked = false
                        StealState.state = "ChestGo"
                        StealState.since = os.clock()
                    else
                        StealState.state = "ChestGo"
                    end

                    RefreshSteal()
                else
                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", "fed", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()
                    StealDest = nil
                end

                return true
            end

            StealState.feedWasWait = StealState.feedWaitMsg(VarV2486, VarV2487)

            if StealState.feedWasWait then
                StealState.feedLockUntil = Clock44 + 2.8
                StealState.lookWhy = "feed wait"
                KozuaLog("steal", "feed cooldown", (tostring(VarV2486)))
            else
                StealState.feedLockUntil = Clock44 + 1.6
                KozuaLog("steal", "feed fail", (tostring(VarV2486)))

                if type(VarV2486) == "string" and string.find(string.lower(VarV2486), "closer", 1, true) then
                    StealState.feedPad = math.max(1.4, (tonumber(StealState.feedPad) or 5) - 1.6)
                end
            end
        end

        if EvtElapsed > 28 then
            if VarV2478 and not StealState.feedWasWait then
                StealState.eventSkip[VarV2478] = true
            end

            local VarV2491 = not StealState.feedWasWait and "feed timeout" or "feed wait"

            if StealState.state ~= "Scan" then
                KozuaLog("steal", StealState.state, "->", "Scan", VarV2491 or "", StealState.target and StealState.target.name or "")
                StealState.state = "Scan"
                StealState.since = os.clock()
            else
                StealState.state = "Scan"
            end

            RefreshSteal()
            StealDest = nil
        end

        return true
    end
    function StealTick(TickDt)
        if not IsAlive or not Config.AutoSteal then
            return
        end

        local VarV2493 = tonumber(TickDt) or (n7 or 0.016)

        v1158("tick")
        StealState.muteHazards(true)

        if StealState.muteBelt then
            StealState.muteBelt(StealState.allowTrain() ~= true)
        end

        local VarV2494 = EggCycleCountdown()
        local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

        if type(AreaEggCycleNightSeconds) ~= "number" then
            AreaEggCycleNightSeconds = 10
        end

        local VarV2496 = VarV2494 <= math.clamp(AreaEggCycleNightSeconds, 1, 300)

        if VarV2496 then
            local VarV2497 = StealState.state == "Return" or (StealState.state == "Bank" or (StealState.state == "FeedGo" or (StealState.state == "Feed" or (StealState.state == "ChestGo" or StealState.state == "ChestOpen"))))
            local VarV2498 = StealState.state == "Safe"

            if not VarV2497 and not VarV2498 then
                StealDest = nil
                StealActive = false
                StealState.target = nil

                if StealState.state ~= "Night" then
                    if StealState.state ~= "Night" then
                        KozuaLog("steal", StealState.state, "->", "Night", "paused until day", StealState.target and StealState.target.name or "")
                        StealState.state = "Night"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Night"
                    end

                    RefreshSteal()

                    return
                end

                local Ok89, Ret85 = pcall(EggCycleCountdown)
                local VarV2501 = (not Ok89 or type(Ret85) ~= "number") and 0 or math.max(0, math.floor(Ret85 + 0.5))

                if VarV2501 ~= StealState.nightLeft then
                    StealState.nightLeft = VarV2501
                    RefreshSteal()
                end

                return
            end
        elseif StealState.state == "Night" then
            if StealState.state ~= "Scan" then
                KozuaLog("steal", StealState.state, "->", "Scan", "day", StealState.target and StealState.target.name or "")
                StealState.state = "Scan"
                StealState.since = os.clock()
            else
                StealState.state = "Scan"
            end

            RefreshSteal()
        end

        local Character22 = LocalPlayer.Character
        local VarV2503, VarV2504

        if not Character22 then
            VarV2503 = nil
            VarV2504 = nil
        else
            VarV2503 = Character22:FindFirstChildOfClass("Humanoid")
            VarV2504 = Character22:FindFirstChild("HumanoidRootPart")

            if not VarV2503 or not VarV2504 or VarV2503.Health <= 0 then
                VarV2503 = nil
                VarV2504 = nil
            end
        end

        local VarV2505 = VarV2503

        StealValidateTarget(VarV2504)
        StealState.adoptCarry()

        if not VarV2504 then
            StealDest = nil

            return
        end

        if StealState.rescueVoid(VarV2504, VarV2505) then
            return
        end

        if StealState.state == "Safe" then
            StealActive = true
            pcall(v1158, "safe")
            pcall(EnsureFlight)

            if StealState.target and VarV2504 and (IsAtSpawn(VarV2504) or not IsAtOwnPlot(VarV2504.Position)) then
                local VarV2506 = FindPenPad(VarV2504.Position)

                if IsAtSpawn(VarV2504) or not VarV2506 or not PlotScanNests(VarV2506, VarV2504.Position, 18) then
                    if StealState.state ~= "GoEgg" then
                        KozuaLog("steal", StealState.state, "->", "GoEgg", "skip pad", StealState.target and StealState.target.name or "")
                        StealState.state = "GoEgg"
                        StealState.since = os.clock()
                    else
                        StealState.state = "GoEgg"
                    end

                    RefreshSteal()

                    return
                end
            end

            local VarV2507, VarV2508 = IsInSafeZone(VarV2504.Position)

            if typeof(VarV2508) ~= "Vector3" then
                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "no safe zone", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            StealDest = VarV2507

            if Vector3.new(VarV2504.Position.X - VarV2508.X, 0, VarV2504.Position.Z - VarV2508.Z).Magnitude < 16 then
                if VarV2496 then
                    if StealState.state ~= "Night" then
                        KozuaLog("steal", StealState.state, "->", "Night", "at safe zone", StealState.target and StealState.target.name or "")
                        StealState.state = "Night"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Night"
                    end

                    RefreshSteal()

                    return
                end

                if StealState.target then
                    if StealState.state ~= "GoEgg" then
                        KozuaLog("steal", StealState.state, "->", "GoEgg", "from pad", StealState.target and StealState.target.name or "")
                        StealState.state = "GoEgg"
                        StealState.since = os.clock()
                    else
                        StealState.state = "GoEgg"
                    end

                    RefreshSteal()

                    return
                end

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "at safe zone", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            if os.clock() - StealState.since > 14 then
                if StealState.target then
                    if StealState.state ~= "GoEgg" then
                        KozuaLog("steal", StealState.state, "->", "GoEgg", "safe timeout", StealState.target and StealState.target.name or "")
                        StealState.state = "GoEgg"
                        StealState.since = os.clock()
                    else
                        StealState.state = "GoEgg"
                    end

                    RefreshSteal()

                    return
                end

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "safe timeout", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
            end

            return
        end

        if StealDest then
            local Position6 = VarV2504.Position

            if StealState.lastPos and (Position6 - StealState.lastPos).Magnitude < 1.2 then
                local VarV2510 = StealState

                VarV2510.stillFor = VarV2510.stillFor + VarV2493
            else
                StealState.stillFor = 0
            end

            StealState.lastPos = Position6

            if StealState.stillFor > 0.85 then
                v1158("stuck")
                pcall(EnsureFlight)

                if not IsFlying() then
                    pcall(function()
                        VarV2505.Jump = true
                        VarV2505.AutoJumpEnabled = true
                    end)
                end
            end

            if StealState.stillFor > 2.6 then
                local state = StealState.state

                if state ~= "Feed" and state ~= "FeedGo" and state ~= "ChestGo" and state ~= "ChestOpen" then
                    StealState.resetStuck(VarV2504, VarV2505)
                else
                    StealState.stillFor = 0
                end

                if StealState.state == "GoEgg" and not StealState.carrying and not StealState.lockUid then
                    KozuaLog("steal", "stuck, rescan")
                    StealState.target = nil

                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", "stuck", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()

                    return
                end
            end
        else
            StealState.stillFor = 0
            StealState.lastPos = VarV2504.Position
        end

        if StealDest and not EngineOn then
            local vector3 = Vector3.new(StealDest.X - VarV2504.Position.X, 0, StealDest.Z - VarV2504.Position.Z)

            pcall(function()
                VarV2505.PlatformStand = false
                VarV2505.Sit = false
                VarV2505.AutoRotate = true

                if StealActive and typeof(StealDest) == "Vector3" then
                    local VarV4575 = tonumber(Config.StealSpeed) or 16

                    VarV2505.WalkSpeed = math.clamp(VarV4575, 16, 1300)
                else
                    VarV2505.WalkSpeed = n9
                end

                if vector3.Magnitude > 1.2 then
                    VarV2505:Move(vector3.Unit, false)

                    return
                end

                VarV2505:Move(Vector3.zero, false)
            end)
        end

        local Clock45 = os.clock()
        local VarV2514 = Clock45 - StealState.since

        if StealState.runEvent(VarV2504, VarV2514) then
            return
        end

        if not StealState.carrying then
            local VarV2515 = StealState.eggResetAt or 0
            local VarV2516 = false

            if VarV2515 > 0 then
                local VarV2517 = Clock45 - VarV2515

                VarV2516 = VarV2517 < 3.25 or (StealState.eggResetGrew or 0) > 0 and (Clock45 - StealState.eggResetGrew < 0.55 and VarV2517 < 5)

                if not VarV2516 then
                    StealState.eggResetAt = 0
                end
            end

            local VarV2518 = StealState.wallUp()

            if (VarV2516 or VarV2518) and not StealState.heldUid then
                local state = StealState.state

                if state == "Idle" or state == "Scan" or state == "GoEgg" or state == "Grab" or state == "Chase" then
                    StealState.target = nil
                    StealState.lockUid = nil
                    StealState.lockPos = nil
                    StealDest = nil
                    StealActive = false

                    local VarV2520 = not VarV2516 and "waiting barrier" or "eggs refreshing"

                    StealState.lookWhy = VarV2520

                    if state ~= "Scan" then
                        if StealState.state ~= "Scan" then
                            KozuaLog("steal", StealState.state, "->", "Scan", VarV2520 or "", StealState.target and StealState.target.name or "")
                            StealState.state = "Scan"
                            StealState.since = os.clock()
                        else
                            StealState.state = "Scan"
                        end

                        RefreshSteal()

                        return
                    end

                    RefreshSteal()

                    return
                end
            end
        end

        if StealState.state == "Idle" or StealState.state == "Scan" then
            if Config.AutoEvent and not StealState.chestSkip then
                if StealState.findChestTool() then
                    StealActive = true

                    if StealState.state ~= "ChestOpen" then
                        KozuaLog("steal", StealState.state, "->", "ChestOpen", "chest in bag", StealState.target and StealState.target.name or "")
                        StealState.chestClaimed = false
                        StealState.state = "ChestOpen"
                        StealState.since = os.clock()
                    else
                        StealState.state = "ChestOpen"
                    end

                    RefreshSteal()

                    return
                end

                if StealState.worldChest() then
                    StealActive = true

                    if StealState.state ~= "ChestGo" then
                        KozuaLog("steal", StealState.state, "->", "ChestGo", "world chest", StealState.target and StealState.target.name or "")
                        StealState.chestAsked = false
                        StealState.state = "ChestGo"
                        StealState.since = os.clock()
                    else
                        StealState.state = "ChestGo"
                    end

                    RefreshSteal()

                    return
                end
            end

            local VarV2521 = CollectStealTargets()

            if VarV2521 and VarV2521.matched then
                StealActive = true
                StealPickTarget(VarV2521, VarV2521.area or "egg")

                return
            end

            local VarV2522 = os.clock() >= (StealState.feedLockUntil or 0)

            if Config.AutoEvent then
                local VarV2523 = VarV2522 and StealState.pickSatchelEvent()

                if VarV2523 then
                    StealState.eventUid = VarV2523.uid
                    StealState.eventFromField = false
                    StealActive = true

                    if StealState.state ~= "FeedGo" then
                        KozuaLog("steal", StealState.state, "->", "FeedGo", "satchel infested", StealState.target and StealState.target.name or "")
                        StealState.feedDropped = false
                        StealState.feedPad = 5
                        StealState.state = "FeedGo"
                        StealState.since = os.clock()
                    else
                        StealState.state = "FeedGo"
                    end

                    RefreshSteal()

                    return
                end

                if VarV2522 and VarV2521 and VarV2521.event then
                    StealActive = true
                    StealPickTarget(VarV2521, "event")

                    return
                end
            elseif VarV2521 and VarV2521.matched then
                StealActive = true
                StealPickTarget(VarV2521, VarV2521.area)

                return
            end

            StealState.target = nil
            StealState.lockUid = nil
            StealState.lockPos = nil

            if not FarmSync or not FarmSync.driving or not FarmSync.driving() then
                StealActive = false
                StealDest = nil
            end

            local VarV2524 = v1204()
            local VarV2525 = type(VarV2524) == "table" and #VarV2524 or 0
            local Num65 = 0
            local Num66 = 0

            if type(VarV2524) == "table" then
                for i = 1, VarV2525 do
                    local VarV2529 = VarV2524[i]

                    if type(VarV2529) == "table" then
                        local State = VarV2529.State
                        local num = tonumber(VarV2529.CarrierUserId)

                        if (State == "Slot" or State == "Dropped") and ((not num or num == 0 or num == LocalPlayer.UserId) and not PlotIsOwnedPlaced(VarV2529)) then
                            Num65 += 1

                            local AssetCategory = VarV2529.AssetCategory
                            local VarV2533 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil

                            if PlotPassesFilter(VarV2529, VarV2533) then
                                local VarV2535

                                if (Config.StealMode or "Best value") == "Gen ($/s) snipe" then
                                    local VarV2534 = v1194(Config.GenSnipeFloor)

                                    VarV2535 = not (VarV2534 > 0) or not (VarV2534 > v1193(VarV2529, VarV2533))
                                else
                                    VarV2535 = true
                                end

                                if VarV2535 then
                                    Num66 += 1
                                end
                            end
                        end
                    end
                end
            end

            if not VarV2522 and Config.AutoEvent then
                StealState.lookWhy = "feed wait"
            elseif VarV2525 == 0 then
                StealState.lookWhy = "map empty"
            elseif Num65 == 0 then
                StealState.lookWhy = "nests empty"
            elseif Num66 == 0 then
                StealState.lookWhy = "no match"
            else
                StealState.lookWhy = tostring(Num66) .. " open"
            end

            if StealState.state ~= "Scan" then
                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "no target", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            RefreshSteal()

            return
        end

        if StealState.state == "GoEgg" then
            local target = StealState.target

            if not target then
                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "lost target", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            pcall(v1158, "goegg")
            pcall(EnsureFlight)

            local VarV2537, VarV2538 = StealByUid(target)

            if VarV2538 == "plot" then
                StealState.target = nil
                StealState.lockUid = nil
                StealState.lockPos = nil

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "plot egg", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            if VarV2538 == "Carried" then
                if tonumber(target.carrier or target.rec and target.rec.CarrierUserId) == LocalPlayer.UserId then
                    StealState.carrying = true
                    StealState.carryUid = target.rec and target.rec.Uid or StealState.carryUid
                    StealState.heldUid = StealState.carryUid or StealState.heldUid
                    StealState.adoptCarry()

                    return
                end

                if Config.BatAura then
                    if StealState.state ~= "Chase" then
                        KozuaLog("steal", StealState.state, "->", "Chase", "player has it", StealState.target and StealState.target.name or "")
                        StealState.state = "Chase"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Chase"
                    end

                    RefreshSteal()

                    return
                end

                if VarV2514 > 3 then
                    StealState.lockUid = nil
                    StealState.lockPos = nil
                    StealState.target = nil

                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", "taken", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()
                end

                return
            end

            if VarV2537 then
                if typeof(target.pos) == "Vector3" then
                    StealState.lockPos = target.pos
                end

                local pos = target.pos
                local _ = VarV2504.Position
                local VarV2541 = if typeof(pos) == "Vector3" then if not IsFlying() then Vector3.new(pos.X, pos.Y - 2.5, pos.Z) else Vector3.new(pos.X, pos.Y + 1.5, pos.Z) else pos

                StealDest = PickTravelDest(VarV2541, VarV2504.Position, true)
                StealActive = true

                if typeof(StealDest) == "Vector3" and typeof(VarV2541) == "Vector3" then
                    local Magnitude = Vector3.new(StealDest.X - VarV2504.Position.X, 0, StealDest.Z - VarV2504.Position.Z).Magnitude
                    local Magnitude2 = Vector3.new(VarV2541.X - VarV2504.Position.X, 0, VarV2541.Z - VarV2504.Position.Z).Magnitude

                    if Magnitude < 8 and Magnitude2 > 20 then
                        StealDest = VarV2541
                    end
                end

                local Magnitude = Vector3.new(VarV2504.Position.X - VarV2541.X, 0, VarV2504.Position.Z - VarV2541.Z).Magnitude
                local VarV2545 = VarV2504.Position.Y - VarV2541.Y

                if not IsFlying() and Magnitude <= 16 then
                    StealDest = VarV2541
                end

                local VarV2546 = not (target.rec and target.rec.State == "Dropped") and 10 or 16

                if IsFlying() then
                    if Magnitude <= VarV2546 and VarV2545 < 18 then
                        EventKeepCheck(target)
                    end

                    if Magnitude <= 5 and VarV2545 < 10 then
                        local VarV2547 = "in range " .. math.floor(Magnitude)

                        if StealState.state ~= "Grab" then
                            KozuaLog("steal", StealState.state, "->", "Grab", VarV2547 or "", StealState.target and StealState.target.name or "")
                            StealState.state = "Grab"
                            StealState.since = os.clock()
                        else
                            StealState.state = "Grab"
                        end

                        RefreshSteal()

                        return
                    end
                else
                    local Magnitude3 = (VarV2504.Position - VarV2541).Magnitude

                    if Magnitude3 <= VarV2546 then
                        EventKeepCheck(target)
                    end

                    if Magnitude3 <= 4 then
                        local VarV2549 = "in range " .. math.floor(Magnitude3)

                        if StealState.state ~= "Grab" then
                            KozuaLog("steal", StealState.state, "->", "Grab", VarV2549 or "", StealState.target and StealState.target.name or "")
                            StealState.state = "Grab"
                            StealState.since = os.clock()
                        else
                            StealState.state = "Grab"
                        end

                        RefreshSteal()

                        return
                    end
                end
            else
                n29 = 0
                StealDest = nil
                StealActive = false

                if VarV2514 > 2.5 then
                    KozuaLog("steal", "egg gone", VarV2538 or "")
                    StealState.lockUid = nil
                    StealState.lockPos = nil
                    StealState.target = nil

                    local VarV2550 = VarV2538 or "egg gone"

                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", VarV2550 or "", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()

                    return
                end
            end

            if VarV2514 > (not StealState.lockUid and 18 or 45) then
                KozuaLog("steal", "GoEgg timeout, rescan")
                n29 = 0

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "timeout", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
            end

            return
        end

        if StealState.state == "Grab" then
            local target = StealState.target

            if not target then
                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "no target", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            pcall(v1158, "grab")
            pcall(EnsureFlight)

            local VarV2552, VarV2553 = StealByUid(target)

            if VarV2553 == "Carried" then
                if tonumber(target.carrier or target.rec and target.rec.CarrierUserId) == LocalPlayer.UserId then
                    StealState.carrying = true
                    StealState.carryUid = target.rec and target.rec.Uid or StealState.carryUid
                    StealState.heldUid = StealState.carryUid or StealState.heldUid
                    StealState.adoptCarry()

                    return
                end

                if Config.BatAura then
                    if StealState.state ~= "Chase" then
                        KozuaLog("steal", StealState.state, "->", "Chase", "player has it", StealState.target and StealState.target.name or "")
                        StealState.state = "Chase"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Chase"
                    end

                    RefreshSteal()

                    return
                end

                if VarV2514 > 3 then
                    StealState.lockUid = nil
                    StealState.lockPos = nil
                    StealState.target = nil

                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", "taken", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()
                end

                return
            end

            if VarV2552 then
                local VarV2554 = PickTravelDest
                local pos = target.pos
                local _ = VarV2504.Position

                StealDest = VarV2554(if typeof(pos) == "Vector3" then if not IsFlying() then Vector3.new(pos.X, pos.Y - 2.5, pos.Z) else Vector3.new(pos.X, pos.Y + 1.5, pos.Z) else pos, VarV2504.Position, true)

                if typeof(target.pos) == "Vector3" then
                    StealState.lockPos = target.pos
                    StealState.lockAt = os.clock()
                end
            else
                StealDest = nil
                StealActive = false

                if VarV2514 > 2.5 then
                    KozuaLog("steal", "grab lost", VarV2553 or "")
                    StealState.lockUid = nil
                    StealState.lockPos = nil
                    StealState.target = nil

                    local VarV2557 = VarV2553 or "grab lost"

                    if StealState.state ~= "Scan" then
                        KozuaLog("steal", StealState.state, "->", "Scan", VarV2557 or "", StealState.target and StealState.target.name or "")
                        StealState.state = "Scan"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Scan"
                    end

                    RefreshSteal()

                    return
                end
            end

            StealActive = true
            EventKeepCheck(target)

            if StealState.carrying then
                StealState.adoptCarry()

                return
            end

            if VarV2514 > (not StealState.lockUid and (not target.rec or target.rec.State ~= "Dropped") and 8 or 30) then
                KozuaLog("steal", "Grab timeout")
                n29 = 0

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "grab timeout", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
            end

            return
        end

        if StealState.state == "Chase" then
            local target = StealState.target
            if not target or not Config.BatAura then
                StealState.target = nil

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "no chase", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end
            local VarV2559, VarV2560 = StealByUid(target)
            if VarV2560 ~= "Carried" then
                if VarV2559 then
                    if StealState.state ~= "GoEgg" then
                        KozuaLog("steal", StealState.state, "->", "GoEgg", "egg loose", StealState.target and StealState.target.name or "")
                        StealState.state = "GoEgg"
                        StealState.since = os.clock()
                    else
                        StealState.state = "GoEgg"
                    end

                    RefreshSteal()

                    return
                end

                StealState.target = nil

                local VarV2561 = VarV2560 or "chase lost"

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", VarV2561 or "", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end
            local VarV2562
            local VarV2563
            if StealState.bat then
                VarV2562, VarV2563 = StealState.bat.posOf(target.carrier)
            end
            if VarV2562 then
                StealDest = VarV2562
                StealActive = true

                if VarV2563 then
                    StealState.bat.swingAt(VarV2563)
                end
            elseif VarV2514 > 4 then
                StealState.target = nil

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "thief gone", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end
            if VarV2514 > 20 then
                StealState.target = nil

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "chase timeout", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()
            end

            return
        end

        if StealState.state == "Return" then
            if not StealState.carrying then
                if StealState.lockUid and typeof(StealState.lockPos) == "Vector3" then
                    if StealState.state ~= "GoEgg" then
                        KozuaLog("steal", StealState.state, "->", "GoEgg", "dropped", StealState.target and StealState.target.name or "")
                        StealState.state = "GoEgg"
                        StealState.since = os.clock()
                    else
                        StealState.state = "GoEgg"
                    end

                    RefreshSteal()

                    return
                end

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "empty hands", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            local _ = VarV2504.Position

            if typeof((select(1, ResolveSpawnFallback()))) ~= "Vector3" then
                KozuaLog("steal", "no safe zone")
                StealDest = nil

                return
            end

            StealDest = select(1, IsInSafeZone(VarV2504.Position))
            StealActive = true

            if IsAtSpawn(VarV2504) then
                if StealState.liveCarry and select(1, StealState.liveCarry()) then
                    if StealState.state ~= "Bank" then
                        KozuaLog("steal", StealState.state, "->", "Bank", "at safe zone", StealState.target and StealState.target.name or "")
                        StealState.state = "Bank"
                        StealState.since = os.clock()
                    else
                        StealState.state = "Bank"
                    end

                    RefreshSteal()

                    return
                end

                StealState.carrying = false

                if StealState.lockUid and typeof(StealState.lockPos) == "Vector3" then
                    if StealState.state ~= "GoEgg" then
                        KozuaLog("steal", StealState.state, "->", "GoEgg", "empty at pad", StealState.target and StealState.target.name or "")
                        StealState.state = "GoEgg"
                        StealState.since = os.clock()
                    else
                        StealState.state = "GoEgg"
                    end

                    RefreshSteal()

                    return
                end

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "empty at pad", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            if VarV2514 > 28 then
                KozuaLog("steal", "Return timeout")

                if StealState.state ~= "GoEgg" then
                    KozuaLog("steal", StealState.state, "->", "GoEgg", "return timeout", StealState.target and StealState.target.name or "")
                    StealState.state = "GoEgg"
                    StealState.since = os.clock()
                else
                    StealState.state = "GoEgg"
                end

                RefreshSteal()
            end

            return
        end

        if StealState.state == "Bank" then
            local _ = VarV2504.Position
            local VarV2566 = select(1, ResolveSpawnFallback())

            StealDest = if typeof(VarV2566) == "Vector3" then select(1, IsInSafeZone(VarV2504.Position)) else VarV2566

            local Clock46 = os.clock()

            if Clock46 - StealState.lastBankTry >= 0.45 then
                StealState.lastBankTry = Clock46
            end

            if not StealState.carrying then
                HookDigestCheck("empty-hands-at-safe")

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "took", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            if not StealState.liveCarry or not select(1, StealState.liveCarry()) then
                StealState.carrying = false

                if StealState.lockUid and typeof(StealState.lockPos) == "Vector3" then
                    if StealState.state ~= "GoEgg" then
                        KozuaLog("steal", StealState.state, "->", "GoEgg", "empty bank", StealState.target and StealState.target.name or "")
                        StealState.state = "GoEgg"
                        StealState.since = os.clock()
                    else
                        StealState.state = "GoEgg"
                    end

                    RefreshSteal()

                    return
                end

                if StealState.state ~= "Scan" then
                    KozuaLog("steal", StealState.state, "->", "Scan", "empty bank", StealState.target and StealState.target.name or "")
                    StealState.state = "Scan"
                    StealState.since = os.clock()
                else
                    StealState.state = "Scan"
                end

                RefreshSteal()

                return
            end

            if VarV2514 > 4 then
                KozuaLog("steal", "Bank timeout, still carrying")

                if StealState.state ~= "Return" then
                    KozuaLog("steal", StealState.state, "->", "Return", "bank timeout", StealState.target and StealState.target.name or "")
                    StealState.state = "Return"
                    StealState.since = os.clock()
                else
                    StealState.state = "Return"
                end

                RefreshSteal()
            end

            return
        end
    end
    local function StopSteal()
        StealState.running = false
        StealActive = false
        StealDest = nil
        StealState.target = nil
        StealState.eventUid = nil
        StealState.pendingCarry = nil
        StealState.haltUntil = os.clock() + 2.2
        StealState.muteHazards(false)

        if StealState.muteBelt then
            StealState.muteBelt(false)
        end

        if StealState.state ~= "Idle" then
            KozuaLog("steal", StealState.state, "->", "Idle", "disabled", StealState.target and StealState.target.name or "")
            StealState.state = "Idle"
            StealState.since = os.clock()
        else
            StealState.state = "Idle"
        end

        RefreshSteal()

        if FarmSync and FarmSync.stop then
            pcall(FarmSync.stop)
        end

        local Character23 = LocalPlayer.Character
        local VarV2569, VarV2570

        if not Character23 then
            VarV2569 = nil
            VarV2570 = nil
        else
            VarV2569 = Character23:FindFirstChildOfClass("Humanoid")
            VarV2570 = Character23:FindFirstChild("HumanoidRootPart")

            if not VarV2569 or not VarV2570 or VarV2569.Health <= 0 then
                VarV2569 = nil
                VarV2570 = nil
            end
        end

        local VarV2571 = VarV2570
        local VarV2572 = VarV2569

        pcall(function()
            if VarV2571 then
                VarV2571.AssemblyLinearVelocity = Vector3.zero
                VarV2571.AssemblyAngularVelocity = Vector3.zero
            end

            if VarV2572 then
                VarV2572:Move(Vector3.zero, false)
                VarV2572.Sit = false

                if not Config.Flight then
                    VarV2572.PlatformStand = false
                end
            end
        end)

        if VarV2571 and VarV2571.Position.Y < 58 then
            local VarV2573 = select(1, ResolveSpawnFallback())

            pcall(function()
                if typeof(VarV2573) == "Vector3" and VarV2573.Y >= 58 then
                    VarV2571.CFrame = CFrame.new(VarV2573.X, VarV2573.Y + 6, VarV2573.Z)
                else
                    VarV2571.CFrame = CFrame.new(0, 74, 0)
                end

                VarV2571.AssemblyLinearVelocity = Vector3.zero
            end)
        end

        if not Config.Flight then
            v1144()
            v1146(VarV2572, VarV2571, true)
        end

        EngineRefresh((EngineWantsFlight()))

        if EngineOn then
            if (Config.Flight or Config.BypassSpeed) and true or (Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                FlightEnable()
                FlightDisable()
                FlightSetWrap(true)
            elseif next(MoveWraps) then
                FlightSetWrap(false)
            end
        end

        KozuaLog("steal", "loop stopped")
    end
    if EggState and EggState.CarryChanged and EggState.CarryChanged.Connect then
        v1136(EggState.CarryChanged:Connect(function(Arg476)
            if type(Arg476) ~= "table" then
                return
            end

            local Uid = Arg476.Uid

            StealState.pendingCarry = {
				carrying = Arg476.IsCarrying == true,
				uid = type(Uid) == "string" and Uid or nil
			}
        end))
    end
    local function OnFlagChanged(FlagName, FlagVal)
        local VarV2578 = WidgetRegistry[FlagName]

        if not VarV2578 then
            KozuaLog("wire", "missing widget", FlagName)

            return
        end

        VarV2578.on = FlagVal
    end
    OnFlagChanged("AutoSteal", function(Arg479)
        if Arg479 then
            if StealState.running then
                return
            end

            StealState.running = true
            StealState.stillFor = 0
            StealState.lastPos = nil
            StealState.pendingCarry = nil

            if StealState.state ~= "Scan" then
                KozuaLog("steal", StealState.state, "->", "Scan", "start", StealState.target and StealState.target.name or "")
                StealState.state = "Scan"
                StealState.since = os.clock()
            else
                StealState.state = "Scan"
            end

            RefreshSteal()
            StealActive = false
            StealDest = nil
            EngineRefresh((EngineWantsFlight()))

            if EngineOn then
                if (Config.Flight or Config.BypassSpeed) and true or (not not Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                    FlightEnable()
                    FlightDisable()
                    FlightSetWrap(true)
                elseif next(MoveWraps) then
                    FlightSetWrap(false)
                end
            end

            KozuaLog("steal", "loop started", Config.StealTravel)

            return
        end

        StopSteal()
    end)
    OnFlagChanged("AutoEvent", function()
        RefreshSteal()
    end)
    OnFlagChanged("AntiTrap", function(AntiTrapVal)
        KozuaLog("engine", "anti trap", AntiTrapVal)
        EngineRefresh((EngineWantsFlight()))

        if EngineOn then
            if (Config.Flight or Config.BypassSpeed) and true or (not not Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                FlightEnable()
                FlightDisable()
                FlightSetWrap(true)
            elseif next(MoveWraps) then
                FlightSetWrap(false)
            end
        end

        TrapRefresh()
    end)
    OnFlagChanged("AntiMob", function(AntiMobVal)
        KozuaLog("engine", "anti ragdoll", AntiMobVal)
        EngineRefresh((EngineWantsFlight()))

        if EngineOn then
            if (Config.Flight or Config.BypassSpeed) and true or (not not Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                FlightEnable()
                FlightDisable()
                FlightSetWrap(true)
            elseif next(MoveWraps) then
                FlightSetWrap(false)
            end
        end

        RagdollRefresh()
    end)
    OnFlagChanged("BatAura", function(BatAuraVal)
        KozuaLog("esp", "bat aura", BatAuraVal)

        if StealState.bat and StealState.bat.setLive then
            StealState.bat.setLive(BatAuraVal)
        end
    end)
    OnFlagChanged("BypassSpeed", function()
        if Config.BypassSpeed ~= true then
            local VarV2583 = select(1, GetCharParts())

            pcall(function()
                if VarV2583 then
                    VarV2583.WalkSpeed = n9
                end
            end)
        end

        EngineRefresh((EngineWantsFlight()))

        if not EngineOn then
            return
        end

        if (Config.Flight or Config.BypassSpeed) and true or (not not Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
            FlightEnable()
            FlightDisable()
            FlightSetWrap(true)

            return
        end

        if next(MoveWraps) then
            FlightSetWrap(false)
        end
    end)
    OnFlagChanged("StealTravel", function(Arg483)
        KozuaLog("wire", "travel mode", (tostring(Arg483)))

        if Config.AutoSteal then
            EngineRefresh((EngineWantsFlight()))

            if not EngineOn then
                return
            end

            if (Config.Flight or Config.BypassSpeed) and true or (not not Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                FlightEnable()
                FlightDisable()
                FlightSetWrap(true)

                return
            end

            if next(MoveWraps) then
                FlightSetWrap(false)
            end
        end
    end)
    OnFlagChanged("StealSpeed", function(Arg484)
        KozuaLog("engine", "steal speed", Arg484)
    end)
    OnFlagChanged("StealMode", function(Arg485)
        KozuaLog("steal", "pick", (tostring(Arg485)))

        if ActiveTab then
            FilterTabItems(ActiveTab, SearchBox.Text)
        end
    end)
    OnFlagChanged("BypassCap", function(Arg486)
        KozuaLog("engine", "cap", Arg486)
    end)
    OnFlagChanged("Flight", function(FlightVal)
        warn("flight is " .. tostring(FlightVal))

        if FlightVal then
            v1144()

            local Character24 = LocalPlayer.Character
            local VarV2590

            if not Character24 then
                VarV2590 = nil
            else
                local Humanoid = Character24:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character24:FindFirstChild("HumanoidRootPart")

                VarV2590 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            local VarV2593 = VarV2590

            if VarV2593 then
                pcall(function()
                    local AssemblyLinearVelocity = VarV2593.AssemblyLinearVelocity

                    VarV2593.AssemblyLinearVelocity = Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z)
                    VarV2593.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        else
            local Character25 = LocalPlayer.Character
            local VarV2595, VarV2596

            if not Character25 then
                VarV2595 = nil
                VarV2596 = nil
            else
                VarV2595 = Character25:FindFirstChildOfClass("Humanoid")
                VarV2596 = Character25:FindFirstChild("HumanoidRootPart")

                if not VarV2595 or not VarV2596 or VarV2595.Health <= 0 then
                    VarV2595 = nil
                    VarV2596 = nil
                end
            end

            u1145 = false
            v1146(VarV2595, VarV2596, true)
        end

        EngineRefresh((EngineWantsFlight()))

        if not EngineOn then
            return
        end

        if (Config.Flight or Config.BypassSpeed) and true or (Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
            FlightEnable()
            FlightDisable()
            FlightSetWrap(true)

            return
        end

        if next(MoveWraps) then
            FlightSetWrap(false)
        end
    end)
    OnFlagChanged("FlightSpeed", function(FlightSpeedVal)
        if Config.Flight then
            KozuaLog("engine", "flight speed", FlightSpeedVal)
        end
    end)
    OnFlagChanged("EggESP", function()
        KozuaLog("esp", "field", Config.EggESP)
    end)
    OnFlagChanged("ESPFilter", function(Arg489)
        KozuaLog("esp", "filter", (tostring(Arg489)))
    end)
    OnFlagChanged("ESPBeam", function()
        KozuaLog("esp", "beam", Config.ESPBeam)
    end)
    OnFlagChanged("PlotESP", function()
        KozuaLog("esp", "plot", Config.PlotESP)

        if PanelCtl.bumpPlot then
            PanelCtl.bumpPlot()
        end
    end)
    OnFlagChanged("StatsPanel", function(StatsVal)
        if PanelCtl.stats then
            PanelCtl.stats(StatsVal)
        end

        KozuaLog("esp", "stats panel", StatsVal)
    end)
    OnFlagChanged("ClaimIndex", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("AutoPlaceEggs", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("AutoHatch", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("EquipBest", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("UpgTrails", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("UpgTreadmill", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("UpgPen", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("AutoSellPets", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("AutoSellEggs", function()
        if FarmSync then
            FarmSync.sync()
        end
    end)
    OnFlagChanged("AutoTreadmill", function(Arg491)
        if FarmSync then
            if not Arg491 and FarmSync.leave then
                FarmSync.leave()
            end

            FarmSync.sync()
        end
    end)
    OnFlagChanged("AutoHop", function()
    end)
    OnFlagChanged("HopNow", function()
        if VarU1230 and VarU1230.now then
            VarU1230.now()
        end
    end)
    OnFlagChanged("SellPreview", function()
        if SpareRegistry.open then
            SpareRegistry.open()
        end
    end)
    function SpareRegistry.open()
        Config.StatsPanel = true

        if WidgetRegistry.StatsPanel and WidgetRegistry.StatsPanel.set then
            pcall(WidgetRegistry.StatsPanel.set, true)
        end

        if PanelCtl and PanelCtl.stats then
            pcall(PanelCtl.stats, true)
        end

        if FarmSync and FarmSync.queuePreview then
            local Ok90, Ret86 = pcall(FarmSync.queuePreview)

            if not Ok90 then
                local SellPreview = WidgetRegistry.SellPreview

                if SellPreview and SellPreview.status then
                    SellPreview.status.Text = "failed · " .. tostring(Ret86)
                end

                KozuaLog("plot", "preview ERR", (tostring(Ret86)))
            end

            return
        end

        local SellPreview = WidgetRegistry.SellPreview

        if SellPreview and SellPreview.status then
            SellPreview.status.Text = "preview missing"
        end
    end
    OnFlagChanged("HookTest", function()
        local HookTest = WidgetRegistry.HookTest

        if not u1195 or not u1195.test then
            if HookTest and HookTest.status then
                HookTest.status.Text = "missing"
            end

            return
        end

        if HookTest and HookTest.status then
            HookTest.status.Text = "sending…"
        end

        task.spawn(function()
            local VarV4577, VarV4578 = u1195.test()

            if HookTest and HookTest.status then
                HookTest.status.Text = if not VarV4577 then "fail · " .. tostring(VarV4578) else "sent"
            end

            KozuaLog("hook", not VarV4577 and "test fail" or "test ok", (tostring(VarV4578)))
        end)
    end)
    OnFlagChanged("Optimizer", function(OptVal)
        PanelCtl.opt(OptVal)
        KozuaLog("esp", "optimizer", OptVal)
    end)
    OnFlagChanged("FPSCap", function(FpsVal)
        PanelCtl.fps()
        KozuaLog("esp", "fps cap", FpsVal)
    end)
    v1136(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if Config.FlightBind and input.KeyCode == Config.FlightBind then
            local VarV2610 = not Config.Flight

            if WidgetRegistry.Flight and WidgetRegistry.Flight.set then
                WidgetRegistry.Flight.set(VarV2610)
            else
                Config.Flight = VarV2610
            end

            if WidgetRegistry.Flight and WidgetRegistry.Flight.on then
                WidgetRegistry.Flight.on(VarV2610)
            else
                EngineRefresh((EngineWantsFlight()))

                if EngineOn then
                    if (Config.Flight or Config.BypassSpeed) and true or (not not Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
                        FlightEnable()
                        FlightDisable()
                        FlightSetWrap(true)
                    elseif next(MoveWraps) then
                        FlightSetWrap(false)
                    end
                end
            end

            if IsApplyingConfig then
                return
            end

            if IsSavingDebounced then
                return
            end

            IsSavingDebounced = true

            local VarV2611 = ConfigGen

            task.delay(0.35, function()
                IsSavingDebounced = false

                if VarV2611 ~= (getUserSlot().gen or 0) then
                    return
                end

                saveConfig()
            end)
        end
    end));
    (function()
        local Ok91, Ret87, _, _ = pcall(function()
            v1191()

            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    v1188(descendant)
                end
            end
        end)

        if not Ok91 then
            KozuaLog("prompts", "ERR", "scan", (tostring(Ret87)))
        end

        local connection20 = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") then
                task.defer(v1188, descendant)
            end
        end)

        if connection20 then
            ConnList[connection20] = true
        end

        local connection21 = ProximityPromptService.PromptButtonHoldBegan:Connect(function(Arg494)
            v1188(Arg494)

            if v1189(Arg494) and (StealState and StealState.running and Config.AutoSteal) then
                if (StealState.state == "GoEgg" or StealState.state == "Grab") and StealState.promptIsTarget and StealState.promptIsTarget(Arg494, StealState.target, 5) then
                    v1190(Arg494)
                end

                return
            end

            if v1185 then
                pcall(v1185, Arg494, 0)

                return
            end

            pcall(function()
                Arg494:InputHoldBegin()
                Arg494:InputHoldEnd()
            end)
        end)

        if connection21 then
            ConnList[connection21] = true
        end

        pcall(function()
            local connection22 = ProximityPromptService.PromptShown:Connect(function(prompt)
                u1187 = prompt
                v1188(prompt)

                if StealState and (StealState.running and Config.AutoSteal and v1189(prompt) and StealState.state == "Grab" and StealState.promptIsTarget and StealState.promptIsTarget(prompt, StealState.target, 5)) then
                    v1190(prompt)
                end
            end)

            if connection22 then
                ConnList[connection22] = true
            end
        end)
        pcall(function()
            local connection23 = ProximityPromptService.PromptHidden:Connect(function(prompt)
                if prompt == u1187 then
                    u1187 = nil
                end
            end)

            if connection23 then
                ConnList[connection23] = true
            end
        end)
        KozuaLog("prompts", "instant HoldDuration=0")
    end)();
    (function()
        EngineRefresh((EngineWantsFlight()))

        if not EngineOn then
            return
        end

        if (Config.Flight or Config.BypassSpeed) and true or (not not Config.AutoSteal or ((Config.AutoPlaceEggs or Config.AutoTreadmill) and true or (not not Config.AutoHatch or StealActive and Config.StealTravel == "Flight"))) then
            FlightEnable()
            FlightDisable()
            FlightSetWrap(true)

            return
        end

        if next(MoveWraps) then
            FlightSetWrap(false)
        end
    end)()
    pcall(loadAutoConfig, true)
    if not PhoneUILocked then
        IsMobile = Config.PhoneUI == true
    end
    if ApplyResponsiveLayout then
        ApplyResponsiveLayout()
    end
    if StealState.bat and StealState.bat.setLive then
        StealState.bat.setLive(Config.BatAura == true)
    end
    if FarmSync and FarmSync.sync then
        FarmSync.sync()
    end
    local Ok92, Ret88 = pcall(SyncGameData)
    if not Ok92 then
        KozuaLog("modules", "sync fail", (tostring(Ret88)))
    end
    task.spawn(function()
        while IsAlive do
            task.wait(20)

            if IsAlive then
                pcall(SyncGameData)
            end
        end
    end)
    if not IsFlying() then
        v1144()

        local VarV1241 = select(1, GetCharParts())

        if VarV1241 then
            pcall(function()
                VarV1241.PlatformStand = false
            end)
        end
    end
    PanelCtl.fps()
    if Config.Optimizer then
        PanelCtl.opt(true)
    end
    local VarV1242 = u323
    function u323()
        IsAlive = false

        local VarV2612 = StopSteal
        local Ok93, Ret89, _, _ = pcall(VarV2612)

        if not Ok93 then
            KozuaLog("shutdown", "ERR", "stopSteal", (tostring(Ret89)))
        end

        local Ok94, Ret90, _, _ = pcall(function()
            if StealState and StealState.muteHazards then
                StealState.muteHazards(false)
            end

            if StealState and StealState.muteBelt then
                StealState.muteBelt(false)
            end
        end)

        if not Ok94 then
            KozuaLog("shutdown", "ERR", "hazards", (tostring(Ret90)))
        end

        local Ok95, Ret91, _, _ = pcall(function()
            if StealState.bat and StealState.bat.stop then
                StealState.bat.stop()
            end
        end)

        if not Ok95 then
            KozuaLog("shutdown", "ERR", "bat", (tostring(Ret91)))
        end

        local Ok96, Ret92, _, _ = pcall(function()
            if VarU1230 and VarU1230.stop then
                VarU1230.stop()
            end
        end)

        if not Ok96 then
            KozuaLog("shutdown", "ERR", "hop", (tostring(Ret92)))
        end

        local Ok97, Ret93, _, _ = pcall(function()
            if FarmSync and FarmSync.stop then
                FarmSync.stop()
            end
        end)

        if not Ok97 then
            KozuaLog("shutdown", "ERR", "plot", (tostring(Ret93)))
        end

        local Ok98, Ret94, _, _ = pcall(function()
            EngineRefresh(false)
            FlightSetWrap(false)
        end)

        if not Ok98 then
            KozuaLog("shutdown", "ERR", "engineOff", (tostring(Ret94)))
        end

        local Ok99, Ret95, _, _ = pcall(function()
            for _, v in ipairs({
				"attrConn",
				"stConn",
				"hpConn"
			}) do
                local VarV4581 = t165[v]

                t165[v] = nil

                if VarV4581 then
                    pcall(function()
                        VarV4581:Disconnect()
                    end)
                end
            end
        end)

        if not Ok99 then
            KozuaLog("shutdown", "ERR", "antiMob", (tostring(Ret95)))
        end

        local VarV2641 = v1137
        local Ok100, Ret96, _, _ = pcall(VarV2641)

        if not Ok100 then
            KozuaLog("shutdown", "ERR", "conns", (tostring(Ret96)))
        end

        local clear = PanelCtl.clear
        local Ok101, Ret97, _, _ = pcall(clear)

        if not Ok101 then
            KozuaLog("shutdown", "ERR", "esp", (tostring(Ret97)))
        end

        local Ok103, Ret99, _, _ = pcall(function()
            local VarV4582 = ScreenGui and ScreenGui.Parent
            local VarV4583 = WorldGuiTag

            if VarV4582 and type(VarV4583) == "string" then
                local VarV4584 = VarV4582:FindFirstChild(VarV4583)

                if VarV4584 then
                    VarV4584:Destroy()
                end
            end

            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local VarV4586 = WorldGuiTag

            if PlayerGui and type(VarV4586) == "string" then
                local VarV4587 = PlayerGui:FindFirstChild(VarV4586)

                if VarV4587 then
                    VarV4587:Destroy()
                end
            end

            if PlayerGui then
                local KozuaWorldGui = PlayerGui:FindFirstChild("KozuaWorldGui")

                if KozuaWorldGui then
                    KozuaWorldGui:Destroy()
                end
            end

            if gethui then
                local Ok102, Ret98 = pcall(gethui)

                if Ok102 then
                    local VarV4591 = WorldGuiTag

                    if Ret98 then
                        if type(VarV4591) ~= "string" then
                            return
                        end

                        local VarV4592 = Ret98:FindFirstChild(VarV4591)

                        if VarV4592 then
                            VarV4592:Destroy()
                        end
                    end
                end
            end
        end)

        if not Ok103 then
            KozuaLog("shutdown", "ERR", "worldGui", (tostring(Ret99)))
        end

        local VarV2655 = v1144
        local Ok104, Ret100, _, _ = pcall(VarV2655)

        if not Ok104 then
            KozuaLog("shutdown", "ERR", "ghost", (tostring(Ret100)))
        end

        local Ok105, Ret101, _, _ = pcall(function()
            PanelCtl.opt(false)
        end)

        if not Ok105 then
            KozuaLog("shutdown", "ERR", "opt", (tostring(Ret101)))
        end

        local Ok106, Ret102, _, _ = pcall(function()
            saveConfig(true)
        end)

        if not Ok106 then
            KozuaLog("shutdown", "ERR", "saveConfig", (tostring(Ret102)))
        end

        local VarV2668 = getgenv and getgenv() or _G
        local VarV2669 = getUserSlot()

        VarV2669.unload = nil
        VarV2669.alive = false
        VarV2669.dump = nil

        if type(VarV2668.KozuaUI) == "table" then
            VarV2668.KozuaUI[UserIdStr] = nil
        end

        if type(VarV2668.KozuaDumpByUser) == "table" then
            VarV2668.KozuaDumpByUser[UserIdStr] = nil
        end

        if VarV2668.UI == KozuaUI then
            VarV2668.UI = nil
        end

        if VarV2668.KozuaUnloadUid == UserIdStr then
            VarV2668.KozuaUnloadUid = nil
            VarV2668.KozuaUnload = nil
        end

        VarV1242()
    end
    KozuaUI.Destroy = u323
    local VarV1243 = getEnvTable()
    local VarV1244 = getUserSlot()
    VarV1244.unload = u323
    VarV1244.alive = true
    VarV1243.KozuaUnloadUid = UserIdStr
    function VarV1243.KozuaUnload()
        local LocalPlayer2 = Players.LocalPlayer
        local StrId42 = tostring(LocalPlayer2 and LocalPlayer2.UserId or 0)
        local KozuaHub = VarV1243.KozuaHub
        local VarV2673 = type(KozuaHub) == "table" and (type(KozuaHub.slots) == "table" and KozuaHub.slots[StrId42])

        if type(VarV2673) == "table" and type(VarV2673.unload) == "function" then
            VarV2673.unload()
        end
    end
    function KozuaUI.KozuaDump()
        local Character26 = LocalPlayer.Character
        local VarV2675

        if not Character26 then
            VarV2675 = nil
        else
            local Humanoid = Character26:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = Character26:FindFirstChild("HumanoidRootPart")

            VarV2675 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
        end

        local Tab305 = {
			state = StealState.state,
			travel = Config.StealTravel,
			stealSpeed = Config.StealSpeed,
			bypass = Config.BypassSpeed,
			cap = Config.BypassCap,
			engine = EngineOn,
			carrying = StealState.carrying,
			trapped = u1157,
			trapEscaped = n14,
			stillFor = StealState.stillFor,
			target = StealState.target and StealState.target.area .. " " .. StealState.target.name or nil,
			pos = VarV2675 and {
				math.floor(VarV2675.Position.X),
				math.floor(VarV2675.Position.Y),
				math.floor(VarV2675.Position.Z)
			},
			wraps = MoveWraps and next(MoveWraps) ~= nil,
			areas = Config.Areas,
			eggTypes = Config.EggTypes,
			stealMode = Config.StealMode,
			eggEsp = Config.EggESP,
			plotEsp = Config.PlotESP
		}
        local VarV2679 = EggCycleCountdown()
        local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

        if type(AreaEggCycleNightSeconds) ~= "number" then
            AreaEggCycleNightSeconds = 10
        end

        Tab305.night = VarV2679 <= math.clamp(AreaEggCycleNightSeconds, 1, 300)

        return Tab305
    end
    local VarV1245 = getEnvTable()
    getUserSlot().dump = KozuaUI.KozuaDump
    VarV1245.KozuaDumpByUser = type(VarV1245.KozuaDumpByUser) == "table" and VarV1245.KozuaDumpByUser or {}
    VarV1245.KozuaDumpByUser[UserIdStr] = KozuaUI.KozuaDump
    function VarV1245.KozuaDump(...)
        local LocalPlayer3 = Players.LocalPlayer
        local StrId43 = tostring(LocalPlayer3 and LocalPlayer3.UserId or 0)
        local VarV2683 = VarV1245.KozuaDumpByUser and VarV1245.KozuaDumpByUser[StrId43]

        if type(VarV2683) == "function" then
            return VarV2683(...)
        end
    end
    print("[UI] KOZUA ready · RightShift toggles · Dark / Light / Kozua in Settings")
    KozuaLog("boot", "game logic attached · KozuaDump() in F9")
end)()
