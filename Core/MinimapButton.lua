local _, Mimorium = ...

local BUTTON_POSITION = { x = 76, y = -6 }

function Mimorium:CreateMinimapButton()
    -- New installations show the button by default. A saved false value keeps
    -- it hidden until the player enables it again through the slash command.
    if MimoriumDB.minimapButton == nil then
        MimoriumDB.minimapButton = true
    end

    local button = CreateFrame("Button", "MimoriumMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetPoint("CENTER", Minimap, "CENTER", BUTTON_POSITION.x, BUTTON_POSITION.y)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("CENTER", 0, 0)

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            Mimorium:ToggleFrame()
        else
            Mimorium:SetMinimapButtonShown(false)
            Mimorium:Print("Minimap-Button ausgeblendet. Mit /mimo minimap blendest du ihn wieder ein.")
        end
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Mimorium")
        GameTooltip:AddLine("Linksklick: Mimorium öffnen", 1, 1, 1)
        GameTooltip:AddLine("Rechtsklick: Button ausblenden", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)

    self.minimapButton = button
    self:SetMinimapButtonShown(MimoriumDB.minimapButton)
end

function Mimorium:SetMinimapButtonShown(isShown)
    MimoriumDB.minimapButton = isShown

    if isShown then
        self.minimapButton:Show()
    else
        self.minimapButton:Hide()
    end
end

function Mimorium:ToggleMinimapButton()
    self:SetMinimapButtonShown(not MimoriumDB.minimapButton)

    if MimoriumDB.minimapButton then
        self:Print("Minimap-Button eingeblendet.")
    else
        self:Print("Minimap-Button ausgeblendet.")
    end
end
