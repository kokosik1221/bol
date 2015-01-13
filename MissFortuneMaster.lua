--[[

	Script Name: MISS FORUNTE MASTER 
    	Author: kokosik1221
	Last Version: 0.3
	13.01.2015
	
]]--

if myHero.charName ~= "MissFortune" then return end

_G.AUTOUPDATE = true


local version = "0.3"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/MissFortuneMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>MissFortuneMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/MissFortuneMaster.version")
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
	BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
	YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
	RND = { id = 3143, range = 275, reqTarget = false, slot = nil },
}

function OnLoad()
	Vars()
	Menu()
	print("<b><font color=\"#6699FF\">MissFortune Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
end

function Vars()
    Q = {name = "Double Up", range = 650}
	W = {name = "Impure Shots", range = 550}
	E = {name = "Make It Rain", range = 800, width = 400, delay = 0.65, speed = 500}	
	R = {name = "Bullet Time", range = 1400, width = 400, angle = 30, delay = 1, speed = 780}
	QReady, WReady, EReady, RReady, recall, sac, mma, rcasting = false, false, false, false, false, false, false, false
	abilitylvl = myHero.level - 1
	EnemyMinions = minionManager(MINION_ENEMY, E.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, E.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	QTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_PHYSICAL)
	RTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_PHYSICAL)
	ETargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_PHYSICAL)
	TextList = {"Harass him", "1 AA = Kill!", "2 AA = Kill!", "3 AA = Kill!", "4 AA = Kill!", "Q = Kill!", "E = Kill!", "R = Kill!", "Ignite = Kill!", "Harass him"}
	HealKey = nil
	KillText = {}
	VP = VPrediction()
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
	levelSequences = {
		QEW = { 1,3,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2},
		QWE = { 1,2,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},	
		EQW = { 3,1,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2}, 
		WQE = { 2,1,3,2,2,4,1,3,1,3,4,3,3,2,2,4,1,1},
	}
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">MissFortune Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
		mma = true
	end	
	if _G.Reborn_Loaded then
		print("<b><font color=\"#6699FF\">MissFortune Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
		sac = true
	end
end

function OnTick()
	Check()
	if MFMenu.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.comboConfig.manac then
		Combo()
	end
	if (MFMenu.harrasConfig.HEnabled or MFMenu.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.harrasConfig.manah then
		Harrass()
	end
	if MFMenu.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.farm.manaf then
		Farm()
	end
	if MFMenu.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.jf.manajf then
		JungleFarm()
	end
	if MFMenu.prConfig.ALS then
		autolvl()
	end
	if MFMenu.comboConfig.rConfig.CRKD and ValidTarget(RCel, R.range) then
		CastR(RCel)
	end
	if MFMenu.exConfig.UAH then
		AutoHeal()
	end
	AutoF()
	KillSteal()
end

function Menu()
	MFMenu = scriptConfig("MissFortune Master "..version, "MissFortune Master "..version)
	MFMenu:addSubMenu("Orbwalking", "Orbwalking")
	SxOrb:LoadToMenu(MFMenu.Orbwalking)
	MFMenu:addSubMenu("Target selector", "STS")
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 550, DAMAGE_PHYSICAL)
	TargetSelector.name = "MissFortune"
	MFMenu.STS:addTS(TargetSelector)
	MFMenu:addSubMenu("[MissFortune Master]: Combo Settings", "comboConfig")
	MFMenu.comboConfig:addSubMenu("[MissFortune Master]: Q Settings", "qConfig")
	MFMenu.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig.qConfig:addParam("USEQ2", "Use On Minions", SCRIPT_PARAM_ONOFF, false)
	MFMenu.comboConfig:addSubMenu("[MissFortune Master]: W Settings", "wConfig")
	MFMenu.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig:addSubMenu("[MissFortune Master]: E Settings", "eConfig")
	MFMenu.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig:addSubMenu("[MissFortune Master]: R Settings", "rConfig")
	MFMenu.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig.rConfig:addParam("RM", "R Cast Mode", SCRIPT_PARAM_LIST, 2, { "Normal", "Killable & Dist > AA", "Can Hit X"})
	MFMenu.comboConfig.rConfig:addParam("RX", "X = ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MFMenu.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MFMenu.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MFMenu.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MFMenu.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: Harras Settings", "harrasConfig")
	MFMenu.harrasConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("USEQ2", "Use On Minions", SCRIPT_PARAM_ONOFF, false)
	MFMenu.harrasConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MFMenu.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MFMenu.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: Extra Settings", "exConfig")
	MFMenu.exConfig:addParam("ARF", "Auto (R) If Can Hit X", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MFMenu.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.exConfig:addParam("AEF", "Auto (E) If Can Hit X", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("AEX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MFMenu.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.exConfig:addParam("UAH", "Auto Heal Summoner", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("UAHHP", "Min. HP% To Heal", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: KillSteal Settings", "ksConfig")
	MFMenu.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.ksConfig:addParam("EKS", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.ksConfig:addParam("IKS", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
	MFMenu:addSubMenu("[MissFortune Master]: Farm Settings", "farm")
	MFMenu.farm:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MFMenu.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: Jungle Farm Settings", "jf")
	MFMenu.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MFMenu.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: Draw Settings", "drawConfig")
	MFMenu.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,240,0})
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,0,200,0})
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255,200,0,0})
	MFMenu:addSubMenu("[MissFortune Master]: Misc Settings", "prConfig")
	MFMenu.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MFMenu.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MFMenu.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "Q>E>W>R", "Q>W>E>R", "E>Q>W>R", "W>Q>E>R"})
	MFMenu.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MFMenu.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	MFMenu.comboConfig:permaShow("CEnabled")
	MFMenu.harrasConfig:permaShow("HEnabled")
	MFMenu.harrasConfig:permaShow("HTEnabled")
	MFMenu.exConfig:permaShow("ARF")
	MFMenu.exConfig:permaShow("AEF")
	MFMenu.exConfig:permaShow("UAH")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") then HealKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") then HealKey = SUMMONER_2
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
	CheckUlt()
	QTargetSelector:update()
	QCel = QTargetSelector.target
	ETargetSelector:update()
	ECel = ETargetSelector.target
	RTargetSelector:update()
	RCel = RTargetSelector.target
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if ((sac and _G.AutoCarry) or mma) and SxOrb.SxOrbMenu.General.Enabled ~= false then
		SxOrb.SxOrbMenu.General.Enabled = false
	end
	SxOrb:ForceTarget(Cel)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	HReady = (HealKey ~= nil and myHero:CanUseSpell(HealKey) == READY)
	if MFMenu.drawConfig.DLC then 
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

function Getminion(tar)
	for i, minion in pairs(EnemyMinions.objects) do
		if GetDistance(minion, tar) < 300 and ValidTarget(minion, Q.range) then
			return minion
		end
	end
end

function Combo()
	if Cel ~= nil then 
		UseItems(Cel)
		if MFMenu.comboConfig.wConfig.USEW and ValidTarget(Cel, W.range) and not rcasting then
			CastW()
		end
	end
	if QCel ~= nil then 
		if MFMenu.comboConfig.qConfig.USEQ and ValidTarget(QCel, Q.range) and not rcasting and not MFMenu.comboConfig.qConfig.USEQ2 then
			CastQ(QCel)
		end
		if MFMenu.comboConfig.qConfig.USEQ and MFMenu.comboConfig.qConfig.USEQ2 and not rcasting then
			EnemyMinions:update()
			local minio = Getminion(QCel)
			local hit = CountObjectsNearPos(QCel, 200, 200, EnemyMinions.objects)
			if hit > 0 and GetDistance(minio, QCel) < 300 and ValidTarget(minio, Q.range) then
				CastQ(minion)
			end
			if not minio or GetDistance(minio, QCel) > 300 then
				if ValidTarget(QCel, Q.range) then
					CastQ(QCel)
				end
			end
		end
	end
	if ECel ~= nil then 
		if MFMenu.comboConfig.eConfig.USEE and ValidTarget(ECel) and GetDistance(ECel) <= E.range+100 and not rcasting then
			CastE(ECel)
		end
	end
	if RCel ~= nil then 
		if MFMenu.comboConfig.rConfig.USER and GetDistance(RCel) < R.range then
			if MFMenu.comboConfig.rConfig.RM == 1 then
				CastR(RCel)	
			elseif MFMenu.comboConfig.rConfig.RM == 2 then
				local RDMG = getDmg("R", RCel, myHero, 3) * 7
				if RCel.health <= RDMG and GetDistance(RCel) >= 550 then
					CastR(RCel)
				end
			elseif MFMenu.comboConfig.rConfig.RM == 3 then
				local CastPosition,  HitChance, maxHit = VP:GetConeAOECastPosition(RCel, R.delay, R.angle, R.range, R.speed, myHero)
				if HitChance >= MFMenu.prConfig.vphit - 1 and maxHit >= MFMenu.comboConfig.rConfig.RX then
					if VIP_USER and MFMenu.prConfig.pc then
						Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
					else
						CastSpell(_R, CastPosition.x, CastPosition.z)
					end
				end
			end
		end
	end
end

function Harrass()
	if MFMenu.harrasConfig.USEQ and recall == false and not rcasting and not MFMenu.harrasConfig.USEQ2 then
		if ValidTarget(QCel, Q.range) then
			CastQ(QCel)
		end
	end
	if QCel ~= nil and MFMenu.harrasConfig.USEQ and MFMenu.harrasConfig.USEQ2 and not rcasting then
		EnemyMinions:update()
		local minio = Getminion(QCel)
		local hit = CountObjectsNearPos(QCel, 200, 200, EnemyMinions.objects)
		if hit > 0 and GetDistance(minio, QCel) < 300 and ValidTarget(minio, Q.range) then
			CastQ(minio)
		end
		if not minio or GetDistance(minio, QCel) > 300 then
			if ValidTarget(QCel, Q.range) then
				CastQ(QCel)
			end
		end
	end
	if MFMenu.harrasConfig.USEW and recall == false and not rcasting then
		if ValidTarget(Cel, W.range) then
			CastW()
		end
	end
	if MFMenu.harrasConfig.USEE and recall == false and not rcasting then
		if ValidTarget(ECel, E.range) then
			CastE(ECel)
		end
	end
end

function Farm()
	EnemyMinions:update()
	if not SxOrb:CanMove() then return end
	for i, minion in pairs(EnemyMinions.objects) do
		if MFMenu.farm.USEQ then
			if minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		end
		if MFMenu.farm.USEW then
			if minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastW()
			end
		end
		if MFMenu.farm.USEE then
			if minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				local pos = BestEFarmPos(E.range, E.width, EnemyMinions.objects)
				if pos ~= nil then
					CastSpell(_E, pos.x, pos.z)
				end
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MFMenu.jf.EJF then
			if minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				local pos = BestEFarmPos(E.range, E.width, JungleMinions.objects)
				if pos ~= nil then
					CastSpell(_E, pos.x, pos.z)
				end
			end
		end
		if MFMenu.jf.WJF then
			if minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastW()
			end
		end
		if MFMenu.jf.QJF then
			if minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		end
	end
end

function BestEFarmPos(range, radius, objects)
    local Pos 
    local BHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.visionPos or object, range, radius, objects)
        if hit > BHit then
            BHit = hit
            Pos = Vector(object)
            if BHit == #objects then
               break
            end
         end
    end
    return Pos, BHit
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function autolvl()
	if MFMenu.prConfig.ALS then
		if MFMenu.prConfig.AL == 1 then
			autoLevelSetSequence(levelSequences.QEW)
		elseif MFMenu.prConfig.AL == 2 then
			autoLevelSetSequence(levelSequences.QWE)
		elseif MFMenu.prConfig.AL == 3 then
			autoLevelSetSequence(levelSequences.EQW)
		elseif MFMenu.prConfig.AL == 4 then
			autoLevelSetSequence(levelSequences.WQE)
		end
	end
end

function DmgCalc()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local iDmg = 50 + (20 * myHero.level)
			local aaDmg = getDmg("AD", enemy, myHero)
			local aaDmg2 = getDmg("AD", enemy, myHero) * 2
			local aaDmg3 = getDmg("AD", enemy, myHero) * 3
			local aaDmg4 = getDmg("AD", enemy, myHero) * 4
			local qDmg = getDmg("Q", enemy, myHero, 3)
			local eDmg = getDmg("E", enemy, myHero, 3)
			local rDmg = getDmg("R", enemy, myHero, 3) * 7
			if enemy.health < qDmg and QReady then
				KillText[i] = 6
			elseif enemy.health < eDmg and EReady then
				KillText[i] = 7
			elseif enemy.health < rDmg and RReady then
				KillText[i] = 8
			elseif enemy.health < iDmg and IReady then
				KillText[i] = 9
			elseif enemy.health < aaDmg then
				KillText[i] = 2
			elseif enemy.health < aaDmg2 then
				KillText[i] = 3
			elseif enemy.health < aaDmg3 then
				KillText[i] = 4
			elseif enemy.health < aaDmg4 then
				KillText[i] = 8
			elseif enemy.health > (aaDmg4+qDmg+eDmg+rDmg+iDmg) then
				KillText[i] = 10
			end
        end
    end
end

function OnDraw()
	if MFMenu.drawConfig.DST and MFMenu.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MFMenu.drawConfig.DQRC[2], MFMenu.drawConfig.DQRC[3], MFMenu.drawConfig.DQRC[4]))
		end
	end
	if MFMenu.drawConfig.DD then	
		DmgCalc()
		for i = 1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) and enemy ~= nil then
				local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z)) 
				local PosX = barPos.x - 35
				local PosY = barPos.y - 10
				DrawText(TextList[KillText[i]], 19, PosX, PosY, 0xFFFFFF00)
			end
		end
	end
	if MFMenu.drawConfig.DQR then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MFMenu.drawConfig.DQRC[2], MFMenu.drawConfig.DQRC[3], MFMenu.drawConfig.DQRC[4]))
	end
	if MFMenu.drawConfig.DER then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MFMenu.drawConfig.DERC[2], MFMenu.drawConfig.DERC[3], MFMenu.drawConfig.DERC[4]))
	end
	if MFMenu.drawConfig.DRR then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MFMenu.drawConfig.DRRC[2], MFMenu.drawConfig.DRRC[3], MFMenu.drawConfig.DRRC[4]))
	end
end

function AutoHeal()
	if HReady and recall == false then
		if ((myHero.health/myHero.maxHealth)*100) < MFMenu.exConfig.UAHHP then
			CastSpell(HealKey)
		end
	end
end

function AutoF()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if MFMenu.exConfig.ARF and not rcasting then
			if RReady and ValidTarget(enemy, R.range) and recall == false then
				local rPos, HitChance, maxHit, Positions = VP:GetConeAOECastPosition(enemy, R.delay, R.angle, R.range, R.speed, myHero)
				if rPos ~= nil and maxHit >= MFMenu.exConfig.ARX and HitChance >=2 then		
					if VIP_USER and MFMenu.prConfig.pc then
						Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
					else
						CastSpell(_R, rPos.x, rPos.z)
					end
				end
			end
		end
		if MFMenu.exConfig.AEF and not rcasting then
			if EReady and ValidTarget(enemy, E.range) and recall == false then
				local ePos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, E.delay, E.width, E.range, E.speed, myHero)
				if ePos ~= nil and maxHit >= MFMenu.exConfig.AEX and HitChance >=2 then		
					if VIP_USER and MFMenu.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = ePos.x, fromY = ePos.z, toX = ePos.x, toY = ePos.z}):send()
					else
						CastSpell(_E, ePos.x, ePos.z)
					end
				end
			end
		end
	end
end

function CheckUlt()
	if TargetHaveBuff("missfortunebulletsound", myHero) then
		rcasting = true 
		r2 = true
		SxOrbWalk:DisableMove()
		if _G.AutoCarry then
			
		end
    else
        rcasting = false
		r2 = false
		if rcasting == false then
			DelayAction(function() SxOrbWalk:EnableMove() end, 0.25)
			if _G.AutoCarry then
				
			end
		end
    end
	if TargetHaveBuff("recallimproved", myHero) then
		recall = true
    else
        recall = false 
    end
end

function KillSteal()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero, 3)
		local eDmg = getDmg("E", Enemy, myHero, 3)
		local rDmg = getDmg("R", Enemy, myHero, 3) * 7
		local iDmg = getDmg("IGNITE", Enemy, myHero) 
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible and GetDistance(Enemy) < 2000 and not rcasting then
			if health < qDmg and MFMenu.ksConfig.QKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
			elseif health < eDmg and MFMenu.ksConfig.EKS and ValidTarget(Enemy, E.range+50) then
				CastE(Enemy)
			elseif health < rDmg and MFMenu.ksConfig.RKS and ValidTarget(Enemy, R.range) then
				CastR(Enemy)
			elseif health <= iDmg and MFMenu.ksConfig.IKS and ValidTarget(Enemy, 600) and IReady then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end

function CastQ(unit)
	if QReady then
		if VIP_USER and MFMenu.prConfig.pc then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_Q, unit)
		end
	end
end

function CastW()
	if WReady then
		if VIP_USER and MFMenu.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if EReady then
		if MFMenu.prConfig.pro == 1 then
			local CastPosition,  HitChance,  Position = VP:GetPredictedPos(unit, E.delay, E.speed, myHero, false)
			if Position and HitChance >= MFMenu.prConfig.vphit - 1 then
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end
			end
		end
		if MFMenu.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetCircularAOEPrediction(unit, E.range, E.speed, E.delay, E.width, myHero)
			if Position ~= nil then
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end	
			end
		end
	end
end

function CastR(unit)
	if RReady then
		rcasting = true 
		r2 = true
		if MFMenu.prConfig.pro == 1 then
			local CastPosition,  HitChance, maxHit = VP:GetConeAOECastPosition(unit, R.delay, R.angle, R.range, R.speed, myHero)
			if HitChance >= MFMenu.prConfig.vphit - 1 then
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MFMenu.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetConeAOEPrediction(unit, R.range, R.speed, R.delay, R.width, myHero)
			if Position ~= nil then
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end	
			end
		end
	end
end

function OnSendPacket(packet)
    local UltPacket = Packet(packet)
    if VIP_USER and MFMenu.prConfig.pc and (UltPacket:get("name") == "S_MOVE") and r2 == true then
		UltPacket:block()
    end
end

function OnWndMsg(Msg, Key)
	if RReady and Msg == KEY_DOWN and Key == 82 then
		rcasting = true
		r2 = true
	end
	if Msg == WM_LBUTTONDOWN and MFMenu.comboConfig.ST then
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
				if MFMenu.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MFMenu.comboConfig.ST then 
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

