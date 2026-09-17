local _, Mimorium = ...

local PREFIX = "Mimorium"
local NOTES = {
    { key = "A", note = "C4" }, { key = "W", note = "Db4", black = true },
    { key = "S", note = "D4" }, { key = "E", note = "Eb4", black = true },
    { key = "D", note = "E4" }, { key = "F", note = "F4" },
    { key = "T", note = "Gb4", black = true }, { key = "G", note = "G4" },
    { key = "Y", note = "Ab4", black = true }, { key = "H", note = "A4" },
    { key = "U", note = "Bb4", black = true }, { key = "J", note = "B4" },
    { key = "K", note = "C5" },
}

local NOTE_BY_KEY = {}
for _, entry in ipairs(NOTES) do
    NOTE_BY_KEY[entry.key] = entry.note
end

local function soundPath(note)
    return "Interface\\AddOns\\Mimorium\\Sounds\\Harp_" .. note .. ".ogg"
end

local function groupChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    end

    if IsInRaid() then
        return "RAID"
    end

    if IsInGroup() then
        return "PARTY"
    end
end

function Mimorium:InitializeInstruments()
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    self:CreateInstrumentFrame()
end

function Mimorium:CreateInstrumentFrame()
    local frame = CreateFrame("Frame", "MimoriumInstrumentFrame", UIParent, "BackdropTemplate")
    frame:SetSize(590, 255)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:EnableKeyboard(true)
    frame:EnableMouse(true)
    frame:Hide()
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -24)
    title:SetText("Kristallharfe")

    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOP", title, "BOTTOM", 0, -8)
    hint:SetText("A W S E D F T G Y H U J K  ·  ESC schließt")

    local sync = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sync:SetPoint("TOP", hint, "BOTTOM", 0, -4)
    frame.syncText = sync

    local keyWidth = 38
    local firstX = -((#NOTES - 1) * keyWidth) / 2
    for index, entry in ipairs(NOTES) do
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(keyWidth - 2, entry.black and 46 or 70)
        button:SetPoint("TOP", frame, "CENTER", firstX + (index - 1) * keyWidth, entry.black and -10 or 20)
        button:SetText(entry.key .. "\n" .. entry.note:gsub("b", "♭"))
        if entry.black then
            button:GetFontString():SetTextColor(0.75, 0.55, 1)
        end
        button:SetScript("OnClick", function()
            Mimorium:PlayInstrumentNote(entry.note, true)
        end)
    end

    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
            return
        end

        local note = NOTE_BY_KEY[key]
        if note then
            Mimorium:PlayInstrumentNote(note, true)
        end
    end)
    frame:SetScript("OnShow", function(self)
        self:SetPropagateKeyboardInput(false)
        local channel = groupChannel()
        self.syncText:SetText(channel and "Synchronisiert mit deiner Gruppe" or "Lokal spielen – für Synchronisierung einer Gruppe beitreten")
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
        local channel = groupChannel()
        if channel then
            C_ChatInfo.SendAddonMessage(PREFIX, "N:" .. note, channel)
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
