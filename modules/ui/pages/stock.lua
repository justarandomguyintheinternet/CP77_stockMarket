local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")

info = {}

function info:new(inkPage, controller, eventCatcher)
	local o = {}

    o.inkPage = inkPage
	o.controller = controller
	o.eventCatcher = eventCatcher
	o.pageName = "stockInfo"

	o.canvas = nil

	o.stock = nil
	o.buySellVolume = 0

	self.__index = self
   	return setmetatable(o, self)
end

function info:initialize(stock)
	self.buySellVolume = 0
	self.stock = stock
	self.canvas = ink.canvas(0, 0, inkEAnchor.TopLeft)
	self.canvas:Reparent(self.inkPage, -1)

	self.buttons = require("modules/ui/pages/menuButtons").createMenu(self)

	local graph = require("modules/ui/widgets/graph"):new(55, 300, 2000, 1000, 10, 5, lang.getText(lang.graph_time), lang.getText(lang.graph_value), 5, 50, color.darkcyan, 0.3)
	graph:initialize(self.canvas)

	local currentValue = 200
	local points = {}
	local steps = 50
	for i = 1, steps do
		currentValue = currentValue + (1 - (math.random() * 2))
		points[i] = {x = i, y = currentValue}
	end
	graph.data = points
	graph:showData()

	self:setupInfo()
	self:setupBuySell(2600, 750)
	self:showData()
end

function info:setupInfo()
	self.title = ink.canvas(2100, 260, inkEAnchor.Centered)
	self.title:Reparent(self.canvas, -1)

	self.stockName = ink.text(self.stock.name .. ":", 0, 0, 130)
	self.stockName:SetAnchorPoint(0, 0)
	self.stockName:Reparent(self.title, -1)
	self.nameLine = ink.line(0, 135, 450, 135, color.white, 8)
	self.nameLine:Reparent(self.title, -1)

	self.shortInfo = ink.canvas(2100, 420, inkEAnchor.Centered)
	self.shortInfo:Reparent(self.canvas, -1)

	self.stockValue = ink.text("", 0, 0, 75, color.white)
	self.stockValue:Reparent(self.shortInfo, -1)
	self.stockTrend = ink.text("", 600, 0, 75, color.white)
	self.stockTrend:Reparent(self.shortInfo, -1)

	self.portfolio = ink.text("", 0, 100, 75, color.white)
	self.portfolio:Reparent(self.shortInfo, -1)

	self.infoLine = ink.line(0, 210, 700, 210, color.gray, 3)
	self.infoLine:Reparent(self.shortInfo, -1)
end

function info:showData()
	self.stockValue:SetText(tostring(lang.getText(lang.info_value) .. ": " .. self.stock:getCurrentPrice() .. " E$"))

	local trend = self.stock:getTrend()
    local c = color.red
    if trend > 0 then
        c = color.lime
        trend = tostring("+" .. trend)
    end
    self.stockTrend:SetText(tostring(trend .. "%"))
	self.stockTrend:SetTintColor(c)

	self.portfolio:SetText(tostring(lang.getText(lang.info_owned) .. ": " .. self.stock:getPortfolioNum() .. " / " .. (self.stock:getPortfolioNum() * self.stock:getCurrentPrice()) .. " E$"))
end

function info:getBuySellOptions()
	local xSize = 850
	local ySize = 140
	local bgColor = color.darkgray
	local textSize = 70
	local borderSize = 3
	local textColor = color.white

	return xSize, ySize, bgColor, textSize, borderSize, textColor
end

function info:setupBuySell(x, y)
	local xSize, ySize, bgColor, textSize, _, textColor = self:getBuySellOptions()

	local canvas = ink.canvas(x, y, inkEAnchor.Centered)
	canvas:Reparent(self.canvas, -1)

	local bg = ink.rect(0, 0, xSize, ySize, bgColor, 0)
	bg:SetAnchorPoint(0.5, 0.5)
	bg:Reparent(canvas, -1)

	local middleText = ink.text(tostring(self.buySellVolume), 0, 0, textSize, textColor)
	middleText:SetAnchorPoint(0.5, 0.5)
	middleText:Reparent(canvas, -1)

	local plusOne = self:setupVolumeButton(xSize / 2 - ySize * 2, 0, 1, middleText)
	plusOne.canvas:Reparent(canvas, -1)
	local plusFive = self:setupVolumeButton(xSize / 2 - ySize, 0, 5, middleText)
	plusFive.canvas:Reparent(canvas, -1)
	local plusTen = self:setupVolumeButton(xSize / 2, 0, 10, middleText)
	plusTen.canvas:Reparent(canvas, -1)

	local minusOne = self:setupVolumeButton(- xSize / 2 + ySize * 2, 0, -1, middleText)
	minusOne.canvas:Reparent(canvas, -1)
	local minusFive = self:setupVolumeButton(- xSize / 2 + ySize, 0, -5, middleText)
	minusFive.canvas:Reparent(canvas, -1)
	local minusTen = self:setupVolumeButton(- xSize / 2, 0, -10, middleText)
	minusTen.canvas:Reparent(canvas, -1)
end

function info:setupVolumeButton(x, y, amount, textWidget)
	local _, ySize, _, textSize, borderSize, textColor = self:getBuySellOptions()

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
	button.fillColor = color.darkred
	button.bgColor = color.darkcyan
	button.textColor = textColor
	button.callback = function()
		self.buySellVolume = self.buySellVolume + amount
		textWidget:SetText(tostring(self.buySellVolume))
	end
	button:initialize()
	button:registerCallbacks(self.eventCatcher)

	return button
end

function info:uninitialize()
	if not self.canvas then return end
	self.eventCatcher.removeSubscriber(self.button)
	self.inkPage:RemoveChild(self.canvas)
	self.inkPage:RemoveChild(self.buttons)
	self.canvas = nil
end

return info