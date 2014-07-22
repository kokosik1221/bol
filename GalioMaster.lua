--[[
	GALIO MASTER KOKOSIK1221

	Changelog:
 
	1.0 - First Relase
	1.1 - Added Use R To Stop Enemy Ultimates
            - Added Auto Zhonya
            - Added Auto Lvl Skills
            - Added Support Prodiction(Not Tested)
        1.2 - fix error with cast ultimate
 

]]--


if myHero.charName ~= "Galio" then return end


if VIP_USER then
	require "Prodiction"
else 
	if not VIP_USER then
		require 'VPrediction'
	end
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
	MenuGalio:addSubMenu("Extra Settings", "exConfig")
	MenuGalio.exConfig:addParam("AR", "Use R To Stop Enemy Ultimates", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.exConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.exConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuGalio.exConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.exConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
end

function Variables()
	IgniteKey = nil;
	zhonyaslot = GetInventorySlotItem(3157)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		IgniteKey = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		IgniteKey = SUMMONER_2
	else
		IgniteKey = nil
	end
	abilitylvl = 0
	skills = {
	skillQ = {range = 940, speed = 1400, delay = 0.25, width = 235},
	skillW = {range = 800},
	skillE = {range = 1180, speed = 1400, delay = 0.25, width = 235},
	skillR = {range = 560},
	}
	AutoCarry.SkillsCrosshair.range = 1180
end

function Loadp()
	if VIP_USER then
		Prod = ProdictManager.GetInstance()
	    ProdQ = Prod:AddProdictionObject(_Q, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width) 
		ProdE = Prod:AddProdictionObject(_E, skills.skillE.range, skills.skillE.speed, skills.skillE.delay, skills.skillE.width) 
	end
	if not VIP_USER then
		VP = VPrediction()
	end
end

function PluginOnLoad()
	Menu()
	Variables()
	Loadp()
end

function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = ((myHero:CanUseSpell(_R) ~= NOTLEARNED) and (myHero:CanUseSpell(_R) ~= COOLDOWN))
	IReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	ZhonyaReady	= (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	autolvl()


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
	if MenuGalio.exConfig.AZ then
		if ZhonyaReady and ((myHero.health/myHero.maxHealth)*100) < MenuGalio.exConfig.AZHP then
			CastSpell(zhonyaslot)
		end
	end
end

function KsQ()
	players = heroManager.iCount
	for i = 1, players, 1 do
        target = heroManager:getHero(i)
		qDmg = getDmg("Q", myHero, target)
        if target ~= nil and target.team ~= player.team and not target.dead and GetDistance(target) < skills.skillQ.range and target.visible then
            if QReady and qDmg > target.health then
				if VIP_USER then
					local pos, info = Prodiction.GetPrediction(target, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width)
					if pos then 
						CastSpell(_Q, pos.x, pos.z)
					end	
				end
				if not VIP_USER then
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, false)
					if CastPosition and HitChance >= 2 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
						return
					end
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
        if target ~= nil and target.team ~= player.team and not target.dead and GetDistance(target) < skills.skillE.range and target.visible then
            if EReady and eDmg > target.health then
				if VIP_USER then
					local pos, info = Prodiction.GetPrediction(target, skills.skillE.range, skills.skillE.speed, skills.skillE.delay, skills.skillE.width)
					if pos then 
						CastSpell(_E, pos.x, pos.z)
					end	
				end
				if not VIP_USER then
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.skillE.delay, skills.skillE.width, skills.skillE.range, skills.skillE.speed, myHero, false)
					if CastPosition and HitChance >= 2 then
						CastSpell(_E, CastPosition.x, CastPosition.z)
						return
					end
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
        if target ~= nil and target.team ~= player.team and not target.dead and GetDistance(target) < skills.skillQ.range and target.visible then
			if VIP_USER then
				local pos, info = Prodiction.GetPrediction(target, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width)
				if pos then 
					CastSpell(_Q, pos.x, pos.z)
				end	
			end
			if not VIP_USER then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, false)
				if CastPosition and HitChance >= 2 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
					return
				end
			end
        end
    end
end

function HarrasE()
	players = heroManager.iCount
	for i = 1, players, 1 do
		target = heroManager:getHero(i)
		if target ~= nil and target.team ~= player.team and not target.dead and GetDistance(target) < skills.skillE.range and target.visible then
			if VIP_USER then
				local pos, info = Prodiction.GetPrediction(target, skills.skillE.range, skills.skillE.speed, skills.skillE.delay, skills.skillE.width)
				if pos then 
					CastSpell(_E, pos.x, pos.z)
				end	
			end
			if not VIP_USER then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.skillE.delay, skills.skillE.width, skills.skillE.range, skills.skillE.speed, myHero, false)
				if CastPosition and HitChance >= 2 then
					CastSpell(_E, CastPosition.x, CastPosition.z)
					return
				end
			end
		end
	end
end

function CastQ()
	if QReady and MenuGalio.comboConfig.USEQ and GetDistance(Target) < skills.skillQ.range then
		if VIP_USER then
			if Target ~= nil and Target.team ~= player.team and not Target.dead and Target.visible then
				local pos, info = Prodiction.GetPrediction(Target, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width)
				if pos then 
					CastSpell(_Q, pos.x, pos.z)
				end	
			end
		end
		if not VIP_USER then
			if Target ~= nil and Target.team ~= player.team and not Target.dead then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, false)
				if CastPosition and HitChance >= 2 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
					return
				end
			end
		end
	end
end		

function CastE()
	if EReady and MenuGalio.comboConfig.USEE and GetDistance(Target) < skills.skillE.range then
		if VIP_USER then
			if Target ~= nil and Target.team ~= player.team and not Target.dead and Target.visible then
				local pos, info = Prodiction.GetPrediction(Target, skills.skillE.range, skills.skillE.speed, skills.skillE.delay, skills.skillE.width)
				if pos then 
					CastSpell(_E, pos.x, pos.z)
				end	
			end
		end
		if not VIP_USER then
			if Target ~= nil and Target.team ~= player.team and not Target.dead then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, skills.skillE.delay, skills.skillE.width, skills.skillE.range, skills.skillE.speed, myHero, false)
				if CastPosition and HitChance >= 2 then
					CastSpell(_E, CastPosition.x, CastPosition.z)
					return
				end
			end
		end
	end
end

function CastW()
	if WReady and MenuGalio.comboConfig.USEW and GetDistance(Target) <= skills.skillW.range then
		CastSpell(_W)
	end
end

function CastR()
	local enemyCount = EnemyCount(myHero, skills.skillR.range)
	if RReady and MenuGalio.comboConfig.USER and enemyCount >= MenuGalio.comboConfig.ENEMYTOR then
		CastSpell(_R)
	end
end

function FarmQ()
	local EnemyMinions = minionManager(MINION_ENEMY, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	EnemyMinions:update()
	for index, minion in pairs(EnemyMinions.objects) do
        local qDmg = getDmg("Q",minion,  GetMyHero())
        local MinionHealth_ = minion.health
        if qDmg >= MinionHealth_ then
            CastSpell(_Q, minion)
        end
    end
end

function FarmE()
	local EnemyMinions = minionManager(MINION_ENEMY, skills.skillE.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	EnemyMinions:update()
	for index, minionn in pairs(EnemyMinions.objects) do
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

function autolvl()
	if not MenuGalio.exConfig.ALS then return end

	
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuGalio.exConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuGalio.exConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuGalio.exConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuGalio.exConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuGalio.exConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuGalio.exConfig.AL == 6 then	
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

function PluginOnDraw()
	if MenuGalio.drawConfig.DQ and QReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, ARGB(255,0,0,255))
	end
	if MenuGalio.drawConfig.DW and WReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillW.range, ARGB(255,100,0,255))
	end
	if MenuGalio.drawConfig.DE and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, ARGB(255,255,0,0))
	end
	if MenuGalio.drawConfig.DR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillR.range, ARGB(255,0,255,0))
	end
end
