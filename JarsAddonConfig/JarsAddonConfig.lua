-- Jar's Addon Config - Central configuration launcher for all Jar's addons
-- Version 1.0.0

local addonName = "JarsAddonConfig"
local configFrame = nil

-- Saved variables
JarsAddonConfigDB = JarsAddonConfigDB or { scale = 1.0, minimapAngle = 45 }

-- List of Jar's addons with their config frame names and display names
local addons = {
    { frameName = "JUF_ConfigFrame", name = "Jar's Unit Frames" },
    { frameName = "JarsCastbarConfig", name = "Jar's Cast Bar" },
    { frameName = "JMCB_ConfigFrame", name = "Jar's Mouse Cast Bar" },
    { frameName = "JMAB_ConfigFrame", name = "Jar's Mouse Action Bars" },
    { frameName = "JG13_ConfigFrame", name = "Jar's G13 Bars" },
    { frameName = "JFC_ConfigFrame", name = "Jar's Font Changer" },
    { frameName = "JET_ErrorFrame", name = "Jar's Error Trap" },
    { func = function() JarsRaid_OpenConfig() end,          name = "Jar's Raid" },
    { frameName = "JarsCoolDownConfig",                     name = "Jar's Cooldowns" },
    { frameName = "JarsMonkStaxConfig",                     name = "Jar's Monk Stax" },
    { func = function() JarsEasyTracker_OpenConfig() end,   name = "Jar's Easy Tracker" },
}

-- Forward declaration
local CreateConfigFrame

-- Create minimap icon
local function CreateMinimapIcon()
    local icon = CreateFrame("Button", "JAC_MinimapButton", Minimap)
    icon:SetSize(32, 32)
    icon:SetFrameStrata("MEDIUM")
    icon:SetFrameLevel(8)
    icon:EnableMouse(true)
    icon:RegisterForDrag("LeftButton")
    icon:RegisterForClicks("LeftButtonUp")
    
    -- Position on minimap
    local angle = JarsAddonConfigDB.minimapAngle or 45
    local radius = 110
    local x = math.cos(angle) * radius + 10
    local y = math.sin(angle) * radius - 10
    icon:SetPoint("CENTER", Minimap, "CENTER", x, y)
    
    
    -- Background
    icon.bg = icon:CreateTexture(nil, "BACKGROUND")
    icon.bg:SetSize(20, 20)
    icon.bg:SetPoint("CENTER", -10, 10)
    icon.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    
    -- Icon texture (settings/gear icon)
    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetSize(18, 18)
    icon.texture:SetPoint("CENTER", -10, 10)
    icon.texture:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
    
    -- Border
    icon.border = icon:CreateTexture(nil, "OVERLAY")
    icon.border:SetSize(52, 52)
    icon.border:SetPoint("CENTER")
    icon.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    -- Tooltip
    icon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Jar's Addon Config")
        GameTooltip:AddLine("Click to open config launcher", 0.5, 0.5, 1)
        GameTooltip:AddLine("Drag to move", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Click to toggle window
    icon:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            local frame = CreateConfigFrame()
            frame:SetShown(not frame:IsShown())
        end
    end)
    
    -- Drag to move around minimap
    icon:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            mx = mx + 10
            my = my - 10
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            
            local angle = math.atan2(py - my, px - mx)
            local radius = 110
            local x = math.cos(angle) * radius + 10
            local y = math.sin(angle) * radius - 10
            self:SetPoint("CENTER", Minimap, "CENTER", x, y)
            
            JarsAddonConfigDB.minimapAngle = angle
        end)
    end)
    icon:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    
    return icon
end

-- Modern dark UI colour palette
local UI = {
    bg        = { 0.10, 0.10, 0.12, 0.95 },
    header    = { 0.13, 0.13, 0.16, 1 },
    accent    = { 0.30, 0.75, 0.75, 1 },
    accentDim = { 0.20, 0.50, 0.50, 1 },
    text      = { 0.90, 0.90, 0.90, 1 },
    textDim   = { 0.55, 0.55, 0.58, 1 },
    section   = { 0.16, 0.16, 0.19, 1 },
    border    = { 0.22, 0.22, 0.26, 1 },
    sliderBg  = { 0.18, 0.18, 0.22, 1 },
    sliderFill= { 0.30, 0.75, 0.75, 0.6 },
    btnNormal = { 0.18, 0.18, 0.22, 1 },
    btnHover  = { 0.24, 0.24, 0.28, 1 },
    btnPress  = { 0.14, 0.14, 0.17, 1 },
    checkOn   = { 0.30, 0.75, 0.75, 1 },
    checkOff  = { 0.22, 0.22, 0.26, 1 },
}

local FONT = "Fonts\\FRIZQT__.TTF"

local backdrop_main = {
    bgFile   = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
}

-- ---------------------------------------------------------------------------
-- UI Helpers
-- ---------------------------------------------------------------------------

local function CreateSectionHeader(parent, text)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(20)

    local label = container:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT, 10, "")
    label:SetTextColor(unpack(UI.textDim))
    label:SetPoint("LEFT", 0, 0)
    label:SetText(string.upper(text))
    container.label = label

    local line = container:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("LEFT", label, "RIGHT", 6, 0)
    line:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    line:SetColorTexture(unpack(UI.border))
    container.line = line

    return container
end

local function CreateModernButton(parent, text, width, height, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    btn:SetBackdrop(backdrop_main)
    btn:SetBackdropColor(unpack(UI.btnNormal))
    btn:SetBackdropBorderColor(unpack(UI.border))

    btn.label = btn:CreateFontString(nil, "OVERLAY")
    btn.label:SetFont(FONT, 11, "")
    btn.label:SetTextColor(unpack(UI.accent))
    btn.label:SetPoint("CENTER")
    btn.label:SetText(text)

    -- Convenience wrapper so callers can use btn:SetText()
    btn.SetText = function(self, t) self.label:SetText(t) end

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(UI.btnHover))
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(UI.btnNormal))
    end)
    btn:SetScript("OnMouseDown", function(self)
        self:SetBackdropColor(unpack(UI.btnPress))
    end)
    btn:SetScript("OnMouseUp", function(self)
        self:SetBackdropColor(unpack(UI.btnHover))
    end)
    if onClick then
        btn:SetScript("OnClick", onClick)
    end

    return btn
end

local function CreateModernSlider(parent, name, labelText, minVal, maxVal, curVal, step, width, formatFunc, onChange)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, 40)

    -- Label
    local label = container:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT, 11, "")
    label:SetTextColor(unpack(UI.text))
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(labelText)

    -- Value readout
    local valText = container:CreateFontString(nil, "OVERLAY")
    valText:SetFont(FONT, 11, "")
    valText:SetTextColor(unpack(UI.accent))
    valText:SetPoint("TOPRIGHT", 0, 0)
    container.valText = valText

    -- Track background
    local trackBg = container:CreateTexture(nil, "BACKGROUND")
    trackBg:SetHeight(4)
    trackBg:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
    trackBg:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -16)
    trackBg:SetColorTexture(unpack(UI.sliderBg))

    -- Fill overlay (drawn on the slider itself below)
    local slider = CreateFrame("Slider", name, container, "MinimalSliderTemplate")
    slider:SetPoint("TOPLEFT", trackBg, "TOPLEFT", 0, 0)
    slider:SetPoint("BOTTOMRIGHT", trackBg, "BOTTOMRIGHT", 0, 0)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(curVal)
    container.slider = slider

    -- Teal fill behind current value
    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetHeight(4)
    fill:SetPoint("LEFT", trackBg, "LEFT", 0, 0)
    fill:SetColorTexture(unpack(UI.sliderFill))

    -- Thumb
    local thumb = slider:GetThumbTexture()
    if thumb then
        thumb:SetSize(14, 14)
        thumb:SetColorTexture(unpack(UI.accent))
    end

    local function UpdateFill()
        local pct = (slider:GetValue() - minVal) / (maxVal - minVal)
        fill:SetWidth(math.max(1, pct * trackBg:GetWidth()))
    end

    local function UpdateValue(_, value)
        valText:SetText(formatFunc and formatFunc(value) or string.format("%.2f", value))
        UpdateFill()
        if onChange then onChange(value) end
    end

    slider:SetScript("OnValueChanged", UpdateValue)
    slider:HookScript("OnShow", UpdateFill)
    UpdateValue(nil, curVal)

    return container
end

-- ---------------------------------------------------------------------------
-- Create the main configuration window
-- ---------------------------------------------------------------------------
CreateConfigFrame = function()
    if configFrame then
        return configFrame
    end

    -- Main frame
    local frame = CreateFrame("Frame", "JarsAddonConfigFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 560)
    frame:SetPoint("CENTER")
    frame:SetBackdrop(backdrop_main)
    frame:SetBackdropColor(unpack(UI.bg))
    frame:SetBackdropBorderColor(unpack(UI.border))
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetScale(JarsAddonConfigDB.scale or 1.0)
    tinsert(UISpecialFrames, "JarsAddonConfigFrame")

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    titleBar:SetHeight(30)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetBackdrop(backdrop_main)
    titleBar:SetBackdropColor(unpack(UI.header))
    titleBar:SetBackdropBorderColor(unpack(UI.border))

    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(FONT, 13, "")
    titleText:SetTextColor(unpack(UI.accent))
    titleText:SetPoint("LEFT", 12, 0)
    titleText:SetText("Jar's Addon Config")
    frame.title = titleText

    -- Close button (minimal "x")
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPoint("RIGHT", -2, 0)
    closeBtn.label = closeBtn:CreateFontString(nil, "OVERLAY")
    closeBtn.label:SetFont(FONT, 14, "")
    closeBtn.label:SetTextColor(unpack(UI.textDim))
    closeBtn.label:SetPoint("CENTER", 0, 0)
    closeBtn.label:SetText("x")
    closeBtn:SetScript("OnEnter", function(self) self.label:SetTextColor(1, 0.35, 0.35, 1) end)
    closeBtn:SetScript("OnLeave", function(self) self.label:SetTextColor(unpack(UI.textDim)) end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(scrollFrame:GetWidth() or 340)
    scrollFrame:SetScrollChild(content)

    -- We need to set the content width after the scroll frame is sized
    frame:HookScript("OnShow", function()
        content:SetWidth(scrollFrame:GetWidth())
    end)

    -- -----------------------------------------------------------------------
    -- Populate content
    -- -----------------------------------------------------------------------
    local yOffset = 0

    -- Section: Addons
    local addonHeader = CreateSectionHeader(content, "Addons")
    addonHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    addonHeader:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    yOffset = yOffset - 26

    for i, addon in ipairs(addons) do
        local btn = CreateModernButton(content, addon.name, 330, 28, function()
            if addon.func then
                local ok, err = pcall(addon.func)
                if not ok then
                    print("|cffff0000" .. addon.name .. " config not found. Make sure the addon is loaded.|r")
                end
            elseif addon.frameName then
                local targetFrame = _G[addon.frameName]
                if targetFrame then
                    targetFrame:SetShown(not targetFrame:IsShown())
                else
                    print("|cffff0000" .. addon.name .. " config not found. Make sure the addon is loaded.|r")
                end
            end
        end)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        yOffset = yOffset - 34
    end

    -- Section: Settings
    yOffset = yOffset - 10
    local settingsHeader = CreateSectionHeader(content, "Settings")
    settingsHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    settingsHeader:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    yOffset = yOffset - 30

    local scaleSlider = CreateModernSlider(
        content,
        "JAC_ScaleSlider",
        "Window Scale",
        0.5, 1.5,
        JarsAddonConfigDB.scale or 1.0,
        0.05,
        330,
        function(v) return string.format("%.2f", v) end,
        function(value)
            JarsAddonConfigDB.scale = value
            frame:SetScale(value)
        end
    )
    scaleSlider:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    yOffset = yOffset - 50

    -- Set content height so scroll works
    content:SetHeight(math.abs(yOffset) + 10)

    -- Initially hide the frame
    frame:Hide()

    configFrame = frame
    return frame
end

-- Slash command handler
SLASH_JARSADDONCONFIG1 = "/jac"
SLASH_JARSADDONCONFIG2 = "/jarsaddonconfig"
SlashCmdList["JARSADDONCONFIG"] = function(msg)
    local frame = CreateConfigFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Event handler
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        CreateMinimapIcon()
        print("|cff00ff00Jar's Addon Config loaded! Type |r|cffFFFF00/jac|r|cff00ff00 to open.|r")
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)
