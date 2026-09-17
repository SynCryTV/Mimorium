local addonName, Mimorium = ...

Mimorium.name = addonName
Mimorium.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "dev"

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "CHAT_MSG_ADDON" then
        Mimorium:HandleAddonMessage(...)
        return
    end

    local loadedAddon = ...
    if loadedAddon ~= addonName then
        return
    end

    MimoriumDB = MimoriumDB or {}
    MimoriumCharDB = MimoriumCharDB or {}
    Mimorium:Initialize()
end)

function Mimorium:Initialize()
    self:CreateMainFrame()
    self:CreateMinimapButton()
    self:InitializeInstruments()
    self:RegisterSlashCommands()
end

function Mimorium:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffc084fcMimorium|r: " .. message)
end
