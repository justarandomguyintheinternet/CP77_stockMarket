local lang = require("modules/utils/lang")
local utils = require("modules/utils/utils")

stock = {}

function stock:new(steps)
	local o = {}

    o.steps = steps

    o.name = ""
    o.startPrice = 0
    o.sharesAmount = 0
    o.exportData = {}
    o.default = {
        name = "",
        owned = 0,
        spent = 0,
        data = {}
    }

	self.__index = self
   	return setmetatable(o, self)
end

function stock:getCurrentPrice()
    return utils.round(self.exportData.data[#self.exportData.data].y, 1)
end

function stock:getTrend()
    -- TODO: Change to avg of last 1/2 of data
    local percent = 100 * (self:getCurrentPrice() - self.exportData.data[#self.exportData.data  - 5].y) / self.exportData.data[#self.exportData.data  - 5].y
    return utils.round(percent, 1)
end

function stock:getPortfolioNum()
    return self.exportData.owned
end

function stock:getProfit(amount)
    local v = (amount * (self.exportData.spent / (self.exportData.owned))) - (self:getCurrentPrice() * amount)
    if amount == 0 then v = 0 end
    return v
end

function stock:performTransaction(amount)
    self.exportData.owned = self.exportData.owned + amount
    if amount > 0 then
        utils.spendMoney(amount * self:getCurrentPrice())
        self.exportData.spent = self.exportData.spent + amount * self:getCurrentPrice()
    else
        Game.AddToInventory("Items.money", math.abs(amount * self:getCurrentPrice()))
        amount = math.abs(amount)
        self.exportData.spent = self.exportData.spent - (amount * (self.exportData.spent / (amount + self.exportData.owned)))
    end
end

function stock:loadFromDefinition(data) -- Load from json file
    self.name = data.name
    self.sharesAmount = data.sharesAmount
    self.startPrice = data.startPrice
    self.exportData.name = name
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

    -- Generate some initial data
    local currentValue = self.startPrice
	local points = {}
	local steps = self.steps
	for i = 1, steps do
		currentValue = currentValue + self:getStep()
		points[i] = {x = i, y = currentValue}
	end

    self.exportData.data = points
end

function stock:getStep()
    return (4 - (math.random() * 8))
end

function stock:update() -- Runs every intervall
    local shift = {}
    for i = 2, #self.exportData.data do -- Shift table, to remove first element
        local v = self.exportData.data[i]
        v.x = v.x - 1
        shift[i - 1] = v
    end

    local value = shift[#shift].y + self:getStep() -- Calc new value
    shift[#shift + 1] = {x = #shift + 1, y = value}
    self.exportData.data = shift
end

return stock