-------------------------------------------------------------------------------------------------------------------------------
-- This mod was created by keanuWheeze from CP2077 Modding Tools Discord.
--
-- You are free to use this mod as long as you follow the following license guidelines:
--    * It may not be uploaded to any other site without my express permission.
--    * Using any code contained herein in another mod requires credits / asking me.
--    * You may not fork this code and make your own competing version of this mod available for download without my permission.
-------------------------------------------------------------------------------------------------------------------------------

local GameUI = require("modules/external/GameUI")
local Cron = require("modules/external/Cron")

stocks = {
    runtimeData = {
        inMenu = false,
        inGame = false,
        cetOpen = false
    },
    config = require("modules/utils/config"),
    browser = require("modules/ui/browser")
}

function stocks:new()
    registerForEvent("onInit", function()
        math.randomseed(os.clock()) -- Prevent predictable random() behavior

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            self.runtimeData.inGame = true
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
        end)

        self.runtimeData.inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods
        self.browser.init()
    end)

    registerForEvent("onShutdown", function()

    end)

    registerForEvent("onUpdate", function(dt)
        if not self.runtimeData.inMenu and self.runtimeData.inGame then
            Cron.Update(dt)
        end
    end)

    registerForEvent("onDraw", function()
        if not self.runtimeData.cetOpen then return end
    end)

    registerForEvent("onOverlayOpen", function()
        self.runtimeData.cetOpen = true
    end)

    registerForEvent("onOverlayClose", function()
        self.runtimeData.cetOpen = false
    end)

    return self
end

return stocks:new()