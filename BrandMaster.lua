--[[

	Script Name: BRAND MASTER 
    	Author: kokosik1221
	Last Version: 0.5
	07.09.2014
	
]]--
	
if myHero.charName ~= "Brand" then return end

local AUTOUPDATE = true



--AUTO UPDATE--
local version = 0.5
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
ScriptName = "BrandMaster"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
--END BOL TRACKER--

local skills = {
	skillQ = {range = 1100, speed = 1600, delay = 0.25, width = 60},
	skillW = {range = 900, speed = math.huge, delay = 1, width = 240},
	skillE = {range = 625},
	skillR = {range = 750},
}
local QReady, WReady, EReady, RReady, IReady, hextechready, deathfiregraspready, blackfiretorchready, woogletready, zhonyaready = false, false, false, false, false, false, false, false, false, false
local abilitylvl, blackfiretorchrange, deathfiregrasprange, hextechrange, lastskin = 0, 600, 600, 600, 0
local EnemyMinions = minionManager(MINION_ENEMY, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, zhonyaslot, woogletslot, hextechslot, deathfiregraspslot, blackfiretorchslot = nil, nil, nil, nil, nil, nil
local killstring = {}

function OnLoad()
	Menu()
	UpdateWeb(true, ScriptName, id, HWID)
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function skinChanged()
	return MenuBrand.prConfig.skin1 ~= lastSkin
end

function Havepasive(target)
	return HasBuff(target, "brandablaze")
end

function OnTick()
	Check()
	if Cel ~= nil and MenuBrand.comboConfig.CEnabled then
		caa()
		Combo()
	end
	if Cel ~= nil and MenuBrand.harrasConfig.HEnabled then
		Harrass()
	end
	if Cel ~= nil and MenuBrand.harrasConfig.HTEnabled then
		Harrass()
	end
	if MenuBrand.farm.Freeze or MenuBrand.farm.LaneClear then
		local Mode = MenuBrand.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
	end
	if MenuBrand.jf.JFEnabled then
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
	KillSteall()
end

function Menu()
	VP = VPrediction()
	SOWi = SOW(VP)
	MenuBrand = scriptConfig("Brand Master "..version, "Brand Master "..version)
	MenuBrand:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuBrand.Orbwalking)
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, skills.skillQ.range, DAMAGE_MAGIC)
	TargetSelector.name = "Brand"
	MenuBrand:addSubMenu("Target selector", "STS")
	MenuBrand.STS:addTS(TargetSelector)
	--[[--- Combo --]]--
	MenuBrand:addSubMenu("[Brand Master]: Combo Settings", "comboConfig")
	MenuBrand.comboConfig:addSubMenu("Q Options", "qConfig")
	MenuBrand.comboConfig.qConfig:addParam("USEQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig.qConfig:addParam("USEQS", "Use Only If Target Is Ablazed", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.comboConfig:addSubMenu("W Options", "wConfig")
	MenuBrand.comboConfig.wConfig:addParam("USEW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addSubMenu("E Options", "eConfig")
	MenuBrand.comboConfig.eConfig:addParam("USEE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addSubMenu("R Options", "rConfig")
	MenuBrand.comboConfig.rConfig:addParam("USER", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig.rConfig:addParam("ENEMYTOR", "Min Enemies to Cast R: ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuBrand.comboConfig.rConfig:addParam("Ablazed", "Only Use If Target Is Ablazed", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig.rConfig:addParam("Kilable", "Only Use If Target Is Killable", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addParam("CT", "Combo Type", SCRIPT_PARAM_LIST, 2, { "Q>W>E>R", "W>Q>E>R", "E>Q>W>R", "E>W>Q>R"})
	MenuBrand.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--[[--- Harras --]]--
	MenuBrand:addSubMenu("[Brand Master]: Harras Settings", "harrasConfig")
    MenuBrand.harrasConfig:addParam("QH", "Harras Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.harrasConfig:addParam("QHS", "Use Only If Target Is Ablazed", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("WH", "Harras Use W", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("EH", "Harras Use E", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuBrand.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	--[[--- Mana Manager --]]--
	MenuBrand:addSubMenu("[Brand Master]: Mana Settings" , "mpConfig")
	MenuBrand.mpConfig:addParam("mptocq", "Min. Mana To Cast Q", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuBrand.mpConfig:addParam("mptocw", "Min. Mana To Cast W", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuBrand.mpConfig:addParam("mptoce", "Min. Mana To Cast E", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuBrand.mpConfig:addParam("mptocr", "Min. Mana To Cast R", SCRIPT_PARAM_SLICE, 5, 0, 100, 0)
	MenuBrand.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.mpConfig:addParam("mptohq", "Min. Mana To Harras Q", SCRIPT_PARAM_SLICE, 35, 0, 100, 0) 
	MenuBrand.mpConfig:addParam("mptohw", "Min. Mana To Harras W", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
	MenuBrand.mpConfig:addParam("mptohe", "Min. Mana To Harras E", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
	MenuBrand.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.mpConfig:addParam("mptofq", "Min. Mana To Farm Q", SCRIPT_PARAM_SLICE, 25, 0, 100, 0) 
	MenuBrand.mpConfig:addParam("mptofw", "Min. Mana To Farm W", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
	MenuBrand.mpConfig:addParam("mptofe", "Min. Mana To Farm E", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
	--[[--- Kill Steal --]]--
	MenuBrand:addSubMenu("[Brand Master]: KS Settings", "ksConfig")
	MenuBrand.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("QKS", "Use Q To KS", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("WKS", "Use W To KS", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("EKS", "Use E To KS", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("RKS", "Use R To KS", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("ITKS", "Use Items To KS", SCRIPT_PARAM_ONOFF, true)
	--[[--- Farm --]]--
	MenuBrand:addSubMenu("[Brand Master]: Farm Settings", "farm")
	MenuBrand.farm:addParam("QF", "Use Q Farm", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuBrand.farm:addParam("WF",  "Use W Farm", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuBrand.farm:addParam("EF",  "Use E Farm", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuBrand.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
	MenuBrand.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	--[[--- Jungle Farm --]]--
	MenuBrand:addSubMenu("[Brand Master]: Jungle Farm Settings", "jf")
	MenuBrand.jf:addParam("QJF", "Jungle Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("WJF", "Jungle Farm Use W", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("EJF", "Jungle Farm Use E", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--[[--- Extra --]]--
	MenuBrand:addSubMenu("[Brand Master]: Extra Settings", "exConfig")
	MenuBrand.exConfig:addParam("AQ", "Auto Q On Stunned Enemy", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.exConfig:addParam("AW", "Auto W On Stunned Enemy", SCRIPT_PARAM_ONOFF, false)
	--[[--- Drawing --]]--
	MenuBrand:addSubMenu("[Brand Master]: Draw Settings", "drawConfig")
	MenuBrand.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
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
	--[[--- Misc --]]--
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
	if MenuBrand.prConfig.skin and VIP_USER then
		GenModelPacket("Brand", MenuBrand.prConfig.skin1)
		lastSkin = MenuBrand.prConfig.skin1
	end
	--[[-- PermShow --]]--
	MenuBrand.comboConfig:permaShow("CEnabled")
	MenuBrand.harrasConfig:permaShow("HEnabled")
	MenuBrand.harrasConfig:permaShow("HTEnabled")
	MenuBrand.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
end

function cancast()
	--Q--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptocq then
		ccq = true
	else
		ccq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptohq then
		chq = true
	else
		chq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptofq then
		cfq = true
	else
		cfq = false
	end
	--W--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptocw then
		ccw = true
	else
		ccw = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptohw then
		chw = true
	else
		chw = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptofw then
		cfw = true
	else
		cfw = false
	end
	--E--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptoce then
		cce = true
	else
		cce = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptohe then
		che = true
	else
		che = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptofe then
		cfe = true
	else
		cfe = false
	end
	--R--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.mpConfig.mptocr then
		ccr = true
	else
		ccr = false
	end
end

function caa()
	if MenuBrand.comboConfig.uaa then
		SOWi:EnableAttacks()
	elseif not MenuBrand.comboConfig.uaa then
		SOWi:DisableAttacks()
	end
end

function Check()
	TargetSelector:update()
	Cel = TargetSelector.target
	SOWi:ForceTarget(Cel)
	DmgCalc()
	cancast()
	zhonyaslot = GetInventorySlotItem(3157)
	woogletslot = GetInventorySlotItem(3090)
	hextechslot = GetInventorySlotItem(3146)
	deathfiregraspslot = GetInventorySlotItem(3128)
	blackfiretorchslot = GetInventorySlotItem(3188)
	hextechready = (hextechslot ~= nil and myHero:CanUseSpell(hextechslot) == READY)
	deathfiregraspready = (deathfiregraspslot ~= nil and myHero:CanUseSpell(deathfiregraspslot) == READY)
	blackfiretorchready = (blackfiretorchslot ~= nil and myHero:CanUseSpell(blackfiretorchslot) == READY)
	woogletready = (woogletslot ~= nil and myHero:CanUseSpell(woogletslot) == READY)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end
	if MenuBrand.prConfig.skin and VIP_USER and skinChanged() then
		GenModelPacket("Brand", MenuBrand.prConfig.skin1)
		lastSkin = MenuBrand.prConfig.skin1
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
		if blackfiretorchready and GetDistance(int) < blackfiretorchrange then CastSpell(blackfiretorchslot, int) end
		if deathfiregraspready and GetDistance(int) < deathfiregrasprange then CastSpell(deathfiregraspslot, int) end
		if hextechready and GetDistance(int) < hextechrange then CastSpell(hextechslot, int) end
	end
end

--COMBO--
function Combo()
	UseItems(Cel)
	if MenuBrand.comboConfig.CT == 1 then
		comboQWER()
	elseif MenuBrand.comboConfig.CT == 2 then
		comboWQER()
	elseif MenuBrand.comboConfig.CT == 3 then
		comboEQWR()
	elseif MenuBrand.comboConfig.CT == 4 then
		comboEWQR()
	end
end

function comboQWER()
	if ValidTarget(Cel, skills.skillQ.range) then
		if QReady and ccq and MenuBrand.comboConfig.qConfig.USEQ then
			if MenuBrand.comboConfig.qConfig.USEQS then
				if Havepasive(Cel) then
					CastQ(Cel)
				end
			elseif not MenuBrand.comboConfig.qConfig.USEQS then
				CastQ(Cel)
			end
		end
		if WReady and ccw and MenuBrand.comboConfig.wConfig.USEW then
			CastW(Cel)
		end
		if EReady and cce and MenuBrand.comboConfig.eConfig.USEE then
			CastSpell(_E, Cel)
		end
		CastRC()
	end
end

function comboWQER()
	if ValidTarget(Cel, skills.skillW.range) then
		if WReady and ccw and MenuBrand.comboConfig.wConfig.USEW then
			CastW(Cel)
		end
		if QReady and ccq and MenuBrand.comboConfig.qConfig.USEQ then
			if MenuBrand.comboConfig.qConfig.USEQS then
				if Havepasive(Cel) then
					CastQ(Cel)
				end
			elseif not MenuBrand.comboConfig.qConfig.USEQS then
				CastQ(Cel)
			end
		end
		if EReady and cce and MenuBrand.comboConfig.eConfig.USEE then
			CastSpell(_E, Cel)
		end
		CastRC()
	end
end

function comboEQWR()
	if ValidTarget(Cel, skills.skillE.range) then
		if EReady and cce and MenuBrand.comboConfig.eConfig.USEE then
			CastSpell(_E, Cel)
		end
		if QReady and ccq and MenuBrand.comboConfig.qConfig.USEQ then
			if MenuBrand.comboConfig.qConfig.USEQS then
				if Havepasive(Cel) then
					CastQ(Cel)
				end
			elseif not MenuBrand.comboConfig.qConfig.USEQS then
				CastQ(Cel)
			end
		end
		if WReady and ccw and MenuBrand.comboConfig.wConfig.USEW then
			CastW(Cel)
		end
		CastRC()
	end
end

function comboEWQR()
	if ValidTarget(Cel, skills.skillE.range) then
		if EReady and cce and MenuBrand.comboConfig.eConfig.USEE then
			CastSpell(_E, Cel)
		end
		if WReady and ccw and MenuBrand.comboConfig.wConfig.USEW then
			CastW(Cel)
		end
		if QReady and ccq and MenuBrand.comboConfig.qConfig.USEQ then
			if MenuBrand.comboConfig.qConfig.USEQS then
				if Havepasive(Cel) then
					CastQ(Cel)
				end
			elseif not MenuBrand.comboConfig.qConfig.USEQS then
				CastQ(Cel)
			end
		end
		CastRC()
	end
end

function CastRC()
	local enemyCount = EnemyCount(myHero, skills.skillR.range)
	if RReady and ValidTarget(Cel, skills.skillR.range) and MenuBrand.comboConfig.rConfig.USER and enemyCount >= MenuBrand.comboConfig.rConfig.ENEMYTOR and ccr then
		if MenuBrand.comboConfig.rConfig.Ablazed then
			if Havepasive(Cel) then
				CastSpell(_R, Cel)
			end
		elseif MenuBrand.comboConfig.rConfig.Kilable then
			local rdmg = getDmg("R", Cel, myHero)
			if Cel.health < rdmg then
				CastSpell(_R, Cel)
			end
		elseif not MenuBrand.comboConfig.rConfig.Ablazed or not MenuBrand.comboConfig.rConfig.Kilable then
			CastSpell(_R, Cel)
		end
	end
end
--END COMBO--

--HARRAS--
function Harrass()
	if MenuBrand.harrasConfig.QH then
		if QReady and ValidTarget(Cel, skills.skillQ.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and chq then
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
		if WReady and ValidTarget(Cel, skills.skillW.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and chw then
			CastW(Cel)
		end
	end
	if MenuBrand.harrasConfig.EH then
		if EReady and ValidTarget(Cel, skills.skillE.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and che then
			CastSpell(_E, Cel)
		end
	end
end
--END HARRAS--

--FARM--
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
	
	if UseQ then
		for i, minion in pairs(EnemyMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				CastQ(minion)
			end
		end
	end

	if UseW then
		for i, minion in pairs(EnemyMinions.objects) do
			if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillW.range and cfw then
				local Pos, Hit = BestWFarmPos(skills.skillW.range, skills.skillW.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
		end
	end
	
	if UseE then
		for i, minion in pairs(EnemyMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range and cfe then
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
--END FARM--

--JUNGLE FARM--
function JungleFarmm()
	JungleMinions:update()
	if MenuBrand.jf.QJF then
		for i, minion in pairs(JungleMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				local Pos, Hit = BestWFarmPos(skills.skillQ.range, skills.skillQ.width, JungleMinions.objects)
				if Pos ~= nil then
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		end
	end
	if MenuBrand.jf.WJF then
		for i, minion in pairs(JungleMinions.objects) do
			if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillW.range and cfw then
				local Pos, Hit = BestWFarmPos(skills.skillW.range, skills.skillW.width, JungleMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
		end
	end
	if MenuBrand.jf.EJF then
		for i, minion in pairs(JungleMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				if Havepasive(minion) then
					CastSpell(_E, minion)
				end
			end
		end
	end
end
--END JUNGLE FARM--

function AutoQ()
	players = heroManager.iCount
    for i = 1, players, 1 do
        targetq = heroManager:getHero(i)
        if targetq ~= nil and targetq.team ~= player.team and targetq.visible and not targetq.dead then
            if ValidTarget(targetq, skills.skillQ.range) and WReady and not targetq.CanMove then
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
            if ValidTarget(target, skills.skillW.range) and WReady and not target.CanMove then
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
--END EXTRA--

--DRAWING--
function OnDraw()
	if MenuBrand.drawConfig.DQL and ValidTarget(Cel, skills.skillQ.range) and not GetMinionCollision(myHero, Cel, skills.skillQ.width) then
		QMark = Cel
		DrawLine3D(myHero.x, myHero.y, myHero.z, QMark.x, QMark.y, QMark.z, skills.skillQ.width, ARGB(MenuBrand.drawConfig.DQLC[1], MenuBrand.drawConfig.DQLC[2], MenuBrand.drawConfig.DQLC[3], MenuBrand.drawConfig.DQLC[4]))
	end
	if MenuBrand.drawConfig.DD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuBrand.drawConfig.DLC then
		if MenuBrand.drawConfig.DQR and QReady then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillQ.range - 90, 1, RGB(MenuBrand.drawConfig.DQRC[2], MenuBrand.drawConfig.DQRC[3], MenuBrand.drawConfig.DQRC[4]))
		end
		if MenuBrand.drawConfig.DWR and WReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillW.range - 80, 1, RGB(MenuBrand.drawConfig.DWRC[2], MenuBrand.drawConfig.DWRC[3], MenuBrand.drawConfig.DWRC[4]))
		end
		if MenuBrand.drawConfig.DER and EReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillE.range - 60, 1, RGB(MenuBrand.drawConfig.DERC[2], MenuBrand.drawConfig.DERC[3], MenuBrand.drawConfig.DERC[4]))
		end
		if MenuBrand.drawConfig.DRR then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillR.range - 10, 1, RGB(MenuBrand.drawConfig.DRRC[2], MenuBrand.drawConfig.DRRC[3], MenuBrand.drawConfig.DRRC[4]))
		end
	else
		if MenuBrand.drawConfig.DQR and QReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, ARGB(MenuBrand.drawConfig.DQRC[1], MenuBrand.drawConfig.DQRC[2], MenuBrand.drawConfig.DQRC[3], MenuBrand.drawConfig.DQRC[4]))
		end
		if MenuBrand.drawConfig.DWR and WReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillW.range, ARGB(MenuBrand.drawConfig.DWRC[1], MenuBrand.drawConfig.DWRC[2], MenuBrand.drawConfig.DWRC[3], MenuBrand.drawConfig.DWRC[4]))
		end
		if MenuBrand.drawConfig.DER and EReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, ARGB(MenuBrand.drawConfig.DERC[1], MenuBrand.drawConfig.DERC[2], MenuBrand.drawConfig.DERC[3], MenuBrand.drawConfig.DERC[4]))
		end
		if MenuBrand.drawConfig.DRR and RReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillR.range, ARGB(MenuBrand.drawConfig.DRRC[1], MenuBrand.drawConfig.DRRC[2], MenuBrand.drawConfig.DRRC[3], MenuBrand.drawConfig.DRRC[4]))
		end
	end
end
--END DRAWING--

function KillSteall()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		local health = Enemy.health
		local distance = GetDistance(Enemy)
		if MenuBrand.ksConfig.QKS then
			qDmg = getDmg("Q", Enemy, myHero)
		else 
			qDmg = 0
		end
		if MenuBrand.ksConfig.WKS then
			wDmg = getDmg("W", Enemy, myHero)
		else 
			wDmg = 0
		end
		if MenuBrand.ksConfig.EKS then
			eDmg = getDmg("E", Enemy, myHero)
		else 
			eDmg = 0
		end
		if MenuBrand.ksConfig.RKS then
			rDmg = getDmg("R", Enemy, myHero)
		else 
			rDmg = 0
		end
		if MenuBrand.ksConfig.IKS then
			iDmg = getDmg("IGNITE", Enemy, myHero)
		else 
			iDmg = 0
		end
		if MenuBrand.ksConfig.ITKS then
			deathfiregraspDmg = ((deathfiregraspready and getDmg("DFG", Enemy, myHero)) or 0)
			hextechDmg = ((hextechready and getDmg("HXG", Enemy, myHero)) or 0)
			blackfiretorchdmg = ((blackfiretorchready and getDmg("BLACKFIRE", Enemy, myHero)) or 0)
			itemsDmg = deathfiregraspDmg + hextechDmg + blackfiretorchdmg 
		else
			itemsDmg = 0
		end
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health <= qDmg and QReady and (distance < skills.skillQ.range) and MenuBrand.ksConfig.QKS then
				CastQ(Enemy)
			elseif health < wDmg and WReady and (distance < skills.skillW.range) and MenuBrand.ksConfig.WKS then
				CastW(Enemy)
			elseif health < eDmg and EReady and (distance < skills.skillE.range) and MenuBrand.ksConfig.EKS then
				CastSpell(_E, Enemy)
			elseif health < rDmg and RReady and (distance < skills.skillR.range) and MenuBrand.ksConfig.RKS then
				CastSpell(_R, Enemy)
			elseif health < (qDmg + wDmg) and QReady and WReady and (distance < skills.skillW.range) and MenuBrand.ksConfig.WKS then
				CastW(Enemy)
			elseif health < (qDmg + rDmg) and QReady and RReady and (distance < skills.skillR.range) and MenuBrand.ksConfig.RKS then
				CastSpell(_R, Enemy)
			elseif health < (wDmg + rDmg) and WReady and RReady and (distance < skills.skillW.range) and MenuBrand.ksConfig.WKS then
				CastW(Enemy)
			elseif health < (qDmg + wDmg + rDmg) and QReady and WReady and RReady and (distance < skills.skillR.range) and MenuBrand.ksConfig.RKS then
				CastSpell(_R, Enemy)
			elseif health < (qDmg + wDmg + rDmg + itemsDmg) and MenuBrand.ksConfig.ITKS then
				if QReady and WReady and RReady then
					UseItems(Enemy)
				end
			elseif health < (qDmg + wDmg + itemsDmg) and health > (qDmg + wDmg) then
				if QReady and WReady then
					UseItems(Enemy)
				end
			end
			if IReady and health <= iDmg and MenuBrand.ksConfig.IKS and distance < 600 then
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
            local wDmg = getDmg("W", enemy, myHero)
			local eDmg = getDmg("E", enemy, myHero)
			local rDmg = getDmg("R", enemy, myHero)
			local deathfiregraspDmg = ((deathfiregraspready and getDmg("DFG", enemy, myHero)) or 0)
			local hextechDmg = ((hextechready and getDmg("HXG", enemy, myHero)) or 0)
			local bilgewaterDmg = ((bilgewaterready and getDmg("BWC", enemy, myHero)) or 0)
			local blackfiretorchdmg = ((blackfiretorchready and getDmg("BLACKFIRE", enemy, myHero)) or 0)
			local tiamatdmg = ((tiamatready and getDmg("TIAMAT", enemy, myHero)) or 0)
			local brkdmg = ((brkready and getDmg("RUINEDKING", enemy, myHero)) or 0)
			local hydradmg = ((hydraready and getDmg("HYDRA", enemy, myHero)) or 0)
			itemsDmg = deathfiregraspDmg + hextechDmg + bilgewaterDmg + blackfiretorchdmg + tiamatdmg + brkdmg + hydradmg
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
			elseif enemy.health < (qDmg + itemsDmg) then
				killstring[enemy.networkID] = "Q+Items Kill!"
			elseif enemy.health < (wDmg + itemsDmg) then
				killstring[enemy.networkID] = "W+Items Kill!"
			elseif enemy.health < (eDmg + itemsDmg) then
				killstring[enemy.networkID] = "E+Items Kill!"
            elseif enemy.health < (rDmg + itemsDmg) then
				killstring[enemy.networkID] = "R+Items Kill!"
            elseif enemy.health < (qDmg + wDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+W+Items Kill!"
			elseif enemy.health < (qDmg + eDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+E+Items Kill!"	
			elseif enemy.health < (qDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+R+Items Kill!"	
			elseif enemy.health < (wDmg + eDmg + itemsDmg) then
                killstring[enemy.networkID] = "W+E+Items Kill!"	
			elseif enemy.health < (wDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "W+R+Items Kill!"	
			elseif enemy.health < (qDmg + wDmg + eDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+W+E+R+Items Kill!"	
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
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, true)
		if CastPosition and HitChance >= MenuBrand.prConfig.vphit - 1 then
			SpellCast(_Q, CastPosition)
		end
	end
	if MenuBrand.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width)
		if Position ~= nil and not info.mCollision() then
			SpellCast(_Q, Position)	
		end
	end
end

function CastW(unit)
	if MenuBrand.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, skills.skillW.delay, skills.skillW.width, skills.skillW.range, skills.skillW.speed, myHero, true)
		if CastPosition and HitChance >= MenuBrand.prConfig.vphit - 1 then
			SpellCast(_W, CastPosition)
			return
		end
	end
	if MenuBrand.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, skills.skillW.range, skills.skillW.speed, skills.skillW.delay, skills.skillW.width)
		if Position ~= nil then
			SpellCast(_W, Position)
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
