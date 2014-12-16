--[[

	Script Name: Blitzcrank MASTER 
    	Author: kokosik1221
	Last Version: 0.66
	16.12.2014
	
]]--


if myHero.charName ~= "Blitzcrank" then return end

_G.AUTOUPDATE = true
_G.USESKINHACK = false


local version = 0.66
local SCRIPT_NAME = "BlitzcrankMaster"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local prodstatus = false
local colstatus = false
if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() PrintChat("Required libraries downloaded successfully, please reload") end)
end
if DOWNLOADING_SOURCELIB then PrintChat("Downloading required libraries, please wait...") return end
if _G.AUTOUPDATE then
	 SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/kokosik1221/bol/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/kokosik1221/bol/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end
local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
if VIP_USER then
	RequireI:Add("Prodiction", "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua")
	RequireI:Add("Collision", "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/b891699e739f77f77fd428e74dec00b2a692fdef/Common/Collision.lua")
	prodstatus = true
	colstatus = true
end
RequireI:Check()
if RequireI.downloadNeeded == true then return end


local Counterspells = {
	['KatarinaR'] = {charName = "Katarina", spellSlot = "R"},
	['GalioIdolOfDurand'] = {charName = "Galio", spellSlot = "R"},
	['Crowstorm'] = {charName = "FiddleSticks", spellSlot = "R"},
	['Drain'] = {charName = "FiddleSticks", spellSlot = "W"},
	['AbsoluteZero'] = {charName = "Nunu", spellSlot = "R"},
	['ShenStandUnited'] = {charName = "Shen", spellSlot = "R"},
	['UrgotSwap2'] = {charName = "Urgot", spellSlot = "R"},
	['AlZaharNetherGrasp'] = {charName = "Malzahar", spellSlot = "R"},
	['FallenOne'] = {charName = "Karthus", spellSlot = "R"},
	['Pantheon_GrandSkyfall_Jump'] = {charName = "Pantheon", spellSlot = "R"},
	['CaitlynAceintheHole'] = {charName = "Caitlyn", spellSlot = "R"},
	['MissFortuneBulletTime'] = {charName = "MissFortune", spellSlot = "R"},
	['InfiniteDuress'] = {charName = "Warwick", spellSlot = "R"},
	['Meditate'] = {},
	['Teleport'] = {},
}

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

function Vars()
	Q = {name = "Rocket Grab", range = 900, speed = 1800, delay = 0.25, width = 60}
	W = {name = "Overdrive"}
	E = {name = "Power Fist", range = 140}
	R = {name = "Static Field", range = 600}
	QReady, WReady, EReady, RReady, IReady, zhonyaready, sac, mma = false, false, false, false, false, false, false, false
	abilitylvl, lastskin = 0, 0
	EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	IgniteKey, SmiteKey, zhonyaslot = nil, nil, nil
	killstring = {}
	Spells = {_Q,_W,_E,_R}
	Spells2 = {"Q","W","E","R"}
	print("<b><font color=\"#6699FF\">Blitzcrank Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if VIP_USER and prodstatus and colstatus then
		Prodict = ProdictManager.GetInstance()
		ProdictQ = Prodict:AddProdictionObject(_Q, Q.range, Q.speed, Q.delay, Q.width, myHero)
        ProdictQCol = Collision(Q.range, Q.speed, Q.delay, Q.width)
	end
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Blitzcrank Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
		mma = true
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Blitzcrank Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
		sac = true
	end
end

function OnLoad()
	Vars()
	Menu()
	PriorityOnLoad()
end

function PriorityOnLoad()
	if heroManager.iCount < 10 then
		print("<font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function OnTick()
	Check()
	if MenuBlitz.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuBlitz.comboConfig.manac then
		Combo()
	end
	if (MenuBlitz.harrasConfig.HEnabled or MenuBlitz.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuBlitz.harrasConfig.manah then
		Harrass()
	end
	if MenuBlitz.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuBlitz.farm.manaf then
		Farm()
	end
	if MenuBlitz.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuBlitz.jf.manajf then
		JungleFarmm()
	end
	if MenuBlitz.prConfig.AZ then
		autozh()
	end
	if MenuBlitz.prConfig.ALS then
		autolvl()
	end
	KillSteall()
end


function Menu()
	VP = VPrediction()
	SOWi = SOW(VP)
	MenuBlitz = scriptConfig("Blitzcrank Master "..version, "Blitzcrank Master "..version)
	MenuBlitz:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuBlitz.Orbwalking)
	MenuBlitz:addSubMenu("Target selector", "STS")
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Blitzcrank"
	MenuBlitz.STS:addTS(TargetSelector)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Combo Settings", "comboConfig")
	MenuBlitz.comboConfig:addParam("USEQ", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("USEQS", "Use Smite If See Collision", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.comboConfig:addParam("USEW", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.comboConfig:addParam("USEE", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.comboConfig:addParam("USER", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("Kilable", "Only Use If Target Is Killable", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuBlitz.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Harras Settings", "harrasConfig")
	MenuBlitz.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 1, {"|Q|", "|E|", "|Q|E|"}) 
	MenuBlitz.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuBlitz.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuBlitz.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 50, 0, 100, 0) 
	MenuBlitz.harrasConfig:addParam("MM", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: KS Settings", "ksConfig")
	MenuBlitz.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ksConfig:addParam("RKS", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: LaneClear Settings", "farm")
	MenuBlitz.farm:addParam("QF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.farm:addParam("EF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.farm:addParam("LaneClear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuBlitz.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0) 
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Jungle Farm Settings", "jf")
	MenuBlitz.jf:addParam("QJF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.jf:addParam("EJF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuBlitz.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0) 
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Draw Settings", "drawConfig")
	MenuBlitz.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.drawConfig:addParam("DQL", "Draw Q Collision Line", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuBlitz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Extra Settings", "exConfig")
	Enemies = GetEnemyHeroes() 
	MenuBlitz.exConfig:addSubMenu("Auto-Interrupt Spells", "ES")
    for i,enemy in pairs (Enemies) do
		for j,spell in pairs (Spells) do 
			if Counterspells[enemy:GetSpellData(spell).name] then 
				MenuBlitz.exConfig.ES:addParam(tostring(enemy:GetSpellData(spell).name),"Interrupt "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
			end 
		end 
	end 
	MenuBlitz.exConfig:addParam("UI", "Use Auto-Interrupt", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Black List", "blConfig")
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team ~= myHero.team then
			MenuBlitz.blConfig:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, false)
		end
	end
	MenuBlitz.blConfig:addParam("UBL", "Use Black List Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Misc Settings", "prConfig")
	MenuBlitz.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 1, 1, 8)
	MenuBlitz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuBlitz.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuBlitz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuBlitz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuBlitz.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	MenuBlitz.comboConfig:permaShow("CEnabled")
	MenuBlitz.harrasConfig:permaShow("HEnabled")
	MenuBlitz.harrasConfig:permaShow("HTEnabled")
	MenuBlitz.prConfig:permaShow("AZ")
	MenuBlitz.blConfig:permaShow("UBL")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	if myHero:GetSpellData(SUMMONER_1).name:find("summonersmite") then SmiteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonersmite") then SmiteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	TargetTable = {
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
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if sac or mma then
		SOWi.Menu.Enabled = false
	end
	SOWi:ForceTarget(Cel)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	SReady = (SmiteKey ~= nil and myHero:CanUseSpell(SmiteKey) == READY)
	if MenuBlitz.prConfig.skin and VIP_USER and _G.USESKINHACK then
		if MenuBlitz.prConfig.skin1 ~= lastSkin then
			GenModelPacket("Blitzcrank", MenuBlitz.prConfig.skin1)
			lastSkin = MenuBlitz.prConfig.skin1
		end
	end
	if MenuBlitz.drawConfig.DLC then 
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

function FindBL()
	for i = 1, heroManager.iCount do
		hero = heroManager:GetHero(i)
		if MenuBlitz.blConfig.UBL and hero.team ~= myHero.team and not hero.dead and MenuBlitz.blConfig[hero.charName] then
			return hero
		end
	end
end

function Combo()
	blacktarget = FindBL()
	if Cel ~= nil and ValidTarget(Cel) and Cel ~= blacktarget then
		UseItems(Cel)
		if MenuBlitz.comboConfig.USEQ then
			CastQ(Cel)
		end
		if MenuBlitz.comboConfig.USEW then
			CastW()
		end
		if MenuBlitz.comboConfig.USEE then
			CastE(Cel)
		end
		if MenuBlitz.comboConfig.USER then
			if MenuBlitz.comboConfig.Kilable then
				local r = getDmg("R", Cel, myHero) + ((myHero.ap*90)/100)
				if Cel.health < r then
					CastR(Cel)
				end
			elseif not MenuBlitz.comboConfig.Kilable then
				CastR(Cel)
			end
		end
	end
end

function Harrass()
	blacktarget = FindBL()
	if Cel ~= nil and ValidTarget(Cel) and Cel ~= blacktarget then
		if MenuBlitz.harrasConfig.HM == 1 then
			CastQ(Cel)
		end
		if MenuBlitz.harrasConfig.HM == 2 then
			CastE(Cel)
		end
		if MenuBlitz.harrasConfig.HM == 3 then
			CastQ(Cel)
			CastE(Cel)
		end
	end
	if MenuBlitz.harrasConfig.MM then
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function Farm()
	EnemyMinions:update()
	for i, minion in pairs(EnemyMinions.objects) do
		if MenuBlitz.farm.QF then
			if minion ~= nil and not minion.dead then
				CastQ(minion)
			end
		end
		if MenuBlitz.farm.EF then
			if minion ~= nil and not minion.dead then
				CastE(minion)
			end
		end
	end
end

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuBlitz.jf.QJF then
			if minion ~= nil and not minion.dead then
				CastQ(minion)
			end
		end
		if MenuBlitz.jf.EJF then
			if minion ~= nil and not minion.dead then
				CastE(minion)
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuBlitz.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuBlitz.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuBlitz.prConfig.ALS then return end
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuBlitz.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuBlitz.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuBlitz.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuBlitz.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuBlitz.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuBlitz.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end

function OnDraw()
	if MenuBlitz.drawConfig.DST and MenuBlitz.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuBlitz.drawConfig.DQRC[2], MenuBlitz.drawConfig.DQRC[3], MenuBlitz.drawConfig.DQRC[4]))
		end
	end
	if MenuBlitz.drawConfig.DQL and ValidTarget(Cel, Q.range) and VIP_USER then
		ProdictQCol:DrawCollision(myHero, Cel)
	end
	if MenuBlitz.drawConfig.DD then	
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuBlitz.drawConfig.DQR and QReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuBlitz.drawConfig.DQRC[2], MenuBlitz.drawConfig.DQRC[3], MenuBlitz.drawConfig.DQRC[4]))
	end
	if MenuBlitz.drawConfig.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuBlitz.drawConfig.DRRC[2], MenuBlitz.drawConfig.DRRC[3], MenuBlitz.drawConfig.DRRC[4]))
	end
end

function KillSteall()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero, 1)
		local eDmg = getDmg("E", Enemy, myHero, 1)
		local rDmg = getDmg("R", Enemy, myHero, 3)
		local iDmg = (50 + (20 * myHero.level))
		if ValidTarget(Enemy, Q.range) and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health < qDmg and MenuBlitz.ksConfig.QKS and GetDistance(Enemy) < Q.range then
				CastQ(Enemy)
			elseif health < eDmg and MenuBlitz.ksConfig.EKS and GetDistance(Enemy) < E.range then
				CastE(Enemy)
			elseif health < rDmg and MenuBlitz.ksConfig.RKS and GetDistance(Enemy) < R.range then
				CastR(Enemy)
			elseif health < iDmg and MenuBlitz.ksConfig.IKS and IReady and GetDistance(Enemy) <= 600 then
				CastSpell(IgniteKey, Enemy)
			elseif health < (qDmg + eDmg) and MenuBlitz.ksConfig.QKS and MenuBlitz.ksConfig.EKS and GetDistance(Enemy) < Q.range then
				CastQ(Enemy)
				CastE(Enemy)
			elseif health < (qDmg + rDmg) and MenuBlitz.ksConfig.QKS and MenuBlitz.ksConfig.RKS and GetDistance(Enemy) < Q.range then
				CastQ(Enemy)
				CastR(Enemy)				
			elseif health < (eDmg + rDmg) and MenuBlitz.ksConfig.EKS and MenuBlitz.ksConfig.RKS and GetDistance(Enemy) < E.range then
				CastE(Enemy)
				CastR(Enemy)	
			elseif health < (qDmg + eDmg + rDmg) and MenuBlitz.ksConfig.QKS and MenuBlitz.ksConfig.EKS and MenuBlitz.ksConfig.RKS and GetDistance(Enemy) < Q.range then
				CastQ(Enemy)
				CastE(Enemy)
				CastR(Enemy)	
			end
		end
	end
end

function DmgCalc()
	for _, enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
			local qDmg = getDmg("Q", enemy, myHero, 1)
			local eDmg = getDmg("E", enemy, myHero, 1)
			local rDmg = getDmg("R", enemy, myHero, 3)
			local iDmg = (50 + (20 * myHero.level))
            if enemy.health > (qDmg + eDmg + rDmg) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < qDmg then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < eDmg then
				killstring[enemy.networkID] = "E Kill!"
			elseif enemy.health < rDmg then
				killstring[enemy.networkID] = "R Kill!"
            elseif enemy.health < (qDmg + eDmg) then
                killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (qDmg + rDmg) then
                killstring[enemy.networkID] = "Q+R Kill!"	
			elseif enemy.health < (rDmg + eDmg) then
                killstring[enemy.networkID] = "R+E Kill!"	
			elseif enemy.health < (qDmg + eDmg + rDmg) then
                killstring[enemy.networkID] = "Q+E+R Kill!"	
            end
        end
    end
end

function CastQ(unit)
	if QReady and GetDistance(unit) - getHitBoxRadius(unit)/2 < Q.range then
		if MenuBlitz.prConfig.pro == 1 then
			if MenuBlitz.comboConfig.USEQS then
				local willCollide1, ColTable2 = GetMinionCollisionM(unit, myHero)
				if #ColTable2 == 1 and SReady and GetDistance(myHero, ColTable2[1]) < 800 then
					CastSpell(SmiteKey, ColTable2[1])
				end
			end
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, true)
			if HitChance >= MenuBlitz.prConfig.vphit - 1 then
				if VIP_USER and MenuBlitz.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MenuBlitz.prConfig.pro == 2 and VIP_USER and prodstatus then
			if MenuBlitz.comboConfig.USEQS then
				local Position = ProdictQ:GetPrediction(unit)
				local willCollide, ColTable = ProdictQCol:GetMinionCollision(Position, myHero)
				if #ColTable == 1 and SReady and GetDistance(myHero, ColTable[1]) < 800 then
					CastSpell(SmiteKey, ColTable[1])
				end
			end
			if Position ~= nil and not willCollide then
				if VIP_USER and MenuBlitz.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end	
			end
		end
	end
end

function CastW()
	if WReady then
		if VIP_USER and MenuBlitz.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end	
	end
end

function CastE(unit)
	if EReady and GetDistance(unit) < E.range then
		if VIP_USER and MenuBlitz.prConfig.pc then
			Packet("S_CAST", {spellId = _E}):send()
			myHero:Attack(unit)
		else
			CastSpell(_E)
			myHero:Attack(unit)
		end	
	end
end

function CastR(unit)
	if RReady and GetDistance(unit) - getHitBoxRadius(unit)/2 < R.range then
		if VIP_USER and MenuBlitz.prConfig.pc then
			Packet("S_CAST", {spellId = _R}):send()
		else
			CastSpell(_R)
		end	
	end
end

function OnProcessSpell(object, spell)
	if MenuBlitz.exConfig.UI then
		if object and object.team ~= myHero.team and object.type == myHero.type and spell then
			if Counterspells[spell.name] or spell.name == "Meditate" or spell.name == "Teleport" then 
				CastR(object)
			end
		end
	end
end

function GenModelPacket(champ, skinId)
	p = CLoLPacket(0x97)
	p:EncodeF(myHero.networkID)
	p.pos = 1
	t1 = p:Decode1()
	t2 = p:Decode1()
	t3 = p:Decode1()
	t4 = p:Decode1()
	p:Encode1(t1)
	p:Encode1(t2)
	p:Encode1(t3)
	p:Encode1(bit32.band(t4,0xB))
	p:Encode1(1)--hardcode 1 bitfield
	p:Encode4(skinId)
	for i = 1, #champ do
		p:Encode1(string.byte(champ:sub(i,i)))
	end
	for i = #champ + 1, 64 do
		p:Encode1(0)
	end
	p:Hide()
	RecvPacket(p)
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuBlitz.comboConfig.ST then
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
				if MenuBlitz.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuBlitz.comboConfig.ST then 
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


-- FROM Collision 1.1.1 by Klokje Mod by Boboben1 --
function GetMinionCollisionM(pStart, pEnd)
    EnemyMinions:update()
    local distance =  GetDistance(pStart, pEnd)
    local prediction = TargetPrediction(Q.range, Q.speed/1000, Q.delay*1000, Q.width)
    local mCollision = {}
    if distance > Q.range then
        distance = Q.range
    end
    local V = Vector(pEnd) - Vector(pStart)
    local k = V:normalized()
    local P = V:perpendicular2():normalized()
    local t,i,u = k:unpack()
    local x,y,z = P:unpack()
    local startLeftX = pStart.x + (x *Q.width)
    local startLeftY = pStart.y + (y *Q.width)
    local startLeftZ = pStart.z + (z *Q.width)
    local endLeftX = pStart.x + (x * Q.width) + (t * distance)
    local endLeftY = pStart.y + (y * Q.width) + (i * distance)
    local endLeftZ = pStart.z + (z * Q.width) + (u * distance)
    local startRightX = pStart.x - (x * Q.width)
    local startRightY = pStart.y - (y * Q.width)
    local startRightZ = pStart.z - (z * Q.width)
    local endRightX = pStart.x - (x * Q.width) + (t * distance)
    local endRightY = pStart.y - (y * Q.width) + (i * distance)
    local endRightZ = pStart.z - (z * Q.width)+ (u * distance)
    local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
    local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
    local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
    local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
    local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
    for index, minion in pairs(EnemyMinions.objects) do
        if minion ~= nil and minion.valid and not minion.dead then
            if GetDistance(pStart, minion) < distance then
                local pos, t, vec = prediction:GetPrediction(minion)
                local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                local toScreen, toPoint
                if pos ~= nil then
                    toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                else
                    toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                end
                if poly:contains(toPoint) then
                    table.insert(mCollision, minion)
                else
                    if pos ~= nil then
                        distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                        distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                    else
                        distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                        distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                    end
                    if (distance1 < (getHitBoxRadius2(minion)*2+10) or distance2 < (getHitBoxRadius2(minion) *2+10)) then
                        table.insert(mCollision, minion)
                    end
                end
            end
        end
    end
    if #mCollision > 0 then return true, mCollision else return false, mCollision end
end

function getHitBoxRadius2(target)
    return GetDistance(target, target.minBBox)/2
end
