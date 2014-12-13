--[[

	Script Name: BRAND MASTER 
    	Author: kokosik1221
	Last Version: 1.26
	13.12.2014
	
]]--
	
if myHero.charName ~= "Brand" then return end

_G.AUTOUPDATE = true
_G.USESKINHACK = false


local version = 1.26
local SCRIPT_NAME = "BrandMaster"
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
if _G.AUTOUPDATE then
	 SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/kokosik1221/bol/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/kokosik1221/bol/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end
local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
require "AoE_Skillshot_Position"
if VIP_USER then
	RequireI:Add("Prodiction", "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua")
	prodstatus = true
end
RequireI:Check()
if RequireI.downloadNeeded == true then return end


local Q = {name = "Sear", range = 1100, speed = 1600, delay = 0.25, width = 60}
local W = {name = "Pillar of Flame", range = 900, speed = math.huge, delay = 1, width = 240}
local E = {name = "Conflagration", range = 625}
local R = {name = "Pyroclasm", range = 750}
local QReady, WReady, EReady, RReady, IReady, sac, mma = false, false, false, false, false, false, false
local abilitylvl, lastskin = 0, 0
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey = nil
local killstring = {}
local cclist = {'Stun', 'BandageToss', 'CurseoftheSadMummy', 'FlashFrostSpell', 'EnchantedCrystalArrow', 'braumstundebuff', 'caitlynyordletrapdebuff', 'CassiopeiaPetrifyingGaze', 'EliseHumanE', 'GragasBodySlam', 'HeimerdingerE', 'IreliaEquilibriumStrike', 'JaxCounterStrike', 'JinxE', 'karmaspiritbindroot', 'LeonaShieldOfDaybreak', 'LeonaZenithBladeMissle', 'lissandraenemy2', 'LuxLightBindingMis', 'AlZaharNetherGrasp', 'maokaiunstablegrowthroot', 'DarkBindingMissile', 'namiqdebuff', 'Pantheon_LeapBash', 'RenektonPreExecute', 'RengarE', 'RivenMartyr', 'RunePrison', 'sejuaniglacialprison', 'CrypticGaze', 'SonaR', 'swainshadowgrasproot', 'Dazzle', 'TFW', 'udyrbearstuncheck', 'VarusR', 'VeigarStun', 'velkozestun', 'viktorgravitonfieldstun', 'infiniteduresssound', 'XerathMageSpear', 'zyragraspingrootshold', 'zhonyasringshield'}

function OnLoad()
	print("<b><font color=\"#6699FF\">Brand Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	Menu()
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Brand Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
		mma = true
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Brand Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
		sac = true
	end
end

function Havepasive(target)
	return HasBuff(target, "brandablaze")
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
	if MenuBrand.farm.Freeze or MenuBrand.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.farm.manaf then
		local Mode = MenuBrand.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
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
		local wPos = GetAoESpellPosition(W.width, Cel, W.delay)
        if wPos and GetDistance(wPos) <= W.range then
            if EnemyCount(wPos, 450) >= MenuBrand.exConfig.AW2C then
				if VIP_USER and MenuBrand.prConfig.pc then
					Packet("S_CAST", {spellId = _W, fromX = wPos.x, fromY = wPos.z, toX = wPos.x, toY = wPos.z}):send()
				else
					CastSpell(_W, wPos.x, wPos.z)
				end	
            end
        end
	end	
	KillSteall()
end

function Menu()
	VP = VPrediction()
	SOWi = SOW(VP)
	MenuBrand = scriptConfig("Brand Master "..version, "Brand Master "..version)
	MenuBrand:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuBrand.Orbwalking)
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
	MenuBrand.comboConfig.rConfig:addParam("ENEMYTOR", "Min Enemies to Cast R: ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuBrand.comboConfig.rConfig:addParam("Ablazed", "Only Use If Target Is Ablazed", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.comboConfig.rConfig:addParam("Kilable", "Only Use If Target Is Killable", SCRIPT_PARAM_ONOFF, true)
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
	MenuBrand.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuBrand.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuBrand.farm:addParam("EF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuBrand.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
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
	MenuBrand.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
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
	if MenuBrand.comboConfig.uaa then
		SOWi:EnableAttacks()
	elseif not MenuBrand.comboConfig.uaa then
		SOWi:DisableAttacks()
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
	if GetDistanceSqr(Cel) <= E.range then
		if EReady and ValidTarget(Cel, E.range) then
			CastSpell(_E, Cel)
		end
		if WReady then
			CastW(Cel)
		end
		if QReady and GetDistance(Cel) - getHitBoxRadius(Cel)/2 < Q.range then
			if MenuBrand.comboConfig.qConfig.USEQS then
				if TargetHaveBuff("brandablaze", Cel) then
					CastQ(Cel)
				end
			elseif not MenuBrand.comboConfig.qConfig.USEQS then
				CastQ(Cel)
			end
		end
		CastRC()
	else if GetDistanceSqr(Cel) > E.range then
			if WReady then
				CastW(Cel)
			end
			if QReady and GetDistance(Cel) - getHitBoxRadius(Cel)/2 < Q.range then
				if MenuBrand.comboConfig.qConfig.USEQS then
					if TargetHaveBuff("brandablaze", Cel) then
						CastQ(Cel)
					end
				elseif not MenuBrand.comboConfig.qConfig.USEQS then
					CastQ(Cel)
				end
			end
			if EReady and ValidTarget(Cel, E.range) then
				CastSpell(_E, Cel)
			end
			CastRC()
		end
	end
end

function CastRC()
	local enemyCount = EnemyCount(myHero, R.range)
	if RReady and ValidTarget(Cel, R.range) and MenuBrand.comboConfig.rConfig.USER and enemyCount >= MenuBrand.comboConfig.rConfig.ENEMYTOR then
		if MenuBrand.comboConfig.rConfig.Ablazed then
			if Havepasive(Cel) then
				CastSpell(_R, Cel)
			end
		elseif MenuBrand.comboConfig.rConfig.Kilable then
			local rdmg = getDmg("R", Cel, myHero,3)
			if Cel.health < rdmg then
				CastSpell(_R, Cel)
			end
		elseif not MenuBrand.comboConfig.rConfig.Ablazed or not MenuBrand.comboConfig.rConfig.Kilable then
			CastSpell(_R, Cel)
		end
	end
end

function Harrass()
	if MenuBrand.harrasConfig.QH then
		if QReady and GetDistance(Cel) - getHitBoxRadius(Cel)/2 < Q.range and Cel ~= nil then
			if MenuBrand.harrasConfig.QHS then
				if Havepasive(Cel) then
					CastQ(Cel)
				end
			elseif not MenuBrand.harrasConfig.QHS then
				CastQ(Cel)
			end
		end
	end
	if MenuBrand.harrasConfig.WH then
		if WReady and Cel ~= nil then
			CastW(Cel)
		end
	end
	if MenuBrand.harrasConfig.EH then
		if EReady and ValidTarget(Cel, E.range) and Cel ~= nil then
			CastSpell(_E, Cel)
		end
	end
end

function Farm(Mode)
	local UseQ
	local UseW
	local UseE
	if not SOWi:CanMove() then return end

	EnemyMinions:update()
	if Mode == "Freeze" then
		UseQ =  MenuBrand.farm.QF == 2
		UseW =  MenuBrand.farm.WF == 2 
		UseE =  MenuBrand.farm.EF == 2 
	elseif Mode == "LaneClear" then
		UseQ =  MenuBrand.farm.QF == 3
		UseW =  MenuBrand.farm.WF == 3 
		UseE =  MenuBrand.farm.EF == 3
	end
	
	UseQ =  MenuBrand.farm.QF == 4 or UseQ
	UseW =  MenuBrand.farm.WF == 4  or UseW
	UseE =  MenuBrand.farm.EF == 4 or UseE
	
	for i, minion in pairs(EnemyMinions.objects) do
		if UseQ then
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= Q.range then
				CastQ(minion)
			end
		end
		if UseW then
			if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= W.range then
				local Pos, Hit = BestWFarmPos(W.range, W.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
		end
		if UseE then
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= E.range then
				if Havepasive(minion) then
					CastSpell(_E, minion)
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
				if Havepasive(minion) then
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
	players = heroManager.iCount
    for i = 1, players, 1 do
        targetq = heroManager:getHero(i)
        if targetq ~= nil and targetq.team ~= player.team and targetq.visible and not targetq.dead then
            if GetDistance(targetq) - getHitBoxRadius(targetq)/2 < Q.range and WReady and TargetHaveBuff(cclist, targetq) then
                CastQ(targetq)
            end
        end
    end
end

function AutoW()
	players = heroManager.iCount
    for i = 1, players, 1 do
        target = heroManager:getHero(i)
        if target ~= nil and target.team ~= player.team and target.visible and not target.dead then
            if WReady and TargetHaveBuff(cclist, target) then
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
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuBrand.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuBrand.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuBrand.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuBrand.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuBrand.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuBrand.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
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
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero,1)
		if Havepasive(Enemy) then
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
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible then
			local qDmg = getDmg("Q", enemy, myHero,1)
			if Havepasive(enemy) then
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
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, true)
		if HitChance >= MenuBrand.prConfig.vphit - 1 then
			SpellCast(_Q, CastPosition)
		end
	end
	if MenuBrand.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetLineAOEPrediction(unit, Q.range, Q.speed, Q.delay, Q.width)
		if Position ~= nil and not info.mCollision() then
			SpellCast(_Q, Position)	
		end
	end
end

function CastW(unit)
	if GetDistance(unit) <= W.range then
		if MenuBrand.prConfig.pro == 1 then
			local CastPosition,  HitChance,  Position = VP:GetCircularAOECastPosition(unit, W.delay, W.width, W.range, W.speed, myHero)
			if CastPosition and HitChance >= MenuBrand.prConfig.vphit - 1 then
				SpellCast(_W, CastPosition)
			end
		end
		if MenuBrand.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetCircularAOEPrediction(unit, W.range, W.speed, W.delay, W.width, myHero)
			if Position ~= nil then
				SpellCast(_W, Position)
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
