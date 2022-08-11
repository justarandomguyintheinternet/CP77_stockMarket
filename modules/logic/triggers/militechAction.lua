trigger = {}

function trigger:new()
	local o = {}

    -- Default data
    o.name = "militechAction"
    o.fadeSpeed = 0.01
    o.exportData = {
        value = 0
    }

	self.__index = self
   	return setmetatable(o, self)
end

function trigger:checkForData(data)
    if data["triggers"][self.name] == nil then
        data["triggers"][self.name] = self.exportData
    else
        self.exportData = data["triggers"][self.name]
    end
end

function trigger:decreaseValue() -- Runs every intervall
    if self.exportData.value == 0 then return end
    if self.exportData.value > 0 then
        self.exportData.value = self.exportData.value - self.fadeSpeed
    elseif self.exportData.value < 0 then
        self.exportData.value = self.exportData.value + self.fadeSpeed
    end
end

function trigger:registerObservers() -- Gets called once onInit
    ---@param this NPCPuppet
    ---@param evt gamePotentialDeathEvent
    Observe("NPCPuppet", "OnPotentialDeath", function (this, evt) -- Track Militech Forces Deaths / Deaths by Militech Weapons
        ---@type GameObject
        local killer = evt.instigator
        local faction = this:GetRecord():Affiliation():Type()

        if faction == gamedataAffiliation.Militech then -- Militech death
            self.exportData.value = self.exportData.value - 0.02
        end
        if killer:IsPuppet() and string.match(TweakDBInterface.GetWeaponItemRecord(killer:GetActiveWeapon():GetItemID():GetTDBID()):FriendlyName(), "militech") then -- Kill with Militech weapon
            self.exportData.value = self.exportData.value + 0.015
        end
    end)
end

function trigger:update() -- Gets called onUpdate

end

return trigger