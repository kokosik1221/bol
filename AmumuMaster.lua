--[[
	AMUMU MASTER KOKOSIK1221

	Changelog:
 
	0.1 - First Relase
 



]]--

if myHero.charName ~= "Amumu" then return end

local version = 1.0
local AUTOUPDATE = true
local SCRIPT_NAME = "AmumuMaster"

--AUTO UPDATE--
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() PrintChat("Required libraries downloaded successfully, please reload") end)
end

if VIP_USER and FileExist(LIB_PATH.."Prodiction.lua") then
	require("Prodiction")
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

--END AUTO UPDATE--
-------------------

Champions = {
    ["Katarina"] = {charName = "Katarina", qwer = {
        ["KatarinaR"] = {spellName = "KatarinaR", range = 550},
    }}, 
    ["Caitlyn"] = {charName = "Caitlyn", qwer = {
        ["CaitlynAceintheHole"] = {spellName = "CaitlynAceintheHole", range = 3000},
    }},
	["Shen"] = {charName = "Shen", qwer = {
        ["ShenStandUnited"] = {spellName = "ShenStandUnited", range = 550},
    }},
	["Urgot"] = {charName = "Urgot", qwer = {
        ["UrgotSwap2"] = {spellName = "UrgotSwap2", range = 550},
    }},
	["MissFortune"] = {charName = "MissFortune", qwer = {
        ["MissFortuneBulletTime"] =  {spellName = "MissFortuneBulletTime", range = 1400},
    }},
	["Galio"] = {charName = "Galio", qwer = {
        ["GalioIdolOfDurand"] =  {spellName = "GalioIdolOfDurand", range = 560},
    }},
	["FiddleSticks"] = {charName = "FiddleSticks", qwer = {
        ["Crowstorm"] = {spellName="Crowstorm", range=600},
    }},  
}

function Menuu()
	MumuMenu = scriptConfig("Amumu Master "..version, "Amumu Master "..version)
	MumuMenu:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MumuMenu.Orbwalking)
	MumuMenu:addSubMenu("Target selector", "STS")
    STS:AddToMenu(MumuMenu.STS)
	--[[--- Combo --]]--
	MumuMenu:addSubMenu("Combo", "combo")
	MumuMenu.combo:addSubMenu("Q Options", "QO")
	MumuMenu.combo.QO:addParam("USEQ", "Use Q In Combo", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.combo.QO:addParam("UQMC", "Min Mana To Cast Q", SCRIPT_PARAM_SLICE, 10, 0, 100)
	MumuMenu.combo:addSubMenu("W Options", "WO")
	MumuMenu.combo.WO:addParam("USEW", "Use W In Combo", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.combo.WO:addParam("UWMC", "Min Mana To Cast W", SCRIPT_PARAM_SLICE, 30, 0, 100)
	MumuMenu.combo:addSubMenu("E Options", "EO")
	MumuMenu.combo.EO:addParam("USEE", "Use E In Combo", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.combo.EO:addParam("UEMC", "Min Mana To Cast E", SCRIPT_PARAM_SLICE, 20, 0, 100)
	MumuMenu.combo:addSubMenu("R Options", "RO")
	MumuMenu.combo.RO:addParam("USER", "Use R In Combo", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.combo.RO:addParam("RCS", "Use R To Stop Enemy Spells", SCRIPT_PARAM_ONOFF, true)
	for i = 1, heroManager.iCount,1 do
        local hero = heroManager:getHero(i)
        if hero.team ~= player.team then
            if Champions[hero.charName] ~= nil then
                for index, skillshot in pairs(Champions[hero.charName].qwer) do
                    MumuMenu.combo.RO:addParam(skillshot.spellName, hero.charName .. " - " .. skillshot.name, SCRIPT_PARAM_ONOFF, true)
                end
            end
        end
    end
	MumuMenu.combo:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--[[--- Harras --]]--
	MumuMenu:addSubMenu("Harras", "harras")
	MumuMenu.harras:addParam("QH", "Harras Use Q", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.harras:addParam("WH", "Harras Use W", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.harras:addParam("EH", "Harras Use E", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.harras:addParam("MTH", "Min Mana To Harras", SCRIPT_PARAM_SLICE, 50, 0, 100)
	MumuMenu.harras:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	--[[--- Farm --]]--
	MumuMenu:addSubMenu("Farm", "farm")
	MumuMenu.farm:addParam("QF", "Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.farm:addParam("WF", "Farm Use W", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.farm:addParam("EF", "Farm Use E", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.farm:addParam("MTF", "Min % Mana", SCRIPT_PARAM_SLICE, 50, 0, 100)
	MumuMenu.farm:addParam("FEnabled", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MumuMenu.farm:addParam("LCEnabled", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	--[[--- Jungle Farm --]]--
	MumuMenu:addSubMenu("Jungle Farm", "jf")
	MumuMenu.jf:addParam("QJF", "Jungle Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.jf:addParam("WJF", "Jungle Farm Use W", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.jf:addParam("EJF", "Jungle Farm Use E", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.jf:addParam("MTJF", "Min Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 50, 0, 100)
	MumuMenu.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--[[--- Kill Steal --]]--
	MumuMenu:addSubMenu("Kill Steal", "ks")
	MumuMenu.ks:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.ks:addParam("QKS", "Use Q To KS", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.ks:addParam("EKS", "Use E To KS", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.ks:addParam("RKS", "Use R To KS", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.ks:addParam("ITKS", "Use Items To KS", SCRIPT_PARAM_ONOFF, true)
	--[[--- Drawing --]]--
	MumuMenu:addSubMenu("Drawing", "dr")
	MumuMenu.dr:addParam("DQR", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.dr:addParam("DWR", "Draw W radius", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.dr:addParam("DER", "Draw E radius", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.dr:addParam("DRR", "Draw R radius", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.dr:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	--[[--- Extra --]]--
	MumuMenu:addSubMenu("Extra", "ex")
	MumuMenu.ex:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.ex:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MumuMenu.ex:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, true)
	MumuMenu.ex:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 4, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
end

function LoadLibs()
	if VIP_USER then
		Prod = ProdictManager.GetInstance()
	    ProdQ = Prod:AddProdictionObject(_Q, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width) 
	end
	if not VIP_USER then
		VP = VPrediction(true)
	end
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC) 
end

function Variables()
	skills = 
	{
	skillQ = {range = 1100, speed = 2000, delay = 0.4, width = 80},
	skillW = {range = 300},
	skillE = {range = 350, delay = 0.25},
	skillR = {range = 550, delay = 0.25},
	}
	IgniteKey = nil;
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		IgniteKey = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		IgniteKey = SUMMONER_2
	else
		IgniteKey = nil
	end
	abilitylvl = 0
	tiamatrange = 275
	blackfiretorchrange = 600
	bilgewaterrange = 450
	yomurange = 275
	randuinrange = 275
	deathfiregrasprange = 600
	brkrange = 450
	hydrarange = 275
	hextechrange = 600
	EnemyMinions = minionManager(MINION_ENEMY, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	killstring = {}
end

function Check()
	DmgCalc()
	EnemyMinions:update()
	JungleMinions:update()
	zhonyaslot = GetInventorySlotItem(3157)
	woogletslot = GetInventorySlotItem(3090)
	hextechslot = GetInventorySlotItem(3146)
	hydraslot = GetInventorySlotItem(3074)
	brkslot = GetInventorySlotItem(3153)
	deathfiregraspslot = GetInventorySlotItem(3128)
	randuinslot = GetInventorySlotItem(3143)
	yomuslot = GetInventorySlotItem(3142)
	muramanaslot = GetInventorySlotItem(3042)
	serafinslot = GetInventorySlotItem(3048)
	bilgewaterslot = GetInventorySlotItem(3144)
	sworddivineslot = GetInventorySlotItem(3131)
	blackfiretorchslot = GetInventorySlotItem(3188)
	tiamatslot = GetInventorySlotItem(3077)
	
	tiamatready = (tiamatslot ~= nil and myHero:CanUseSpell(tiamatslot) == READY)
	hextechready = (hextechslot ~= nil and myHero:CanUseSpell(hextechslot) == READY)
	hydraready = (hydraslot ~= nil and myHero:CanUseSpell(hydraslot) == READY)
	brkready = (brkslot ~= nil and myHero:CanUseSpell(brkslot) == READY)
	deathfiregraspready = (deathfiregraspslot ~= nil and myHero:CanUseSpell(deathfiregraspslot) == READY)
	randuinready = (randuinslot ~= nil and myHero:CanUseSpell(randuinslot) == READY)
	yomuready = (yomuslot ~= nil and myHero:CanUseSpell(yomuslot) == READY)
	bilgewaterready = (bilgewaterslot ~= nil and myHero:CanUseSpell(bilgewaterslot) == READY)
	sworddivineready = (sworddivineslot ~= nil and myHero:CanUseSpell(sworddivineslot) == READY)
	blackfiretorchready = (blackfiretorchslot ~= nil and myHero:CanUseSpell(blackfiretorchslot) == READY)
	muramanaready = (muramanaslot ~= nil and myHero:CanUseSpell(muramanaslot) == READY)
	serafinready = (serafinslot ~= nil and myHero:CanUseSpell(serafinslot) == READY)
	woogletready = (woogletslot ~= nil and myHero:CanUseSpell(woogletslot) == READY)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	
	x = STS:GetTarget(skills.skillQ.range)
	if wstatus and not x or GetDistance(x) > skills.skillW.range + 150  then
		CastSpell(_W)
	end
end

function OnLoad()
	LoadLibs()
	Menuu()
	Variables()
end

function OnTick()
	Cel = STS:GetTarget(skills.skillQ.range)
	Check()
	if Cel ~= nil and MumuMenu.combo.CEnabled then
		Combo()
	end
	if Cel ~= nil and MumuMenu.harras.HEnabled then
		Harrass()
	end
	if MumuMenu.farm.FEnabled or MumuMenu.farm.LCEnabled then
		Farmm()
	end
	if MumuMenu.jf.JFEnabled then
		JungleFarmm()
	end
	if MumuMenu.ex.AZ then
		autozh()
	end
	if MumuMenu.ex.ALS then
		autolvl()
	end
	KillSteall()
end

function Combo()
	if MumuMenu.combo.QO.USEQ then
		CastQC()
	end
	if MumuMenu.combo.WO.USEW then
		CastWC()
	end
	UseItems(Cel)
	if MumuMenu.combo.EO.USEE then
		CastEC()
	end
	if MumuMenu.combo.RO.USER then
		CastRC()
	end
end

function UseItems(int)
	if not int then
			int = Cel
		end
	if ValidTarget(int) and int ~= nil then
		if tiamatready and GetDistanceSqr(int) < tiamatrange then CastSpell(tiamatslot, int) end
		if blackfiretorchready and GetDistanceSqr(int) < blackfiretorchrange then CastSpell(blackfiretorchslot, int) end
		if bilgewaterready and GetDistanceSqr(int) < bilgewaterrange then CastSpell(bilgewaterslot, int) end
		if yomuready and GetDistanceSqr(int) < yomurange then CastSpell(yomuslot, int) end
		if randuinready and GetDistanceSqr(int) < randuinrange then CastSpell(randuinslot, int) end
		if deathfiregraspready and GetDistanceSqr(int) < deathfiregrasprange then CastSpell(deathfiregraspslot, int) end
		if brkready and GetDistanceSqr(int) < brkrange then CastSpell(brkslot, int) end
		if hydraready and GetDistanceSqr(int) < hydrarange then CastSpell(hydraslot, int) end
		if hextechready and GetDistanceSqr(int) < hextechrange then CastSpell(hextechslot, int) end
		if sworddivineready then CastSpell(sworddivineslot, int) end
	end
end

function CastQC()
	if QReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and (MumuMenu.combo.QO.UQMC <= (myHero.mana / myHero.maxMana * 100)) then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Cel, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, true)
		if CastPosition and HitChance >= 2 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
			return
		end
	end
end

function CastWC()
	local enemyCount = EnemyCount(myHero, skills.skillW.range)
	if WReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and (MumuMenu.combo.WO.UWMC <= (myHero.mana / myHero.maxMana * 100)) then
		if not wstatus and GetDistance(Cel) < skills.skillW.range and enemyCount >= 1 then
			CastSpell(_W)
		end
		if wstatus and not Cel or GetDistance(Cel) > skills.skillW.range + 150 or (MumuMenu.combo.WO.UWMC > (myHero.mana / myHero.maxMana * 100))  then
			CastSpell(_W)
		end
	end
end

function CastEC()
	local enemyCount = EnemyCount(myHero, skills.skillE.range)
	if EReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and (MumuMenu.combo.EO.UEMC <= (myHero.mana / myHero.maxMana * 100)) then
		if ValidTarget(Cel) and GetDistance(Cel) < skills.skillE.range and enemyCount >= 1 then
			CastSpell(_E)
		end
	end
end

function CastRC()
	local enemyCount = EnemyCount(myHero, skills.skillR.range)
	if RReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead then
		if ValidTarget(Cel) and GetDistance(Cel) < skills.skillR.range and enemyCount >= 1 then
			CastSpell(_R)
		end
	end
end

function Harrass()
	if MumuMenu.harras.QH then
		CastQH()
	end
	if MumuMenu.harras.WH then
		CastWH()
	end
	if MumuMenu.harras.EH then
		CastEH()
	end
end

function CastQH()
	if QReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and (MumuMenu.harras.MTH <= (myHero.mana / myHero.maxMana * 100)) then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Cel, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, true)
		if CastPosition and HitChance >= 2 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
			return
		end
	end
end

function CastWH()
	if WReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and (MumuMenu.harras.MTH <= (myHero.mana / myHero.maxMana * 100)) then
		if not wstatus and GetDistance(Cel) < skills.skillW.range and enemyCount >= 1 then
			CastSpell(_W)
		end
		if wstatus and not Cel or GetDistance(Cel) > skills.skillW.range + 150 then
			CastSpell(_W)
		end
	end
end

function CastEH()
	if EReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and (MumuMenu.harras.MTH <= (myHero.mana / myHero.maxMana * 100)) then
		if ValidTarget(Cel) and GetDistance(Cel) < skills.skillE.range then
			CastSpell(_E)
		end
	end
end

function Farmm()
	if MumuMenu.farm.QF then
		CastQF()
	end
	if MumuMenu.farm.WF then
		CastWF()
	end
	if MumuMenu.farm.EF then
		CastEF()
	end
end

function CastQF()
	for i, minion in pairs(EnemyMinions.objects) do
		if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and (MumuMenu.farm.MTF <= (myHero.mana / myHero.maxMana * 100)) then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, true)
			if CastPosition and HitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
				return
			end
		end
	end
end

function CastWF()
	for i, minion in pairs(EnemyMinions.objects) do
		if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillW.range and (MumuMenu.farm.MTF <= (myHero.mana / myHero.maxMana * 100)) then
			if not wstatus and GetDistance(minion) < skills.skillW.range then
				CastSpell(_W)
			end
			if wstatus and not minion or GetDistance(minion) > skills.skillW.range + 150 then
				CastSpell(_W)
			end
		end
	end
end

function CastEF()
	for i, minion in pairs(EnemyMinions.objects) do
		if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range and (MumuMenu.farm.MTF <= (myHero.mana / myHero.maxMana * 100)) then
			CastSpell(_E)
		end
	end
end

function JungleFarmm()
	if MumuMenu.jf.QJF then
		CastQJF()
	end
	if MumuMenu.jf.WJF then
		CastWJF()
	end
	if MumuMenu.jf.EJF then
		CastEJF()
	end
end

function CastQJF()
	for i, minion in pairs(JungleMinions.objects) do
		if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and (MumuMenu.jf.MTF <= (myHero.mana / myHero.maxMana * 100)) then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, true)
			if CastPosition and HitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
				return
			end
		end
	end
end

function CastWJF()
	for i, minion in pairs(JungleMinions.objects) do
		if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillW.range and (MumuMenu.jf.MTF <= (myHero.mana / myHero.maxMana * 100)) then
			if not wstatus and GetDistance(minion) < skills.skillW.range then
				CastSpell(_W)
			end
			if wstatus and not minion or GetDistance(minion) > skills.skillW.range + 150 then
				CastSpell(_W)
			end
		end
	end
end

function CastEJF()
	for i, minion in pairs(JungleMinions.objects) do
		if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range and (MumuMenu.jf.MTF <= (myHero.mana / myHero.maxMana * 100)) then
			CastSpell(_E)
		end
	end
end

function KillSteall()
	if MumuMenu.ks.IKS then
		if IReady then
			for i = 1, heroManager.iCount do
			local Enemy = heroManager:getHero(i)
				iDmg = getDmg("IGNITE", myHero, Enemy)
				if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					if IReady and iDmg > Enemy.health then
						CastSpell(IgniteKey, Enemy)
					end
				end
			end
		end
	end
	if MumuMenu.ks.QKS then
		players = heroManager.iCount
		for i = 1, players, 1 do
			target = heroManager:getHero(i)
			qDmg = getDmg("Q", myHero, target)
			if target ~= nil and target.team ~= player.team and not target.dead and GetDistance(target) < skills.skillQ.range and target.visible then
				if QReady and qDmg > target.health then
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, true)
					if CastPosition and HitChance >= 2 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
						return
					end
				end
			end
		end	
	end
	if MumuMenu.ks.EKS then
		players = heroManager.iCount
		for i = 1, players, 1 do
			target = heroManager:getHero(i)
			eDmg = getDmg("E", myHero, target)
			local enemyCount = EnemyCount(myHero, skills.skillE.range)
			if target ~= nil and target.team ~= player.team and not target.dead and GetDistance(target) < skills.skillE.range and target.visible then
				if EReady and eDmg > target.health and enemyCount >= 1 then
					CastSpell(_E)
				end
			end
		end
	end
	if MumuMenu.ks.RKS then
		players = heroManager.iCount
		for i = 1, players, 1 do
			target = heroManager:getHero(i)
			rDmg = getDmg("R", myHero, target)
			local enemyCount = EnemyCount(myHero, skills.skillR.range)
			if target ~= nil and target.team ~= player.team and not target.dead and GetDistance(target) < skills.skillR.range and target.visible then
				if RReady and rDmg > target.health and enemyCount >= 1 then
					CastSpell(_R)
				end
			end
		end
	end
	if MumuMenu.ks.ITKS then
		for i = 1, heroManager.iCount do
			local Enemy = heroManager:getHero(i)
			local health = Enemy.health
			deathfiregraspDmg = ((deathfiregraspready and getDmg("DFG", Enemy, myHero)) or 0)
			hextechDmg = ((hextechready and getDmg("HXG", Enemy, myHero)) or 0)
			bilgewaterDmg = ((bilgewaterready and getDmg("BWC", Enemy, myHero)) or 0)
			blackfiretorchdmg = ((blackfiretorchready and getDmg("BLACKFIRE", Enemy, myHero)) or 0)
			tiamatdmg = ((tiamatready and getDmg("TIAMAT", Enemy, myHero)) or 0)
			brkdmg = ((brkready and getDmg("RUINEDKING", Enemy, myHero)) or 0)
			hydradmg = ((hydraready and getDmg("HYDRA", Enemy, myHero)) or 0)
			itemsDmg = deathfiregraspDmg + hextechDmg + bilgewaterDmg + blackfiretorchdmg + tiamatdmg + brkdmg + hydradmg
			if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
				if health < itemsDmg then
					UseItems(Enemy)
				end
			end
		end
	end
end

function OnDraw()
	if MumuMenu.dr.DQR and QReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, ARGB(255,0,0,255))
	end
	if MumuMenu.dr.DWR and WReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillW.range, ARGB(255,100,0,255))
	end
	if MumuMenu.dr.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, ARGB(255,255,0,0))
	end
	if MumuMenu.dr.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillR.range, ARGB(255,0,255,0))
	end
	if MumuMenu.dr.DRD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
end

function autozh()
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MumuMenu.ex.AZHP then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
if not MumuMenu.ex.ALS then return end
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MumuMenu.ex.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MumuMenu.ex.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MumuMenu.ex.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MumuMenu.ex.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MumuMenu.ex.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MumuMenu.ex.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end

function OnCreateObj(obj)	
	if obj ~= nil and obj.name:find("Despairpool_tar.troy") then
		if GetDistance(obj, myHero) <=70 then
			wstatus = true
		end
	end
end

function OnDeleteObj(obj)
	if obj ~= nil and obj.name:find("Despairpool_tar.troy") then
		if GetDistance(obj, myHero) <=70 then
			wstatus = false
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

function OnProcessSpell(object,spellProc)
if MumuMenu.combo.RO.RCS then
	if object.team ~= player.team and string.find(spellProc.name, "Basic") == nil then
		if Champions[object.charName] ~= nil then
            skillshot = Champions[object.charName].qwer[spellProc.name]
            if skillshot ~= nil then
				range = skillshot.range
				if not spellProc.startPos then
                    spellProc.startPos.x = object.x
                    spellProc.startPos.z = object.z                        
                end     
				if GetDistance(spellProc.startPos) <= range then		
					if GetDistance(spellProc.endPos) <= skills.skillR.range then
						if RReady and MumuMenu.combo.RO[spellProc.name] then
							CastSpell(_R)
						end
					end
				end
            end
		end
	end	
end
end

function DmgCalc()
    for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
            local qDmg = getDmg("Q", enemy, myHero)
            local wDmg = getDmg("W", enemy, myHero)
			local eDmg = getDmg("E", enemy, myHero)
			local rDmg = getDmg("R", enemy, myHero)
			local deathfiregraspDmg = ((deathfiregraspready and getDmg("DFG", Enemy, myHero)) or 0)
			local hextechDmg = ((hextechready and getDmg("HXG", Enemy, myHero)) or 0)
			local bilgewaterDmg = ((bilgewaterready and getDmg("BWC", Enemy, myHero)) or 0)
			local blackfiretorchdmg = ((blackfiretorchready and getDmg("BLACKFIRE", Enemy, myHero)) or 0)
			local tiamatdmg = ((tiamatready and getDmg("TIAMAT", Enemy, myHero)) or 0)
			local brkdmg = ((brkready and getDmg("RUINEDKING", Enemy, myHero)) or 0)
			local hydradmg = ((hydraready and getDmg("HYDRA", Enemy, myHero)) or 0)
			itemsDmg = deathfiregraspDmg + hextechDmg + bilgewaterDmg + blackfiretorchdmg + tiamatdmg + brkdmg + hydradmg
            if qDmg + eDmg + rDmg > enemy.health then
                killstring[enemy.networkID] = "Q+E+R Kill"
			elseif qDmg + eDmg > enemy.health then
                killstring[enemy.networkID] = "Q+E Kill"
			elseif qDmg + rDmg > enemy.health then
                killstring[enemy.networkID] = "Q+R Kill"
            elseif eDmg + rDmg > enemy.health then
                killstring[enemy.networkID] = "E+R Kill"
            elseif qDmg > enemy.health then
                killstring[enemy.networkID] = "Q Kill"
			elseif eDmg > enemy.health then
                killstring[enemy.networkID] = "E Kill"	
			elseif rDmg > enemy.health then
                killstring[enemy.networkID] = "R Kill"	
			elseif qDmg + eDmg + rDmg + itemsDmg > enemy.health then
                killstring[enemy.networkID] = "Q+E+R+Items Kill"
			elseif qDmg + eDmg + itemsDmg > enemy.health then
                killstring[enemy.networkID] = "Q+E+Items Kill"
			elseif qDmg + rDmg + itemsDmg > enemy.health then
                killstring[enemy.networkID] = "Q+R+Items Kill"
            elseif eDmg + rDmg + itemsDmg > enemy.health then
                killstring[enemy.networkID] = "E+R+Items Kill"
            elseif qDmg + itemsDmg > enemy.health then
                killstring[enemy.networkID] = "Q+Items Kill"
			elseif eDmg + itemsDmg > enemy.health then
                killstring[enemy.networkID] = "E+Items Kill"	
			elseif rDmg + itemsDmg > enemy.health then
				killstring[enemy.networkID] = "R+Items Kill"
			elseif itemsDmg > enemy.health then
				killstring[enemy.networkID] = "Items Kill"									
            else
                killstring[enemy.networkID] = "Harass Him"
            end
        end
    end
end
