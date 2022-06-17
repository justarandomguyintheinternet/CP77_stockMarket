local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")

trigger = {}

function trigger:new()
	local o = {}

    -- Default data
    o.name = "Arasaka"
    o.fadeSpeed = 0.01
    o.exportData = {
        name = o.name,
        value = 0
    }

	self.__index = self
   	return setmetatable(o, self)
end

function trigger:initialize() -- Clear data, load data from file
    print("Trigger \"" .. self.name .. "\" init...")
end

function trigger:registerObservers() -- Gets called once onInit
    print("Trigger \"" .. self.name .. "\" registering observers...")
end

function trigger:update() -- Gets called onUpdate

end

return trigger