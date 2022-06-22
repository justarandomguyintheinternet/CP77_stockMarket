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
        cetOpen = false,
        time = 0
    },
    intervall = 30,
    config = require("modules/utils/config"),
    browser = require("modules/ui/browser"),
    debug = require("debug/ui/baseUI")
}

function stocks:new()
    registerForEvent("onInit", function()
        math.randomseed(os.clock()) -- Prevent predictable random() behavior

        local triggerManager = require("modules/logic/triggerManager"):new()
        self.market = require("modules/logic/stockMarket"):new(self.intervall, triggerManager)
        self.market.triggerManager:onInit()
        self.market:setupPersistency()
        self.market:initialize()
        self.market:checkForData()

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            self.runtimeData.inGame = true
            self.runtimeData.time = Game.GetTimeSystem():GetGameTime():Hours()
            self.market:checkForData()
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
        end)

        self.runtimeData.inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods
        if self.runtimeData.inGame then
            self.runtimeData.time = Game.GetTimeSystem():GetGameTime():Hours()
        end
        self.browser.init(self)
    end)

    registerForEvent("onShutdown", function()

    end)

    registerForEvent("onUpdate", function(dt)
        if not self.runtimeData.inMenu and self.runtimeData.inGame then
            if Game.GetTimeSystem():GetGameTime():Hours() - self.runtimeData.time > 0 and Game.GetTimeSystem():GetGameTime():Minutes() ~= 0 then
                local diff = Game.GetTimeSystem():GetGameTime():Hours() - self.runtimeData.time
                for i = 0, diff * (7 * (60/self.intervall)) do
                    self.market:update()
                    Cron.Update(dt * 5000)
                end
            end
            self.runtimeData.time = Game.GetTimeSystem():GetGameTime():Hours()

            Cron.Update(dt)
            self.market.triggerManager:update()
        end
    end)

    registerForEvent("onDraw", function()
        if not self.runtimeData.cetOpen then return end
        self.debug:draw(self)
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