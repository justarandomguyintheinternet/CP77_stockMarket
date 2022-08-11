trigger = {}

function trigger:new()
	local o = {}

    -- Default data
    o.name = "budgetArmsKills"
    o.fadeSpeed = 0.004
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
    ---@param evt gamePotentialDeathEvent
    Observe("NPCPuppet", "OnPotentialDeath", function (this, evt)
        ---@type GameObject
        local killer = evt.instigator

        if killer:IsPuppet() and string.match(TweakDBInterface.GetWeaponItemRecord(killer:GetActiveWeapon():GetItemID():GetTDBID()):FriendlyName(), "budget") then
            self.exportData.value = self.exportData.value + 0.02
        end

        local weapon = this:GetActiveWeapon()
        if weapon then
            if string.match(weapon:GetWeaponRecord():FriendlyName(), "budget") then
                self.exportData.value = self.exportData.value - 0.01
            end
        end
    end)
end

function trigger:update() end

return trigger