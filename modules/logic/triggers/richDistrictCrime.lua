trigger = {}

function trigger:new()
	local o = {}

    -- Default data
    o.name = "richDistrictCrime"
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
        self.exportData.value = 0
    end
end

function trigger:registerObservers() -- Gets called once onInit
    ---@param this NPCPuppet
    ---@param evt gamePotentialDeathEvent
    Observe("NPCPuppet", "OnPotentialDeath", function (this, evt)
        ---@type GameObject
        local killer = evt.instigator
        local faction = this:GetRecord():Affiliation():Type()
        if faction ~= gamedataAffiliation.Civilian and faction ~= gamedataAffiliation.NCPD then return end

        local district = TweakDBInterface.GetDistrictRecord(Game.GetScriptableSystemsContainer():Get("PreventionSystem").districtManager:GetCurrentDistrict():GetDistrictID())
        local mainDistrict = district:LocalizedName()

        local richDistrict = mainDistrict == "LocKey#10950" or mainDistrict == "LocKey#10967" or mainDistrict == "LocKey#10965"

        if killer:IsPlayer() and richDistrict then
            self.exportData.value = self.exportData.value + 0.05
        end
    end)
end

function trigger:update() -- Gets called onUpdate

end

return trigger