local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")
local UIScroller = require("modules/external/UIScroller")

portfolio = {}

function portfolio:new(inkPage, controller, eventCatcher, mod)
	local o = {}

	o.mod = mod
    o.inkPage = inkPage
	o.controller = controller
	o.eventCatcher = eventCatcher
	o.pageName = "stocks"

	o.canvas = nil
	o.refreshCron = nil
	o.previews = {}
	o.sort = "ascAlpha"
	o.sortButtons = {}

	self.__index = self
   	return setmetatable(o, self)
end

function portfolio:initialize()
	self.refreshCron = Cron.Every(5, function ()
		self:refresh()
	end)

	self.canvas = ink.canvas(0, 0, inkEAnchor.TopLeft)
	self.canvas:Reparent(self.inkPage, -1)

	self.buttons = require("modules/ui/pages/menuButtons").createMenu(self)

	self.graph = require("modules/ui/widgets/graph"):new(2110, 720, 1000, 550, 5, 3, "", "", 4, 25, color.darkcyan, 0.3)
	self.graph:initialize(self.canvas)
	self.graph.canvas:SetVisible(false)

	local line = ink.line(2120, 650, 3080, 650, color.white, 3)
	line:Reparent(self.canvas, -1)

	self:setupInfo()
	self:setupScrollArea()
	self:setupSortButtons()
	self:setStocks()
end

function portfolio:setupInfo()
	self.info = ink.canvas(100, 300, inkEAnchor.Centered)
	self.info:SetVisible(false)
	self.info:Reparent(self.canvas, -1)

	self.infoName = ink.text("", 0, 0, 120, color.white)
	self.infoName:Reparent(self.info, -1)

	local line = ink.line(0, 130, 500, 130, color.white, 5)
	line:Reparent(self.info, -1)

	self.infoText = ink.text("", 0, 150, 50, color.white)
	self.infoText:Reparent(self.info, -1)
end

function portfolio:setStocks()
	local stocks = {}
	for key, stock in pairs(self.mod.market.stocks) do
		if key ~= "market" then
			table.insert(stocks, stock)
		end
	end

	local sortFunc = nil
	if self.sort == "ascAlpha" then
		sortFunc = function(a, b) return a.name < b.name end
	elseif self.sort == "desAlpha" then
		sortFunc = function(a, b) return a.name > b.name end
	elseif self.sort == "ascPercent" then
		sortFunc = function(a, b) return a:getTrend() < b:getTrend() end
	elseif self.sort == "desPercent" then
		sortFunc = function(a, b) return a:getTrend() > b:getTrend() end
	elseif self.sort == "ascValue" then
		sortFunc = function(a, b) return a:getCurrentPrice() < b:getCurrentPrice() end
	elseif self.sort == "desValue" then
		sortFunc = function(a, b) return a:getCurrentPrice() > b:getCurrentPrice() end
	end

	table.sort(stocks, sortFunc)

	for k, button in pairs(self.previews) do
		button.stock = stocks[k]
		button:showData()
	end

	for key, button in pairs(self.sortButtons) do
		if key ~= self.sort then
			button.bg:SetTintColor(color.darkcyan)
		else
			button.bg:SetTintColor(color.cyan)
		end
	end
end

function portfolio:setupSortButtons()
	local canvas = ink.canvas(2400, 350, inkEAnchor.Centered)
	canvas:Reparent(self.canvas, -1)

	self:setupSortButton(canvas, 0, 0, lang.getText(lang.stocks_ascending) .. " ABC", "ascAlpha")
	self:setupSortButton(canvas, 420, 0, lang.getText(lang.stocks_descending) .. " ABC", "desAlpha")
	self:setupSortButton(canvas, 0, 110, lang.getText(lang.stocks_ascending) .. " %", "ascPercent")
	self:setupSortButton(canvas, 420, 110, lang.getText(lang.stocks_descending) .. " %", "desPercent")
	self:setupSortButton(canvas, 0, 220, lang.getText(lang.stocks_ascending) .. " E$", "ascValue")
	self:setupSortButton(canvas, 420, 220, lang.getText(lang.stocks_descending) .. " E$", "desValue")
end

function portfolio:setupSortButton(canvas, x, y, name, sort)
	local xSize = 400
	local ySize = 100
	local border = 3

	local sButton = require("modules/ui/widgets/button"):new(x, y, xSize, ySize, border, name, 45, color.darkcyan, color.darkred, color.white, function ()
		self.sort = sort
		self:setStocks()
	end)
	sButton:initialize()
	sButton:registerCallbacks(self.eventCatcher)
	sButton.canvas:Reparent(canvas, -1)

	if self.sort == sort then
		sButton.bg:SetTintColor(color.cyan)
	end

	self.sortButtons[sort] = sButton
end

function portfolio:setupScrollArea()
	local scrollComponent = UIScroller.Create()

	local scrollPanel = scrollComponent:GetRootWidget()
	scrollPanel:SetAnchor(inkEAnchor.TopLeft)
	scrollPanel:SetMargin(inkMargin.new({ left = 1020.0, top = 300 }))
	scrollPanel:SetSize(Vector2.new({ X = 1050.0, Y = 1000.0 }))
	scrollPanel:Reparent(self.canvas, -1)

	local scrollContent = scrollComponent:GetContentWidget()

	local buttonList = inkVerticalPanel.new()
	buttonList:SetName('list')
	buttonList:SetPadding(inkMargin.new({ left = 32.0, top = 20.0, right = 32.0 }))
	buttonList:SetChildMargin(inkMargin.new({ top = 66.0, bottom = 66.0 }))
	buttonList:SetFitToContent(true)
	buttonList:Reparent(scrollContent, -1)

	Cron.NextTick(function()
		scrollComponent:UpdateContent(true)
	end)

	local basePos = {x = 500, y = 50}

	for i = 0, self.mod.market:getNumberStocks() - 1 do
		local preview = self:createPreviewButton(basePos.x, basePos.y)
		preview.canvas:Reparent(buttonList, -1)
	end
end

function portfolio:createPreviewButton(x, y, stock)
	local button = require("modules/ui/widgets/stockPreview"):new(self)
	button.x = x
	button.y = y
	button.sizeX = 1000
	button.sizeY = 170
	button.textSize = 80
	button.borderSize = 8
	button.fillColor = color.darkred
	button.bgColor = color.darkcyan
	button.textColor = color.white
	button.stock = stock
	button:initialize()
	button:registerCallbacks(self.eventCatcher)
	table.insert(self.previews, button)

	button.hoverInCallback = function (bt)
		bt.fill:SetOpacity(0.6)
		self.graph.canvas:SetVisible(true)
		self.graph.data = bt.stock.exportData.data
		self.graph:showData()

		self.infoName:SetText(bt.stock.name)
		self.infoText:SetText(utils.wrap(bt.stock.info, 30))
		self.info:SetVisible(true)
	end
	button.hoverOutCallback = function (bt)
		bt.fill:SetOpacity(1)
		self.graph.canvas:SetVisible(false)
		self.info:SetVisible(false)
	end

	return button
end

function portfolio:refresh()
	self:setStocks()
	for _, p in pairs(self.previews) do
		p:showData()
	end
end

function portfolio:uninitialize()
	Cron.Halt(self.refreshCron)

	if not self.canvas then return end
	self.previews = {}
	self.sortButtons = {}
	self.eventCatcher.removeSubscriber(self.button)
	self.inkPage:RemoveChild(self.canvas)
	self.inkPage:RemoveChild(self.buttons)
	self.canvas = nil
end

return stocks