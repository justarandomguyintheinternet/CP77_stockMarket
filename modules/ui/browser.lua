local catcher = require("modules/ui/eventCatcher")
local lang = require("modules/utils/lang")

browser = {
    openedCustom = false,
    controllers = {}
}

function browser.init(mod)
    catcher.init()

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
            browser.openedCustom = true
            this:ShowInternet()
            this:GetMainLayoutController():MarkManuButtonAsSelected("stock")
        else
            wrapped(adress)
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
        if this.addressText:GetText() == "custom" then
            this.currentPage:RemoveAllChildren()

            browser.controllers = {}
            local controller = require("modules/ui/pages/controller"):new(this, catcher, mod)
            controller:initialize()
            table.insert(browser.controllers, controller)
        end
    end)

    ObserveAfter("BrowserController", "LoadWebPage", function (this, adress)
        if adress == "stocks" then
            inkTextRef.SetText(this.addressText, "custom")
        end
    end)
end

return browser