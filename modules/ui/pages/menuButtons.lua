local color = require("modules/ui/color")
local lang = require("modules/utils/lang")
local ink = require("modules/ui/inkHelper")

local buttons = {}

function buttons.createMenu(page)
    local canvas = ink.canvas(0, 0, inkEAnchor.TopCenter)
	canvas:Reparent(page.inkPage, -1)

    -- Home button
	local home = buttons.createMenuButton(lang.getText(lang.button_home), -450, 170, page.eventCatcher)
    if page.pageName ~= "home" then
        home.callback = function()
            page.controller:switchToPage("home")
        end
    else
        home.bg:SetTintColor(color.cyan)
    end
    home.canvas:Reparent(canvas, -1)

    -- Stocks button
	local stocks = buttons.createMenuButton(lang.getText(lang.button_stocks), -150, 170, page.eventCatcher)
    if page.pageName ~= "stocks" then
        stocks.callback = function()
            page.controller:switchToPage("stocks")
        end
    else
        stocks.bg:SetTintColor(color.cyan)
    end
    stocks.canvas:Reparent(canvas, -1)

    -- Portfolio button
	local portfolio = buttons.createMenuButton(lang.getText(lang.button_portfolio), 150, 170, page.eventCatcher)
    if page.pageName ~= "portfolio" then
        portfolio.callback = function()
            page.controller:switchToPage("login")
        end
    else
        portfolio.bg:SetTintColor(color.cyan)
    end
    portfolio.canvas:Reparent(canvas, -1)

    -- Logout button
	local logout = buttons.createMenuButton(lang.getText(lang.button_logout), 450, 170, page.eventCatcher)
    logout.callback = function()
        page.controller:switchToPage("login")
    end
    logout.canvas:Reparent(canvas, -1)

    -- Horizontal divider
	local divider = ink.rect(0, 270, 3135, 5, color.red)
	divider:SetAnchorPoint(0.5, 0.5)
	divider:Reparent(canvas)

    return canvas
end

function buttons.createMenuButton(text, x, y, catcher)
	local button = require("modules/ui/widgets/button"):new()
	button.x = x
	button.y = y
	button.sizeX = 300
	button.sizeY = 150
	button.textSize = 55
	button.text = text
	button.borderSize = 4
	button.fillColor = color.darkred
	button.bgColor = color.darkcyan
	button.textColor = color.white
	button:initialize()
	button:registerCallbacks(catcher)
	return button
end

return buttons