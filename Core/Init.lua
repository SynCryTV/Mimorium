local addonName, Mimorium = ...

Mimorium.name = addonName
Mimorium.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "dev"

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, _, loadedAddon)
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
    self:RegisterSlashCommands()
end

function Mimorium:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffc084fcMimorium|r: " .. message)
end
