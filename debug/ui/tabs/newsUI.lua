local utils = require("modules/utils/utils")
local config = require("modules/utils/config")

newsUI = {
    news = nil,
    newsMeta = nil,
    filter = "",
    currentStockSelect = 0,
    stocks = {}
}

function newsUI.load(mod)
    if newsUI.news == nil then
        newsUI.news = {}
        for _, l in pairs(Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValues()) do
            local language = l.value

            if not config.fileExists("localization/news/" .. language .. ".json") then
                config.tryCreateConfig("localization/news/" .. language .. ".json", {})
            end

            local locFile = config.loadFile("localization/news/" .. language .. ".json")

            for name, _ in pairs(mod.market.triggerManager.triggers) do
                if not mod.market.stocks[name] and locFile[name] == nil then
                    locFile[name] = {title = "", msg = ""}
                end
            end

            config.saveFile("localization/news/" .. language .. ".json", locFile)
            newsUI.news[language] = locFile
        end
    end

    if not newsUI.newsMeta then
        config.tryCreateConfig("data/static/news/newsQuestDelays.json", {})
        newsUI.newsMeta = config.loadFile("data/static/news/newsQuestDelays.json")

        for name, _ in pairs(mod.market.triggerManager.triggers) do
            if not mod.market.stocks[name] and name:match("LocKey") then
                if not newsUI.newsMeta[name] then
                    newsUI.newsMeta[name] = 2 -- News delay
                end
            end
        end

        config.saveFile("data/static/news/newsQuestDelays.json", newsUI.newsMeta)
    end
end

function newsUI.drawStocks(quest, mod)
    local stockList = {"--Select stock--"}
    for _, stock in pairs(mod.market.stocks) do
        table.insert(stockList, stock.name)
    end
    table.sort(stockList, function(a, b)
        return a < b
    end)

    if ImGui.Button("Add") and newsUI.currentStockSelect ~= 0 then
        table.insert(newsUI.stocks[stockList[newsUI.currentStockSelect + 1]].triggers, {
            name = "quest_" .. quest.name,
            amount = 0.1
        })

        config.saveFile("data/static/stocks/".. stockList[newsUI.currentStockSelect + 1] .. ".json", newsUI.stocks[stockList[newsUI.currentStockSelect + 1]])
    end

    ImGui.SameLine()
    newsUI.currentStockSelect = ImGui.Combo("Stock to influence", newsUI.currentStockSelect, stockList, #stockList)

    ImGui.Separator()

    for _, stock in pairs(newsUI.stocks) do
        local hasQuest = false
        local trigger = nil
        for _, t in pairs(stock.triggers) do
            if t.name == "quest_" .. quest.name then
                hasQuest = true
                trigger = t
            end
        end

        if hasQuest then
            ImGui.PushID(stock.name)

            ImGui.Text(stock.name)
            ImGui.SameLine()
            ImGui.PushItemWidth(50)
            trigger.amount, changed = ImGui.InputFloat("##amount", trigger.amount)
            ImGui.PopItemWidth()
            if changed then config.saveFile("data/static/stocks/".. stock.name .. ".json", stock) end
            ImGui.SameLine()
            ImGui.Text("|Total=" .. utils.round(quest.amount * trigger.amount, 2) .. ";Duration=" .. utils.round((((quest.amount * trigger.amount) / quest.fade) * mod.intervall) / 60, 2) .. "min|")
            ImGui.SameLine()
            if ImGui.Button("Remove") then
                utils.removeItem(stock.triggers, trigger)
                config.saveFile("data/static/stocks/".. stock.name .. ".json", stock)
            end
            ImGui.Separator()

            ImGui.PopID()
        end
    end
end

function newsUI.draw(_, mod)
    newsUI.load(mod)

    newsUI.filter = ImGui.InputTextWithHint('##Filter', 'Search for trigger...', newsUI.filter, 25)

    if newsUI.filter ~= '' then
        ImGui.SameLine()
        if ImGui.Button('X') then
            newsUI.filter = ''
        end
    end

    ImGui.Separator()

    local language = Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value

    for name, text in pairs(newsUI.news[language]) do
        local name = name
        local trigger = name

        if string.match(name, "LocKey") then
            local lockey = string.gsub(name, "quest_", "")
            name = GetLocalizedText(lockey)
        end

        if (name:lower():match(newsUI.filter:lower())) ~= nil then
            local state = ImGui.CollapsingHeader(name)
            if state then
                ImGui.PushID(name)

                ImGui.Indent(25)

                ImGui.PushItemWidth(450)

                text.title, changed = ImGui.InputTextWithHint("##title", "News Title...", text.title, 100000)
                if changed then config.saveFile("localization/news/" .. language .. ".json", newsUI.news[language]) end
                text.msg, changed = ImGui.InputTextWithHint("##msg", "News Message...", text.msg, 100000)
                if changed then config.saveFile("localization/news/" .. language .. ".json", newsUI.news[language]) end
                ImGui.PopItemWidth()

                ImGui.PushItemWidth(50)
                newsUI.newsMeta[trigger], changed = ImGui.InputFloat("News message Delay", newsUI.newsMeta[trigger])
                if changed then config.saveFile("data/static/news/newsQuestDelays.json", newsUI.newsMeta) end
                ImGui.PopItemWidth()

                ImGui.Unindent(25)

                ImGui.PopID()
            end
        end
    end
end

return newsUI