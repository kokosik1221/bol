if myHero.charName ~= "Galio" then return end

require 'VPrediction'

if VIP_USER then
	require "Prodiction"
end

function Menu()
	MenuGalio = AutoCarry.PluginMenu
	MenuGalio:addSubMenu("Combo Settings", "comboConfig")
    MenuGalio.comboConfig:addParam("USEQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
    MenuGalio.comboConfig:addParam("USEW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("USEE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("USER", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("ENEMYTOR", "Min Enemies to Cast R: ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuGalio:addSubMenu("KS Settings" , "ksConfig")
    MenuGalio.ksConfig:addParam("IGN", "KS Ignite", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("KSQ", "KS Q", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("KSE", "KS E", SCRIPT_PARAM_ONOFF, true)
    MenuGalio.ksConfig:addParam("KSULT", "KS R", SCRIPT_PARAM_ONOFF, true)
	MenuGalio:addSubMenu("Harras Settings", "harrasConfig")
    MenuGalio.harrasConfig:addParam("HQ", "Harras enemy Q", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("X"))
	MenuGalio.harrasConfig:addParam("MINMPTOQ", "Min % MP To Harras Q", SCRIPT_PARAM_SLICE, 70, 0, 100, 2)	
	MenuGalio.harrasConfig:addParam("HE", "Harras enemy E", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("Z"))
	MenuGalio.harrasConfig:addParam("MINMPTOE", "Min % MP To Harras W", SCRIPT_PARAM_SLICE, 70, 0, 100, 2)
	MenuGalio.harrasConfig:permaShow("HQ")
	MenuGalio.harrasConfig:permaShow("HE")
	MenuGalio:addSubMenu("Farm Settings", "farmConfig")
    MenuGalio.farmConfig:addParam("FQ", "Farm Q", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.farmConfig:addParam("MINMPTOFQ", "Min % MP To Farm Q", SCRIPT_PARAM_SLICE, 70, 0, 100, 2)	
	MenuGalio.farmConfig:addParam("FE", "Farm E", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.farmConfig:addParam("MINMPTOFE", "Min % MP To Farm W", SCRIPT_PARAM_SLICE, 70, 0, 100, 2)
	MenuGalio.farmConfig:permaShow("FQ")
	MenuGalio.farmConfig:permaShow("FE")
	MenuGalio:addSubMenu("Drawing Settings", "drawConfig")
	MenuGalio.drawConfig:addParam("DQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.drawConfig:addParam("DR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	
end

function Variables()
	VP = VPrediction()
	IgniteKey = nil;
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		IgniteKey = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		IgniteKey = SUMMONER_2
	else
		IgniteKey = nil
	end
	-- Q --
	qRange = 940
	qDelay = 240
	qSpeed = 1400
	qWidth = 235
	-- W --
	wRange = 800
	-- E --
	eRange = 1180
	eDelay = 240
	eSpeed = 1400
	eWidth = 235
	-- R --
	rRange = 560
	AutoCarry.SkillsCrosshair.range = 1180
end

function PluginOnLoad()
	Menu()
	Variables()
end

function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = ((myHero:CanUseSpell(_R) ~= NOTLEARNED) and (myHero:CanUseSpell(_R) ~= COOLDOWN))
	IReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

	if AutoCarry.MainMenu.AutoCarry and Target ~= nil then
		if MenuGalio.comboConfig.USEQ then
			CastQ()
		end
		if MenuGalio.comboConfig.USEW then
			CastW()
		end
		if MenuGalio.comboConfig.USEE then
			CastE()
		end
		if MenuGalio.comboConfig.USER then
			CastR()
		end
	end
	
	if MenuGalio.ksConfig.KSQ and QReady then
		KsQ()
	end
	
	if MenuGalio.ksConfig.KSE and EReady then
		KsE()
	end
	
	if MenuGalio.ksConfig.KSULT and RReady then
		KsULT()
	end
	
	if MenuGalio.ksConfig.KSIGNITE and IgniteKey ~= nil then
		KsIG()
	end
	
	if MenuGalio.harrasConfig.HQ and QReady and ((myHero.mana/myHero.maxMana)*100) > MenuGalio.harrasConfig.MINMPTOQ then
		HarrasQ()
	end
	
	if MenuGalio.harrasConfig.HE and EReady and ((myHero.mana/myHero.maxMana)*100) > MenuGalio.harrasConfig.MINMPTOE then
		HarrasE()
	end
	
	if MenuGalio.farmConfig.FQ and QReady and ((myHero.mana/myHero.maxMana)*100) > MenuGalio.farmConfig.MINMPTOFQ then
		FarmQ()
	end
	
	if MenuGalio.farmConfig.FE and EReady and ((myHero.mana/myHero.maxMana)*100) > MenuGalio.farmConfig.MINMPTOFE then
		FarmE()
	end
end

function KsQ()
	players = heroManager.iCount
	for i = 1, players, 1 do
        target = heroManager:getHero(i)
		qDmg = getDmg("Q", myHero, target)
        if target ~= nil and target.team ~= player.team and not target.dead then
            if QReady and qDmg > target.health then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, qDelay, qWidth, qRange, qSpeed, myHero, false)
				if HitChance >= 2 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
					return
				end
            end
        end
    end
end

function KsE()
	players = heroManager.iCount
	for i = 1, players, 1 do
        target = heroManager:getHero(i)
		eDmg = getDmg("E", myHero, target)
        if target ~= nil and target.team ~= player.team and not target.dead then
            if EReady and eDmg > target.health then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, eDelay, eWidth, eRange, eSpeed, myHero, false)
				if CastPosition and not target.canMove and HitChance >= 2 then
					CastSpell(_E, CastPosition.x, CastPosition.z)
					return
				end
            end
        end
    end
end

function KsULT()
	players = heroManager.iCount
	for i = 1, players, 1 do
        target = heroManager:getHero(i)
		rDmg = getDmg("R", myHero, target)
        if target ~= nil and target.team ~= player.team and not target.dead then
            if RReady and rDmg > target.health then
				CastSpell(_R)
            end
        end
    end
end

function KsIG()
	players = heroManager.iCount
	for i = 1, players, 1 do
        target = heroManager:getHero(i)
		iDmg = getDmg("IGNITE", myHero, Target)
        if target ~= nil and target.team ~= player.team and not target.dead then
            if IReady and iDmg > target.health then
				CastSpell(IgniteKey, target)
            end
        end
    end
end

function HarrasQ()
	players = heroManager.iCount
	for i = 1, players, 1 do
        target = heroManager:getHero(i)
        if target ~= nil and target.team ~= player.team and not target.dead then
			local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, qDelay, qWidth, qRange, qSpeed, myHero, false)
			if HitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
				return
			end
        end
    end
end

function HarrasE()
	players = heroManager.iCount
	for i = 1, players, 1 do
		target = heroManager:getHero(i)
		if target ~= nil and target.team ~= player.team and not target.dead then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, eDelay, eWidth, eRange, eSpeed, myHero, false)
			if CastPosition and HitChance >= 2 then
				CastSpell(_E, CastPosition.x, CastPosition.z)
				return
			end
		end
	end
end

function CastQ()
	if QReady and MenuGalio.comboConfig.USEQ then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(Target, qDelay, qWidth, qRange, qSpeed, myHero, false)
		if HitChance >= 2 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
			return
		end
	end
end		

function CastE()
	if EReady and MenuGalio.comboConfig.USEE then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, eDelay, eWidth, eRange, eSpeed, myHero, false)
		if CastPosition and HitChance >= 2 then
			CastSpell(_E, CastPosition.x, CastPosition.z)
			return
		end
	end
end

function CastW()
	if WReady and MenuGalio.comboConfig.USEW and GetDistance(Target) <= qRange then
		CastSpell(_W)
	end
end

function CastR()
	local enemyCount = EnemyCount(myHero, rRange)
	if RReady and MenuGalio.comboConfig.USER and enemyCount >= MenuGalio.comboConfig.ENEMYTOR then
		CastSpell(_R)
	end
end

function FarmQ()
	for index, minion in pairs(minionManager(MINION_ENEMY, qRange, player, MINION_SORT_HEALTH_ASC).objects) do
        local qDmg = getDmg("Q",minion,  GetMyHero())
        local MinionHealth_ = minion.health
        if qDmg >= MinionHealth_ then
            CastSpell(_Q, minion)
        end
    end
end

function FarmE()
	for index, minionn in pairs(minionManager(MINION_ENEMY, eRange, player, MINION_SORT_HEALTH_ASC).objects) do
        local eDmg = getDmg("E",minionn,  GetMyHero())
        local MinionHealth_ = minionn.health
        if eDmg >= MinionHealth_ then
            CastSpell(_E, minionn)		
        end
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

function PluginOnDraw()
	if MenuGalio.drawConfig.DQ and QReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, ARGB(255,0,0,255))
	end
	if MenuGalio.drawConfig.DW and WReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, wRange, ARGB(255,100,0,255))
	end
	if MenuGalio.drawConfig.DE and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, eRange, ARGB(255,255,0,0))
	end
	if MenuGalio.drawConfig.DR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, rRange, ARGB(255,0,255,0))
	end
end





