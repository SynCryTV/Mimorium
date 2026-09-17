local _, Mimorium = ...

function Mimorium:RegisterSlashCommands()
    SLASH_MIMORIUM1 = "/mimorium"
    SLASH_MIMORIUM2 = "/mimo"

    SlashCmdList.MIMORIUM = function(message)
        if message:lower():match("^%s*minimap%s*$") then
            Mimorium:ToggleMinimapButton()
            return
        end

        Mimorium:ToggleFrame()
    end
end
