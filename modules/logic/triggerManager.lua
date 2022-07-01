local lang = require("modules/utils/lang")
local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")

triggerManager = {}

function triggerManager:new(mod, intervall)
	local o = {}

    o.mod = mod
    o.intervall = intervall
    o.triggers = {}

	self.__index = self
   	return setmetatable(o, self)
end

function triggerManager:onInit()
    for _, file in pairs(dir("modules/logic/triggers/")) do
        if file.name:match("^.+(%..+)$") == ".lua" then
            local name = file.name:match("(.+)%..+$")
            print("Loading trigger: " .. file.name)
            local trigger = require("modules/logic/triggers/" .. name):new(self.mod)
            trigger:registerObservers()
            self.triggers[trigger.name] = trigger
        end
    end

    Cron.Every(self.intervall, function ()
        for _, trigger in pairs(self.triggers) do
            trigger:decreaseValue()
        end
    end)
end

function triggerManager:createBuySellTriggers(stocks)
    for _, stock in pairs(stocks) do
        local trigger = require("modules/logic/buySellTrigger.lua"):new(self.mod)
        trigger.name = stock.name
        trigger:registerObservers()
        self.triggers[stock.name] = trigger
    end
end

function triggerManager:getStockDelta(stock)
    local delta = 0

    for _, trigger in pairs(self.triggers) do
        for _, t in pairs(stock.triggers) do
            if t.name == trigger.name then
                delta = delta + trigger.exportData.value * t.mult
            end
        end
    end

    delta = delta + self.triggers[stock.name].exportData.value
    return delta
end

function triggerManager:update()
    for _, trigger in pairs(self.triggers) do
        trigger:update()
    end
end

return triggerManager