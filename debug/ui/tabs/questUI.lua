local utils = require("modules/utils/utils")
local config = require("modules/utils/config")

questUI = {
    quests = nil,
    filter = "",
    currentStockSelect = 0,
    stocks = {}
}

function questUI.load()
    if questUI.quests == nil then
        config.tryCreateConfig("data/static/quests/quests.json", {})
        questUI.quests = config.loadFile("data/static/quests/quests.json")

        local requestContext = JournalRequestContext.new({
            stateFilter = JournalRequestStateFilter.new({
                active = true,
                succeeded = true,
            })
        })

        local quests = Game.GetJournalManager():GetQuests(requestContext)
        for _, quest in ipairs(quests) do
            local name = quest:GetTitle(Game.GetJournalManager())
            if questUI.quests[name] == nil then
                print("[StockMarketDebug] Added quest: " .. GetLocalizedText(name))
                questUI.quests[name] = {
                    name = name,
                    amount = 1,
                    fade = 0.05
                }
            end
        end

        table.sort(questUI.quests, function (a, b)
            return GetLocalizedText(a.name) < GetLocalizedText(b.name)
        end)

        config.saveFile("data/static/quests/quests.json", questUI.quests)
    end

    for _, file in pairs(dir("data/static/stocks/")) do
        if file.name:match("^.+(%..+)$") == ".json" then
            local name = file.name:match("(.+)%..+$")
            if questUI.stocks[name] == nil then
                questUI.stocks[name] = config.loadFile("data/static/stocks/" .. name .. ".json")
            end
        end
    end
end

function questUI.drawStocks(quest, mod)
    local stockList = {"--Select stock--"}
    for _, stock in pairs(mod.market.stocks) do
        table.insert(stockList, stock.name)
    end

    if ImGui.Button("Add") and questUI.currentStockSelect ~= 0 then
        table.insert(questUI.stocks[stockList[questUI.currentStockSelect + 1]].triggers, {
            name = "quest_" .. quest.name,
            amount = 0.1
        })

        config.saveFile("data/static/stocks/".. stockList[questUI.currentStockSelect + 1] .. ".json", questUI.stocks[stockList[questUI.currentStockSelect + 1]])
    end

    ImGui.SameLine()
    questUI.currentStockSelect = ImGui.Combo("Stock to influence", questUI.currentStockSelect, stockList, #stockList)

    ImGui.Separator()

    for _, stock in pairs(questUI.stocks) do
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

function questUI.draw(debug, mod)
    questUI.load()

    questUI.filter = ImGui.InputTextWithHint('##Filter', 'Search for quest...', questUI.filter, 25)

    if questUI.filter ~= '' then
        ImGui.SameLine()
        if ImGui.Button('X') then
            questUI.filter = ''
        end
    end

    ImGui.Separator()

    for _, quest in pairs(questUI.quests) do
        if (GetLocalizedText(quest.name):lower():match(questUI.filter:lower())) ~= nil then
            local state = ImGui.CollapsingHeader(GetLocalizedText(quest.name))
            if state then
                ImGui.PushID(quest.name)

                ImGui.Indent(25)
                quest.amount, changed = ImGui.InputFloat("Amount", quest.amount)
                if changed then config.saveFile("data/static/quests/quests.json", questUI.quests) end
                quest.fade, changed = ImGui.InputFloat("Fade speed", quest.fade, 0, 5,  "%.5f")
                if changed then config.saveFile("data/static/quests/quests.json", questUI.quests) end

                local state = ImGui.CollapsingHeader("Stocks")
                if state then
                    ImGui.Indent(25)
                    questUI.drawStocks(quest, mod)
                    ImGui.Unindent(25)
                end

                ImGui.Unindent(25)

                ImGui.PopID()
            end
        end
    end
end

return questUI