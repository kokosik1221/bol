--[[

	Script Name: Poppy MASTER 
    	Author: kokosik1221
	Last Version: 0.2
	08.01.2015
	
]]--


if myHero.charName ~= "Poppy" then return end

_G.AUTOUPDATE = true
_G.USESKINHACK = false

local version = "0.2"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/PoppyMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>PoppyMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/PoppyMaster.version")
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
	["vPrediction"] = "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua",
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
	BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
	RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
	STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
	TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
	YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
	RND = { id = 3143, range = 275, reqTarget = false, slot = nil },
}

function OnLoad()
	print("<b><font color=\"#FF0000\">Poppy Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	Vars()
	Menu()
end

function Vars()
	Q = {name = "Devastating Blow", range = 230}
	W = {name = "Paragon of Demacia", range = 525}
	E = {name = "Heroic Charge", range = 525, range2 = 325}
	R = {name = "Diplomatic Immunity", range = 900}
	QReady, WReady, EReady, RReady, IReady, zhonyaready, recall, sac, mma = false, false, false, false, false, false, false, false
	abilitylvl, lastskin = 0, 0
	EnemyMinions = minionManager(MINION_ENEMY, E.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, E.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	IgniteKey, zhonyaslot = nil, nil
	killstring = {}
	TargetTable = {
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
end

function Menu()
	VP = VPrediction()
	MenuPoppy = scriptConfig("Poppy Master "..version, "Poppy Master "..version)
	MenuPoppy:addSubMenu("Orbwalking", "Orbwalking")
	SxOrb:LoadToMenu(MenuPoppy.Orbwalking)
	MenuPoppy:addSubMenu("Target selector", "STS")
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_MAGIC)
	TargetSelector.name = "Poppy"
	MenuPoppy.STS:addTS(TargetSelector)
	MenuPoppy:addSubMenu("[Poppy Master]: Combo Settings", "comboConfig")
	MenuPoppy.comboConfig:addSubMenu("[Poppy Master]: Q Settings", "qConfig")
	MenuPoppy.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.comboConfig:addSubMenu("[Poppy Master]: W Settings", "wConfig")
	MenuPoppy.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.comboConfig:addSubMenu("[Poppy Master]: E Settings", "eConfig")
	MenuPoppy.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.comboConfig.eConfig:addParam("USEE2", "Use Only If Can Stun", SCRIPT_PARAM_ONOFF, false)
	MenuPoppy.comboConfig:addSubMenu("[Poppy Master]: R Settings", "rConfig")
	MenuPoppy.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.comboConfig.rConfig:addParam("RM", "R Cast Mode:", SCRIPT_PARAM_LIST, 5, {"Normal", "If My HP% <", "Weakest Enemy", "X Enemy Around Me", "Weakest Enemy + HP% <", "HP% < + X Enemy"})
	MenuPoppy.comboConfig.rConfig:addParam("HP", "My HP % < ", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
	MenuPoppy.comboConfig.rConfig:addParam("X", "X Enemy = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MenuPoppy.comboConfig.rConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.comboConfig.rConfig:addParam("qqq", "Use Ultimate On: ", SCRIPT_PARAM_INFO,"")
	for _,hero in pairs(GetEnemyHeroes()) do
		if hero.team ~= myHero.team then
			MenuPoppy.comboConfig.rConfig:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuPoppy.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuPoppy.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuPoppy.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuPoppy:addSubMenu("[Poppy Master]: Harras Settings", "harrasConfig")
    MenuPoppy.harrasConfig:addParam("USEQ", "Harras Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.harrasConfig:addParam("USEE", "Harras Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuPoppy.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuPoppy.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuPoppy:addSubMenu("[Poppy Master]: Extra Settings", "exConfig")
	MenuPoppy.exConfig:addSubMenu("[Poppy Master]: Auto Stun Enemy List", "EL")
	for _,hero in pairs(GetEnemyHeroes()) do
		if hero.team ~= myHero.team then
			MenuPoppy.exConfig.EL:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuPoppy.exConfig:addParam("AS", "Auto Stun Enemy (E)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.exConfig:addSubMenu("[Poppy Master]: Auto-Interrupt Spells", "ES")
	for i, enemy in ipairs(GetEnemyHeroes()) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				MenuPoppy.exConfig.ES:addParam(champ.spellName, "Stop "..champ.charName.." "..champ.spellName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end
	MenuPoppy.exConfig:addParam("UI", "Use Auto-Interrupt (E)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy:addSubMenu("[Poppy Master]: KS Settings", "ksConfig")
	MenuPoppy.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy:addSubMenu("[Poppy Master]: Farm Settings", "farm")
	MenuPoppy.farm:addParam("QF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuPoppy.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.farm:addParam("EF",  "Use " .. E.name .. "(E)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuPoppy.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuPoppy.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuPoppy:addSubMenu("[Poppy Master]: Jungle Farm Settings", "jf")
	MenuPoppy.jf:addParam("QJF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.jf:addParam("EJF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuPoppy.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuPoppy:addSubMenu("[Poppy Master]: Draw Settings", "drawConfig")
	MenuPoppy.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuPoppy.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuPoppy:addSubMenu("[Poppy Master]: Misc Settings", "prConfig")
	MenuPoppy.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuPoppy.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuPoppy.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuPoppy.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuPoppy.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuPoppy.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuPoppy.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
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
	SxOrb:RegisterAfterAttackCallback(function(t) aa() end)
end

function aa()
	if MenuPoppy.comboConfig.CEnabled and MenuPoppy.comboConfig.qConfig.USEQ then
		CastQ()
	end
	if (MenuPoppy.harrasConfig.HEnabled or MenuPoppy.harrasConfig.HTEnabled) and MenuPoppy.harrasConfig.USEQ then
		CastQ()
	end
	if MenuPoppy.jf.JFEnabled and MenuPoppy.jf.QJF then
		CastQ()
	end
end

function OnTick()
	Check()
	if Cel ~= nil and MenuPoppy.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuPoppy.comboConfig.manac then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuPoppy.harrasConfig.HEnabled or MenuPoppy.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuPoppy.harrasConfig.manah then
		Harrass()
	end
	if MenuPoppy.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuPoppy.farm.manaf then
		Farm()
	end
	if MenuPoppy.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuPoppy.jf.manajf then
		JungleFarm()
	end
	if MenuPoppy.exConfig.AS then
		AutoE()
	end
	KillSteal()
end

function caa()
	if MenuPoppy.comboConfig.uaa then
		SxOrb:EnableAttacks()
	elseif not MenuPoppy.comboConfig.uaa then
		SxOrb:DisableAttacks()
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
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, E.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if sac or mma then
		SxOrb.SxOrbMenu.General.Enabled = false
	end
	SxOrb:ForceTarget(Cel)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if MenuPoppy.prConfig.skin and VIP_USER and _G.USESKINHACK then
		if MenuPoppy.prConfig.skin1 ~= lastSkin then
			GenModelPacket("Poppy", MenuPoppy.prConfig.skin1)
			lastSkin = MenuPoppy.prConfig.skin1
		end
	end
	if MenuPoppy.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
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
	if (sac or mma) and MenuPoppy.comboConfig.qConfig.USEQ and ValidTarget(Cel, Q.range)then
		CastQ()
	end
	if MenuPoppy.comboConfig.wConfig.USEW and ValidTarget(Cel, W.range) then
		CastW()
	end
	if MenuPoppy.comboConfig.eConfig.USEE and ValidTarget(Cel, E.range) and not MenuPoppy.comboConfig.eConfig.USEE2 then
		CastE(Cel)
	end
	if MenuPoppy.comboConfig.eConfig.USEE and ValidTarget(Cel, E.range) and MenuPoppy.comboConfig.eConfig.USEE2 then
		CheckWallStun(Cel)
	end
	if MenuPoppy.comboConfig.rConfig.USER then
		CastR()
	end
end

function Harrass()
	if MenuPoppy.harrasConfig.USEE and ValidTarget(Cel, E.range) then
		CastE(Cel)
	end
	if (sac or mma) and MenuPoppy.harrasConfig.USEQ and ValidTarget(Cel, Q.range)then
		CastQ()
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuPoppy.farm.QF
	EMode =  MenuPoppy.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastQ()
			end
		elseif QMode == 2 then
			if minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					CastQ()
					myHero:Attack(minion)
				end
			end
		end
		if EMode == 3 then
			if minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				CastE(minion)
			end
		elseif EMode == 2 then
			if minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				if minion.health <= getDmg("E", minion, myHero) then
					CastE(minion)
				end
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuPoppy.jf.EJF then
			if minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastE(minion)
			end
		end
		if MenuPoppy.jf.QJF and (sac or mma) then
			if minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastQ()
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuPoppy.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuPoppy.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuPoppy.prConfig.ALS then return end
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuPoppy.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuPoppy.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuPoppy.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuPoppy.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuPoppy.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuPoppy.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end

function OnDraw()
	if MenuPoppy.drawConfig.DST and MenuPoppy.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuPoppy.drawConfig.DQRC[2], MenuPoppy.drawConfig.DQRC[3], MenuPoppy.drawConfig.DQRC[4]))
		end
	end
	if MenuPoppy.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuPoppy.drawConfig.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuPoppy.drawConfig.DERC[2], MenuPoppy.drawConfig.DERC[3], MenuPoppy.drawConfig.DERC[4]))
	end
	if MenuPoppy.drawConfig.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuPoppy.drawConfig.DRRC[2], MenuPoppy.drawConfig.DRRC[3], MenuPoppy.drawConfig.DRRC[4]))
	end
end

function CalcItems(unit)
	tiamatslot = GetInventorySlotItem(3077)
	hydraslot = GetInventorySlotItem(3074)
	brkslot = GetInventorySlotItem(3153)
	bwcslot = GetInventorySlotItem(3144)
	dfgslot = GetInventorySlotItem(3128)
	hgbslot = GetInventorySlotItem(3146)
	bftslot = GetInventorySlotItem(3188)
	tiamatready = (tiamatslot ~= nil and myHero:CanUseSpell(tiamatslot) == READY)
	hydraready = (hydraslot ~= nil and myHero:CanUseSpell(hydraslot) == READY)
	brkready = (brkslot ~= nil and myHero:CanUseSpell(brkslot) == READY)
	bwcready = (bwcslot ~= nil and myHero:CanUseSpell(bwcslot) == READY)
	dfgready = (dfgslot ~= nil and myHero:CanUseSpell(dfgslot) == READY)
	hgbready = (hgbslot ~= nil and myHero:CanUseSpell(hgbslot) == READY)
	bftready = (bftslot ~= nil and myHero:CanUseSpell(bftslot) == READY)
	tmt = ((tiamatready and getDmg("TIAMAT", unit, myHero)) or 0)
	hyd = ((hydraready and getDmg("HYDRA", unit, myHero)) or 0)
	bwc = ((bwcready and getDmg("BWC", unit, myHero)) or 0)
	brk = ((brkready and getDmg("RUINEDKING", unit, myHero)) or 0)
	dfg = ((dfgready and getDmg("DFG", unit, myHero)) or 0)
	hgb = ((hgbready and getDmg("HXG", unit, myHero)) or 0)
	bft = ((bftready and getDmg("BLACKFIRE", unit, myHero)) or 0)
	ritems = tmt + hyd + bwc + brk + dfg + hgb + bft
end

function DmgCalc()
	for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
			local QDMG = getDmg("Q", enemy, myHero, 1)
			local EDMG = getDmg("R", enemy, myHero, 1)
			local IDMG = (50 + (20 * myHero.level))
			CalcItems(enemy)
			local ITEMS = ritems
			if enemy.health > (QDMG + EDMG + IDMG + ITEMS) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < ITEMS then
				killstring[enemy.networkID] = "Items Kill!"	
			elseif enemy.health < IDMG then
				killstring[enemy.networkID] = "Ignite Kill!"	
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < (QDMG + ITEMS) then
				killstring[enemy.networkID] = "Q+Items Kill!"	
			elseif enemy.health < (QDMG + IDMG) then
				killstring[enemy.networkID] = "Q+Ignite Kill!"
			elseif enemy.health < EDMG then
				killstring[enemy.networkID] = "E Kill!"
			elseif enemy.health < (EDMG + ITEMS) then
				killstring[enemy.networkID] = "E+Items Kill!"	
			elseif enemy.health < (EDMG + IDMG) then
				killstring[enemy.networkID] = "E+Ignite Kill!"
			elseif enemy.health < (QDMG + EDMG) then
				killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (QDMG + EDMG + ITEMS) then
				killstring[enemy.networkID] = "Q+E+Items Kill!"	
			elseif enemy.health < (QDMG + EDMG + IDMG) then
				killstring[enemy.networkID] = "Q+E+Ignite Kill!"
			end
		end
	end
end

function KillSteal()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero, 3)
		local eDmg = getDmg("E", Enemy, myHero, 3)
		local iDmg = getDmg("IGNITE", Enemy, myHero) 
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health < qDmg and MenuPoppy.ksConfig.QKS and ValidTarget(Enemy, Q.range) and QReady then
				CastQ()
				myHero:Attack(Enemy)
			elseif health < eDmg and MenuPoppy.ksConfig.EKS and ValidTarget(Enemy, E.range) and EReady then
				CastE(Enemy)
			elseif IReady and health <= iDmg and MenuPoppy.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end

function AutoE()
	for _,enemy in pairs(GetEnemyHeroes()) do
		if enemy ~= nil and not enemy.dead and ValidTarget(enemy, E.range) then
			if MenuPoppy.exConfig.EL[enemy.charName] then
				CheckWallStun(enemy)
			end
		end
	end
end

function CheckWallStun(Target)
	CastPosition, HitChance, PredictPosition = VP:GetPredictedPos(Target, 0.3, 1000, myHero, false)
	if HitChance > 1 then
		for i = 1, E.range2, 60  do
			local CheckWallPos = Vector(PredictPosition) + (Vector(PredictPosition) - myHero):normalized()*(i)
			if IsWall(D3DXVECTOR3(CheckWallPos.x, CheckWallPos.y, CheckWallPos.z)) then
				CastSpell(_E, Target)
				break
			end
		end
	end
end

function OnProcessSpell(unit, spell)
	if MenuPoppy.exConfig.UI and EReady then
		for _, x in pairs(InterruptList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuPoppy.exConfig.ES[x.spellName] and ValidTarget(unit, E.range) then
					CastE(unit)
				end
			end
		end
	end
end

function CastQ()
	if QReady then
		if VIP_USER and MenuPoppy.prConfig.pc then
			Packet("S_CAST", {spellId = _Q}):send()
		else
			CastSpell(_Q)
		end
	end
end

function CastW()
	if WReady then
		if VIP_USER and MenuPoppy.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if EReady then
		if VIP_USER and MenuPoppy.prConfig.pc then
			Packet("S_CAST", {spellId = _E, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_E, unit)
		end	
	end
end

function CastR()
	for _,enemy in pairs(GetEnemyHeroes()) do
		if enemy ~= nil and not enemy.dead and ValidTarget(enemy, R.range) and MenuPoppy.comboConfig.rConfig[enemy.charName] then	
			if MenuPoppy.comboConfig.rConfig.RM == 1 then
				if VIP_USER and MenuPoppy.prConfig.pc then
					Packet("S_CAST", {spellId = _R, targetNetworkId = enemy.networkID}):send()
				else
					CastSpell(_R, enemy)
				end	
			elseif MenuPoppy.comboConfig.rConfig.RM == 2 and (myHero.health/myHero.maxHealth)*100 <= MenuPoppy.comboConfig.rConfig.HP then
				if VIP_USER and MenuPoppy.prConfig.pc then
					Packet("S_CAST", {spellId = _R, targetNetworkId = enemy.networkID}):send()
				else
					CastSpell(_R, enemy)
				end	
			elseif MenuPoppy.comboConfig.rConfig.RM == 3 then
				x = FindRCel()
				if x ~= nil then
					if VIP_USER and MenuPoppy.prConfig.pc then
						Packet("S_CAST", {spellId = _R, targetNetworkId = x.networkID}):send()
					else
						CastSpell(_R, x)
					end	
				end
			elseif MenuPoppy.comboConfig.rConfig.RM == 3 and EnemyCount(myHero, R.range) >= MenuPoppy.comboConfig.rConfig.X then
				if VIP_USER and MenuPoppy.prConfig.pc then
					Packet("S_CAST", {spellId = _R, targetNetworkId = enemy.networkID}):send()
				else
					CastSpell(_R, enemy)
				end	
			elseif MenuPoppy.comboConfig.rConfig.RM == 5 then
				x = FindRCel()
				if x ~= nil and (myHero.health/myHero.maxHealth)*100 <= MenuPoppy.comboConfig.rConfig.HP then
					if VIP_USER and MenuPoppy.prConfig.pc then
						Packet("S_CAST", {spellId = _R, targetNetworkId = x.networkID}):send()
					else
						CastSpell(_R, x)
					end	
				end
			elseif MenuPoppy.comboConfig.rConfig.RM == 6 then
				if EnemyCount(myHero, R.range) >= MenuPoppy.comboConfig.rConfig.X and (myHero.health/myHero.maxHealth)*100 <= MenuPoppy.comboConfig.rConfig.HP then
					if VIP_USER and MenuPoppy.prConfig.pc then
						Packet("S_CAST", {spellId = _R, targetNetworkId = x.networkID}):send()
					else
						CastSpell(_R, x)
					end	
				end
			end
		end
	end
end

function FindRCel()
    WeakestEnemy = nil
	for _,enemyhero in pairs(GetEnemyHeroes()) do
		if enemyhero ~= nil and enemyhero.team ~= myHero.team and not enemyhero.invulnerable and GetDistance(enemyhero) <= R.range then
			if WeakestEnemy == nil then
				WeakestEnemy = enemyhero
			elseif ((WeakestEnemy.addDamage+WeakestEnemy.ap)>(enemyhero.addDamage+enemyhero.ap)) then
				WeakestEnemy = enemyhero
			end                            
		end
	end
	return WeakestEnemy
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuPoppy.comboConfig.ST then
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
				if MenuPoppy.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuPoppy.comboConfig.ST then 
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
