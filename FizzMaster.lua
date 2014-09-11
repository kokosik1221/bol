--[[

	Script Name: FIZZ MASTER 
    Author: kokosik1221
	Last Version: 0.1
	11.09.2014
	
]]--
	
if myHero.charName ~= "Fizz" then return end

local AUTOUPDATE = true



--AUTO UPDATE--
local version = 0.1
local SCRIPT_NAME = "FizzMaster"
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
ScriptName = "FizzMaster"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
--END BOL TRACKER--

local skills = {
	skillQ = {name = "Urchin Strike", range = 550},
	skillW = {name = "Seastone Trident"},
	skillE = {name = "Playful", range = 400},
	skillR = {name = "Chum the Waters", range = 1275, speed = 1.38, delay = 242, width = 500},
}
local QReady, WReady, EReady, RReady, IReady, hextechready, deathfiregraspready, blackfiretorchready, zhonyaready = false, false, false, false, false, false, false, false, false
local abilitylvl, blackfiretorchrange, deathfiregrasprange, hextechrange, lastskin, aarange = 0, 600, 600, 600, 0, 175
local EnemyMinions = minionManager(MINION_ENEMY, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, zhonyaslot, hextechslot, deathfiregraspslot, blackfiretorchslot = nil, nil, nil, nil, nil
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
	return MenuFizz.prConfig.skin1 ~= lastSkin
end

function OnTick()
	Check()
	if Cel ~= nil and MenuFizz.comboConfig.CEnabled then
		caa()
		Combo()
	end
	if Cel ~= nil and MenuFizz.harrasConfig.HEnabled then
		Harrass()
	end
	if Cel ~= nil and MenuFizz.harrasConfig.HTEnabled then
		Harrass()
	end
	if MenuFizz.farm.Freeze or MenuFizz.farm.LaneClear then
		local Mode = MenuFizz.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
	end
	if MenuFizz.jf.JFEnabled then
		JungleFarmm()
	end
	if MenuFizz.prConfig.AZ then
		autozh()
	end
	if MenuFizz.prConfig.ALS then
		autolvl()
	end
	KillSteall()
end

function Menu()
	VP = VPrediction()
	SOWi = SOW(VP)
	MenuFizz = scriptConfig("Fizz Master "..version, "Fizz Master "..version)
	MenuFizz:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuFizz.Orbwalking)
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, skills.skillR.range, DAMAGE_MAGIC)
	TargetSelector.name = "Fizz"
	MenuFizz:addSubMenu("Target selector", "STS")
	MenuFizz.STS:addTS(TargetSelector)
	--[[--- Combo --]]--
	MenuFizz:addSubMenu("[Fizz Master]: Combo Settings", "comboConfig")
	MenuFizz.comboConfig:addParam("USEQ", "Use " .. skills.skillQ.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("USEW", "Use " .. skills.skillW.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("USEE", "Use " .. skills.skillE.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("USEE2", "Use Double " .. skills.skillE.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("USER", "Use " .. skills.skillR.name .. "(R)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("Kilable", "Only Use If Target Is Killable", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("CT", "Combo Type", SCRIPT_PARAM_LIST, 1, { "Q>R>W>E", "R>Q>W>E"})
	MenuFizz.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--[[--- Harras --]]--
	MenuFizz:addSubMenu("[Fizz Master]: Harras Settings", "harrasConfig")
    MenuFizz.harrasConfig:addParam("QH", "Harras Use " .. skills.skillQ.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.harrasConfig:addParam("WH", "Harras Use " .. skills.skillW.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuFizz.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	--[[--- Mana Manager --]]--
	MenuFizz:addSubMenu("[Fizz Master]: Mana Settings" , "mpConfig")
	MenuFizz.mpConfig:addParam("mptocq", "Min. Mana To Cast Q", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuFizz.mpConfig:addParam("mptocw", "Min. Mana To Cast W", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuFizz.mpConfig:addParam("mptoce", "Min. Mana To Cast E", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuFizz.mpConfig:addParam("mptocr", "Min. Mana To Cast R", SCRIPT_PARAM_SLICE, 5, 0, 100, 0)
	MenuFizz.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.mpConfig:addParam("mptohq", "Min. Mana To Harras Q", SCRIPT_PARAM_SLICE, 35, 0, 100, 0) 
	MenuFizz.mpConfig:addParam("mptohw", "Min. Mana To Harras W", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
	MenuFizz.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.mpConfig:addParam("mptofq", "Min. Mana To Farm Q", SCRIPT_PARAM_SLICE, 25, 0, 100, 0) 
	MenuFizz.mpConfig:addParam("mptofw", "Min. Mana To Farm W", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
	MenuFizz.mpConfig:addParam("mptofe", "Min. Mana To Farm E", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
	--[[--- Kill Steal --]]--
	MenuFizz:addSubMenu("[Fizz Master]: KS Settings", "ksConfig")
	MenuFizz.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.ksConfig:addParam("ITKS", "Use Items To KS", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.ksConfig:addParam("QKS", "Use " .. skills.skillQ.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.ksConfig:addParam("WKS", "Use " .. skills.skillW.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.ksConfig:addParam("EKS", "Use " .. skills.skillE.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.ksConfig:addParam("RKS", "Use " .. skills.skillR.name .. "(R)", SCRIPT_PARAM_ONOFF, false)
	--[[--- Farm --]]--
	MenuFizz:addSubMenu("[Fizz Master]: Farm Settings", "farm")
	MenuFizz.farm:addParam("QF", "Use " .. skills.skillQ.name .. "(Q)", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuFizz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.farm:addParam("WF",  "Use " .. skills.skillW.name .. "(W)", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuFizz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.farm:addParam("EF",  "Use " .. skills.skillE.name .. "(E)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuFizz.farm:addParam("EF2", "Use Double " .. skills.skillE.name .. "(E)", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
	MenuFizz.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	--[[--- Jungle Farm --]]--
	MenuFizz:addSubMenu("[Fizz Master]: Jungle Farm Settings", "jf")
	MenuFizz.jf:addParam("QJF", "Use " .. skills.skillQ.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.jf:addParam("WJF", "Use " .. skills.skillW.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.jf:addParam("EJF", "Use " .. skills.skillE.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.jf:addParam("EJF2", "Use Double " .. skills.skillE.name .. "(E)", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--[[--- Extra --]]--
	MenuFizz:addSubMenu("[Fizz Master]: Extra Settings", "exConfig")
	
	--[[--- Drawing --]]--
	MenuFizz:addSubMenu("[Fizz Master]: Draw Settings", "drawConfig")
	MenuFizz.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuFizz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuFizz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	--[[--- Misc --]]--
	MenuFizz:addSubMenu("[Fizz Master]: Misc Settings", "prConfig")
	MenuFizz.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 5, 1, 5)
	MenuFizz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuFizz.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuFizz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuFizz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuFizz.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	if MenuFizz.prConfig.skin and VIP_USER then
		GenModelPacket("Fizz", MenuFizz.prConfig.skin1)
		lastSkin = MenuFizz.prConfig.skin1
	end
	--[[-- PermShow --]]--
	MenuFizz.comboConfig:permaShow("CEnabled")
	MenuFizz.harrasConfig:permaShow("HEnabled")
	MenuFizz.harrasConfig:permaShow("HTEnabled")
	MenuFizz.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
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

function cancast()
	--Q--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptocq then
		ccq = true
	else
		ccq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptohq then
		chq = true
	else
		chq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptofq then
		cfq = true
	else
		cfq = false
	end
	--W--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptocw then
		ccw = true
	else
		ccw = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptohw then
		chw = true
	else
		chw = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptofw then
		cfw = true
	else
		cfw = false
	end
	--E--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptoce then
		cce = true
	else
		cce = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptofe then
		cfe = true
	else
		cfe = false
	end
	--R--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.mpConfig.mptocr then
		ccr = true
	else
		ccr = false
	end
end

function caa()
	if MenuFizz.comboConfig.uaa then
		SOWi:EnableAttacks()
	elseif not MenuFizz.comboConfig.uaa then
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
	hextechslot = GetInventorySlotItem(3146)
	deathfiregraspslot = GetInventorySlotItem(3128)
	blackfiretorchslot = GetInventorySlotItem(3188)
	hextechready = (hextechslot ~= nil and myHero:CanUseSpell(hextechslot) == READY)
	deathfiregraspready = (deathfiregraspslot ~= nil and myHero:CanUseSpell(deathfiregraspslot) == READY)
	blackfiretorchready = (blackfiretorchslot ~= nil and myHero:CanUseSpell(blackfiretorchslot) == READY)
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
	if MenuFizz.prConfig.skin and VIP_USER and skinChanged() then
		GenModelPacket("Fizz", MenuFizz.prConfig.skin1)
		lastSkin = MenuFizz.prConfig.skin1
	end
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
	if MenuFizz.comboConfig.CT == 1 then
		comboQRWE()
	elseif MenuFizz.comboConfig.CT == 2 then
		comboRQWE()
	end
end

function comboQRWE()
	if MenuFizz.comboConfig.USEQ then
		if QReady and ValidTarget(Cel, skills.skillQ.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and ccq then
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = Cel.networkID}):send()
			else
				CastSpell(_Q, Cel)
			end
		end
	end
	if MenuFizz.comboConfig.USER then
		if RReady and ValidTarget(Cel, skills.skillR.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and ccr then
			if MenuFizz.comboConfig.Kilable then
				local RDMG = getDmg("R", Cel, myHero)
				if Cel.health < RDMG then
					CastR(Cel)
				end
			elseif not MenuFizz.comboConfig.Kilable then
				CastR(Cel)
			end
		end
	end
	if MenuFizz.comboConfig.USEW then
		if WReady and ValidTarget(Cel, aarange) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and ccw then
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
	end
	if MenuFizz.comboConfig.USEE then
		if EReady and ValidTarget(Cel, skills.skillE.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and cce then
			if MenuFizz.comboConfig.USEE2 then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Cel.x, fromY = Cel.z, toX = Cel.x, toY = Cel.z}):send()
				else
					CastSpell(_E, Cel.x, Cel.z)
				end
			elseif not MenuFizz.comboConfig.USEE2 then
				local myE = myHero:GetSpellData(_E)
				if myE.name == "FizzJump" then
					if VIP_USER and MenuFizz.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = Cel.x, fromY = Cel.z, toX = Cel.x, toY = Cel.z}):send()
					else
						CastSpell(_E, Cel.x, Cel.z)
					end
				end
			end
		end
	end
end

function comboRQWE()
	if MenuFizz.comboConfig.USER then
		if RReady and ValidTarget(Cel, skills.skillR.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and ccr then
			if MenuFizz.comboConfig.Kilable then
				local RDMG = getDmg("R", Cel, myHero)
				if Cel.health < RDMG then
					CastR(Cel)
				end
			elseif not MenuFizz.comboConfig.Kilable then
				CastR(Cel)
			end
		end
	end
	if MenuFizz.comboConfig.USEQ then
		if QReady and ValidTarget(Cel, skills.skillQ.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and ccq then
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = Cel.networkID}):send()
			else
				CastSpell(_Q, Cel)
			end
		end
	end
	if MenuFizz.comboConfig.USEW then
		if WReady and ValidTarget(Cel, aarange) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and ccw then
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
	end
	if MenuFizz.comboConfig.USEE then
		if EReady and ValidTarget(Cel, skills.skillE.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and cce then
			if MenuFizz.comboConfig.USEE2 then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Cel.x, fromY = Cel.z, toX = Cel.x, toY = Cel.z}):send()
				else
					CastSpell(_E, Cel.x, Cel.z)
				end
			elseif not MenuFizz.comboConfig.USEE2 then
				local myE = myHero:GetSpellData(_E)
				if myE.name == "FizzJump" then
					if VIP_USER and MenuFizz.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = Cel.x, fromY = Cel.z, toX = Cel.x, toY = Cel.z}):send()
					else
						CastSpell(_E, Cel.x, Cel.z)
					end
				end
			end
		end
	end
end
--END COMBO--

--HARRAS--
function Harrass()
	if MenuFizz.harrasConfig.QH then
		if QReady and ValidTarget(Cel, skills.skillQ.range) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and chq then
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = Cel.networkID}):send()
			else
				CastSpell(_Q, Cel)
			end
		end
	end
	if MenuFizz.harrasConfig.WH then
		if WReady and ValidTarget(Cel, aarange) and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and chw then
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
	end
	if ValidTarget(Cel, aarange) then
		myHero:Attack(Cel)
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
		UseQ =  MenuFizz.farm.QF == 2
		UseW =  MenuFizz.farm.WF == 2 
		UseE =  MenuFizz.farm.EF == 2 
	elseif Mode == "LaneClear" then
		UseQ =  MenuFizz.farm.QF == 3
		UseW =  MenuFizz.farm.WF == 3 
		UseE =  MenuFizz.farm.EF == 3
	end
	
	UseQ =  MenuFizz.farm.QF == 4 or UseQ
	UseW =  MenuFizz.farm.WF == 4  or UseW
	UseE =  MenuFizz.farm.EF == 4 or UseE
	
	if UseQ then
		for i, minion in pairs(EnemyMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, targetNetworkId = minion.networkID}):send()
				else
					CastSpell(_Q, minion)
				end
			end
		end
	end

	if UseW then
		for i, minion in pairs(EnemyMinions.objects) do
			if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= aarange and cfw then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _W}):send()
				else
					CastSpell(_W)
				end
			end
		end
	end
	
	if UseE then
		for i, minion in pairs(EnemyMinions.objects) do
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillE.range and cfe then
				if MenuFizz.farm.EF2 then
					if VIP_USER and MenuFizz.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = minion.x, fromY = minion.z, toX = minion.x, toY = minion.z}):send()
					else
						CastSpell(_E, minion.x, minion.z)
					end
				elseif not MenuFizz.farm.EF2 then
					local myE = myHero:GetSpellData(_E)
					if myE.name == "FizzJump" then
						if VIP_USER and MenuFizz.prConfig.pc then
							Packet("S_CAST", {spellId = _E, fromX = minion.x, fromY = minion.z, toX = minion.x, toY = minion.z}):send()
						else
							CastSpell(_E, minion.x, minion.z)
						end
					end
				end
			end
		end
	end
end
--END FARM--

--JUNGLE FARM--
function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuFizz.jf.QJF then
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, targetNetworkId = minion.networkID}):send()
				else
					CastSpell(_Q, minion)
				end
			end
		end
		if MenuFizz.jf.WJF then
			if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= aarange and cfw then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _W}):send()
				else
					CastSpell(_W)
				end
			end
		end
		if MenuFizz.jf.EJF then
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				if MenuFizz.jf.EJF2 then
					if VIP_USER and MenuFizz.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = minion.x, fromY = minion.z, toX = minion.x, toY = minion.z}):send()
					else
						CastSpell(_E, minion.x, minion.z)
					end
				elseif not MenuFizz.jf.EJF2 then
					local myE = myHero:GetSpellData(_E)
					if myE.name == "FizzJump" then
						if VIP_USER and MenuFizz.prConfig.pc then
							Packet("S_CAST", {spellId = _E, fromX = minion.x, fromY = minion.z, toX = minion.x, toY = minion.z}):send()
						else
							CastSpell(_E, minion.x, minion.z)
						end
					end
				end
			end
		end
		myHero:Attack(minion)
	end
end
--END JUNGLE FARM--

function autozh()
	local count = EnemyCount(myHero, MenuFizz.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuFizz.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuFizz.prConfig.ALS then return end
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuFizz.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuFizz.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuFizz.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuFizz.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuFizz.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuFizz.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end

--DRAWING--
function OnDraw()
	if MenuFizz.drawConfig.DD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuFizz.drawConfig.DLC then
		if MenuFizz.drawConfig.DQR and QReady then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillQ.range - 50, 1, RGB(MenuFizz.drawConfig.DQRC[2], MenuFizz.drawConfig.DQRC[3], MenuFizz.drawConfig.DQRC[4]))
		end
		if MenuFizz.drawConfig.DER and EReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillE.range - 40, 1, RGB(MenuFizz.drawConfig.DERC[2], MenuFizz.drawConfig.DERC[3], MenuFizz.drawConfig.DERC[4]))
		end
		if MenuFizz.drawConfig.DRR and RReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillR.range - 10, 1, RGB(MenuFizz.drawConfig.DRRC[2], MenuFizz.drawConfig.DRRC[3], MenuFizz.drawConfig.DRRC[4]))
		end
	else
		if MenuFizz.drawConfig.DQR and QReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, ARGB(MenuFizz.drawConfig.DQRC[1], MenuFizz.drawConfig.DQRC[2], MenuFizz.drawConfig.DQRC[3], MenuFizz.drawConfig.DQRC[4]))
		end
		if MenuFizz.drawConfig.DER and EReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, ARGB(MenuFizz.drawConfig.DERC[1], MenuFizz.drawConfig.DERC[2], MenuFizz.drawConfig.DERC[3], MenuFizz.drawConfig.DERC[4]))
		end
		if MenuFizz.drawConfig.DRR and RReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillR.range, ARGB(MenuFizz.drawConfig.DRRC[1], MenuFizz.drawConfig.DRRC[2], MenuFizz.drawConfig.DRRC[3], MenuFizz.drawConfig.DRRC[4]))
		end
	end
end
--END DRAWING--

function KillSteall()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		local health = Enemy.health
		local distance = GetDistance(Enemy)
		if MenuFizz.ksConfig.QKS then qDmg = getDmg("Q", Enemy, myHero) else qDmg = 0 end
		if MenuFizz.ksConfig.WKS then wDmg = getDmg("W", Enemy, myHero) else wDmg = 0 end
		if MenuFizz.ksConfig.EKS then eDmg = getDmg("E", Enemy, myHero) else eDmg = 0 end
		if MenuFizz.ksConfig.RKS then rDmg = getDmg("R", Enemy, myHero) else rDmg = 0 end
		if MenuFizz.ksConfig.IKS then iDmg = getDmg("IGNITE", Enemy, myHero) else iDmg = 0 end
		if MenuFizz.ksConfig.ITKS then
			deathfiregraspDmg = ((deathfiregraspready and getDmg("DFG", Enemy, myHero)) or 0)
			hextechDmg = ((hextechready and getDmg("HXG", Enemy, myHero)) or 0)
			blackfiretorchdmg = ((blackfiretorchready and getDmg("BLACKFIRE", Enemy, myHero)) or 0)
			itemsDmg = deathfiregraspDmg + hextechDmg + blackfiretorchdmg 
		else
			itemsDmg = 0
		end
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health <= qDmg and QReady and (distance < skills.skillQ.range) and MenuFizz.ksConfig.QKS then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, targetNetworkId = Enemy.networkID}):send()
				else
					CastSpell(_Q, Enemy)
				end
			elseif health < wDmg and WReady and (distance < aarange) and MenuFizz.ksConfig.WKS then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _W}):send()
				else
					CastSpell(_W)
				end
			elseif health < eDmg and EReady and (distance < skills.skillE.range) and MenuFizz.ksConfig.EKS then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Enemy.x, fromY = Enemy.z, toX = Enemy.x, toY = Enemy.z}):send()
				else
					CastSpell(_E, Enemy.x, Enemy.z)
				end
			elseif health < rDmg and RReady and (distance < skills.skillR.range) and MenuFizz.ksConfig.RKS then
				CastR(Enemy)
			elseif health < (qDmg + wDmg) and QReady and WReady and (distance < aarange) and MenuFizz.ksConfig.WKS then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _W}):send()
				else
					CastSpell(_W)
				end
			elseif health < (qDmg + rDmg) and QReady and RReady and (distance < skills.skillR.range) and MenuFizz.ksConfig.RKS then
				CastR(Enemy)
			elseif health < (wDmg + rDmg) and WReady and RReady and (distance < aarange) and MenuFizz.ksConfig.WKS then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _W}):send()
				else
					CastSpell(_W)
				end
			elseif health < (qDmg + wDmg + rDmg) and QReady and WReady and RReady and (distance < skills.skillR.range) and MenuFizz.ksConfig.RKS then
				CastR(Enemy)
			elseif health < (qDmg + wDmg + rDmg + itemsDmg) and MenuFizz.ksConfig.ITKS then
				if QReady and WReady and RReady then
					UseItems(Enemy)
				end
			elseif health < (qDmg + wDmg + itemsDmg) and health > (qDmg + wDmg) then
				if QReady and WReady then
					UseItems(Enemy)
				end
			end
			if IReady and health <= iDmg and MenuFizz.ksConfig.IKS and distance < 600 then
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
			itemsDmg = deathfiregraspDmg + hextechDmg + bilgewaterDmg + blackfiretorchdmg
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

function CastR(unit)
	if MenuFizz.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, skills.skillR.delay, skills.skillR.width, skills.skillR.range, skills.skillR.speed, myHero, false)
		if CastPosition and HitChance >= MenuFizz.prConfig.vphit - 1 then
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
	if MenuFizz.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, skills.skillR.range, skills.skillR.speed, skills.skillR.delay, skills.skillR.width)
		if Position ~= nil then
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_R, Position.x, Position.z)
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







