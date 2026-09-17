local _, Mimorium = ...

local PREFIX = "Mimorium"
local MUSIC_CHANNEL = "MimoriumMusic"
local NOTES = {
    { key = "A", note = "C4", whiteIndex = 1 },
    { key = "W", note = "Db4", black = true, whiteIndex = 1 },
    { key = "S", note = "D4", whiteIndex = 2 },
    { key = "E", note = "Eb4", black = true, whiteIndex = 2 },
    { key = "D", note = "E4", whiteIndex = 3 },
    { key = "F", note = "F4", whiteIndex = 4 },
    { key = "T", note = "Gb4", black = true, whiteIndex = 4 },
    { key = "G", note = "G4", whiteIndex = 5 },
    { key = "Y", note = "Ab4", black = true, whiteIndex = 5 },
    { key = "H", note = "A4", whiteIndex = 6 },
    { key = "U", note = "Bb4", black = true, whiteIndex = 6 },
    { key = "J", note = "B4", whiteIndex = 7 },
    { key = "K", note = "C5", whiteIndex = 8 },
}

local NOTE_BY_KEY = {}
for _, entry in ipairs(NOTES) do
    NOTE_BY_KEY[entry.key] = entry
end

local function soundPath(note)
    return "Interface\\AddOns\\Mimorium\\Sounds\\Harp_" .. note .. ".ogg"
end

local function createKey(frame, entry, x)
    local button = CreateFrame("Button", nil, frame, "BackdropTemplate")
    button:SetSize(entry.black and 40 or 54, entry.black and 112 or 166)
    button:SetPoint("CENTER", frame, "CENTER", x, entry.black and -18 or -46)
    button:SetFrameLevel(frame:GetFrameLevel() + (entry.black and 4 or 2))
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    button:SetBackdropColor(entry.black and 0.05 or 0.16, entry.black and 0.04 or 0.11, entry.black and 0.09 or 0.20, 1)
    button:SetBackdropBorderColor(0.78, 0.61, 0.22, 1)

    local keyText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    keyText:SetPoint("BOTTOM", 0, 28)
    keyText:SetText(entry.key)
    keyText:SetTextColor(0.95, 0.84, 0.48)

    local noteText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    noteText:SetPoint("BOTTOM", 0, 10)
    noteText:SetText(entry.note:gsub("b", "♭"))
    noteText:SetTextColor(0.86, 0.75, 0.48)

    button:SetScript("OnClick", function()
        Mimorium:PlayInstrumentNote(entry.note, true)
    end)
    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.26, 0.17, 0.40, 1)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(entry.black and 0.05 or 0.16, entry.black and 0.04 or 0.11, entry.black and 0.09 or 0.20, 1)
    end)
end

function Mimorium:EnsureMusicChannel()
    local channelNumber = GetChannelName(MUSIC_CHANNEL)
    if channelNumber == 0 then
        JoinChannelByName(MUSIC_CHANNEL, nil, 0, false)
        channelNumber = GetChannelName(MUSIC_CHANNEL)
    end
    return channelNumber
end

function Mimorium:InitializeInstruments()
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    self:EnsureMusicChannel()
    self:CreateInstrumentFrame()
end

function Mimorium:CreateInstrumentFrame()
    local frame = CreateFrame("Frame", "MimoriumInstrumentFrame", UIParent, "BackdropTemplate")
    frame:SetSize(700, 410)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:EnableKeyboard(true)
    frame:EnableMouse(true)
    frame:Hide()
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 18,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    frame:SetBackdropBorderColor(0.75, 0.58, 0.22, 1)
    frame.pressedKeys = {}

    local crest = frame:CreateTexture(nil, "ARTWORK")
    crest:SetTexture("Interface\\Icons\\INV_Misc_Gem_Variety_01")
    crest:SetSize(36, 36)
    crest:SetPoint("TOP", 0, -26)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", crest, "BOTTOM", 0, -5)
    title:SetText("MIMORIUM · KRISTALLHARFE")

    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -7)
    subtitle:SetText("Spiele frei – jede Note erreicht den Mimorium-Musikkanal")

    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetTexture("Interface\\Buttons\\WHITE8x8")
    divider:SetSize(480, 1)
    divider:SetPoint("TOP", subtitle, "BOTTOM", 0, -10)
    divider:SetVertexColor(0.74, 0.57, 0.20, 0.8)

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    status:SetPoint("BOTTOM", 0, 25)
    frame.statusText = status

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)

    local whiteStart = -189
    local whiteWidth = 54
    for _, entry in ipairs(NOTES) do
        local x = whiteStart + (entry.whiteIndex - 1) * whiteWidth
        if entry.black then
            x = x + (whiteWidth / 2)
        end
        createKey(frame, entry, x)
    end

    local controls = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    controls:SetPoint("BOTTOM", status, "TOP", 0, 10)
    controls:SetText("A  W  S  E  D  F  T  G  Y  H  U  J  K     ·     ESC schließen")
    controls:SetTextColor(0.84, 0.73, 0.43)

    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
            return
        end

        local entry = NOTE_BY_KEY[key]
        if entry and not self.pressedKeys[key] then
            self.pressedKeys[key] = true
            Mimorium:PlayInstrumentNote(entry.note, true)
        end
    end)
    frame:SetScript("OnKeyUp", function(self, key)
        self.pressedKeys[key] = nil
    end)
    frame:SetScript("OnShow", function(self)
        self:SetPropagateKeyboardInput(false)
        wipe(self.pressedKeys)
        local channelNumber = Mimorium:EnsureMusicChannel()
        if channelNumber and channelNumber > 0 then
            self.statusText:SetText("MUSIKKANAL: " .. MUSIC_CHANNEL .. "  ·  AUDIO: SPIELEFFEKTE (SFX)")
        else
            self.statusText:SetText("Musikkanal wird verbunden …")
        end
    end)
    frame:SetScript("OnHide", function(self)
        wipe(self.pressedKeys)
    end)

    self.instrumentFrame = frame
end

function Mimorium:ToggleInstrumentFrame()
    if self.instrumentFrame:IsShown() then
        self.instrumentFrame:Hide()
    else
        self.instrumentFrame:Show()
    end
end

function Mimorium:PlayInstrumentNote(note, shouldBroadcast)
    -- SFX is deliberately used: it is the same audio channel as spell effects.
    PlaySoundFile(soundPath(note), "SFX")

    if shouldBroadcast then
        local channelNumber = self:EnsureMusicChannel()
        if channelNumber and channelNumber > 0 then
            C_ChatInfo.SendAddonMessage(PREFIX, "N:" .. note, "CHANNEL", channelNumber)
        end
    end
end

function Mimorium:HandleAddonMessage(prefix, message, _, sender)
    if prefix ~= PREFIX or Ambiguate(sender, "none") == UnitName("player") then
        return
    end

    local note = message:match("^N:([A-G][b#]?%d)$")
    if note then
        self:PlayInstrumentNote(note, false)
    end
end
