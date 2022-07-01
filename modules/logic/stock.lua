local lang = require("modules/utils/lang")
local utils = require("modules/utils/utils")

stock = {}

function stock:new(steps, market)
	local o = {}

    o.market = market

    o.steps = steps
    o.name = ""
    o.info = ""

    o.startPrice = 0
    o.sharesAmount = 0
    o.max = 0
    o.min = 0
    o.maxStep = 0
    o.deltaPower = 0
    o.triggers = {}

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
    if #self.exportData.data == 0 then return self.startPrice end
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
    return utils.round(v, 1)
end

function stock:performTransaction(amount)
    self.exportData.owned = self.exportData.owned + amount
    self.market.triggerManager.triggers[self.name]:onTransaction(self, amount)

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
    self.exportData.name = name
    self.name = data.name
    self.info = "stockInfo_" .. data.name
    self.sharesAmount = data.sharesAmount
    self.startPrice = data.startPrice
    self.min = data.min
    self.max = data.max
    self.maxStep = data.maxStepSize

    self.deltaPower = data.smoothOff
    if self.deltaPower and self.deltaPower % 2 == 0 then
        self.deltaPower = self.deltaPower + 1
    end

    self.triggers = data.triggers or {}
    table.insert(self.triggers, self.name)
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
	local steps = self.steps
	for i = 1, steps do
		currentValue = currentValue + self:getStep()
		self.exportData.data[i] = {x = i, y = currentValue}
	end
end

function stock:getMinMaxAdjustment() -- Trying to keep the price in min/max range
    local remaped = utils.remap(self:getCurrentPrice(), self.min, self.max, -1, 1)
    remaped = math.min(math.max(remaped, -1), 1)
    return remaped ^ self.deltaPower
end

function stock:getStep() -- Size of random step
    local rand = (math.random() * 2) - 1
    rand = rand - self:getMinMaxAdjustment()
    rand = rand + self.market.triggerManager:getStockDelta(self)
    rand = rand * self.maxStep
    return rand
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