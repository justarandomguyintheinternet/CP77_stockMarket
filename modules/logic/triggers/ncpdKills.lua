trigger = {}

function trigger:new()
	local o = {}

    -- Default data
    o.name = "ncpdKills"
    o.fadeSpeed = 0.005
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
    Observe("NPCPuppet", "OnPotentialDeath", function (this, evt) -- Track Arasaka Forces Deaths / Deaths by Arasaka Weapons
        ---@type GameObject
        local killer = evt.instigator
        local faction = this:GetRecord():Affiliation():Type()
        if faction == gamedataAffiliation.NCPD then
            self.exportData.value = self.exportData.value - 0.025
        end
        pcall(function()
            local type = killer:GetRecord():Affiliation():Type()
            if type == gamedataAffiliation.NCPD then
            self.exportData.value = self.exportData.value + 0.075
            end
        end)
    end)
end

function trigger:update() -- Gets called onUpdate

end

return trigger