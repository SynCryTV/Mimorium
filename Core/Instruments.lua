local _, Mimorium = ...

local PREFIX = "Mimorium"
local MUSIC_CHANNEL = "MimoriumMusic"
local NOTE_NAMES = { "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B" }
local WHITE_NOTE_INDEX = { C = 1, D = 2, E = 3, F = 4, G = 5, A = 6, B = 7 }
local KEY_LAYOUT = {
    A = { name = "C", offset = 0 }, W = { name = "Db", offset = 0 },
    S = { name = "D", offset = 0 }, E = { name = "Eb", offset = 0 },
    D = { name = "E", offset = 0 }, F = { name = "F", offset = 0 },
    T = { name = "Gb", offset = 0 }, G = { name = "G", offset = 0 },
    Y = { name = "Ab", offset = 0 }, H = { name = "A", offset = 0 },
    U = { name = "Bb", offset = 0 }, J = { name = "B", offset = 0 },
    K = { name = "C", offset = 1 },
}

local function makeNote(name, octave)
    return name .. octave
end

local function splitNote(note)
    return note:match("^([A-G][b#]?)(%d)$")
end

local function soundPath(note)
    return "Interface\\AddOns\\Mimorium\\Sounds\\Harp_" .. note .. ".ogg"
end

local function displayNote(note)
    return note:gsub("b", "♭")
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

function Mimorium:SetInstrumentKeyActive(note, active)
    local button = self.instrumentFrame and self.instrumentFrame.keyButtons[note]
    if not button then
        return
    end

    if active then
        button:SetBackdropColor(0.67, 0.40, 0.90, 1)
        button:SetBackdropBorderColor(1, 0.88, 0.36, 1)
    else
        button:SetBackdropColor(button.isBlack and 0.10 or 0.82, button.isBlack and 0.07 or 0.73, button.isBlack and 0.16 or 0.56, 1)
        button:SetBackdropBorderColor(0.54, 0.36, 0.12, 1)
    end
end

function Mimorium:FlashInstrumentKey(note)
    self:SetInstrumentKeyActive(note, true)
    C_Timer.After(0.18, function()
        if not self.instrumentFrame or not self.instrumentFrame.heldNotes[note] then
            self:SetInstrumentKeyActive(note, false)
        end
    end)
end

function Mimorium:CreateInstrumentKey(frame, note, keyLabel, isBlack, x)
    local button = CreateFrame("Button", nil, frame, "BackdropTemplate")
    button.isBlack = isBlack
    button:SetSize(isBlack and 34 or 49, isBlack and 155 or 238)
    button:SetPoint("BOTTOM", frame, "BOTTOM", x, isBlack and 114 or 66)
    button:SetFrameLevel(frame:GetFrameLevel() + (isBlack and 5 or 2))
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    button:SetBackdropBorderColor(0.54, 0.36, 0.12, 1)
    button:SetBackdropColor(isBlack and 0.10 or 0.82, isBlack and 0.07 or 0.73, isBlack and 0.16 or 0.56, 1)

    local noteText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    noteText:SetPoint("BOTTOM", 0, isBlack and 35 or 45)
    noteText:SetText(displayNote(note))
    noteText:SetTextColor(isBlack and 0.94 or 0.22, isBlack and 0.83 or 0.13, isBlack and 0.45 or 0.30)

    local keyText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    keyText:SetPoint("BOTTOM", 0, 16)
    button.keyText = keyText
    if keyLabel then
        keyText:SetText(keyLabel)
        keyText:SetTextColor(isBlack and 1 or 0.27, isBlack and 0.90 or 0.17, isBlack and 0.52 or 0.36)
    end

    button:SetScript("OnMouseDown", function()
        frame.heldNotes[note] = true
        Mimorium:SetInstrumentKeyActive(note, true)
        Mimorium:PlayInstrumentNote(note, true)
    end)
    button:SetScript("OnMouseUp", function()
        frame.heldNotes[note] = nil
        Mimorium:SetInstrumentKeyActive(note, false)
    end)

    frame.keyButtons[note] = button
end

function Mimorium:RefreshInstrumentKeyboard()
    local frame = self.instrumentFrame
    for note, button in pairs(frame.keyButtons) do
        local name, octave = splitNote(note)
        local displayKey
        for key, mapping in pairs(KEY_LAYOUT) do
            if mapping.name == name and frame.activeOctave + mapping.offset == tonumber(octave) then
                displayKey = key
                break
            end
        end
        button.keyText:SetText(displayKey or "")
        button.keyText:SetTextColor(button.isBlack and 1 or 0.27, button.isBlack and 0.90 or 0.17, button.isBlack and 0.52 or 0.36)
    end
    frame.octaveText:SetText("SPIEL-OKTAVE: C" .. frame.activeOctave .. "  ·  ← / →")
end

function Mimorium:CreateInstrumentFrame()
    local frame = CreateFrame("Frame", "MimoriumInstrumentFrame", UIParent, "BackdropTemplate")
    frame:SetSize(1260, 585)
    frame:SetPoint("CENTER", 0, 30)
    frame:SetFrameStrata("DIALOG")
    frame:EnableKeyboard(true)
    frame:EnableMouse(true)
    frame:Hide()
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 24,
        insets = { left = 12, right = 12, top = 12, bottom = 12 },
    })
    frame:SetBackdropColor(0.13, 0.08, 0.19, 0.98)
    frame:SetBackdropBorderColor(0.80, 0.60, 0.20, 1)
    frame.keyButtons = {}
    frame.heldNotes = {}
    frame.activeOctave = 4

    local header = frame:CreateTexture(nil, "ARTWORK")
    header:SetTexture("Interface\\Buttons\\WHITE8x8")
    header:SetSize(1230, 112)
    header:SetPoint("TOP", 0, -14)
    header:SetVertexColor(0.25, 0.15, 0.36, 1)

    local crest = frame:CreateTexture(nil, "OVERLAY")
    crest:SetTexture("Interface\\Icons\\INV_Misc_Gem_Variety_01")
    crest:SetSize(44, 44)
    crest:SetPoint("TOP", 0, -27)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", crest, "BOTTOM", 0, -4)
    title:SetText("MIMORIUM · KRISTALLHARFE")

    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -6)
    subtitle:SetText("Freies Spiel im gemeinsamen Mimorium-Musikkanal")
    subtitle:SetTextColor(0.94, 0.80, 0.40)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -7, -7)

    local octave = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    octave:SetPoint("TOPLEFT", 46, -43)
    frame.octaveText = octave

    local channel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    channel:SetPoint("TOPRIGHT", -46, -43)
    channel:SetText("MUSIKKANAL: " .. MUSIC_CHANNEL)
    channel:SetTextColor(0.94, 0.80, 0.40)

    local whiteWidth = 49
    local firstWhiteX = -((22 - 1) * whiteWidth) / 2
    local whiteCount = 0
    for octaveNumber = 3, 5 do
        for _, name in ipairs({ "C", "D", "E", "F", "G", "A", "B" }) do
            whiteCount = whiteCount + 1
            local note = makeNote(name, octaveNumber)
            local physicalKey
            for key, mapping in pairs(KEY_LAYOUT) do
                if mapping.name == name and mapping.offset == 0 and octaveNumber == frame.activeOctave then
                    physicalKey = key
                end
            end
            self:CreateInstrumentKey(frame, note, physicalKey, false, firstWhiteX + (whiteCount - 1) * whiteWidth)
        end
    end
    whiteCount = whiteCount + 1
    self:CreateInstrumentKey(frame, "C6", frame.activeOctave == 5 and "K" or nil, false, firstWhiteX + (whiteCount - 1) * whiteWidth)

    local whiteOffset = 0
    for octaveNumber = 3, 5 do
        for _, name in ipairs({ "Db", "Eb", "Gb", "Ab", "Bb" }) do
            local beforeWhite = WHITE_NOTE_INDEX[name:gsub("b", "")] + whiteOffset
            local note = makeNote(name, octaveNumber)
            local physicalKey
            for key, mapping in pairs(KEY_LAYOUT) do
                if mapping.name == name and octaveNumber == frame.activeOctave then
                    physicalKey = key
                end
            end
            self:CreateInstrumentKey(frame, note, physicalKey, true, firstWhiteX + (beforeWhite - 1) * whiteWidth + (whiteWidth / 2))
        end
        whiteOffset = whiteOffset + 7
    end

    local controls = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    controls:SetPoint("BOTTOM", 0, 31)
    controls:SetText("A W S E D F T G Y H U J K  ·  ← / → Oktave wechseln  ·  ESC schließen")
    controls:SetTextColor(0.97, 0.86, 0.54)

    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
            return
        end
        if key == "LEFT" or key == "RIGHT" then
            self.activeOctave = math.max(3, math.min(5, self.activeOctave + (key == "LEFT" and -1 or 1)))
            Mimorium:RefreshInstrumentKeyboard()
            return
        end

        local mapping = KEY_LAYOUT[key]
        if mapping and not self.pressedKeys[key] then
            local note = makeNote(mapping.name, self.activeOctave + mapping.offset)
            self.pressedKeys[key] = note
            self.heldNotes[note] = true
            Mimorium:SetInstrumentKeyActive(note, true)
            Mimorium:PlayInstrumentNote(note, true)
        end
    end)
    frame:SetScript("OnKeyUp", function(self, key)
        local note = self.pressedKeys[key]
        if note then
            self.pressedKeys[key] = nil
            self.heldNotes[note] = nil
            Mimorium:SetInstrumentKeyActive(note, false)
        end
    end)
    frame:SetScript("OnShow", function(self)
        self:SetPropagateKeyboardInput(false)
        self.pressedKeys = {}
        Mimorium:RefreshInstrumentKeyboard()
        Mimorium:EnsureMusicChannel()
    end)
    frame:SetScript("OnHide", function(self)
        wipe(self.pressedKeys)
        wipe(self.heldNotes)
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
        self:FlashInstrumentKey(note)
        self:PlayInstrumentNote(note, false)
    end
end
