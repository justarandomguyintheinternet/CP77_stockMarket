local Cron = require("modules/external/Cron")

trigger = {}

function trigger:new()
	local o = {}

    -- Default data
    o.name = "kaukazAction"
    o.fadeSpeed = 0.005
    o.exportData = {
        value = 0
    }

    o.cooldown = false

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
    Observe("VehicleComponent", "StealVehicle", function(this)
        if self.cooldown then return end
        self.cooldown = true
        if this:GetVehicle():GetRecord():Manufacturer():Type() ~= gamedataVehicleManufacturer.Kaukaz then return end
        Cron.After(1, function ()
            self.cooldown = false
        end)
        self.exportData.value = self.exportData.value - 0.12
    end)

    Cron.Every(5, function ()
        local veh = GetMountedVehicle(GetPlayer())
        if veh ~= nil then
            if veh:GetRecord():Manufacturer():Type() ~= gamedataVehicleManufacturer.Kaukaz then return end
            self.exportData.value = math.min(1, self.exportData.value + 0.005)
        end
    end)
end

function trigger:update() end

return trigger