local lang = require("modules/utils/lang")

stock = {}

function stock:new()
	local o = {}

    o.name = ""
    o.startPrice = 0
    o.exportData = {}
    o.default = {
        name = "",
        owned = 0,
        data = {}
    }

	self.__index = self
   	return setmetatable(o, self)
end

function stock:getCurrentPrice()
    return math.floor(self.exportData.data[#self.exportData.data].y)
end

function stock:getTrend()
    return 3.2
end

function stock:getPortfolioNum()
    return self.exportData.owned
end

function stock:performTransaction(amount)
    self.exportData.owned = self.exportData.owned + amount
end

function stock:loadFromDefinition(data) -- Load from json file
    self.name = data.name
    self.exportData.name = name
    self.startPrice = data.startPrice
end

function stock:checkForData(data)
    if data["stocks"][self.name] == nil then
        self:loadDefault()
        data["stocks"][self.name] = self.exportData
    else
        self.exportData = data["stocks"][self.name]
    end

    -- Fix wrong order
    local points = {}
    for _, v in pairs(self.exportData.data) do
        points[#points + 1] = v
    end
    table.sort(points, function(a, b)
        return a.x < b.x
    end)
    self.exportData.data = points
end

function stock:loadDefault()
    self.exportData = self.default

    local currentValue = self.startPrice
	local points = {}
	local steps = 150
	for i = 1, steps do
		currentValue = currentValue + (4 - (math.random() * 8))
		points[i] = {x = i, y = currentValue}
	end

    self.exportData.data = points
end

function stock:update() -- Runs every intervall
    local shift = {}
    for i = 2, #self.exportData.data do
        local v = self.exportData.data[i]
        v.x = v.x - 1
        shift[i - 1] = v
    end

    local value = shift[#shift].y + (1 - (math.random() * 2))

    shift[#shift + 1] = {x = #shift + 1, y = value}
    self.exportData.data = shift
end

return stock