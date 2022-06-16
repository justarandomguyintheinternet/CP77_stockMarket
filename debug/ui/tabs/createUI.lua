local config = require("modules/utils/config")

createUI = {
    name = ""
}

function createUI.draw()
    createUI.name =  ImGui.InputTextWithHint("Stock Name", "Name...", createUI.name, 100)

    if ImGui.Button("Create") then
        local stock = {
            name = createUI.name,
            triggers = {},
            startPrice = 0,
            priceSpread = 0.5
        }
        config.saveFile("data/static/stocks/" .. stock.name .. ".json", stock)
        createUI.name = ""
    end
end

return createUI