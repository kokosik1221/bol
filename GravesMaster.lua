--[[

	Script Name: GRAVES MASTER 
  Author: kokosik1221
	Last Version: 0.1
	28.02.2015

]]--

if myHero.charName ~= "Graves" then return end

_G.AUTOUPDATE = true

local version = "0.1"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/GravesMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>GravesMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/GravesMaster.version")
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
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["Prodiction"] = "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua",
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

local Q = {name = "Buckshot", range = 950, speed = 2000, delay = 0.25, angle = 25 * math.pi/180}
local W = {name = "Smoke Screen", range = 950, speed = 1650, delay = 0.25, width = 250}
local E = {name = "Quickdraw", range = 425}
local R = {name = "Collateral Damage", range = 1000, speed = 2100, delay = 0.25, width = 100}
local QTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_PHYSICAL)
local WTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, W.range, DAMAGE_PHYSICAL)
local RTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_PHYSICAL)
local QReady, WReady, EReady, RReady, HReady, recall = false, false, false, false, false, false, false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local HealKey = nil
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

function Menu()
	VP = VPrediction()
	MenuGraves = scriptConfig("Graves Master "..version, "Graves Master "..version)
	MenuGraves:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuGraves:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuGraves.orb == 1 then
		MenuGraves:addSubMenu("[Graves Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuGraves.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, myHero.range+65, DAMAGE_PHYSICAL)
	TargetSelector.name = "Graves"
	MenuGraves:addTS(TargetSelector)
	MenuGraves:addSubMenu("[Graves Master]: Combo Settings", "comboConfig")
	MenuGraves.comboConfig:addSubMenu("[Graves Master]: Q Settings", "qConfig")
	MenuGraves.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.comboConfig.qConfig:addParam("USEQ2", "Dash With E", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.comboConfig:addSubMenu("[Graves Master]: W Settings", "wConfig")
	MenuGraves.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.comboConfig:addSubMenu("[Graves Master]: E Settings", "eConfig")
	MenuGraves.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 2, { "No", "To Mouse", "To Target"})
	MenuGraves.comboConfig:addSubMenu("[Graves Master]: R Settings", "rConfig")
	MenuGraves.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.comboConfig.rConfig:addParam("USER2", "Cast If:", SCRIPT_PARAM_LIST, 2, { "Easy Kill", "Medium Kill", "Hard Kill"})
	MenuGraves.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
	MenuGraves.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuGraves.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuGraves.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: Harras Settings", "harrasConfig")
    MenuGraves.harrasConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.harrasConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuGraves.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuGraves.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: Extra Settings", "exConfig")
	MenuGraves.exConfig:addParam("UAH", "Auto Heal Summoner", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.exConfig:addParam("UAHHP", "Min. HP% To Heal", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: KS Settings", "ksConfig")
	MenuGraves.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.ksConfig:addParam("WKS", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves:addSubMenu("[Graves Master]: Farm Settings", "farm")
	MenuGraves.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuGraves.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuGraves.farm:addParam("LaneClear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuGraves.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: Jungle Farm", "jf")
	MenuGraves.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuGraves.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: Draw Settings", "drawConfig")
	MenuGraves.drawConfig:addParam("DLC", "Draw Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DAR", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DARC", "Draw AA Range Color", SCRIPT_PARAM_COLOR, {255,255,0,255})
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,0,255,255})
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuGraves:addSubMenu("[Graves Master]: Misc Settings", "prConfig")
	MenuGraves.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuGraves.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuGraves.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction"}) 
	MenuGraves.comboConfig:permaShow("CEnabled")
	MenuGraves.harrasConfig:permaShow("HEnabled")
	MenuGraves.harrasConfig:permaShow("HTEnabled")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") then HealKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") then HealKey = SUMMONER_2
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
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Graves Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Graves Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnLoad()
	Menu()
end

function OnTick()
	Check()
	if MenuGraves.comboConfig.CEnabled and not recall then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.comboConfig.manac then
			Combo()
		end
	end
	if (MenuGraves.harrasConfig.HEnabled or MenuGraves.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.harrasConfig.manah and not recall then
		Harass()
	end
	if MenuGraves.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.farm.manaf and not recall then
		Farm()
	end
	if MenuGraves.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.jf.manajf and not recall then
		JungleFarm()
	end
	if MenuGraves.prConfig.ALS then
		autolvl()
	end
	if MenuGraves.exConfig.UAH and not recall then
		AutoHeal()
	end
	if not recall then
		KillSteal()
	end
	if MenuGraves.comboConfig.rConfig.CRKD then
		if RCel and RCel ~= nil and GetDistance(RCel) < R.range then
			CastR(RCel)
		end
	end
end

function Check()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	QTargetSelector:update()	
	QCel = QTargetSelector.target
	WTargetSelector:update()	
	WCel = WTargetSelector.target
	RTargetSelector:update()	
	RCel = RTargetSelector.target
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	HReady = (HealKey ~= nil and myHero:CanUseSpell(HealKey) == READY)
	if MenuGraves.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
	if MenuGraves.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if MenuGraves.comboConfig.qConfig.USEQ2 and QReady and EReady then
		Q.range = 425 + 950
	elseif not MenuGraves.comboConfig.qConfig.USEQ2 then
		Q.range = 950
	end
end

function Combo()
	if QCel and QCel ~= nil and MenuGraves.comboConfig.qConfig.USEQ and GetDistance(QCel) < Q.range then
		if MenuGraves.comboConfig.qConfig.USEQ2 then
			CastE(QCel)
		end
		CastQ(QCel)
	end
	if WCel and WCel ~= nil and MenuGraves.comboConfig.wConfig.USEW and GetDistance(WCel) < W.range then
		CastW(WCel)
	end
	if QCel and QCel ~= nil and MenuGraves.comboConfig.eConfig.USEE == 2 and GetDistance(QCel) <= myHero.range+65 then
		CastE(mousePos)
	end
	if QCel and QCel ~= nil and MenuGraves.comboConfig.eConfig.USEE == 3 and GetDistance(QCel) <= myHero.range+65 then
		CastE(QCel)
	end
	if RCel and RCel ~= nil and MenuGraves.comboConfig.rConfig.USER and GetDistance(RCel) < R.range then
		CastR(RCel)
	end
end

function Harass()
	if QCel and QCel ~= nil and MenuGraves.harrasConfig.USEQ and GetDistance(QCel) < Q.range then
		CastQ(QCel)
	end
	if WCel and WCel ~= nil and MenuGraves.harrasConfig.USEW and GetDistance(WCel) < W.range then
		CastW(WCel)
	end
end

function Farm()
	EnemyMinions:update()
	local QMode = MenuGraves.farm.QF
	local WMode = MenuGraves.farm.WF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 2 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				if minion.health < getDmg("Q", minion, myHero, 3) then
					CastQ(minion)
				end
			end
		elseif QMode == 3 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				local pos, BestHit = GetBestLineFarmPosition(Q.range, Q.angle, EnemyMinions.objects)
				if pos ~= nil then
					CastSpell(_Q, pos.x, pos.z)
				end
			end
		end
		if WMode == 2 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				if minion.health <= getDmg("W", minion, myHero, 3) then
					CastW(minion)
				end
			end
		elseif WMode == 3 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				local pos = BestWFarmPos(W.range, W.width, EnemyMinions.objects)
				if pos ~= nil then
					CastSpell(_W, pos.x, pos.z)
				end
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuGraves.jf.WJF then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				local pos = BestWFarmPos(W.range, W.width, JungleMinions.objects)
				if pos ~= nil then
					CastSpell(_W, pos.x, pos.z)
				end
			end
		end
		if MenuGraves.jf.QJF then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				local pos, BestHit = GetBestLineFarmPosition(Q.range, Q.angle, JungleMinions.objects)
				if pos ~= nil then
					CastSpell(_Q, pos.x, pos.z)
				end
			end
		end
	end
end

function OnDraw()
	if MenuGraves.drawConfig.DST and MenuGraves.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuGraves.drawConfig.DQRC[2], MenuGraves.drawConfig.DQRC[3], MenuGraves.drawConfig.DQRC[4]))
		end
	end
	if MenuGraves.drawConfig.DAR then			
		DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+65, RGB(MenuGraves.drawConfig.DARC[2], MenuGraves.drawConfig.DARC[3], MenuGraves.drawConfig.DARC[4]))
	end
	if MenuGraves.drawConfig.DQR and QReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuGraves.drawConfig.DQRC[2], MenuGraves.drawConfig.DQRC[3], MenuGraves.drawConfig.DQRC[4]))
	end
	if MenuGraves.drawConfig.DWR and WReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuGraves.drawConfig.DWRC[2], MenuGraves.drawConfig.DWRC[3], MenuGraves.drawConfig.DWRC[4]))
	end
	if MenuGraves.drawConfig.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuGraves.drawConfig.DERC[2], MenuGraves.drawConfig.DERC[3], MenuGraves.drawConfig.DERC[4]))
	end
	if MenuGraves.drawConfig.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuGraves.drawConfig.DRRC[2], MenuGraves.drawConfig.DRRC[3], MenuGraves.drawConfig.DRRC[4]))
	end
end

function autolvl()
	if not MenuGraves.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function GetBestLineFarmPosition(range, width, objects)
	local BestPos 
	local BestHit = 0
	for i, object in ipairs(objects) do
		local EndPos = Vector(myHero.visionPos) + range * (Vector(object) - Vector(myHero.visionPos)):normalized()
		local hit = CountObjectsOnLineSegment(myHero.visionPos, EndPos, width, objects)
		if hit > BestHit then
			BestHit = hit
			BestPos = Vector(object)
			if BestHit == #objects then
			   break
			end
		 end
	end
	return BestPos, BestHit
end

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
	local n = 0
	for i, object in ipairs(objects) do
		local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
		if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width then
			n = n + 1
		end
	end
	return n
end

function BestWFarmPos(range, radius, objects)
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

function AutoHeal()
	if HReady then
		if ((myHero.health/myHero.maxHealth)*100) < MenuGraves.exConfig.UAHHP then
			CastSpell(HealKey)
		end
	end
end

function CalcDMG(unit)
	local dmg = 0
	if MenuGraves.comboConfig.rConfig.USER2 == 1 then
		dmg = dmg + getDmg("AD", unit, myHero) * 2
	elseif MenuGraves.comboConfig.rConfig.USER2 == 2 then
		dmg = dmg + getDmg("AD", unit, myHero) * 5
	elseif MenuGraves.comboConfig.rConfig.USER2 == 3 then
		dmg = dmg + getDmg("AD", unit, myHero) * 9
	end
	dmg = dmg + ((RReady and getDmg("R", unit, myHero, 3)) or 0)
	dmg = dmg + ((QReady and getDmg("Q", unit, myHero, 3)) or 0)
	dmg = dmg + ((WReady and getDmg("W", unit, myHero)) or 0)
	return dmg
end

function CastR(unit)
	local DMG = CalcDMG(unit)
	if RReady and ValidTarget(unit) and DMG > unit.health then
		if MenuGraves.prConfig.pro == 1 then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, R.delay, R.width, R.range, R.speed, myHero)
			if CastPosition and HitChance >= 2 then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end	
			end
		end
		if MenuGraves.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, R.range, R.speed, R.delay, R.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end
			end
		end
	end
end

function CastE(unit)
	if EReady then
		if VIP_USER and MenuGraves.prConfig.pc then
			Packet("S_CAST", {spellId = _E, fromX = unit.x, fromY = unit.z, toX = unit.x, toY = unit.z}):send()
		else
			CastSpell(_E, unit.x, unit.z)
		end
	end
end

function CastW(unit)
	if WReady and ValidTarget(unit) then
		if MenuGraves.prConfig.pro == 1 then
			local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(unit, W.delay, W.width, W.range, W.speed, myHero)
			if CastPosition and HitChance >= 2  then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_W, CastPosition.x, CastPosition.z)
				end	
			end
		end
		if MenuGraves.prConfig.pro == 2 then
			local Position, info = Prodiction.GetPrediction(unit, W.range, W.speed, W.delay, W.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _W, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_W, Position.x, Position.z)
				end
			end
		end
	end
end

function CastQ(unit)
	if QReady and ValidTarget(unit) then
		if MenuGraves.prConfig.pro == 1 then
			local CastPosition, HitChance, Position = VP:GetConeAOECastPosition(unit, Q.delay, Q.angle, Q.range, Q.speed, myHero)
			if CastPosition and HitChance >= 2  then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end	
			end
		end
		if MenuGraves.prConfig.pro == 2 then
			local Position, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
	end
end

function OnApplyBuff(unit, source, buff)
	if unit and unit.isMe and buff and buff.name == "recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and buff.name == "recall" then
		recall = false
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

function KillSteal()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero)
		local wDmg = getDmg("W", Enemy, myHero)
		local rDmg = getDmg("R", Enemy, myHero, 3)
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible and GetDistance(Enemy) < 2000 then
			if health < qDmg and MenuGraves.ksConfig.QKS and GetDistance(Enemy) < Q.range then
				CastQ(Enemy)
			elseif health < wDmg and MenuGraves.ksConfig.WKS and GetDistance(Enemy) < W.range then
				CastW(Enemy)
			elseif health < rDmg and MenuGraves.ksConfig.RKS and GetDistance(Enemy) < R.range then
				CastR(Enemy)
			end
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuGraves.comboConfig.ST then
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
				if MenuGraves.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuGraves.comboConfig.ST then 
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("SFIGJFHGFIM") 
