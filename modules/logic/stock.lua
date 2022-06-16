local ink = require("modules/ui/inkHelper")
local color = require("modules/ui/color")
local lang = require("modules/utils/lang")

stock = {}

function stock:new()
	local o = {}

    o.name = "Arasaka"

	self.__index = self
   	return setmetatable(o, self)
end

function stock:getCurrentPrice()
    return 390
end

function stock:getTrend()
    return 3.2
end

function stock:getPortfolioNum()
    return 16
end

return stock