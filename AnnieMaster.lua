--[[

	Script Name: ANNIE MASTER 
    	Author: kokosik1221
	Last Version: 0.3
	29.11.2014
	
]]--


if myHero.charName ~= "Annie" then return end

local AUTOUPDATE = true


local version = 0.3
local SCRIPT_NAME = "AnnieMaster"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local prodstatus = false
if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() PrintChat("Required libraries downloaded successfully, please reload") end)
end
if DOWNLOADING_SOURCELIB then PrintChat("Downloading required libraries, please wait...") return end
if AUTOUPDATE then
	 SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/kokosik1221/bol/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/kokosik1221/bol/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end
local RequireI = Require("SourceLib")
RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
require "AoE_Skillshot_Position"
if VIP_USER then
	RequireI:Add("Prodiction", "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua")
	prodstatus = true
end
RequireI:Check()
if RequireI.downloadNeeded == true then return end

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

function OnLoad()
	Vars()
	Menu()
	print("<b><font color=\"#6699FF\">Annie Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
end

function Vars()
	Q = {name = "Disintegrate", range = 625, speed = 1300, delay = 0.25}
	W = {name = "Incinerate", range = 625, speed = math.huge, delay = 0.60, width = 50*math.pi/180}
	E = {name = "Molten Shield"}
	R = {name = "Summon: Tibbers", range = 600, speed = math.huge, delay = 0.20, width = 200}
	QReady, WReady, EReady, RReady, IReady, zhonyaready, sac, mma, stun, tibbers, recall = false, false, false, false, false, false, false, false, false, false, false
	abilitylvl, lastskin = 0, 0
	EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
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

function OnTick()
	Check()
	if Cel ~= nil and MenuAnnie.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuAnnie.comboConfig.manac then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuAnnie.harrasConfig.HEnabled or MenuAnnie.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuAnnie.harrasConfig.manah then
		Harrass()
	end
	if MenuAnnie.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuAnnie.farm.manaf then
		Farm()
	end
	if MenuAnnie.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuAnnie.jf.manajf then
		JungleFarm()
	end
	if MenuAnnie.prConfig.AZ then
		autozh()
	end
	if MenuAnnie.prConfig.ALS then
		autolvl()
	end
	if MenuAnnie.exConfig.AW then
		AutoW()
	end
	if MenuAnnie.exConfig.AR then
		AutoR()
	end
	if MenuAnnie.exConfig.SP then
		stackp()
	end
	KillSteall()
end

function Menu()
	VP = VPrediction()
	SOWi = SOW(VP)
	MenuAnnie = scriptConfig("Annie Master "..version, "Annie Master "..version)
	MenuAnnie:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuAnnie.Orbwalking)
	MenuAnnie:addSubMenu("Target selector", "STS")
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Annie"
	MenuAnnie.STS:addTS(TargetSelector)
	MenuAnnie:addSubMenu("[Annie Master]: Combo Settings", "comboConfig")
	MenuAnnie.comboConfig:addSubMenu("[Annie Master]: Q Settings", "qConfig")
	MenuAnnie.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig:addSubMenu("[Annie Master]: W Settings", "wConfig")
	MenuAnnie.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig:addSubMenu("[Annie Master]: E Settings", "eConfig")
	MenuAnnie.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.comboConfig:addSubMenu("[Annie Master]: R Settings", "rConfig")
	MenuAnnie.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig.rConfig:addParam("RM", "Cast (R) Mode", SCRIPT_PARAM_LIST, 3, {"Don't Use", "Normal", "Killable", "Can Hit X"})
	MenuAnnie.comboConfig.rConfig:addParam("HXC", "Min. Enemy To Hit", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuAnnie.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig:addParam("uaa2", "Use AA Only If Enemy Is In Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuAnnie.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuAnnie:addSubMenu("[Annie Master]: Harras Settings", "harrasConfig")
	MenuAnnie.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 1, {"|Q|", "|W|"}) 
	MenuAnnie.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuAnnie.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuAnnie.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuAnnie:addSubMenu("[Annie Master]: Extra Settings", "exConfig")
	MenuAnnie.exConfig:addParam("AW", "Auto W If Can Stun X Enemy", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.exConfig:addParam("AWX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuAnnie.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.exConfig:addParam("AR", "Auto R If Can Stun X Enemy", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.exConfig:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuAnnie.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.exConfig:addParam("SP", "Stack Pasive With (E)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
	MenuAnnie.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.exConfig:addParam("AEE", "Auto E If Enemy AA Me", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie:addSubMenu("[Annie Master]: KS Settings", "ksConfig")
	MenuAnnie.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.ksConfig:addParam("WKS", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie:addSubMenu("[Annie Master]: Farm Settings", "farm")
	MenuAnnie.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuAnnie.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuAnnie.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuAnnie.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuAnnie:addSubMenu("[Annie Master]: Jungle Farm Settings", "jf")
	MenuAnnie.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuAnnie.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuAnnie:addSubMenu("[Annie Master]: Draw Settings", "drawConfig")
	MenuAnnie.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.drawConfig:addParam("DQR", "Draw Q&W Range", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("DQRC", "Draw Q&W Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuAnnie.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuAnnie:addSubMenu("[Annie Master]: Misc Settings", "prConfig")
	MenuAnnie.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 9, 1, 9)
	MenuAnnie.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuAnnie.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuAnnie.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuAnnie.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	if MenuAnnie.prConfig.skin and VIP_USER then
		GenModelPacket("Annie", MenuAnnie.prConfig.skin1)
		lastSkin = MenuAnnie.prConfig.skin1
	end
	MenuAnnie.comboConfig:permaShow("CEnabled")
	MenuAnnie.harrasConfig:permaShow("HEnabled")
	MenuAnnie.harrasConfig:permaShow("HTEnabled")
	MenuAnnie.prConfig:permaShow("AZ")
	MenuAnnie.exConfig:permaShow("AW")
	MenuAnnie.exConfig:permaShow("AR")
	MenuAnnie.exConfig:permaShow("SP")
	MenuAnnie.exConfig:permaShow("AEE")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Annie Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
		mma = true
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Annie Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
		sac = true
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
	if MenuAnnie.comboConfig.uaa and not MenuAnnie.comboConfig.uaa2 then
		SOWi:EnableAttacks()
	elseif not MenuAnnie.comboConfig.uaa and not MenuAnnie.comboConfig.uaa2 then
		SOWi:DisableAttacks()
	end
	if MenuAnnie.comboConfig.uaa and MenuAnnie.comboConfig.uaa2 then
		if GetDistance(Cel) < Q.range then
			SOWi:EnableAttacks()
		else
			SOWi:DisableAttacks()
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
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
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
	if MenuAnnie.prConfig.skin and VIP_USER and skinChanged() then
		GenModelPacket("Annie", MenuAnnie.prConfig.skin1)
		lastSkin = MenuAnnie.prConfig.skin1
	end
	if MenuAnnie.drawConfig.DLC then 
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
	if QReady and MenuAnnie.comboConfig.qConfig.USEQ and GetDistance(Cel) <= Q.range then
		CastQ(Cel)
	end
	if WReady and MenuAnnie.comboConfig.wConfig.USEW and GetDistance(Cel) < W.range then
		CastW(Cel)
	end
	if MenuAnnie.comboConfig.eConfig.USEE then
		CastE()
	end
	if RReady and GetDistance(Cel) <= R.range then
		if MenuAnnie.comboConfig.rConfig.RM == 2 then
			CastR(Cel)
		end
		if MenuAnnie.comboConfig.rConfig.RM == 3 then
			local r = getDmg("R", Cel, myHero, 3)
			if Cel.health < r then
				CastR(Cel)
			end
		end
		if MenuAnnie.comboConfig.rConfig.RM == 4 then
			CastRMEC(Cel, MenuAnnie.comboConfig.rConfig.HXC)
		end
	end
end

function Harrass()
	if MenuAnnie.harrasConfig.HM == 1 then
		if QReady and GetDistance(Cel) <= Q.range and not recall then
			CastQ(Cel)
		end
	end
	if MenuAnnie.harrasConfig.HM == 2 then
		if WReady and GetDistance(Cel) < W.range and not recall then
			CastW(Cel)
		end
	end
end

function Farm()
	EnemyMinions:update()
	if not SOWi:CanMove() then return end
	QMode =  MenuAnnie.farm.QF
	WMode =  MenuAnnie.farm.WF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastSpell(_Q, minion)
			end
		elseif QMode == 2 then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					CastSpell(_Q, minion)
				end
			end
		end
		if WMode == 3 then
			if WReady and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastW(minion)
			end
		elseif WMode == 2 then
			if WReady and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				if minion.health <= getDmg("W", minion, myHero) then
					CastW(minion)
				end
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuAnnie.jf.WJF then
			if WReady and minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				CastW(minion)
			end
		end
		if MenuAnnie.jf.QJF then
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= Q.range then
				CastSpell(_Q, minion)
			end
		end
	end
end

function AutoW()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible then
			if stun and WReady and not recall then
				CastWMEC(enemy, MenuAnnie.exConfig.AWX)
			end
		end
	end
end

function AutoR()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible then
			if stun and RReady and not recall then
				CastRMEC(enemy, MenuAnnie.exConfig.ARX)
			end
		end
	end
end

function stackp()
	if not stun and EReady and not recall then
		CastE()
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuAnnie.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuAnnie.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuAnnie.prConfig.ALS then return end
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuAnnie.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuAnnie.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuAnnie.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuAnnie.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuAnnie.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuAnnie.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end

function OnDraw()
	if MenuAnnie.drawConfig.DST and MenuAnnie.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuAnnie.drawConfig.DQRC[2], MenuAnnie.drawConfig.DQRC[3], MenuAnnie.drawConfig.DQRC[4]))
		end
	end
	if MenuAnnie.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuAnnie.drawConfig.DQR and (QReady or WReady) then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuAnnie.drawConfig.DQRC[2], MenuAnnie.drawConfig.DQRC[3], MenuAnnie.drawConfig.DQRC[4]))
	end
	if MenuAnnie.drawConfig.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuAnnie.drawConfig.DRRC[2], MenuAnnie.drawConfig.DRRC[3], MenuAnnie.drawConfig.DRRC[4]))
	end
end

function KillSteall()
	for i = 1, heroManager.iCount do
		local enemy = heroManager:getHero(i)
		local health = enemy.health
		local QDMG = myHero:CalcDamage(enemy, (35 * myHero:GetSpellData(0).level + 45 + 0.8 * myHero.ap))
		local WDMG = myHero:CalcDamage(enemy, (45 * myHero:GetSpellData(1).level + 25 + 0.85 * myHero.ap))
		local RDMG = getDmg("R", enemy, myHero, 3)
		local IDMG = getDmg("IGNITE", enemy, myHero) 
		if ValidTarget(enemy) and enemy ~= nil and enemy.team ~= player.team and not enemy.dead and enemy.visible then
			if health < QDMG and MenuAnnie.ksConfig.QKS and GetDistance(enemy) <= Q.range and QReady then
				CastQ(enemy)
			elseif health < QDMG and MenuAnnie.ksConfig.WKS and GetDistance(enemy) < W.range and WReady then
				CastW(enemy)
			elseif health < RDMG and MenuAnnie.ksConfig.RKS and GetDistance(enemy) <= R.range and RReady then
				CastR(enemy)
			elseif health < IDMG and MenuAnnie.ksConfig.IKS and GetDistance(enemy) <= 600 and IReady then
				CastSpell(IgniteKey, enemy)
			elseif health < (QDMG+WDMG) and MenuAnnie.ksConfig.WKS and MenuAnnie.ksConfig.QKS and GetDistance(enemy) < W.range and WReady and QReady then
				CastW(enemy)
				CastQ(enemy)
			elseif health < (QDMG+RDMG) and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.QKS and GetDistance(enemy) <= R.range and RReady and QReady then
				CastR(enemy)
				CastQ(enemy)
			elseif health < (WDMG+RDMG) and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.WKS and GetDistance(enemy) <= R.range and RReady and WReady then
				CastR(enemy)
				CastW(enemy)
			elseif health < (QDMG+WDMG+RDMG) and MenuAnnie.ksConfig.QKS and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.WKS and GetDistance(enemy) <= R.range and RReady and WReady and QReady then
				CastR(enemy)
				CastQ(enemy)
				CastW(enemy)
			elseif health < (QDMG+IDMG) and MenuAnnie.ksConfig.QKS and GetDistance(enemy) <= Q.range and QReady and MenuAnnie.ksConfig.IKS and IReady then
				CastQ(enemy)
				CastSpell(IgniteKey, enemy)
			elseif health < (QDMG+IDMG) and MenuAnnie.ksConfig.WKS and GetDistance(enemy) < W.range and WReady and MenuAnnie.ksConfig.IKS and IReady then
				CastW(enemy)
				CastSpell(IgniteKey, enemy)
			elseif health < (RDMG+IDMG) and MenuAnnie.ksConfig.RKS and GetDistance(enemy) <= R.range and RReady and MenuAnnie.ksConfig.IKS and IReady then
				CastR(enemy)
				CastSpell(IgniteKey, enemy)
			elseif health < (QDMG+WDMG+IDMG) and MenuAnnie.ksConfig.WKS and MenuAnnie.ksConfig.QKS and GetDistance(enemy) < W.range and WReady and QReady and MenuAnnie.ksConfig.IKS and IReady then
				CastW(enemy)
				CastQ(enemy)
				CastSpell(IgniteKey, enemy)
			elseif health < (QDMG+RDMG+IDMG) and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.QKS and GetDistance(enemy) <= R.range and RReady and QReady and MenuAnnie.ksConfig.IKS and IReady then
				CastR(enemy)
				CastQ(enemy)
				CastSpell(IgniteKey, enemy)
			elseif health < (WDMG+RDMG+IDMG) and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.WKS and GetDistance(enemy) <= R.range and RReady and WReady and MenuAnnie.ksConfig.IKS and IReady then
				CastR(enemy)
				CastW(enemy)
				CastSpell(IgniteKey, enemy)
			elseif health < (QDMG+WDMG+RDMG+IDMG) and MenuAnnie.ksConfig.QKS and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.WKS and GetDistance(enemy) <= R.range and RReady and WReady and QReady and MenuAnnie.ksConfig.IKS and IReady then
				CastR(enemy)
				CastQ(enemy)
				CastW(enemy)
				CastSpell(IgniteKey, enemy)
			end
		end
	end
end

function DmgCalc()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible then
			local QDMG = myHero:CalcDamage(enemy, (35 * myHero:GetSpellData(0).level + 45 + 0.8 * myHero.ap))
			local WDMG = myHero:CalcDamage(enemy, (45 * myHero:GetSpellData(1).level + 25 + 0.85 * myHero.ap))
			local RDMG = getDmg("R", enemy, myHero, 3)
			local IDMG = getDmg("IGNITE", enemy, myHero) 
			if enemy.health > (QDMG + WDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < WDMG then
				killstring[enemy.networkID] = "W Kill!"
			elseif enemy.health < RDMG then
				killstring[enemy.networkID] = "R Kill!"
			elseif enemy.health < (QDMG + WDMG) then
				killstring[enemy.networkID] = "Q+W Kill!"
			elseif enemy.health < (QDMG + RDMG) then
				killstring[enemy.networkID] = "Q+R Kill!"
			elseif enemy.health < (WDMG + RDMG) then
				killstring[enemy.networkID] = "W+R Kill!"
			elseif enemy.health < (QDMG + WDMG + RDMG) then
				killstring[enemy.networkID] = "Q+W+R Kill!"
			elseif enemy.health < (QDMG + IDMG) then
				killstring[enemy.networkID] = "Q+Ignite Kill!"
			elseif enemy.health < (WDMG + IDMG) then
				killstring[enemy.networkID] = "W+Ignite Kill!"
			elseif enemy.health < (RDMG + IDMG) then
				killstring[enemy.networkID] = "R+Ignite Kill!"
			elseif enemy.health < (QDMG + WDMG + IDMG) then
				killstring[enemy.networkID] = "Q+W+Ignite Kill!"
			elseif enemy.health < (QDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Q+R+Ignite Kill!"
			elseif enemy.health < (WDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "W+R+Ignite Kill!"
			elseif enemy.health < (QDMG + WDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Q+W+R+Ignite Kill!"
			end
		end
	end
end

function CastQ(unit)
	if VIP_USER and MenuAnnie.prConfig.pc then
		Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
	else
		CastSpell(_Q, unit)
	end	
end

function CastW(unit)
	if MenuAnnie.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetConeAOECastPosition(unit, W.delay, W.width, W.range, W.speed, myHero)
		if CastPosition and HitChance >= 2 then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_W, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuAnnie.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetConeAOEPrediction(unit, W.range, W.speed, W.delay, W.width, myHero)
		if Position ~= nil then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _W, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_W, Position.x, Position.z)
			end	
		end
	end
end

function CastE()
	if EReady then
		if VIP_USER and MenuAnnie.prConfig.pc then
			Packet("S_CAST", {spellId = _E}):send()
		else
			CastSpell(_E)
		end
	end
end

function CastR(unit)
	if MenuAnnie.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularAOECastPosition(unit, R.delay, R.width, R.range, R.speed, myHero)
		if CastPosition and HitChance >= 2 then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuAnnie.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetCircularAOEPrediction(unit, R.range, R.speed, R.delay, R.width, myHero)
		if Position ~= nil then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_R, Position.x, Position.z)
			end	
		end
	end
end

function CastWMEC(unit, count)
	local wPos = GetAoESpellPosition(W.width, unit, W.delay)
    if wPos and GetDistance(wPos) < W.range then
        if EnemyCount(wPos, W.width) >= count then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _W, fromX = wPos.x, fromY = wPos.z, toX = wPos.x, toY = wPos.z}):send()
			else
				CastSpell(_W, wPos.x, wPos.z)
			end	
        end
	end
end

function CastRMEC(unit, count)
	local rPos = GetAoESpellPosition(R.width, unit, R.delay)
    if rPos and GetDistance(rPos) <= R.range then
        if EnemyCount(rPos, R.width) >= count then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
			else
				CastSpell(_R, rPos.x, rPos.z)
			end	
        end
	end
end

function OnProcessSpell(unit,spell)
	if MenuAnnie.exConfig.AEE then
		if unit.team ~= myHero.team and unit.type == myHero.type and spell.target == myHero and spell.name:lower():find("attack") then
			CastE()
		end
	end
end

function OnCreateObj(object)
    if object.name == "StunReady.troy" then
        stun = true
    end
    if object.name == "BearFire_foot.troy" then
        tibbers = true
    end
	if object.name:find("TeleportHome") then
		recall = true
	end
end
 
function OnDeleteObj(object)
    if object.name == "StunReady.troy" then
        stun = false
    end
    if object.name == "BearFire_foot.troy" then
        tibbers = false
    end
	if object.name:find("TeleportHome") or (recall == nil and object.name == recall.name) then
		recall = false
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

function skinChanged()
	return MenuAnnie.prConfig.skin1 ~= lastSkin
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
	if Msg == WM_LBUTTONDOWN and MenuAnnie.comboConfig.ST then
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
				if MenuAnnie.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuAnnie.comboConfig.ST then 
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
