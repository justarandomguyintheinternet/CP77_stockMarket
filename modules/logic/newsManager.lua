local lang = require("modules/utils/lang")
local Cron = require("modules/external/Cron")
local config = require("modules/utils/config")

newsManager = {}

function newsManager:new(mod)
	local o = {}

    o.mod = mod
    o.data = {}
    o.questDelays = {}
    o.updateCron = nil
    o.dataLink = nil

	self.__index = self
   	return setmetatable(o, self)
end

function newsManager:checkForData(data)
    if data["news"] == {} then
        data["news"] = self.data
    else
        self.data = data["news"]
    end
    self.dataLink = data -- Data doesnt cant get written back to the "data" otherwise
end

function newsManager:onInit()
    self.updateCron = Cron.Every(5.0, function ()
        self:update()
    end)
    self.questDelays = config.loadFile("data/static/news/newsQuestDelays.json")
end

function newsManager:isNewsActive(triggerName)
    for _, data in pairs(self.data) do
        if data.name == triggerName then return true end
    end
    return false
end

function newsManager:update() -- Runs on Cron
    for key, data in pairs(self.data) do
        if data.delay == 1 then
            print("Should show news NOW", data.name)
        end
        data.delay = math.max(0, data.delay - 1)
    end

    for name, trigger in pairs(self.mod.market.triggerManager.triggers) do
        if not self.mod.market.stocks[name] then
            local newsThreshold = trigger.newsThreshold or 0.375
            if name:match("LocKey") then
                newsThreshold = 0.95
            end

            if trigger.exportData.value >= newsThreshold and not self:isNewsActive(name) then
                local shift = {}
                for key, value in pairs(self.data) do
                    if key < 16 then
                        shift[key + 1] = value
                    end
                end

                shift[1] = {name = name, delay = self.questDelays[name] or 18} -- Delay for dyn triggers is 90 secs
                self.data = shift
            end
        end
    end

    self.dataLink["news"] = self.data
end

return newsManager