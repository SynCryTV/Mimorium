local _, Mimorium = ...

function Mimorium:RegisterSlashCommands()
    SLASH_MIMORIUM1 = "/mimorium"
    SLASH_MIMORIUM2 = "/mimo"

    SlashCmdList.MIMORIUM = function()
        Mimorium:ToggleFrame()
    end
end

