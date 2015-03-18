--[[

	Script Name: ZILEAN MASTER 
    	Author: kokosik1221
	Last Version: 0.2
	18.03.2015
	
]]--

if myHero.charName ~= "Zilean" then return end


_G.AUTOUPDATE = true

local version = "0.2"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/ZileanMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>ZileanMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/ZileanMaster.version")
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
 
local Q = {name = "Time Bomb", range = 900, speed = 1800, delay = 0.25, width = 170, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Rewind", Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Time Warp", range = 700, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Chronoshift", range = 900, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local IReady, ExhaustReady, HealReady, zhonyaready, recall, MAQCel = false, false, false, false, false, false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, ExhaustKey, HealKey, zhonyaslot = nil, nil, nil, nil
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
	print("<b><font color=\"#FF0000\">Zilean Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Zilean Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Zilean Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if MenuZilean.comboConfig.CEnabled and not recall then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuZilean.comboConfig.manac then
			Combo()
		end
	end
	if MenuZilean.comboConfig.CEnabled2 then
		StunCombo()
	end
	if (MenuZilean.harrasConfig.HEnabled or MenuZilean.harrasConfig.HTEnabled) and not recall then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuZilean.harrasConfig.manah then
			Harrass()
		end
	end
	if MenuZilean.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuZilean.farm.manaf and not recall then
		Farm()
	end
	if MenuZilean.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuZilean.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuZilean.prConfig.AZ and not recall then
		autozh()
	end
	if MenuZilean.prConfig.ALS then
		autolvl()
	end
	if not recall then
		KillSteall()
		Support()
	end
	if MenuZilean.uConfig.UAU and not recall then
		AutoULT()
	end
end

function Menu()
	VP = VPrediction()
	MenuZilean = scriptConfig("Zilean Master "..version, "Zilean Master "..version)
	MenuZilean:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuZilean:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuZilean.orb == 1 then
		MenuZilean:addSubMenu("[Zilean Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuZilean.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Zilean"
	MenuZilean:addTS(TargetSelector)
	MenuZilean:addSubMenu("[Zilean Master]: Combo Settings", "comboConfig")
	MenuZilean.comboConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.comboConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.comboConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuZilean.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuZilean.comboConfig:addParam("CEnabled2", "Stun Combo", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("T"))
	MenuZilean.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuZilean:addSubMenu("[Zilean Master]: Harras Settings", "harrasConfig")
    MenuZilean.harrasConfig:addParam("QH", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.harrasConfig:addParam("EH", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuZilean.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuZilean.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuZilean:addSubMenu("[Zilean Master]: Ultimate Settings", "uConfig")
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == myHero.team then
			MenuZilean.uConfig:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuZilean.uConfig:addParam("UAUHP", "Min. HP% To Use", SCRIPT_PARAM_SLICE, 10, 0, 50, 0)
    MenuZilean.uConfig:addParam("UAU", "Use Auto Ultimate", SCRIPT_PARAM_ONOFF, true)
	MenuZilean:addSubMenu("[Zilean Master]: Support Settings", "ss")
	MenuZilean.ss:addParam("qqq", "---- Mikael's Crucible ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("mchp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean.ss:addParam("umc", "Use Mikael's Crucible", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("qqq", "---- Frost Queen's Claim ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("fqhp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuZilean.ss:addParam("ufq", "Use Frost Queen's Claim", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("qqq", "---- Locket of the Iron Solari ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("ishp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean.ss:addParam("uis", "Use Locket of the Iron Solari", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("qqq", "---- Twin Shadows ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("tshp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuZilean.ss:addParam("uts", "Use Twin Shadows", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("qqq", "---- Exhaust ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("exhp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuZilean.ss:addParam("uex", "Use Exhaust", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("qqq", "---- Heal ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("hhp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean.ss:addParam("uh", "Use Heal", SCRIPT_PARAM_ONOFF, true)
	MenuZilean:addSubMenu("[Zilean Master]: KS Settings", "ksConfig")
	MenuZilean.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean:addSubMenu("[Zilean Master]: Farm Settings", "farm")
	MenuZilean.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuZilean.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 2, { "No", "LaneClear"})
	MenuZilean.farm:addParam("LaneClear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuZilean.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean:addSubMenu("[Zilean Master]: Jungle Farm", "jf")
	MenuZilean.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuZilean.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean:addSubMenu("[Zilean Master]: Draw Settings", "drawConfig")
	MenuZilean.drawConfig:addParam("DLC", "Draw Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuZilean.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.drawConfig:addParam("DRR", "Draw Q&R Range", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("DRRC", "Draw Q&R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuZilean:addSubMenu("[Zilean Master]: Misc Settings", "prConfig")
	MenuZilean.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuZilean.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuZilean.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuZilean.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuZilean.comboConfig:permaShow("CEnabled")
	MenuZilean.harrasConfig:permaShow("HEnabled")
	MenuZilean.harrasConfig:permaShow("HTEnabled")
	MenuZilean.farm:permaShow("LaneClear")
	MenuZilean.jf:permaShow("JFEnabled")
	MenuZilean.prConfig:permaShow("AZ")
	MenuZilean.prConfig:permaShow("ALS")
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

function Check()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuZilean.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if MenuZilean.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
end

function Combo()
	UseItems(Cel)
	if MenuZilean.comboConfig.USEQ and ValidTarget(Cel, Q.range) then
		CastQ(Cel)
	end
	if MenuZilean.comboConfig.USEE and ValidTarget(Cel, E.range) then
		CastE(Cel)
	end
	if MenuZilean.comboConfig.USEW and ValidTarget(Cel, Q.range) and not Q.Ready() or not E.Ready() then
		CastW()
	end
end

function StunCombo()
	CheckBomb()
	local QMana = myHero:GetSpellData(_Q).mana
    local WMana = myHero:GetSpellData(_W).mana
	if Q.Ready() and W.Ready() and ValidTarget(Cel, Q.range) and myHero.mana >= (QMana*2) + WMana then
		CastQ(Cel)
	end
	if MAQCel then
		if not Q.Ready() then
			CastW()
		end
		if Q.Ready() and ValidTarget(Cel, Q.range) then
			CastQ(Cel)
		end
	end
end

function CheckBomb()
	if Cel then
		for i = 1, Cel.buffCount do
			local buf = Cel:getBuff(i)
			if BuffIsValid(buf) then
				MAQCel = false
				if buf.name == "zileanqenemybomb" then
					MAQCel = true
				end
			end
		end
	end
end

function Harrass()
	if MenuZilean.harrasConfig.QH and ValidTarget(Cel, Q.range) then
		CastQ(Cel)
	end
	if MenuZilean.harrasConfig.EH and ValidTarget(Cel, E.range) then
		CastE(Cel)
	end
end

function Farm()
	EnemyMinions:update()
	local QMode =  MenuZilean.farm.QF
	local WMode =  MenuZilean.farm.WF
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
				if minion.health <= getDmg("Q", minion, myHero, 3) then
					CastQ(minion)
				end
			end
		end
		if WMode == 2 and QMode == 3 then
			if W.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) and not Q.Ready() then
				CastW()
			end
		end
	end
end

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuZilean.jf.QJF then
			if Q.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		end
		if MenuZilean.jf.WJF then
			if W.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) and not Q.Ready() then
				CastW()
			end
		end
	end
end

function KillSteall()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local hp = Enemy.health
		local QDMG = getDmg("Q", Enemy, myHero, 3)
		local IDMG = 50 + (20 * myHero.level)
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
			if IReady and hp < IDMG and MenuZilean.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(IgniteKey, Enemy)
			elseif hp < QDMG and MenuZilean.ksConfig.QKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
			end
		end
	end
end

function AutoULT()
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == myHero.team and GetDistance(hero) <= R.range then
			if ((hero.health/hero.maxHealth)*100) < MenuZilean.uConfig.UAUHP and MenuZilean.uConfig[hero.charName] then
				CastR(hero)
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuZilean.prConfig.AZMR)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuZilean.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuZilean.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_W,_Q,_E,_Q,_R,_W,_W,_W,_W,_R,_E,_E,_E,_E,_R,_Q,_Q}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function DmgCalc()
	for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local QDMG = getDmg("Q", enemy, myHero, 3)
			local IDMG = (50 + (20 * myHero.level))
			if enemy.health > ((QDMG*2) + IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < IDMG then
				killstring[enemy.networkID] = "Ignite Kill!"
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < 2*QDMG then
				killstring[enemy.networkID] = "2xQ Kill!"
			end
		end
	end
end

function OnDraw()
	if MenuZilean.drawConfig.DST and MenuZilean.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuZilean.drawConfig.DQRC[2], MenuZilean.drawConfig.DQRC[3], MenuZilean.drawConfig.DQRC[4]))
		end
	end
	if MenuZilean.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuZilean.drawConfig.DER and E.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuZilean.drawConfig.DERC[2], MenuZilean.drawConfig.DERC[3], MenuZilean.drawConfig.DERC[4]))
	end
	if MenuZilean.drawConfig.DRR and Q.Ready() or R.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuZilean.drawConfig.DRRC[2], MenuZilean.drawConfig.DRRC[3], MenuZilean.drawConfig.DRRC[4]))
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

function OnApplyBuff(unit, source, buff)
	if unit.isMe and buff and buff.name == "recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit.isMe and buff and buff.name == "recall" then
		recall = false
	end
end

function getHitBoxRadius(target)
	return GetDistance(target.minBBox, target.maxBBox)/2
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

function Support()
	if MenuZilean.ss.umc then
		mikael = GetInventorySlotItem(3222)
		mikaelready = (mikael ~= nil and (myHero:CanUseSpell(mikael) == READY))
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 750) and ((((hero.health/hero.maxHealth)*100) < MenuZilean.ss.mchp) or HaveBuff(hero)) then
					if mikaelready then
						CastSpell(mikael)
					end
				end
			end
		end
	end
	if MenuZilean.ss.ufq then
		frost = GetInventorySlotItem(3092)
		frostready = (frost ~= nil and (myHero:CanUseSpell(frost) == READY))
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 880) and ((enemy.health/enemy.maxHealth)*100) < MenuZilean.ss.fqhp then
				if frostready then
					CastSpell(frost, enemy.x, enemy.z)
				end
			end
		end
	end
	if MenuZilean.ss.uis then
		solari = GetInventorySlotItem(3190)
		solariready = (solari ~= nil and (myHero:CanUseSpell(solari) == READY))
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 700) and ((hero.health/hero.maxHealth)*100) < MenuZilean.ss.ishp then
					if solariready then
						CastSpell(solari)
					end
				end
			end
		end
	end
	if MenuZilean.ss.uts then
		twin = GetInventorySlotItem(3023)
		twinready = (twin ~= nil and (myHero:CanUseSpell(twin) == READY))
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 1000) and ((enemy.health/enemy.maxHealth)*100) < MenuZilean.ss.tshp then
				if twinready then
					CastSpell(twin)
				end
			end
		end
	end
	if MenuZilean.ss.uex then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 550) and ((enemy.health/enemy.maxHealth)*100) < MenuZilean.ss.exhp then
				ExhaustReady = (ExhaustKey ~= nil and myHero:CanUseSpell(ExhaustKey) == READY)
				if ExhaustReady then
					CastSpell(ExhaustKey, enemy)
				end
			end
		end
	end
	if MenuZilean.ss.uh then
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 700) and ((hero.health/hero.maxHealth)*100) < MenuZilean.ss.hhp then
					HealReady = (HealKey ~= nil and myHero:CanUseSpell(HealKey) == READY)
					if HealReady then
						CastSpell(HealKey, enemy)
					end
				end
			end
		end
	end
end

function HaveBuff(unit)
	for i = 1, unit.buffCount, 1 do      
        local buff = unit:getBuff(i) 
        if (buff.valid == true) and (buff.type == BUFF_STUN or buff.type == BUFF_ROOT or buff.type == BUFF_FEAR or buff.type == BUFF_TAUNT or buff.type == BUFF_SILENCE) then
            return true                     
        end                    
    end
end

function BestQFarmPos(range, radius, objects)
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

function CastQ(unit)
	if Q.Ready() then
		local CastPosition,  HitChance,  Position = VP:GetCircularAOECastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero)
		if CastPosition and HitChance >= 2 then
			if VIP_USER and MenuZilean.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end	
		end
	end
end

function CastW()
	if W.Ready() then
		if VIP_USER and MenuZilean.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if E.Ready() then
		if VIP_USER and MenuZilean.prConfig.pc then
			Packet("S_CAST", {spellId = _E, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_E, unit)
		end
	end
end

function CastR(unit)
	if R.Ready() then
		if VIP_USER and MenuZilean.prConfig.pc then
			Packet("S_CAST", {spellId = _R, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_R, unit)
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuZilean.comboConfig.ST then
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
				if MenuZilean.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuZilean.comboConfig.ST then 
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("OBECFJCEEDB") 
