local lang = {
    ["de-de"] = {
        ["pc_stockmarket"] = "Börse",
        ["login_name"] = "Name",
        ["login_password"] = "Passwort",
        ["button_home"] = "Hauptseite",
        ["button_stocks"] = "Aktien",
        ["button_portfolio"] = "Portfolio",
        ["login_login"] = "Anmelden",
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
        ["portfolio_accountValue"] = "Konto Wert",
        ["portfolio_ownedStocks"] = "Aktien im Besitz",
        ["portfolio_totalMoney"] = "Vermögen",
        ["portfolio_moneyInStocks"] = "In Aktien"
    },
    ["en-us"] = {
        ["pc_stockmarket"] = "Stock Market",
        ["login_name"] = "Name",
        ["login_password"] = "Password",
        ["button_home"] = "Home",
        ["button_stocks"] = "Stocks",
        ["button_portfolio"] = "Portfolio",
        ["login_login"] = "Login",
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
        ["portfolio_accountValue"] = "Account Value",
        ["portfolio_ownedStocks"] = "Owned Stocks",
        ["portfolio_totalMoney"] = "Total wealth",
        ["portfolio_moneyInStocks"] = "In Stocks",

        ["stockInfo_Arasaka"] = "The Arasaka Corporation is a world-wide megacorporation dealing in corporate security, banking, and manufacturing. It is one of the most influential megacorporations in the world. Arasaka-branded weapons and military vehicles are among the most sought after by police and security firms.",
        ["stockInfo_Biotechnica"] = "Biotechnica specializes in genetically modifying crops, more specifically grains. It has developed a patent on a new species of GMO wheat known as V. Megasuavis, the key ingredient in the production of CHOOH2 the supposed \"fuel of the future\".",
        ["stockInfo_Kang Tao"] = "Kang Tao went from a small failing company, to a massive corporation within 20 years, partly due to constant funding by the Chineese government. By 2077, Kang Tao is now competing with the top dog industry giants, such as Arasaka and Tsunami.",
        ["stockInfo_Militech"] = "Militech, formerly Armatech-Luccessi, is a military-industrial arms giant. Commonly known as the largest weapons manufacturer in the world.",
        ["stockInfo_WNS"] = "WNS is a London-based news service that operates worldwide. WNS keeps tabs on the world, by any means possible. Newspapers and news stations around the world pay large amounts of money to receive WNS stories via the WorldSat Network.",
        ["stockInfo_Petrochem"] = "Petrochem, formerly Parker Petrochemicals, is are the largest producer of CHOOH2 in the US. They are also responsible for manufacturing many agricultural products.",
        ["stockInfo_Zetatech"] = "Zetatech is originally a small company from the Silicon Valley. Specializing in computer hardware, software, and wetware design, the company is among the main providers of neural processors, microchips, and robotics on the American market. They also manufacture aerodyne gunships, as well as security, combat, and utility drones.",
        ["stockInfo_Kiroshi Optics"] = "Kiroshi is an industry leader in optics design and manufacturing, and holds a monopoly on the cyber optics market. Kiroshi deals worldwide and a majority of people utilizing optics are using their products.",
        ["stockInfo_Orbital Air"] = "Orbital Air specializes in cargo and passenger transport to Earth's orbit. Orbital Air can be found on nearly every continent, with multiple space facilities in low orbit. Their spaceplanes are mostly manufactured and owned by them, however JAB and ESA manufacture their own and are used when travelling to their respective territories.",
        ["stockInfo_Trauma Team"] = "TTI is specialized paramedics company that will kill anything in their way to assist their injured client.",
        ["stockInfo_Asukaga"] = "Asukaga & Finch (A&F), formerly known as Merill, is an exclusive investment and financial counseling firm, based in New York, NUSA. The company is known for handling and investing very large sums of money on behalf of their global clients.",
        ["stockInfo_All Foods"] = "All Foods Inc. is corporation based in Mexico which focuses on providing its customers with readily available quality food (usually meat based products). The majority of Allfoods products and their sales go to the United States."
    }
}

lang.pc_stockmarket = "pc_stockmarket"
lang.button_home = "button_home"
lang.button_stocks = "button_stocks"
lang.button_portfolio = "button_portfolio"
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

function lang.getLang()
    local l = Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
    if lang[l] == nil then
        return "en-us"
    else
        return l
    end
end

function lang.getText(key)
    local text = lang[lang.getLang()][key]
    if text == nil then
        text = lang["en-us"][key]
        if text == nil then
            return "Not Localized"
        end
        return text
    else
        return lang[lang.getLang()][key]
    end
end

function lang.getKey(text)
    for k, v in pairs(lang[lang.getLang()]) do
        if v == text then return k end
    end
end

return lang