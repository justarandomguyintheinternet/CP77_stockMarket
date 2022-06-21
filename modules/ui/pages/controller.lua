local ink = require("modules/ui/inkHelper")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")

controller = {}

function controller:new(browserController, catcher, mod)
	local o = {}

    o.browserController = browserController
    o.catcher = catcher
    o.mod = mod

    o.loginPage = nil
    o.homePage = nil
    o.stockInfo = nil
    o.stocksPage = nil
    o.currentInfoStock = nil

    o.activePage = ""

	self.__index = self
   	return setmetatable(o, self)
end

function controller:initialize()
    if self.loginPage or self.homePage or self.stockInfo then self:uninitialize() end
    self.loginPage = require("modules/ui/pages/login"):new(self.browserController.currentPage, self, self.catcher)
    self.homePage = require("modules/ui/pages/home"):new(self.browserController.currentPage, self, self.catcher, self.mod)
    self.stockInfo = require("modules/ui/pages/stock"):new(self.browserController.currentPage, self, self.catcher, self.mod)
    self.stocksPage = require("modules/ui/pages/stocks"):new(self.browserController.currentPage, self, self.catcher, self.mod)
    self:switchToPage("login")
end

function controller:uninitialize()
    self.loginPage:uninitialize()
    self.homePage:uninitialize()
    self.stockInfo:uninitialize()
    self.stocksPage:uninitialize()
end

function controller:switchToPage(page)
    self.activePage = page
    if page == "login" then
        self.homePage:uninitialize()
        self.stockInfo:uninitialize()
        self.stocksPage:uninitialize()
        self.loginPage:initialize()
    elseif page == "home" then
        self.loginPage:uninitialize()
        self.stockInfo:uninitialize()
        self.stocksPage:uninitialize()
        self.homePage:initialize()
    elseif page == "stockInfo" then
        self.loginPage:uninitialize()
        self.homePage:uninitialize()
        self.stocksPage:uninitialize()
        self.stockInfo:initialize(self.currentInfoStock)
    elseif page == "stocks" then
        self.loginPage:uninitialize()
        self.homePage:uninitialize()
        self.stockInfo:uninitialize()
        self.stocksPage:initialize()
    end
    inkTextRef.SetText(self.browserController.addressText, self:getPageAdress())
end

function controller:getPageAdress()
    if self.activePage == "login" then
        return "NETdir://nusa.stockXC.corp/login"
    elseif self.activePage == "home" then
        return "NETdir://nusa.stockXC.corp/home"
    elseif self.activePage == "stocks" then
        return "NETdir://nusa.stockXC.corp/stocks"
    elseif self.activePage == "stockInfo" then
        return "NETdir://nusa.stockXC.corp/stocks/" .. self.currentInfoStock.name
    end
end

return controller