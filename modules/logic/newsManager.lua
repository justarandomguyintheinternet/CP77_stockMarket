local lang = require("modules/utils/lang")
local Cron = require("modules/external/Cron")
local config = require("modules/utils/config")
local utils = require("modules/utils/utils")

newsManager = {}

function newsManager:new(mod)
	local o = {}

    o.mod = mod
    o.data = {}
    o.questDelays = {}
    o.updateCron = nil
    o.dataLink = nil

    o.settings = nil
    o.journalQ = nil
    o.messages = {}
    o.contactHash = 999999999999999999 -- ?
    o.isContactSelected = false
    o.bufferSize = 10

    o.lang = lang

	self.__index = self
   	return setmetatable(o, self)
end

function newsManager:checkForData(data)
    self.data = {}

    if data["news"][1] == nil then
        self:setupData()
        data["news"] = self.data
    else
        self.data = data["news"]
    end
    self.dataLink = data -- Data cant get written back to the "data" otherwise

    if data["settings"]["notifications"] == nil then -- Setup settings data
        data["settings"]["notifications"] = true
    end
    if data["settings"]["lastNews"] == nil then -- Setup settings data
        local time = Game.GetTimeSystem():GetGameTime()
        data["settings"]["lastNews"] = {d = time:Days(), h = time:Hours(), m = time:Minutes()}
    end
    self.settings = data["settings"]

    local news = {} -- Fix wrong order
    for k, v in pairs(self.data) do
        news[k] = v
    end
    self.data = news
end

function newsManager:setupData() -- Setup some news to avoid empty news UI
    self:addNews("roadRage", 0)
    self:addNews("purchaseVehicleAny", 0)
    self:addNews("smartWeaponKills", 0)
end

function newsManager:onInit()
    self.updateCron = Cron.Every(5.0, function ()
        self:update()
    end)
    self.delays = config.loadFile("data/static/news/newsDelays.json")
    self:registerObservers()
end

function newsManager:isNewsActive(triggerName) -- Is this news already displayed
    for _, data in pairs(self.data) do
        if data.name == triggerName then return true end
    end
    return false
end

function newsManager:getNews() -- Returns list of all active news (No more delay)
    local news = {}
    for _, data in pairs(self.data) do
        if data.delay <= 1 then
            table.insert(news, data.name)
        end
    end
    return news
end

function newsManager:addNews(name, delay) -- Add to the queue
    local alternative = self.mod.market.triggerManager.triggers[name].factCondition and self.mod.market.triggerManager.triggers[name].factCondition ~= "" and Game.GetQuestsSystem():GetFactStr(self.mod.market.triggerManager.triggers[name].factCondition) == 1
    if alternative then
        local title, _ = lang.getNewsText(name, true)
        if title == "" then return end
    else
        local title, _ = lang.getNewsText(name, false)
        if title == "" then return end
    end

    local title, msg = lang.getNewsText(name, self.mod.market.triggerManager.triggers[name].factCondition and Game.GetQuestsSystem():GetFactStr(self.mod.market.triggerManager.triggers[name].factCondition) == 1)
    if title == nil or msg == nil or title == "" or msg == "" then return end -- No news for this trigger

    local shift = {}
    for key, value in pairs(self.data) do
        if key < self.bufferSize then
            shift[key + 1] = value
        end
    end

    shift[1] = {name = name, delay = delay or self.delays[name]}
    self.data = shift
end

function newsManager:updateLastMessageTime()
    local time = Game.GetTimeSystem():GetGameTime()
    self.settings.lastNews = {d = time:Days(), h = time:Hours(), m = time:Minutes()}
end

function newsManager:update() -- Runs on Cron
    local remove = nil
    for key, data in pairs(self.data) do -- Decrement delay, show notifications if needed
        if data.delay == 1 then
            self:updateLastMessageTime()
            if self.settings.notifications then
                self:sendMessage(data.name)
            end
            remove = key
        end
        data.delay = math.max(0, data.delay - 1)
    end
    if remove then -- Move newly activated news to the top
        local d = self.data[remove]
        table.remove(self.data, remove)
        table.insert(self.data, 1, d)
    end

    for name, trigger in pairs(self.mod.market.triggerManager.triggers) do -- Detect new news to add to the queue
        if not self.mod.market.stocks[name] then
            local newsThreshold = trigger.newsThreshold or 0.375
            if name:match("LocKey") then
                newsThreshold = 0.95
            end

            if (trigger.exportData.value >= newsThreshold or trigger.exportData.value < -0.95) and not self:isNewsActive(name) then -- Negative for quests with invert condition
                self:addNews(name)
            end
        end
    end

    self.dataLink["news"] = self.data
end

-- Phone stuff

function newsManager:registerObservers()
    Observe("JournalNotificationQueue", "OnMenuUpdate", function(this)
        self.journalQ = this
    end)

    Observe("JournalNotificationQueue", "OnPlayerAttach", function(this)
        self.journalQ = this
    end)

    Observe("JournalNotificationQueue", "OnInitialize", function(this)
        self.journalQ = this
    end)

    Override("MessengerDialogViewController", "UpdateData", function (this, opt, wrapped) -- Insert custom messages / replies
		if self.isContactSelected or (this.parentEntry and this.parentEntry.avatarID == TweakDBID.new("news")) then -- Is our custom contact (Either selected in journal, or from notification)
			local countMessages
			local lastMessageWidget

            -- Insert emtpy custom messages
            self.messages = {}
            for _ = 1, #self:getNews() do
                table.insert(self.messages, JournalPhoneMessage.new())
            end
			this.messages = self.messages

            -- Vanilla stuff:
			inkWidgetRef.SetVisible(this.replayFluff, #this.replyOptions > 0)
			this:SetVisited(this.messages)
			this.messagesListController:Clear()
			this.messagesListController:PushEntries(this.messages)

			this.choicesListController:Clear()
			this.choicesListController:PushEntries(this.replyOptions)
			if #(this.replyOptions) > 0 then
				this.choicesListController:SetSelectedIndex(0)
			end
			if IsDefined(this.newMessageAninmProxy) then
				this.newMessageAninmProxy:Stop()
				this.newMessageAninmProxy = nil
			end
			countMessages = this.messagesListController:Size()
			if opt and countMessages > 0 then
				lastMessageWidget = this.messagesListController:GetItemAt(countMessages - 1)
			end
			if IsDefined(lastMessageWidget) then
				this.newMessageAninmProxy = this:PlayLibraryAnimationOnAutoSelectedTargets("new_message", lastMessageWidget)
			end
			this.scrollController:SetScrollPosition(1.00)
		else
			wrapped(opt)
		end
	end)

    Override("MessangerItemRenderer", "OnJournalEntryUpdated", function (this, entry, extra, wrapped) -- Insert messages text
        local news = self:getNews()
        for key, msg in pairs(self.messages) do
            if utils.isSameInstance(entry, msg) then
                local name = news[#news - key + 1]
                local title, msg = lang.getNewsText(name, self.mod.market.triggerManager.triggers[name].factCondition and Game.GetQuestsSystem():GetFactStr(self.mod.market.triggerManager.triggers[name].factCondition) == 1)
                this:SetMessageView(title .. ":\n\n" .. msg, MessageViewType.Received, "")
                return
            end
        end
        wrapped(entry, extra)
	end)

    Override("MessengerUtils", "GetContactDataArray;JournalManagerBoolBoolMessengerContactSyncData", function (journal, includeUnknown, skipEmpty, activeDataSync, wrapped) -- Insert contact
		local data = wrapped(journal, includeUnknown, skipEmpty, activeDataSync)

		local contactData = ContactData.new()
		contactData.hash = self.contactHash
		contactData.localizedName = lang.getText(lang.news_contactName)
		contactData.timeStamp = GameTime.MakeGameTime(self.settings.lastNews.d, self.settings.lastNews.h, self.settings.lastNews.m, 0)

		local contactVirtualListData = VirutalNestedListData.new()
		contactVirtualListData.level = self.contactHash
		contactVirtualListData.widgetType = 0
		contactVirtualListData.isHeader = true
		contactVirtualListData.data = contactData

		table.insert(data, 1, contactVirtualListData)

		return data
	end)

    Observe("MessengerContactItemVirtualController", "OnToggledOn", function (this) -- Keep track of currently selected contact (Hub menu)
		if this.contactData.localizedName == lang.getText(lang.news_contactName) then
			self.isContactSelected = true
		else
			self.messages = {}
			self.isContactSelected = false
		end
	end)

    ObserveAfter("MessengerContactItemVirtualController", "UpdateState", function (this) -- Make custom contact appear selected
		if this.contactData.localizedName == lang.getText(lang.news_contactName) then
			if self.isContactSelected then
				this:GetRootWidget():SetState("Active")
			end
		end
	end)

    ObserveAfter("MessengerGameController", "OnUninitialize", function () -- Clean up
		self.isContactSelected = false
        self.messages = {}
	end)
end

function newsManager:sendMessage(name)
    if not self.journalQ then return end

    local title, _ = lang.getNewsText(name, self.mod.market.triggerManager.triggers[name].factCondition and Game.GetQuestsSystem():GetFactStr(self.mod.market.triggerManager.triggers[name].factCondition) == 1)

	local notificationData = gameuiGenericNotificationData.new()
	local openAction = OpenMessengerNotificationAction.new()
	openAction.eventDispatcher = self.journalQ

	local contact = JournalContact.new()
	contact.avatarID = TweakDBID.new("news") -- Needed to identify this contact inside the dialog popup
	openAction.journalEntry = contact

	local userData = PhoneMessageNotificationViewData.new()
	userData.title = lang.getText(lang.news_contactName)
	userData.SMSText = title
	userData.action = openAction
	userData.animation = CName("notification_phone_MSG")
	userData.soundEvent = CName("PhoneSmsPopup")
	userData.soundAction = CName("OnOpen")

	notificationData.time = 6.7
	notificationData.widgetLibraryItemName = CName("notification_message")
	notificationData.notificationData = userData

	self.journalQ:AddNewNotificationData(notificationData)
end

return newsManager