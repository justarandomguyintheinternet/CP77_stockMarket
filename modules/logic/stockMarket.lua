local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")
local GameSession = require("modules/external/GameSession")
local lang = require("modules/utils/lang")

market = {}

function market:new(intervall, triggerManager, questManager, newsManager)
	local o = {}

    o.stocks = {}
    o.marketStock = nil
    o.portfolioStock = nil

    o.triggerManager = triggerManager
    o.questManger = questManager
    o.newsManager = newsManager

    o.persistentData = {
        stocks = {},
        triggers = {},
        news = {},
        settings = {}
    }

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
    self.newsManager:checkForData(self.persistentData)

    for _, trigger in pairs(self.triggerManager.triggers) do
        trigger:checkForData(self.persistentData)
    end
end

function market:initialize() -- Generate stock instances from json files
    Cron.Every(self.intervall, function ()
        self:update()
    end)
    Cron.Every(30, function () -- Update triggers seperate, as their fadeOff speed is meant for 30s intervalls
        self.triggerManager:step()
    end)
    self.newsManager:onInit()

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

    pStock:loadFromDefinition({name = "portfolio", min = 0, max = 0})

    pStock.loadDefault = function(st)
        local points = {}
        for i = 1, self.range do
            points[i] = 0
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
        for k, v in pairs(st.exportData.data) do
            points[k] = v
        end
        st.exportData.data = points
    end

    pStock.update = function(st)
        local shift = {}
        for i = 2, #st.exportData.data do -- Shift table, to remove first element
            shift[i - 1] = st.exportData.data[i]
        end

        local y = 0
        for _, stock in pairs(self.stocks) do
            y = y + stock:getPortfolioNum() * stock:getCurrentPrice()
        end

        shift[#shift + 1] = y
        st.exportData.data = shift
    end

    self.portfolioStock = pStock
end

function market:setupMarketStock()
    local mStock = require("modules/logic/stock"):new(self.range, self)
    mStock:loadFromDefinition({name = "NC ETF", info = "stockInfo_etf", min = 0, max = 0, atlasPath = "base\\icon\\stocks\\etf.inkatlas", atlasPart = "stock", iconX = 415, iconY = 94})

    mStock.loadDefault = function(st)
        local nStocks = self:getNumberStocks()

        local points = {}
        for i = 1, self.range do
            local y = 0
            for _, stock in pairs(self.stocks) do
                y = y + stock.exportData.data[i] * stock.sharesAmount * 0.0001
            end
            points[i] = y / nStocks
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
        for k, v in pairs(st.exportData.data) do
            points[k] = v
        end
        st.exportData.data = points

        if not st.exportData.owned or not st.exportData.owned then
            st.exportData.owned = 0
            st.exportData.spent = 0
        end
    end

    mStock.update = function(st)
        local shift = {}
        for i = 2, #st.exportData.data do -- Shift table, to remove first element
            shift[i - 1] = st.exportData.data[i]
        end

        local nStocks = self:getNumberStocks()

        local y = 0
        for _, stock in pairs(self.stocks) do
            y = y + stock.exportData.data[self.range] * stock.sharesAmount * 0.0001
        end

        local value = y / nStocks
        shift[#shift + 1] = utils.round(value, 2)
        st.exportData.data = shift
    end

    self.marketStock = mStock
end

function market:getTopStocks()
    local keys = {}
	for k, _ in pairs(self.stocks) do
		table.insert(keys, k)
	end

	local top1 = {k = "", n = -100}
	for _, key in pairs(keys) do
		local trend = self.stocks[key]:getTrend()
		if trend > top1.n then
			top1.n = trend
			top1.k = key
		end
	end
	utils.removeItem(keys, top1.k)

	local top2 = {k = "", n = -100}
	for _, key in pairs(keys) do
		local trend = self.stocks[key]:getTrend()
		if trend > top2.n then
			top2.n = trend
			top2.k = key
		end
	end
	utils.removeItem(keys, top2.k)

	local low1 = {k = "", n = 100}
	for _, key in pairs(keys) do
		local trend = self.stocks[key]:getTrend()
		if trend < low1.n then
			low1.n = trend
			low1.k = key
		end
	end
	utils.removeItem(keys, low1.k)

	local low2 = {k = "", n = 100}
	for _, key in pairs(keys) do
		local trend = self.stocks[key]:getTrend()
		if trend < low2.n then
			low2.n = trend
			low2.k = key
		end
	end
	utils.removeItem(keys, low2.k)

    return {top1 = self.stocks[top1.k], top2 = self.stocks[top2.k], low1 = self.stocks[low1.k], low2 = self.stocks[low2.k]}
end

function market:update() -- Main market update loop
    for _, stock in pairs(self.stocks) do
        stock:update()
    end
    self.marketStock:update()
    self.portfolioStock:update()
end

function market:overflowReset() -- Well, shit
    print("[StockMarket] OverflowReset initiated")
    for _, stock in pairs(self.stocks) do
        local owned = stock.exportData.owned
        local spent = stock.exportData.spent
        self.persistentData.stocks[stock.name] = nil
        stock:checkForData(self.persistentData)
        stock.exportData.owned = owned
        stock.exportData.spent = spent
    end
    self.persistentData.stocks["stock_market"] = nil
    self.marketStock:checkForData(self.persistentData)
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
        for _ = 0, diff * (14) do -- Fixed 30s time step for triggers
            self.triggerManager:step()
        end
        for _ = 0, diff * (85) do -- Fixed 30s time step for triggers
            self.newsManager:update()
        end
    end
    self.time = Game.GetTimeSystem():GetGameTime():Hours()
end

return market