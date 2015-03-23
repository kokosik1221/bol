--[[

	Script Name: Gragas MASTER 
    	Author: kokosik1221
	Last Version: 0.81
	23.03.2015
	
]]--


if myHero.charName ~= "Gragas" then return end

_G.AUTOUPDATE = true


local version = "0.81"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/GragasMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>GragasMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/GragasMaster.version")
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
	["DivinePred"] = ""
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
		if DOWNLOAD_LIB_NAME == "DivinePred" and VIP_USER then 
			require(DOWNLOAD_LIB_NAME) 
		end
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

local InterruptList = {
	{charName = "FiddleSticks", spellName = "Crowstorm"},
    {charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    {charName = "Nunu", spellName = "AbsoluteZero"},
    {charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    {charName = "Katarina", spellName = "KatarinaR"},
    {charName = "Karthus", spellName = "FallenOne"},
    {charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    {charName = "Galio", spellName = "GalioIdolOfDurand"},
    {charName = "Darius", spellName = "DariusExecute"},
    {charName = "MonkeyKing", spellName = "MonkeyKingSpinToWin"},
    {charName = "Vi", spellName = "ViR"},
    {charName = "Shen", spellName = "ShenStandUnited"},
    {charName = "Urgot", spellName = "UrgotSwap2"},
    {charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    {charName = "Lucian", spellName = "LucianR"},
    {charName = "Warwick", spellName = "InfiniteDuress"},
    {charName = "Urgot", spellName = "UrgotSwap2"},
    {charName = "Xerath", spellName = "XerathLocusOfPower2"},
    {charName = "Velkoz", spellName = "VelkozR"},
    {charName = "Skarner", spellName = "SkarnerImpale"},
}

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local Q = {name = "Barrel Roll", range = 850, speed = 1100, delay = 0.25, width = 330, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Drunken Rage", Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Body Slam", range = 650, speed = math.huge, delay = 0.25, width = 100, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Explosive Cask", range = 1150, speed = 1300, delay = 0.5, width = 400, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local IReady, zhonyaready, recall  = false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, zhonyaslot = nil, nil
local killstring = {}
local TargetTable = {
	AP = {
		"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Annie", "Heimerdinger", "Karthus",
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
	print("<b><font color=\"#6699FF\">Gragas Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Gragas Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Gragas Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if Cel ~= nil and MenuGragy.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGragy.comboConfig.manac and not recall then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuGragy.harrasConfig.HEnabled or MenuGragy.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuGragy.harrasConfig.manah and not recall then
		Harrass()
	end
	if MenuGragy.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuGragy.farm.manaf and not recall then
		Farm()
	end
	if MenuGragy.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGragy.jf.manajf and not recall then
		JungleFarm()
	end
	if MenuGragy.prConfig.AZ and not recall then
		autozh()
	end
	if MenuGragy.prConfig.ALS and not recall then
		autolvl()
	end
	if MenuGragy.comboConfig.qConfig.ADQ then
		AutoQ()
	end
	if MenuGragy.comboConfig.rConfig.CRKD and Cel and not recall then
		if not MenuGragy.comboConfig.rConfig.CBE then
			CastR(Cel)
		else
			CastRBehind(Cel)
		end
	end
	if not recall then
		KillSteall()
	end
end


function Menu()
	if VIP_USER then
		DP = DivinePred()
	end
	VP = VPrediction()
	MenuGragy = scriptConfig("Gragas Master "..version, "Gragas Master "..version)
	MenuGragy:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuGragy:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuGragy.orb == 1 then
		MenuGragy:addSubMenu("[Gragas Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuGragy.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_MAGIC)
	TargetSelector.name = "Gragas"
	MenuGragy:addTS(TargetSelector)
	MenuGragy:addSubMenu("[Gragas Master]: Combo Settings", "comboConfig")
	MenuGragy.comboConfig:addSubMenu("[Gragas Master]: Q Settings", "qConfig")
	MenuGragy.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.comboConfig.qConfig:addParam("ADQ", "Auto Detonate (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.comboConfig:addSubMenu("[Gragas Master]: W Settings", "wConfig")
	MenuGragy.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.comboConfig:addSubMenu("[Gragas Master]: E Settings", "eConfig")
	MenuGragy.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.comboConfig:addSubMenu("[Gragas Master]: R Settings", "rConfig")
	MenuGragy.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.comboConfig.rConfig:addParam("RMODE", "Cast Mode:", SCRIPT_PARAM_LIST, 2, {"Normal", "Killable", "Can Hit X"}) 
	MenuGragy.comboConfig.rConfig:addParam("HXC", "X = ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuGragy.comboConfig.rConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.comboConfig.rConfig:addParam("CBE", "Cast Behind Enemy", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.comboConfig.rConfig:addParam("qqq", "OFF (Cast To Target POS)", SCRIPT_PARAM_INFO,"")
	MenuGragy.comboConfig.rConfig:addParam("qqq", "ON (Try Cast Behind Target)", SCRIPT_PARAM_INFO,"")
	MenuGragy.comboConfig.rConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuGragy.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuGragy.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuGragy.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuGragy:addSubMenu("[Gragas Master]: Harras Settings", "harrasConfig")
	MenuGragy.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 1, {"|Q|", "|E|Q|"}) 
	MenuGragy.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuGragy.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuGragy.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuGragy:addSubMenu("[Gragas Master]: Extra Settings", "exConfig")
	MenuGragy.exConfig:addParam("ARF", "Auto (R) If Can Hit X", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.exConfig:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MenuGragy.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.exConfig:addParam("AQF", "Auto (Q) If Can Hit X", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.exConfig:addParam("AQX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MenuGragy:addSubMenu("[Gragas Master]: Interrupt Settings", "iConfig")
    MenuGragy.iConfig:addSubMenu("Auto-Interrupt Spells", "ES")
	for i, enemy in ipairs(GetEnemyHeroes()) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				MenuGragy.iConfig.ES:addParam(champ.spellName, "Stop "..champ.charName.." "..champ.spellName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end
	MenuGragy.iConfig:addParam("UI", "Use Auto-Interrupt (E)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy:addSubMenu("[Gragas Master]: KS Settings", "ksConfig")
	MenuGragy.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.ksConfig:addParam("EKS", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
	MenuGragy:addSubMenu("[Gragas Master]: Farm Settings", "farm")
	MenuGragy.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuGragy.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 1, { "No", "Yes"})
	MenuGragy.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.farm:addParam("EF",  "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuGragy.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuGragy.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGragy:addSubMenu("[Gragas Master]: Jungle Farm Settings", "jf")
	MenuGragy.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	MenuGragy.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGragy:addSubMenu("[Gragas Master]: Draw Settings", "drawConfig")
	MenuGragy.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuGragy.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuGragy.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuGragy:addSubMenu("[Gragas Master]: Misc Settings", "prConfig")
	MenuGragy.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuGragy.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuGragy.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuGragy.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuGragy.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuGragy.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "MID","JUNGLE"})
	MenuGragy.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGragy.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuGragy.comboConfig:permaShow("CEnabled")
	MenuGragy.harrasConfig:permaShow("HEnabled")
	MenuGragy.harrasConfig:permaShow("HTEnabled")
	MenuGragy.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	if heroManager.iCount < 10 then
		print("<font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function caa()
	if MenuGragy.orb == 1 then
		if MenuGragy.comboConfig.uaa then
			SxOrb:EnableAttacks()
		elseif not MenuGragy.comboConfig.uaa then
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
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, R.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuGragy.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if MenuGragy.drawConfig.DLC then 
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

function AutoQ()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if enemy and barrel and GetDistance(barrel,enemy) <= Q.width then
			if myHero:GetSpellData(_Q).name == "GragasQToggle" then
				CastSpell(_Q)
			end
		end
	end
end

function Combo()
	UseItems(Cel)
	if R.Ready() and MenuGragy.comboConfig.rConfig.USER and GetDistance(Cel) < R.range then
		if MenuGragy.comboConfig.rConfig.RMODE == 1 then
			if not MenuGragy.comboConfig.rConfig.CBE then
				CastR(Cel)
			else
				CastRBehind(Cel)
			end
		elseif MenuGragy.comboConfig.rConfig.RMODE == 2 then
			local r = myHero:CalcDamage(Cel, (100 * myHero:GetSpellData(3).level + 100 + 0.7 * myHero.ap))
			if Cel.health < r then
				if not MenuGragy.comboConfig.rConfig.CBE then
					CastR(Cel)
				else
					CastRBehind(Cel)
				end
			end
		elseif MenuGragy.comboConfig.rConfig.RMODE == 3 then
			local rPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(Cel, R.delay, R.width, R.range, R.speed, myHero)
			if ValidTarget(Cel) and rPos ~= nil and maxHit >= MenuGragy.comboConfig.rConfig.HXC then		
				if VIP_USER and MenuGragy.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
				else
					CastSpell(_R, rPos.x, rPos.z)
				end	
			end
		end
	end
	if Q.Ready() and MenuGragy.comboConfig.qConfig.USEQ and GetDistance(Cel) < Q.range then
		CastQ(Cel)
	end
	if E.Ready() and MenuGragy.comboConfig.eConfig.USEE and GetDistance(Cel) <= E.range then
		CastE(Cel)
	end
	if W.Ready() and MenuGragy.comboConfig.wConfig.USEW and GetDistance(Cel) < E.range and not Q.Ready() and not E.Ready() then
		CastW()
	end
end

function Harrass()
	if MenuGragy.harrasConfig.HM == 1 then
		if Q.Ready() and GetDistance(Cel) < Q.range then
			CastQ(Cel)
		end
	end
	if MenuGragy.harrasConfig.HM == 2 then
		if Q.Ready() and E.Ready() and GetDistance(Cel) <= E.range then
			CastE(Cel)
		end
		if TargetHaveBuff("Stun", Cel) and GetDistance(Cel) <= Q.range then
			CastQ(Cel)
		end
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuGragy.farm.QF
	WMode =  MenuGragy.farm.WF
	EMode =  MenuGragy.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if Q.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				local Pos, Hit = BestQFarmPos(Q.range, Q.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		elseif QMode == 2 then
			if Q.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					CastSpell(_Q, minion.x, minion.z)
				end
			end
		end
		if EMode == 3 then
			if E.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				CastE(minion)
			end
		elseif EMode == 2 then
			if E.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				if minion.health <= getDmg("E", minion, myHero) then
					CastE(minion)
				end
			end
		end
		if WMode == 2 then
			if W.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				CastW()
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuGragy.jf.EJF then
			if E.Ready() and minion ~= nil and not minion.dead and GetDistance(minion) <= E.range then
				CastE(minion)
			end
		end
		if MenuGragy.jf.QJF then
			if Q.Ready() and minion ~= nil and not minion.dead and GetDistance(minion) <= Q.range then
				local Pos, Hit = BestQFarmPos(Q.range, Q.width, JungleMinions.objects)
				if Pos ~= nil and myHero:GetSpellData(_Q).name ~= "GragasQToggle" then
					CastSpell(_Q, Pos.x, Pos.z)
				end
				DelayAction(function() Q2JF() end, 2)
			end
		end
		if ValidTarget(minion, myHero.range+65) then
			myHero:Attack(minion)
		end
	end
end

function Q2JF()
	if myHero:GetSpellData(_Q).name == "GragasQToggle" then
		CastSpell(_Q)
	end
end

function _GetDistanceSqr(p1, p2)
    p2 = p2 or player
    if p1 and p1.networkID and (p1.networkID ~= 0) and p1.visionPos then p1 = p1.visionPos end
    if p2 and p2.networkID and (p2.networkID ~= 0) and p2.visionPos then p2 = p2.visionPos end
    return GetDistanceSqr(p1, p2)
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if _GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function BestQFarmPos(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.visionPos or object, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function autozh()
	local count = EnemyCount(myHero, MenuGragy.prConfig.AZMR)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuGragy.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuGragy.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {}
		if MenuGragy.prConfig.AL == 1 then			
			a = {_Q,_E,_W,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}
		else
			a = {_Q,_W,_E,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
		end
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuGragy.drawConfig.DST and MenuGragy.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuGragy.drawConfig.DQRC[2], MenuGragy.drawConfig.DQRC[3], MenuGragy.drawConfig.DQRC[4]))
		end
	end
	if MenuGragy.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuGragy.drawConfig.DQR and Q.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuGragy.drawConfig.DQRC[2], MenuGragy.drawConfig.DQRC[3], MenuGragy.drawConfig.DQRC[4]))
	end
	if MenuGragy.drawConfig.DER and E.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuGragy.drawConfig.DERC[2], MenuGragy.drawConfig.DERC[3], MenuGragy.drawConfig.DERC[4]))
	end
	if MenuGragy.drawConfig.DRR and R.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuGragy.drawConfig.DRRC[2], MenuGragy.drawConfig.DRRC[3], MenuGragy.drawConfig.DRRC[4]))
	end
end

function KillSteall()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local health = enemy.health
		local QDMG = myHero:CalcDamage(enemy, (40 * myHero:GetSpellData(0).level + 40 + 0.6 * myHero.ap))
		local EDMG = myHero:CalcDamage(enemy, (50 * myHero:GetSpellData(2).level + 30 + 0.6 * myHero.ap))
		local RDMG = myHero:CalcDamage(enemy, (100 * myHero:GetSpellData(3).level + 100 + 0.7 * myHero.ap))
		local IDMG = 50 + (20 * myHero.level)
		if ValidTarget(enemy) and enemy ~= nil and enemy.team ~= player.team and not enemy.dead and enemy.visible then
			IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
			if health < QDMG and MenuGragy.ksConfig.QKS and GetDistance(enemy) < Q.range and Q.Ready() then
				CastQ(enemy)
			elseif health < QDMG and MenuGragy.ksConfig.EKS and GetDistance(enemy) < E.range and E.Ready() then
				CastE(enemy)
			elseif health < RDMG and MenuGragy.ksConfig.RKS and GetDistance(enemy) < R.range and R.Ready() then
				CastR(enemy)	
			elseif health < (QDMG + EDMG) and MenuGragy.ksConfig.QKS and MenuGragy.ksConfig.EKS and GetDistance(enemy) < E.range and Q.Ready() and E.Ready() then
				CastE(enemy)
				CastQ(enemy)
			elseif health < (QDMG + RDMG) and MenuGragy.ksConfig.QKS and MenuGragy.ksConfig.RKS and GetDistance(enemy) < Q.range and Q.Ready() and R.Ready() then
				CastQ(enemy)
				CastR(enemy)
			elseif health < (EDMG + RDMG) and MenuGragy.ksConfig.EKS and MenuGragy.ksConfig.RKS and GetDistance(enemy) < E.range and E.Ready() and R.Ready() then
				CastE(enemy)
				CastR(enemy)
			elseif health < (QDMG + EDMG + RDMG) and MenuGragy.ksConfig.QKS and MenuGragy.ksConfig.EKS and MenuGragy.ksConfig.RKS and GetDistance(enemy) < E.range and Q.Ready() and E.Ready() and R.Ready() then
				CastE(enemy)
				CastQ(enemy)
				CastR(enemy)
			elseif health < IDMG and MenuGragy.ksConfig.IKS and GetDistance(enemy) <= 600 and IReady then
				CastSpell(IgniteKey, enemy)
			end
		end
	end
	for _, enemy in pairs(GetEnemyHeroes()) do
		if MenuGragy.exConfig.AQF then
			if Q.Ready() and ValidTarget(enemy) and GetDistance(enemy) < Q.range then
				local qPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, Q.delay, Q.width, Q.range, Q.speed, myHero)
				if qPos ~= nil and maxHit >= MenuGragy.exConfig.AQX and HitChance >=2 then		
					if VIP_USER and MenuGragy.prConfig.pc then
						Packet("S_CAST", {spellId = _Q, fromX = qPos.x, fromY = qPos.z, toX = qPos.x, toY = qPos.z}):send()
					else
						CastSpell(_Q, qPos.x, qPos.z)
					end
				end
			end
		end
		if MenuGragy.exConfig.ARF then
			if R.Ready() and ValidTarget(enemy) and GetDistance(enemy) < R.range then
				local rPos, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(enemy, R.delay, R.width, R.range, R.speed, myHero)
				if rPos ~= nil and maxHit >= MenuGragy.exConfig.ARX and HitChance >=2 then		
					if VIP_USER and MenuGragy.prConfig.pc then
						Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
					else
						CastSpell(_R, rPos.x, rPos.z)
					end
				end
			end
		end
	end
end

function DmgCalc()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible then
			local QDMG = myHero:CalcDamage(enemy, (40 * myHero:GetSpellData(0).level + 40 + 0.6 * myHero.ap))
			local EDMG = myHero:CalcDamage(enemy, (50 * myHero:GetSpellData(2).level + 30 + 0.6 * myHero.ap))
			local RDMG = myHero:CalcDamage(enemy, (100 * myHero:GetSpellData(3).level + 100 + 0.7 * myHero.ap))
			if enemy.health > (QDMG + EDMG + RDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < EDMG then
				killstring[enemy.networkID] = "E Kill!"
			elseif enemy.health < RDMG then
				killstring[enemy.networkID] = "R Kill!"
			elseif enemy.health < (QDMG + EDMG) then
				killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (QDMG + RDMG) then
				killstring[enemy.networkID] = "Q+R Kill!"
			elseif enemy.health < (EDMG + RDMG) then
				killstring[enemy.networkID] = "E+R Kill!"
			elseif enemy.health < (QDMG + EDMG + RDMG) then
				killstring[enemy.networkID] = "Q+E+R Kill!"
			end
		end
	end
end

function CastQ(unit)
	if myHero:GetSpellData(_Q).name ~= "GragasQToggle" then
	if MenuGragy.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, false)
		if HitChance >= 2 then
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuGragy.prConfig.pro == 2 and VIP_USER and prodstatus then
		local CastPosition, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
		if CastPosition ~= nil then
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuGragy.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local GragQ = CircleSS(Q.speed, Q.range, Q.width, 250, math.huge)
		local State, Position, perc = DP:predict(unit, GragQ)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_Q, Position.x, Position.z)
			end
		end
	end
	end
end

function CastW()
	if VIP_USER and MenuGragy.prConfig.pc then
		Packet("S_CAST", {spellId = _W}):send()
	else
		CastSpell(_W)
	end
end

function CastE(unit)
	if MenuGragy.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, E.delay, E.width, E.range, E.speed, myHero, true)
		if HitChance >= 2 then
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _E, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_E, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuGragy.prConfig.pro == 2 and VIP_USER and prodstatus then
		local CastPosition, info = Prodiction.GetPrediction(unit, E.range, E.speed, E.delay, E.width)
		if CastPosition ~= nil and not info.mCollision() then
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _E, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_E, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuGragy.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local GragE = LineSS(E.speed, E.range, E.width, 250, 0)
		local State, Position, perc = DP:predict(unit, GragE)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_E, Position.x, Position.z)
			end
		end
	end
end

function CastR(unit)
	if MenuGragy.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, R.delay, R.width, R.range, R.speed, myHero, false)
		if HitChance >= 2 then
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuGragy.prConfig.pro == 2 and VIP_USER and prodstatus then
		local CastPosition, info = Prodiction.GetPrediction(unit, R.range, R.speed, R.delay, R.width, myHero)
		if CastPosition ~= nil then
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuGragy.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local GragR = CircleSS(R.speed, R.range, R.width, 500, math.huge)
		local State, Position, perc = DP:predict(unit, GragR)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			if VIP_USER and MenuGragy.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_R, Position.x, Position.z)
			end
		end
	end
end

function CastRBehind(unit)
	if GetDistance(unit) <= R.range - 80 then
		local x,y,z = (Vector(unit) - Vector(myHero)):normalized():unpack()
		posX = unit.x + (x * 300)
		posY = unit.y + (y * 300)
		posZ = unit.z + (z * 300)
		if VIP_USER and MenuGragy.prConfig.pc then
			Packet("S_CAST", {spellId = _R, fromX = posX, fromY = posZ, toX = posX, toY = posZ}):send()
		else
			CastSpell(_R, posX, posZ)
		end	
	end
end

function OnProcessSpell(unit, spell)
	if MenuGragy.iConfig.UI and E.Ready() then
		for _, x in pairs(InterruptList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuGragy.iConfig.ES[x.spellName] and ValidTarget(unit, E.range) then
					CastE(unit)
				end
			end
		end
	end
end

function OnCreateObj(obj)
	if obj.name:find("Gragas") and obj.name:find("Q_Mis") then 
		barrelmis = obj 
	end
	if obj.name:find("Gragas") and obj.name:find("Q_Ally") then
		barrel = obj
	end
end

function OnDeleteObj(obj)
	if obj.name:find("Gragas") and obj.name:find("Q_End") then
		barrel = nil
		barrelmis = nil
	end
end

function EnemyCount(point, range)
	local count = 0
	for _, enemy in pairs(GetEnemyHeroes()) do
		if enemy and not enemy.dead and GetDistance(point, enemy) <= range then
			count = count + 1
		end
	end            
	return count
end

function OnApplyBuff(unit, source, buff)
	if unit.isMe and buff and buff.name == "Recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit.isMe and buff and buff.name == "Recall" then
		recall = false
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuGragy.comboConfig.ST then
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
				if MenuGragy.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuGragy.comboConfig.ST then 
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("UHKIIOHKGOL") 
