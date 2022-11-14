local config = require("modules/utils/config")

local lang = {}

lang.pc_stockmarket = "pc_stockmarket"
lang.button_home = "button_home"
lang.button_stocks = "button_stocks"
lang.button_portfolio = "button_portfolio"
lang.button_news = "button_news"
lang.login_login = "login_login"
lang.button_logout = "button_logout"
lang.graph_time = "graph_time"
lang.graph_value = "graph_value"
lang.login_name = "login_name"
lang.login_password = "login_password"
lang.info_value = "info_value"
lang.info_buy = "info_buy"
lang.info_sell = "info_sell"
lang.info_owned = "info_owned"
lang.info_transaction = "info_transaction"
lang.info_post_portfolio = "info_post_portfolio"
lang.info_margin = "info_margin"
lang.stocks_ascending = "stocks_ascending"
lang.stocks_descending = "stocks_descending"
lang.portfolio_accountValue = "portfolio_accountValue"
lang.portfolio_ownedStocks = "portfolio_ownedStocks"
lang.portfolio_totalMoney = "portfolio_totalMoney"
lang.portfolio_moneyInStocks = "portfolio_moneyInStocks"
lang.news_toggleNotification = "news_toggleNotification"
lang.news_contactName = "news_contactName"

function lang.getLang(key)
    local language = Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
    local loc = require("localization/" .. language)

    if loc[key] == "" then
        return "en-us"
    else
        return language
    end
end

function lang.getText(key)
    local language = lang.getLang(key)
    local loc = require("localization/" .. language)
    local text = loc[key]

    if text == "" then
        return "Not Localized"
    else
        return text
    end
end

function lang.getNewsLang(key)
    local language = Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
    local loc = config.loadFile("localization/news/" .. language .. ".json")

    if loc[key]["default"]["title"] == "" or loc[key]["default"]["msg"] == "" then
        return "en-us"
    else
        return language
    end
end

function lang.getNewsText(key, condition)
    local loc = config.loadFile("localization/news/" .. lang.getNewsLang(key) .. ".json")

    local subNews = "default"
    if condition then subNews = "choice" end
    local title = loc[key][subNews]["title"]
    local msg = loc[key][subNews]["msg"]

    return title, msg
end

return lang