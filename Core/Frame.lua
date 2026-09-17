local _, Mimorium = ...

function Mimorium:CreateMainFrame()
    local frame = CreateFrame("Frame", "MimoriumFrame", UIParent, "BackdropTemplate")
    frame:SetSize(420, 260)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -24)
    title:SetText("Mimorium")

    local description = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    description:SetPoint("TOP", title, "BOTTOM", 0, -16)
    description:SetWidth(330)
    description:SetJustifyH("CENTER")
    description:SetText("Dein Buch für Emotes, Gesten und kleine Darbietungen.")

    local instrumentButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    instrumentButton:SetSize(190, 28)
    instrumentButton:SetPoint("TOP", description, "BOTTOM", 0, -24)
    instrumentButton:SetText("Kristallharfe spielen")
    instrumentButton:SetScript("OnClick", function()
        Mimorium:ToggleInstrumentFrame()
    end)

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -4, -4)

    self.frame = frame
end

function Mimorium:ToggleFrame()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end
