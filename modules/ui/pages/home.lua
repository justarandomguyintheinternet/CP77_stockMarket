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

	self.graph = require("modules/ui/widgets/graph"):new(55, 300, 2000, 1000, 10, 5, lang.getText(lang.graph_time), lang.getText(lang.graph_value), 5, 50, color.darkcyan, 0.115)
	self.graph.intervall = self.mod.intervall
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
	market.fgColor = color.red
	market.textColor = color.white
	market.stock = self.mod.market.marketStock
	market:initialize()
	market:registerCallbacks(self.eventCatcher)
	market:showData()

	market.canvas:Reparent(self.canvas, -1)
	table.insert(self.previews, market)

	self.p1 = self:createPreviewButton(2600, 600, nil)
	self.p2 = self:createPreviewButton(2600, 800, nil)

	self.p3 = self:createPreviewButton(2600, 1000, nil)
	self.p4 = self:createPreviewButton(2600, 1200, nil)

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
	button.sizeY = 175
	button.textSize = 80
	button.textColor = color.white
	button.stock = stock
	button:initialize()
	button:registerCallbacks(self.eventCatcher)
	button.canvas:Reparent(self.canvas, -1)
	table.insert(self.previews, button)

	return button
end

function home:setStocks()
	local topStocks = self.mod.market:getTopStocks()

	self.p1.stock = topStocks.top1
	self.p2.stock = topStocks.top2
	self.p3.stock = topStocks.low1
	self.p4.stock = topStocks.low2
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