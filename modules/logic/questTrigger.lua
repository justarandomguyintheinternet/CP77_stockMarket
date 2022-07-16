trigger = {}

function trigger:new(market)
	local o = {}

    o.market = market
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

function trigger:initialize(data)
    self.name = "quest_" .. data.name
    self.fadeSpeed = data.fade
end

function trigger:decreaseValue()
    if self.exportData.value == 0 then return end
    if self.exportData.value > 0 then
        self.exportData.value = self.exportData.value - self.fadeSpeed
    elseif self.exportData.value < 0 then
        self.exportData.value = 0
    end
end

function trigger:registerObservers() end
function trigger:update() end

return trigger