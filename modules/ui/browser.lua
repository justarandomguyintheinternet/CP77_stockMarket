local catcher = require("modules/ui/eventCatcher")
local lang = require("modules/utils/lang")
local utils = require("modules/utils/utils")

browser = {
    openedCustom = false,
    controllers = {}
}

function browser.init(mod)
    catcher.init()

    --DLC
    Override("DlcDescriptionController", "SetData", function(this, userData, wrapped)
        if userData.title.value ~= "stocks" then
            wrapped(userData)
            return
        end
        this.titleRef:SetText(lang.getText(lang.pc_stockmarket))
        this.descriptionRef:SetText("Adds a fully useable Stock Market that reacts to quests and player actions in the open world. Also includes 66 News Messages reacting to your actions.")
        this.guideRef:SetText("Can be accessed from any computer. News Feed can also be accessed using the \"N54 Breaking News\" Contact.")
        this.imageRef:SetAtlasResource(ResRef.FromString("base\\icon\\dlc.inkatlas"))
        this.imageRef:SetTexturePart("stock")
    end)

    ObserveAfter("DlcMenuGameController", "OnInitialize", function(this)
        this:SpawnDescriptions("stocks", "", "", "")
    end)
    --DLC End

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
        if this.addressText:GetText() == "custom" then
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

    ObserveAfter("BrowserController", "LoadWebPage", function (this, adress)
        if adress == "stocks" then
            inkTextRef.SetText(this.addressText, "custom")
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