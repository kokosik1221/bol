--[[

	Script Name: GANKGPLANK MASTER 
    	Author: kokosik1221
	Last Version: 1.7
	31.10.2014
	
]]--

if myHero.charName ~= "Gangplank" then return end

local AUTOUPDATE = true


local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local SCRIPT_NAME = "GangplankMaster"
local version = 1.7
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
RequireI:Check()
if RequireI.downloadNeeded == true then return end

local skills = {
	skillQ = {range = 625},
	skillW = {range = 0},
	skillE = {range = 1300},
	skillR = {range = 99000},
}

local Items = {
	BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
	STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
	TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
	YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
	RND = { id = 3143, range = 275, reqTarget = false, slot = nil },
}

local QReady, WReady, EReady, RReady, IReady, Recall, sac, mma = false, false, false, false, false, false, false, false
local abilitylvl, lastskin = 0, 0
local EnemyMinions = minionManager(MINION_ENEMY, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey = nil
local killstring = {}
		
function OnLoad()
	print("<b><font color=\"#6699FF\">Gangplank Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	Menu()
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Gangplank Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
		mma = true
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Gangplank Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
		sac = true
	end
end

function OnCreateObj(object)
	if object.name:find("TeleportHome") then
		Recall = true
	end
end
 
function OnDeleteObj(object)
	if object.name:find("TeleportHome") or (Recall == nil and object.name == Recall.name) then
		Recall = false
	end
end

function skinChanged()
	return MenuGP.prConfig.skin1 ~= lastSkin
end

function OnTick()
	Check()
	if Cel ~= nil and MenuGP.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGP.comboConfig.manac then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuGP.harrasConfig.HEnabled or MenuGP.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuGP.harrasConfig.manah then
		Harrass()
	end
	if MenuGP.farm.Freeze or MenuGP.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuGP.farm.manaf then
		local Mode = MenuGP.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
	end
	if MenuGP.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGP.jf.manajf then
		JungleFarmm()
	end
	if MenuGP.prConfig.ALS then
		autolvl()
	end
	if MenuGP.exConfig.cc then
		cc()
	end
	if MenuGP.exConfig.aw then
		autow()
	end
	if QReady and MenuGP.farm.LQ then
		lq()
	end
	KillSteall()
end

function Menu()
	VP = VPrediction()
	SOWi = SOW(VP)
	MenuGP = scriptConfig("Gangplank Master "..version, "Gangplank Master "..version)
	MenuGP:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuGP.Orbwalking)
	MenuGP:addSubMenu("Target selector", "STS")
    TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, skills.skillQ.range, DAMAGE_PHYSICAL)
	TargetSelector.name = "Gangplank"
	MenuGP.STS:addTS(TargetSelector)
	MenuGP:addSubMenu("[Gangplank Master]: Combo Settings", "comboConfig")
	MenuGP.comboConfig:addParam("USEQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("USEW", "Use W in Combo", SCRIPT_PARAM_ONOFF, false)
	MenuGP.comboConfig:addParam("USEE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("EC", "Min Team Count To Cast E", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuGP.comboConfig:addParam("USER", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuGP.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuGP:addSubMenu("[Gangplank Master]: Harras Settings", "harrasConfig")
    MenuGP.harrasConfig:addParam("QH", "Harras Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuGP.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuGP.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuGP.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuGP:addSubMenu("[Gangplank Master]: KS Settings", "ksConfig")
	MenuGP.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGP.ksConfig:addParam("QKS", "Use Q To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGP.ksConfig:addParam("RKS", "Use R To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGP.ksConfig:addParam("ULTHITS", "Ult hit times:", SCRIPT_PARAM_SLICE, 2, 1, 7, 0)
	MenuGP:addSubMenu("[Gangplank Master]: Farm Settings", "farm")
	MenuGP.farm:addParam("LQ", "Last Hit Minions With Q", SCRIPT_PARAM_ONOFF, true)
	MenuGP.farm:addParam("QF", "Use Q Farm", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuGP.farm:addParam("EF",  "Use E Farm", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuGP.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
	MenuGP.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuGP.farm:addParam("manac", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGP:addSubMenu("[Gangplank Master]: Jungle Farm Settings", "jf")
	MenuGP.jf:addParam("QJF", "Jungle Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuGP.jf:addParam("EJF", "Jungle Farm Use E", SCRIPT_PARAM_ONOFF, true)
	MenuGP.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	MenuGP.jf:addParam("manac", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGP:addSubMenu("[Gangplank Master]: Extra Settings", "exConfig")
	MenuGP.exConfig:addParam("CC", "Anty CC", SCRIPT_PARAM_ONOFF, true)
	MenuGP.exConfig:addParam("aw", "Auto Heal", SCRIPT_PARAM_ONOFF, true)
	MenuGP.exConfig:addParam("MINHPTOW", "Min % HP To Heal", SCRIPT_PARAM_SLICE, 60, 0, 100, 2)
	MenuGP.exConfig:addParam("MINMPTOW", "Min % MP To Heal", SCRIPT_PARAM_SLICE, 70, 0, 100, 2)	
	MenuGP:addSubMenu("[Gangplank Master]: Draw Settings", "drawConfig")
	MenuGP.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuGP.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuGP:addSubMenu("[Gangplank Master]: Misc Settings", "prConfig")
	MenuGP.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuGP.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuGP.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 7, 1, 7)
	MenuGP.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuGP.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	if MenuGP.prConfig.skin and VIP_USER then
		GenModelPacket("Gangplank", MenuGP.prConfig.skin1)
		lastSkin = MenuGP.prConfig.skin1
	end
	MenuGP.comboConfig:permaShow("CEnabled")
	MenuGP.harrasConfig:permaShow("HEnabled")
	MenuGP.harrasConfig:permaShow("HTEnabled")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end

function caa()
	if MenuGP.comboConfig.uaa then
		SOWi:EnableAttacks()
	elseif not MenuGP.comboConfig.uaa then
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
	else
		SOWi.Menu.Enabled = true
	end
	SOWi:ForceTarget(Cel)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if MenuGP.prConfig.skin and VIP_USER and skinChanged() then
		GenModelPacket("Gangplank", MenuGP.prConfig.skin1)
		lastSkin = MenuGP.prConfig.skin1
	end
	if MenuGP.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
end

function CountTeam(point, range)
    local ChampCount = 0
    for j = 1, heroManager.iCount, 1 do
        local enemyhero = heroManager:getHero(j)
		if myHero.team == enemyhero.team and ValidTarget(enemyhero, skills.skillE.range) then
            if GetDistance(enemyhero, point) <= range then
                 ChampCount = ChampCount + 1
            end
        end
    end            
    return ChampCount
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
	if MenuGP.comboConfig.USEQ then
		if QReady and ValidTarget(Cel) then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = Cel.networkID}):send()
			else
				CastSpell(_Q, Cel)
			end
		end
	end
	if MenuGP.comboConfig.USEW then
		if WReady and MenuGP.comboConfig.USEW then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
	end
	if MenuGP.comboConfig.USEE then
		local enemyCount = CountTeam(myHero, skills.skillE.range)
		if EReady and MenuGP.comboConfig.USEE and enemyCount >= MenuGP.comboConfig.EC then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _E}):send()
			else
				CastSpell(_E)
			end
		end
	end
	if MenuGP.comboConfig.USER then
		if RReady and GetDistance(CelR) < skills.skillR.range and MenuGP.comboConfig.USER then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _R, targetNetworkId = CelR.networkID}):send()
			else
				CastSpell(_R, CelR)
			end
		end
	end
end

function Harrass()
	if MenuGP.harrasConfig.QH then
		if QReady and GetDistance(Cel) <= skills.skillQ.range and Cel ~= nil and Cel.team ~= player.team and not Cel.dead then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = Cel.networkID}):send()
			else
				CastSpell(_Q, Cel)
			end
		end
	end
end

function Farm(Mode)
	local UseQ
	local UseE
	if not SOWi:CanMove() then return end

	EnemyMinions:update()
	if Mode == "Freeze" then
		UseQ =  MenuGP.farm.QF == 2
		UseE =  MenuGP.farm.EF == 2 
	elseif Mode == "LaneClear" then
		UseQ =  MenuGP.farm.QF == 3
		UseE =  MenuGP.farm.EF == 3
	end
	
	UseQ =  MenuGP.farm.QF == 4 or UseQ
	UseE =  MenuGP.farm.EF == 4 or UseE
	
	if UseQ then
		for i, minion in pairs(EnemyMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range then
				if VIP_USER and MenuGP.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, targetNetworkId = minion.networkID}):send()
				else
					CastSpell(_Q, minion)
				end
			end
		end
	end
	if UseE then
		for i, minion in pairs(EnemyMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range then
				if VIP_USER and MenuGP.prConfig.pc then
					Packet("S_CAST", {spellId = _E}):send()
				else
					CastSpell(_E)
				end
			end
		end
	end
end

function JungleFarmm()
	JungleMinions:update()
	if MenuGP.jf.QJF then
		for i, minion in pairs(JungleMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range then
				if VIP_USER and MenuGP.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, targetNetworkId = minion.networkID}):send()
				else
					CastSpell(_Q, minion)
				end
			end
		end
	end
	if MenuGP.jf.EJF then
		for i, minion in pairs(JungleMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range then
				if VIP_USER and MenuGP.prConfig.pc then
					Packet("S_CAST", {spellId = _E}):send()
				else
					CastSpell(_E)
				end
			end
		end
	end
end

function autow()
	if MenuGP.exConfig.aw and not Recall and WReady then
		if ((myHero.mana/myHero.maxMana)*100) > MenuGP.exConfig.MINMPTOW and  ((myHero.health/myHero.maxHealth)*100) < MenuGP.exConfig.MINHPTOW then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
	end
end

function lq()
	for i, minion in pairs(EnemyMinions.objects) do
        local qDmg = getDmg("Q",minion,  GetMyHero()) + getDmg("AD",minion,  GetMyHero())
		local MinionHealth_ = minion.health
        if qDmg >= MinionHealth_ then
            CastSpell(_Q, minion)
        end
    end
end

function cc()
	if MenuGP.exConfig.CC and WReady then
		myPlayer = GetMyHero()
		if myPlayer.canMove == false then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
		if myPlayer.isTaunted == true then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
		if myPlayer.isFleeing == true then
			if VIP_USER and MenuGP.prConfig.pc then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
	end
end

function autolvl()
	if not MenuGP.prConfig.ALS then return end
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuGP.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuGP.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuGP.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuGP.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuGP.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuGP.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end

function OnDraw()
	if MenuGP.drawConfig.DD then	
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuGP.drawConfig.DQR and QReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, RGB(MenuGP.drawConfig.DQRC[2], MenuGP.drawConfig.DQRC[3], MenuGP.drawConfig.DQRC[4]))
	end
	if MenuGP.drawConfig.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, RGB(MenuGP.drawConfig.DERC[2], MenuGP.drawConfig.DERC[3], MenuGP.drawConfig.DERC[4]))
	end
end

function KillSteall()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		local health = Enemy.health
		local distance = GetDistance(Enemy)
		if MenuGP.ksConfig.QKS then
			qDmg = getDmg("Q", Enemy, myHero) + (myHero.damage)
		else 
			qDmg = 0
		end
		if MenuGP.ksConfig.RKS then
			rDmg = getDmg("R", Enemy, myHero) * MenuGP.ksConfig.ULTHITS + (myHero.ap * 0.2)
		else 
			rDmg = 0
		end
		if MenuGP.ksConfig.IKS then
			iDmg = getDmg("IGNITE", Enemy, myHero)
		else 
			iDmg = 0
		end
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health <= qDmg and QReady and (distance < skills.skillQ.range) and MenuGP.ksConfig.QKS then
				if VIP_USER and MenuGP.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, targetNetworkId = Enemy.networkID}):send()
				else
					CastSpell(_Q, Enemy)
				end
			elseif health < rDmg and RReady and (distance < skills.skillR.range) and MenuGP.ksConfig.RKS then
				if VIP_USER and MenuGP.prConfig.pc then
					Packet("S_CAST", {spellId = _R, targetNetworkId = Enemy.networkID}):send()
				else
					CastSpell(_R, Enemy)
				end
			elseif health < (qDmg + rDmg) and QReady and RReady and (distance < skills.skillQ.range) and MenuGP.ksConfig.QKS and MenuGP.ksConfig.RKS then
				if VIP_USER and MenuGP.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, targetNetworkId = Enemy.networkID}):send()
				else
					CastSpell(_Q, Enemy)
				end
				if VIP_USER and MenuGP.prConfig.pc then
					Packet("S_CAST", {spellId = _R, targetNetworkId = Enemy.networkID}):send()
				else
					CastSpell(_R, Enemy)
				end
			end
			if IReady and health <= iDmg and MenuGP.ksConfig.IKS and distance < 600 then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end

function DmgCalc()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible then
            local qDmg = getDmg("Q", enemy, myHero) + getDmg("AD", enemy, GetMyHero())
			local rDmg = getDmg("R", enemy, myHero) * MenuGP.ksConfig.ULTHITS + (myHero.ap * 0.2)
            if enemy.health > (qDmg + rDmg) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < qDmg then
				killstring[enemy.networkID] = "Q Kill!"
            elseif enemy.health < rDmg then
				killstring[enemy.networkID] = "R Kill!"
			elseif enemy.health < (qDmg + rDmg) then
                killstring[enemy.networkID] = "Q+R Kill!"	
            end
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
