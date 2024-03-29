local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")

info = {}

function info:new(inkPage, controller, eventCatcher, mod)
	local o = {}

	o.mod = mod
    o.inkPage = inkPage
	o.controller = controller
	o.eventCatcher = eventCatcher
	o.pageName = "stockInfo"

	o.canvas = nil
	o.refreshCron = nil

	o.stock = nil
	o.buySellVolume = 0

	self.__index = self
   	return setmetatable(o, self)
end

function info:initialize(stock)
	self.refreshCron = Cron.Every(2, function ()
		self:refresh()
	end)

	self.buySellVolume = 0
	self.stock = stock
	self.canvas = ink.canvas(0, -70, inkEAnchor.TopLeft)
	self.canvas:Reparent(self.inkPage, -1)

	self.buttons = require("modules/ui/pages/menuButtons").createMenu(self)

	self.graph = require("modules/ui/widgets/graph"):new(55, 300, 2000, 1000, 10, 5, lang.getText(lang.graph_time), lang.getText(lang.graph_value), 5, 50, color.darkcyan, 0.1)
	self.graph.intervall = self.mod.intervall
	self.graph:initialize(self.canvas)
	self.graph.data = self.stock.exportData.data
	self.graph:showData()

	self:setupInfo()
	self:setupBuySell(2600, 750)
	self:showData()
end

function info:setupInfo() -- Basic info section
	self.title = ink.canvas(2100, 260, inkEAnchor.Centered)
	self.title:Reparent(self.canvas, -1)

	self.stockName = ink.text(self.stock.name .. ":", 0, 0, 130)
	self.stockName:SetAnchorPoint(0, 0)
	self.stockName:Reparent(self.title, -1)
	self.nameLine = ink.line(0, 135, 450, 135, color.white, 8)
	self.nameLine:Reparent(self.title, -1)

	Cron.NextTick(function ()
		ink.updateLine(self.nameLine, 0, 135, self.stockName:GetDesiredWidth(), 135)
	end)

	self.shortInfo = ink.canvas(2100, 420, inkEAnchor.Centered)
	self.shortInfo:Reparent(self.canvas, -1)

	self.stockValue = ink.text("", 0, 0, 75, color.white)
	self.stockValue:Reparent(self.shortInfo, -1)
	self.stockTrend = ink.text("", 835, 0, 75, color.white)
	self.stockTrend:Reparent(self.shortInfo, -1)

	self.portfolio = ink.text("", 0, 100, 75, color.white)
	self.portfolio:Reparent(self.shortInfo, -1)
	self.portfolioTrend = ink.text("", 835, 100, 75, color.white)
	self.portfolioTrend:Reparent(self.shortInfo, -1)

	self.infoLine = ink.line(0, 210, 1000, 210, color.gray, 3)
	self.infoLine:Reparent(self.shortInfo, -1)
end

function info:showData() -- Update data
	-- Stock value
	self.stockValue:SetText(tostring(lang.getText(lang.info_value) .. ": " .. self.stock:getCurrentPrice() .. " E$"))

	-- Stock trend
	local trend = self.stock:getTrend()
    local c = color.red
    if trend > 0 then
        c = color.lime
        trend = tostring("+" .. trend)
    end
    self.stockTrend:SetText(tostring(trend .. "%"))
	self.stockTrend:SetTintColor(c)

	-- Stocks in portfolio
	self.portfolio:SetText(tostring(lang.getText(lang.info_owned) .. ": " .. self.stock:getPortfolioNum() .. " / " .. (self.stock:getPortfolioNum() * self.stock:getCurrentPrice()) .. " E$"))
	-- Portfolio trend
	local trend = self.stock:getProfit(-self.stock:getPortfolioNum()) / self.stock.exportData.spent
	if self.stock.exportData.spent == 0 then trend = 0 end

	trend = utils.round(trend * 100, 1)
    local c = color.red
    if trend >= 0 then
        c = color.lime
        trend = tostring("+" .. trend)
    end
    self.portfolioTrend:SetText(tostring(trend .. "%"))
	self.portfolioTrend:SetTintColor(c)

	-- Stock volume buttons text
	self.middle.textWidget:SetText(tostring(self.buySellVolume))
	-- Account balance / Margin
	local text = tostring(lang.getText(lang.info_post_portfolio) .. ": " .. (Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money()) - (self.buySellVolume * self.stock:getCurrentPrice())) .. "E$")
	if self.buySellVolume <= 0 then
		text = lang.getText(lang.info_margin) .. ": " .. self.stock:getProfit(self.buySellVolume) .. "E$"
	end
	self.accountText:SetText(text)
	-- Transaction cost
	local transCost = tostring(math.abs(self.buySellVolume * self.stock:getCurrentPrice()) .. "E$")
	local locText = lang.getText(lang.info_transaction) .. ": "
	if self.buySellVolume < 0 then
		self.transText:SetText(tostring(locText .. "+" .. transCost))
		self.transText:SetTintColor(color.lime)
		self.mainButton.textWidget:SetText(lang.getText(lang.info_sell))
	elseif self.buySellVolume > 0 then
		self.transText:SetText(tostring(locText .. "-" .. transCost))
		self.transText:SetTintColor(color.red)
		self.mainButton.textWidget:SetText(lang.getText(lang.info_buy))
	else
		self.transText:SetText(tostring(locText .. "0E$"))
		self.transText:SetTintColor(color.white)
	end
end

function info:getBuySellOptions() -- Visual params
	local xSize = 850
	local ySize = 140
	local textSize = 70
	local borderSize = 3
	local textColor = color.white

	return xSize, ySize, textSize, borderSize, textColor
end

function info:setupBuySell(x, y) -- Buy sell section
	local xSize, ySize, textSize, _, textColor = self:getBuySellOptions()

	local canvas = ink.canvas(x, y, inkEAnchor.Centered)
	canvas:Reparent(self.canvas, -1)

	local plusOne = self:setupVolumeButton(xSize / 2 - ySize * 2, 0, 1)
	plusOne.canvas:Reparent(canvas, -1)
	local plusFive = self:setupVolumeButton(xSize / 2 - ySize, 0, 5)
	plusFive.canvas:Reparent(canvas, -1)
	local plusTen = self:setupVolumeButton(xSize / 2, 0, 25)
	plusTen.canvas:Reparent(canvas, -1)

	self.middle = self:setupVolumeButton(0, 0, 0)
	self.middle.canvas:Reparent(canvas, -1)
	self.middle.callback = function () end
	self.middle.hoverInCallback = function () end
	self.middle.hoverOutCallback = function () end
	self.middle.bg:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
	self.middle.textWidget:SetText(tostring(self.buySellVolume))

	local minusOne = self:setupVolumeButton(- xSize / 2 + ySize * 2, 0, -1)
	minusOne.canvas:Reparent(canvas, -1)
	local minusFive = self:setupVolumeButton(- xSize / 2 + ySize, 0, -5)
	minusFive.canvas:Reparent(canvas, -1)
	local minusTen = self:setupVolumeButton(- xSize / 2, 0, -25)
	minusTen.canvas:Reparent(canvas, -1)

	self.transText = ink.text(tostring(lang.getText(lang.info_transaction) .. ": 0E$"), -500, 100, textSize, textColor)
	self.transText:SetAnchorPoint(0, 0)
	self.transText:Reparent(canvas, -1)

	self.accountText = ink.text("", -500, 190, textSize, textColor)
	self.accountText:SetAnchorPoint(0, 0)
	self.accountText:Reparent(canvas, -1)

	self.mainButton = require("modules/ui/widgets/button"):new(0, 420, 650, 200, 5, lang.getText(lang.info_buy), 80, color.white, color.black, color.white)
	self.mainButton.callback = function()
		if self.buySellVolume == 0 then return end
		self.stock:performTransaction(self.buySellVolume)
		self.buySellVolume = 0
		self:showData()
	end

	self.mainButton.hoverInCallback = function (bt)
		bt.fill:SetOpacity(0.9)
	end

	self.mainButton:initialize()
	self.mainButton:registerCallbacks(self.eventCatcher)
	self.mainButton.canvas:Reparent(canvas, -1)
end

function info:calculateBuySellAmount(baseAmount) -- Adjust base amount for stock price and player money
	if math.abs(baseAmount) == 1 then return baseAmount end

	local factor = 200 -- Higher means higher amounts

	if baseAmount < 0 and self.stock:getPortfolioNum() ~= 0 then
		amount = self.stock:getPortfolioNum() / (factor / baseAmount)
	else
		amount = Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money()) / self.stock:getCurrentPrice() / (factor / baseAmount)
	end

	if baseAmount < 0 then
		return math.min(math.floor((amount / 5) + 0.5) * 5, baseAmount)
	end

	return math.max(math.floor((amount / 5) + 0.5) * 5, baseAmount)
end

function info:setupVolumeButton(x, y, amount) -- Button to change buy/sell amount
	local _, ySize, textSize, borderSize, textColor = self:getBuySellOptions()

	amount = self:calculateBuySellAmount(amount)

	local button = require("modules/ui/widgets/button"):new()
	button.x = x
	button.y = y
	button.sizeX = ySize
	button.sizeY = ySize
	button.textSize = textSize
	local text = tostring(amount)
	if amount > 0 then
		text = tostring("+" .. amount)
	end
	button.text = text
	button.borderSize = borderSize
	button.fillColor = color.black
	button.bgColor = color.white
	button.textColor = textColor
	button.callback = function()
		self.buySellVolume = self.buySellVolume + amount
		if - self.buySellVolume > self.stock:getPortfolioNum() then
			self.buySellVolume = -self.stock:getPortfolioNum()
			if self.buySellVolume == -0 then self.buySellVolume = 0 end
		elseif (Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money()) - (self.buySellVolume * self.stock:getCurrentPrice())) < 0 then
			self.buySellVolume = self.buySellVolume - amount
		end
		self:showData()
	end
	button.hoverInCallback = function (bt)
		bt.fill:SetOpacity(0.9)
	end
	button:initialize()
	button:registerCallbacks(self.eventCatcher)

	return button
end

function info:refresh()
	self:showData()
	self.graph.data = self.stock.exportData.data
	self.graph:showData()
end

function info:uninitialize()
	Cron.Halt(self.refreshCron)
	if not self.canvas then return end
	self.eventCatcher.removeSubscriber(self.button)
	self.inkPage:RemoveChild(self.canvas)
	self.inkPage:RemoveChild(self.buttons)
	self.canvas = nil
end

return info