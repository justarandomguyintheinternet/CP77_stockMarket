local lang = {
    ["de-de"] = {
        ["pc_stockmarket"] = "Börse",
        ["login_name"] = "Name",
        ["login_password"] = "Passwort",
        ["button_home"] = "Hauptseite",
        ["button_stocks"] = "Aktien",
        ["button_portfolio"] = "Portfolio",
        ["button_login"] = "Anmelden",
        ["button_logout"] = "Abmelden",
        ["graph_time"] = "Zeit",
        ["graph_value"] = "Marktwert",
        ["info_value"] = "Wert",
        ["info_buy"] = "Kaufen",
        ["info_sell"] = "Verkaufen",
        ["info_owned"] = "Im Besitz",
        ["info_transaction"] = "Transaktionskosten",
        ["info_post_portfolio"] = "Vermögen nach Transaktion"
    },
    ["en-us"] = {
        ["pc_stockmarket"] = "Stock Market",
        ["login_name"] = "Name",
        ["login_password"] = "Password",
        ["button_home"] = "Home",
        ["button_stocks"] = "Stocks",
        ["button_portfolio"] = "Portfolio",
        ["button_login"] = "Login",
        ["button_logout"] = "Logout",
        ["graph_time"] = "Time",
        ["graph_value"] = "Market Value",
        ["info_value"] = "Value",
        ["info_buy"] = "Buy",
        ["info_sell"] = "Sell",
        ["info_owned"] = "In Account",
        ["info_transaction"] = "Cost of transaction",
        ["info_post_portfolio"] = "Money after transaction"
    }
}

lang.pc_stockmarket = "pc_stockmarket"
lang.button_home = "button_home"
lang.button_stocks = "button_stocks"
lang.button_portfolio = "button_portfolio"
lang.button_login = "button_login"
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

function lang.getLang()
    local l = Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
    if lang[l] == nil then
        return "en-us"
    else
        return l
    end
end

function lang.getText(key)
    return lang[lang.getLang()][key]
end

function lang.getKey(text)
    for k, v in pairs(lang[lang.getLang()]) do
        if v == text then return k end
    end
end

return lang