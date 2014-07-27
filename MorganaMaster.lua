--[[
	MORGANA MASTER KOKOSIK1221

	Changelog:
 
	1.0 - First Relase
	1.1 - Added drawing options
        - Improved collisions
	1.2 - Fixed combo
        - Added new option in harras
	1.3 - Added mana manager
        - Improved Cast Q
        - Added auto zhonya
        - Added auto lvl spells
        - Added auto "E"
	1.4 - Small fix
	1.5 - Script Rewritten(now it is not SAC PLUGIN)
		- Added SOW integration
		- Added Free, VIP, VPrediction, Prodiction 1.4+ Support
		- Added Auto Update
		- Added Jungle Farm
		- Added Lane Clear
		- Added DMG Calculation
		- Added Draw Lag-Free Circles
		- New Special Menu For Auto Shield
	1.6 - Added changing colors in Drawing Menu
		- Added BOL TRACKER
		- Rewritten Farm/Lane Clear Mode
		
]]--

if myHero.charName ~= "Morgana" then return end

local version = 1.5
local AUTOUPDATE = true
local SCRIPT_NAME = "MorganaMaster"
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
ScriptName = "MorganaMaster"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
--END BOL TRACKER--
---------------

Champions = {
    ["Lux"] = {charName = "Lux", qwer = {
        ["LuxLightBinding"] =  {spellName = "LuxLightBinding", range = 1300},
        ["LuxLightStrikeKugel"] = {spellName = "LuxLightStrikeKugel", range = 1100},
        ["LuxMaliceCannon"] =  {spellName = "LuxMaliceCannon", range = 3500},
    }},
    ["Nidalee"] = {charName = "Nidalee", qwer = {
        ["JavelinToss"] = {spellName = "JavelinToss", range = 1500}
    }},
    ["Akali"] = {charName = "Akali", qwer = {
        ["AkaliMota"] = {spellName = "AkaliMota", range = 1500}
    }},
    ["Kennen"] = {charName = "Kennen", qwer = {
        ["KennenShurikenHurlMissile1"] = {spellName = "KennenShurikenHurlMissile1", range = 1050}
    }},
    ["Amumu"] = {charName = "Amumu", qwer = {
        ["BandageToss"] = {spellName = "BandageToss", range = 1100}
    }},
    ["Morgana"] = {charName = "Morgana", qwer = {
        ["DarkBindingMissile"] = {spellName = "DarkBindingMissile", range = 1300},
        ["TormentedSoil"] = {spellName = "TormentedSoil", range = 900},
    }},
    ["Ezreal"] = {charName = "Ezreal", qwer = {
        ["EzrealMysticShot"] = {spellName = "EzrealMysticShot", range = 1200},
        ["EzrealEssenceFlux"] = {spellName = "EzrealEssenceFlux", range = 1050},
        ["EzrealMysticShotPulse"] = {spellName = "EzrealMysticShotPulse", range = 1200},
        ["EzrealTrueshotBarrage"] = {spellName = "EzrealTrueshotBarrage", range = 20000},
    }},
    ["Ahri"] = {charName = "Ahri", qwer = {
        ["AhriOrbofDeception"] = {spellName = "AhriOrbofDeception", range = 900},
        ["AhriSeduce"] = {spellName = "AhriSeduce", range = 1000}
    }},
    ["Olaf"] = {charName = "Olaf", qwer = {
        ["OlafAxeThrow"] = {spellName = "OlafAxeThrow", range = 1000}
    }},
    ["Leona"] = {charName = "Leona", qwer = { 
        ["LeonaZenithBlade"] = {spellName = "LeonaZenithBlade", range = 900},
        ["LeonaSolarFlare"] = {spellName = "LeonaSolarFlare", range = 1200}
    }},
    ["Karthus"] = {charName = "Karthus", qwer = {
        ["LayWaste"] = {spellName = "LayWaste", range = 875}
    }},
    ["Chogath"] = {charName = "Chogath", qwer = {
        ["Rupture"] = {spellName = "Rupture", range = 950}
    }},
    ["Blitzcrank"] = {charName = "Blitzcrank", qwer = {
       ["RocketGrabMissile"] = {spellName = "RocketGrabMissile", range = 1050}
    }},
    ["Anivia"] = {charName = "Anivia", qwer = {
        ["FlashFrostSpell"] = {spellName = "FlashFrostSpell", range = 1100},
        ["FrostBite"] = {spellName = "FrostBite", range = 1100},
    }},
    ["Annie"] = {charName = "Annie", qwer = {
        ["Disintegrate"] = {spellName = "Disintegrate", range = 875}
    }},
    ["Katarina"] = {charName = "Katarina", qwer = {
        ["KatarinaR"] = {spellName = "KatarinaR", range = 550},
        ["KatarinaQ"] = {spellName = "KatarinaQ", range = 675},
    }},    
    ["Zyra"] = {charName = "Zyra", qwer = {
        ["ZyraGraspingRoots"] = {spellName = "ZyraGraspingRoots", range = 1150},
        ["zyrapassivedeathmanager"] = {spellName = "zyrapassivedeathmanager", range = 1474},
    }},
    ["Gragas"] = {charName = "Gragas", qwer = {
        ["GragasExplosiveCask"] = {spellName="GragasExplosiveCask", range=1050},
        ["GragasBarrelRoll"] = {spellName="GragasBarrelRoll", range=950}
    }},
    ["Nautilus"] = {charName = "Nautilus", qwer = {
        ["NautilusAnchorDrag"] = {spellName = "NautilusAnchorDrag", range = 1080},
    }},
    ["Caitlyn"] = {charName = "Caitlyn", qwer = {
        ["CaitlynPiltoverPeacemaker"] = {spellName = "CaitlynPiltoverPeacemaker", range = 1300},
        ["CaitlynEntrapment"] = {spellName = "CaitlynEntrapment", range = 950},
        ["CaitlynHeadshotMissile"] = {spellName = "CaitlynHeadshotMissile", range = 3000},
    }},
    ["Mundo"] = {charName = "DrMundo", qwer = {
        ["InfectedCleaverMissile"] = {spellName = "InfectedCleaverMissile", range = 1050},
    }},
    ["Brand"] = {charName = "Brand", qwer = { -- Q+ W+
        ["BrandBlaze"] = {spellName = "BrandBlaze", range = 1100},
        ["BrandWildfire"] = {spellName = "BrandWildfire", range = 1100}
    }},
    ["Corki"] = {charName = "Corki", qwer = {
        ["MissileBarrage"] = {spellName = "MissileBarrage", range = 1300},
    }},
    ["TwistedFate"] = {charName = "TwistedFate", qwer = {
        ["WildCards"] = {spellName = "WildCards", range = 1450},
    }},
    ["Swain"] = {charName = "Swain", qwer = {
        ["SwainShadowGrasp"] = {spellName = "SwainShadowGrasp", range = 900},
        ["SwainTorment"] = {spellName = "SwainTorment", range = 900}
    }},
    ["Cassiopeia"] = {charName = "Cassiopeia", qwer = {
        ["CassiopeiaNoxiousBlast"] = {spellName = "CassiopeiaNoxiousBlast", range = 850},
    }},
    ["Sivir"] = {charName = "Sivir", qwer = { 
        ["SivirQ"] = {spellName = "SivirQ", range = 1175},
    }},
    ["Ashe"] = {charName = "Ashe", qwer = {
        ["EnchantedCrystalArrow"] = {spellName = "EnchantedCrystalArrow", range = 25000},
        ["Volley"] = {spellName = "Volley", range = 1200},
    }},
    ["KogMaw"] = {charName = "KogMaw", qwer = {
        ["KogMawLivingArtillery"] = {spellName = "KogMawLivingArtillery", range = 2200}
    }},
    ["Khazix"] = {charName = "Khazix", qwer = {
        ["KhazixW"] = {spellName = "KhazixW", range = 1025},
    }},
    ["Zed"] = {charName = "Zed", qwer = {
        ["ZedShuriken"] = {spellName = "ZedShuriken", range = 925},
    }},
    ["Leblanc"] = {charName = "Leblanc", qwer = {
        ["LeblancChaosOrb"] = {spellName = "LeblancChaosOrb", range = 960},
        ["LeblancChaosOrbM"] = {spellName = "LeblancChaosOrbM", range = 960},
        ["LeblancSoulShackle"] = {spellName = "LeblancSoulShackle", range = 960},
        ["LeblancSoulShackleM"] = {spellName = "LeblancSoulShackleM", range = 960},
        ["LeblancMimic"] = {spellName="LeblancMimic", range=650}
    }},
    ["Draven"] = {charName = "Draven", qwer = {
        ["DravenDoubleShot"] = {spellName = "DravenDoubleShot", range = 1100},
        ["DravenRCast"] = {spellName = "DravenRCast", range = 25000},
    }},
    ["Elise"] = {charName = "Elise", qwer = {
        ["EliseHumanE"] = {spellName = "EliseHumanE", range = 1100}
    }},
    ["Lulu"] = {charName = "Lulu", qwer = {
        ["LuluQ"] = {spellName = "LuluQ", range = 1000}
    }},
    ["Thresh"] = {charName = "Thresh", qwer = {
        ["ThreshQ"] = {spellName = "ThreshQ", range = 1100}
    }},
    ["Shen"] = {charName = "Shen", qwer = {
        ["ShenShadowDash"] = {spellName = "ShenShadowDash", range = 575}
    }},
    ["Quinn"] = {charName = "Quinn", qwer = {
        ["QuinnQ"] = {spellName = "QuinnQ", range = 1050}
    }},
    ["Veigar"] = {charName = "Veigar", qwer = {
        ["VeigarPrimordialBurst"] = {spellName="VeigarPrimordialBurst", range = 650},
        ["VeigarBalefulStrike"] = {spellName="VeigarBalefulStrike", range=650}
    }},
    ["Nami"] = {charName = "Nami", qwer = {
        ["NamiQ"] = {spellName = "NamiQ", range = 1625}
    }},
    ["Fizz"] = {charName = "Fizz", qwer = {
        ["FizzMarinerDoom"] = {spellName = "FizzMarinerDoom", range = 1275},
    }},
    ["Varus"] = {charName = "Varus", qwer = {
        ["VarusQ"] = {spellName = "VarusQ", range = 1600},
        ["VarusE"] = {spellName = "VarusE", range = 925},
        ["VarusR"] = {spellName = "VarusR", range = 1250},
    }},
    ["Karma"] = {charName = "Karma", qwer = {
        ["KarmaQ"] = {spellName = "KarmaQ", range = 1050},
    }},
    ["Aatrox"] = {charName = "Aatrox", qwer = {
        ["AatroxE"] = {spellName = "AatroxE", range = 1075},
        ["AatroxQ"] = {spellName = "AatroxQ", range = 650},
   }},
    ["Xerath"] = {charName = "Xerath", qwer = {
        ["XerathArcanopulse"] =  {spellName = "XerathArcanopulse", range = 1025},
        ["xeratharcanopulseextended"] =  {spellName = "xeratharcanopulseextended", range = 1625},
        ["xeratharcanebarragewrapper"] = {spellName = "xeratharcanebarragewrapper", range = 1100},
        ["xeratharcanebarragewrapperext"] = {spellName = "xeratharcanebarragewrapperext", range = 1600}
    }},
    ["Lucian"] = {charName = "Lucian", qwer = {
        ["LucianQ"] =  {spellName = "LucianQ", range = 570*2},
        ["LucianW"] =  {spellName = "LucianW", range = 1000},
    }},
    ["Rumble"] = {charName = "Rumble", qwer = {
        ["RumbleGrenade"] =  {spellName = "RumbleGrenade", range = 950},
    }},
    ["Nocturne"] = {charName = "Nocturne", qwer = {
        ["NocturneDuskbringer"] =  {spellName = "NocturneDuskbringer", range = 1125},
    }},
    ["MissFortune"] = {charName = "MissFortune", qwer = {
        ["MissFortuneScattershot"] =  {spellName = "MissFortuneScattershot", range = 800},
        ["MissFortuneBulletTime"] =  {spellName = "MissFortuneBulletTime", range = 1400}
    }},
    ["Ziggs"] = {charName = "Ziggs", qwer = { 
        ["ZiggsQ"] =  {spellName = "ZiggsQ", range = 1500},
        ["ZiggsW"] =  {spellName = "ZiggsW", range = 1500},
        ["ZiggsE"] =  {spellName = "ZiggsE", range = 1500},
        ["ZiggsR"] =  {spellName = "ZiggsR", range = 1500}
    }},
    ["Galio"] = {charName = "Galio", qwer = {
        ["GalioResoluteSmite"] =  {spellName = "GalioResoluteSmite", range = 2000},
    }},
    ["Yasuo"] = {charName = "Yasuo", qwer = {
        ["yasuoq3w"] =  {spellName = "yasuoq3w", range = 900},
    }},
    ["Kassadin"] = {charName = "Kassadin", qwer = {
        ["NullLance"] =  {spellName = "NullLance", range = 650},
    }},
    ["Jinx"] = {charName = "Jinx", qwer = { 
        ["JinxWMissile"] =  {spellName = "JinxWMissile", range = 1450},
        ["JinxRWrapper"] =  {spellName = "JinxRWrapper", range = 20000}
    }},
    ["Taric"] = {charName = "Taric", qwer = {
        ["Dazzle"] = {spellName="Dazzle", range=625},
        }},
    ["FiddleSticks"] = {charName = "FiddleSticks", qwer = {
        ["FiddlesticksDarkWind"] = {spellName="FiddlesticksDarkWind", range=750},
    }},           
    ["Syndra"] = {charName = "Syndra", qwer = {
        ["SyndraQ"] = {spellName = "SyndraQ", range = 800},
        ["SyndraR"] = {spellName="SyndraR", range=675}
    }},
    ["Kayle"] = {charName = "Kayle", qwer = {
        ["JudicatorReckoning"] = {spellName="JudicatorReckoning", range=650},
    }},
    ["Heimerdinger"] = {charName = "Heimerdinger", qwer = {
        ["HeimerdingerW"] =  {spellName = "HeimerdingerW", range = 2000},
        ["HeimerdingerE"] = {spellName="HeimerdingerE", range=750}
    }},    
    ["Annie"] = {charName = "Annie", qwer = {
        ["Disintegrate"] = {spellName = "Disintegrate", range = 875}
    }},
    ["Janna"] = {charName = "Janna", qwer = {
        ["HowlingGale"] = {spellName = "HowlingGale", range = 1500}
    }},
    ["Lissandra"] = {charName = "Lissandra", qwer = {
        ["LissandraQ"] = {spellName = "LissandraQ", range = 1500},
        ["LissandraE"] = {spellName = "LissandraE", range = 1500}
    }},
    ["Sejuani"] = {charName = "Sejuani", qwer = {
        ["SejuaniR"] = {spellName = "SejuaniR", range = 1500}
    }},
    ["Ryze"] = {charName = "Ryze", qwer = {
        ["Overload"] = {spellName = "Overload", range = 1500},
        ["SpellFlux"] = {spellName = "SpellFlux", range = 1500}
    }},
    ["Malphite"] = {charName = "Malphite", qwer = {
        ["SeismicShard"] = {spellName = "SeismicShard", range = 1500}
    }},
    ["Sona"] = {charName = "Sona", qwer = {
        ["SonaHymnofValor"] = {spellName = "SonaHymnofValor", range = 1500},
        ["SonaCrescendo"] = {spellName = "SonaCrescendo", range = 1500}
    }},
    ["Teemo"] = {charName = "Teemo", qwer = {
        ["BlindingDart"] = {spellName = "BlindingDart", range = 680}
    }},
    ["Vayne"] = {charName = "Vayne", qwer = {
        ["VayneCondemn"] = {spellName = "VayneCondemn", range = 550}
    }},
}


function Menu()
	MenuMorg = scriptConfig("Morgana Master "..version, "Morgana Master "..version)
	MenuMorg:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuMorg.Orbwalking)
	MenuMorg:addSubMenu("Target selector", "STS")
    STS:AddToMenu(MenuMorg.STS)
	--[[--- Combo --]]--
	MenuMorg:addSubMenu("Combo Settings", "comboConfig")
    MenuMorg.comboConfig:addParam("USEQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
    MenuMorg.comboConfig:addParam("USEW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.comboConfig:addParam("USEE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.comboConfig:addParam("USER", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.comboConfig:addParam("ENEMYTOR", "Min Enemies to Cast R: ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuMorg.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--[[--- Harras --]]--
	MenuMorg:addSubMenu("Harras Settings", "harrasConfig")
    MenuMorg.harrasConfig:addParam("QH", "Harras Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.harrasConfig:addParam("WH", "Harras Use W", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.harrasConfig:addParam("HWS", "Only On Stunned Enemy", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuMorg.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	--[[--- Mana Manager --]]--
	MenuMorg:addSubMenu("Mana Config" , "mpConfig")
	MenuMorg.mpConfig:addParam("mptocq", "Min Mana To Cast Q", SCRIPT_PARAM_SLICE, 20, 0, 100, 0) 
	MenuMorg.mpConfig:addParam("mptocw", "Min Mana To Cast W", SCRIPT_PARAM_SLICE, 25, 0, 100, 0) 
	MenuMorg.mpConfig:addParam("mptocr", "Min Mana To Cast R", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuMorg.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.mpConfig:addParam("mptohq", "Min Mana To Harras Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0) 
	MenuMorg.mpConfig:addParam("mptohw", "Min Mana To Harras W", SCRIPT_PARAM_SLICE, 55, 0, 100, 0)
	MenuMorg.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.mpConfig:addParam("mptofq", "Min Mana To Farm Q", SCRIPT_PARAM_SLICE, 60, 0, 100, 0) 
	MenuMorg.mpConfig:addParam("mptofw", "Min Mana To Farm W", SCRIPT_PARAM_SLICE, 65, 0, 100, 0)
	--[[--- Kill Steal --]]--
	MenuMorg:addSubMenu("KS Settings", "ksConfig")
	MenuMorg.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.ksConfig:addParam("QKS", "Use Q To KS", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.ksConfig:addParam("WKS", "Use W To KS", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.ksConfig:addParam("RKS", "Use R To KS", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.ksConfig:addParam("ITKS", "Use Items To KS", SCRIPT_PARAM_ONOFF, true)
	--[[--- Farm --]]--
	MenuMorg:addSubMenu("Farm Config", "farm")
	MenuMorg.farm:addParam("QF", "Use Q", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuMorg.farm:addParam("WF",  "Use W", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuMorg.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
	MenuMorg.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
		
	--[[--- Jungle Farm --]]--
	MenuMorg:addSubMenu("Jungle Farm", "jf")
	MenuMorg.jf:addParam("QJF", "Jungle Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.jf:addParam("WJF", "Jungle Farm Use W", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--[[--- Extra --]]--
	MenuMorg:addSubMenu("Extra Settings", "exConfig")
	MenuMorg.exConfig:addSubMenu("Shield Options", "SO")
	for i = 1, heroManager.iCount,1 do
        local hero = heroManager:getHero(i)
        if hero.team ~= player.team then
            if Champions[hero.charName] ~= nil then
                for index, skillshot in pairs(Champions[hero.charName].qwer) do
                    MenuMorg.exConfig.SO:addParam(skillshot.spellName, hero.charName .. " - " .. skillshot.spellName, SCRIPT_PARAM_ONOFF, true)
                end
            end
        end
    end
	MenuMorg.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.exConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.exConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuMorg.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.exConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.exConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	--[[--- Drawing --]]--
	MenuMorg:addSubMenu("Draw Settings", "drawConfig")
	MenuMorg.drawConfig:addParam("DLC", "Draw Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.drawConfig:addParam("DQL", "Draw Q Collision Line", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("DQLC", "Draw Q Collision Color", SCRIPT_PARAM_COLOR, {150,40,4,4})
	MenuMorg.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuMorg.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,100,0,255})
	MenuMorg.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuMorg.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	--[[--- Prediction --]]--
	MenuMorg:addSubMenu("Prediction Settings", "prConfig")
	MenuMorg.prConfig:addParam("pro", "Use", SCRIPT_PARAM_LIST, 3, {"FREEPrediction","VIPPrediction","VPrediction","Prodiction"}) 
	--dsf--
	MenuMorg.comboConfig:permaShow("CEnabled")
	MenuMorg.harrasConfig:permaShow("HEnabled")
	MenuMorg.harrasConfig:permaShow("HTEnabled")
	MenuMorg.exConfig:permaShow("AZ")
end

function LoadLibs()
	if VIP_USER then
		Prod = ProdictManager.GetInstance()
	    ProdictionQ = Prod:AddProdictionObject(_Q, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width) 
		ProdictionW = Prod:AddProdictionObject(_W, skills.skillW.range, skills.skillW.speed, skills.skillW.delay, skills.skillW.width)
		
		VipPredictionQ = TargetPredictionVIP(skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width, myHero)
		VipPredictionW = TargetPredictionVIP(skills.skillW.range, skills.skillW.speed, skills.skillW.delay, skills.skillW.width, myHero)
	end
	VP = VPrediction(true)
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC) 
	FreePredictionQ = TargetPrediction(skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width)
	FreePredictionW = TargetPrediction(skills.skillW.range, skills.skillW.speed, skills.skillW.delay, skills.skillW.width)
end

function Variables()
	skills = 
	{
	skillQ = {range = 1300, speed = 1200, delay = 0.25, width = 60},
	skillW = {range = 900, speed = 1200, delay = 0.15, width = 105},
	skillE = {range = 750},
	skillR = {range = 600},
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
	if ((myHero.mana/myHero.maxMana)*100) >= MenuMorg.mpConfig.mptocq then
		ccq = true
	else
		ccq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuMorg.mpConfig.mptohq then
		chq = true
	else
		chq = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuMorg.mpConfig.mptofq then
		cfq = true
	else
		cfq = false
	end
	--W--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuMorg.mpConfig.mptocw then
		ccw = true
	else
		ccw = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuMorg.mpConfig.mptohw then
		chw = true
	else
		chw = false
	end
	if ((myHero.mana/myHero.maxMana)*100) >= MenuMorg.mpConfig.mptofw then
		cfw = true
	else
		cfw = false
	end
	--R--
	if ((myHero.mana/myHero.maxMana)*100) >= MenuMorg.mpConfig.mptocr then
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
	Cel = STS:GetTarget(skills.skillQ.range)
	Check()
	if Cel ~= nil and MenuMorg.comboConfig.CEnabled then
		Combo()
	end
	if Cel ~= nil and MenuMorg.harrasConfig.HEnabled or MenuMorg.harrasConfig.HTEnabled then
		Harrass()
	end
	if MenuMorg.farm.Freeze or MenuMorg.farm.LaneClear then
		local Mode = MenuMorg.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
	end
	if MenuMorg.jf.JFEnabled then
		JungleFarmm()
	end
	if MenuMorg.exConfig.AZ then
		autozh()
	end
	if MenuMorg.exConfig.ALS then
		autolvl()
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
	if MenuMorg.comboConfig.USEQ then
		CastQC()
	end
	if MenuMorg.comboConfig.USEW then
		CastWC()
	end
	UseItems(Cel)
	if MenuMorg.comboConfig.USEE then
		CastEC()
	end
	if MenuMorg.comboConfig.USER then
		CastRC()
	end
end

function CastQC()
	if QReady and MenuMorg.comboConfig.USEQ and Cel.canMove and ccq then
		CastQ(Cel)
	end
end

function CastWC()
	if WReady and MenuMorg.comboConfig.USEW and not Cel.canMove and ccw then
		CastW(Cel)
	end
end

function CastEC()
	if EReady and MenuMorg.comboConfig.USEE then
		CastSpell(_E)
	end
end

function CastRC()
	local enemyCount = EnemyCount(myHero, skills.skillR.range)
	if RReady and MenuMorg.comboConfig.USER and enemyCount >= MenuMorg.comboConfig.ENEMYTOR and ccr then
		CastSpell(_R)
	end
end
--END COMBO--

--HARRAS--
function Harrass()
	if MenuMorg.harrasConfig.QH then
		CastQH()
	end
	if MenuMorg.harrasConfig.WH then
		CastWH()
	end
end

function CastQH()
	if QReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and chq then
		CastQ(Cel)
	end
end

function CastWH()
	if WReady and Cel ~= nil and Cel.team ~= player.team and not Cel.dead and chw then
		if MenuMorg.harrasConfig.HWS then
			if not Cel.canMove then
				CastW(Cel)
			end
		end
		if not MenuMorg.harrasConfig.HWS then
			CastW(Cel)
		end
	end
end
--END HARRAS--

--FARM--
function Farm(Mode)
	local UseQ
	local UseW
	if not SOWi:CanMove() then return end

	EnemyMinions:update()
	if Mode == "Freeze" then
		UseQ =  MenuMorg.farm.QF == 2
		UseW =  MenuMorg.farm.WF == 2 
	elseif Mode == "LaneClear" then
		UseQ =  MenuMorg.farm.QF == 3
		UseW =  MenuMorg.farm.WF == 3 
	end
	
	UseQ =  MenuMorg.farm.QF == 4 or UseQ
	UseW =  MenuMorg.farm.WF == 4  or UseW
	
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
				CastW(minion)
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
	if MenuMorg.jf.QJF then
		CastQJF()
	end
	if MenuMorg.jf.WJF then
		CastWJF()
	end
end

function CastQJF()
	for i, minion in pairs(JungleMinions.objects) do
		if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
			CastQ(minion)
		end
	end
end

function CastWJF()
	for i, minion in pairs(JungleMinions.objects) do
		if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillW.range and cfw then
			CastW(minion)
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
		if MenuMorg.ksConfig.QKS then
			qDmg = getDmg("Q", Enemy, myHero)
		else 
			qDmg = 0
		end
		if MenuMorg.ksConfig.WKS then
			wDmg = getDmg("W", Enemy, myHero)
		else 
			wDmg = 0
		end
		if MenuMorg.ksConfig.RKS then
			rDmg = getDmg("R", Enemy, myHero)
		else 
			rDmg = 0
		end
		if MenuMorg.ksConfig.ITKS then
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
			if health <= qDmg and QReady and (distance < skills.skillQ.range) and MenuMorg.ksConfig.QKS then
				CastQ(Enemy)
			elseif health < wDmg and WReady and (distance < skills.skillW.range) and MenuMorg.ksConfig.WKS then
				CastW(Enemy)
			elseif health < rDmg and RReady and (distance < skills.skillR.range) and MenuMorg.ksConfig.RKS then
				CastSpell(_R)
			elseif health < (qDmg + wDmg) and QReady and WReady and (distance < skills.skillW.range) and MenuMorg.ksConfig.WKS then
				CastW(Enemy)
			elseif health < (qDmg + rDmg) and QReady and RReady and (distance < skills.skillR.range) and MenuMorg.ksConfig.RKS then
				CastSpell(_R)
			elseif health < (wDmg + rDmg) and WReady and RReady and (distance < skills.skillW.range) and MenuMorg.ksConfig.WKS then
				CastW(Enemy)
			elseif health < (qDmg + wDmg + rDmg) and QReady and WReady and RReady and (distance < skills.skillR.range) and MenuMorg.ksConfig.RKS then
				CastSpell(_R)
			elseif health < (qDmg + wDmg + rDmg + itemsDmg) and MenuMorg.ksConfig.ITKS then
				if QReady and WReady and RReady then
					UseItems(Enemy)
				end
			elseif health < (qDmg + wDmg + itemsDmg) and health > (qDmg + wDmg) then
				if QReady and WReady then
					UseItems(Enemy)
				end
			end
		end
	end
end
--END KILL STEAL--

--DRAWING--
function OnDraw()
	if MenuMorg.drawConfig.DQL and ValidTarget(Cel, skills.skillQ.range) then
		QMark = Cel
		DrawLine3D(myHero.x, myHero.y, myHero.z, QMark.x, QMark.y, QMark.z, skills.skillQ.width, ARGB(MenuMorg.drawConfig.DQLC[1], MenuMorg.drawConfig.DQLC[2], MenuMorg.drawConfig.DQLC[3], MenuMorg.drawConfig.DQLC[4]))
	end
	if MenuMorg.drawConfig.DD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuMorg.drawConfig.DLC then
		if MenuMorg.drawConfig.DQR and QReady then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillQ.range - 90, 1, RGB(MenuMorg.drawConfig.DQRC[2], MenuMorg.drawConfig.DQRC[3], MenuMorg.drawConfig.DQRC[4]))
		end
		if MenuMorg.drawConfig.DWR and WReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillW.range - 80, 1, RGB(MenuMorg.drawConfig.DWRC[2], MenuMorg.drawConfig.DWRC[3], MenuMorg.drawConfig.DWRC[4]))
		end
		if MenuMorg.drawConfig.DER and EReady then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillE.range - 70, 1, RGB(MenuMorg.drawConfig.DERC[2], MenuMorg.drawConfig.DERC[3], MenuMorg.drawConfig.DERC[4]))
		end
		if MenuMorg.drawConfig.DRR then			
			DrawCircle3D(myHero.x, myHero.y, myHero.z, skills.skillR.range - 20, 1, RGB(MenuMorg.drawConfig.DRRC[2], MenuMorg.drawConfig.DRRC[3], MenuMorg.drawConfig.DRRC[4]))
		end
	else
		if MenuMorg.drawConfig.DQR and QReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillQ.range, ARGB(MenuMorg.drawConfig.DQRC[1], MenuMorg.drawConfig.DQRC[2], MenuMorg.drawConfig.DQRC[3], MenuMorg.drawConfig.DQRC[4]))
		end
		if MenuMorg.drawConfig.DWR and WReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillW.range, ARGB(MenuMorg.drawConfig.DWRC[1], MenuMorg.drawConfig.DWRC[2], MenuMorg.drawConfig.DWRC[3], MenuMorg.drawConfig.DWRC[4]))
		end
		if MenuMorg.drawConfig.DER and EReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillE.range, ARGB(MenuMorg.drawConfig.DERC[1], MenuMorg.drawConfig.DERC[2], MenuMorg.drawConfig.DERC[3], MenuMorg.drawConfig.DERC[4]))
		end
		if MenuMorg.drawConfig.DRR then			
			DrawCircle(myHero.x, myHero.y, myHero.z, skills.skillR.range, ARGB(MenuMorg.drawConfig.DRRC[1], MenuMorg.drawConfig.DRRC[2], MenuMorg.drawConfig.DRRC[3], MenuMorg.drawConfig.DRRC[4]))
		end
	end
end
--END DRAWING--

--EXTRA--
function autozh()
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuMorg.exConfig.AZHP then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuMorg.exConfig.ALS then return end

	
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuMorg.exConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuMorg.exConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuMorg.exConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuMorg.exConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuMorg.exConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuMorg.exConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end
--END EXTRA--

function OnProcessSpell(object,spellProc)
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
					if GetDistance(spellProc.endPos) <= skills.skillE.range then
						if EReady and MenuMorg.exConfig.SO[spellProc.name] then
							CastSpell(_E)
						end
					end
				end
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
            elseif enemy.health < rDmg then
				killstring[enemy.networkID] = "R Kill!"
            elseif enemy.health < (qDmg + wDmg) then
                killstring[enemy.networkID] = "Q+W Kill!"
			elseif enemy.health < (qDmg + rDmg) then
                killstring[enemy.networkID] = "Q+R Kill!"	
			elseif enemy.health < (wDmg + rDmg) then
                killstring[enemy.networkID] = "W+R Kill!"	
			elseif enemy.health < (qDmg + wDmg + rDmg) then
                killstring[enemy.networkID] = "Q+W+R Kill!"	
			elseif enemy.health < (qDmg + itemsDmg) then
				killstring[enemy.networkID] = "Q+Items Kill!"
			elseif enemy.health < (wDmg + itemsDmg) then
				killstring[enemy.networkID] = "W+Items Kill!"
            elseif enemy.health < (rDmg + itemsDmg) then
				killstring[enemy.networkID] = "R+Items Kill!"
            elseif enemy.health < (qDmg + wDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+W+Items Kill!"
			elseif enemy.health < (qDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+R+Items Kill!"	
			elseif enemy.health < (wDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "W+R+Items Kill!"	
			elseif enemy.health < (qDmg + wDmg + rDmg + itemsDmg) then
                killstring[enemy.networkID] = "Q+W+R+Items Kill!"	
            end
        end
    end
end

function CastQ(unit)
	if MenuMorg.prConfig.pro == 1 then
		local Position = FreePredictionQ:GetPrediction(unit)
		if Position ~= nil then				
			CastSpell(_Q, Position.x, Position.z)
			return
		end
	end
	if MenuMorg.prConfig.pro == 2 and VIP_USER then
		local Position = VipPredictionQ:GetPrediction(unit)
		if Position ~= nil then
			CastSpell(_Q, Position.x, Position.z)
			return		
		end
	end
	if MenuMorg.prConfig.pro == 3 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, true)
		if CastPosition and HitChance >= 2 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
			return
		end
	end
	if MenuMorg.prConfig.pro == 4 and VIP_USER and prodstatus then
		local Position = ProdictionQ:GetPrediction(unit)
		if Position ~= nil then
			CastSpell(_Q, Position.x, Position.z)
			return		
		end
	end
end

function CastW(unit)
	if MenuMorg.prConfig.pro == 1 then
		local Position = FreePredictionW:GetPrediction(unit)
		if Position ~= nil then				
			CastSpell(_W, Position.x, Position.z)
			return
		end
	end
	if MenuMorg.prConfig.pro == 2 and VIP_USER then
		local Position = VipPredictionW:GetPrediction(unit)
		if Position ~= nil then
			CastSpell(_W, Position.x, Position.z)
			return		
		end
	end
	if MenuMorg.prConfig.pro == 3 then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, skills.skillW.delay, skills.skillW.width, skills.skillW.range, skills.skillW.speed, myHero, false)
		if CastPosition and HitChance >= 2 then
			CastSpell(_W, CastPosition.x, CastPosition.z)
			return
		end
	end
	if MenuMorg.prConfig.pro == 4 and VIP_USER and prodstatus then
		local Position = ProdictionW:GetPrediction(unit)
		if Position ~= nil then
			CastSpell(_W, Position.x, Position.z)
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


