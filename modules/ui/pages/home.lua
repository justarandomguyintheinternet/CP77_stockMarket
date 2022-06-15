local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")

home = {}

function home:new(inkPage, controller, eventCatcher)
	local o = {}

    o.inkPage = inkPage
	o.controller = controller
	o.eventCatcher = eventCatcher
	o.pageName = "home"

	o.canvas = nil

	self.__index = self
   	return setmetatable(o, self)
end

function home:initialize()
	self.canvas = ink.canvas(0, 0, inkEAnchor.TopLeft)
	self.canvas:Reparent(self.inkPage, -1)

	self.buttons = require("modules/ui/pages/menuButtons").createMenu(self)

	local graph = require("modules/ui/widgets/graph"):new(55, 300, 2000, 1000, 10, 5, lang.getText(lang.graph_time), lang.getText(lang.graph_value), 5, 50, color.darkcyan, 0.3)
	graph:initialize(self.canvas)

	local currentValue = 200
	local points = {}
	local steps = 50
	for i = 1, steps do
		currentValue = currentValue + (1 - (math.random() * 2))
		points[i] = {x = i, y = currentValue}
	end
	graph.data = points
	graph:showData()
end

function home:uninitialize()
	if not self.canvas then return end
	self.eventCatcher.removeSubscriber(self.button)
	self.inkPage:RemoveChild(self.canvas)
	self.inkPage:RemoveChild(self.buttons)
	self.canvas = nil
end

return home