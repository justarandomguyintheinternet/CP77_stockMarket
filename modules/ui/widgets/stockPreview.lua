local ink = require("modules/ui/inkHelper")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")

preview = {}

function preview:new(page)
	local o = {}

    o.x = x
    o.y = y
    o.sizeX = sizeX
    o.sizeY = sizeY
    o.borderSize = borderSize
    o.textSize = textSize
    o.bgColor = bgColor
    o.fillColor = fillColor

    o.eventCatcher = nil
    o.cooldown = false
    o.page = page

    o.bg = nil
    o.fill = nil
    o.canvas = nil

    o.stock = stock
    o.stockName = nil
    o.stockPrice = nil
    o.stockTrend = nil

	self.__index = self
   	return setmetatable(o, self)
end

function preview:initialize()
    self.canvas = ink.canvas(self.x, self.y, inkEAnchor.Centered)
    self.canvas:SetInteractive(true)

    self.bg = ink.rect(0, 0, self.sizeX, self.sizeY, self.bgColor, 0, Vector2.new({X = 0.5, Y = 0.5}))
    self.bg:Reparent(self.canvas, -1)

    self.fill = ink.rect(0, 0, self.sizeX - self.borderSize * 2, self.sizeY - self.borderSize * 2, self.fillColor, 0, Vector2.new({X = 0.5, Y = 0.5}))
    self.fill:Reparent(self.canvas, -1)
    self.fill:SetInteractive(true)

    local line = ink.line(0, - self.sizeY / 2, 0, self.sizeY / 2, self.bgColor, self.borderSize)
    line:Reparent(self.canvas, -1)
    local line = ink.line(self.sizeX / 4, - self.sizeY / 2, self.sizeX / 4, self.sizeY / 2, self.bgColor, self.borderSize)
    line:Reparent(self.canvas, -1)

    self.stockName = ink.text("", -self.sizeX / 4, 0, self.textSize, self.textColor)
    self.stockName:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockName:Reparent(self.canvas, -1)

    self.stockPrice = ink.text("", self.sizeX / 8, 0, math.floor(self.textSize * 0.9), self.textColor)
    self.stockPrice:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockPrice:Reparent(self.canvas, -1)

    self.stockTrend = ink.text("", self.sizeX / 4 + (self.sizeX / 8), 0, self.textSize, self.textColor)
    self.stockTrend:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockTrend:Reparent(self.canvas, -1)
end

function preview:showData()
    self.stockName:SetText(self.stock.name)
    self.stockPrice:SetText(tostring(self.stock:getCurrentPrice() .. "E$"))

    local trend = self.stock:getTrend()
    local c = color.red
    if trend > 0 then
        c = color.lime
        trend = tostring("+" .. trend)
    end

    self.stockTrend:SetText(tostring(trend .. "%"))
    self.stockTrend:SetTintColor(c)
end

function preview:registerCallbacks(catcher)
    self.eventCatcher = sampleStyleManagerGameController.new()

	self.fill:RegisterToCallback('OnPress', self.eventCatcher, 'OnState1')
	self.fill:RegisterToCallback('OnEnter', self.eventCatcher, 'OnStyle1')
	self.fill:RegisterToCallback('OnLeave', self.eventCatcher, 'OnStyle2')

    table.insert(catcher.subscribers, self)
end

function preview:hoverInCallback()
    self.fill:SetOpacity(0.6)
end

function preview:hoverOutCallback()
    self.fill:SetOpacity(1)
end

function preview:clickCallback()
    if self.cooldown then return end
    self.cooldown = true
    Cron.NextTick(function()
        self.cooldown = false
    end)
    utils.playSound("ui_menu_onpress", 1)

    self.page.controller.currentInfoStock = self.stock
    self.page.controller:switchToPage("stockInfo")
end

return preview