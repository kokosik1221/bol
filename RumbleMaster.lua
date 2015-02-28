--[[

	Script Name: RUMBLE MASTER 
    	Author: kokosik1221
	Last Version: 0.25
	28.02.2015

]]--


if myHero.charName ~= "Rumble" then return end

_G.AUTOUPDATE = true


local version = "0.25"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/RumbleMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>RumbleMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/RumbleMaster.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end
local REQUIRED_LIBS = {
	["vPrediction"] = "https://raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua",
	["Prodiction"] = "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua",
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
}
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#FF0000\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end
for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		if DOWNLOAD_LIB_NAME ~= "Prodiction" then 
			require(DOWNLOAD_LIB_NAME) 
		end
		if DOWNLOAD_LIB_NAME == "Prodiction" and VIP_USER then 
			require(DOWNLOAD_LIB_NAME) 
			prodstatus = true 
		end
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local Q = {name = "Flamespitter", range = 600}
local W = {name = "Scrap Shield"}
local E = {name = "Electro-Harpoon", range = 850, speed = 1200, delay = 0.25, width = 90}
local R = {name = "The Equalizer", range = 1700, speed = 2600, delay = 0.25, width = 100, wall = 900}
local RTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_MAGIC)
local QReady, WReady, EReady, RReady, IReady, zhonyaready = false, false, false, false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, E.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, E.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, zhonyaslot = nil, nil
local killstring = {}
local TargetTable = {
	AP = {
		"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
		"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
		"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
	},	
	Support = {
		"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
	},	
	Tank = {
		"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
		"Warwick", "Yorick", "Zac"
	},
	AD_Carry = {
		"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
		"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
	},
	Bruiser = {
		"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
		"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
	}
}

function OnLoad()
	Menu()
	print("<b><font color=\"#6699FF\">Rumble Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
end

function OnTick()
	Check()
	if Cel ~= nil and MenuRumble.comboConfig.CEnabled then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuRumble.harrasConfig.HEnabled or MenuRumble.harrasConfig.HTEnabled) then
		Harrass()
	end
	if MenuRumble.farm.LaneClear then
		Farm()
	end
	if MenuRumble.jf.JFEnabled then
		JungleFarm()
	end
	if MenuRumble.prConfig.AZ then
		autozh()
	end
	if MenuRumble.prConfig.ALS then
		autolvl()
	end
	KillSteall()
	if MenuRumble.comboConfig.rConfig.CRKD and Cel then
		if VIP_USER then
			CastRVIP(RCel)
		else
			CastRFREE(RCel)
		end
	end
end

function Menu()
	VP = VPrediction()
	MenuRumble = scriptConfig("Rumble Master "..version, "Rumble Master "..version)
	MenuRumble:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuRumble:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuRumble.orb == 1 then
		MenuRumble:addSubMenu("[Rumble Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuRumble.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_MAGIC)
	TargetSelector.name = "Rumble"
	MenuRumble:addTS(TargetSelector)
	MenuRumble:addSubMenu("[Rumble Master]: Combo Settings", "comboConfig")
	MenuRumble.comboConfig:addSubMenu("[Rumble Master]: Q Settings", "qConfig")
	MenuRumble.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.comboConfig:addSubMenu("[Rumble Master]: W Settings", "wConfig")
	MenuRumble.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.comboConfig:addSubMenu("[Rumble Master]: E Settings", "eConfig")
	MenuRumble.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
	MenuRumble.comboConfig:addSubMenu("[Rumble Master]: R Settings", "rConfig")
	MenuRumble.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.comboConfig.rConfig:addParam("RM", "Cast (R) Mode", SCRIPT_PARAM_LIST, 2, {"Normal", "Killable"})
	MenuRumble.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuRumble.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuRumble.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuRumble.comboConfig:addParam('HEAT', 'Use Combo If Heat < ', SCRIPT_PARAM_SLICE, 80, 1, 100, 0)
	MenuRumble:addSubMenu("[Rumble Master]: Harras Settings", "harrasConfig")
	MenuRumble.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 1, {"|Q|", "|E|"}) 
	MenuRumble.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuRumble.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuRumble.harrasConfig:addParam('HEAT', 'Use Harass If Heat < ', SCRIPT_PARAM_SLICE, 80, 1, 100, 0)
	MenuRumble:addSubMenu("[Rumble Master]: KS Settings", "ksConfig")
	MenuRumble.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.ksConfig:addParam("RKS", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, false)
	MenuRumble:addSubMenu("[Rumble Master]: Farm Settings", "farm")
	MenuRumble.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuRumble.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.farm:addParam("EF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuRumble.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuRumble.farm:addParam('HEAT', 'Farm If Heat < ', SCRIPT_PARAM_SLICE, 80, 1, 100, 0)
	MenuRumble:addSubMenu("[Rumble Master]: Jungle Farm Settings", "jf")
	MenuRumble.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuRumble.jf:addParam('HEAT', 'Jungle Farm If Heat < ', SCRIPT_PARAM_SLICE, 80, 1, 100, 0)
	MenuRumble:addSubMenu("[Rumble Master]: Draw Settings", "drawConfig")
	MenuRumble.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuRumble.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,0,200,0})
	MenuRumble.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuRumble:addSubMenu("[Rumble Master]: Misc Settings", "prConfig")
	MenuRumble.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuRumble.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuRumble.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuRumble.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuRumble.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuRumble.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuRumble.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuRumble.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuRumble.comboConfig:permaShow("CEnabled")
	MenuRumble.harrasConfig:permaShow("HEnabled")
	MenuRumble.harrasConfig:permaShow("HTEnabled")
	MenuRumble.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Rumble Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Rumble Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
	if heroManager.iCount < 10 then
		print("<font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function caa()
	if MenuRumble.orb == 1 then
		if MenuRumble.comboConfig.uaa then
			SxOrb:EnableAttacks()
		elseif not MenuRumble.comboConfig.uaa then
			SxOrb:DisableAttacks()
		end
	end
end

function GetCustomTarget()
 	TargetSelector:update()	
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
		return _G.MMA_Target
	end
	if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then 
		return _G.AutoCarry.Attack_Crosshair.target 
	end
	return TargetSelector.target
end

function Check()
	RTargetSelector:update()
	RCel = RTargetSelector.target
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, E.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuRumble.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if MenuRumble.drawConfig.DLC then 
		_G.DrawCircle = DrawCircle2 
	else 
		_G.DrawCircle = _G.oldDrawCircle 
	end
end

function UseItems(unit)
	if unit ~= nil then
		for _, item in pairs(Items) do
			item.slot = GetInventorySlotItem(item.id)
			if item.slot ~= nil then
				if item.reqTarget and GetDistance(unit) < item.range then
					CastSpell(item.slot, unit)
				elseif not item.reqTarget then
					if (GetDistance(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
						CastSpell(item.slot)
					end
				end
			end
		end
	end
end

function getHitBoxRadius(target)
	return GetDistance(target.minBBox, target.maxBBox)/2
end

function Combo()
	UseItems(Cel)
	if myHero.mana < MenuRumble.comboConfig.HEAT then
		if MenuRumble.comboConfig.qConfig.USEQ and GetDistance(Cel) < Q.range then
			CastQ(Cel)
		end
	end
	if myHero.mana < MenuRumble.comboConfig.HEAT then
		if MenuRumble.comboConfig.wConfig.USEW then
			CastW()
		end
	end
	if myHero.mana < MenuRumble.comboConfig.HEAT or TargetHaveBuff("RumbleGrenade", myHero) then
		if MenuRumble.comboConfig.eConfig.USEE and GetDistance(Cel) < E.range then
			CastE(Cel)
		end
	end
	if MenuRumble.comboConfig.rConfig.USER and RReady and GetDistance(RCel) <= R.range and ValidTarget(RCel) then
		if MenuRumble.comboConfig.rConfig.RM == 1 then
			if VIP_USER then
				CastRVIP(RCel)
			else
				CastRFREE(RCel)
			end
		end
		if MenuRumble.comboConfig.rConfig.RM == 2 then
			if myHero.mana >= 50 then
				r = getDmg("R", RCel, myHero, 2)
			else
				r = getDmg("R", RCel, myHero, 1)
			end
			if Cel.health < r then
				if VIP_USER then
					CastRVIP(RCel)
				else
					CastRFREE(RCel)
				end
			end
		end
	end
end

function Harrass()
	if myHero.mana < MenuRumble.harrasConfig.HEAT then
		if MenuRumble.harrasConfig.HM == 1 then
			CastQ(Cel)
		end
	end
	if myHero.mana < MenuRumble.harrasConfig.HEAT or TargetHaveBuff("RumbleGrenade", myHero) then
		if MenuRumble.harrasConfig.HM == 2 then
			CastE(Cel)
		end
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuRumble.farm.QF
	EMode =  MenuRumble.farm.EF
	if myHero.mana < MenuRumble.farm.HEAT then
		for i, minion in pairs(EnemyMinions.objects) do
			if QMode == 3 then
				if minion ~= nil and not minion.dead then
					CastSpell(_Q, minion)
				end
			elseif QMode == 2 then
				if minion ~= nil and not minion.dead then
					if minion.health <= getDmg("Q", minion, myHero) then
						CastSpell(_Q, minion)
					end
				end
			end
			if EMode == 3 then
				if minion ~= nil and not minion.dead then
					CastE(minion)
				end
			elseif EMode == 2 then
				if minion ~= nil and not minion.dead then
					if minion.health <= getDmg("E", minion, myHero, 3) then
						CastE(minion)
					end
				end
			end
		end
	end
end

function JungleFarm()
	if myHero.mana < MenuRumble.jf.HEAT then
		JungleMinions:update()
		for i, minion in pairs(JungleMinions.objects) do
			if MenuRumble.jf.EJF then
				if minion ~= nil and not minion.dead then
					CastE(minion)
				end
			end
			if MenuRumble.jf.QJF then
				if minion ~= nil and not minion.dead then
					CastSpell(_Q, minion)
				end
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuRumble.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuRumble.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuRumble.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuRumble.drawConfig.DST and MenuRumble.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuRumble.drawConfig.DQRC[2], MenuRumble.drawConfig.DQRC[3], MenuRumble.drawConfig.DQRC[4]))
		end
	end
	if MenuRumble.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuRumble.drawConfig.DQR and QReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuRumble.drawConfig.DQRC[2], MenuRumble.drawConfig.DQRC[3], MenuRumble.drawConfig.DQRC[4]))
	end
	if MenuRumble.drawConfig.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuRumble.drawConfig.DERC[2], MenuRumble.drawConfig.DERC[3], MenuRumble.drawConfig.DERC[4]))
	end
	if MenuRumble.drawConfig.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuRumble.drawConfig.DRRC[2], MenuRumble.drawConfig.DRRC[3], MenuRumble.drawConfig.DRRC[4]))
	end	
end

function KillSteall()
	for i = 1, heroManager.iCount do
		local enemy = heroManager:getHero(i)
		if myHero.mana >= 50 then
			QDMG = getDmg("Q", enemy, myHero, 3)
			EDMG = getDmg("E", enemy, myHero, 3)
			RDMG = getDmg("R", enemy, myHero, 2)
			IDMG = (50 + (20 * myHero.level))
		else
			QDMG = getDmg("Q", enemy, myHero, 1)
			EDMG = getDmg("E", enemy, myHero, 1)
			RDMG = getDmg("R", enemy, myHero, 1)
			IDMG = (50 + (20 * myHero.level))
		end
		if ValidTarget(enemy) and enemy ~= nil and enemy.team ~= player.team and not enemy.dead and enemy.visible then
			if enemy.health < IDMG and IReady and GetDistance(enemy) <= 600 and MenuRumble.ksConfig.IKS then
				CastSpell(IgniteKey, enemy)
			elseif enemy.health < QDMG and GetDistance(enemy) < Q.range and MenuRumble.ksConfig.QKS then
				CastQ(enemy)
			elseif enemy.health < EDMG and GetDistance(enemy) < E.range and MenuRumble.ksConfig.EKS then
				CastE(enemy)
			elseif enemy.health < RDMG and GetDistance(enemy) < R.range and MenuRumble.ksConfig.RKS then
				if VIP_USER then
					CastRVIP()
				else
					CastRFREE(enemy)
				end
			end
		end
	end
end

function DmgCalc()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible then
			if myHero.mana >= 50 then
				QDMG = getDmg("Q", enemy, myHero, 3)
				EDMG = getDmg("E", enemy, myHero, 3)
				RDMG = getDmg("R", enemy, myHero, 2)
				IDMG = (50 + (20 * myHero.level))
			else
				QDMG = getDmg("Q", enemy, myHero, 1)
				EDMG = getDmg("E", enemy, myHero, 1)
				RDMG = getDmg("R", enemy, myHero, 1)
				IDMG = (50 + (20 * myHero.level))
			end
			if enemy.health > (QDMG + EDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < EDMG then
				killstring[enemy.networkID] = "E Kill!"
			elseif enemy.health < RDMG then
				killstring[enemy.networkID] = "R Kill!"
			end
		end
	end
end

function CastQ(unit)
	if QReady and ValidTarget(unit) then
		if VIP_USER and MenuRumble.prConfig.pc then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_Q, unit)
		end	
	end
end

function CastW()
	if WReady then
		if VIP_USER and MenuRumble.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end	
	end
end

function CastE(unit)
	if EReady and ValidTarget(unit) then
		if MenuRumble.prConfig.pro == 1 then
			local CastPosition,  HitChance, Position = VP:GetLineCastPosition(unit, E.delay, E.width, E.range, E.speed, myHero, true)
			if HitChance >= 2 then
				if VIP_USER and MenuRumble.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_E, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MenuRumble.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetLineAOEPrediction(unit, E.range, E.speed, E.delay, E.width)
			if Position ~= nil and not info.mCollision() then
				if VIP_USER and MenuRumble.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end	
			end
		end
	end
end

function CastRFREE(unit)
	if GetDistance(unit) < R.range and RReady then
		local pos, HitChance, Position = VP:GetPredictedPos(unit, R.delay, R.speed, myHero, false)
		if Position and HitChance >= 2 then
			CastSpell(_R, Position.x, Position.z)
		end
	end
end

function CastRVIP(unit)
	local CastPosition1, CastPosition2 = CalcUltVIP(unit)
    if CastPosition1 ~= nil and CastPosition2 ~= nil then
		Packet("S_CAST", {spellId = _R, fromX = CastPosition1.x, fromY = CastPosition1.z, toX = CastPosition2.x, toY = CastPosition2.z}):send()
	end
end

assert(load(Base64Decode("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"), nil, "bt", _ENV))()

function EnemyCount(point, range)
	local count = 0
	for _, enemy in pairs(GetEnemyHeroes()) do
		if enemy and not enemy.dead and GetDistance(point, enemy) <= range then
			count = count + 1
		end
	end            
	return count
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuRumble.comboConfig.ST then
		local dist = 0
		local Selecttarget = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				if GetDistance(enemy, mousePos) <= dist or Selecttarget == nil then
					dist = GetDistance(enemy, mousePos)
					Selecttarget = enemy
				end
			end
		end
		if Selecttarget and dist < 300 then
			if SelectedTarget and Selecttarget.charName == SelectedTarget.charName then
				SelectedTarget = nil
				if MenuRumble.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuRumble.comboConfig.ST then 
					print("New target selected: "..Selecttarget.charName) 
				end
			end
		end
	end
end

function SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end

function arrangePrioritysTT()
    for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(TargetTable.AD_Carry, enemy, 1)
		SetPriority(TargetTable.AP,       enemy, 1)
		SetPriority(TargetTable.Support,  enemy, 2)
		SetPriority(TargetTable.Bruiser,  enemy, 2)
		SetPriority(TargetTable.Tank,     enemy, 3)
    end
end

function arrangePrioritys()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(TargetTable.AD_Carry, enemy, 1)
		SetPriority(TargetTable.AP, enemy, 2)
		SetPriority(TargetTable.Support, enemy, 3)
		SetPriority(TargetTable.Bruiser, enemy, 4)
		SetPriority(TargetTable.Tank, enemy, 5)
	end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
  radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
  
  local points = {}
  for theta = 0, 2 * math.pi + quality, quality do
    local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
    points[#points + 1] = D3DXVECTOR2(c.x, c.y)
  end
  
  DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
  if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
  
  if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
    DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
  end
end

-----SCRIPT STATUS------------
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("QDGEEKCIJEC") 
