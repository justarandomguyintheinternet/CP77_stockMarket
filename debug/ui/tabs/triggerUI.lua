triggerUI = {
    hideStocks = true
}

function triggerUI.draw(mod)
    triggerUI.hideStocks = ImGui.Checkbox("Hide stock triggers", triggerUI.hideStocks)
    ImGui.Separator()

    for key, trigger in pairs(mod.market.triggerManager.triggers) do
        if not (triggerUI.hideStocks and mod.market.stocks[key]) then
            ImGui.Text(trigger.name .. ": " .. trigger.exportData.value)
            ImGui.SameLine()
            if ImGui.Button("Reset") then
                trigger.exportData.value = 0
            end
            ImGui.SameLine()
            if ImGui.Button("Add .1") then
                trigger.exportData.value = trigger.exportData.value + 0.1
            end
        end
    end
end

return triggerUI