--[[

	Script Name: GANKGPLANK MASTER 
    Author: kokosik1221
	Last Version: 1.3
	25.08.2014
	
]]--

if myHero.charName ~= "Gangplank" then return end

local AUTOUPDATE = true


--AUTO UPDATE--
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local prodstatus = false
local SCRIPT_NAME = "GangplankMaster"
local version = 1.3
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
--END AUTO UPDATE--
--BOL TRACKER--
HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
id = 74
ScriptName = "GangplankMaster"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
--END BOL TRACKER--

local skills = {
	skillQ = {range = 625},
	skillW = {range = 0},
	skillE = {range = 1400},
	skillR = {range = 99000, speed = math.huge, delay = 0.25, width = 1150},
}
local QReady, WReady, EReady, RReady, IReady, tiamatready, hydraready, brkready, randuinready, yomuready, bilgewaterready, Recall = false, false, false, false, false, false, false, false, false, false, false, false
local abilitylvl, brkrange, hydrarange, yomurange, lastskin, randuinrange, tiamatrange, bilgewaterrange = 0, 450, 275, 275, 0, 275, 275, 450
local EnemyMinions = minionManager(MINION_ENEMY, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, tiamatslot, randuinslot, yomuslot, hydraslot, brkslot, bilgewaterslot = nil, nil, nil, nil, nil, nil, nil
local killstring = {}
		
function OnLoad()
	Menu()
	UpdateWeb(true, ScriptName, id, HWID)
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

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function skinChanged()
	return MenuGP.prConfig.skin1 ~= lastSkin
end

function OnTick()
	Cel = STS:GetTarget(skills.skillQ.range)
	Check()
	if Cel ~= nil and MenuGP.comboConfig.CEnabled then
		Combo()
	end
	if Cel ~= nil and MenuGP.harrasConfig.HEnabled then
		Harrass()
	end
	if Cel ~= nil and MenuGP.harrasConfig.HTEnabled then
		Harrass()
	end
	if MenuGP.farm.Freeze or MenuGP.farm.LaneClear then
		local Mode = MenuGP.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
	end
	if MenuGP.jf.JFEnabled then
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
	KillSteall()
end

function Menu()
	VP = VPrediction()
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC) 
	MenuGP = scriptConfig("Gangplank Master "..version, "Gangplank Master "..version)
	MenuGP:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuGP.Orbwalking)
	MenuGP:addSubMenu("Target selector", "STS")
    STS:AddToMenu(MenuGP.STS)
	--[[--- Combo --]]--
	MenuGP:addSubMenu("[Gangplank Master]: Combo Settings", "comboConfig")
	MenuGP.comboConfig:addParam("USEQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("USEW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("USEE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("USER", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuGP.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--[[--- Harras --]]--
	MenuGP:addSubMenu("[Gangplank Master]: Harras Settings", "harrasConfig")
    MenuGP.harrasConfig:addParam("QH", "Harras Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuGP.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuGP.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	--[[--- Mana Manager --]]--
	MenuGP:addSubMenu("[Gangplank Master]: Mana Settings" , "mpConfig")
	MenuGP.mpConfig:addParam("mptocq", "Min. Mana To Cast Q", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuGP.mpConfig:addParam("mptocw", "Min. Mana To Cast W", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuGP.mpConfig:addParam("mptoce", "Min. Mana To Cast E", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuGP.mpConfig:addParam("mptocr", "Min. Mana To Cast R", SCRIPT_PARAM_SLICE, 5, 0, 100, 0)
	MenuGP.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.mpConfig:addParam("mptohq", "Min. Mana To Harras Q", SCRIPT_PARAM_SLICE, 40, 0, 100, 0) 
	MenuGP.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.mpConfig:addParam("mptofq", "Min. Mana To Farm Q", SCRIPT_PARAM_SLICE, 45, 0, 100, 0) 
	MenuGP.mpConfig:addParam("mptofe", "Min. Mana To Farm E", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
	--[[--- Kill Steal --]]--
	MenuGP:addSubMenu("[Gangplank Master]: KS Settings", "ksConfig")
	MenuGP.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGP.ksConfig:addParam("QKS", "Use Q To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGP.ksConfig:addParam("RKS", "Use R To KS", SCRIPT_PARAM_ONOFF, true)
	MenuGP.ksConfig:addParam("ULTHITS", "Ult hit times:", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
	MenuGP.ksConfig:addParam("ITKS", "Use Items To KS", SCRIPT_PARAM_ONOFF, true)
	--[[--- Farm --]]--
	MenuGP:addSubMenu("[Gangplank Master]: Farm Settings", "farm")
	MenuGP.farm:addParam("QF", "Use Q Farm", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuGP.farm:addParam("EF",  "Use E Farm", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear", "Both" })
	MenuGP.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
	MenuGP.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	--[[--- Jungle Farm --]]--
	MenuGP:addSubMenu("[Gangplank Master]: Jungle Farm Settings", "jf")
	MenuGP.jf:addParam("QJF", "Jungle Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuGP.jf:addParam("EJF", "Jungle Farm Use E", SCRIPT_PARAM_ONOFF, true)
	MenuGP.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--[[--- Extra --]]--
	MenuGP:addSubMenu("[Gangplank Master]: Extra Settings", "exConfig")
	MenuGP.exConfig:addParam("CC", "Anty CC", SCRIPT_PARAM_ONOFF, true)
	MenuGP.exConfig:addParam("aw", "Auto W", SCRIPT_PARAM_ONOFF, true)
	MenuGP.exConfig:addParam("MINHPTOW", "Min % HP To Heal", SCRIPT_PARAM_SLICE, 60, 0, 100, 2)
	MenuGP.exConfig:addParam("MINMPTOW", "Min % MP To Heal", SCRIPT_PARAM_SLICE, 70, 0, 100, 2)	
	--[[--- Drawing --]]--
	MenuGP:addSubMenu("[Gangplank Master]: Draw Settings", "drawConfig")
	MenuGP.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuGP.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,100,0,255})
	MenuGP.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuGP.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuGP.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	--[[--- Misc --]]--
	MenuGP:addSubMenu("[Gangplank Master]: Misc Settings", "prConfig")
	MenuGP.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuGP.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuGP.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 5, 1, 5)
	MenuGP.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuGP.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuGP.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGP.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuGP.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	if MenuGP.prConfig.skin and VIP_USER then
		GenModelPacket("Gangplank", MenuGP.prConfig.skin1)
		lastSkin = MenuGP.prConfig.skin1
	end
	--[[-- PermShow --]]--
	MenuGP.comboConfig:permaShow("CEnabled")
	MenuGP.harrasConfig:permaShow("HEnabled")
	MenuGP.harrasConfig:permaShow("HTEnabled")
	MenuGP.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		IgniteKey = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		IgniteKey = SUMMONER_2
	else
		IgniteKey = nil
	end
end

function cancast()
	--Q--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGP.mpConfig.mptocq then
		ccq = true
	else
		ccq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGP.mpConfig.mptohq then
		chq = true
	else
		chq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGP.mpConfig.mptofq then
		cfq = true
	else
		cfq = false
	end
	--W--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGP.mpConfig.mptocw then
		ccw = true
	else
		ccw = false
	end
	--E--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGP.mpConfig.mptoce then
		cce = true
	else
		cce = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGP.mpConfig.mptofe then
		cfe = true
	else
		cfe = false
	end
	--R--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuGP.mpConfig.mptocr then
		ccr = true
	else
		ccr = false
	end
end

function caa()
	if MenuGP.comboConfig.uaa then
		SOWi:EnableAttacks()
	elseif not MenuGP.comboConfig.uaa then
		SOWi:DisableAttacks()
	end
end

function Check()
	caa()
	DmgCalc()
	cancast()
	EnemyMinions:update()
	JungleMinions:update()
	tiamatslot = GetInventorySlotItem(3077)
	randuinslot = GetInventorySlotItem(3143)
	yomuslot = GetInventorySlotItem(3142)
	hydraslot = GetInventorySlotItem(3074)
	brkslot = GetInventorySlotItem(3153)
	tiamatready = (tiamatslot ~= nil and myHero:CanUseSpell(tiamatslot) == READY)
	hydraready = (hydraslot ~= nil and myHero:CanUseSpell(hydraslot) == READY)
	brkready = (brkslot ~= nil and myHero:CanUseSpell(brkslot) == READY)
	randuinready = (randuinslot ~= nil and myHero:CanUseSpell(randuinslot) == READY)
	yomuready = (yomuslot ~= nil and myHero:CanUseSpell(yomuslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end
	if MenuGP.prConfig.skin and VIP_USER and skinChanged() then
		GenModelPacket("Gangplank", MenuGP.prConfig.skin1)
		lastSkin = MenuGP.prConfig.skin1
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

function UseItems(int)
	if ValidTarget(int) and int ~= nil then
		if tiamatready and GetDistanceSqr(int) < tiamatrange then CastSpell(tiamatslot, int) end
		if bilgewaterready and GetDistanceSqr(int) < bilgewaterrange then CastSpell(bilgewaterslot, int) end
		if yomuready and GetDistanceSqr(int) < yomurange then CastSpell(yomuslot, int) end
		if randuinready and GetDistanceSqr(int) < randuinrange then CastSpell(randuinslot, int) end
		if brkready and GetDistanceSqr(int) < brkrange then CastSpell(brkslot, int) end
		if hydraready and GetDistanceSqr(int) < hydrarange then CastSpell(hydraslot, int) end
	end
end

function Combo()
	UseItems(Cel)
	if MenuGP.comboConfig.USEQ then
		if QReady and MenuGP.comboConfig.USEQ and GetDistance(Cel) < skills.skillQ.range and ccq then
			CastSpell(_Q, Cel)
		end
	end
	if MenuGP.comboConfig.USEW then
		if WReady and MenuGP.comboConfig.USEW and ccw then
			CastSpell(_W)
		end
	end
	if MenuGP.comboConfig.USEE then
		local enemyCount = EnemyCount(myHero, skills.skillE.range)
		if EReady and MenuGP.comboConfig.USEE and enemyCount >= MenuGP.comboConfig.mine then
			CastSpell(_E)
		end
	end
	if MenuGP.comboConfig.USER then
		if RReady and GetDistance(Cel) < skills.skillR.range and MenuGP.comboConfig.USER and ccr then
			CastR(Cel)
		end
	end
end

function Harrass()
	if MenuGP.harrasConfig.QH then
		if QReady and GetDistance(Cel) < skills.skillQ.range and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and chq then
			if MenuGP.harrasConfig.QHS then
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
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				CastSpell(_Q, minion)
			end
		end
	end
	if UseE then
		for i, minion in pairs(EnemyMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range and cfe then
				CastSpell(_E)
			end
		end
	end
end

function JungleFarmm()
	if MenuGP.jf.QJF then
		for i, minion in pairs(JungleMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				CastSpell(_Q, minion)
			end
		end
	end
	if MenuGP.jf.EJF then
		for i, minion in pairs(JungleMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range and cfq then
				CastSpell(_E)
			end
		end
	end
end

function autow()
	if MenuGP.exConfig.aw and not Recall and WReady then
		if ((myHero.mana/myHero.maxMana)*100) > MenuGP.exConfig.MINMPTOW and  ((myHero.health/myHero.maxHealth)*100) < MenuGP.exConfig.MINHPTOW then
			CastSpell(_W)
		end
	end
end

function cc()
	if MenuGP.exConfig.CC and WReady then
		myPlayer = GetMyHero()
		if myPlayer.canMove == false then
			CastSpell(_W)
		end
		if myPlayer.isTaunted == true then
			CastSpell(_W)
		end
		if myPlayer.isFleeing == true then
			CastSpell(_W)
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
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuGP.drawConfig.DLC then
		if MenuGP.drawConfig.DQR and QReady then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillQ.range - 90, 1, RGB(MenuGP.drawConfig.DQRC[2], MenuGP.drawConfig.DQRC[3], MenuGP.drawConfig.DQRC[4]))
		end
		if MenuGP.drawConfig.DWR and WReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillW.range - 80, 1, RGB(MenuGP.drawConfig.DWRC[2], MenuGP.drawConfig.DWRC[3], MenuGP.drawConfig.DWRC[4]))
		end
		if MenuGP.drawConfig.DER and EReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillE.range - 60, 1, RGB(MenuGP.drawConfig.DERC[2], MenuGP.drawConfig.DERC[3], MenuGP.drawConfig.DERC[4]))
		end
		if MenuGP.drawConfig.DRR then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillR.range - 10, 1, RGB(MenuGP.drawConfig.DRRC[2], MenuGP.drawConfig.DRRC[3], MenuGP.drawConfig.DRRC[4]))
		end
	else
		if MenuGP.drawConfig.DQR and QReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, ARGB(MenuGP.drawConfig.DQRC[1], MenuGP.drawConfig.DQRC[2], MenuGP.drawConfig.DQRC[3], MenuGP.drawConfig.DQRC[4]))
		end
		if MenuGP.drawConfig.DWR and WReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillW.range, ARGB(MenuGP.drawConfig.DWRC[1], MenuGP.drawConfig.DWRC[2], MenuGP.drawConfig.DWRC[3], MenuGP.drawConfig.DWRC[4]))
		end
		if MenuGP.drawConfig.DER and EReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, ARGB(MenuGP.drawConfig.DERC[1], MenuGP.drawConfig.DERC[2], MenuGP.drawConfig.DERC[3], MenuGP.drawConfig.DERC[4]))
		end
		if MenuGP.drawConfig.DRR and RReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillR.range, ARGB(MenuGP.drawConfig.DRRC[1], MenuGP.drawConfig.DRRC[2], MenuGP.drawConfig.DRRC[3], MenuGP.drawConfig.DRRC[4]))
		end
	end
end

function KillSteall()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		local health = Enemy.health
		local distance = GetDistance(Enemy)
		if MenuGP.ksConfig.QKS then
			qDmg = getDmg("Q", Enemy, myHero)
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
		if MenuGP.ksConfig.ITKS then
			bilgewaterDmg = ((bilgewaterready and getDmg("BWC", Enemy, myHero)) or 0)
			tiamatdmg = ((tiamatready and getDmg("TIAMAT", Enemy, myHero)) or 0)
			brkdmg = ((brkready and getDmg("RUINEDKING", Enemy, myHero)) or 0)
			hydradmg = ((hydraready and getDmg("HYDRA", Enemy, myHero)) or 0)
			itemsDmg = bilgewaterDmg + tiamatdmg + brkdmg + hydradmg
		else
			itemsDmg = 0
		end
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health <= qDmg and QReady and (distance < skills.skillQ.range) and MenuGP.ksConfig.QKS then
				CastSpell(_Q, Enemy)
			elseif health < rDmg and RReady and (distance < skills.skillR.range) and MenuGP.ksConfig.RKS then
				CastR(Enemy)
			elseif health < (qDmg + rDmg) and QReady and RReady and (distance < skills.skillR.range) then
				CastR(Enemy)
			elseif health < (qDmg + rDmg + itemsDmg) and MenuGP.ksConfig.ITKS then
				if QReady and RReady then
					UseItems(Enemy)
				end
			elseif health < (qDmg + wDmg + itemsDmg) and health > (qDmg + wDmg) then
				if QReady and WReady then
					UseItems(Enemy)
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
            local qDmg = getDmg("Q", enemy, myHero)
			local rDmg = getDmg("R", enemy, myHero)
			local rDmg = getDmg("R", enemy, myHero) * MenuGP.ksConfig.ULTHITS + (myHero.ap * 0.2)
			local bilgewaterDmg = ((bilgewaterready and getDmg("BWC", enemy, myHero)) or 0)
			local tiamatdmg = ((tiamatready and getDmg("TIAMAT", enemy, myHero)) or 0)
			local brkdmg = ((brkready and getDmg("RUINEDKING", enemy, myHero)) or 0)
			local hydradmg = ((hydraready and getDmg("HYDRA", enemy, myHero)) or 0)
			itemsDmg = bilgewaterDmg + tiamatdmg + brkdmg + hydradmg
            if enemy.health > (qDmg + rDmg) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < qDmg then
				killstring[enemy.networkID] = "Q Kill!"
            elseif enemy.health < rDmg then
				killstring[enemy.networkID] = "R Kill!"
			elseif enemy.health < (qDmg + rDmg) then
                killstring[enemy.networkID] = "Q+R Kill!"	
			elseif enemy.health < (qDmg + itemsDmg) then
				killstring[enemy.networkID] = "Q+Items Kill!"
            elseif enemy.health < (rDmg + itemsDmg) then
				killstring[enemy.networkID] = "R+Items Kill!"
			elseif enemy.health < (qDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+R+Items Kill!"	
            end
        end
    end
end

function SpellCast(spellSlot,castPosition)
	if VIP_USER and MenuGP.prConfig.pc then
		Packet("S_CAST", {spellId = spellSlot, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
	else
		CastSpell(spellSlot,castPosition.x,castPosition.z)
	end
end

function CastR(unit)
	if MenuGP.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, skills.skillR.delay, skills.skillR.width, skills.skillR.range, skills.skillR.speed, myHero, false)
		if CastPosition and HitChance >= MenuGP.prConfig.vphit - 1 then
			SpellCast(_R, CastPosition)
			return
		end
	end
	if MenuGP.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, skills.skillR.range, skills.skillR.speed, skills.skillR.delay, skills.skillR.width)
		if Position ~= nil then
			SpellCast(_R, Position)
			return		
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
