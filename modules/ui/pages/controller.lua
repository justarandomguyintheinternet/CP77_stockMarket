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
    self.portfolioPage = require("modules/ui/pages/portfolio"):new(self.browserController.currentPage, self, self.catcher, self.mod)
    self:switchToPage("login")
end

function controller:uninitialize()
    self.loginPage:uninitialize()
    self.homePage:uninitialize()
    self.stockInfo:uninitialize()
    self.stocksPage:uninitialize()
    self.portfolioPage:uninitialize()
end

function controller:switchToPage(page)
    self.activePage = page
    if page == "login" then
        self.homePage:uninitialize()
        self.stockInfo:uninitialize()
        self.stocksPage:uninitialize()
        self.portfolioPage:uninitialize()
        self.loginPage:initialize()
    elseif page == "home" then
        self.loginPage:uninitialize()
        self.stockInfo:uninitialize()
        self.stocksPage:uninitialize()
        self.portfolioPage:uninitialize()
        self.homePage:initialize()
    elseif page == "stockInfo" then
        self.loginPage:uninitialize()
        self.homePage:uninitialize()
        self.stocksPage:uninitialize()
        self.portfolioPage:uninitialize()
        self.stockInfo:initialize(self.currentInfoStock)
    elseif page == "stocks" then
        self.loginPage:uninitialize()
        self.homePage:uninitialize()
        self.portfolioPage:uninitialize()
        self.stockInfo:uninitialize()
        self.stocksPage:initialize()
    elseif page == "portfolio" then
        self.loginPage:uninitialize()
        self.homePage:uninitialize()
        self.stocksPage:uninitialize()
        self.stockInfo:uninitialize()
        self.portfolioPage:initialize()
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
    elseif self.activePage == "portfolio" then
        return "NETdir://nusa.stockXC.corp/portfolio"
    elseif self.activePage == "stockInfo" then
        return "NETdir://nusa.stockXC.corp/stocks/" .. string.gsub(self.currentInfoStock.name, "%s", "_")
    end
end

return controller