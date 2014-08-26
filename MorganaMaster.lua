--[[

	Script Name: MORGANA MASTER 
    	Author: kokosik1221
	Last Version: 2.02
	26.08.2014
	
]]--

if myHero.charName ~= "Morgana" then return end

local AUTOUPDATE = true



--AUTO UPDATE--
local version = 2.02
local SCRIPT_NAME = "MorganaMaster"
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
ScriptName = "MorganaMaster"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
--END BOL TRACKER--

local Shieldspells = {
  ['AatroxQ'] = {charName = "Aatrox", spellSlot = "Q", SpellType = "skillshot"},
  ['AatroxE'] = {charName = "Aatrox", spellSlot = "E", SpellType = "skillshot"},
  ['AhriOrbofDeception'] = {charName = "Ahri", spellSlot = "Q", SpellType = "skillshot"},
  ['AhriFoxFire'] = {charName = "Ahri", spellSlot = "W", SpellType = "skillshot"},
  ['AhriSeduce'] = {charName = "Ahri", spellSlot = "E", SpellType = "skillshot"},
  ['AhriTumble'] = {charName = "Ahri", spellSlot = "R", SpellType = "skillshot"},
  ['AkaliMota'] = {charName = "Akali", spellSlot = "Q", SpellType = "castcel"},
  ['AkaliShadowSwipe'] = {charName = "Akali", spellSlot = "E", SpellType = "skillshot"},
  ['AkaliShadowDance'] = {charName = "Akali", spellSlot = "R", SpellType = "castcel"},
  ['Pulverize'] = {charName = "Alistar", spellSlot = "Q", SpellType = "castcel"},
  ['Headbutt'] = {charName = "Alistar", spellSlot = "W", SpellType = "castcel"},
  ['BandageToss'] = {charName = "Amumu", spellSlot = "Q", SpellType = "skillshot"},
  ['AuraofDespair'] = {charName = "Amumu", spellSlot = "W", SpellType = "skillshot"},
  ['Tantrum'] = {charName = "Amumu", spellSlot = "E", SpellType = "skillshot"},
  ['CurseoftheSadMumm'] = {charName = "Amumu", spellSlot = "R", SpellType = "skillshot"},
  ['FlashFrost'] = {charName = "Anivia", spellSlot = "Q", SpellType = "skillshot"},
  ['Frostbite'] = {charName = "Anivia", spellSlot = "E", SpellType = "castcel"},
  ['GlacialStorm'] = {charName = "Anivia", spellSlot = "R", SpellType = "skillshot"},
  ['Disintegrate'] = {charName = "Annie", spellSlot = "Q", SpellType = "castcel"},
  ['Incinerate'] = {charName = "Annie", spellSlot = "W", SpellType = "castcel"},
  ['InfernalGuardian'] = {charName = "Annie", spellSlot = "R", SpellType = "castcel"},
  ['Volley'] = {charName = "Ashe", spellSlot = "W", SpellType = "skillshot"},
  ['EnchantedCrystalArrow'] = {charName = "Ashe", spellSlot = "R", SpellType = "skillshot"},
  ['RocketGrabMissile'] = {charName = "Blitzcrank", spellSlot = "Q", SpellType = "skillshot"},
  ['PowerFist'] = {charName = "Blitzcrank", spellSlot = "E", SpellType = "skillshot"},
  ['StaticField'] = {charName = "Blitzcrank", spellSlot = "R", SpellType = "skillshot"},
  ['BrandBlaze'] = {charName = "Brand", spellSlot = "Q", SpellType = "skillshot"},
  ['BrandFissure'] = {charName = "Brand", spellSlot = "W", SpellType = "skillshot"},
  ['BrandConflagration'] = {charName = "Brand", spellSlot = "E", SpellType = "castcel"},
  ['BrandWildfire'] = {charName = "Brand", spellSlot = "R", SpellType = "castcel"},
  ['BraumQ'] = {charName = "Braum", spellSlot = "Q", SpellType = "skillshot"},
  ['BraumQMissle'] = {charName = "Braum", spellSlot = "Q", SpellType = "skillshot"},
  ['BraumR'] = {charName = "Braum", spellSlot = "R", SpellType = "skillshot"},
  ['CaitlynPiltoverPeacemaker'] = {charName = "Caitlyn", spellSlot = "Q", SpellType = "skillshot"},
  ['CaitlynYordleTrap'] = {charName = "Caitlyn", spellSlot = "W", SpellType = "skillshot"},
  ['CaitlynEntrapment'] = {charName = "Caitlyn", spellSlot = "E", SpellType = "skillshot"},
  ['CaitlynAceintheHole'] = {charName = "Caitlyn", spellSlot = "R", SpellType = "castcel"},
  ['CassiopeiaNoxiousBlast'] = {charName = "Cassiopeia", spellSlot = "Q", SpellType = "skillshot"},
  ['CassiopeiaMiasma'] = {charName = "Cassiopeia", spellSlot = "W", SpellType = "skillshot"},
  ['CassiopeiaTwinFang'] = {charName = "Cassiopeia", spellSlot = "E", SpellType = "castcel"},
  ['CassiopeiaPetrifyingGaze'] = {charName = "Cassiopeia", spellSlot = "R", SpellType = "skillshot"},
  ['Rupture'] = {charName = "Chogath", spellSlot = "Q", SpellType = "skillshot"},
  ['FeralScream'] = {charName = "Chogath", spellSlot = "W", SpellType = "skillshot"},
  ['VorpalSpikes'] = {charName = "Chogath", spellSlot = "E", SpellType = "castcel"},
  ['Feast'] = {charName = "Chogath", spellSlot = "R", SpellType = "castcel"},
  ['PhosphorusBomb'] = {charName = "Corki", spellSlot = "Q", SpellType = "skillshot"},
  ['CarpetBomb'] = {charName = "Corki", spellSlot = "W", SpellType = "skillshot"},
  ['GGun'] = {charName = "Corki", spellSlot = "E", SpellType = "skillshot"},
  ['MissileBarrage'] = {charName = "Corki", spellSlot = "R", SpellType = "skillshot"},
  ['DariusCleave'] = {charName = "Darius", spellSlot = "Q", SpellType = "castcel"},
  ['DariusAxeGrabCone'] = {charName = "Darius", spellSlot = "E", SpellType = "castcel"},
  ['DariusExecute'] = {charName = "Darius", spellSlot = "R", SpellType = "castcel"},
  ['DianaArc'] = {charName = "Diana", spellSlot = "Q", SpellType = "skillshot"},
  ['DianaOrbs'] = {charName = "Diana", spellSlot = "W", SpellType = "skillshot"},
  ['DianaVortex'] = {charName = "Diana", spellSlot = "E", SpellType = "skillshot"},
  ['DianaTeleport'] = {charName = "Diana", spellSlot = "R", SpellType = "castcel"},
  ['InfectedCleaverMissileCast'] = {charName = "DrMundo", spellSlot = "Q"},
  ['BurningAgony'] = {charName = "DrMundo", spellSlot = "W", SpellType = "skillshot"},
  ['DravenDoubleShot'] = {charName = "Draven", spellSlot = "E", SpellType = "castcel"},
  ['DravenRCast'] = {charName = "Draven", spellSlot = "R", SpellType = "castcel"},
  ['EliseHumanQ'] = {charName = "Elise", spellSlot = "Q", SpellType = "castcel"},
  ['EliseHumanW'] = {charName = "Elise", spellSlot = "W", SpellType = "skillshot"},
  ['EliseHumanE'] = {charName = "Elise", spellSlot = "E", SpellType = "skillshot"},
  ['EliseSpiderQCast'] = {charName = "Elise", spellSlot = "Q", SpellType = "skillshot"},
  ['EliseSpiderW'] = {charName = "Elise", spellSlot = "W", SpellType = "skillshot"},
  ['EliseSpiderEInitial'] = {charName = "Elise", spellSlot = "E", SpellType = "castcel"},
  ['elisespideredescent'] = {charName = "Elise", spellSlot = "E", SpellType = "castcel"},
  ['EvelynnQ'] = {charName = "Evelynn", spellSlot = "Q", SpellType = "skillshot"},
  ['EvelynnE'] = {charName = "Evelynn", spellSlot = "E", SpellType = "castcel"},
  ['EvelynnR'] = {charName = "Evelynn", spellSlot = "R", SpellType = "skillshot"},
  ['EzrealMysticShot'] = {charName = "Ezreal", spellSlot = "Q", SpellType = "skillshot"},
  ['EzrealEssenceFlux'] = {charName = "Ezreal", spellSlot = "W", SpellType = "skillshot"},
  ['EzrealArcaneShift'] = {charName = "Ezreal", spellSlot = "E", SpellType = "castcel"},
  ['EzrealTruehotBarrage'] = {charName = "Ezreal", spellSlot = "R", SpellType = "skillshot"},
  ['Terrify'] = {charName = "FiddleSticks", spellSlot = "Q", SpellType = "castcel"},
  ['Drain'] = {charName = "FiddleSticks", spellSlot = "W", SpellType = "castcel"},
  ['FiddlesticksDarkWind'] = {charName = "FiddleSticks", spellSlot = "E", SpellType = "castcel"},
  ['Crowstorm'] = {charName = "FiddleSticks", spellSlot = "R", SpellType = "skillshot"},
  ['FioraQ'] = {charName = "Fiora", spellSlot = "Q", SpellType = "castcel"},
  ['FioraDance'] = {charName = "Fiora", spellSlot = "R", SpellType = "castcel"},
  ['FizzPiercingStrike'] = {charName = "Fizz", spellSlot = "Q", SpellType = "castcel"},
  ['FizzJump'] = {charName = "Fizz", spellSlot = "E", SpellType = "skillshot"},
  ['FizzJumptwo'] = {charName = "Fizz", spellSlot = "E", SpellType = "skillshot"},
  ['FizzMarinerDoom'] = {charName = "Fizz", spellSlot = "R", SpellType = "skillshot"},
  ['GalioResoluteSmite'] = {charName = "Galio", spellSlot = "Q", SpellType = "skillshot"},
  ['GalioRighteousGust'] = {charName = "Galio", spellSlot = "E", SpellType = "skillshot"},
  ['GalioIdolOfDurand'] = {charName = "Galio", spellSlot = "R", SpellType = "skillshot"},
  ['Parley'] = {charName = "Gangplank", spellSlot = "Q", SpellType = "castcel"},
  ['CannonBarrage'] = {charName = "Gangplank", spellSlot = "R", SpellType = "skillshot"},
  ['GarenQ'] = {charName = "Garen", spellSlot = "Q", SpellType = "skillshot"},
  ['GarenE'] = {charName = "Garen", spellSlot = "E", SpellType = "skillshot"},
  ['GarenR'] = {charName = "Garen", spellSlot = "R", SpellType = "castcel"},
  ['GragasBarrelRoll'] = {charName = "Gragas", spellSlot = "Q", SpellType = "skillshot"},
  ['gragasbarrelrolltoggle'] = {charName = "Gragas", spellSlot = "Q", SpellType = "skillshot"},
  ['GragasBodySlam'] = {charName = "Gragas", spellSlot = "E", SpellType = "skillshot"},
  ['GragasExplosiveCask'] = {charName = "Gragas", spellSlot = "R", SpellType = "skillshot"},
  ['GravesClusterShot'] = {charName = "Graves", spellSlot = "Q", SpellType = "skillshot"},
  ['GravesSmokeGrenade'] = {charName = "Graves", spellSlot = "W", SpellType = "skillshot"},
  ['gravessmokegrenadeboom'] = {charName = "Graves", spellSlot = "W", SpellType = "skillshot"},
  ['GravesChargeShot'] = {charName = "Graves", spellSlot = "R", SpellType = "skillshot"},
  ['HecarimRapidSlash'] = {charName = "Hecarim", spellSlot = "Q", SpellType = "skillshot"},
  ['HecarimW'] = {charName = "Hecarim", spellSlot = "W", SpellType = "skillshot"},
  ['HecarimUlt'] = {charName = "Hecarim", spellSlot = "R", SpellType = "skillshot"},
  ['HeimerdingerQ'] = {charName = "Heimerdinger", spellSlot = "Q", SpellType = "skillshot"},
  ['HeimerdingerW'] = {charName = "Heimerdinger", spellSlot = "W", SpellType = "skillshot"},
  ['HeimerdingerE'] = {charName = "Heimerdinger", spellSlot = "E", SpellType = "skillshot"},
  ['IreliaGatotsu'] = {charName = "Irelia", spellSlot = "Q", SpellType = "castcel"},
  ['IreliaEquilibriumStrike'] = {charName = "Irelia", spellSlot = "E", SpellType = "castcel"},
  ['IreliaTranscendentBlades'] = {charName = "Irelia", spellSlot = "R", SpellType = "skillshot"},
  ['HowlingGale'] = {charName = "Janna", spellSlot = "Q", SpellType = "skillshot"},
  ['SowTheWind'] = {charName = "Janna", spellSlot = "W", SpellType = "castcel"},
  ['JarvanIVDragonStrike'] = {charName = "JarvanIV", spellSlot = "Q", SpellType = "skillshot"},
  ['JarvanIVDemacianStandard'] = {charName = "JarvanIV", spellSlot = "E", SpellType = "skillshot"},
  ['JarvanIVCataclysm'] = {charName = "JarvanIV", spellSlot = "R", SpellType = "skillshot"},
  ['JaxLeapStrike'] = {charName = "Jax", spellSlot = "Q", SpellType = "castcel"},
  ['JaxCounterStrike'] = {charName = "Jax", spellslot = "E", SpellType = "skillshot"},
  ['JayceToTheSkies'] = {charName = "Jayce", spellSlot = "Q", SpellType = "castcel"},
  ['JayceStaticField'] = {charName = "Jayce", spellSlot = "W", SpellType = "skillshot"},
  ['JayceThunderingBlow'] = {charName = "Jayce", spellSlot = "E", SpellType = "castcel"},
  ['jayceshockblast'] = {charName = "Jayce", spellSlot = "Q", SpellType = "skillshot"},
  ['jaycehypercharge'] = {charName = "Jayce", spellSlot = "W", SpellType = "skillshot"},
  ['jayceaccelerationgate'] = {charName = "Jayce", spellSlot = "E", SpellType = "skillshot"},
  ['JinxW'] = {charName = "Jinx", spellSlot = "W", SpellType = "skillshot"},
  ['JinxRWrapper'] = {charName = "Jinx", spellSlot = "R", SpellType = "skillshot"},
  ['LayWaste'] = {charName = "Karthus", spellSlot = "Q", SpellType = "skillshot"},
  ['WallOfPain'] = {charName = "Karthus", spellSlot = "W", SpellType = "skillshot"},
  ['Defile'] = {charName = "Karthus", spellSlot = "E", SpellType = "skillshot"},
  ['FallenOne'] = {charName = "Karthus", spellSlot = "R", SpellType = "skillshot"},
  ['KarmaQ'] = {charName = "Karma", spellSlot = "Q", SpellType = "skillshot"},
  ['KarmaSpiritBind'] = {charName = "Karma", spellSlot = "W", SpellType = "castcel"},
  ['NullLance'] = {charName = "Kassadin", spellSlot = "Q", SpellType = "castcel"},
  ['NetherBlade'] = {charName = "Kassadin", spellSlot = "W", SpellType = "skillshot"},
  ['ForcePulse'] = {charName = "Kassadin", spellSlot = "E", SpellType = "skillshot"},
  ['RiftWalk'] = {charName = "Kassadin", spellSlot = "R", SpellType = "skillshot"},
  ['KatarinaQ'] = {charName = "Katarina", spellSlot = "Q", SpellType = "castcel"},
  ['KatarinaW'] = {charName = "Katarina", spellSlot = "W", SpellType = "skillshot"},
  ['KatarinaE'] = {charName = "Katarina", spellSlot = "E", SpellType = "castcel"},
  ['KatarinaR'] = {charName = "Katarina", spellSlot = "R", SpellType = "skillshot"},
  ['JudicatorReckoning'] = {charName = "Kayle", spellSlot = "Q", SpellType = "castcel"},
  ['JudicatorRighteousFury'] = {charName = "Kayle", spellSlot = "E", SpellType = "skillshot"},
  ['KennenShurikenHurlMissile1'] = {charName = "Kennen", spellSlot = "Q"},
  ['KennenBringTheLight'] = {charName = "Kennen", spellSlot = "W", SpellType = "skillshot"},
  ['KennenShurikenStorm ']= {charName = "Kennen", spellSlot = "R", SpellType = "skillshot"},
  ['KhazixQ'] = {charName = "Khazix", spellSlot = "Q", SpellType = "castcel"},
  ['KhazixW'] = {charName = "Khazix", spellSlot = "W", SpellType = "skillshot"},
  ['KhazixE'] = {charName = "Khazix", spellSlot = "E", SpellType = "skillshot"},
  ['khazixqlong'] = {charName = "Khazix", spellSlot = "Q", SpellType = "castcel"},
  ['khazixwlong'] = {charName = "Khazix", spellSlot = "W", SpellType = "skillshot"},
  ['khazixelong'] = {charName = "Khazix", spellSlot = "E", SpellType = "skillshot"},
  ['KogMawCausticSpittle'] = {charName = "KogMaw", spellSlot = "Q", SpellType = "skillshot"},
  ['KogMawBioArcanBarrage'] = {charName = "KogMaw", spellSlot = "W", SpellType = "skillshot"},
  ['KogMawVoidOoze'] = {charName = "KogMaw", spellSlot = "E", SpellType = "skillshot"},
  ['KogMawLivingArtillery'] = {charName = "KogMaw", spellSlot = "R", SpellType = "skillshot"},
  ['LeblancChaosOrb'] = {charName = "Leblanc", spellSlot = "Q", SpellType = "castcel"},
  ['LeblancSlide'] = {charName = "Leblanc", spellSlot = "W", SpellType = "skillshot"},
  ['LeblancSoulShackle'] = {charName = "Leblanc", spellSlot = "E", SpellType = "skillshot"},
  ['LeblancChaosOrbM'] = {charName = "Leblanc", spellSlot = "R", SpellType = "castcel"},
  ['LeblancSlideM'] = {charName = "Leblanc", spellSlot = "R", SpellType = "skillshot"},
  ['LeblancSoulShackleM'] = {charName = "Leblanc", spellSlot = "R", SpellType = "skillshot"},
  ['BlindMonkQOne'] = {charName = "LeeSin", spellSlot = "Q", SpellType = "skillshot"},
  ['BlindMonkWOne'] = {charName = "LeeSin", spellSlot = "W", SpellType = "skillshot"},
  ['BlindMonkEOne'] = {charName = "LeeSin", spellSlot = "E", SpellType = "skillshot"},
  ['BlindMonkRKick'] = {charName = "LeeSin", spellSlot = "R", SpellType = "castcel"},
  ['blindmonkqtwo'] = {charName = "LeeSin", spellSlot = "Q", SpellType = "castcel"},
  ['blindmonkwtwo'] = {charName = "LeeSin", spellSlot = "W", SpellType = "skillshot"},
  ['blindmonketwo'] = {charName = "LeeSin", spellSlot = "E", SpellType = "skillshot"},
  ['LeonaShieldOfDaybreak'] = {charName = "Leona", spellSlot = "Q", SpellType = "skillshot"},
  ['LeonaSolarBarrier'] = {charName = "Leona", spellSlot = "W", SpellType = "skillshot"},
  ['LeonaZenithBlade'] = {charName = "Leona", spellSlot = "E", SpellType = "skillshot"},
  ['LeonaZenithBladeMissle'] = {charName = "Leona", spellSlot = "E", SpellType = "skillshot"},
  ['LeonaSolarFlare'] = {charName = "Leona", spellSlot = "R", SpellType = "skillshot"},
  ['LissandraQ'] = {charName = "Lissandra", spellSlot = "Q", SpellType = "skillshot"},
  ['LissandraW'] = {charName = "Lissandra", spellSlot = "W", SpellType = "skillshot"},
  ['LissandraE'] = {charName = "Lissandra", spellSlot = "E", SpellType = "skillshot"},
  ['LissandraR'] = {charName = "Lissandra", spellSlot = "R", SpellType = "skillshot"},
  ['LucianQ']= {charName = "Lucian", spellSlot = "Q", SpellType = "castcel"},
  ['LucianW']= {charName = "Lucian", spellSlot = "W", SpellType = "skillshot"},
  ['LucianR'] = {charName = "Lucian", spellSlot = "R", SpellType = "skillshot"},
  ['LuluQ'] = {charName = "Lulu", spellSlot = "Q", SpellType = "skillshot"},
  ['LuluW'] = {charName = "Lulu", spellSlot = "W", SpellType = "castcel"},
  ['LuluE'] = {charName = "Lulu", spellSlot = "E", SpellType = "castcel"},
  ['LuxLightBinding'] = {charName = "Lux", spellSlot = "Q", SpellType = "skillshot"},
  ['LuxPrismaticWave'] = {charName = "Lux", spellSlot = "W", SpellType = "skillshot"},
  ['LuxLightStrikeKugel'] = {charName = "Lux", spellSlot = "E", SpellType = "skillshot"},
  ['luxlightstriketoggle'] = {charName = "Lux", spellSlot = "E", SpellType = "skillshot"},
  ['LuxMaliceCannon'] = {charName = "Lux", spellSlot = "R", SpellType = "skillshot"},
  ['SeismicShard'] = {charName = "Malphite", spellSlot = "Q", SpellType = "castcel"},
  ['Landslide'] = {charName = "Malphite", spellSlot = "E", SpellType = "skillshot"},
  ['UFSlash'] = {charName = "Malphite", spellSlot = "R", SpellType = "skillshot"},
  ['AlZaharCalloftheVoid'] = {charName = "Malzahar", spellSlot = "Q", SpellType = "castcel"},
  ['AlZaharNullZone'] = {charName = "Malzahar", spellSlot = "W", SpellType = "skillshot"},
  ['AlZaharMaleficVisions'] = {charName = "Malzahar", spellSlot = "E", SpellType = "castcel"},
  ['AlZaharNetherGrasp'] = {charName = "Malzahar", spellSlot = "R", SpellType = "castcel"},
  ['MaokaiTrunkLine'] = {charName = "Maokai", spellSlot = "Q", SpellType = "skillshot"},
  ['MaokaiUnstableGrowth'] = {charName = "Maokai", spellSlot = "W", SpellType = "castcel"},
  ['MaokaiSapling2'] = {charName = "Maokai", spellSlot = "E", SpellType = "skillshot"},
  ['MaokaiDrain3'] = {charName = "Maokai", spellSlot = "R", SpellType = "skillshot"},
  ['AlphaStrike'] = {charName = "MasterYi", spellSlot = "Q", SpellType = "castcel"},
  ['MissFortuneRicochetShot'] = {charName = "MissFortune", spellSlot = "Q", SpellType = "castcel"},
  ['MissFortuneScattershot'] = {charName = "MissFortune", spellSlot = "E", SpellType = "skillshot"},
  ['MissFortuneBulletTime'] = {charName = "MissFortune", spellSlot = "R", SpellType = "skillshot"},
  ['MordekaiserMaceOfSpades'] = {charName = "Mordekaiser", spellSlot = "Q", SpellType = "skillshot"},
  ['MordekaiserSyphoneOfDestruction'] = {charName = "Mordekaiser", spellSlot = "E", SpellType = "skillshot"},
  ['MordekaiserChildrenOfTheGrave'] = {charName = "Mordekaiser", spellSlot = "R", SpellType = "castcel"},
  ['DarkBindingMissile'] = {charName = "Morgana", spellSlot = "Q", SpellType = "skillshot"},
  ['TormentedSoil'] = {charName = "Morgana", spellSlot = "W", SpellType = "skillshot"},
  ['SoulShackles'] = {charName = "Morgana", spellSlot = "R", SpellType = "skillshot"},
  ['NamiQ'] = {charName = "Nami", spellSlot = "Q", SpellType = "skillshot"},
  ['NamiW'] = {charName = "Nami", spellSlot = "W", SpellType = "castcel"},
  ['NamiE'] = {charName = "Nami", spellSlot = "E", SpellType = "skillshot"},
  ['NamiR'] = {charName = "Nami", spellSlot = "R", SpellType = "skillshot"},
  ['NasusQ'] = {charName = "Nasus", spellSlot = "Q", SpellType = "skillshot"},
  ['NasusW'] = {charName = "Nasus", spellSlot = "W", SpellType = "castcel"},
  ['NasusE'] = {charName = "Nasus", spellSlot = "E", SpellType = "skillshot"},
  ['NautilusAnchorDrag'] = {charName = "Nautilus", spellSlot = "Q", SpellType = "skillshot"},
  ['NautilusSplashZone'] = {charName = "Nautilus", spellSlot = "E", SpellType = "skillshot"},
  ['NautilusGandLine'] = {charName = "Nautilus", spellSlot = "R", SpellType = "castcel"},
  ['JavelinToss'] = {charName = "Nidalee", spellSlot = "Q", SpellType = "skillshot"},
  ['Bushwhack'] = {charName = "Nidalee", spellSlot = "W", SpellType = "skillshot"},
  ['PrimalSurge'] = {charName = "Nidalee", spellSlot = "E", SpellType = "skillshot"},
  ['Takedown'] = {charName = "Nidalee", spellSlot = "Q", SpellType = "skillshot"},
  ['Pounce'] = {charName = "Nidalee", spellSlot = "W", SpellType = "skillshot"},
  ['Swipe'] = {charName = "Nidalee", spellSlot = "E", SpellType = "skillshot"},
  ['NocturneDuskbringer'] = {charName = "Nocturne", spellSlot = "Q", SpellType = "skillshot"},
  ['NocturneUnspeakableHorror'] = {charName = "Nocturne", spellSlot = "E", SpellType = "castcel"},
  ['IceBlast'] = {charName = "Nunu", spellSlot = "E", SpellType = "castcel"},
  ['AbsoluteZero'] = {charName = "Nunu", spellSlot = "R", SpellType = "skillshot"},
  ['OlafAxeThrowCast'] = {charName = "Olaf", spellSlot = "Q", SpellType = "skillshot"},
  ['OlafRecklessStrike'] = {charName = "Olaf", spellSlot = "E", SpellType = "castcel"},
  ['OrianaIzunaCommand'] = {charName = "Orianna", spellSlot = "Q", SpellType = "skillshot"},
  ['OrianaDissonanceCommand'] = {charName = "Orianna", spellSlot = "W", SpellType = "skillshot"},
  ['OrianaDetonateCommand'] = {charName = "Orianna", spellSlot = "R", SpellType = "skillshot"},
  ['Pantheon_Throw'] = {charName = "Pantheon", spellSlot = "Q", SpellType = "castcel"},
  ['Pantheon_LeapBash'] = {charName = "Pantheon", spellSlot = "W", SpellType = "castcel"},
  ['Pantheon_Heartseeker'] = {charName = "Pantheon", spellSlot = "E", SpellType = "skillshot"},
  ['PoppyDevastatingBlow'] = {charName = "Poppy", spellSlot = "Q", SpellType = "skillshot"},
  ['PoppyHeroicCharge'] = {charName = "Poppy", spellSlot = "E", SpellType = "castcel"},
  ['QuinnQ'] = {charName = "Quinn", spellSlot = "Q", SpellType = "skillshot"},
  ['QuinnE'] = {charName = "Quinn", spellSlot = "E", SpellType = "castcel"},
  ['PowerBall'] = {charName = "Rammus", spellSlot = "Q", SpellType = "skillshot"},
  ['PuncturingTaunt'] = {charName = "Rammus", spellSlot = "E", SpellType = "castcel"},
  ['Tremors2'] = {charName = "Rammus", spellSlot = "R", SpellType = "skillshot"},
  ['RenektonCleave'] = {charName = "Renekton", spellSlot = "Q", SpellType = "skillshot"},
  ['RenektonPreExecute'] = {charName = "Renekton", spellSlot = "W", SpellType = "skillshot"},
  ['RenektonSliceAndDice'] = {charName = "Renekton", spellSlot = "E", SpellType = "skillshot"},
  ['RengarQ'] = {charName = "Rengar", spellSlot = "Q", SpellType = "skillshot"},
  ['RengarE'] = {charName = "Rengar", spellSlot = "E", SpellType = "skillshot"},
  ['RivenTriCleav'] = {charName = "Riven", spellSlot = "Q", SpellType = "skillshot"},
  ['RivenTriCleave_03'] = {charName = "Riven", spellSlot = "Q", SpellType = "skillshot"},
  ['RivenMartyr'] = {charName = "Riven", spellSlot = "W", SpellType = "skillshot"},
  ['RivenFengShuiEngine'] = {charName = "Riven", spellSlot = "R", SpellType = "skillshot"},
  ['rivenizunablade'] = {charName = "Riven", spellSlot = "R", SpellType = "skillshot"},
  ['RumbleFlameThrower'] = {charName = "Rumble", spellSlot = "Q", SpellType = "skillshot"},
  ['RumbeGrenade'] = {charName = "Rumble", spellSlot = "E", SpellType = "skillshot"},
  ['RumbleCarpetBomb'] = {charName = "Rumble", spellSlot = "R", SpellType = "skillshot"},
  ['Overload'] = {charName = "Ryze", spellSlot = "Q", SpellType = "castcel"},
  ['RunePrison'] = {charName = "Ryze", spellSlot = "W", SpellType = "castcel"},
  ['SpellFlux'] = {charName = "Ryze", spellSlot = "E", SpellType = "castcel"},
  ['SejuaniArcticAssault'] = {charName = "Sejuani", spellSlot = "Q", SpellType = "skillshot"},
  ['SejuaniGlacialPrisonStart'] = {charName = "Sejuani", spellSlot = "R", SpellType = "skillshot"},
  ['Deceive'] = {charName = "Shaco", spellSlot = "Q", SpellType = "skillshot"},
  ['JackInTheBox'] = {charName = "Shaco", spellSlot = "W", SpellType = "skillshot"},
  ['TwoShivPoisen'] = {charName = "Shaco", spellSlot = "E", SpellType = "castcel"},
  ['ShenVorpalStar'] = {charName = "Shen", spellSlot = "Q", SpellType = "castcel"},
  ['ShenShadowDash'] = {charName = "Shen", spellSlot = "E", SpellType = "skillshot"},
  ['ShyvanaFireball'] = {charName = "Shyvana", spellSlot = "E", SpellType = "skillshot"},
  ['ShyvanaTransformCast'] = {charName = "Shyvana", spellSlot = "R", SpellType = "skillshot"},
  ['PoisenTrail'] = {charName = "Singed", spellSlot = "Q", SpellType = "skillshot"},
  ['MegaAdhesive'] = {charName = "Singed", spellSlot = "W", SpellType = "skillshot"},
  ['Fling'] = {charName = "Singed", spellSlot = "E", SpellType = "castcel"},
  ['CrypticGaze'] = {charName = "Sion", spellSlot = "Q", SpellType = "castcel"},
  ['SivirQ'] = {charName = "Sivir", spellSlot = "Q", SpellType = "skillshot"},
  ['SkarnerVirulentSlash'] = {charName = "Skarner", spellSlot = "Q", SpellType = "skillshot"},
  ['SkarnerFracture'] = {charName = "Skarner", spellSlot = "E", SpellType = "skillshot"},
  ['SkarnerImpale'] = {charName = "Skarner", spellSlot = "R", SpellType = "castcel"},
  ['SonaHymnofValor'] = {charName = "Sona", spellSlot = "Q", SpellType = "castcel"},
  ['SonaAriaofPerseverance'] = {charName = "Sona", spellSlot = "W", SpellType = "skillshot"},
  ['SonaSongofDiscord'] = {charName = "Sona", spellSlot = "E", SpellType = "skillshot"},
  ['SonaCrescendo'] = {charName = "Sona", spellSlot = "R", SpellType = "skillshot"},
  ['Starcall'] = {charName = "Soraka", spellSlot = "Q", SpellType = "skillshot"},
  ['InfuseWrapper'] = {charName = "Soraka", spellSlot = "E", SpellType = "castcel"},
  ['SwainDecrepify'] = {charName = "Swain", spellSlot = "Q", SpellType = "castcel"},
  ['SwainShadowGrasp'] = {charName = "Swain", spellSlot = "W", SpellType = "skillshot"},
  ['SwainTorment'] = {charName = "Swain", spellSlot = "E", SpellType = "castcel"},
  ['SwainMetamorphism'] = {charName = "Swain", spellSlot = "R", SpellType = "skillshot"},
  ['SyndraQ']= {charName = "Syndra", spellSlot = "Q", SpellType = "skillshot"},
  ['SyndraW ']= {charName = "Syndra", spellSlot = "W", SpellType = "skillshot"},
  ['SyndraE'] = {charName = "Syndra", spellSlot = "E", SpellType = "skillshot"},
  ['SyndraR'] = {charName = "Syndra", spellSlot = "R", SpellType = "castcel"},
  ['TalonRake'] = {charName = "Talon", spellSlot = "W", SpellType = "skillshot"},
  ['TalonCutthroat'] = {charName = "Talon", spellSlot = "E", SpellType = "castcel"},
  ['Shatter'] = {charName = "Taric", spellSlot = "W", SpellType = "skillshot"},
  ['Dazzle'] = {charName = "Taric", spellSlot = "E", SpellType = "castcel"},
  ['TaricHammerSmash'] = {charName = "Taric", spellSlot = "R", SpellType = "skillshot"},
  ['BlindingDart'] = {charName = "Teemo", spellSlot = "Q", SpellType = "castcel"},
  ['ThreshQ'] = {charName = "Thresh", spellSlot = "Q", SpellType = "skillshot"},
  ['ThreshE'] = {charName = "Thresh", spellSlot = "E", SpellType = "skillshot"},
  ['ThreshRPenta'] = {charName = "Thresh", spellSlot = "R", SpellType = "skillshot"},
  ['RocketJump'] = {charName = "Tristana", spellSlot = "W", SpellType = "skillshot"},
  ['DetonatingShot'] = {charName = "Tristana", spellSlot = "E", SpellType = "castcel"},
  ['BusterShot'] = {charName = "Tristana", spellSlot = "R", SpellType = "castcel"},
  ['TrundleTrollSmash'] = {charName = "Trundle", spellSlot = "Q", SpellType = "castcel"},
  ['TrundlePain'] = {charName = "Trundle", spellSlot = "R", SpellType = "castcel"},
  ['slashCast'] = {charName = "Tryndamere", spellSlot = "E", SpellType = "skillshot"},
  ['WildCards'] = {charName = "TwistedFate", spellSlot = "Q", SpellType = "skillshot"},
  ['TwitchVenomCask'] = {charName = "Twitch", spellSlot = "W", SpellType = "skillshot"},
  ['TwitchVenomCaskMissle'] = {charName = "Twitch", spellSlot = "W", SpellType = "skillshot"},
  ['Expunge'] = {charName = "Twitch", spellSlot = "E", SpellType = "skillshot"},
  ['UdyrTigerStance'] = {charName = "Udyr", spellSlot = "Q", SpellType = "skillshot"},
  ['UdyrTurtleStance'] = {charName = "Udyr", spellSlot = "W", SpellType = "skillshot"},
  ['UdyrBearStance'] = {charName = "Udyr", spellSlot = "E", SpellType = "skillshot"},
  ['UdyrPhoenixStance'] = {charName = "Udyr", spellSlot = "R", SpellType = "skillshot"},
  ['UrgotHeatseekingMissile'] = {charName = "Urgot", spellSlot = "Q", SpellType = "skillshot"},
  ['UrgotPlasmaGrenade'] = {charName = "Urgot", spellSlot = "E", SpellType = "skillshot"},
  ['UrgotSwap2'] = {charName = "Urgot", spellSlot = "R", SpellType = "castcel"},
  ['VarusQ'] = {charName = "Varus", spellSlot = "Q", SpellType = "skillshot"},
  ['VarusE'] = {charName = "Varus", spellSlot = "E", SpellType = "skillshot"},
  ['VarusR'] = {charName = "Varus", spellSlot = "R", SpellType = "skillshot"},
  ['VayneCondemm'] = {charName = "Vayne", spellSlot = "E", SpellType = "castcel"},
  ['VeigarBalefulStrike'] = {charName = "Veigar", spellSlot = "Q", SpellType = "castcel"},
  ['VeigarDarkMatter'] = {charName = "Veigar", spellSlot = "W", SpellType = "skillshot"},
  ['VeigarEventHorizon'] = {charName = "Veigar", spellSlot = "E", SpellType = "skillshot"},
  ['VeigarPrimordialBurst'] = {charName = "Veigar", spellSlot = "R", SpellType = "castcel"},
  ['VelkozQ'] = {charName = "Velkoz", spellSlot = "Q", SpellType = "castcel"},
  ['VelkozQMissle'] = {charName = "Velkoz", spellSlot = "Q", SpellType = "castcel"},
  ['velkozqplitactive'] = {charName = "Velkoz", spellSlot = "Q", SpellType = "castcel"},
  ['VelkozW'] = {charName = "Velkoz", spellSlot = "W", SpellType = "skillshot"},
  ['VelkozE'] = {charName = "Velkoz", spellSlot = "E", SpellType = "skillshot"},
  ['VelkozR'] = {charName = "Velkoz", spellSlot = "R", SpellType = "skillshot"},
  ['ViQ'] = {charName = "Vi", spellSlot = "Q", SpellType = "skillshot"},
  ['ViR'] = {charName = "Vi", spellSlot = "R", SpellType = "castcel"},
  ['ViktorPowerTransfer'] = {charName = "Viktor", spellSlot = "Q", SpellType = "castcel"},
  ['ViktorGravitonField'] = {charName = "Viktor", spellSlot = "W", SpellType = "skillshot"},
  ['ViktorDeathRa'] = {charName = "Viktor", spellSlot = "E", SpellType = "skillshot"},
  ['ViktorChaosStorm'] = {charName = "Viktor", spellSlot = "R", SpellType = "skillshot"},
  ['VladimirTransfusion'] = {charName = "Vladimir", spellSlot = "Q", SpellType = "castcel"},
  ['VladimirTidesofBlood'] = {charName = "Vladimir", spellSlot = "E", SpellType = "skillshot"},
  ['VladimirHemoplague'] = {charName = "Vladimir", spellSlot = "R", SpellType = "skillshot"},
  ['VolibearQ'] = {charName = "Volibear", spellSlot = "Q", SpellType = "skillshot"},
  ['VolibearW'] = {charName = "Volibear", spellSlot = "W", SpellType = "castcel"},
  ['VolibearE'] = {charName = "Volibear", spellSlot = "E", SpellType = "skillshot"},
  ['HungeringStrike'] = {charName = "Warwick", spellSlot = "Q", SpellType = "castcel"},
  ['InfiniteDuress'] = {charName = "Warwick", spellSlot = "R", SpellType = "castcel"},
  ['MonkeyKingDoubleAttack'] = {charName = "MonkeyKing", spellSlot = "Q", SpellType = "skillshot"},
  ['MonkeyKingNimbus'] = {charName = "MonkeyKing", spellSlot = "E", SpellType = "castcel"},
  ['MonkeyKingSpinToWin'] = {charName = "MonkeyKing", spellSlot = "R", SpellType = "skillshot"},
  ['monkeykingspintowinleave'] = {charName = "MonkeyKing", spellSlot = "R", SpellType = "skillshot"},
  ['XerathArcanoPulseChargeUp'] = {charName = "Xerath", spellSlot = "Q", SpellType = "skillshot"},
  ['XerathArcaneBarrage2'] = {charName = "Xerath", spellSlot = "W", SpellType = "skillshot"},
  ['XerathMageSpear'] = {charName = "Xerath", spellSlot = "E", SpellType = "skillshot"},
  ['XerathLocusOfPower2'] = {charName = "Xerath", spellSlot = "R", SpellType = "castcel"},
  ['XenZhaoSweep'] = {charName = "Xin Zhao", spellSlot = "E", SpellType = "castcel"},
  ['XenZhaoParry'] = {charName = "Xin Zhao", spellSlot = "R", SpellType = "skillshot"},
  ['YasuoQW'] = {charName = "Yasuo", spellSlot = "Q", SpellType = "skillshot"},
  ['yasuoq2w'] = {charName = "Yasuo", spellSlot = "Q", SpellType = "skillshot"},
  ['yasuoq3w'] = {charName = "Yasuo", spellSlot = "Q", SpellType = "skillshot"},
  ['YasuoDashWrapper'] = {charName = "Yasuo", spellSlot = "E", SpellType = "castcel"},
  ['YasuoRKnockUpComboW'] = {charName = "Yasuo", spellSlot = "R", SpellType = "skillshot"},
  ['YorickSpectral'] = {charName = "Yorick", spellSlot = "Q", SpellType = "skillshot"},
  ['YorickDecayed'] = {charName = "Yorick", spellSlot = "W", SpellType = "skillshot"},
  ['YorickRavenous'] = {charName = "Yorick", spellSlot = "E", SpellType = "castcel"},
  ['ZacQ'] = {charName = "Zac", spellSlot = "Q", SpellType = "skillshot"},
  ['ZacW'] = {charName = "Zac", spellSlot = "W", SpellType = "skillshot"},
  ['ZacE'] = {charName = "Zac", spellSlot = "E", SpellType = "skillshot"},
  ['ZedShuriken'] = {charName = "Zed", spellSlot = "Q", SpellType = "skillshot"},
  ['zedult'] = {charName = "Zed", spellSlot = "R", SpellType = "castcel"},
  ['ZiggsQ'] = {charName = "Ziggs", spellSlot = "Q", SpellType = "skillshot"},
  ['ZiggsW'] = {charName = "Ziggs", spellSlot = "W", SpellType = "skillshot"},
  ['ZiggsE'] = {charName = "Ziggs", spellSlot = "E", SpellType = "skillshot"},
  ['ZiggsR'] = {charName = "Ziggs", spellSlot = "R", SpellType = "skillshot"},
  ['TimeBomb'] = {charName = "Zilean", spellSlot = "Q", SpellType = "castcel"},
  ['Rewind'] = {charName = "Zilean", spellSlot = "W"},
  ['TimeWarp'] = {charName = "Zilean", spellSlot = "E", SpellType = "castcel"},
  ['ZyraQFissure'] = {charName = "Zyra", spellSlot = "Q", SpellType = "skillshot"},
  ['ZyraGraspingRoots'] = {charName = "Zyra", spellSlot = "E", SpellType = "skillshot"},
  ['ZyraBrambleZone'] = {charName = "Zyra", spellSlot = "R", SpellType = "skillshot"},
}
	
local skills = {
	skillQ = {range = 1200, speed = 1200, delay = 0.250, width = 60},
	skillW = {range = 900, speed = 1200, delay = 0.150, width = 105},
	skillE = {range = 750},
	skillR = {range = 600},
}
local QReady, WReady, EReady, RReady, IReady, hextechready, deathfiregraspready, blackfiretorchready, woogletready, zhonyaready = false, false, false, false, false, false, false, false, false, false
local abilitylvl, blackfiretorchrange, deathfiregrasprange, hextechrange, lastskin = 0, 600, 600, 600, 0
local EnemyMinions = minionManager(MINION_ENEMY, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, skills.skillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, zhonyaslot, woogletslot, hextechslot, deathfiregraspslot, blackfiretorchslot = nil, nil, nil, nil, nil, nil
local Spells = {_Q,_W,_E,_R}
local Spells2 = {"Q","W","E","R"}
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
	return MenuMorg.prConfig.skin1 ~= lastSkin
end

function OnTick()
	Cel = STS:GetTarget(skills.skillQ.range)
	CelH = STS:GetTarget(skills.skillQ.range)
	Check()
	if Cel ~= nil and MenuMorg.comboConfig.CEnabled then
		caa()
		Combo()
	end
	if CelH ~= nil and MenuMorg.harrasConfig.HEnabled then
		Harrass()
	end
	if CelH ~= nil and MenuMorg.harrasConfig.HTEnabled then
		Harrass()
	end
	if MenuMorg.farm.Freeze or MenuMorg.farm.LaneClear then
		local Mode = MenuMorg.farm.Freeze and "Freeze" or "LaneClear"
		Farm(Mode)
	end
	if MenuMorg.jf.JFEnabled then
		JungleFarmm()
	end
	if MenuMorg.prConfig.AZ then
		autozh()
	end
	if MenuMorg.prConfig.ALS then
		autolvl()
	end
	KillSteall()
end
		
function Menu()
	VP = VPrediction(true)
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC) 
	MenuMorg = scriptConfig("Morgana Master "..version, "Morgana Master "..version)
	MenuMorg:addSubMenu("Orbwalking", "Orbwalking")
	SOWi:LoadToMenu(MenuMorg.Orbwalking)
	MenuMorg:addSubMenu("Target selector", "STS")
    STS:AddToMenu(MenuMorg.STS)
	--[[--- Combo --]]--
	MenuMorg:addSubMenu("[Morgana Master]: Combo Settings", "comboConfig")
    MenuMorg.comboConfig:addParam("USEQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
    MenuMorg.comboConfig:addParam("USEW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.comboConfig:addParam("USEE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.comboConfig:addParam("USER", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.comboConfig:addParam("ENEMYTOR", "Min Enemies to Cast R: ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuMorg.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--[[--- Harras --]]--
	MenuMorg:addSubMenu("[Morgana Master]: Harras Settings", "harrasConfig")
    MenuMorg.harrasConfig:addParam("QH", "Harras Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.harrasConfig:addParam("WH", "Harras Use W", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.harrasConfig:addParam("HWS", "Use 'W' Only On Stunned Enemy", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuMorg.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	--[[--- Mana Manager --]]--
	MenuMorg:addSubMenu("[Morgana Master]: Mana Settings" , "mpConfig")
	MenuMorg.mpConfig:addParam("mptocq", "Min. Mana To Cast Q", SCRIPT_PARAM_SLICE, 20, 0, 100, 0) 
	MenuMorg.mpConfig:addParam("mptocw", "Min. Mana To Cast W", SCRIPT_PARAM_SLICE, 25, 0, 100, 0) 
	MenuMorg.mpConfig:addParam("mptocr", "Min. Mana To Cast R", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuMorg.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.mpConfig:addParam("mptohq", "Min. Mana To Harras Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0) 
	MenuMorg.mpConfig:addParam("mptohw", "Min. Mana To Harras W", SCRIPT_PARAM_SLICE, 55, 0, 100, 0)
	MenuMorg.mpConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.mpConfig:addParam("mptofq", "Min. Mana To Farm Q", SCRIPT_PARAM_SLICE, 60, 0, 100, 0) 
	MenuMorg.mpConfig:addParam("mptofw", "Min. Mana To Farm W", SCRIPT_PARAM_SLICE, 65, 0, 100, 0)
	--[[--- Kill Steal --]]--
	MenuMorg:addSubMenu("[Morgana Master]: KS Settings", "ksConfig")
	MenuMorg.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.ksConfig:addParam("QKS", "Use Q To KS", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.ksConfig:addParam("WKS", "Use W To KS", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.ksConfig:addParam("RKS", "Use R To KS", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.ksConfig:addParam("ITKS", "Use Items To KS", SCRIPT_PARAM_ONOFF, true)
	--[[--- Farm --]]--
	MenuMorg:addSubMenu("[Morgana Master]: Farm Settings", "farm")
	MenuMorg.farm:addParam("QF", "Use Q Farm", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
	MenuMorg.farm:addParam("WF",  "Use W", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
	MenuMorg.farm:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
	MenuMorg.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	--[[--- Jungle Farm --]]--
	MenuMorg:addSubMenu("[Morgana Master]: Jungle Farm", "jf")
	MenuMorg.jf:addParam("QJF", "Jungle Farm Use Q", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.jf:addParam("WJF", "Jungle Farm Use W", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--[[--- Extra --]]--
	MenuMorg:addSubMenu("[Morgana Master]: Shield Settings", "exConfig")
	MenuMorg.exConfig:addSubMenu("Enemy Skills", "ES")
	Enemies = GetEnemyHeroes() 
    for i,enemy in pairs (Enemies) do
		for j,spell in pairs (Spells) do 
			if Shieldspells[enemy:GetSpellData(spell).name] then 
				MenuMorg.exConfig.ES:addParam(tostring(enemy:GetSpellData(spell).name),"Block "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
			end 
		end 
	end 
	MenuMorg.exConfig:addParam("UAS", "Use Auto Shield", SCRIPT_PARAM_ONOFF, false)
	--[[--- Drawing --]]--
	MenuMorg:addSubMenu("[Morgana Master]: Draw Settings", "drawConfig")
	MenuMorg.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.drawConfig:addParam("DSE", "Draw Stunned Enemy", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.drawConfig:addParam("DSEC", "Draw Stunned Enemy Color", SCRIPT_PARAM_COLOR, {255,0,240,0})
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
	--[[--- Misc --]]--
	MenuMorg:addSubMenu("[Morgana Master]: Misc Settings", "prConfig")
	MenuMorg.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuMorg.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuMorg.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 6, 1, 6)
	MenuMorg.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuMorg.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuMorg.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuMorg.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuMorg.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuMorg.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuMorg.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuMorg.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	if MenuMorg.prConfig.skin and VIP_USER then
		GenModelPacket("Morgana", MenuMorg.prConfig.skin1)
		lastSkin = MenuMorg.prConfig.skin1
	end
	--[[-- PermShow --]]--
	MenuMorg.comboConfig:permaShow("CEnabled")
	MenuMorg.harrasConfig:permaShow("HEnabled")
	MenuMorg.harrasConfig:permaShow("HTEnabled")
	MenuMorg.prConfig:permaShow("AZ")
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

function caa()
	if MenuMorg.comboConfig.uaa then
		SOWi:EnableAttacks()
	elseif not MenuMorg.comboConfig.uaa then
		SOWi:DisableAttacks()
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
	if MenuMorg.prConfig.skin and VIP_USER and skinChanged() then
		GenModelPacket("Morgana", MenuMorg.prConfig.skin1)
		lastSkin = MenuMorg.prConfig.skin1
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
	if MenuMorg.comboConfig.USEQ then
		if QReady and MenuMorg.comboConfig.USEQ and Cel.canMove and GetDistance(Cel) < skills.skillQ.range and ccq then
			CastQ(Cel)
		end
	end
	if MenuMorg.comboConfig.USEW then
		if WReady and MenuMorg.comboConfig.USEW and not Cel.canMove and GetDistance(Cel) < skills.skillW.range and ccw then
			CastW(Cel)
		end
	end
	if MenuMorg.comboConfig.USEE then
		if EReady and MenuMorg.comboConfig.USEE then
			CastSpell(_E)
		end
	end
	if MenuMorg.comboConfig.USER then
		local enemyCount = EnemyCount(myHero, skills.skillR.range)
		if RReady and GetDistance(Cel) < skills.skillR.range and MenuMorg.comboConfig.USER and enemyCount >= MenuMorg.comboConfig.ENEMYTOR and ccr then
			CastSpell(_R)
		end
	end
end
--END COMBO--

--HARRAS--
function Harrass()
	if MenuMorg.harrasConfig.QH then
		if QReady and GetDistance(CelH) < skills.skillQ.range and CelH ~= nil and CelH.team ~= player.team and not CelH.dead and chq then
			CastQ(CelH)
		end
	end
	if MenuMorg.harrasConfig.WH then
		if WReady and GetDistance(CelH) < skills.skillW.range and CelH ~= nil and CelH.team ~= player.team and not CelH.dead and chw then
			if MenuMorg.harrasConfig.HWS then
				if not CelH.canMove then
					CastW(CelH)
				end
			end
			if not MenuMorg.harrasConfig.HWS then
				CastW(CelH)
			end
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
				local Pos, Hit = BestWFarmPos(skills.skillW.range, skills.skillW.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
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
	if MenuMorg.jf.QJF then
		for i, minion in pairs(JungleMinions.objects) do
			if QReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillQ.range and cfq then
				CastQ(minion)
			end
		end
	end
	if MenuMorg.jf.WJF then
		for i, minion in pairs(JungleMinions.objects) do
			if WReady and minion ~= nil and not minion.dead and GetDistance(minion) <= skills.skillW.range and cfw then
				local Pos, Hit = BestWFarmPos(skills.skillW.range, skills.skillW.width, JungleMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
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
		if MenuMorg.ksConfig.IKS then
			iDmg = getDmg("IGNITE", Enemy, myHero)
		else 
			iDmg = 0
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
			if IReady and health <= iDmg and MenuMorg.ksConfig.IKS and (distance < 600) then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end
--END KILL STEAL--

--DRAWING--
function OnDraw()
	if MenuMorg.drawConfig.DSE then
		for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
			if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.canMove and not Enemy.dead and Enemy.visible then
				if MenuMorg.drawConfig.DLC then
					DrawCircle3D(Enemy.x, Enemy.y, Enemy.z, 100, 1, RGB(MenuMorg.drawConfig.DSEC[2], MenuMorg.drawConfig.DSEC[3], MenuMorg.drawConfig.DSEC[4]))
				end
				DrawCircle(Enemy.x, Enemy.y, Enemy.z, 100, ARGB(MenuMorg.drawConfig.DSEC[1], MenuMorg.drawConfig.DSEC[2], MenuMorg.drawConfig.DSEC[3], MenuMorg.drawConfig.DSEC[4]))
			end
		end
	end
	if MenuMorg.drawConfig.DQL and ValidTarget(Cel, skills.skillQ.range) and not GetMinionCollision(myHero, Cel, skills.skillQ.width) then
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
	local count = EnemyCount(myHero, MenuMorg.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuMorg.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuMorg.prConfig.ALS then return end

	
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuMorg.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuMorg.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuMorg.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuMorg.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuMorg.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuMorg.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end
--END EXTRA--

function OnProcessSpell(object, spell)
	if MenuMorg.exConfig.UAS then
		if object and object.team ~= myHero.team and object.type == myHero.type and spell then
			if Shieldspells[spell.name] then 
				if Shieldspells[spell.name].SpellType == "castcel" then 
					if EReady and MenuMorg.exConfig.ES[spell.name] and spell.target == myHero then 
						CastSpell(_E)
					end
				end
				if Shieldspells[spell.name].SpellType == "skillshot" then 
					if not spell.endPos then
						spell.endPos.x = spell.endPos.x
						spell.endPos.z = spell.endPos.z                    
					end   
					if EReady and MenuMorg.exConfig.ES[spell.name] and GetDistance(spell.endPos) < 400 then
						CastSpell(_E)
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

function SpellCast(spellSlot,castPosition)
	if VIP_USER and MenuMorg.prConfig.pc then
		Packet("S_CAST", {spellId = spellSlot, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
	else
		CastSpell(spellSlot,castPosition.x,castPosition.z)
	end
end

function CastQ(unit)
	if MenuMorg.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, skills.skillQ.delay, skills.skillQ.width, skills.skillQ.range, skills.skillQ.speed, myHero, true)
		local col = VP:CheckMinionCollision(myHero, unit, skills.skillQ.delay, skills.skillQ.width, GetDistance(myHero, unit), skills.skillQ.speed, myHero, false)
		if CastPosition and HitChance >= MenuMorg.prConfig.vphit - 1 and not col then
			SpellCast(_Q, CastPosition)
			return
		end
	end
	if MenuMorg.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, skills.skillQ.range, skills.skillQ.speed, skills.skillQ.delay, skills.skillQ.width)
		if Position ~= nil and info.hitchance >= 2 and not info.mCollision() then
			SpellCast(_Q, Position)
			return		
		end
	end
end

function CastW(unit)
	if MenuMorg.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, skills.skillW.delay, skills.skillW.width, skills.skillW.range, skills.skillW.speed, myHero, false)
		if CastPosition and HitChance >= MenuMorg.prConfig.vphit - 1 then
			SpellCast(_W, CastPosition)
			return
		end
	end
	if MenuMorg.prConfig.pro == 2 and VIP_USER and prodstatus then
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
