local color = require("modules/ui/color")
local lang = require("modules/utils/lang")
local ink = require("modules/ui/inkHelper")

local buttons = {}

function buttons.createMenu(page)
    local canvas = ink.canvas(0, 0, inkEAnchor.TopCenter)
	canvas:Reparent(page.inkPage, -1)

    -- Logo
    local logo = ink.image(-1440, 175, 233, 233, "base\\icon\\stock_logo.inkatlas", "stock")
    logo.image:SetTintColor(HDRColor.new({ Red = 0.9, Green = 0.9, Blue = 0.9, Alpha = 1.0 }))
    logo.pos:Reparent(canvas, -1)

    -- Home button
	local home = buttons.createMenuButton(lang.getText(lang.button_home), -475, 170, page.eventCatcher)
    if page.pageName ~= "home" then
        home.callback = function()
            page.controller:switchToPage("home")
        end
    else
        home.fg.image:SetOpacity(1)
    end
    home.canvas:Reparent(canvas, -1)

    -- Stocks button
	local stocks = buttons.createMenuButton(lang.getText(lang.button_stocks), -155, 170, page.eventCatcher)
    if page.pageName ~= "stocks" then
        stocks.callback = function()
            page.controller:switchToPage("stocks")
        end
    else
        stocks.fg.image:SetOpacity(1)
    end
    stocks.canvas:Reparent(canvas, -1)

    -- News button
	local news = buttons.createMenuButton("News", 165, 170, page.eventCatcher)
    if page.pageName ~= "news" then
        news.callback = function()
            page.controller:switchToPage("news")
        end
    else
        news.fg.image:SetOpacity(1)
    end
    news.canvas:Reparent(canvas, -1)

    -- Portfolio button
	local portfolio = buttons.createMenuButton(lang.getText(lang.button_portfolio), 485, 170, page.eventCatcher)
    if page.pageName ~= "portfolio" then
        portfolio.callback = function()
            page.controller:switchToPage("portfolio")
        end
    else
        portfolio.fg.image:SetOpacity(1)
    end
    portfolio.canvas:Reparent(canvas, -1)

    -- Logout button
	local logout = buttons.createMenuButton(lang.getText(lang.button_logout), 1375, 170, page.eventCatcher)
    logout.callback = function()
        page.controller:switchToPage("login")
    end
    logout.fg.image:SetTexturePart("status_cell_fg")
    logout.fg.image:SetOpacity(0.25)
    logout.canvas:Reparent(canvas, -1)

    -- Horizontal divider
	local divider = ink.rect(1, 270, 3137, 5, HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 })) --color.red
	divider:SetAnchorPoint(0.5, 0.5)
	divider:Reparent(canvas)

    return canvas
end

function buttons.createMenuButton(text, x, y, catcher)
	local button = require("modules/ui/widgets/button_texture"):new()
	button.x = x
	button.y = y
	button.sizeX = 300
	button.sizeY = 150
	button.textSize = 55
	button.text = text
	button.bgPart = ""
	button.fgPart = "tooltip_b_bracket_decent_fg_thick"
    button.bgColor = HDRColor.new({ Red = 1, Green = 1, Blue = 1, Alpha = 1.0 })
    button.fgColor = HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 })
	button.textColor = color.white
    button.useNineSlice = true
    button.nineSliceScale = inkMargin.new({ left = 5.0, top = 0.0, right = 5.0, bottom = 0.0 })

    button.hoverInCallback = function (bt)
        bt.textWidget:SetTintColor(HDRColor.new({ Red = bt.textColor.Red * 1.7, Green = bt.textColor.Green * 1.7, Blue = bt.textColor.Blue * 1.7, Alpha = 1.0 }))
    end

    button.hoverOutCallback = function (bt)
        bt.textWidget:SetTintColor(bt.textColor)
    end

	button:initialize()
    button.fg.image:SetOpacity(0)
	button:registerCallbacks(catcher)

	return button
end

return buttons