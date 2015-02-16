--[[

	Script Name: BRAND MASTER 
    	Author: kokosik1221
	Last Version: 1.3
	16.02.2015
	
]]--
	
if myHero.charName ~= "Brand" then return end

_G.AUTOUPDATE = true
_G.USESKINHACK = false


local version = "1.3"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/BrandMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>BrandMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/BrandMaster.version")
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
		print("<b><font color=\"#6699FF\">Required libraries downloaded successfully, please reload (double F9).</font>")
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

function Vars()
	Q = {name = "Sear", range = 1100, speed = 1600, delay = 0.25, width = 60}
	W = {name = "Pillar of Flame", range = 900, speed = math.huge, delay = 1, width = 240}
	E = {name = "Conflagration", range = 625}
	R = {name = "Pyroclasm", range = 750}
	QReady, WReady, EReady, RReady, IReady = false, false, false, false, false
	lastskin = 0
	EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	IgniteKey = nil
	killstring = {}
	print("<b><font color=\"#FF0000\">Brand Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Brand Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Brand Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnLoad()
	Vars()
	Menu()
end

function OnTick()
	Check()
	if Cel ~= nil and MenuBrand.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.comboConfig.manac then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuBrand.harrasConfig.HEnabled or MenuBrand.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.harrasConfig.manah then
		Harrass()
	end
	if MenuBrand.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.farm.manaf then
		Farm()
	end
	if MenuBrand.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.jf.manajf then
		JungleFarmm()
	end
	if MenuBrand.prConfig.AZ then
		autozh()
	end
	if MenuBrand.prConfig.ALS then
		autolvl()
	end
	if MenuBrand.exConfig.AW then
		AutoW()
	end
	if MenuBrand.exConfig.AQ then
		AutoQ()
	end
	if WReady and Cel ~= nil and MenuBrand.exConfig.AW2 then
		for _, enemy in pairs(GetEnemyHeroes()) do
			local wPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, W.delay, W.width, W.range, W.speed, myHero)
			if ValidTarget(enemy) and wPos ~= nil and maxHit >= MenuBrand.exConfig.AW2C then		
				if VIP_USER and MenuBrand.prConfig.pc then
					Packet("S_CAST", {spellId = _W, fromX = wPos.x, fromY = wPos.z, toX = wPos.x, toY = wPos.z}):send()
				else
					CastSpell(_W, wPos.x, wPos.z)
				end	
			end
		end
	end	
	if MenuBrand.comboConfig.rConfig.CRKD and Cel and RReady then
		CastSpell(_R, Cel)
	end
	KillSteall()
end

function Menu()
	VP = VPrediction()
	MenuBrand = scriptConfig("Brand Master "..version, "Brand Master "..version)
	MenuBrand:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuBrand:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuBrand.orb == 1 then
		MenuBrand:addSubMenu("Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuBrand.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Brand"
	MenuBrand:addSubMenu("Target selector", "STS")
	MenuBrand.STS:addTS(TargetSelector)
	MenuBrand:addSubMenu("[Brand Master]: Combo Settings", "comboConfig")
	MenuBrand.comboConfig:addSubMenu(Q.name .. " (Q) Options", "qConfig")
	MenuBrand.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig.qConfig:addParam("USEQS", "Use Only If Target Is Ablazed", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.comboConfig:addSubMenu(W.name .. " (W) Options", "wConfig")
	MenuBrand.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addSubMenu(E.name .. " (E) Options", "eConfig")
	MenuBrand.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addSubMenu(R.name .. " (R) Options", "rConfig")
	MenuBrand.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig.rConfig:addParam("RM", "R Cast Mode:", SCRIPT_PARAM_LIST, 4, {"Normal", "Target Ablazed", "Target Killable", "Target Ablazed&Killable"})
	MenuBrand.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuBrand.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuBrand.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuBrand:addSubMenu("[Brand Master]: Harras Settings", "harrasConfig")
    MenuBrand.harrasConfig:addParam("QH", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.harrasConfig:addParam("QHS", "Use Only If Target Is Ablazed", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("WH", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("EH", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuBrand.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuBrand.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuBrand:addSubMenu("[Brand Master]: KS Settings", "ksConfig")
	MenuBrand.ksConfig:addParam("IKS", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("WKS", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("EKS", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
	MenuBrand:addSubMenu("[Brand Master]: Farm Settings", "farm")
	MenuBrand.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuBrand.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuBrand.farm:addParam("EF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuBrand.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuBrand.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuBrand:addSubMenu("[Brand Master]: Jungle Farm Settings", "jf")
	MenuBrand.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	MenuBrand.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuBrand:addSubMenu("[Brand Master]: Extra Settings", "exConfig")
	MenuBrand.exConfig:addParam("AQ", "Auto Q On Stunned Enemy", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.exConfig:addParam("AW", "Auto W On Stunned Enemy", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.exConfig:addParam("AW2", "Auto W If Can Hit X Enemy ", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.exConfig:addParam("AW2C", "Min. Enemy To Hit", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuBrand:addSubMenu("[Brand Master]: Draw Settings", "drawConfig")
	MenuBrand.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DQL", "Draw Q Collision Line", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DQLC", "Draw Q Collision Color", SCRIPT_PARAM_COLOR, {150,40,4,4})
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,100,0,255})
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuBrand:addSubMenu("[Brand Master]: Misc Settings", "prConfig")
	MenuBrand.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 5, 1, 5)
	MenuBrand.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuBrand.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuBrand.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "MID" })
	MenuBrand.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuBrand.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	MenuBrand.comboConfig:permaShow("CEnabled")
	MenuBrand.harrasConfig:permaShow("HEnabled")
	MenuBrand.harrasConfig:permaShow("HTEnabled")
	MenuBrand.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end

function caa()
	if MenuBrand.orb == 1 then
	if MenuBrand.comboConfig.uaa then
		SxOrb:EnableAttacks()
	elseif not MenuBrand.comboConfig.uaa then
		SxOrb:DisableAttacks()
	end
	end
end

function GetRange()
	if QReady and WReady then
		return Q.range
	elseif not QReady and WReady then
		return W.range
	elseif QReady and not WReady then
		return Q.range
	elseif not QReady and not WReady then
		return E.range	
	elseif not QReady and not WReady and RReady then
		return R.range
	elseif not QReady and not WReady and not RReady then
		return E.range
	else
		return Q.range
	end
end

function GetCustomTarget()
	TargetSelector.range = GetRange()
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
	if MenuBrand.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if MenuBrand.prConfig.skin and VIP_USER and _G.USESKINHACK then
		if MenuBrand.prConfig.skin1 ~= lastSkin then
			GenModelPacket("Brand", MenuBrand.prConfig.skin1)
			lastSkin = MenuBrand.prConfig.skin1
		end
	end
	if MenuBrand.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
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
	UseItems(Cel)
	CastRC()
	if WReady and MenuBrand.comboConfig.wConfig.USEW and ValidTarget(Cel, W.range) then
		CastW(Cel)
	end
	if QReady and MenuBrand.comboConfig.qConfig.USEQ and ValidTarget(Cel, Q.range) then
		if MenuBrand.comboConfig.qConfig.USEQS then
			if TargetHaveBuff("brandablaze", Cel) then
				CastQ(Cel)
			end
		elseif not MenuBrand.comboConfig.qConfig.USEQS then
			CastQ(Cel)
		end
	end
	if EReady and MenuBrand.comboConfig.eConfig.USEE and ValidTarget(Cel, E.range) then
		CastSpell(_E, Cel)
	end
end

function CastRC()
	if RReady and MenuBrand.comboConfig.rConfig.USER and ValidTarget(Cel, R.range) then
		if MenuBrand.comboConfig.rConfig.RM == 1 then
			CastSpell(_R, Cel)
		elseif MenuBrand.comboConfig.rConfig.RM == 2 then
			if TargetHaveBuff("brandablaze", Cel) then
				CastSpell(_R, Cel)
			end
		elseif MenuBrand.comboConfig.rConfig.RM == 3 then
			local rdmg = getDmg("R", Cel, myHero,3)
			if Cel.health < rdmg then
				CastSpell(_R, Cel)
			end
		elseif MenuBrand.comboConfig.rConfig.RM == 4 then
			local rdmg = getDmg("R", Cel, myHero,3)
			if TargetHaveBuff("brandablaze", Cel) and Cel.health < rdmg then
				CastSpell(_R, Cel)
			end
		end
	end
end

function Harrass()
	if MenuBrand.harrasConfig.QH and QReady and ValidTarget(Cel, Q.range) then
		if MenuBrand.harrasConfig.QHS then
			if TargetHaveBuff("brandablaze", Cel) then
				CastQ(Cel)
			end
		elseif not MenuBrand.harrasConfig.QHS then
			CastQ(Cel)
		end
	end
	if WReady and MenuBrand.harrasConfig.WH then
		CastW(Cel)
	end
	if MenuBrand.harrasConfig.EH and EReady and ValidTarget(Cel, E.range)then
		CastSpell(_E, Cel)
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuBrand.farm.QF
	WMode =  MenuBrand.farm.WF
	EMode =  MenuBrand.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		elseif QMode == 2 then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					CastQ(minion)
				end
			end
		end
		if EMode == 3 then
			if EReady and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				if TargetHaveBuff("brandablaze", minion) then
					CastSpell(_E, minion)
				end
			end
		elseif EMode == 2 then
			if EReady and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				if minion.health <= getDmg("E", minion, myHero) then
					CastSpell(_E, minion)
				end
			end
		end
		if WMode == 3 then
			if WReady and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				local Pos, Hit = BestWFarmPos(W.range, W.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
		elseif WMode == 2 then
			if WReady and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				if minion.health <= getDmg("W", minion, myHero) then
					CastSpell(_W, minion.x, minion.z)
				end
			end
		end
	end
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

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuBrand.jf.QJF then
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= Q.range then
				CastQ(minion)
			end
		end
		if MenuBrand.jf.WJF then
			if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= W.range then
				local Pos, Hit = BestWFarmPos(W.range, W.width, JungleMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
		end
		if MenuBrand.jf.EJF then
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= Q.range then
				if TargetHaveBuff("brandablaze", minion) then
					CastSpell(_E, minion)
				end
			end
		end
		if ValidTarget(minion, 550) then
			myHero:Attack(minion)
		end
	end
end

function AutoQ()
	for _, targetq in pairs(GetEnemyHeroes()) do
        if targetq ~= nil and targetq.team ~= player.team and targetq.visible and not targetq.dead then
            if ValidTarget(targetq, Q.range - 30) and QReady and not targetq.canMove then
                CastQ(targetq)
            end
        end
    end
end

function AutoW()
	for _, target in pairs(GetEnemyHeroes()) do
        if target ~= nil and target.team ~= player.team and target.visible and not target.dead then
            if ValidTarget(target, W.range - 30) and WReady and not target.canMove) then
                CastW(target)
            end
        end
    end
end

function autozh()
	local count = EnemyCount(myHero, MenuBrand.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuBrand.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuBrand.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuBrand.drawConfig.DST and MenuBrand.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuBrand.drawConfig.DQRC[2], MenuBrand.drawConfig.DQRC[3], MenuBrand.drawConfig.DQRC[4]))
		end
	end
	if MenuBrand.drawConfig.DQL and ValidTarget(Cel, Q.range) and not GetMinionCollision(myHero, Cel, Q.width) then
		QMark = Cel
		DrawLine3D(myHero.x, myHero.y, myHero.z, QMark.x, QMark.y, QMark.z, Q.width, ARGB(MenuBrand.drawConfig.DQLC[1], MenuBrand.drawConfig.DQLC[2], MenuBrand.drawConfig.DQLC[3], MenuBrand.drawConfig.DQLC[4]))
	end
	if MenuBrand.drawConfig.DD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
			DmgCalc()
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuBrand.drawConfig.DQR and QReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuBrand.drawConfig.DQRC[2], MenuBrand.drawConfig.DQRC[3], MenuBrand.drawConfig.DQRC[4]))
	end
	if MenuBrand.drawConfig.DWR and WReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuBrand.drawConfig.DWRC[2], MenuBrand.drawConfig.DWRC[3], MenuBrand.drawConfig.DWRC[4]))
	end
	if MenuBrand.drawConfig.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuBrand.drawConfig.DERC[2], MenuBrand.drawConfig.DERC[3], MenuBrand.drawConfig.DERC[4]))
	end
	if MenuBrand.drawConfig.DRR and RReady then				
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuBrand.drawConfig.DRRC[2], MenuBrand.drawConfig.DRRC[3], MenuBrand.drawConfig.DRRC[4]))
	end
end

function KillSteall()
	for _,Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero,1)
		if TargetHaveBuff("brandablaze", Enemy) then
			wDmg = getDmg("W", Enemy, myHero,3)
		else
			wDmg = getDmg("W", Enemy, myHero,1)
		end
		local eDmg = getDmg("E", Enemy, myHero,1)
		local rDmg = getDmg("R", Enemy, myHero,3)
		local iDmg = (50 + (20 * myHero.level))
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health <= qDmg and QReady and GetDistance(Enemy) - getHitBoxRadius(Enemy)/2 < Q.range and MenuBrand.ksConfig.QKS then
				CastQ(Enemy)
			elseif health < wDmg and WReady and GetDistance(Enemy) < W.range and MenuBrand.ksConfig.WKS then
				CastW(Enemy)
			elseif health < eDmg and EReady and GetDistance(Enemy) < E.range and MenuBrand.ksConfig.EKS then
				CastSpell(_E, Enemy)
			elseif health < rDmg and RReady and GetDistance(Enemy) <= R.range and MenuBrand.ksConfig.RKS then
				CastSpell(_R, Enemy)
			elseif health < (qDmg + wDmg) and QReady and WReady and GetDistance(Enemy) < W.range and MenuBrand.ksConfig.QKS and MenuBrand.ksConfig.WKS then
				CastQ(Enemy)
				CastW(Enemy)
			elseif health < (qDmg + rDmg) and QReady and RReady and GetDistance(Enemy) < R.range and MenuBrand.ksConfig.QKS and MenuBrand.ksConfig.RKS then
				CastQ(Enemy)
				CastSpell(_R, Enemy)
			elseif health < (wDmg + rDmg) and WReady and RReady and GetDistance(Enemy) <= R.range and MenuBrand.ksConfig.WKS and MenuBrand.ksConfig.RKS then
				CastW(Enemy)
				CastSpell(_R, Enemy)
			elseif health < (qDmg + wDmg + rDmg) and QReady and WReady and RReady and GetDistance(Enemy) <= R.range and MenuBrand.ksConfig.QKS and MenuBrand.ksConfig.WKS and MenuBrand.ksConfig.RKS then
				CastQ(Enemy)
				CastW(Enemy)
				CastSpell(_R, Enemy)
			end
			if IReady and health <= iDmg and MenuBrand.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end

function DmgCalc()
	for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local qDmg = getDmg("Q", enemy, myHero,1)
			if TargetHaveBuff("brandablaze", enemy) then
				wDmg = getDmg("W", enemy, myHero,3)
			else
				wDmg = getDmg("W", enemy, myHero,1)
			end
			local eDmg = getDmg("E", enemy, myHero,1)
			local rDmg = getDmg("R", enemy, myHero,3)
            if enemy.health > (qDmg + wDmg + rDmg) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < qDmg then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < wDmg then
				killstring[enemy.networkID] = "W Kill!"
			elseif enemy.health < eDmg then
				killstring[enemy.networkID] = "E Kill!"
            elseif enemy.health < rDmg then
				killstring[enemy.networkID] = "R Kill!"
            elseif enemy.health < (qDmg + wDmg) then
                killstring[enemy.networkID] = "Q+W Kill!"
			elseif enemy.health < (qDmg + eDmg) then
                killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (qDmg + rDmg) then
                killstring[enemy.networkID] = "Q+R Kill!"	
			elseif enemy.health < (wDmg + eDmg) then
                killstring[enemy.networkID] = "W+E Kill!"	
			elseif enemy.health < (wDmg + rDmg) then
                killstring[enemy.networkID] = "W+R Kill!"	
			elseif enemy.health < (qDmg + wDmg + eDmg + rDmg) then
                killstring[enemy.networkID] = "Q+W+E+R Kill!"	
            end
        end
    end
end

function SpellCast(spellSlot,castPosition)
	if VIP_USER and MenuBrand.prConfig.pc then
		Packet("S_CAST", {spellId = spellSlot, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
	else
		CastSpell(spellSlot,castPosition.x,castPosition.z)
	end
end

function CastQ(unit)
	if MenuBrand.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, myHero, true)
		if HitChance >= MenuBrand.prConfig.vphit - 1 then
			SpellCast(_Q, CastPosition)
		end
	end
	if MenuBrand.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, Q.range-30, Q.speed, Q.delay, Q.width, myHero)
		if Position ~= nil and not info.mCollision() then
			SpellCast(_Q, Position)	
		end
	end
end

function CastW(unit)
	if MenuBrand.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetPredictedPos(unit, W.delay, W.speed, myHero, false)
		if Position and HitChance >= MenuBrand.prConfig.vphit - 1 then
			SpellCast(_W, Position)
		end
	end
	if MenuBrand.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, W.range, W.speed, W.delay, W.width, myHero)
		if Position ~= nil then
			SpellCast(_W, Position)
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
	if Msg == WM_LBUTTONDOWN and MenuBrand.comboConfig.ST then
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
				if MenuBrand.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuBrand.comboConfig.ST then 
					print("New target selected: "..Selecttarget.charName) 
				end
			end
		end
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("PCFDDJCEJCB") 
