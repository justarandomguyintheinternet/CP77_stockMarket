local ink = require("modules/ui/inkHelper")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")

preview = {}

function preview:new(page)
	local o = {}

    o.x = 0
    o.y = 0
    o.sizeX = 500
    o.sizeY = 50
    o.textSize = 55

    o.fgColor = nil
    o.bgColor = nil

    o.eventCatcher = nil
    o.cooldown = false
    o.page = page

    o.bg = nil
    o.fill = nil
    o.canvas = nil

    o.stock = nil
    o.stockIcon = nil
    o.stockPrice = nil
    o.stockTrend = nil

	self.__index = self
   	return setmetatable(o, self)
end

function preview:initialize()
    local atlas = "base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas"

    self.canvas = ink.canvas(self.x, self.y, inkEAnchor.Centered)
    self.canvas:SetInteractive(true)

    self.fg = ink.image(0, 0, self.sizeX, self.sizeY, atlas, "tooltip_map_fg")
    self.fg.pos:SetInteractive(true)
    self.fg.image.useNineSliceScale = true
    self.fg.image:SetTintColor(self.fgColor or color.white)
    self.fg.pos:Reparent(self.canvas, -1)

    self.bg = ink.image(0, 0, self.sizeX, self.sizeY, atlas, "tooltip_map_bg")
    self.bg.pos:SetInteractive(true)
    self.bg.image.useNineSliceScale = true
    self.bg.image:SetTintColor(self.bgColor or color.gray)
    self.bg.image:SetOpacity(0)
    self.bg.pos:Reparent(self.canvas, -1)

    self.stockIcon = ink.image(-self.sizeX / 4, 0, 0, 0, "", "")
    self.stockIcon.pos:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockIcon.pos:Reparent(self.canvas, -1)

    self.stockPrice = ink.text("", self.sizeX / 8, 0, math.floor(self.textSize * 0.9), self.textColor)
    self.stockPrice:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockPrice:Reparent(self.canvas, -1)

    self.stockTrend = ink.text("", self.sizeX / 4 + (self.sizeX / 8), 0, self.textSize, self.textColor)
    self.stockTrend:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockTrend:Reparent(self.canvas, -1)
end

function preview:showData()
    self.stockIcon.image:SetAtlasResource(ResRef.FromString(self.stock.atlasPath))
    self.stockIcon.image:SetTexturePart(self.stock.atlasPart)
    self.stockIcon.pos:SetSize(self.stock.iconX, self.stock.iconY)
    self.stockIcon.image:SetTintColor(HDRColor.new({ Red = 0.9, Green = 0.9, Blue = 0.9, Alpha = 1.0 }))

    self.stockPrice:SetText(tostring(math.floor(self.stock:getCurrentPrice()) .. "E$"))

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

	self.bg.pos:RegisterToCallback('OnPress', self.eventCatcher, 'OnState1')
	self.bg.pos:RegisterToCallback('OnEnter', self.eventCatcher, 'OnStyle1')
	self.bg.pos:RegisterToCallback('OnLeave', self.eventCatcher, 'OnStyle2')

    table.insert(catcher.subscribers, self)
end

function preview:hoverInCallback()
    self.bg.image:SetOpacity(0.25)
end

function preview:hoverOutCallback()
    self.bg.image:SetOpacity(0)
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