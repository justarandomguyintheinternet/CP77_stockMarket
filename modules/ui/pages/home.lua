local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")

home = {}

function home:new(inkPage, controller, eventCatcher, mod)
	local o = {}

	o.mod = mod
    o.inkPage = inkPage
	o.controller = controller
	o.eventCatcher = eventCatcher
	o.pageName = "home"

	o.canvas = nil
	o.refreshCron = nil
	o.previews = {}

	self.__index = self
   	return setmetatable(o, self)
end

function home:initialize()
	self.refreshCron = Cron.Every(5, function ()
		self:refresh()
	end)

	self.canvas = ink.canvas(0, 0, inkEAnchor.TopLeft)
	self.canvas:Reparent(self.inkPage, -1)

	self.buttons = require("modules/ui/pages/menuButtons").createMenu(self)

	self.graph = require("modules/ui/widgets/graph"):new(55, 300, 2000, 1000, 10, 5, lang.getText(lang.graph_time), lang.getText(lang.graph_value), 5, 50, color.darkcyan, 0.3)
	self.graph:initialize(self.canvas)
	self.graph.data = self.mod.market.marketStock.exportData.data
	self.graph:showData()

	local market = require("modules/ui/widgets/stockPreview"):new(self)
	market.x = 2600
	market.y = 400
	market.sizeX = 1000
	market.sizeY = 170
	market.textSize = 80
	market.borderSize = 8
	market.fillColor = color.darkred
	market.bgColor = color.yellowgreen
	market.textColor = color.white
	market.stock = self.mod.market.marketStock
	market:initialize()
	market:showData()
	market.canvas:Reparent(self.canvas, -1)
	table.insert(self.previews, market)

	local line = ink.line(2080, 510, 3120, 510, color.white, 3)
	line:Reparent(self.canvas, -1)

	self.p1 = self:createPreviewButton(2600, 620, nil)
	self.p2 = self:createPreviewButton(2600, 820, nil)

	local line = ink.line(2080, 920, 3120, 920, color.white, 3)
	line:Reparent(self.canvas, -1)

	self.p3 = self:createPreviewButton(2600, 1020, nil)
	self.p4 = self:createPreviewButton(2600, 1220, nil)

	self:setStocks()
	for _, p in pairs(self.previews) do
		p:showData()
	end
end

function home:createPreviewButton(x, y, stock)
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
	button.canvas:Reparent(self.canvas, -1)
	table.insert(self.previews, button)

	return button
end

function home:setStocks()
	local keys = {}
	for k, _ in pairs(self.mod.market.stocks) do
		table.insert(keys, k)
	end

	local top1 = {k = "", n = -100}
	for _, key in pairs(keys) do
		local trend = self.mod.market.stocks[key]:getTrend()
		if trend > top1.n then
			top1.n = trend
			top1.k = key
		end
	end
	utils.removeItem(keys, top1.k)

	local top2 = {k = "", n = -100}
	for _, key in pairs(keys) do
		local trend = self.mod.market.stocks[key]:getTrend()
		if trend > top2.n then
			top2.n = trend
			top2.k = key
		end
	end
	utils.removeItem(keys, top2.k)

	local low1 = {k = "", n = 100}
	for _, key in pairs(keys) do
		local trend = self.mod.market.stocks[key]:getTrend()
		if trend < low1.n then
			low1.n = trend
			low1.k = key
		end
	end
	utils.removeItem(keys, low1.k)

	local low2 = {k = "", n = 100}
	for _, key in pairs(keys) do
		local trend = self.mod.market.stocks[key]:getTrend()
		if trend < low2.n then
			low2.n = trend
			low2.k = key
		end
	end
	utils.removeItem(keys, low2.k)

	self.p1.stock = self.mod.market.stocks[top1.k]
	self.p2.stock = self.mod.market.stocks[top2.k]
	self.p3.stock = self.mod.market.stocks[low1.k]
	self.p4.stock = self.mod.market.stocks[low2.k]
end

function home:refresh()
	self:setStocks()
	for _, p in pairs(self.previews) do
		p:showData()
	end

	self.graph.data = self.mod.market.marketStock.exportData.data
	self.graph:showData()
end

function home:uninitialize()
	Cron.Halt(self.refreshCron)

	if not self.canvas then return end
	self.eventCatcher.removeSubscriber(self.button)
	self.inkPage:RemoveChild(self.canvas)
	self.inkPage:RemoveChild(self.buttons)
	self.canvas = nil
end

return home