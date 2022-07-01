local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")

trigger = {}

function trigger:new()
	local o = {}

    -- Default data
    o.name = ""
    o.fadeSpeed = 0.01
    o.exportData = {
        value = 0
    }

	self.__index = self
   	return setmetatable(o, self)
end

function trigger:checkForData(data)
    if data["triggers"][self.name] == nil then
        data["triggers"][self.name] = self.exportData
    else
        self.exportData = data["triggers"][self.name]
    end
end

function trigger:onTransaction(stock, amount)
    local price = stock:getCurrentPrice()
    local totalValue = price * stock.sharesAmount
    local percent = 8 * ((math.abs(amount) * price) / totalValue)
    if amount > 0 then
        self.exportData.value = self.exportData.value + percent
    else
        self.exportData.value = self.exportData.value - percent
    end
end

function trigger:decreaseValue()
    if self.exportData.value > 0 then
        self.exportData.value = self.exportData.value - self.fadeSpeed
    elseif self.exportData.value < 0 then
        self.exportData.value = self.exportData.value + self.fadeSpeed
    end
end

function trigger:registerObservers() -- Gets called once onInit
    print("Trigger \"" .. self.name .. "\" registering observers...")
end

function trigger:update() -- Gets called onUpdate

end

return trigger