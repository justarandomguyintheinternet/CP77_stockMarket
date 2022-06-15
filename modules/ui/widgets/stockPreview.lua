local ink = require("modules/ui/inkHelper")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")

preview = {}

function preview:new(x, y, sizeX, sizeY, borderSize, bgColor, fillColor, textSize, stock)
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

    o.bg = nil
    o.fill = nil
    o.textWidget = nil
    o.canvas = nil

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

    self.textWidget = ink.text(self.text, 0, 0, self.textSize, self.textColor, nil, nil, 0)
    self.textWidget:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.textWidget:Reparent(self.canvas, -1)
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
    if not self.callback or self.cooldown then return end
    self.cooldown = true
    Cron.NextTick(function()
        self.cooldown = false
    end)
    utils.playSound("ui_menu_onpress", 1)
    self.callback()
end

return preview