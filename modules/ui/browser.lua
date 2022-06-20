local catcher = require("modules/ui/eventCatcher")
local lang = require("modules/utils/lang")
local utils = require("modules/utils/utils")

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
            for key, c in pairs(browser.controllers) do -- Different menu
                if utils.isSameInstance(this:GetOwner(), c.pc) then
                    browser.controllers[key].controller:uninitialize()
                    browser.controllers[key] = nil
                end
            end
            wrapped(adress)
        end
    end)

    Observe("BrowserGameController", "OnUninitialize", function (this) -- PC despawn
        for key, c in pairs(browser.controllers) do
            if utils.isSameInstance(this:GetOwnerEntity(), c.pc) then
                browser.controllers[key].controller:uninitialize()
                browser.controllers[key] = nil
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
        if this.addressText:GetText() == "custom" then
            this.currentPage:RemoveAllChildren()

            for key, c in pairs(browser.controllers) do
                if utils.isSameInstance(this:GetOwnerGameObject(), c.pc) then
                    browser.controllers[key].controller:uninitialize()
                    browser.controllers[key] = nil
                end
            end

            local controller = require("modules/ui/pages/controller"):new(this, catcher, mod)
            controller:initialize()
            table.insert(browser.controllers, {controller = controller, pc = this:GetOwnerGameObject()})
        end
    end)

    ObserveAfter("BrowserController", "LoadWebPage", function (this, adress)
        if adress == "stocks" then
            inkTextRef.SetText(this.addressText, "custom")
        end
    end)
end

return browser