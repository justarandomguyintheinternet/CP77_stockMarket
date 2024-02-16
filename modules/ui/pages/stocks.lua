local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")
local UIScroller = require("modules/external/UIScroller")

stocks = {}

function stocks:new(inkPage, controller, eventCatcher, mod)
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

function stocks:initialize()
	self.refreshCron = Cron.Every(5, function ()
		self:refresh()
	end)

	self.canvas = ink.canvas(0, -70, inkEAnchor.TopLeft)
	self.canvas:Reparent(self.inkPage, -1)

	self.buttons = require("modules/ui/pages/menuButtons").createMenu(self)

	self.graph = require("modules/ui/widgets/graph"):new(2110, 720, 1000, 550, 5, 3, "", "", 4, 25, color.darkcyan, 0.1)
	self.graph.intervall = self.mod.intervall
	self.graph:initialize(self.canvas)
	self.graph.canvas:SetVisible(false)

	local line = ink.line(2120, 650, 3080, 650, color.white, 3)
	line:Reparent(self.canvas, -1)

	self:setupInfo()
	self:setupScrollArea()
	self:setupSortButtons()
	self:setStocks()
end

function stocks:setupInfo()
	self.info = ink.canvas(100, 300, inkEAnchor.Centered)
	self.info:SetVisible(false)
	self.info:Reparent(self.canvas, -1)

	self.infoName = ink.text("", 0, 0, 120, color.white)
	self.infoName:Reparent(self.info, -1)

	self.infoLine = ink.line(0, 130, 500, 130, color.white, 5)
	self.infoLine:Reparent(self.info, -1)

	self.infoText = ink.text("", 0, 150, 50, color.white)
	self.infoText:Reparent(self.info, -1)
end

function stocks:setStocks()
	local stocks = {}
	for _, stock in pairs(self.mod.market.stocks) do
		table.insert(stocks, stock)
	end

	table.insert(stocks, self.mod.market.marketStock)

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
			button.fg.image:SetTintColor(color.white)
		else
			button.fg.image:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		end
	end
end

function stocks:setupSortButtons()
	local canvas = ink.canvas(2400, 350, inkEAnchor.Centered)
	canvas:Reparent(self.canvas, -1)

	self:setupSortButton(canvas, 0, 0, "ABC", "ascAlpha")
	self:setupSortButton(canvas, 420, 0, "ABC", "desAlpha")
	self:setupSortButton(canvas, 0, 110, "%", "ascPercent")
	self:setupSortButton(canvas, 420, 110, "%", "desPercent")
	self:setupSortButton(canvas, 0, 220, "E$", "ascValue")
	self:setupSortButton(canvas, 420, 220, "E$", "desValue")
end

function stocks:setupSortButton(canvas, x, y, name, sort)
	local xSize = 400
	local ySize = 100

	local sButton = require("modules/ui/widgets/button_texture"):new()
	sButton.x = x
	sButton.y = y
	sButton.sizeX = xSize
	sButton.sizeY = ySize
	sButton.textSize = 45
	sButton.text = name
	sButton.bgPart = "status_cell_bg"
	sButton.fgPart = "status_cell_fg"
    sButton.bgColor = color.white
    sButton.fgColor = color.white
	sButton.textColor = color.white
    sButton.useNineSlice = true

	sButton.callback = function ()
		self.sort = sort
		self:setStocks()
	end
	sButton:initialize()
	sButton:registerCallbacks(self.eventCatcher)
	sButton.canvas:Reparent(canvas, -1)

	if self.sort == sort then
		sButton.fg.image:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
	end

	local arrowSize = 50
	if string.match(sort, "asc") then
		local icon = ink.image((- xSize / 2) + arrowSize, 0, arrowSize, arrowSize, "base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas", "arrow_rect_fg")
		icon.pos:Reparent(sButton.canvas, -1)
	else
		local icon = ink.image((- xSize / 2) + arrowSize, 0, arrowSize, arrowSize, "base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas", "arrow_down_fg")
		icon.pos:Reparent(sButton.canvas, -1)
	end

	self.sortButtons[sort] = sButton
end

function stocks:setupScrollArea()
	local scrollComponent = UIScroller.Create()

	local scrollPanel = scrollComponent:GetRootWidget()
	scrollPanel:SetAnchor(inkEAnchor.TopLeft)
	scrollPanel:SetMargin(inkMargin.new({ left = 1020.0, top = 300 }))
	scrollPanel:SetSize(Vector2.new({ X = 1050.0, Y = 1000.0 }))
	scrollPanel:Reparent(self.canvas, -1)

	local scrollContent = scrollComponent:GetContentWidget()

	local buttonList = inkVerticalPanel.new()
	buttonList:SetName('list')
	buttonList:SetPadding(inkMargin.new({ left = 32.0, top = 5.0, right = 32.0, bottom = 15.0 }))
	buttonList:SetChildMargin(inkMargin.new({ top = 75.0, bottom = 75.0 }))
	buttonList:SetFitToContent(true)
	buttonList:Reparent(scrollContent, -1)

	Cron.NextTick(function()
		scrollComponent:UpdateContent(true)
	end)

	local basePos = {x = 500, y = 50}

	for i = 0, self.mod.market:getNumberStocks() do
		local preview = self:createPreviewButton(basePos.x, basePos.y)
		preview.canvas:Reparent(buttonList, -1)
	end
end

function stocks:createPreviewButton(x, y, stock)
	local button = require("modules/ui/widgets/stockPreview"):new(self)
	button.x = x
	button.y = y
	button.sizeX = 1000
	button.sizeY = 175
	button.textColor = color.white
	button.textSize = 80
	button.stock = stock
	button:initialize()
	button:registerCallbacks(self.eventCatcher)
	table.insert(self.previews, button)

	button.hoverInCallback = function (bt)
		bt.bg.image:SetOpacity(0.15)
		self.graph.canvas:SetVisible(true)
		self.graph.data = bt.stock.exportData.data
		self.graph:showData()

		self.infoName:SetText(bt.stock.name)
		self.infoText:SetText(utils.wrap(lang.getText(bt.stock.info), 30))
		self.info:SetVisible(true)

		Cron.NextTick(function ()
			ink.updateLine(self.infoLine, 0, 130, self.infoName:GetDesiredWidth(), 130)
		end)
	end
	button.hoverOutCallback = function (bt)
		bt.bg.image:SetOpacity(0)
		self.graph.canvas:SetVisible(false)
		self.info:SetVisible(false)
	end

	return button
end

function stocks:refresh()
	self:setStocks()
	for _, p in pairs(self.previews) do
		p:showData()
	end
end

function stocks:uninitialize()
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