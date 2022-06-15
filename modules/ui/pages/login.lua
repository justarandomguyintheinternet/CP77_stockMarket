local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")

login = {}

function login:new(inkPage, controller, eventCatcher)
	local o = {}

    o.inkPage = inkPage
	o.controller = controller
	o.eventCatcher = eventCatcher

	o.canvas = nil
	o.button = nil

	self.__index = self
   	return setmetatable(o, self)
end

function login:initialize()
	self.canvas = ink.canvas(0, 100, inkEAnchor.TopCenter)
	self.canvas:Reparent(self.inkPage, -1)

	local t = ink.text(tostring(lang.getText(lang.login_name) .. ": V"), 0, 350, 150, color.white)
	t:SetAnchorPoint(0.5, 0.5)
	t:Reparent(self.canvas, -1)

	local t = ink.text(lang.getText(lang.login_password) .. ": *********", 0, 550, 150, color.white)
	t:SetAnchorPoint(0.5, 0.5)
	t:Reparent(self.canvas, -1)

	self.button = require("modules/ui/widgets/button"):new()
	self.button.x = 0
	self.button.y = 800
	self.button.sizeX = 500
	self.button.sizeY = 220
	self.button.textSize = 85
	self.button.text = lang.getText(lang.button_login)
	self.button.borderSize = 6
	self.button.fillColor = color.darkred
	self.button.bgColor = color.darkcyan
	self.button.textColor = color.white
	self.button.callback = function()
		self.controller:switchToPage("home")
	end
	self.button:initialize()
	self.button:registerCallbacks(self.eventCatcher)
	self.button.canvas:Reparent(self.canvas, -1)
end

function login:uninitialize()
	if not self.canvas then return end
	self.eventCatcher.removeSubscriber(self.button)
	self.inkPage:RemoveChild(self.canvas)
	self.canvas = nil
end

return login