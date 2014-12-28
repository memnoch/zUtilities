--------------------------------------------------------------------------------
-- Author: Dustin Z.                                             zUtilities.lua
-- Name: zUtilities
-- Abstract: 
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Global Variables
--------------------------------------------------------------------------------
zUtilities = {}
wipe(zUtilities)
zUtilities = LibStub("AceAddon-3.0"):NewAddon("zUtilities", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0","AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("zUtilities")
zUtilities.L = L

-- Defines the name of our mod
local addon, ns = ... -- Defines the name and table of our mod
local mod = zUtilities
local debug = false


--------------------------------------------------------------------------------
-- Name: deepcopy(object)
-- Abstract: 
--------------------------------------------------------------------------------
local function deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end



local options2 = {
    name = "zUtilities",
	type = "group",
	desc = "Options",
    args = {
        enabled = {
            name = "Enable",
            type = "toggle",
            desc = "Enables / disables zUtilities",
            get = function() return db.enabled end,
            set = function(i, switch)
                db.enabled = switch
            end
        },
        debugging = {
            name = "debugging",
            type = "toggle",
            desc = "enables / disables debugging mode",
            get = function() return db.debugging end,
            set = function(i, switch)
                db.debugging = switch
                debug = switch
            end
        },
    },
}

local options = deepcopy(options2)

options.args.auto = {
    name = "automations",
	type = "group",
	desc = "Automations",
	args = {
        autoAcceptFriendInvites = {
			name = "friend invite",
            type = "toggle",
            desc = "auto accept invite requests from players on your friends list",
            get = function() return db.autoAcceptFriendInvites end,
            set = function(i, switch)
                db.autoAcceptFriendInvites = switch
            end
        },
        autoAcceptGuildInvites = {
            name = "guild invite",
            type = "toggle",
            desc = "auto accept invite requests from guildmates",
                get = function() return db.autoAcceptGuildInvites end,
                set = function(i, switch)
                    db.autoAcceptGuildInvites = switch
                end
        },
		autoRepair = {
			name = "auto repair",
			-- type = "select",
			-- desc = "Repair all Equipment and Inventory automatically.",
			-- values = {"Disabled", "Own Money", "Guild Money"},
            type = "toggle",
            desc = "automatically repair gear",
			get = function() return db.autoRepair end,
			set = function(i, switch)
				if db.autoRepair then
					-- if db.autoSellJunk or db.AutoRevive then
						-- return
                    mod.Merchant_Show = true
                    db.autoRepair = 1
                elseif not switch then
                    if db.autoSellJunk then return end --or db.AutoRevive then return end
                    mod.Merchant_Show = false
                    db.autoRepair = 0
                end
			end
		},
		ignoreDuels = {
			name = "ignore duels",
			type = "toggle",
			desc = "ignore duels",
			get = function() return db.ignoreDuels end,
			set = function(i, switch)
				db.ignoreDuels = switch
				if switch then
				else
				end
			end
		},
		betterAutoLoot = {
			name = "better auto loot",
			type = "toggle",
			desc = "Automatically loot all Items and confirm BoP and Disenchant Notification. It does not roll on Items while in a group or raid. This overrides the standard UI Auto Loot setting.",
			get = function() return db.betterAutoLoot end,
			set = function(i, switch)
				db.betterAutoLoot = switch
			end
		},
        autoSellJunk = {
			name = "sell grey items",
			type = "toggle",
			desc = "Sell Grey (junk) Items in your Bags automatically.",
			get = function() return db.autoSellJunk end,
			set = function(i, switch)
				db.autoSellJunk = switch
				if switch then
					mod.Merchant_Show = true 
				else
					if db.autoSellJunk or db.autoRepair then return end --or db.AutoRevive then return end
					mod.Merchant_Show = false
				end
			end
		},
	},
}



options.args.chat = {
    name = "chat",
	type = "group",
	desc = "Chat Options",
	args = {
		chatFade = {
			name = "Disable Chat Fading",
			type = "toggle",
			desc = "Disable Chat Frames Fading Chat after Inactivity.",
			get = function() return db.chatFade end,
			set = function(i, switch)
				db.chatFade = switch
                mod:ChatFadeToggle()
			end
		},
		partyFrames = {
			name = "Default Party Frames",
			type = "toggle",
			desc = "Hide Blizzard Default Party Frames.",
			get = function() return db.PartyFrames end,
			set = function(i, switch)
				db.PartyFrames = switch
                -- mod:PartyFrames()
			end
		},
		raidFrames = {
			name = "Default Frames",
			type = "toggle",
			desc = "Hide Blizzard Default Raid Frames.",
			get = function() return db.RaidFrames end,
			set = function(i, switch)
				db.RaidFrames = switch
                -- mod:RaidFrames()
			end
		}
    }
}



options.args.ui = {
    name = "UI",
	type = "group",
	desc = "User Interface Options",
	args = {
		betterReputation = {
			name = "Better Reputation",
			type = "toggle",
			desc = "Display Reputation Amounts numerically and detailed Information in the Chat Frame.",
			get = function() return db.betterReputation end,
			set = function(i, switch)
				db.betterReputation = switch
				if switch then
					mod:zRepOn()
				else
					mod:zRepOff()
				end
			end
		}, 
		toggleGryphons = {
			name = "Disable Gryphons",
			type = "toggle",
			desc = "Hide Gryphons on Main Toolbar.",
			get = function() return db.toggleGryphons end,
			set = function(i, switch)
				db.toggleGryphons = switch
                mod:toggleGryphons()
			end
		},
        showQuestLevels = {
			name = "Display Quest Levels",
			type = "toggle",
			desc = "Display numeric Quest Level in Quest Frame, Quest completion Frame, and NPC Quest Dialog.",
			get = function() return db.showQuestLevels end,
			set = function(i, switch)
				db.showQuestLevels = switch
				if switch then
                    mod:SecureHook("QuestLogQuests_Update", "updateQuestLog")
                    mod:SecureHook(QUEST_TRACKER_MODULE, "Update", "updateWatchFrame") 
                    -- mod:SecureHook("ObjectiveTracker_Update", "updateWatchFrame")
                    -- mod:SecureHook(QuestScrollFrame, "Update", "updateQuestLog")
                    mod:SecureHookScript(QuestFrameGreetingPanel, "OnShow", "updateQuestFrame")
                    mod:SecureHook("QuestFrameGreetingPanel_OnShow", "updateQuestFrame")
                    mod:SecureHook("GossipFrameUpdate", "gossipQuestFormat")
                    mod:ceFilters()
					if not mod.Gossip_Show then
						mod.Gossip_Show = true
					end
				else
                    mod:Unhook("QuestLogQuests_Update")
                    mod:Unhook(QUEST_TRACKER_MODULE, "Update")
                    -- mod:Unhook("ObjectiveTracker_Update")
					-- mod:Unhook("QuestMapFrame_UpdateAll")
                    -- mod:Unhook(QuestScrollFrame, "Update")
                    mod:Unhook(QuestFrameGreetingPanel, "OnShow")
                    mod:Unhook("QuestFrameGreetingPanel_OnShow")
                    mod:Unhook("GossipFrameUpdate")
					if not db.SkipGossip and not db.showQuestLevels then -- and not db.AutoRevive then
						mod.Gossip_Show = false
					end
				end
			end
		},
        -- SkipGossip = {
			-- name = "Skip useless Gossips",
			-- type = "toggle",
			-- desc = "Skip Battlemaster, Banker, and Flightmaster Gossip.",
			-- get = function() return db.SkipGossip end,
			-- set = function(i, switch)
				-- db.SkipGossip = switch
				-- if switch then
					-- if not mod.Gossip_Show then
						-- mod:RegisterEvent("GOSSIP_SHOW", "zOnEvent")
						-- mod.Gossip_Show = true
					-- end
				-- else
					-- if db.SkipGossip or db.showQuestLevels or db.AutoRevive then return end
						-- mod:UnregisterEvent("GOSSIP_SHOW")
						-- mod.Gossip_Show = false
					-- end
				-- end
			-- end
        -- },
    }
}



options.args.minimap = {
    name = "minimap",
	type = "group",
	desc = "Minimap Options",
	args = {
		toggleBorder = {
			name = "Minimap Border",
			type = "toggle",
			desc = "Hide the Minimap border.",
			get = function() return db.toggleBorder end,
			set = function(i, switch)
				db.toggleBorder = switch
				if switch then
					MinimapBorder:Hide()
				else
					MinimapBorder:Show()
				end
			end
		},
        toggleClock = {
          name = "Hide Game Clock",
          type = "toggle",
          desc = "Hide Game Clock below the minimap.",
          get = function() return db.toggleClock end,
          set = function(i, switch)
            db.toggleClock = switch
            mod:toggleClock()
          end
        },
		toggleClutter = {
			name = "Toggle Clutter",
			type = "toggle",
			desc = "Toggle Minimap Clock, Scroll Buttons, and Location Frame.",
			get = function() return db.toggleClutter end,
			set = function(i, switch)
				db.toggleClutter = switch
				if switch then
					mod:MinMapClutterHide()
				else
					mod:MinMapClutterShow()
				end
			end
		},
		miniMapCoordinates = {
			name = "Map X,Y Coords",
			type = "toggle",
			desc = "Adds Numeric X,Y Coordinates below the Minimap.",
			get = function() return db.miniMapCoordinates end,
			set = function(i, switch)
				db.miniMapCoordinates = switch
				if switch then
					mod:MapLocationOn()
				else
					mod:MapLocationOff()
				end
			end
		},
		mapScroll = {
			name = "MouseWheel Zoom",
			type = "toggle",
			desc = "Enables MouseWheel zooming of the Minimap.",
			get = function() return db.mapScroll end,
			set = function(i, switch)
				db.mapScroll = switch
				if switch then
					mod:mapScroll()
				else
					mod:mapScroll()
				end
			end
		},
		trackingButton = {
			name = "Tracking Button",
			type = "toggle",
			desc = "Hide the Tracking button on the Minimap.",
			get = function() return db.trackingButton end,
			set = function(i, switch)
				db.trackingButton = switch
				if switch then
					MiniMapTracking:Hide()
				else
					MiniMapTracking:Show()
				end
			end
		},
		worldMapButton = {
			name = "World Map Button",
			type = "toggle",
			desc = "Hide the World Map button on the Minimap.",
			get = function() return db.worldMapButton end,
			set = function(i, switch)
				db.worldMapButton = switch
				if switch then
					MiniMapWorldMapButton:Hide()
				else
					MiniMapWorldMapButton:Show()
				end
			end
		}
    }
}



--------------------------------------------------------------------------------
-- Name: defaults
-- Abstract: A table which holds our preference variables
--------------------------------------------------------------------------------
local defaults = {
    profile = {
        autoAcceptFriendInvites = true,
        autoAcceptGuildInvites = true,
        autoRepair = 1,
        autoSellJunk = true,
        betterAutoLoot = true,
        betterReputation = true,
        chatFade = true,
        debugging = false,
        ignoreDuels = true,
        mapScroll = true,
        miniMapCoordinates = true,
        PartyFrames = false,
        showQuestLevels = true,
        RaidFrames = false,
        SkipGossip = false,
        toggleBorder = false,
        toggleClock = true,
        toggleClutter = true,
        toggleGryphons = true,
        trackingButton = true,
        worldMapButton = true,
        enabled = true,
    }
}



local function ProfileSetup()
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(zUtilities.db)
	return profiles
end



--------------------------------------------------------------------------------
-- Name: zUtilities:OnInitialize()
-- Abstract: Our would be constructor, isn't it cute?
--------------------------------------------------------------------------------
function zUtilities:OnInitialize()
	self.Merchant_Show = false
    self.Gossip_Show = false
	self.abacus = LibStub("LibAbacus-3.0")
    self.AC = LibStub("AceConfig-3.0"):RegisterOptionsTable("zUtilities", options, "zu")
	self.ACR = LibStub("AceConfigRegistry-3.0")
	self.ACD = LibStub("AceConfigDialog-3.0")
    
	--# Initialize DB
	self.db = LibStub("AceDB-3.0"):New("zUtilitiesDB", defaults)
	db = self.db.profile
    options.args.profile = ProfileSetup()

	--# Register our options
    self.ACR:RegisterOptionsTable("zUtilities Blizz", options2)
	self.ACR:RegisterOptionsTable("zUtilities Automation", options.args.auto)
	self.ACR:RegisterOptionsTable("zUtilities Chat", options.args.chat)
    self.ACR:RegisterOptionsTable("zUtilities Interface", options.args.ui)
	self.ACR:RegisterOptionsTable("zUtilities Minimap", options.args.minimap)
    self.ACR:RegisterOptionsTable("zUtilities Profile", options.args.profile)
    self.ACD:AddToBlizOptions("zUtilities Blizz", "zUtilities")
	self.ACD:AddToBlizOptions("zUtilities Automation", "Automation", "zUtilities")
	self.ACD:AddToBlizOptions("zUtilities Chat", "Chat", "zUtilities")
    self.ACD:AddToBlizOptions("zUtilities Interface", "Interface", "zUtilities")
	self.ACD:AddToBlizOptions("zUtilities Minimap", "Minimap", "zUtilities")
    self.ACD:AddToBlizOptions("zUtilities Profile", "Profile", "zUtilities")

  -- slash commands
	SlashCmdList["zUtilities"] = function()
                                        InterfaceOptionsFrame_OpenToCategory("zUtilities")
                                        -- InterfaceOptionsFrame_OpenToCategory("zUtilities")
                                        -- self.ACD:SelectGroup("zBattlePets")
                                 end
	SLASH_zUtilities1 = "/zUtilities"
	SLASH_zUtilities2 = "/zuc"

	--# /rl: Reload UI
	SlashCmdList["zReloadUI"] = function() ReloadUI() end
	SLASH_zReloadUI1 = "/rl"

	--# /rg: Restart GFX Subsystem
	SlashCmdList["zRestartGX"] = function() RestartGx() end
	SLASH_zRestartGX1 = "/rgx"
	
	-- # /rg: Is Quest Completed?
 	SlashCmdList["zIsQuestCompleted"] = function(input, editbox)
                                            mod:IsQuestCompleted(input)
                                        end
 	SLASH_zIsQuestCompleted1 = "/iqc"

    
    --# /iqc: check if the quest has been completed and lets you know in your chat frame
    --SlashCmdList["isQC"] = function() print(IsQuestFlaggedCompleted(3247)) end
    --SLASH_isQC = "/iqc"
    
	-- camera now shows up to 50yrd and not only 35yrd
	ConsoleExec("CameraDistanceMax 50")
	ConsoleExec("CameraDistanceMaxFactor 8")

    -- fix the silly UpdateMicroButtons() issues that came about in 5.4.1, dumb whores    
    -- if IsAddOnLoaded("Blizzard_AchievementUI") then
        -- setfenv(AchievementFrame_OnShow, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
        -- setfenv(AchievementFrame_OnHide, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
    -- else
        -- local zVT = CreateFrame("Frame")
        -- zVT:RegisterEvent("ADDON_LOADED", "zOnEvent")
        -- zVT:SetScript("OnEvent",function(_,_,addonName) 
            -- if addonName == "Blizzard_AchievementUI" then
                -- setfenv(AchievementFrame_OnShow, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
                -- setfenv(AchievementFrame_OnHide, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
                -- zVT:UnregisterEvent("ADDON_LOADED")
            -- end
        -- end)
    -- end
    
    -- if IsAddOnLoaded("Blizzard_TrainerUI") then
        -- setfenv(ClassTrainerFrame_OnShow, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
        -- setfenv(ClassTrainerFrame_OnHide, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
    -- else
        -- local zVT = CreateFrame("Frame")
        -- zVT:RegisterEvent("ADDON_LOADED", "zOnEvent")
        -- zVT:SetScript("OnEvent",function(_,_,addonName) 
            -- if addonName == "Blizzard_TrainerUI" then
                -- setfenv(ClassTrainerFrame_OnShow, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
                -- setfenv(ClassTrainerFrame_OnHide, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
                -- zVT:UnregisterEvent("ADDON_LOADED")
            -- end
        -- end)
    -- end
    
    -- fix more taint
    -- Remove the cancel button
    -- InterfaceOptionsFrameCancel:Hide()
    -- InterfaceOptionsFrameOkay:SetAllPoints(InterfaceOptionsFrameCancel)
    -- Make clicking cancel the same as clicking okay
    -- InterfaceOptionsFrameCancel:SetScript("OnClick", function() InterfaceOptionsFrameOkay:Click() end)
    -- disable CUFP
    -- CompactUnitFrameProfiles:UnregisterAllEvents() --This disables the creation of the blizzard raid frames
	-- set max FPS to 70, and limit fps down to 30 when WoW is minimized (saves GPU/CPU)
	SetCVar("maxFPSBk","30")
    
    mod:zMSG("Loaded!")
end



--------------------------------------------------------------------------------
-- Name: zUtilities:OnEnable()
-- Abstract: Our would be constructor, isn't it cute?
--------------------------------------------------------------------------------
function zUtilities:OnEnable()
    zMinimap = CreateFrame("Frame", "zMinimap", MinimapCluster)
    -- self.Minimap:SetAllPoints(Minimap)
    zMinimap:SetFrameStrata("LOW")
    zMinimap.loc = zMinimap:CreateFontString(nil, 'OVERLAY')
    zMinimap.loc:SetWidth(90)
    zMinimap.loc:SetHeight(16)
    zMinimap.loc:SetPoint('TOPLEFT', MinimapCluster, 'BOTTOMLEFT', 65, -16)
    -- self.Minimap.loc:SetPoint('CENTER', Minimap, 'BOTTOM', 0, -16)
    zMinimap.loc:SetJustifyV('MIDDLE')
    zMinimap.loc:SetJustifyH('CENTER')
    zMinimap.loc:SetFontObject(GameFontNormal)

	for varname, val in pairs(options.args.auto.args) do
		if db[varname] then options.args.auto.args[varname].set(false, db[varname]) end
	end
	for varname, val in pairs(options.args.chat.args) do
		if db[varname] then options.args.chat.args[varname].set(false, db[varname]) end
	end
	for varname, val in pairs(options.args.ui.args) do
		if db[varname] then options.args.ui.args[varname].set(false, db[varname]) end
	end
	for varname, val in pairs(options.args.minimap.args) do
		if db[varname] then options.args.minimap.args[varname].set(false, db[varname]) end
	end
	for varname, val in pairs(options.args.profile.args) do
		if db[varname] then options.args.profile.args[varname].set(false, db[varname]) end
	end
    
    -- load events
    mod:UnregisterAllEvents()
    mod:RegisterEvent("ADDON_LOADED", "zOnEvent")
    mod:RegisterEvent("CONFIRM_DISENCHANT_ROLL", "zOnEvent")
    mod:RegisterEvent("CONFIRM_LOOT_ROLL", "zOnEvent")
    mod:RegisterEvent("FACTION_UPDATED", "zOnEvent")
    mod:RegisterEvent("GOSSIP_SHOW", "zOnEvent")
    mod:RegisterEvent("GROUP_ROSTER_UPDATE", "zOnEvent")
    mod:RegisterEvent("LOOT_OPENED", "zOnEvent")
    mod:RegisterEvent("MERCHANT_SHOW", "zOnEvent")
    mod:RegisterEvent("PARTY_INVITE_REQUEST", "zOnEvent")
    mod:RegisterEvent("PLAYER_ENTERING_WORLD", "zOnEvent")
    mod:RegisterEvent("QUEST_GREETING", "zOnEvent")
    mod:RegisterEvent("QUEST_LOG_UPDATE", "zOnEvent")
    mod:RegisterEvent("RAID_ROSTER_UPDATE", "zOnEvent")
    mod:RegisterEvent("UPDATE_FACTION", "zOnEvent")
    
    -- /run SetCVar("taintLog",1)
    -- /run print(GetCVar("taintLog"))

    
    -- local i = setfenv(AchievementFrame_OnShow, setmetatable({UpdateMicroButtons = function() end}, {__index = _G}))
    
    -- send msg on enable
    mod:zMSG("Enabled!")
end

function wave()
    local a,x,n,c=5865,{}
    for i=1,
        GetAchievementNumCriteria(a)
    do n,_,c=GetAchievementCriteriaInfo(a,i)
        if not c then
            x[n]=1
        end
    end
    if x[UnitName("target")] then
        DoEmote("wave")
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:OnDisable()
-- Abstract: Our would be de-constructor, isn't it cute?
--------------------------------------------------------------------------------
function zUtilities:OnDisable()
--   -- Unhook, Unregister Events, Hide frames that you created.
--   -- You would probably only use an OnDisable if you want to 
--   -- build a "standby" mode, or be able to toggle modules on/off.
    -- send message on disable
    mod:zMSG("Disabled!")
end



--------------------------------------------------------------------------------
-- Name: zUtilities:zOnEvent()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:zOnEvent(event, ...)
	local arg1 = ...
    
    if (debug) then
        mod:zMSG("|cffff0000DEBUG|r event fired -> " .. event)
        mod:zDebug("event fired -> " .. event)
    end
    
    if (event == "PLAYER_ENTERING_WORLD") then
        mod:PLAYER_ENTERING_WORLD()
        ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", mod.chatFilter)
        ChatFrame_AddMessageEventFilter("COMBAT_TEXT_UPDATE", mod.chatFilter)
    elseif (event == "UPDATE_FACTION") then
        mod:UPDATE_FACTION()
    elseif (event == "ADDON_LOADED") and (arg1 == "zUtilities") then

    elseif (event == "DUEL_REQUEST") then
      	mod:DUEL_REQUESTED()
    elseif (event == "GROUP_ROSTER_UPDATE") then
        StaticPopup_Hide("PARTY_INVITE")
        StaticPopup_Hide("PARTY_INVITE_XREALM")
        mod:UnregisterEvent("GROUP_ROSTER_UPDATE")
    elseif (event == "GUILD_INVITE_REQUEST") then
        mod:GUILD_INVITE_REQUEST()
    elseif (event == "LOOT_OPENED") then
        mod:LOOT_OPENED()
    elseif (event == "CONFIRM_DISENCHANT_ROLL") or (event == "CONFIRM_LOOT_ROLL") then
        local rollId = select(1, ...)
        local rollType = select(2, ...)
        mod:parseRoll(rollId, rollType)
        mod:parseRoll(rollId, rollType)
    elseif (event == "MERCHANT_SHOW") then
        mod:MERCHANT_SHOW()
    elseif (event == "GOSSIP_SHOW") or (event == "GOSSIP_CONFIRM") then
        mod:gossipHandler()
    elseif (event == "PARTY_INVITE_REQUEST") then
        mod:inviteHandler(arg1)
        mod:RegisterEvent("GROUP_ROSTER_UPDATE", "zOnEvent")
    elseif (event == "QUEST_GREETING") or (event == "QUEST_LOG_UPDATE") then
        mod:gossipHandler()
        mod:updateQuestFrame()
    elseif (event == "ZONE_CHANGED_NEW_AREA") then
        mod:ZONE_CHANGED_NEW_AREA()
    -- elseif (event == "") then
        -- mod:
    -- elseif (event == "") then
        -- mod:
    -- elseif (event == "") then
        -- mod:
    -- elseif (event == "") then
        -- mod:
    elseif (event == "PARTY_MEMBERS_CHANGED") then
        -- mod:PartyFrames()
    elseif (event == "RAID_ROSTER_CHANGED") then
        -- mod:RaidFrames()
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:zMSGc(msg, r, g, b)
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:zMSGc(msg, r, g, b)
    -- strMod = format("|cff0062ffz|r|cff0deb11Utilities|r")
    strMod = format("|cff696969z|r|cff008B8BUtilities|r: ")
    DEFAULT_CHAT_FRAME:AddMessage(strMod .. tostring(msg), r, g, b)
end



--------------------------------------------------------------------------------
-- Name: zUtilities:zMSG(msg)
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:zMSG(msg)
    -- strMod = format("|cff0062ffz|r|cff0deb11Utilities|r")
    strMod = format("|cff696969z|r|cff008B8BUtilities|r: ")
    DEFAULT_CHAT_FRAME:AddMessage(strMod .. tostring(msg))
end



--------------------------------------------------------------------------------
-- Name: zUtilities:zDebug(msg)
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:zDebug(msg)
    mod:zMSG("|cffff0000DEBUG|r " .. tostring(msg))
end



--------------------------------------------------------------------------------
-- Name: zUtilities:zPrint(msg)
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:zPrint(msg)
    -- strMod = format("|cff0062ffz|r|cff0deb11Utilities|r")
    strMod = format("|cff696969z|r|cff008B8BUtilities|r: ")
    self:Print(strMod .. tostring(msg))
end



--------------------------------------------------------------------------------
-- Name: zUtilities:IsQuestCompleted
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:IsQuestCompleted(qid)
    -- mod:zMSG("quest " .. qid .. "? " .. tostring(IsQuestFlaggedCompleted(qid)))
    mod:zMSG(("The quest with ID: #%s is %scomplete!"):format(qid, IsQuestFlaggedCompleted(qid) and "" or "|cFFFF0000NOT|r "))
end



--------------------------------------------------------------------------------
-- Name: zUtilities:zRepPrint
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:zRepPrint(msg, default)
    if not (msg) then return end
    local zmsg = tostring(format("|cff696969z|r|cff008B8BUtilities|r: " .. tostring(msg)))
	if (default) then
		DEFAULT_CHAT_FRAME:AddMessage(zmsg)
	else
		for i = 1, NUM_CHAT_WINDOWS do
			local chatTab = _G["ChatFrame"..i.."Tab"]
			if chatTab:IsShown() then
				local chatFrame = _G["ChatFrame"..i]
				local messageTypes = chatFrame.messageTypeList
				for j = 1, #messageTypes do
					if messageTypes[j] == "COMBAT_FACTION_CHANGE" then
						_G["ChatFrame"..i]:AddMessage(zmsg)
					end
				end
			end
		end

	end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:autoRepair
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:autoRepair()
    local equipcost = GetRepairAllCost()
    local funds = GetMoney()
    
    if (funds < equipcost) and (db.autoRepair == 1) then
        mod:zMSG("Insufficient Funds to Repair")
    end

    if (equipcost > 0) then
        if (db.autoRepair == 2) then
            RepairAllItems(1)
            mod:zMSG("Total repair Costs (Guild Funds): " .. self.abacus:FormatMoneyCondensed(equipcost,1))
        elseif (db.autoRepair == 1) then
            RepairAllItems()
            mod:zMSG("Total repair Costs (Personal Funds): " .. self.abacus:FormatMoneyCondensed(equipcost,1))
        end
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:AutoSellJunk()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:AutoSellJunk()
    -- sell junk?
    if db.autoSellJunk then
	local bag, slot
        for bag = 0, 4 do
            if GetContainerNumSlots(bag) > 0 then
                for slot = 1, GetContainerNumSlots(bag) do
                    local _, _, _, quality = GetContainerItemInfo(bag, slot)
                    if (quality == 0 or quality == -1) then
                        if (mod:ProcessLink(GetContainerItemLink(bag, slot))) then
                            UseContainerItem(bag, slot)
                        end
                    end
                end
            end
        end
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:ChatFadeToggle()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:ChatFadeToggle()

    if db.chatFade then
        for i = 1, NUM_CHAT_WINDOWS do
            getglobal('ChatFrame'..i):SetFading(false)
            --ChatFrame11:SetFading(false)
        end
    elseif not db.chatFade then
        for i = 1, NUM_CHAT_WINDOWS do
            getglobal('ChatFrame'..i):SetFading(true)
            --ChatFrame11:SetFading(true)
        end
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:skipGossip()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:skipGossip()
	local bwl = "The orb's markings match the brand on your hand."
	local mc = "You see large cavernous tunnels"
	local t = GetGossipText()
	if (t == bwl or (strsub(t,1,31) == mc)) then
		SelectGossipOption(1)
		return
	end
	local list = {GetGossipOptions()}
	for i = 2,getn(list),2 do
		if(list[i]=="taxi" or list[i]=="battlemaster" or list[i]=="banker") then SelectGossipOption(i/2) return end
	end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:MapLocationOff()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:MapLocationOff()
	zMinimap.loc:SetText('')
	self:CancelAllTimers()
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end



--------------------------------------------------------------------------------
-- Name: zUtilities:MapLocationOn()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:MapLocationOn()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:ScheduleRepeatingTimer("UpdateMapLocation", 0.5)
end



--------------------------------------------------------------------------------
-- Name: zUtilities:toggleMapLocation()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:toggleMapLocation()
  -- minimap coordinates on/off
  if db.miniMapCoordinates then
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:ScheduleRepeatingTimer("UpdateMapLocation", 0.5)
  elseif not db.miniMapCoordinates then
    zMinimap.loc:SetText('')
    self:CancelAllTimers()
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
  end

end



--------------------------------------------------------------------------------
-- Name: zUtilities:MinMapClutterHide()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:toggleMinMapClutter()
  -- hide/show clutter
  if db.MinMapClutter then
    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
    GameTimeFrame:Hide()
    MinimapZoneTextButton:Hide()
    MinimapBorderTop:Hide()
  elseif not db.MinMapClutter then
    MinimapZoomIn:Show()
    MinimapZoomOut:Show()
    GameTimeFrame:Show()
    MinimapZoneTextButton:Show()
    MinimapBorderTop:Show()
  end

end



function zUtilities:MinMapClutterHide()
    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
    GameTimeFrame:Hide()
    MinimapZoneTextButton:Hide()
    MinimapBorderTop:Hide()
end



function zUtilities:MinMapClutterShow()
    MinimapZoomIn:Show()
    MinimapZoomOut:Show()
    GameTimeFrame:Show()
    MinimapZoneTextButton:Show()
    MinimapBorderTop:Show()
end



--------------------------------------------------------------------------------
-- Name: zUtilities:UpdateMapLocation()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:UpdateMapLocation()
	local x, y = GetPlayerMapPosition("player")
	zMinimap.loc:SetText(string.format('%0.2f, %0.2f', x*100 or '', y*100 or ''))
end



--------------------------------------------------------------------------------
-- Name: zUtilities:toggleClock()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:toggleClock()
    -- hide/show clock
    if db.toggleClock then
        if not IsAddOnLoaded("Blizzard_TimeManager")
            then LoadAddOn("Blizzard_TimeManager")
        end
        TimeManagerClockButton:Hide()
    elseif db.toggleClock then
        if not IsAddOnLoaded("Blizzard_TimeManager")
            then LoadAddOn("Blizzard_TimeManager")
        end
        TimeManagerClockButton:Show()
    end
    
end



--------------------------------------------------------------------------------
-- Name: zUtilities:toggleCoordinates()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:toggleCoordinates()
	-- hide/show minimap coordinates
    if db.miniMapCoordinates then
        mod:MapLocationOn()
    elseif db.miniMapCoordinates then
        mod:MapLocationOff()
    end
    
end    
--------------------------------------------------------------------------------
-- Name: zUtilities:toggleGryphons()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:toggleGryphons()
	-- hide/show gryphons
    if db.toggleGryphons then
        MainMenuBarLeftEndCap:Hide()
        MainMenuBarRightEndCap:Hide()
    elseif not db.toggleGryphons then
        MainMenuBarLeftEndCap:Show()
        MainMenuBarRightEndCap:Show()
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:MapScroll()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:mapScroll()
	zMinimap:Show()
--    MinimapZoomIn:Hide()
--    MinimapZoomOut:Hide()
	zMinimap:SetScript("OnMouseWheel", function(i, switch) 
		if not db.mapScroll then 
            return
        end
		if switch > 0 then
            Minimap_ZoomIn()
		elseif switch < 0 then
            Minimap_ZoomOut()
        end
	end)
    zMinimap:EnableMouseWheel(true)
end



--------------------------------------------------------------------------------
-- Name: zUtilities:zRepOn()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:zRepOn()
	mod:PLAYER_ENTERING_WORLD()
	mod:RegisterEvent("PLAYER_ENTERING_WORLD", "zOnEvent")
	mod:RegisterEvent("UPDATE_FACTION", "zOnEvent")
    -- ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", mod.chatFilter)
    -- ChatFrame_AddMessageEventFilter("COMBAT_TEXT_UPDATE", mod.chatFilter)
	-- if (ReputationFrame:IsVisible()) then
        ReputationFrame_Update()
    -- end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:zRepOff()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:zRepOff()
	-- ReputationWatchBar.cvarLocked = nil
	-- ReputationWatchBar.textLocked = nil
	-- ReputationWatchStatusBarText:Hide()
    -- ReputationWatchBar:Hide()
	mod:UnregisterEvent("UPDATE_FACTION")
	mod:UnregisterEvent("PLAYER_ENTERING_WORLD")
    -- ChatFrame_RemoveMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", mod.chatFilter)
    -- ChatFrame_RemoveMessageEventFilter("COMBAT_TEXT_UPDATE", mod.chatFilter)   
end



--------------------------------------------------------------------------------
-- Name: zUtilities:PartyFrames()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:PartyFrames()
    -- hide/show Party Frames
    local uPMF = "PartyMemberFrame"
    
    if db.PartyFrames then
        for i = 1,4 do
            local cPMF = _G[uPMF .. i]
            cPMF:Hide()
        end
        -- could've also used HidePartyFrame()
    elseif not db.PartyFrames then
        for i = 1,4 do
            local cPMF = _G[uPMF .. i]
            cPMF:Show()
        end
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:ProcessLink()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:ProcessLink(link)
	for color, name in string.gmatch(link, "(|c%x+)|Hitem:.+|h%[(.-)%]|h|r") do
	if color == ITEM_QUALITY_COLORS[0].hex then
		return true
	end
		return false
	end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:RaidFrames()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:RaidFrames()
-- /run CompactRaidFrameManager:UnregisterAllEvents() CompactRaidFrameManager:Hide() CompactRaidFrameContainer:UnregisterAllEvents() CompactRaidFrameContainer:Hide()

    -- hide/show Raid Frames
    if db.RaidFrames then
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
        CompactRaidFrameContainer:UnregisterAllEvents()
        CompactRaidFrameContainer:Hide()
    elseif not db.RaidFrames then
        CompactRaidFrameContainer:RegisterEvent("RAID_ROSTER_UPDATE")
        CompactRaidFrameContainer:RegisterEvent("UNIT_PET")
        CompactRaidFrameContainer:Show()
        CompactRaidFrameManager:Show()
    end
    
end



--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Name: zUtilities:parseRoll(rollId, rollType)
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:parseRoll(rollId, rollType)
	if not IsShiftKeyDown() then
		ConfirmLootRoll(rollId, rollType)
		StaticPopup_Hide("CONFIRM_LOOT_ROLL")
	end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:DUEL_REQUESTED()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:DUEL_REQUESTED()
	if not IsShiftKeyDown() then
		HideUIPanel(StaticPopup1)
		CancelDuel()
	end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:GUILD_INVITE_REQUEST()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:GUILD_INVITE_REQUEST()
	-- self:Print(L["Cancelling guild invite..."])
    zMSG("Cancelling guild invite...")
	DeclineGuild()
	StaticPopup_Hide("GUILD_INVITE")
end



--------------------------------------------------------------------------------
-- Name: LOOT_OPENED()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:LOOT_OPENED()
	if not IsShiftKeyDown() then
		intCount = GetNumLootItems()
		if intCount == 0 then
			CloseLoot()
		else
			for slot = 1, intCount do
				LootSlot(slot)
				ConfirmLootSlot(slot)
			end
		end
	end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:MERCHANT_SHOW()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:MERCHANT_SHOW()
    if not IsShiftKeyDown() then
        if db.autoSellJunk then
            self:AutoSellJunk()
        end
        if CanMerchantRepair() and db.autoRepair then
            self:autoRepair()
        end
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:PLAYER_ENTERING_WORLD()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:PLAYER_ENTERING_WORLD()
    if (db.betterReputation) then
        -- ReputationWatchBar.cvarLocked = 1
        -- ReputationWatchBar.textLocked = 1
        -- ReputationWatchBar:Show()
        -- ReputationWatchStatusBarText:Show()
    end
end



local zReps = {}
--------------------------------------------------------------------------------
-- Name: zUtilities:UPDATE_FACTION()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:UPDATE_FACTION()
    if (db.betterReputation) then
        mod:PLAYER_ENTERING_WORLD()
        for factionIndex=1, GetNumFactions(), 1 do
            local name, _, standingID, bottomValue, topValue, earnedValue, _, _, isHeader = GetFactionInfo(factionIndex)
            local msg = nil
            if (not isHeader) and zReps[name] then
                local difference = earnedValue - zReps[name].Value
                if (difference > 0 and standingID ~= 8) then
                    msg = format("%d |cff7f7fffuntil %s with %s (%d/%d).|r",topValue-earnedValue,getglobal("FACTION_STANDING_LABEL"..standingID+1),name,earnedValue,topValue)
                    mod:zRepPrint(msg)
                elseif (difference < 0 and standingID ~= 1) then
                    difference=abs(difference)
                    msg = format(" %d |cff7f7fffuntil %s with %s (%d/%d).|r",earnedValue-bottomValue,getglobal("FACTION_STANDING_LABEL"..standingID-1),name,earnedValue,topValue)
                    mod:zRepPrint(msg)
                end
                zReps[name].Value = earnedValue
            else
                zReps[name] = {}
                zReps[name].Value = earnedValue
            end
        end
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:chatFilter(event, ...)
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:chatFilter(event, ...)
    local msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...
	local skip = false
	if (db.betterReputation) and (event) then
		if (event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then
			skip = true
		end
		if ((event == "COMBAT_TEXT_UPDATE") and (msg == "FACTION")) then
			skip = true
		end
	end
    if (debug) then
        -- mod:zMSG("chatFrame = " .. tostring(chatFrame))
        mod:zMSG("event = " .. tostring(event))
        mod:zMSG("returns: " .. skip.." "..msg.." "..arg2.." "..arg3.." "..arg4.." "..arg5.." "..arg6.." "..arg7.." "..arg8.." "..arg9.." "..arg10.." "..arg11.." "..arg12.." "..arg13)
    end
	return skip, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13
end


--------------------------------------------------------------------------------
-- Name: zUtilities:gossipHandler()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:gossipHandler()
	if not IsShiftKeyDown() then
		if db.SkipGossip then
            self:skipGossip()
        end
	end
    if db.showQuestLevels then
        self:gossipQuestFormat()
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:IsFriend(name)
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:IsFriend(name)
	local _, bnet_online = BNGetNumFriends()
	for i=1,bnet_online do
		local _, _, _, _, _,    toonID, _, online = BNGetFriendInfo(i)

		if online and toonID then
			local _, toonName, _, realmName = BNGetToonInfo(toonID)
            if (toonName..'-'..realmName == name) or (toonName == name) then
                return true, tostring("bnet")
            end
		end
	end

	for i=1,GetNumFriends() do
		if  (i) == name then
            return true, tostring("friend")
        end
	end

	if IsInGuild() then
		for i=1, GetNumGuildMembers() do
            local gName = GetGuildRosterInfo(i)
			if (gName == name) or ((strsplit("-", gName, 2)) == name) then
                return true, tostring("guild")
            end
		end
	end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:inviteHandler()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:inviteHandler(sender)
    local friend, relationship = mod:IsFriend(sender)
    if friend then
        if ((relationship == "bnet" or "friend") and db.autoAcceptFriendInvites) or (relationship == "guild" and db.autoAcceptGuildInvites) then
            mod:zMSG("Accepting invite from: ".. sender .. "(" .. relationship .. ")")
            AcceptGroup()
        else
            mod:zMSG("Declining invite from: ".. sender)
            DeclineGroup()
        end
    end
    if (debug) then
        mod:zMSG("sender: " .. sender)
        mod:zMSG("friend: " .. tostring(friend))
        mod:zMSG("relationship: " .. relationship)
    end
end



--------------------------------------------------------------------------------
-- quest related functions
--------------------------------------------------------------------------------

local questtags, tags = {}, {
    Account    = "A",
	Elite      = "+",
	Group      = "G",
	Dungeon    = "D",
	Raid       = "R",
	PvP        = "P",
	Daily      = "•",
    Weekly     = "W",
	[2]        = "•",
    [3]        = "W",
	Heroic     = "H",
	Repeatable = "∞",
}

local TRIVIAL = "|cff%02x%02x%02x[%d%s%s]|r "..TRIVIAL_QUEST_DISPLAY
local NORMAL  = "|cff%02x%02x%02x[%d%s%s]|r ".. NORMAL_QUEST_DISPLAY

local chatEvents = {"SAY", "YELL", "GUILD", "GUILD_OFFICER",
                    "WHISPER", "WHISPER_INFORM", "SMART_WHISPER",
                    "BN_CONVERSATION", "BN_WHISPER", "BN_WHISPER_INFORM",
                    "PARTY", "PARTY_LEADER", "PARTY_GUIDE", "RAID",
                    "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT",
                    "INSTANCE_CHAT_LEADER", "ADDON"}

-- local chatEvents = {"SAY", "GUILD", "OFFICER", "WHISPER", "WHISPER_INFORM", "PARTY", "RAID", "RAID_LEADER", "BATTLEGROUND", "BATTLEGROUND_LEADER"}
-- for _,event in pairs(chatEvents) do
    -- ChatFrame_AddMessageEventFilter("CHAT_MSG_"..event, chatFormat)
-- end


function zUtilities:ceFilters()
    for _,event in pairs(chatEvents) do
        -- mod:zMSG(_ .. " event -> " .. "CHAT_MSG_" .. event)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_" .. event,mod.AddLinkColors)
            -- function(event,msg, ...)
                -- if msg then
                    -- return false, msg:gsub("(|c%x+|Hquest:%d+:(%d+))", "(%2) %1"), ...
                -- end
            -- end
        -- )
    end
end



function zUtilities:hex(r, g, b)
	if type(r) == 'table' then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end


function zUtilities:GetLinkColor(data)
	local type, id, arg1 = strmatch(data, "(%w+):(%d+):(%d+)")
	if not(type) then 
		return "|cffffff88" 
	end
	if (type == "item") then
		local quality = (select(3, GetItemInfo(id)))
        local level = (select(4, GetItemInfo(id)))
		if (quality) then
			return "|c" .. (select(4, GetItemQualityColor(quality))) .. "[" .. level .. "]"
		else
			return "|cffffff88"
		end
	elseif (type == "quest") then
		local qColor = GetQuestDifficultyColor(arg1)
        local _,_,_,_,nTag = mod:getTaggedQuestTitle(GetQuestLogIndexByID(id))
        return format("|cff%02x%02x%02x ", qColor.r * 255, qColor.g * 255, qColor.b * 255)
        -- return format("|cff%02x%02x%02x%s ", qColor.r * 255, qColor.g * 255, qColor.b * 255, nTag)
        -- return format("|cff%02x%02x%02x%s ", qColor.r * 255, qColor.g * 255, qColor.b * 255,mod:getTaggedQuestTitle(GetQuestLogIndexByID(id)))
		-- return nMsg:gsub("\[(.-)^)\](.-)", "\(%1\)")
        -- return nMsg:replace("/\)[^(]*$/", "")  \[([^]]+)\]
		
	elseif (type == "spell") then
		return "|cff71d5ff"
		
	elseif (type == "achievement") then
		return "|cffffff00"
		
	elseif (type == "trade") or (type == "enchant") then
		return "|cffffd000"
		
	elseif (type == "instancelock") then
		return "|cffff8000"
		
	elseif (type == "glyph") then
		return "|cff66bbff"
		
	elseif (type == "talent") then
		return "|cff4e96f7"
		
	elseif (type == "levelup") then
		return "|cffFF4E00"
		
	elseif (type == "battlepet") then
		local _, _, level, rarity = strmatch(data, "(%w+):(%d+):(%d+):(%d+)")
		if (rarity) then
			return "|c" .. (select(4, GetItemQualityColor(rarity))) .. "[" .. level .. "]"
		else
			return "|cffffff88"
		end
	else
		-- companions, other stuff we haven't included yet, 
		-- or items that haven't been cached
		return "|cffffff88" 
	end
end

function zUtilities:AddLinkColors(event, msg, ...)
	local data = strmatch(msg, "|H(.-)|h(.-)|h")
	if (data) then
		return false, msg:gsub("|H(.-)|h(.-)|h", mod:GetLinkColor(data) .. "|H%1|h%2|h|r"), ...
	else
		return false, msg, ...
	end
end
    
--------------------------------------------------------------------------------
-- Name: zUtilities:chatFormat()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:chatFormat(event, msg, ...)
	if msg then
		return false, msg:gsub("(|c%x+|Hquest:%d+:(%d+))", mod:GetLinkColor(msg) .. "(%2)|r %1"), ...
	end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:getTaggedQuestTitle()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:getTaggedQuestTitle(i)
    local name, level, suggestedGroup, isHeader, _, isComplete, frequency, questID = GetQuestLogTitle(i)
    local _, tagName = GetQuestTagInfo(questID)
    if isHeader or not name then return end

    if not (suggestedGroup) or (suggestedGroup == 0) then suggestedGroup = nil end
    local qColor = GetQuestDifficultyColor(level)
    local title = string.format("%s[%s%s%s%s]|r %s", mod:hex(qColor), level, tagName and tags[tagName] or "", frequency and tags[frequency] or "",suggestedGroup or "", name)
    local ntag = string.format("%s[%s%s%s%s]|r", mod:hex(qColor), level, tagName and tags[tagName] or "", frequency and tags[frequency] or "",suggestedGroup or "")
    return title, tagName, frequency, isComplete, ntag
end



--------------------------------------------------------------------------------
-- Name: zUtilities:questFormat(isActive, ...)
-- Abstract: helps with quest levels in gossip
--------------------------------------------------------------------------------
function zUtilities:questFormat(isActive, ...)
	local num = select('#', ...)
	if num == 0 then return end
    
	local skip = isActive and 5 or 6
    
	for j=1,num,skip do
		local title, level, isTrivial, frequency, isRepeatable, isLegendary  = select(j, ...)
		if isActive then frequency, isRepeatable = nil end
        if level == -1 then level = UnitLevel("player") end
		if title and level and level ~= -1 then
			local qColor = GetQuestDifficultyColor(level)
			_G["GossipTitleButton"..i]:SetFormattedText(
                isActive and isTrivial and TRIVIAL or NORMAL,
                qColor.r*255, qColor.g*255, qColor.b*255,
                level, isRepeatable and tags.Repeatable or "",
                frequency and tags.Daily or "", title)
		end
		i = i + 1
	end
	i = i + 1
end



--------------------------------------------------------------------------------
-- Name: zUtilities:gossipQuestFormat()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:gossipQuestFormat()
	i = 1
	mod:questFormat(false, GetGossipAvailableQuests()) -- title, level, isTrivial, frequency, isRepeatable , isLegendary 
	mod:questFormat(true, GetGossipActiveQuests()) -- title, level, isTrivial, isComplete, isLegendary 
end



--------------------------------------------------------------------------------
-- Name: updateQuestFrame()
-- Abstract: Add Quest Levels to the QuestFrameGreetingPanel
--------------------------------------------------------------------------------
function zUtilities:updateQuestFrame()
	local nact,navl = GetNumActiveQuests(), GetNumAvailableQuests()
	local title,level,button
	local o,GetTitle,GetLevel = 0,GetActiveTitle,GetActiveLevel
	for i = 1,nact+navl do
		if(i==nact+1) then
			o,GetTitle,GetLevel = nact,GetAvailableTitle,GetAvailableLevel
		end
		title,level = GetTitle(i-o), GetLevel(i-o)
        local qColor = GetQuestDifficultyColor(level)
		if level > 0 then
			button = getglobal("QuestTitleButton"..i)
			button:SetText(format('%s[%d]|r %s',mod:hex(qColor),level,title))
		end
	end
    if (debug) then
        mod:zMSG("debug: event fired -> QUEST_LOG_UPDATE")
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:updateQuestLog()
-- Abstract: Add Quest Levels to the QuestLogFrame
--------------------------------------------------------------------------------
function zUtilities:updateQuestLog()
    local numEntries, numQuests = GetNumQuestLogEntries()
    local headerIndex = 0
    for questLogIndex=1,numEntries do
        -- local questLogIndex = button.questLogIndex or 0
        local name, level, suggestedGroup, isHeader, _, isComplete, frequency, questID , startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questLogIndex)
		local title, tag, frequency, isComplete = mod:getTaggedQuestTitle(questLogIndex)
        -- print("debug: Button #" .. i .. ": " .. "questID: " .. tostring(button.questID) .. " Old Title: " .. tostring(button.Text:GetText()) .. " New Title: " .. tostring(title))
		if isOnMap and not isTask and not isHeader then
        headerIndex = headerIndex + 1
        local button = QuestLogQuests_GetTitleButton(headerIndex)
        button.Text:SetText(title)
        button.Text:SetPoint("TOPLEFT",15,-4)
        button.Text:SetWidth(215)
        button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth() + 2, 0)
        button:SetHeight(button:GetHeight()+1)
		-- if (tag or daily) and not complete then button.Text:SetText("") end
        if (debug) then
            -- mod:zMSG("debug: Button #" .. i .. ": " .. "questID: " .. tostring(button.questID) .. " Old Title: " .. tostring(button.Text:GetText()) .. " New Title: " .. tostring(title))
        end
        -- end
        end
	end
    if (debug) then
        mod:zMSG("debug: hook fired -> QuestLog_Update")
    end
end

-- /run local ne, nq = GetNumQuestLogEntries() for qi=1,ne do local b = QuestLogQuests_GetTitleButton(qi) print("ButtonID: " .. b.Text:GetText() .. " - QuestID: " .. b.questID) end

--------------------------------------------------------------------------------
-- Name: zUtilities:updateWatchFrame()
-- Abstract: Add Quest Levels to the Quest Watch Frame
--------------------------------------------------------------------------------
function zUtilities:updateWatchFrame()
	local questWatchMaxWidth, watchTextIndex = 0, 1
	for i=1,GetNumQuestWatches() do
		local qi = GetQuestIndexForWatch(i)
		-- if qi then
			-- local numObjectives = GetNumQuestLeaderBoards(qi)
            local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i)
            if (not questID) then break end
			-- if numObjectives > 0 then
            local isSequenced = IsQuestSequenced(questID)
            local existingBlock = QUEST_TRACKER_MODULE:GetExistingBlock(questID)
            local block = QUEST_TRACKER_MODULE:GetBlock(questID)
            local header = block.HeaderText
            local name, level, suggestedGroup, isHeader, _, isComplete, frequency, _ = GetQuestLogTitle(questLogIndex)
            local qColor = GetQuestDifficultyColor(level)
            local ftitle = format('%s', mod:getTaggedQuestTitle(questLogIndex))
            local _,_,_,_,nTag = mod:getTaggedQuestTitle(questLogIndex)
            local titleWidth = strlen(nTag)
            local ctitle = format('%s%s|r',mod:hex(qColor),ftitle)
            local oldBlockHeight = existingBlock.Height
            -- local oldHeight = QUEST_TRACKER_MODULE:SetStringText(oldBlock.HeaderText, title, nil, OBJECTIVE_TRACKER_COLOR["Header"])
            local oldHeight = QUEST_TRACKER_MODULE:SetStringText(existingBlock.HeaderText, title, nil, OBJECTIVE_TRACKER_COLOR["Header"])
            local newHeight = QUEST_TRACKER_MODULE:SetStringText(existingBlock.HeaderText, ftitle, nil, OBJECTIVE_TRACKER_COLOR["Header"])
            -- existingBlock:SetHeight(oldBlockHeight + newHeight - oldHeight)
            -- QUEST_TRACKER_MODULE:SetBlockHeader(block, format('%s', mod:getTaggedQuestTitle(questLogIndex)), questLogIndex, isComplete)
            -- block:SetHeight(block:GetHeight()+3)
            if header then
                -- header:SetText(ftitle)
                -- header:SetTextColor(qColor.r, qColor.b, qColor.b)
                -- header.colorstyle = qColor
                local height = QUEST_TRACKER_MODULE:SetStringText(header, ftitle, nil, OBJECTIVE_TRACKER_COLOR["Header"])
                block.height = height
                -- block.lineWidth = OBJECTIVE_TRACKER_TEXT_WIDTH - OBJECTIVE_TRACKER_ITEM_WIDTH - titleWidth
                -- local headerWidth = header:SetWidth(block.lineWidth)
                -- block:SetWidth(0)
                block:SetPoint("LEFT", -10, 25)
            end
            -- block:SetWidth(block:GetWidth()+1)
            -- /run ObjectiveTrackerBlocksFrame.currentBlock.itemButton:Click() 
				-- for bi,butt in pairs(WATCHFRAME_QUESTLINES) do
					-- if butt.text:GetText() == GetQuestLogTitle(questLogIndex) then
                        -- butt.text:SetText(format('%s', mod:getTaggedQuestTitle(qiquestLogIndex
                    -- end
				-- end
			-- end
		-- end
	end
    if (debug) then
        mod:zMSG("debug: hook fired -> WatchFrame_Update")
    end
end



--------------------------------------------------------------------------------
-- Name: zUtilities:ZONE_CHANGED_NEW_AREA()
-- Abstract: 
--------------------------------------------------------------------------------
function zUtilities:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
end



--------------------------------------------------------------------------------
-- Name: zUtilities:autoTitleUpdate(switch)
-- Abstract: 
--------------------------------------------------------------------------------
-- function zUtilities:autoTitleUpdate(switch)
    -- if (tostring(switch) == "x") then
        -- self:CancelTimer(self.tautoTitleUpdate)
        -- if (debug) then
            -- mod:zMSG("|cffff0000DEBUG|r cancelling self.tautoTitleUpdate: " .. self.tautoTitleUpdate)
        -- end
    -- elseif (tonumber(switch)) and (db.AutoUpdateTitle) then
        -- local interval = tonumber(switch * 60)
        -- if (self.tautoTitleUpdate) then self:CancelTimer(self.tautoTitleUpdate) end
        -- self.tautoTitleUpdate = self:ScheduleRepeatingTimer("randomTitle", interval)
        -- if (debug) then
            -- mod:zMSG("|cffff0000DEBUG|r changing title every ".. interval .. " mins (" .. switch .. ") seconds / self.tautoTitleUpdate: " .. self.tautoTitleUpdate)
        -- end
    -- end
        -- self.randomTitle()
-- end



--------------------------------------------------------------------------------
-- Name: zUtilities:randomTitle()
-- Abstract: 
--------------------------------------------------------------------------------
-- function zUtilities:randomTitle()
    -- local titles={}
    -- for t=1,GetNumTitles()-1,1 do
        -- if (IsTitleKnown(t) == true) then
            -- table.insert(titles,t)
        -- end
    -- end
    
    -- local titleNumber=random(#titles)
    -- local titleName = tostring(GetTitleName(titles[titleNumber]))
    -- print("Using title: " .. titleName)
    -- SetCurrentTitle(titles[titleNumber])
	
    -- return titleName, titleNumber
-- end


