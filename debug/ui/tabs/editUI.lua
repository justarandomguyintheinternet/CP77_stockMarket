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
        stock.sharesAmount = ImGui.InputInt("Shares Amount", stock.sharesAmount)
        stock.min = ImGui.InputInt("Share Min Price", stock.min)
        stock.max = ImGui.InputInt("Share Max Price", stock.max)
        stock.smoothOff = ImGui.InputInt("Share MinMax Delta Power", stock.smoothOff)
        stock.maxStepSize = ImGui.InputFloat("Share Max Step", stock.maxStepSize)

        ImGui.Separator()
    end
end

return editUI