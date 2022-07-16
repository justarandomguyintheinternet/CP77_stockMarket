local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")

questManager = {}

function questManager:new(mod)
	local o = {}

    o.mod = mod
    o.quests = {}

	self.__index = self
   	return setmetatable(o, self)
end

function questManager:onInit()
    self.quests = config.loadFile("data/static/quests/quests.json")

    for _, quest in pairs(self.quests) do
        local trigger = require("modules/logic/questTrigger"):new(self.mod.market)
        trigger:initialize(quest)
        trigger:checkForData(self.mod.market.persistentData)
        self.mod.market.triggerManager.triggers["quest_" .. quest.name] = trigger
    end

    Observe("JournalNotificationQueue", "OnJournalUpdate", function(_, hash, class)
        if class.value == "gameJournalQuest" then
            local entry = Game.GetJournalManager():GetEntry(hash)
            local state = Game.GetJournalManager():GetEntryState(entry)
            local name = entry:GetTitle(Game.GetJournalManager())

            if state == gameJournalEntryState.Succeeded or state == gameJournalEntryState.Failed then
                local questData = self.quests[name]
                if not questData then return end

                self.mod.market.triggerManager.triggers["quest_" .. questData.name].exportData.value = questData.amount
            end
        end
    end)

    Observe("JournalNotificationQueue", "OnNCPDJobDoneEvent", function(_, evt)
        print(evt.levelXPAwarded, evt.streetCredXPAwarded)
        local ncpdTrigger = self.mod.market.triggerManager.triggers["NCPD_Hustler"]
        ncpdTrigger.exportData.value = ncpdTrigger.exportData.value + (evt.levelXPAwarded / 6000) + (evt.streetCredXPAwarded / 6000)
    end)
end

return questManager