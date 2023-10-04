local catcher = require("modules/ui/eventCatcher")
local lang = require("modules/utils/lang")
local utils = require("modules/utils/utils")
local Cron = require("modules/external/Cron")

browser = {
    openedCustom = false,
    controllers = {},
    internetFromStock = false
}

function browser.init(mod)
    catcher.init()

    ObserveAfter("ComputerMenuButtonController", "Initialize", function(this, _, data)
        if data.widgetName == "stock" then
            ---@type inkImageWidget
            local icon = this.iconWidget
            icon:SetAtlasResource(ResRef.FromName("base\\icon\\stock_browser_icon.inkatlas")) -- https://freeicons.io/graph-icon-set/graph-stock-analytic-infographic-growth-statistic-circle-data-icon-554960
            icon:SetTexturePart("stock")
        end
    end)

    Override("ComputerControllerPS", "GetMenuButtonWidgets", function (this, wrapped)
        local buttons = wrapped()

        local widgetPackage = SComputerMenuButtonWidgetPackage.new()
        widgetPackage.widgetName = "stock"
        widgetPackage.displayName = lang.getText(lang.pc_stockmarket)
        widgetPackage.ownerID = this:GetID()
        widgetPackage.iconID = "iconInternet"
        widgetPackage.widgetTweakDBID = this:GetMenuButtonWidgetTweakDBID()
        widgetPackage.libraryID, widgetPackage.libraryPath = SWidgetPackageBase.ResolveWidgetTweakDBData(widgetPackage.widgetTweakDBID)
        widgetPackage.isValid = true

        table.insert(buttons, widgetPackage)

        return buttons
    end)

    Override("ComputerInkGameController", "ShowMenuByName", function (this, adress, wrapped)
        if adress == "stock" then
            for _, c in pairs(browser.controllers) do -- Avoid refresh if the page is already open
                if utils.isSameInstance(this:GetOwner(), c.pc) then
                    return
                end
            end
            browser.openedCustom = true
            this:ShowInternet()
            this:GetMainLayoutController():MarkManuButtonAsSelected("stock")
        else
            for key, c in pairs(browser.controllers) do -- Different menu
                if utils.isSameInstance(this:GetOwner(), c.pc) then
                    browser.tryUninitController(key)
                end
            end
            wrapped(adress)
        end
    end)

    Observe("BrowserGameController", "OnUninitialize", function (this) -- PC despawn
        for key, c in pairs(browser.controllers) do
            if utils.isSameInstance(this:GetOwnerEntity(), c.pc) then
                browser.tryUninitController(key)
            end
        end
    end)

    Override("BrowserController", "SetDefaultPage", function (_, adress, wrapped)
        if browser.openedCustom then
            browser.openedCustom = false
            adress = "stocks"
        end
        wrapped(adress)
    end)

    ObserveAfter("BrowserController", "OnPageSpawned", function (this)
        if browser.internetFromStock then
            browser.internetFromStock = false
            this.currentPage:RemoveAllChildren()

            for key, c in pairs(browser.controllers) do
                if utils.isSameInstance(this:GetOwnerGameObject(), c.pc) then
                    browser.tryUninitController(key)
                end
            end

            local controller = require("modules/ui/pages/controller"):new(this, catcher, mod)
            controller:initialize()
            table.insert(browser.controllers, {controller = controller, pc = this:GetOwnerGameObject()})
        end
    end)

    Override("BrowserController", "LoadWebPage", function (this, adress, wrapped)
        if adress == "stocks" then
            this:LoadWebPage("NETdir://ncity.pub") -- Ensure that the currentPage is a valid inkWidget
            browser.internetFromStock = true
        else
            wrapped(adress)
        end
    end)
end

function browser.tryUninitController(key)
    local success = false
    pcall(function ()
        browser.controllers[key].controller:uninitialize()
        browser.controllers[key] = nil
        success = true
    end)
    if not success then
        browser.controllers[key] = nil
    end
end

return browser