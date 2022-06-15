local ink = require("modules/ui/inkHelper")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")

controller = {}

function controller:new(browserController, catcher)
	local o = {}

    o.browserController = browserController
    o.catcher = catcher

    o.loginPage = nil
    o.homePage = nil

    o.activePage = ""

	self.__index = self
   	return setmetatable(o, self)
end

function controller:initialize()
    self.loginPage = require("modules/ui/pages/login"):new(self.browserController.currentPage, self, self.catcher)
    self.homePage = require("modules/ui/pages/home"):new(self.browserController.currentPage, self, self.catcher)
    self:switchToPage("login")
end

function controller:switchToPage(page)
    self.activePage = page
    if page == "login" then
        self.homePage:uninitialize()
        self.loginPage:initialize()
    elseif page == "home" then
        self.loginPage:uninitialize()
        self.homePage:initialize()
    end
    inkTextRef.SetText(self.browserController.addressText, self:getPageAdress())
end

function controller:getPageAdress()
    if self.activePage == "login" then
        return "NETdir://nusa.stockXC.corp/login"
    elseif self.activePage == "home" then
        return "NETdir://nusa.stockXC.corp/home"
    end
end

return controller