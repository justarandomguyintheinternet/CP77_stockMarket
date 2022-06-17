local lang = require("modules/utils/lang")
local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")

triggerManager = {}

function triggerManager:new(mod)
	local o = {}

    o.mod = mod
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
            table.insert(self.triggers, trigger)
        end
    end
end

function triggerManager:initialize()
    for _, trigger in pairs(self.triggers) do
        trigger:initialize()
    end
end

function triggerManager:update()
    for _, trigger in pairs(self.triggers) do
        trigger:update()
    end
end

return triggerManager