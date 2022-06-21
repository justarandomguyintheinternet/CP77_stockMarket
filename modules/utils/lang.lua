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
        ["info_post_portfolio"] = "Vermögen nach Transaktion",
        ["info_margin"] = "Gewinn",
        ["stocks_ascending"] = "Aufsteigend",
        ["stocks_descending"] = "Absteigend",
        ["stockInfo_Arasaka"] = ""
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
        ["info_post_portfolio"] = "Money after transaction",
        ["info_margin"] = "Profit",
        ["stocks_ascending"] = "Ascending",
        ["stocks_descending"] = "Descending",

        ["stockInfo_Arasaka"] = "The Arasaka Corporation, is a world-wide megacorporation dealing in corporate security, banking, and manufacturing. It is one of the most influential megacorporations in the world",
        ["stockInfo_Biotechnica"] = "Biotechnica specializes in genetically modifying crops, more specifically grains. It has developed a patent on a new species of GMO wheat known as V. Megasuavis, the key ingredient in the production of CHOOH2 the supposed \"fuel of the future\".",
        ["stockInfo_Kang Tao"] = "Kang Tao went from a small failing company, to a massive corporation within 20 years, partly due to constant funding by the Chineese government. By 2077, Kang Tao is now competing with the top dog industry giants, such as Arasaka and Tsunami.",
        ["stockInfo_Militech"] = "Militech, formerly Armatech-Luccessi, is a military-industrial arms giant. Commonly known as the largest weapons manufacturer in the world.",
        ["stockInfo_WNS"] = "WNS is a London-based news service that operates worldwide. WNS keeps tabs on the world, by any means possible. Newspapers and news stations around the world pay large amounts of money to receive WNS stories via the WorldSat Network."
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
lang.info_margin = "info_margin"
lang.stocks_ascending = "stocks_ascending"
lang.stocks_descending = "stocks_descending"

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