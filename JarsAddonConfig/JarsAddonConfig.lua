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

-- Create the main configuration window
CreateConfigFrame = function()
    if configFrame then
        return configFrame
    end

    -- Main frame
    local frame = CreateFrame("Frame", "JarsAddonConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(400, 60 + (#addons * 35) + 20)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetScale(JarsAddonConfigDB.scale or 1.0)
    
    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("Jar's Addon Config")
    
    -- Create buttons for each addon
    local yOffset = -30
    for i, addon in ipairs(addons) do
        -- Open button
        local openButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        openButton:SetSize(70, 25)
        openButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
        openButton:SetText("Open")
        openButton:SetScript("OnClick", function()
            local configFrame = _G[addon.frameName]
            if configFrame then
                configFrame:SetShown(not configFrame:IsShown())
            else
                print("|cffff0000" .. addon.name .. " config not found. Make sure the addon is loaded.|r")
            end
        end)
        
        -- Addon name label
        local nameLabel = frame:CreateFontString(nil, "OVERLAY")
        nameLabel:SetFontObject("GameFontNormal")
        nameLabel:SetPoint("LEFT", openButton, "RIGHT", 10, 0)
        nameLabel:SetText(addon.name)
        
        yOffset = yOffset - 35
    end
    
    -- Scale slider
    yOffset = yOffset - 10
    local scaleLabel = frame:CreateFontString(nil, "OVERLAY")
    scaleLabel:SetFontObject("GameFontNormal")
    scaleLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
    scaleLabel:SetText("Window Scale:")
    
    local scaleSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    scaleSlider:SetPoint("LEFT", scaleLabel, "RIGHT", 10, 0)
    scaleSlider:SetMinMaxValues(0.5, 1.5)
    scaleSlider:SetValue(JarsAddonConfigDB.scale or 1.0)
    scaleSlider:SetValueStep(0.05)
    scaleSlider:SetObeyStepOnDrag(true)
    scaleSlider:SetWidth(200)
    scaleSlider.tooltipText = "Adjust the scale of this window"
    
    -- Slider value text
    local scaleValue = frame:CreateFontString(nil, "OVERLAY")
    scaleValue:SetFontObject("GameFontNormalSmall")
    scaleValue:SetPoint("LEFT", scaleSlider, "RIGHT", 5, 0)
    scaleValue:SetText(string.format("%.2f", JarsAddonConfigDB.scale or 1.0))
    
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        JarsAddonConfigDB.scale = value
        frame:SetScale(value)
        scaleValue:SetText(string.format("%.2f", value))
    end)
    
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
