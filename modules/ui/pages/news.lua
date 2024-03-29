local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")
local UIScroller = require("modules/external/UIScroller")

news = {}

function news:new(inkPage, controller, eventCatcher, mod)
	local o = {}

	o.mod = mod
    o.inkPage = inkPage
	o.controller = controller
	o.eventCatcher = eventCatcher
	o.pageName = "news"

	o.canvas = nil
	o.newsButtons = {}
	o.locked = false

	self.__index = self
   	return setmetatable(o, self)
end

function news:initialize()
	self.canvas = ink.canvas(0, -70, inkEAnchor.TopLeft)
	self.canvas:Reparent(self.inkPage, -1)

	self.buttons = require("modules/ui/pages/menuButtons").createMenu(self)

	self:setupNews()
	self:setupScrollArea()
end

function news:setupNews()
	self.news = ink.canvas(1275, 310, inkEAnchor.Centered)
	self.news:SetVisible(false)
	self.news:Reparent(self.canvas, -1)

	self.newsTitle = ink.text("", 0, 0, 120, color.white)
	self.newsTitle:Reparent(self.news, -1)

	self.newsLine = ink.line(0, 130, 500, 130, color.white, 5)
	self.newsLine:Reparent(self.news, -1)

	self.newsText = ink.text("", 0, 175, 65, color.white)
	self.newsText:Reparent(self.news, -1)

	local settingsText = ink.text(lang.getText(lang.news_toggleNotification), 2965, 1275, 65, color.white)
	settingsText:SetAnchorPoint(Vector2.new({X = 1, Y = 0.5}))
	settingsText:Reparent(self.canvas, -1)

	self.settingsButton = self:setupSettingsButton()
	self.settingsButton.canvas:Reparent(self.canvas, -1)
end

function news:setupSettingsButton()
	local button = require("modules/ui/widgets/button_texture"):new()
	button.x = 3050
	button.y = 1275
	button.sizeX = 120
	button.sizeY = 120
	button.textColor = color.white
	button.textSize = 80
	button.bgPart = "status_cell_bg"
	button.fgPart = "status_cell_fg"
    button.bgColor = color.white
    button.fgColor = color.white
    button.useNineSlice = true

	button:initialize()

	button.cross = ink.canvas(0, 0, inkEAnchor.Centered)
	button.cross:Reparent(button.canvas, -1)
	local rect1 = ink.rect(0, 0, 120, 8, color.white, 45, Vector2.new({X = 0.5, Y = 0.5}))
	rect1:Reparent(button.cross, -1)
	local rect2 = ink.rect(0, 0, 120, 8, color.white, -45, Vector2.new({X = 0.5, Y = 0.5}))
	rect2:Reparent(button.cross, -1)

	if not self.mod.market.newsManager.settings.notifications then
		button.cross:SetVisible(false)
	end

	button:registerCallbacks(self.eventCatcher)

	button.callback = function()
		self.mod.market.newsManager.settings.notifications = not self.mod.market.newsManager.settings.notifications
		button.cross:SetVisible(self.mod.market.newsManager.settings.notifications)
	end

	return button
end

function news:setupScrollArea()
	self.scrollComponent = UIScroller.Create()

	local scrollPanel = self.scrollComponent:GetRootWidget()
	scrollPanel:SetAnchor(inkEAnchor.TopLeft)
	scrollPanel:SetMargin(inkMargin.new({ left = 0.0, top = 290 }))
	scrollPanel:SetSize(Vector2.new({ X = 1200.0, Y = 1035.0 }))
	scrollPanel:Reparent(self.canvas, -1)

	local scrollContent = self.scrollComponent:GetContentWidget()

	self.buttonList = inkVerticalPanel.new()
	self.buttonList:SetName('list')
	self.buttonList:SetPadding(inkMargin.new({ left = 55.0, top = 0.0, right = 32.0 }))
	self.buttonList:SetChildMargin(inkMargin.new({ top = 80.0, bottom = 90.0 }))
	self.buttonList:SetFitToContent(true)
	self.buttonList:Reparent(scrollContent, -1)

	Cron.NextTick(function()
		self.scrollComponent:UpdateContent(true)
	end)

	local basePos = {x = 550, y = 50}

	local news = self.mod.market.newsManager:getNews()

	for i = 1, #news do
		local news = self:createNewsButton(basePos.x, basePos.y, news[i])
		news.canvas:SetAffectsLayoutWhenHidden(false)
		news.canvas:Reparent(self.buttonList, -1)
	end

	if #news < 5 then
		self:toggleSlider(false)
	end
end

function news:toggleSlider(state)
	self.scrollComponent:GetRootWidget():GetWidgetByPathName(StringToName('sliderArea')):SetVisible(state)
end

function news:createNewsButton(x, y, name)
	-- Basic Setup
	local button = require("modules/ui/widgets/button_texture"):new()
	button.x = x
	button.y = y
	button.sizeX = 1125
	button.sizeY = 200
	button.textColor = color.white
	button.textSize = 80
	button.bgPart = "status_cell_bg"
	button.fgPart = "status_cell_fg"
    button.bgColor = color.white
    button.fgColor = color.white
    button.useNineSlice = true

	-- Custom callback
	button.callback = function()
		self.locked = false
		button:hoverInCallback()
		for _, b in pairs(self.newsButtons) do -- Unhighlight
			b.fg.image:SetTintColor(color.white)
		end
		button.fg.image:SetTintColor(color.cyan) -- Highlight selected
		self.locked = true -- Disable hover preview
	end

	button:initialize()
	button:registerCallbacks(self.eventCatcher)
	table.insert(self.newsButtons, button)

	local title, text = lang.getNewsText(name, self.mod.market.triggerManager.triggers[name].factCondition and Game.GetQuestsSystem():GetFactStr(self.mod.market.triggerManager.triggers[name].factCondition) == 1)

	button.textWidget:SetText(title)

	button.hoverInCallback = function (bt)
		bt.bg.image:SetOpacity(0.05)

		if not self.locked then -- Display news info
			self.newsTitle:SetText(title)
			self.newsText:SetText(utils.wrap(text, 55))
			self.news:SetVisible(true)
			Cron.NextTick(function ()
				ink.updateLine(self.newsLine, 0, 130, self.newsTitle:GetDesiredWidth(), 130)
			end)
		end
	end
	button.hoverOutCallback = function (bt)
		bt.bg.image:SetOpacity(0)
		if not self.locked then
			self.news:SetVisible(false)
		end
	end

	return button
end

function news:uninitialize()
	Cron.Halt(self.refreshCron)

	if not self.canvas then return end
	self.newsButtons = {}
	self.eventCatcher.removeSubscriber(self.button)
	self.inkPage:RemoveChild(self.canvas)
	self.inkPage:RemoveChild(self.buttons)
	self.canvas = nil
	self.locked = false
end

return news