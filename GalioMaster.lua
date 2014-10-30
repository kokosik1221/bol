--[[

	Script Name: GALIO MASTER 
	Author: kokosik1221
	Last Version: 1.67
	30.10.2014
	
]]--

if myHero.charName ~= "Galio" then return end

local AUTOUPDATE = true


--AUTO UPDATE--
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local prodstatus = false
local SCRIPT_NAME = "GalioMaster"
local version = 1.67
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
RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
if VIP_USER then
	RequireI:Add("Prodiction", "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua")
	prodstatus = true
end
RequireI:Check()
if RequireI.downloadNeeded == true then return end

local skills = {
	skillQ = {range = 940, speed = 1400, delay = 0.25, width = 235},
	skillW = {range = 800},
	skillE = {range = 1180, speed = 1400, delay = 0.25, width = 235},
	skillR = {range = 560},
}
local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}
local QReady, WReady, EReady, RReady, IReady, zhonyaready, ultbuff = false, false, false, false, false, false, false
local abilitylvl, lastskin, lasttickchecked, lasthealthchecked = 0, 0, 0, 0
local EnemyMinions = minionManager(MINION_ENEMY, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, zhonyaslot = nil, nil
local killstring = {}
		
function OnLoad()
	print("<b><font color=\"#6699FF\">Galio Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	Menu()
end

function skinChanged()
	return MenuGalio.prConfig.skin1 ~= lastSkin
end

function CheckUlt()
    if TargetHaveBuff("GalioIdolOfDurand", myHero) then
         ultbuff = true
		 SOWi.Menu.Enabled = false
    else
         ultbuff = false
		 SOWi.Menu.Enabled = true
    end
end

function OnTick()
	Check()
	CheckUlt()
	if Cel ~= nil and MenuGalio.comboConfig.CEnabled and not ultbuff and ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.comboConfig.manac then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuGalio.harrasConfig.HEnabled or MenuGalio.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.harrasConfig.manah then
		Harrass()
	end
	if MenuGalio.farm.Freeze or MenuGalio.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.farm.manaf then
		local Mode = MenuGalio.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
	end
	if MenuGalio.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.jf.manajf then
		JungleFarmm()
	end
	if MenuGalio.exConfig.AZ then
		autozh()
	end
	if MenuGalio.prConfig.ALS then
		autolvl()
	end
	if MenuGalio.esConfig.ESEnabled then
		escape()
	end
	KillSteall()
end

function Menu()
	VP = VPrediction()
	SOWi = SOW(VP)
	MenuGalio = scriptConfig("Galio Master "..version, "Galio Master "..version)
	MenuGalio:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuGalio.Orbwalking)
	MenuGalio:addSubMenu("Target selector", "STS")
    TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, skills.skillE.range, DAMAGE_MAGIC)
	TargetSelector.name = "Fizz"
	MenuGalio.STS:addTS(TargetSelector)
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
	MenuGalio.farm:addParam("QF", "Use Q", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuGalio.farm:addParam("EF",  "Use E", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuGalio.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
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
	MenuGalio.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuGalio.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 5, 1, 5)
	MenuGalio.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuGalio.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuGalio.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuGalio.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuGalio.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuGalio.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	if MenuGalio.prConfig.skin and VIP_USER then
		GenModelPacket("Galio", MenuGalio.prConfig.skin1)
		lastSkin = MenuGalio.prConfig.skin1
	end
	MenuGalio.comboConfig:permaShow("CEnabled")
	MenuGalio.harrasConfig:permaShow("HEnabled")
	MenuGalio.harrasConfig:permaShow("HTEnabled")
	MenuGalio.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end

function caa()
	if MenuGalio.comboConfig.uaa then
		SOWi:EnableAttacks()
	elseif not MenuGalio.comboConfig.uaa then
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
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if MenuGalio.prConfig.skin and VIP_USER and skinChanged() then
		GenModelPacket("Galio", MenuGalio.prConfig.skin1)
		lastSkin = MenuGalio.prConfig.skin1
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
	UseItems(Cel)
	if MenuGalio.comboConfig.USEQ then
		if QReady and MenuGalio.comboConfig.USEQ and GetDistance(Cel) < skills.skillQ.range then
			CastQ(Cel)
		end
	end
	if MenuGalio.comboConfig.USEW then
		if WReady and MenuGalio.comboConfig.USEW and GetDistance(Cel) <= skills.skillW.range then
			if MenuGalio.comboConfig.USEWDMG then
				if lasthealthchecked > myHero.health then
					CastSpell(_W)
				end
			else
				CastSpell(_W)
			end
		end
	end
	if MenuGalio.comboConfig.USEE then
		if EReady and MenuGalio.comboConfig.USEE and GetDistance(Cel) < skills.skillE.range then
			CastE(Cel)
		end
	end
	if MenuGalio.comboConfig.USER then
		local enemyCount = EnemyCount(myHero, skills.skillR.range)
		if not ultbuff and RReady and GetDistance(Cel) < skills.skillR.range and MenuGalio.comboConfig.USER and enemyCount >= MenuGalio.comboConfig.ENEMYTOR then
			SOWi.Menu.Enabled = false
			CastSpell(_R)
		end
	end
end

function Harrass()
	if MenuGalio.harrasConfig.QH then
		if QReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and GetDistance(Cel) < skills.skillQ.range and Cel.visible then
			CastQ(Cel)
		end
	end
	if MenuGalio.harrasConfig.EH then
		if EReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and GetDistance(Cel) < skills.skillE.range and Cel.visible then
			CastE(Cel)
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

function Farm(Mode)
	local UseQ
	local UseE
	if not SOWi:CanMove() then return end

	EnemyMinions:update()
	if Mode == "Freeze" then
		UseQ =  MenuGalio.farm.QF == 2
		UseE =  MenuGalio.farm.EF == 2 
	elseif Mode == "LaneClear" then
		UseQ =  MenuGalio.farm.QF == 3
		UseE =  MenuGalio.farm.EF == 3 
	end
	
	UseQ =  MenuGalio.farm.QF == 4 or UseQ
	UseE =  MenuGalio.farm.EF == 4  or UseE
	
	if UseQ then
		for i, minion in pairs(EnemyMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range then
				local Pos, Hit = BestQFarmPos(skills.skillQ.range, skills.skillQ.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		end
	end

	if UseE then
		for i, minion in pairs(EnemyMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range then
				local Pos, Hit = BestQFarmPos(skills.skillE.range, skills.skillE.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_E, Pos.x, Pos.z)
				end
			end
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

function JungleFarmm()
	if MenuGalio.jf.QJF then
		for i, minion in pairs(JungleMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range then
				CastQ(minion)
			end
		end
	end
	if MenuGalio.jf.EJF then
		for i, minion in pairs(JungleMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range then
				CastE(minion)
			end
		end
	end
end

function KillSteall()
if not ultbuff then 
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		local health = Enemy.health
		local distance = GetDistance(Enemy)
		if MenuGalio.ksConfig.IKS then
			iDmg = getDmg("IGNITE", Enemy, myHero)
		else 
			iDmg = 0
		end
		if MenuGalio.ksConfig.QKS then
			qDmg = getDmg("Q", Enemy, myHero)
		else 
			qDmg = 0
		end
		if MenuGalio.ksConfig.EKS then
			eDmg = getDmg("E", Enemy, myHero)
		else 
			eDmg = 0
		end
		if MenuGalio.ksConfig.RKS then
			rDmg = getDmg("R", Enemy, myHero)
		else 
			rDmg = 0
		end
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health < qDmg and QReady and (distance < skills.skillQ.range) and MenuGalio.ksConfig.QKS then
				CastQ(Enemy)
			elseif health < eDmg and EReady and (distance < skills.skillE.range) and MenuGalio.ksConfig.EKS then
				CastE(Enemy)
			elseif health < rDmg and RReady and (distance < skills.skillR.range) and MenuGalio.ksConfig.RKS then
				CastSpell(_R)
			elseif health < (qDmg + eDmg) and QReady and EReady and (distance < skills.skillQ.range) and MenuGalio.ksConfig.EKS and MenuGalio.ksConfig.QKS then
				CastQ(Enemy)
				CastE(Enemy)
			elseif health < (qDmg + rDmg) and QReady and RReady and (distance < skills.skillR.range) and MenuGalio.ksConfig.RKS and MenuGalio.ksConfig.QKS then
				CastQ(Enemy)
				CastSpell(_R)
			elseif health < (eDmg + rDmg) and EReady and RReady and (distance < skills.skillR.range) and MenuGalio.ksConfig.EKS and MenuGalio.ksConfig.RKS then
				CastE(Enemy)
				CastSpell(_R)
			elseif health < (qDmg + eDmg + rDmg) and QReady and EReady and RReady and (distance < skills.skillR.range) and MenuGalio.ksConfig.RKS and MenuGalio.ksConfig.QKS and MenuGalio.ksConfig.EKS then
				CastQ(Enemy)
				CastE(Enemy)
				CastSpell(_R)
			end
			if IReady and health <= iDmg and MenuGalio.ksConfig.IKS and (distance < 600) then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end
end

function OnDraw()
	if MenuGalio.drawConfig.DQR and QReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, RGB(MenuGalio.drawConfig.DQRC[2], MenuGalio.drawConfig.DQRC[3], MenuGalio.drawConfig.DQRC[4]))
	end
	if MenuGalio.drawConfig.DWR and WReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillW.range, RGB(MenuGalio.drawConfig.DWRC[2], MenuGalio.drawConfig.DWRC[3], MenuGalio.drawConfig.DWRC[4]))
	end
	if MenuGalio.drawConfig.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, RGB(MenuGalio.drawConfig.DERC[2], MenuGalio.drawConfig.DERC[3], MenuGalio.drawConfig.DERC[4]))
	end
	if MenuGalio.drawConfig.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillR.range, RGB(MenuGalio.drawConfig.DRRC[2], MenuGalio.drawConfig.DRRC[3], MenuGalio.drawConfig.DRRC[4]))
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

function autozh()
	local count = EnemyCount(myHero, MenuGalio.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuGalio.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuGalio.prConfig.ALS then return end
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuGalio.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuGalio.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuGalio.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuGalio.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuGalio.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuGalio.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end

function PluginOnProcessSpell(unit, spell)
    if MenuGalio.exConfig.AR and unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and CanUseSpell(_R) == READY and GetDistance(unit) < skills.skillR.range then
        if spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel" or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp" or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole" or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport" then
            CastSpell(_R, unit)
        end
    end
end

function DmgCalc()
    for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
            local qDmg = getDmg("Q", enemy, myHero)
            local eDmg = getDmg("E", enemy, myHero)
			local rDmg = getDmg("R", enemy, myHero)
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
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, false)
		if HitChance >= MenuGalio.prConfig.vphit - 1 then
			SpellCast(_Q, CastPosition)
		end
	end
	if MenuGalio.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width)
		if Position ~= nil and info.hitchance >= 2 then
			SpellCast(_Q, Position)	
		end
	end
end

function CastE(unit)
	if MenuGalio.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, skills.skillE.delay, skills.skillE.width, skills.skillE.range, skills.skillE.speed, myHero, false)
		if HitChance >= MenuGalio.prConfig.vphit - 1 then
			SpellCast(_E, CastPosition)
		end
	end
	if MenuGalio.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, skills.skillE.range, skills.skillE.speed, skills.skillE.delay, skills.skillE.width)
		if Position ~= nil and info.hitchance >= 2 then
			SpellCast(_E, Position)	
		end
	end
end

-- Change skin function, made by Shalzuth
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
	if Msg == WM_LBUTTONDOWN then
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
