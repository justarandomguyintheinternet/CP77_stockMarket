local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")
local GameSession = require("modules/external/GameSession")
local lang = require("modules/utils/lang")

market = {}

function market:new(intervall, triggerManager, questManager)
	local o = {}

    o.stocks = {}
    o.marketStock = nil
    o.portfolioStock = nil

    o.triggerManager = triggerManager
    o.questManger = questManager
    o.persistentData = {
        stocks = {},
        triggers = {}
    }

    o.updateCron = nil
    o.intervall = intervall
    o.time = 0
    o.range = 90

	self.__index = self
   	return setmetatable(o, self)
end

function market:setupPersistency() -- Setup persistency once onInit
    GameSession.StoreInDir('data/persistent/')
    GameSession.Persist(self.persistentData)
end

function market:checkForData()
    for _, stock in pairs(self.stocks) do
        stock:checkForData(self.persistentData)
    end
    self.marketStock:checkForData(self.persistentData)
    self.portfolioStock:checkForData(self.persistentData)

    for _, trigger in pairs(self.triggerManager.triggers) do
        trigger:checkForData(self.persistentData)
    end
end

function market:initialize() -- Generate stock instances from json files
    self.updateCron = Cron.Every(self.intervall, function ()
        self:update()
    end)

    for _, file in pairs(dir("data/static/stocks/")) do
        if file.name:match("^.+(%..+)$") == ".json" then
            local data = config.loadFile("data/static/stocks/" .. file.name)
            local stock = require("modules/logic/stock"):new(self.range, self)
            stock:loadFromDefinition(data)
            self.stocks[stock.name] = stock
        end
    end

    self.triggerManager:createBuySellTriggers(self.stocks)

    self:setupMarketStock()
    self:setupPortfolioStock()
end

function market:getNumberStocks() -- Get number of stocks, stock market excluded
    local nStocks = 0
    for _, _ in pairs(self.stocks) do nStocks = nStocks + 1 end
    return nStocks
end

function market:setupPortfolioStock()
    local pStock = require("modules/logic/stock"):new(self.range, self)

    pStock:loadFromDefinition({name = "portfolio"})

    pStock.loadDefault = function(st)
        local points = {}
        for i = 1, self.range do
            points[i] = {y = 0, x = i}
        end
        st.exportData.data = points
    end

    pStock.checkForData = function(st, data)
        if data["stocks"]["portfolio"] == nil then
            st:loadDefault()
            data["stocks"]["portfolio"] = st.exportData
        else
            st.exportData = data["stocks"]["portfolio"]
        end

        -- Fix wrong order
        local points = {}
        for _, v in pairs(st.exportData.data) do
            points[#points + 1] = v
        end
        table.sort(points, function(a, b)
            return a.x < b.x
        end)
        st.exportData.data = points
    end

    pStock.update = function(st)
        local shift = {}
        for i = 2, #st.exportData.data do -- Shift table, to remove first element
            local v = st.exportData.data[i]
            v.x = v.x - 1
            shift[i - 1] = v
        end

        local y = 0
        for _, stock in pairs(self.stocks) do
            y = y + stock:getPortfolioNum() * stock:getCurrentPrice()
        end

        shift[#shift + 1] = {x = #shift + 1, y = y}
        st.exportData.data = shift
    end

    self.portfolioStock = pStock
end

function market:setupMarketStock()
    local mStock = require("modules/logic/stock"):new(self.range, self)
    mStock:loadFromDefinition({name = lang.getText(lang.pc_stockmarket)})

    mStock.loadDefault = function(st)
        local nStocks = self:getNumberStocks()

        local points = {}
        for i = 1, self.range do
            local y = 0
            for _, stock in pairs(self.stocks) do
                y = y + stock.exportData.data[i].y * stock.sharesAmount * 0.0001
            end
            points[i] = {y = y / nStocks, x = i}
        end

        st.exportData.data = points
    end

    mStock.checkForData = function(st, data)
        if data["stocks"]["stock_market"] == nil then
            st:loadDefault()
            data["stocks"]["stock_market"] = st.exportData
        else
            st.exportData = data["stocks"]["stock_market"]
        end

        -- Fix wrong order
        local points = {}
        for _, v in pairs(st.exportData.data) do
            points[#points + 1] = v
        end
        table.sort(points, function(a, b)
            return a.x < b.x
        end)
        st.exportData.data = points
    end

    mStock.update = function(st)
        local shift = {}
        for i = 2, #st.exportData.data do -- Shift table, to remove first element
            local v = st.exportData.data[i]
            v.x = v.x - 1
            shift[i - 1] = v
        end

        local nStocks = self:getNumberStocks()

        local y = 0
        for _, stock in pairs(self.stocks) do
            y = y + stock.exportData.data[self.range].y * stock.sharesAmount * 0.0001
        end

        local value = y / nStocks
        shift[#shift + 1] = {x = #shift + 1, y = value}
        st.exportData.data = shift
    end

    self.marketStock = mStock
end

function market:update() -- Update loop for Cron intervall
    self.triggerManager:step()
    for _, stock in pairs(self.stocks) do
        stock:update()
    end
    self.marketStock:update()
    self.portfolioStock:update()
end

function market:checkForTimeSkip()
    local diff = Game.GetTimeSystem():GetGameTime():Hours() - self.time
    if Game.GetTimeSystem():GetGameTime():Hours() < self.time then
        diff = (24 - self.time) + Game.GetTimeSystem():GetGameTime():Hours()
    end

    if diff > 0 and Game.GetTimeSystem():GetGameTime():Minutes() ~= 0 then
        for _ = 0, diff * (7 * (60 / self.intervall)) do
            self:update()
        end
    end
    self.time = Game.GetTimeSystem():GetGameTime():Hours()
end

return market