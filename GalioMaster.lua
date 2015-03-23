--[[

	Script Name: GALIO MASTER 
    	Author: kokosik1221
	Last Version: 2.3
	23.03.2015

]]--

if myHero.charName ~= "Galio" then return end

_G.AUTOUPDATE = true


local version = "2.3"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/GalioMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>GalioMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/GalioMaster.version")
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

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}
		
local Q = {range = 940, speed = 1400, delay = 0.25, width = 235, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {range = 800, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {range = 1180, speed = 1400, delay = 0.25, width = 235, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {range = 560, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local IReady, zhonyaready, ultbuff, recall = false, false, false, false
local lasttickchecked, lasthealthchecked = 0, 0
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local QTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
local ETargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_MAGIC)
local RTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_MAGIC)
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
	print("<b><font color=\"#6699FF\">Galio Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Galio Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Galio Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	CheckUlt()
	if MenuGalio.comboConfig.CEnabled and not ultbuff and ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.comboConfig.manac and not recall then
		caa()
		Combo()
	end
	if (MenuGalio.harrasConfig.HEnabled or MenuGalio.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.harrasConfig.manah and not recall then
		Harrass()
	end
	if MenuGalio.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.farm.manaf and not recall then
		Farm()
	end
	if MenuGalio.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuGalio.exConfig.AZ and not recall then
		autozh()
	end
	if MenuGalio.prConfig.ALS and not recall then
		autolvl()
	end
	if MenuGalio.esConfig.ESEnabled and not recall then
		escape()
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
	MenuGalio = scriptConfig("Galio Master "..version, "Galio Master "..version)
	MenuGalio:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuGalio:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuGalio.orb == 1 then
		MenuGalio:addSubMenu("[Galio Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuGalio.Orbwalking)
	end
    TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, myHero.range+65, DAMAGE_MAGIC)
	TargetSelector.name = "Galio"
	MenuGalio:addTS(TargetSelector)
	MenuGalio:addSubMenu("[Galio Master]: Combo Settings", "comboConfig")
    MenuGalio.comboConfig:addParam("USEQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
    MenuGalio.comboConfig:addParam("USEW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("USEWDMG", "Use 'W' Only If Come DMG", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.comboConfig:addParam("USEE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.comboConfig:addParam("USER", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("ENEMYTOR", "Min Enemies to Cast R: ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuGalio.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuGalio.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuGalio.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuGalio:addSubMenu("[Galio Master]: Harras Settings", "harrasConfig")
    MenuGalio.harrasConfig:addParam("QH", "Harras Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.harrasConfig:addParam("EH", "Harras Use E", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuGalio.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuGalio.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuGalio:addSubMenu("[Galio Master]: Escape Settings", "esConfig")
    MenuGalio.esConfig:addParam("ESE", "Use E", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.esConfig:addParam("ESW", "Use W", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.esConfig:addParam("ESM", "Move To Mouse POS.", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.esConfig:addParam("ESEnabled", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("J"))
	MenuGalio:addSubMenu("[Galio Master]: KS Settings", "ksConfig")
	MenuGalio.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("QKS", "Use Q To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("EKS", "Use E To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("RKS", "Use R To KS", SCRIPT_PARAM_ONOFF, false)
	MenuGalio:addSubMenu("[Galio Master]: Farm Settings", "farm")
	MenuGalio.farm:addParam("QF", "Use Q", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear"})
	MenuGalio.farm:addParam("EF",  "Use E", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuGalio.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuGalio.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGalio:addSubMenu("[Galio Master]: Jungle Farm", "jf")
	MenuGalio.jf:addParam("QJF", "Jungle Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.jf:addParam("EJF", "Jungle Farm Use E", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	MenuGalio.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGalio:addSubMenu("[Galio Master]: Extra Settings", "exConfig")
	MenuGalio.exConfig:addParam("AR", "Use R To Stop Enemy Ultimates", SCRIPT_PARAM_ONOFF, true)
	MenuGalio:addSubMenu("[Galio Master]: Draw Settings", "drawConfig")
	MenuGalio.drawConfig:addParam("DLC", "Draw Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuGalio.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,100,0,255})
	MenuGalio.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuGalio.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuGalio:addSubMenu("[Galio Master]: Misc Settings", "prConfig")
	MenuGalio.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuGalio.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuGalio.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuGalio.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuGalio.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, {"MID"})
	MenuGalio.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuGalio.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	MenuGalio.comboConfig:permaShow("CEnabled")
	MenuGalio.harrasConfig:permaShow("HEnabled")
	MenuGalio.harrasConfig:permaShow("HTEnabled")
	MenuGalio.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	if heroManager.iCount < 10 then
		print("<font color=\"#FF0000\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function caa()
	if MenuGalio.orb == 1 then
		if MenuGalio.comboConfig.uaa then
			SxOrb:EnableAttacks()
		elseif not MenuGalio.comboConfig.uaa then
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
	QTargetSelector:update()
	ETargetSelector:update()
	RTargetSelector:update()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
		QCel = SelectedTarget
		ECel = ESelectedTarget
		RCel = SelectedTarget
	else
		Cel = GetCustomTarget()
		QCel = QTargetSelector.target
		ECel = ETargetSelector.target
		RCel = RTargetSelector.target
	end
	if MenuGalio.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if lasttickchecked <= GetTickCount() - 500 then
		lasthealthchecked = myHero.health
		lasttickchecked = GetTickCount()
	end
	if MenuGalio.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
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
	if Cel ~= nil then
		UseItems(Cel)
	end
	if QCel ~= nil and MenuGalio.comboConfig.USEQ and ValidTarget(QCel) then
		if Q.Ready() and GetDistance(QCel) < Q.range then
			CastQ(QCel)
		end
	end
	if W.Ready() and MenuGalio.comboConfig.USEW then
		if MenuGalio.comboConfig.USEWDMG then
			if lasthealthchecked > myHero.health then
				CastSpell(_W)
			end
		else
			CastSpell(_W)
		end
	end
	if ECel ~= nil and MenuGalio.comboConfig.USEE and ValidTarget(ECel) then
		if E.Ready() and GetDistance(ECel) < E.range then
			CastE(ECel)
		end
	end
	if RCel ~= nil and MenuGalio.comboConfig.USER and ValidTarget(RCel) then
		local enemyCount = EnemyCount(myHero, R.range)
		if not ultbuff and R.Ready() and GetDistance(RCel) < R.range and enemyCount >= MenuGalio.comboConfig.ENEMYTOR then
			ultbuff = true
			CastSpell(_R)
		end
	end
end

function Harrass()
	if QCel ~= nil and MenuGalio.harrasConfig.QH then
		if Q.Ready() and ValidTarget(QCel) and GetDistance(QCel) < Q.range then
			CastQ(QCel)
		end
	end
	if ECel ~= nil and MenuGalio.harrasConfig.EH then
		if E.Ready() and ValidTarget(ECel) and GetDistance(ECel) < E.range then
			CastE(ECel)
		end
	end
end

function escape()
	if MenuGalio.esConfig.ESE then
		CastSpell(_E, mousePos.x, mousePos.z)
	end
	if MenuGalio.esConfig.ESW then
		CastSpell(_W)
	end
	if MenuGalio.esConfig.ESM then
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuGalio.farm.QF
	EMode =  MenuGalio.farm.EF
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
					CastQ(minion)
				end
			end
		end
		if EMode == 3 then
			if E.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				local Pos, Hit = BestQFarmPos(E.range, E.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_E, Pos.x, Pos.z)
				end
			end
		elseif EMode == 2 then
			if E.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				if minion.health <= getDmg("E", minion, myHero) then
					CastE(minion)
				end
			end
		end
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

function JungleFarmm()
	if MenuGalio.jf.QJF then
		for i, minion in pairs(JungleMinions.objects) do
			if Q.Ready() and minion ~= nil and not minion.dead and GetDistance(minion) <= Q.range then
				CastQ(minion)
			end
		end
	end
	if MenuGalio.jf.EJF then
		for i, minion in pairs(JungleMinions.objects) do
			if E.Ready() and minion ~= nil and not minion.dead and GetDistance(minion) <= E.range then
				CastE(minion)
			end
		end
	end
end

function KillSteall()
if not ultbuff then 
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local distance = GetDistance(Enemy)
		local qDmg = myHero:CalcDamage(Enemy, (55 * myHero:GetSpellData(0).level + 25 + 0.6 * myHero.ap))
		local eDmg = myHero:CalcDamage(Enemy, (45 * myHero:GetSpellData(2).level + 15 + 0.5 * myHero.ap))
		local rDmg = myHero:CalcDamage(Enemy, (110 * myHero:GetSpellData(3).level + 110 + 0.6 * myHero.ap))
		local iDmg = 50 + (20 * myHero.level)
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health < qDmg and Q.Ready() and (distance < Q.range) and MenuGalio.ksConfig.QKS then
				CastQ(Enemy)
			elseif health < eDmg and E.Ready() and (distance < E.range) and MenuGalio.ksConfig.EKS then
				CastE(Enemy)
			elseif health < rDmg and R.Ready() and (distance < R.range) and MenuGalio.ksConfig.RKS then
				CastSpell(_R)
			elseif health < (qDmg + eDmg) and Q.Ready() and E.Ready() and (distance < Q.range) and MenuGalio.ksConfig.EKS and MenuGalio.ksConfig.QKS then
				CastQ(Enemy)
				CastE(Enemy)
			elseif health < (qDmg + rDmg) and Q.Ready() and R.Ready() and (distance < R.range) and MenuGalio.ksConfig.RKS and MenuGalio.ksConfig.QKS then
				CastQ(Enemy)
				CastSpell(_R)
			elseif health < (eDmg + rDmg) and E.Ready() and R.Ready() and (distance < R.range) and MenuGalio.ksConfig.EKS and MenuGalio.ksConfig.RKS then
				CastE(Enemy)
				CastSpell(_R)
			elseif health < (qDmg + eDmg + rDmg) and Q.Ready() and E.Ready() and R.Ready() and (distance < R.range) and MenuGalio.ksConfig.RKS and MenuGalio.ksConfig.QKS and MenuGalio.ksConfig.EKS then
				CastQ(Enemy)
				CastE(Enemy)
				CastSpell(_R)
			end
			IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
			if IReady and health <= iDmg and MenuGalio.ksConfig.IKS and (distance < 600) then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end
end

function OnDraw()
	if MenuGalio.drawConfig.DST and MenuGalio.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuGalio.drawConfig.DQRC[2], MenuGalio.drawConfig.DQRC[3], MenuGalio.drawConfig.DQRC[4]))
		end
	end
	if MenuGalio.drawConfig.DQR and Q.Ready() then
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuGalio.drawConfig.DQRC[2], MenuGalio.drawConfig.DQRC[3], MenuGalio.drawConfig.DQRC[4]))
	end
	if MenuGalio.drawConfig.DWR and W.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuGalio.drawConfig.DWRC[2], MenuGalio.drawConfig.DWRC[3], MenuGalio.drawConfig.DWRC[4]))
	end
	if MenuGalio.drawConfig.DER and E.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuGalio.drawConfig.DERC[2], MenuGalio.drawConfig.DERC[3], MenuGalio.drawConfig.DERC[4]))
	end
	if MenuGalio.drawConfig.DRR and R.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuGalio.drawConfig.DRRC[2], MenuGalio.drawConfig.DRRC[3], MenuGalio.drawConfig.DRRC[4]))
	end
	if MenuGalio.drawConfig.DD then	
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
end

function OnApplyBuff(unit, source, buff)
	if unit.isMe and buff and buff.name == "GalioIdolOfDurand" then
		if MenuGalio.orb == 1 then
			SxOrb:DisableMove()
			SxOrb:DisableAttacks()
		elseif MenuGalio.orb == 2 then
			AutoCarry.MyHero:MovementEnabled(false)
			AutoCarry.MyHero:AttacksEnabled(false)
		end
	end
	if unit.isMe and buff and buff.name == "Recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit.isMe and buff and buff.name == "GalioIdolOfDurand" then
		if not _G.AutoCarry then
			SxOrb:EnableMove()
			SxOrb:EnableAttacks()
		elseif _G.AutoCarry then
			AutoCarry.MyHero:MovementEnabled(true)
			AutoCarry.MyHero:AttacksEnabled(true)
		end
		ultbuff = false
	end
	if unit.isMe and buff and buff.name == "Recall" then
		recall = false
	end
end

function CheckUlt()
	if ultbuff then
		if not _G.AutoCarry then
			SxOrb:DisableMove()
			SxOrb:DisableAttacks()
		elseif _G.AutoCarry then
			AutoCarry.MyHero:MovementEnabled(false)
			AutoCarry.MyHero:AttacksEnabled(false)
		end
    end
end

function autozh()
	local count = EnemyCount(myHero, MenuGalio.prConfig.AZMR)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuGalio.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuGalio.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_W,_Q,_E,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnProcessSpell(unit, spell)
    if MenuGalio.exConfig.AR and unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and CanUseSpell(_R) == READY and GetDistance(unit) < R.range then
        if spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel" or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp" or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole" or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport" then
            CastSpell(_R, unit)
        end
    end
end

function DmgCalc()
    for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
			local qDmg = myHero:CalcDamage(enemy, (55 * myHero:GetSpellData(0).level + 25 + 0.6 * myHero.ap))
			local eDmg = myHero:CalcDamage(enemy, (45 * myHero:GetSpellData(2).level + 15 + 0.5 * myHero.ap))
			local rDmg = myHero:CalcDamage(enemy, (110 * myHero:GetSpellData(3).level + 110 + 0.6 * myHero.ap))
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
			elseif enemy.health < (eDmg + rDmg) then
                killstring[enemy.networkID] = "E+R Kill!"	
			elseif enemy.health < (qDmg + eDmg + rDmg) then
                killstring[enemy.networkID] = "Q+E+R Kill!"	
            end
        end
    end
end

function SpellCast(spellSlot,castPosition)
	if VIP_USER and MenuGalio.prConfig.pc then
		Packet("S_CAST", {spellId = spellSlot, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
	else
		CastSpell(spellSlot,castPosition.x,castPosition.z)
	end
end

function CastQ(unit)
	if MenuGalio.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, false)
		if HitChance >= MenuGalio.prConfig.vphit - 1 then
			SpellCast(_Q, CastPosition)
		end
	end
	if MenuGalio.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
		if Position ~= nil and info.hitchance >= 2 then
			SpellCast(_Q, Position)	
		end
	end
	if MenuGalio.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local GalioQ = CircleSS(Q.speed, Q.range, Q.width, 250, math.huge)
		local State, Position, perc = DP:predict(unit, GalioQ)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			SpellCast(_Q, Position)
		end
	end
end

function CastE(unit)
	if MenuGalio.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, E.delay, E.width, E.range, E.speed, myHero, false)
		if HitChance >= MenuGalio.prConfig.vphit - 1 then
			SpellCast(_E, CastPosition)
		end
	end
	if MenuGalio.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, E.range, E.speed, E.delay, E.width, myHero)
		if Position ~= nil and info.hitchance >= 2 then
			SpellCast(_E, Position)	
		end
	end
	if MenuGalio.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local GalioE = LineSS(E.speed, E.range, E.width, 250, math.huge)
		local State, Position, perc = DP:predict(unit, GalioE)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			SpellCast(_E, Position)
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuGalio.comboConfig.ST then
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
				if MenuGalio.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuGalio.comboConfig.ST then 
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("UHKIIOHJPJP") 
