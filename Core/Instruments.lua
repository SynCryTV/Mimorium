local _, Mimorium = ...

local PREFIX, MUSIC_CHANNEL = "Mimorium", "MimoriumMusic"
local INSTRUMENTS = {
    harp = { label = "KRISTALLHARFE", filePrefix = "Harp" },
    piano = { label = "KONZERTKLAVIER", filePrefix = "Piano" },
}
local KEY_LAYOUT = {
    A={"C",0}, W={"Db",0}, S={"D",0}, E={"Eb",0}, D={"E",0}, F={"F",0},
    T={"Gb",0}, G={"G",0}, Y={"Ab",0}, H={"A",0}, U={"Bb",0}, J={"B",0}, K={"C",1},
}
local WHITE_NAMES, BLACK_NAMES = { "C", "D", "E", "F", "G", "A", "B" }, { "Db", "Eb", "Gb", "Ab", "Bb" }
local WHITE_INDEX = { C=1, D=2, E=3, F=4, G=5, A=6, B=7 }

local function note(name, octave) return name .. octave end
local function splitNote(value) return value:match("^([A-G][b#]?)(%d)$") end
local function soundPath(instrument, value)
    return "Interface\\AddOns\\Mimorium\\Sounds\\" .. INSTRUMENTS[instrument].filePrefix .. "_" .. value .. ".ogg"
end

function Mimorium:EnsureMusicChannel()
    local channel = GetChannelName(MUSIC_CHANNEL)
    if channel == 0 then JoinChannelByName(MUSIC_CHANNEL, nil, 0, false); channel = GetChannelName(MUSIC_CHANNEL) end
    return channel
end

function Mimorium:InitializeInstruments()
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    self:EnsureMusicChannel()
    self:CreateInstrumentFrame()
end

function Mimorium:SetKeyActive(value, active)
    local button = self.instrumentFrame and self.instrumentFrame.keyButtons[value]
    if not button then return end
    if active then
        button:SetBackdropColor(0.67, 0.40, 0.90, 1); button:SetBackdropBorderColor(1, 0.88, 0.36, 1)
    else
        button:SetBackdropColor(button.black and 0.10 or 0.82, button.black and 0.07 or 0.73, button.black and 0.16 or 0.56, 1)
        button:SetBackdropBorderColor(0.54, 0.36, 0.12, 1)
    end
end

function Mimorium:FlashKey(value)
    self:SetKeyActive(value, true)
    C_Timer.After(0.18, function()
        if self.instrumentFrame and not self.instrumentFrame.heldNotes[value] then self:SetKeyActive(value, false) end
    end)
end

function Mimorium:RefreshInstrumentFrame()
    local frame, data = self.instrumentFrame, INSTRUMENTS[self.currentInstrument]
    frame.title:SetText("MIMORIUM - " .. data.label)
    frame.octaveText:SetText("SPIEL-OKTAVE: C" .. frame.activeOctave .. " - LINKS/RECHTS")
    for value, button in pairs(frame.keyButtons) do
        local name, octave = splitNote(value)
        local label
        for key, mapping in pairs(KEY_LAYOUT) do
            if mapping[1] == name and frame.activeOctave + mapping[2] == tonumber(octave) then label = key break end
        end
        button.keyText:SetText(label or "")
    end
end

function Mimorium:CreateKey(frame, value, black, x)
    local button = CreateFrame("Button", nil, frame, "BackdropTemplate")
    button.black = black
    button:SetSize(black and 34 or 49, black and 155 or 238)
    button:SetPoint("BOTTOM", frame, "BOTTOM", x, black and 114 or 66)
    button:SetFrameLevel(frame:GetFrameLevel() + (black and 5 or 2))
    button:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=10, insets={left=2,right=2,top=2,bottom=2} })
    button:SetBackdropBorderColor(0.54, 0.36, 0.12, 1)
    button:SetBackdropColor(black and 0.10 or 0.82, black and 0.07 or 0.73, black and 0.16 or 0.56, 1)
    local noteText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    noteText:SetPoint("BOTTOM", 0, black and 35 or 45); noteText:SetText(value); noteText:SetTextColor(black and 0.94 or 0.22, black and 0.83 or 0.13, black and 0.45 or 0.30)
    button.keyText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.keyText:SetPoint("BOTTOM", 0, 16); button.keyText:SetTextColor(black and 1 or 0.27, black and 0.90 or 0.17, black and 0.52 or 0.36)
    button:SetScript("OnMouseDown", function()
        frame.heldNotes[value] = true; Mimorium:SetKeyActive(value, true); Mimorium:PlayInstrumentNote(value, true)
    end)
    button:SetScript("OnMouseUp", function() frame.heldNotes[value] = nil; Mimorium:SetKeyActive(value, false) end)
    frame.keyButtons[value] = button
end

function Mimorium:CreateInstrumentFrame()
    local frame = CreateFrame("Frame", "MimoriumInstrumentFrame", UIParent, "BackdropTemplate")
    frame:SetSize(1260, 585); frame:SetPoint("CENTER", 0, 30); frame:SetFrameStrata("DIALOG")
    frame:EnableKeyboard(true); frame:EnableMouse(true); frame:Hide()
    frame:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=24, insets={left=12,right=12,top=12,bottom=12} })
    frame:SetBackdropColor(0.13, 0.08, 0.19, 0.98); frame:SetBackdropBorderColor(0.80, 0.60, 0.20, 1)
    frame.keyButtons, frame.heldNotes, frame.pressedKeys, frame.activeOctave = {}, {}, {}, 4
    local header = frame:CreateTexture(nil, "ARTWORK")
    header:SetTexture("Interface\\Buttons\\WHITE8x8"); header:SetSize(1230,112); header:SetPoint("TOP",0,-14); header:SetVertexColor(0.25,0.15,0.36,1)
    local crest = frame:CreateTexture(nil,"OVERLAY")
    crest:SetTexture("Interface\\Icons\\INV_Misc_Gem_Variety_01"); crest:SetSize(44,44); crest:SetPoint("TOP",0,-27)
    frame.title = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge"); frame.title:SetPoint("TOP",crest,"BOTTOM",0,-4)
    local subtitle = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    subtitle:SetPoint("TOP",frame.title,"BOTTOM",0,-6); subtitle:SetText("Freies Spiel im gemeinsamen Mimorium-Musikkanal"); subtitle:SetTextColor(0.94,0.80,0.40)
    local close = CreateFrame("Button",nil,frame,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",-7,-7)
    frame.octaveText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight"); frame.octaveText:SetPoint("TOPLEFT",46,-43)
    local channel = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    channel:SetPoint("TOPRIGHT",-46,-43); channel:SetText("MUSIKKANAL: " .. MUSIC_CHANNEL); channel:SetTextColor(0.94,0.80,0.40)
    local width, first, count = 49, -((22-1)*49)/2, 0
    for octave=3,5 do for _,name in ipairs(WHITE_NAMES) do count=count+1; self:CreateKey(frame,note(name,octave),false,first+(count-1)*width) end end
    count=count+1; self:CreateKey(frame,"C6",false,first+(count-1)*width)
    local whiteOffset=0
    for octave=3,5 do
        for _,name in ipairs(BLACK_NAMES) do
            local before = WHITE_INDEX[name:gsub("b","")] + whiteOffset
            self:CreateKey(frame,note(name,octave),true,first+(before-1)*width+width/2)
        end
        whiteOffset=whiteOffset+7
    end
    local controls = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    controls:SetPoint("BOTTOM",0,31); controls:SetText("A W S E D F T G Y H U J K - LINKS/RECHTS: Oktave wechseln - ESC schliessen"); controls:SetTextColor(0.97,0.86,0.54)
    frame:SetScript("OnKeyDown",function(self,key)
        if key=="ESCAPE" then self:Hide(); return end
        if key=="LEFT" or key=="RIGHT" then self.activeOctave=math.max(3,math.min(5,self.activeOctave+(key=="LEFT" and -1 or 1))); Mimorium:RefreshInstrumentFrame(); return end
        local mapping=KEY_LAYOUT[key]
        if mapping and not self.pressedKeys[key] then
            local value=note(mapping[1],self.activeOctave+mapping[2]); self.pressedKeys[key]=value; self.heldNotes[value]=true; Mimorium:SetKeyActive(value,true); Mimorium:PlayInstrumentNote(value,true)
        end
    end)
    frame:SetScript("OnKeyUp",function(self,key) local value=self.pressedKeys[key]; if value then self.pressedKeys[key]=nil; self.heldNotes[value]=nil; Mimorium:SetKeyActive(value,false) end end)
    frame:SetScript("OnShow",function(self) self:SetPropagateKeyboardInput(false); wipe(self.pressedKeys); Mimorium:EnsureMusicChannel(); Mimorium:RefreshInstrumentFrame() end)
    frame:SetScript("OnHide",function(self) wipe(self.pressedKeys); wipe(self.heldNotes) end)
    self.instrumentFrame = frame
end

function Mimorium:OpenInstrument(instrument)
    self.currentInstrument = INSTRUMENTS[instrument] and instrument or "harp"
    self.instrumentFrame:Show()
    self:RefreshInstrumentFrame()
end

function Mimorium:ToggleInstrumentFrame() self:OpenInstrument(self.currentInstrument or "harp") end

function Mimorium:PlayInstrumentNote(value, broadcast, instrument)
    instrument = instrument or self.currentInstrument or "harp"
    local path = soundPath(instrument, value)
    PlaySoundFile(path,"SFX"); PlaySoundFile(path,"SFX"); PlaySoundFile(path,"SFX")
    if broadcast then
        local channel=self:EnsureMusicChannel()
        if channel and channel>0 then C_ChatInfo.SendAddonMessage(PREFIX,"N:"..instrument..":"..value,"CHANNEL",channel) end
    end
end

function Mimorium:HandleAddonMessage(prefix,message,_,sender)
    if prefix~=PREFIX or Ambiguate(sender,"none")==UnitName("player") then return end
    local instrument,value=message:match("^N:([a-z]+):([A-G][b#]?%d)$")
    if INSTRUMENTS[instrument] and value then self:FlashKey(value); self:PlayInstrumentNote(value,false,instrument) end
end
