local utils = require("modules/utils/utils")
local config = require("modules/utils/config")

editUI = {
    currentStock = nil
}

function editUI.draw(debug, mod)
    if editUI.currentStock ~= nil then
        local stock = editUI.currentStock
        local name = stock.name

        stock.name, changed =  ImGui.InputTextWithHint("Stock Name", "Name...", stock.name, 100)
        if changed then
            os.rename("data/static/stocks/" .. name .. ".json", "data/static/stocks/" .. stock.name .. ".json")
        end

        stock.startPrice = ImGui.InputInt("Start Price", stock.startPrice)
        stock.priceSpread = ImGui.InputFloat("Price Spread", stock.priceSpread)

        ImGui.Separator()
    end
end

return editUI