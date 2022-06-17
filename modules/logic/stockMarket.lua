local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")
local GameSession = require("modules/external/GameSession")

market = {}

function market:new(intervall, triggerManager)
	local o = {}

    o.stocks = {}
    o.triggerManager = triggerManager
    o.persistentData = {
        stocks = {},
        triggers = {}
    }

    o.updateCron = nil
    o.intervall = intervall

	self.__index = self
   	return setmetatable(o, self)
end

function market:setupPersistency() -- Setup persistency once onInit
    GameSession.StoreInDir('data/persistent/')
    GameSession.Persist(self.persistentData)
end

function market:checkForData()
    for _, stock in pairs(self.stocks) do
        stock:checkForData(self.persistentData)
    end

    -- Do same thing for triggers
end

function market:initialize() -- Generate stock instances from json files
    self.updateCron = Cron.Every(self.intervall, function ()
        self:update()
    end)

    for _, file in pairs(dir("data/static/stocks/")) do
        if file.name:match("^.+(%..+)$") == ".json" then
            local data = config.loadFile("data/static/stocks/" .. file.name)
            local stock = require("modules/logic/stock"):new()
            stock:loadFromDefinition(data)
            table.insert(self.stocks, stock)
        end
    end
end

function market:update() -- Update loop for Cron intervall
    for _, stock in pairs(self.stocks) do
        stock:update()
    end
end

return market