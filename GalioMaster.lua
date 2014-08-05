--[[
	GALIO MASTER KOKOSIK1221

	Changelog:
 
	1.0 - First Relase
	1.1 - Added Use R To Stop Enemy Ultimates
            - Added Auto Zhonya
            - Added Auto Lvl Skills
            - Added Support Prodiction(Not Tested)
	1.2 - Fix error with cast ultimate
	1.3 - Script Rewritten(now it is not SAC PLUGIN)
	    - Added SOW integration
	    - Added Free, VIP, VPrediction, Prodiction 1.4+ Support
	    - Added Auto Update
	    - Added Jungle Farm
	    - Added Lane Clear
	    - Added DMG Calculation
	    - Added Mana Manager
	    - Added Small Escape Mode
	    - Added Draw Lag-Free Circles
	1.4 - Added changing colors in Drawing Menu
	    - Added BOL TRACKER
	    - Rewritten Farm/LANE Clear MODE
	1.5 - Update BOL-TRACKER Code
	
]]--

if myHero.charName ~= "Galio" then return end

local version = 1.5
local AUTOUPDATE = true
local SCRIPT_NAME = "GalioMaster"
local prodstatus = false

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
	prodstatus = true
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

--BOL TRACKER--
---------------
HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
id = 74
ScriptName = "GalioMaster"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
--END BOL TRACKER--
-------------------

function Menu()
	MenuGalio = scriptConfig("Galio Master "..version, "Galio Master "..version)
	MenuGalio:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuGalio.Orbwalking)
	MenuGalio:addSubMenu("Target selector", "STS")
    STS:AddToMenu(MenuGalio.STS)
	--[[--- Combo --]]--
	MenuGalio:addSubMenu("Combo Settings", "comboConfig")
    MenuGalio.comboConfig:addParam("USEQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
    MenuGalio.comboConfig:addParam("USEW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("USEE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("USER", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.comboConfig:addParam("ENEMYTOR", "Min Enemies to Cast R: ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuGalio.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--[[--- Harras --]]--
	MenuGalio:addSubMenu("Harras Settings", "harrasConfig")
    MenuGalio.harrasConfig:addParam("QH", "Harras Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.harrasConfig:addParam("EH", "Harras Use E", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuGalio.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	--[[--- Escape --]]--
	MenuGalio:addSubMenu("Escape Settings", "esConfig")
    MenuGalio.esConfig:addParam("ESE", "Use E", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.esConfig:addParam("ESW", "Use W", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.esConfig:addParam("ESM", "Move To Mouse POS.", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.esConfig:addParam("ESEnabled", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("J"))
	--[[--- Mana Manager --]]--
	MenuGalio:addSubMenu("Mana Config" , "mpConfig")
	MenuGalio.mpConfig:addParam("mptocq", "Min Mana To Cast Q", SCRIPT_PARAM_SLICE, 20, 0, 100, 0) 
	MenuGalio.mpConfig:addParam("mptoce", "Min Mana To Cast E", SCRIPT_PARAM_SLICE, 25, 0, 100, 0) 
	MenuGalio.mpConfig:addParam("mptocr", "Min Mana To Cast R", SCRIPT_PARAM_SLICE, 20, 0, 100, 0) 
	MenuGalio.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.mpConfig:addParam("mptohq", "Min Mana To Harras Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0) 
	MenuGalio.mpConfig:addParam("mptohe", "Min Mana To Harras E", SCRIPT_PARAM_SLICE, 55, 0, 100, 0)
	MenuGalio.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.mpConfig:addParam("mptofq", "Min Mana To Farm Q", SCRIPT_PARAM_SLICE, 60, 0, 100, 0) 
	MenuGalio.mpConfig:addParam("mptofe", "Min Mana To Farm E", SCRIPT_PARAM_SLICE, 65, 0, 100, 0)
	--[[--- Kill Steal --]]--
	MenuGalio:addSubMenu("KS Settings", "ksConfig")
	MenuGalio.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("QKS", "Use Q To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("EKS", "Use E To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("RKS", "Use R To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.ksConfig:addParam("ITKS", "Use Items To KS", SCRIPT_PARAM_ONOFF, true)
	--[[--- Farm --]]--
	MenuGalio:addSubMenu("Farm Config", "farm")
	MenuGalio.farm:addParam("QF", "Use Q", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuGalio.farm:addParam("EF",  "Use E", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuGalio.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
	MenuGalio.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	--[[--- Jungle Farm --]]--
	MenuGalio:addSubMenu("Jungle Farm", "jf")
	MenuGalio.jf:addParam("QJF", "Jungle Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.jf:addParam("EJF", "Jungle Farm Use E", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--[[--- Extra --]]--
	MenuGalio:addSubMenu("Extra Settings", "exConfig")
	MenuGalio.exConfig:addParam("AR", "Use R To Stop Enemy Ultimates", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.exConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuGalio.exConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuGalio.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGalio.exConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuGalio.exConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 2, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	--[[--- Drawing --]]--
	MenuGalio:addSubMenu("Draw Settings", "drawConfig")
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

	--[[--- Prediction --]]--
	MenuGalio:addSubMenu("Prediction Settings", "prConfig")
	MenuGalio.prConfig:addParam("pro", "Use", SCRIPT_PARAM_LIST, 3, {"FREEPrediction","VIPPrediction","VPrediction","Prodiction"}) 
end

function LoadLibs()
	if VIP_USER then
		Prod = ProdictManager.GetInstance()
	    ProdictionQ = Prod:AddProdictionObject(_Q, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width) 
		ProdictionE = Prod:AddProdictionObject(_E, skills.skillE.range, skills.skillE.speed, skills.skillE.delay, skills.skillE.width)
		
		VipPredictionQ = TargetPredictionVIP(skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width, myHero)
		VipPredictionE = TargetPredictionVIP(skills.skillE.range, skills.skillE.speed, skills.skillE.delay, skills.skillE.width, myHero)
	end
	VP = VPrediction(true)
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC) 
	FreePredictionQ = TargetPrediction(skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width)
	FreePredictionE = TargetPrediction(skills.skillE.range, skills.skillE.speed, skills.skillE.delay, skills.skillE.width)
end

function Variables()
	skills = 
	{
	skillQ = {range = 940, speed = 1400, delay = 0.25, width = 235},
	skillW = {range = 800},
	skillE = {range = 1180, speed = 1400, delay = 0.25, width = 235},
	skillR = {range = 560},
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

function cancast()
	--Q--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.mpConfig.mptocq then
		ccq = true
	else
		ccq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.mpConfig.mptohq then
		chq = true
	else
		chq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.mpConfig.mptofq then
		cfq = true
	else
		cfq = false
	end
	--E--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.mpConfig.mptoce then
		cce = true
	else
		cce = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.mpConfig.mptohe then
		che = true
	else
		che = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.mpConfig.mptofe then
		cfe = true
	else
		cfe = false
	end
	--R--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGalio.mpConfig.mptocr then
		ccr = true
	else
		ccr = false
	end
end

function Check()
	DmgCalc()
	cancast()
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
	
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
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

function OnLoad()
	Variables()
	LoadLibs()
	Menu()
	Variables()
	UpdateWeb(true, ScriptName, id, HWID)
end

function OnTick()
	Cel = STS:GetTarget(skills.skillE.range)
	Check()
	if Cel ~= nil and MenuGalio.comboConfig.CEnabled then
		Combo()
	end
	if Cel ~= nil and MenuGalio.harrasConfig.HEnabled or MenuGalio.harrasConfig.HTEnabled then
		Harrass()
	end
	if MenuGalio.farm.Freeze or MenuGalio.farm.LaneClear then
		local Mode = MenuGalio.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
	end
	if MenuGalio.jf.JFEnabled then
		JungleFarmm()
	end
	if MenuGalio.exConfig.AZ then
		autozh()
	end
	if MenuGalio.exConfig.ALS then
		autolvl()
	end
	if MenuGalio.esConfig.ESEnabled then
		escape()
	end
	KillSteall()
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

--COMBO--
function Combo()
	if MenuGalio.comboConfig.USEQ then
		CastQC()
	end
	if MenuGalio.comboConfig.USEW then
		CastWC()
	end
	UseItems(Cel)
	if MenuGalio.comboConfig.USEE then
		CastEC()
	end
	if MenuGalio.comboConfig.USER then
		CastRC()
	end
end

function CastQC()
	if QReady and MenuGalio.comboConfig.USEQ and GetDistance(Cel) < skills.skillQ.range and ccq then
		CastQ(Cel)
	end
end

function CastWC()
	if WReady and MenuGalio.comboConfig.USEW and GetDistance(Cel) <= skills.skillW.range then
		CastSpell(_W)
	end
end

function CastEC()
	if EReady and MenuGalio.comboConfig.USEE and GetDistance(Cel) < skills.skillE.range and cce then
		CastE(Cel)
	end
end

function CastRC()
	local enemyCount = EnemyCount(myHero, skills.skillR.range)
	if RReady and MenuGalio.comboConfig.USER and enemyCount >= MenuGalio.comboConfig.ENEMYTOR and ccr then
		CastSpell(_R)
	end
end
--END COMBO--

--HARRAS--
function Harrass()
	if MenuGalio.harrasConfig.QH then
		CastQH()
	end
	if MenuGalio.harrasConfig.EH then
		CastEH()
	end
end

function CastQH()
	if QReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and GetDistance(Cel) < skills.skillQ.range and Cel.visible and chq then
		CastQ(Cel)
	end
end

function CastEH()
	if EReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and GetDistance(Cel) < skills.skillE.range and Cel.visible and che then
		CastE(Cel)
	end
end
--END HARRAS--

--ESCAPE--
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
--END ESCAPE--

--FARM--
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
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				CastQ(minion)
			end
		end
	end

	if UseE then
		for i, minion in pairs(EnemyMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range and cfe then
				CastE(minion)
			end
		end
	end
	
end
--END FARM--

--JUNGLE FARM--
function JungleFarmm()
	if MenuGalio.jf.QJF then
		CastQJF()
	end
	if MenuGalio.jf.EJF then
		CastEJF()
	end
end

function CastQJF()
	for i, minion in pairs(JungleMinions.objects) do
		if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
			CastQ(minion)
		end
	end
end

function CastEJF()
	for i, minion in pairs(JungleMinions.objects) do
		if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range and cfe then
			CastE(minion)
		end
	end
end
--END JUNGLE FARM--

--KILL STEAL--
function KillSteall()
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
		if MenuGalio.ksConfig.ITKS then
			deathfiregraspDmg = ((deathfiregraspready and getDmg("DFG", Enemy, myHero)) or 0)
			hextechDmg = ((hextechready and getDmg("HXG", Enemy, myHero)) or 0)
			bilgewaterDmg = ((bilgewaterready and getDmg("BWC", Enemy, myHero)) or 0)
			blackfiretorchdmg = ((blackfiretorchready and getDmg("BLACKFIRE", Enemy, myHero)) or 0)
			tiamatdmg = ((tiamatready and getDmg("TIAMAT", Enemy, myHero)) or 0)
			brkdmg = ((brkready and getDmg("RUINEDKING", Enemy, myHero)) or 0)
			hydradmg = ((hydraready and getDmg("HYDRA", Enemy, myHero)) or 0)
			itemsDmg = deathfiregraspDmg + hextechDmg + bilgewaterDmg + blackfiretorchdmg + tiamatdmg + brkdmg + hydradmg
		else
			itemsDmg = 0
		end
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health < iDmg and IReady then
				CastSpell(IgniteKey, Enemy)
			end
			if health < qDmg and QReady and (distance < skills.skillQ.range) and MenuGalio.ksConfig.QKS then
				CastQ(Enemy)
			elseif health < eDmg and EReady and (distance < skills.skillE.range) and MenuGalio.ksConfig.EKS then
				CastE(Enemy)
			elseif health < rDmg and RReady and (distance < skills.skillR.range) and MenuGalio.ksConfig.RKS then
				CastSpell(_R)
			elseif health < (qDmg + eDmg) and QReady and EReady and (distance < skills.skillE.range) and MenuGalio.ksConfig.EKS then
				CastE(Enemy)
			elseif health < (qDmg + rDmg) and QReady and RReady and (distance < skills.skillR.range) and MenuGalio.ksConfig.RKS then
				CastSpell(_R)
			elseif health < (eDmg + rDmg) and EReady and RReady and (distance < skills.skillE.range) and MenuGalio.ksConfig.EKS then
				CastE(Enemy)
			elseif health < (qDmg + eDmg + rDmg) and QReady and EReady and RReady and (distance < skills.skillR.range) and MenuGalio.ksConfig.RKS then
				CastSpell(_R)
			elseif health < (qDmg + eDmg + rDmg + itemsDmg) and MenuGalio.ksConfig.ITKS then
				if QReady and EReady and RReady then
					UseItems(Enemy)
				end
			elseif health < (qDmg + eDmg + itemsDmg) and health > (qDmg + eDmg) then
				if QReady and EReady then
					UseItems(Enemy)
				end
			end
			if IReady and iDmg > Enemy.health and MenuGalio.ksConfig.IKS then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end
--END KILL STEAL--

--DRAWING--
function OnDraw()
	if MenuGalio.drawConfig.DLC then
		if MenuGalio.drawConfig.DQR and QReady then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillQ.range - 90, 1, RGB(MenuGalio.drawConfig.DQRC[2], MenuGalio.drawConfig.DQRC[3], MenuGalio.drawConfig.DQRC[4]))
		end
		if MenuGalio.drawConfig.DWR and WReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillW.range - 80, 1, RGB(MenuGalio.drawConfig.DWRC[2], MenuGalio.drawConfig.DWRC[3], MenuGalio.drawConfig.DWRC[4]))
		end
		if MenuGalio.drawConfig.DER and EReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillE.range - 70, 1, RGB(MenuGalio.drawConfig.DERC[2], MenuGalio.drawConfig.DERC[3], MenuGalio.drawConfig.DERC[4]))
		end
		if MenuGalio.drawConfig.DRR and RReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillR.range - 40, 1, RGB(MenuGalio.drawConfig.DRRC[2], MenuGalio.drawConfig.DRRC[3], MenuGalio.drawConfig.DRRC[4]))
		end
	else
		if MenuGalio.drawConfig.DQR and QReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, ARGB(MenuGalio.drawConfig.DQRC[1], MenuGalio.drawConfig.DQRC[2], MenuGalio.drawConfig.DQRC[3], MenuGalio.drawConfig.DQRC[4]))
		end
		if MenuGalio.drawConfig.DWR and WReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillW.range, ARGB(MenuGalio.drawConfig.DWRC[1], MenuGalio.drawConfig.DWRC[2], MenuGalio.drawConfig.DWRC[3], MenuGalio.drawConfig.DWRC[4]))
		end
		if MenuGalio.drawConfig.DER and EReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, ARGB(MenuGalio.drawConfig.DERC[1], MenuGalio.drawConfig.DERC[2], MenuGalio.drawConfig.DERC[3], MenuGalio.drawConfig.DERC[4]))
		end
		if MenuGalio.drawConfig.DRR and RReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillR.range, ARGB(MenuGalio.drawConfig.DRRC[1], MenuGalio.drawConfig.DRRC[2], MenuGalio.drawConfig.DRRC[3], MenuGalio.drawConfig.DRRC[4]))
		end
	end
	if MenuGalio.drawConfig.DD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
end
--END DRAWING--

--EXTRA--
function autozh()
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuGalio.exConfig.AZHP then
		CastSpell(zhonyaslot)
	end
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
--END EXTRA--

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
			local deathfiregraspDmg = ((deathfiregraspready and getDmg("DFG", Enemy, myHero)) or 0)
			local hextechDmg = ((hextechready and getDmg("HXG", Enemy, myHero)) or 0)
			local bilgewaterDmg = ((bilgewaterready and getDmg("BWC", Enemy, myHero)) or 0)
			local blackfiretorchdmg = ((blackfiretorchready and getDmg("BLACKFIRE", Enemy, myHero)) or 0)
			local tiamatdmg = ((tiamatready and getDmg("TIAMAT", Enemy, myHero)) or 0)
			local brkdmg = ((brkready and getDmg("RUINEDKING", Enemy, myHero)) or 0)
			local hydradmg = ((hydraready and getDmg("HYDRA", Enemy, myHero)) or 0)
			itemsDmg = deathfiregraspDmg + hextechDmg + bilgewaterDmg + blackfiretorchdmg + tiamatdmg + brkdmg + hydradmg
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
			elseif enemy.health < (qDmg + itemsDmg) then
				killstring[enemy.networkID] = "Q+Items Kill!"
			elseif enemy.health < (eDmg + itemsDmg) then
				killstring[enemy.networkID] = "E+Items Kill!"
            elseif enemy.health < (rDmg + itemsDmg) then
				killstring[enemy.networkID] = "R+Items Kill!"
            elseif enemy.health < (qDmg + eDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+E+Items Kill!"
			elseif enemy.health < (qDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+R+Items Kill!"	
			elseif enemy.health < (eDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "E+R+Items Kill!"	
			elseif enemy.health < (qDmg + eDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+E+R+Items Kill!"	
            end
        end
    end
end

function CastQ(unit)
	if MenuGalio.prConfig.pro == 1 then
		local Position = FreePredictionQ:GetPrediction(unit)
		if Position ~= nil then				
			CastSpell(_Q, Position.x, Position.z)
			return
		end
	end
	if MenuGalio.prConfig.pro == 2 and VIP_USER then
		local Position = VipPredictionQ:GetPrediction(unit)
		if Position ~= nil then
			CastSpell(_Q, Position.x, Position.z)
			return		
		end
	end
	if MenuGalio.prConfig.pro == 3 then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, false)
		if CastPosition and HitChance >= 2 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
			return
		end
	end
	if MenuGalio.prConfig.pro == 4 and VIP_USER and prodstatus then
		local Position = ProdictionQ:GetPrediction(unit)
		if Position ~= nil then
			CastSpell(_Q, Position.x, Position.z)
			return		
		end
	end
end

function CastE(unit)
	if MenuGalio.prConfig.pro == 1 then
		local Position = FreePredictionE:GetPrediction(unit)
		if Position ~= nil then				
			CastSpell(_E, Position.x, Position.z)
			return
		end
	end
	if MenuGalio.prConfig.pro == 2 and VIP_USER then
		local Position = VipPredictionE:GetPrediction(unit)
		if Position ~= nil then
			CastSpell(_E, Position.x, Position.z)
			return		
		end
	end
	if MenuGalio.prConfig.pro == 3 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, skills.skillE.delay, skills.skillE.width, skills.skillE.range, skills.skillE.speed, myHero, false)
		if CastPosition and HitChance >= 2 then
			CastSpell(_E, CastPosition.x, CastPosition.z)
			return
		end
	end
	if MenuGalio.prConfig.pro == 4 and VIP_USER and prodstatus then
		local Position = ProdictionE:GetPrediction(unit)
		if Position ~= nil then
			CastSpell(_E, Position.x, Position.z)
			return		
		end
	end
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

