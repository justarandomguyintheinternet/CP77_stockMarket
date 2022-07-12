baseUI = {
    createUI = require("debug/ui/tabs/createUI"),
    fileUI = require("debug/ui/tabs/fileUI"),
    loadedUI = require("debug/ui/tabs/loadedUI"),
    editUI = require("debug/ui/tabs/editUI"),
    triggerUI = require("debug/ui/tabs/triggerUI"),
    switchToEdit = false,
    switchToLoaded = false
}

function baseUI.getSwitchFlag(tab)
    if tab == "edit" and baseUI.switchToEdit then
        baseUI.switchToEdit = false
        return ImGuiTabItemFlags.SetSelected
    elseif tab == "loaded" and baseUI.switchToLoaded then
        baseUI.switchToLoaded = false
        return ImGuiTabItemFlags.SetSelected
    else
        return ImGuiTabItemFlags.None
    end
end

function baseUI.draw(mod)
    ImGui.Begin("StockMarket Debug Tool", ImGuiWindowFlags.AlwaysAutoResize)

    if ImGui.BeginTabBar("Tabbar", ImGuiTabBarFlags.NoTooltip) then
        if ImGui.BeginTabItem("Create Stock") then
            baseUI.createUI.draw()
            ImGui.EndTabItem()
        end

        if ImGui.BeginTabItem("Loaded Stocks", baseUI.getSwitchFlag("loaded")) then
            baseUI.loadedUI.draw(baseUI)
            ImGui.EndTabItem()
        end

        if ImGui.BeginTabItem("Edit", baseUI.getSwitchFlag("edit")) then
            baseUI.editUI.draw(baseUI, mod)
            ImGui.EndTabItem()
        end

        if ImGui.BeginTabItem("Stock Files") then
            baseUI.fileUI.draw(baseUI)
            ImGui.EndTabItem()
        end

        if ImGui.BeginTabItem("Triggers") then
            baseUI.triggerUI.draw(mod)
            ImGui.EndTabItem()
        end

        ImGui.EndTabBar()
    end

    ImGui.End()
end

return baseUI