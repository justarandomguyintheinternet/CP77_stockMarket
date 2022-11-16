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
	o.pageName = "portfolio"

	o.canvas = nil
	o.refreshCron = nil
	o.previews = {}
	o.sort = "ascAlpha"
	o.sortButtons = {}

	self.__index = self
   	return setmetatable(o, self)
end

function portfolio:initialize()
	self.refreshCron = Cron.Every(2, function ()
		self:refresh()
	end)

	self.canvas = ink.canvas(0, 0, inkEAnchor.TopLeft)
	self.canvas:Reparent(self.inkPage, -1)

	self.buttons = require("modules/ui/pages/menuButtons").createMenu(self)

	self.graph = require("modules/ui/widgets/graph"):new(68, 395, 1162, 900, 6, 4, lang.getText(lang.graph_time), lang.getText(lang.portfolio_accountValue), 4, 45, color.darkcyan, 0.1)
	self.graph.intervall = self.mod.intervall
	self.graph.data = self.mod.market.portfolioStock.exportData.data
	self.graph.relativeScaling = true
	self.graph:initialize(self.canvas)
	self.graph:showData()

	local line = ink.line(2300, 650, 3120, 650, color.white, 3) -- Divider below sort buttons
	line:Reparent(self.canvas, -1)

	self:setupLabels()
	self:setupInfo()
	self:setupScrollArea()
	self:setupSortButtons()
	self:setStocks()
end

function portfolio:setupLabels()
	local gText = ink.text(lang.getText(lang.portfolio_accountValue), 640, 315, 50, color.white)
	gText:SetAnchorPoint(0.5, 0.5)
	gText:Reparent(self.canvas, -1)

	local sText = ink.text(lang.getText(lang.portfolio_ownedStocks), 1750, 315, 50, color.white)
	sText:SetAnchorPoint(0.5, 0.5)
	sText:Reparent(self.canvas, -1)
end

function portfolio:setupInfo()
	self.info = ink.canvas(2320, 775, inkEAnchor.Centered)
	self.info:Reparent(self.canvas, -1)

	self.infoTotal = ink.text("", 0, 0, 80, color.white)
	self.infoTotal:Reparent(self.info, -1)

	local line = ink.line(0, 130, 500, 130, color.white, 5)
	line:Reparent(self.info, -1)

	self.infoStocksV = ink.text("", 0, 155, 80, color.white)
	self.infoStocksV:Reparent(self.info, -1)

	local line = ink.line(0, 275, 500, 275, color.white, 5)
	line:Reparent(self.info, -1)

	self.infoShares = ink.text("", 0, 310, 80, color.white)
	self.infoShares:Reparent(self.info, -1)

	self:refreshInfo()
end

function portfolio:refreshInfo()
	local total = Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money())
	local shares = 0
	local sharesV = 0
	for _, stock in pairs(self.mod.market.stocks) do
		total = total + stock:getPortfolioNum() * stock:getCurrentPrice()
		shares = shares + stock:getPortfolioNum()
		sharesV = sharesV + stock:getPortfolioNum() * stock:getCurrentPrice()
	end

	self.infoTotal:SetText(tostring(lang.getText(lang.portfolio_totalMoney) .. ": " .. total .. "E$"))
	self.infoStocksV:SetText(tostring(lang.getText(lang.portfolio_moneyInStocks) .. ": " .. sharesV .. "E$"))
	self.infoShares:SetText(tostring(lang.getText(lang.portfolio_ownedStocks) .. ": " .. shares))
end

function portfolio:setStocks()
	local stocks = {}
	for _, stock in pairs(self.mod.market.stocks) do
		if stock:getPortfolioNum() > 0 then
			table.insert(stocks, stock)
		end
	end

	local sortFunc = nil
	if self.sort == "ascAlpha" then
		sortFunc = function(a, b) return a.name < b.name end
	elseif self.sort == "desAlpha" then
		sortFunc = function(a, b) return a.name > b.name end
	elseif self.sort == "ascPercent" then
		sortFunc = function(a, b) return utils.round(a:getProfit(-a:getPortfolioNum()) / a.exportData.spent * 100, 1) < utils.round(b:getProfit(-b:getPortfolioNum()) / b.exportData.spent * 100, 1) end
	elseif self.sort == "desPercent" then
		sortFunc = function(a, b) return utils.round(a:getProfit(-a:getPortfolioNum()) / a.exportData.spent * 100, 1) > utils.round(b:getProfit(-b:getPortfolioNum()) / b.exportData.spent * 100, 1) end
	elseif self.sort == "ascValue" then
		sortFunc = function(a, b) return (a:getCurrentPrice() * a:getPortfolioNum()) < (b:getCurrentPrice() * b:getPortfolioNum()) end
	elseif self.sort == "desValue" then
		sortFunc = function(a, b) return (a:getCurrentPrice() * a:getPortfolioNum()) > (b:getCurrentPrice() * b:getPortfolioNum()) end
	end

	table.sort(stocks, sortFunc)

	if #stocks > 5 then
		self:toggleSlider(true)
	else
		self:toggleSlider(false)
	end

	for k, button in pairs(self.previews) do
		if #stocks ~= 0 then
			button.stock = stocks[1]
			button:showData()
			utils.removeItem(stocks, stocks[1])
			button.canvas:SetVisible(true)
		else
			button.canvas:SetVisible(false)
		end
	end

	for key, button in pairs(self.sortButtons) do
		if key ~= self.sort then
			button.fg.image:SetTintColor(color.white)
		else
			button.fg.image:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		end
	end
end

function portfolio:setupSortButtons()
	local canvas = ink.canvas(2500, 350, inkEAnchor.Centered)
	canvas:Reparent(self.canvas, -1)

	self:setupSortButton(canvas, 0, 0, "ABC", "ascAlpha")
	self:setupSortButton(canvas, 420, 0, "ABC", "desAlpha")
	self:setupSortButton(canvas, 0, 110, "%", "ascPercent")
	self:setupSortButton(canvas, 420, 110, "%", "desPercent")
	self:setupSortButton(canvas, 0, 220, "E$", "ascValue")
	self:setupSortButton(canvas, 420, 220, "E$", "desValue")
end

function portfolio:setupSortButton(canvas, x, y, name, sort)
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

function portfolio:setupScrollArea()
	self.scrollComponent = UIScroller.Create()

	local scrollPanel = self.scrollComponent:GetRootWidget()
	scrollPanel:SetAnchor(inkEAnchor.TopLeft)
	scrollPanel:SetMargin(inkMargin.new({ left = 1233.0, top = 350 }))
	scrollPanel:SetSize(Vector2.new({ X = 1040.0, Y = 1000.0 }))
	scrollPanel:Reparent(self.canvas, -1)

	local scrollContent = self.scrollComponent:GetContentWidget()

	self.buttonList = inkVerticalPanel.new()
	self.buttonList:SetName('list')
	self.buttonList:SetPadding(inkMargin.new({ left = 32.0, top = 20.0, right = 32.0 }))
	self.buttonList:SetChildMargin(inkMargin.new({ top = 66.0, bottom = 66.0 }))
	self.buttonList:SetFitToContent(true)
	self.buttonList:Reparent(scrollContent, -1)

	Cron.NextTick(function()
		self.scrollComponent:UpdateContent(true)
	end)

	local basePos = {x = 482, y = 50}

	for i = 0, self.mod.market:getNumberStocks() - 1 do
		local preview = self:createPreviewButton(basePos.x, basePos.y)
		preview.canvas:SetAffectsLayoutWhenHidden(false)
		preview.canvas:Reparent(self.buttonList, -1)
	end
end

function portfolio:toggleSlider(state)
	self.scrollComponent:GetRootWidget():GetWidgetByPathName(StringToName('sliderArea')):SetVisible(state)
end

function portfolio:createPreviewButton(x, y, stock)
	local button = require("modules/ui/widgets/stockPreview"):new(self)
	button.x = x
	button.y = y
	button.sizeX = 1000
	button.sizeY = 170
	button.textSize = 72
	button.borderSize = 8
	button.fillColor = color.darkred
	button.bgColor = color.darkcyan
	button.textColor = color.white
	button.stock = stock

	button.showData = function (bt)
		bt.stockIcon.image:SetAtlasResource(ResRef.FromString(bt.stock.atlasPath))
		bt.stockIcon.image:SetTexturePart(bt.stock.atlasPart)
		bt.stockIcon.pos:SetSize(bt.stock.iconX, bt.stock.iconY)
		bt.stockIcon.image:SetTintColor(HDRColor.new({ Red = 0.9, Green = 0.9, Blue = 0.9, Alpha = 1.0 }))
		bt.stockPrice:SetText(tostring(math.floor(bt.stock:getCurrentPrice() * bt.stock:getPortfolioNum()) .. "E$"))

		local trend = bt.stock:getProfit(-bt.stock:getPortfolioNum()) / bt.stock.exportData.spent
		trend = utils.round(trend * 100, 1)

		local c = color.red
		if trend >= 0 then
			c = color.lime
			trend = tostring("+" .. trend)
		end
		bt.stockTrend:SetText(tostring(trend .. "%"))
		bt.stockTrend:SetTintColor(c)
	end

	button:initialize()
	button:registerCallbacks(self.eventCatcher)
	table.insert(self.previews, button)

	return button
end

function portfolio:refresh()
	self:setStocks()
	self:refreshInfo()
	for _, p in pairs(self.previews) do
		if p.canvas:IsVisible() then
			p:showData()
		end
	end

	self.graph.data = self.mod.market.portfolioStock.exportData.data
	self.graph:showData()
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

return portfolio