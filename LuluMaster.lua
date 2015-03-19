--[[

	Script Name: LULU MASTER 
    	Author: kokosik1221
	Last Version: 0.21
	19.03.2015
	
]]-- 

if myHero.charName ~= "Lulu" then return end

_G.AUTOUPDATE = true


local version = "0.21"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/LuluMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>LuluMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/LuluMaster.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end
local REQUIRED_LIBS = {
	["vPrediction"] = "https://raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua",
	["Prodiction"] = "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua",
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
}
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#FF0000\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end
for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		if DOWNLOAD_LIB_NAME ~= "Prodiction" then 
			require(DOWNLOAD_LIB_NAME) 
		end
		if DOWNLOAD_LIB_NAME == "Prodiction" and VIP_USER then 
			require(DOWNLOAD_LIB_NAME) 
			prodstatus = true 
		end
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

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
  ['CurseoftheSadMummy'] = {charName = "Amumu", spellSlot = "R", SpellType = "skillshot"},
  ['FlashFrost'] = {charName = "Anivia", spellSlot = "Q", SpellType = "skillshot"},
  ['Frostbite'] = {charName = "Anivia", spellSlot = "E", SpellType = "castcel"},
  ['GlacialStorm'] = {charName = "Anivia", spellSlot = "R", SpellType = "skillshot"},
  ['Disintegrate'] = {charName = "Annie", spellSlot = "Q", SpellType = "castcel"},
  ['Incinerate'] = {charName = "Annie", spellSlot = "W", SpellType = "castcel"},
  ['InfernalGuardian'] = {charName = "Annie", spellSlot = "R", SpellType = "castcel"},
  ['Volley'] = {charName = "Ashe", spellSlot = "W", SpellType = "skillshot"},
  ['EnchantedCrystalArrow'] = {charName = "Ashe", spellSlot = "R", SpellType = "skillshot"},
  ['RocketGrab'] = {charName = "Blitzcrank", spellSlot = "Q", SpellType = "skillshot"},
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
  ['GnarQ'] = {charName = "Gnar", spellSlot = "Q", SpellType = "skillshot"},
  ['GnarBigQ'] = {charName = "Gnar", spellSlot = "Q", SpellType = "skillshot"},
  ['GnarWStack'] = {charName = "Gnar", spellSlot = "W", SpellType = "castcel"},
  ['GnarBigW'] = {charName = "Gnar", spellSlot = "W", SpellType = "skillshot"},
  ['GnarBigE'] = {charName = "Gnar", spellSlot = "E", SpellType = "skillshot"},
  ['GnarBigR'] = {charName = "Gnar", spellSlot = "R", SpellType = "skillshot"},
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
  ['TimeWarp'] = {charName = "Zilean", spellSlot = "E", SpellType = "castcel"},
  ['ZyraQFissure'] = {charName = "Zyra", spellSlot = "Q", SpellType = "skillshot"},
  ['ZyraGraspingRoots'] = {charName = "Zyra", spellSlot = "E", SpellType = "skillshot"},
  ['ZyraBrambleZone'] = {charName = "Zyra", spellSlot = "R", SpellType = "skillshot"},
}

local InterruptList = {
    {charName = "Nunu", spellName = "AbsoluteZero", typ = "hard"}, 
    {charName = "Katarina", spellName = "KatarinaR", typ = "hard"}, 
    {charName = "Malzahar", spellName = "AlZaharNetherGrasp", typ = "hard"}, 
    {charName = "Darius", spellName = "DariusExecute", typ = "hard"},
    {charName = "MonkeyKing", spellName = "MonkeyKingSpinToWin", typ = "hard"}, 
    {charName = "Urgot", spellName = "UrgotSwap2", typ = "hard"}, 
    {charName = "Lucian", spellName = "LucianR", typ = "hard"},
    {charName = "Xerath", spellName = "XerathLocusOfPower2", typ = "hard"}, 
    {charName = "Velkoz", spellName = "VelkozR", typ = "hard"},
    {charName = "Skarner", spellName = "SkarnerImpale", typ = "low"}, 
	{charName = "Warwick", spellName = "InfiniteDuress", typ = "low"}, 
	{charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump", typ = "low"},
    {charName = "Vi", spellName = "ViR", typ = "low"}, 
    {charName = "Shen", spellName = "ShenStandUnited", typ = "low"}, 
	{charName = "Galio", spellName = "GalioIdolOfDurand", typ = "low"}, 
	{charName = "Karthus", spellName = "FallenOne", typ = "low"}, 
	{charName = "Caitlyn", spellName = "CaitlynAceintheHole", typ = "low"},
	{charName = "FiddleSticks", spellName = "Crowstorm", typ = "low"}, 
    {charName = "MissFortune", spellName = "MissFortuneBulletTime", typ = "low"}, 
}

local GapCloserList = {
	{charName = "Aatrox", spellName = "AatroxQ"},
	{charName = "Akali", spellName = "AkaliShadowDance"},
	{charName = "Alistar", spellName = "Headbutt"},
	{charName = "Fiora", spellName = "FioraQ"},
	{charName = "Diana", spellName = "DianaTeleport"},
	{charName = "Elise", spellName = "EliseSpiderQCast"},
	{charName = "Fizz", spellName = "FizzPiercingStrike"},
	{charName = "Gragas", spellName = "GragasE"},
	{charName = "Hecarim", spellName = "HecarimUlt"},
	{charName = "JarvanIV", spellName = "JarvanIVDragonStrike"},
	{charName = "Irelia", spellName = "IreliaGatotsu"},
	{charName = "Jax", spellName = "JaxLeapStrike"},
	{charName = "Khazix", spellName = "KhazixE"},
	{charName = "Khazix", spellName = "khazixelong"},
	{charName = "LeBlanc", spellName = "LeblancSlide"},
	{charName = "LeBlanc", spellName = "LeblancSlideM"},
	{charName = "LeeSin", spellName = "BlindMonkQTwo"},
	{charName = "Leona", spellName = "LeonaZenithBlade"},
	{charName = "Malphite", spellName = "UFSlash"},
	{charName = "Pantheon", spellName = "Pantheon_LeapBash"},
	{charName = "Poppy", spellName = "PoppyHeroicCharge"},
	{charName = "Renekton", spellName = "RenektonSliceAndDice"},
	{charName = "Riven", spellName = "RivenTriCleave"},
	{charName = "Sejuani", spellName = "SejuaniArcticAssault"},
	{charName = "Tryndamere", spellName = "slashCast"},
	{charName = "Vi", spellName = "ViQ"},
	{charName = "MonkeyKing", spellName = "MonkeyKingNimbus"},
	{charName = "XinZhao", spellName = "XenZhaoSweep"},
	{charName = "Yasuo", spellName = "YasuoDashWrapper"},
}

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local Q = {name = "Glitterlance", range = 925, speed = 1600, delay = 0.25, width = 60, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Whimsy", range = 650, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Help, Pix!", range = 650, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Wild Growth", range = 900, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local killstring = {}
local IReady, ExhaustReady, HealReady, zhonyaready, recall, ECasted = false, false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, 925, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, 925, myHero, MINION_SORT_MAXHEALTH_DEC)
local AllMinions = minionManager(MINION_ALLY, 650, myHero, MINION_SORT_MAXHEALTH_DES)
local IgniteKey, ExhaustKey, HealKey, zhonyaslot = nil, nil, nil, nil
local ECastTime = 0
local Spells = {_Q,_W,_E,_R}
local Spells2 = {"Q","W","E","R"}
local QTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
local WETargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, W.range, DAMAGE_MAGIC)
local QETargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, (Q.range+E.range), DAMAGE_MAGIC)

function OnLoad()
	Menu()
	print("<b><font color=\"#FF0000\">Lulu Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Lulu Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Lulu Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if MenuLulu.comboConfig.CEnabled then
		caa()
		if ((myHero.mana/myHero.maxMana)*100) >= MenuLulu.comboConfig.manac and not recall then
			Combo()
		end
	end
	if (MenuLulu.harrasConfig.HEnabled or MenuLulu.harrasConfig.HTEnabled) then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuLulu.harrasConfig.manah and not recall then
			Harrass()
		end
	end
	if MenuLulu.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuLulu.farm.manaf and not recall then
		Farm()
	end
	if MenuLulu.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuLulu.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuLulu.prConfig.AZ and not recall then
		autozh()
	end
	if MenuLulu.prConfig.ALS then
		autolvl()
	end
	if MenuLulu.exConfig.SE and not recall then
		Escape()
	end
	if not recall then
		KillSteal()
		AutoR()
		Support()
	end
end

function Menu()
	VP = VPrediction()
	MenuLulu = scriptConfig("Lulu Master "..version, "Lulu Master "..version)
	MenuLulu:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuLulu:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuLulu.orb == 1 then
		MenuLulu:addSubMenu("[Lulu Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuLulu.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, myHero.range+65, DAMAGE_MAGIC)
	TargetSelector.name = "Lulu"
	MenuLulu:addTS(TargetSelector)
	MenuLulu:addSubMenu("[Lulu Master]: Combo Settings", "comboConfig")
	MenuLulu.comboConfig:addSubMenu("[Lulu Master]: Q Settings", "qConfig")
	MenuLulu.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.comboConfig:addSubMenu("[Lulu Master]: W Settings", "wConfig")
	MenuLulu.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.comboConfig:addSubMenu("[Lulu Master]: E Settings", "eConfig")
	MenuLulu.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.comboConfig:addSubMenu("[Lulu Master]: R Settings", "rConfig")
	MenuLulu.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
	MenuLulu.comboConfig.rConfig:addParam("HP", "Min Health %", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
	MenuLulu.comboConfig:addSubMenu("[Lulu Master]: Other Settings", "oConfig")
	MenuLulu.comboConfig.oConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.comboConfig.oConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuLulu.comboConfig.oConfig:addParam("EQ", "Extend Q Range With E On Ally/Minions", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuLulu.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuLulu:addSubMenu("[Lulu Master]: Ultimate Settings", "uConfig")
	MenuLulu.uConfig:addParam("RKU", "Use Auto R To Knock-Up Enemies", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.uConfig:addParam("RKUC", "Min. Enemy To K-U", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	for i, enemy in ipairs(GetEnemyHeroes()) do
		MenuLulu.uConfig:addParam(enemy.charName, "Use Auto K-U On: " ..enemy.charName, SCRIPT_PARAM_ONOFF, true)
	end
	MenuLulu.uConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.uConfig:addParam("RST", "Use Auto R To Save Team", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.uConfig:addParam("RSTHP", "Min. HP %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == myHero.team then
			MenuLulu.uConfig:addParam(hero.charName, "Try Save : " ..hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuLulu:addSubMenu("[Lulu Master]: Harras Settings", "harrasConfig")
	MenuLulu.harrasConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.harrasConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.harrasConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.harrasConfig:addParam("EQ", "Extend Q Range With E On Ally/Minions", SCRIPT_PARAM_ONOFF, false)
	MenuLulu.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuLulu.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuLulu.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuLulu:addSubMenu("[Lulu Master]: Support Settings", "ss")
	MenuLulu.ss:addParam("qqq", "---- Mikael's Crucible ----", SCRIPT_PARAM_INFO,"")
	MenuLulu.ss:addParam("mchp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuLulu.ss:addParam("umc", "Use Mikael's Crucible", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.ss:addParam("qqq", "---- Frost Queen's Claim ----", SCRIPT_PARAM_INFO,"")
	MenuLulu.ss:addParam("fqhp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuLulu.ss:addParam("ufq", "Use Frost Queen's Claim", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.ss:addParam("qqq", "---- Locket of the Iron Solari ----", SCRIPT_PARAM_INFO,"")
	MenuLulu.ss:addParam("ishp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuLulu.ss:addParam("uis", "Use Locket of the Iron Solari", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.ss:addParam("qqq", "---- Twin Shadows ----", SCRIPT_PARAM_INFO,"")
	MenuLulu.ss:addParam("tshp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuLulu.ss:addParam("uts", "Use Twin Shadows", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.ss:addParam("qqq", "---- Exhaust ----", SCRIPT_PARAM_INFO,"")
	MenuLulu.ss:addParam("exhp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuLulu.ss:addParam("uex", "Use Exhaust", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.ss:addParam("qqq", "---- Heal ----", SCRIPT_PARAM_INFO,"")
	MenuLulu.ss:addParam("hhp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuLulu.ss:addParam("uh", "Use Heal", SCRIPT_PARAM_ONOFF, true)
	MenuLulu:addSubMenu("[Lulu Master]: KS Settings", "ksConfig")
	MenuLulu.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.ksConfig:addParam("EKS", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu:addSubMenu("[Lulu Master]: Farm Settings", "farm")
	MenuLulu.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuLulu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.farm:addParam("EF",  "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuLulu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuLulu.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuLulu:addSubMenu("[Lulu Master]: Jungle Farm Settings", "jf")
	MenuLulu.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuLulu.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuLulu:addSubMenu("[Lulu Master]: Extra Settings", "exConfig")
	MenuLulu.exConfig:addSubMenu("Auto-Interrupt Spells", "ES")
	for i, enemy in ipairs(GetEnemyHeroes()) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				MenuLulu.exConfig.ES:addParam(champ.spellName, "Stop "..champ.charName.." "..champ.spellName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end
	MenuLulu.exConfig:addParam("UI", "Use Auto-Interrupt (W&R)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.exConfig:addSubMenu("Anti GapCloser Spells", "ES2")
	for i, enemy in ipairs(GetEnemyHeroes()) do
		for _, champ in pairs(GapCloserList) do
			if enemy.charName == champ.charName then
				MenuLulu.exConfig.ES2:addParam(champ.spellName, "GapCloser "..champ.charName.." "..champ.spellName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end
	MenuLulu.exConfig:addParam("UG", "Use Anti GapCloser (W)", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.exConfig:addParam("SE", "Small Escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuLulu:addSubMenu("[Lulu Master]: Shield Settings", "sConfig")
	MenuLulu.sConfig:addParam("UAS", "Use Auto Shield", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.sConfig:addParam("UASA", "Use Auto Shield To Ally", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.sConfig:addSubMenu("Enemy Skills", "ES")
	MenuLulu.sConfig:addSubMenu("Shield Ally Use On", "uso")
	Enemies = GetEnemyHeroes() 
    for i,enemy in pairs (Enemies) do
		for j,spell in pairs (Spells) do 
			if Shieldspells[enemy:GetSpellData(spell).name] then 
				MenuLulu.sConfig.ES:addParam(tostring(enemy:GetSpellData(spell).name),"Block "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
			end 
		end 
	end 
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == myHero.team then
			MenuLulu.sConfig.uso:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuLulu:addSubMenu("[Lulu Master]: Draw Settings", "drawConfig")
	MenuLulu.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.drawConfig:addParam("DAAR", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.drawConfig:addParam("DAARC", "Draw AA Range Color", SCRIPT_PARAM_COLOR, {255,0,200,0})
	MenuLulu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuLulu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.drawConfig:addParam("DWR", "Draw W&E Range", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.drawConfig:addParam("DWRC", "Draw W&E Range Color", SCRIPT_PARAM_COLOR, {0,255,0,255})
	MenuLulu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255,0,255,0})
	MenuLulu:addSubMenu("[Lulu Master]: Misc Settings", "prConfig")
	MenuLulu.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuLulu.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuLulu.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
	MenuLulu.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuLulu.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLulu.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuLulu.comboConfig:permaShow("CEnabled")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerexhaust") then ExhaustKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerexhaust") then ExhaustKey = SUMMONER_2
	end
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") then HealKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") then HealKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end

function Check()
	QTargetSelector:update()
	WETargetSelector:update()
	QETargetSelector:update()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, E.range) then
		Cel = SelectedTarget
		QCel = SelectedTarget
		WECel = SelectedTarget
		QECel = SelectedTarget
	else
		Cel = GetCustomTarget()
		QCel = QTargetSelector.target
		WECel = WETargetSelector.target
		QECel = QETargetSelector.target
	end
	if MenuLulu.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if MenuLulu.drawConfig.DLC then 
		_G.DrawCircle = DrawCircle2 
	else 
		_G.DrawCircle = _G.oldDrawCircle 
	end
	if os.clock()-ECastTime > 4 then
		ECasted = false
	end
end

function Combo()
	if Cel ~= nil then
		UseItems(Cel)
	end
	if MenuLulu.comboConfig.rConfig.USER then
		if ((myHero.health/myHero.maxHealth)*100) <= MenuLulu.comboConfig.rConfig.HP then
			CastR(myHero)
		end
	end
	if QCel ~= nil and MenuLulu.comboConfig.qConfig.USEQ and ValidTarget(QCel, Q.range) and not MenuLulu.comboConfig.oConfig.EQ then
		CastQ(QCel, myHero)
	end
	if WECel ~= nil then
		if MenuLulu.comboConfig.wConfig.USEW and ValidTarget(WECel, W.range) then
			CastW(WECel)
		end
		if MenuLulu.comboConfig.eConfig.USEE and ValidTarget(WECel, E.range) and not MenuLulu.comboConfig.oConfig.EQ then
			CastE(WECel)
		end
	end
	if QECel ~= nil and GetDistance(QECel) < (Q.range+E.range) and MenuLulu.comboConfig.oConfig.EQ and GetDistance(QECel) > Q.range then
		local champ = GetHero() or GetMinion()
		if champ ~= nil and GetDistance(champ, QECel) < Q.range then
			CastE(champ)
			if ECasted then
				CastQ(QECel, champ)
			end
		end
	elseif QECel ~= nil and GetDistance(QECel) < Q.range and MenuLulu.comboConfig.oConfig.EQ then
		if QCel ~= nil and MenuLulu.comboConfig.qConfig.USEQ and ValidTarget(QCel, Q.range) then
			CastQ(QCel, myHero)
		end
		if WECel ~= nil and MenuLulu.comboConfig.eConfig.USEE and ValidTarget(WECel, E.range) then
			CastE(WECel)
		end
	end
end

function Harrass()
	if QCel ~= nil and MenuLulu.harrasConfig.USEQ and ValidTarget(QCel, Q.range) and not MenuLulu.harrasConfig.EQ then
		CastQ(QCel, myHero)
	end
	if WECel ~= nil then
		if MenuLulu.harrasConfig.USEW and ValidTarget(WECel, W.range) then
			CastW(WECel)
		end
		if MenuLulu.harrasConfig.USEE and ValidTarget(WECel, E.range) and not MenuLulu.harrasConfig.EQ then
			CastE(WECel)
		end
	end
	if QECel ~= nil and GetDistance(QECel) < (Q.range+E.range) and MenuLulu.harrasConfig.EQ and GetDistance(QECel) > Q.range then
		local champ = GetHero() or GetMinion()
		if QECel ~= nil and champ ~= nil and GetDistance(champ, QECel) < Q.range then
			CastE(champ)
			if ECasted then
				CastQ(QECel, champ)
			end
		end
	elseif QECel ~= nil and GetDistance(QECel) < Q.range and MenuLulu.harrasConfig.EQ then
		if QCel ~= nil and MenuLulu.harrasConfig.USEQ and ValidTarget(QCel, Q.range) then
			CastQ(QCel, myHero)
		end
		if WECel ~= nil and MenuLulu.harrasConfig.USEE and ValidTarget(WECel, E.range) then
			CastE(WECel)
		end
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuLulu.farm.QF
	EMode =  MenuLulu.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) and Q.Ready() then
				local BestPos, BestHit = GetBestLineFarmPosition(Q.range, Q.width, EnemyMinions.objects)
				if BestPos ~= nil then
					CastSpell(_Q, BestPos.x, BestPos.z)
				end
			end
		elseif QMode == 2 then
			if minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero, 3) then
					CastQ(minion, myHero)
				end
			end
		end
		if EMode == 3 then
			if minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				CastE(minion)
			end
		elseif EMode == 2 then
			if minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				if minion.health <= getDmg("E", minion, myHero, 3) then
					CastE(minion)
				end
			end
		end
	end
end

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuLulu.jf.QJF then
			if minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) and Q.Ready() then
				local BestPos, BestHit = GetBestLineFarmPosition(Q.range, Q.width, JungleMinions.objects)
				if BestPos ~= nil then
					CastSpell(_Q, BestPos.x, BestPos.z)
				end
			end
		end
		if MenuLulu.jf.EJF then
			if minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				CastE(minion)
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuLulu.prConfig.AZMR)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuLulu.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function OnDraw()
	if MenuLulu.drawConfig.DST and MenuLulu.comboConfig.oConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuLulu.drawConfig.DQRC[2], MenuLulu.drawConfig.DQRC[3], MenuLulu.drawConfig.DQRC[4]))
		end
	end
	if MenuLulu.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy, 2000) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuLulu.drawConfig.DAAR then			
		DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range + 65, RGB(MenuLulu.drawConfig.DAARC[2], MenuLulu.drawConfig.DAARC[3], MenuLulu.drawConfig.DAARC[4]))
	end
	if MenuLulu.drawConfig.DQR and Q.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuLulu.drawConfig.DQRC[2], MenuLulu.drawConfig.DQRC[3], MenuLulu.drawConfig.DQRC[4]))
	end
	if MenuLulu.drawConfig.DWR and (W.Ready() or E.Ready()) then			
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuLulu.drawConfig.DWRC[2], MenuLulu.drawConfig.DWRC[3], MenuLulu.drawConfig.DWRC[4]))
	end
	if MenuLulu.drawConfig.DRR and R.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuLulu.drawConfig.DRRC[2], MenuLulu.drawConfig.DRRC[3], MenuLulu.drawConfig.DRRC[4]))
	end
end

function DmgCalc()
	for _, enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
			local hp = enemy.health
			local QDMG = getDmg("Q", enemy, myHero, 3)
			local EDMG = getDmg("E", enemy, myHero, 3)
			local IDMG = 50 + (20 * myHero.level)
			if hp > (QDMG+EDMG+IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif hp < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif hp < EDMG then
				killstring[enemy.networkID] = "E Kill!"
            elseif hp < (IDMG) then
                killstring[enemy.networkID] = "Ignite Kill!"
			elseif hp < (QDMG+IDMG) then
				killstring[enemy.networkID] = "Q+Ignite Kill!"
			elseif hp < (EDMG+IDMG) then
				killstring[enemy.networkID] = "E+Ignite Kill!"	
			elseif hp < (QDMG+EDMG) then
                killstring[enemy.networkID] = "Q+E Kill!"
			elseif hp < (QDMG+EDMG+IDMG) then
                killstring[enemy.networkID] = "Q+E+Ignite Kill!"
            end
        end
    end
end

function CastQ(unit, from)
	if Q.Ready() then
		if MenuLulu.prConfig.pro == 1 then
			local CastPosition, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, from)
			if HitChance >= 2 then
				if VIP_USER and MenuLulu.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MenuLulu.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, Q.range - 30, Q.speed, Q.delay, Q.width)
			if Position ~= nil then
				if VIP_USER and MenuLulu.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end	
			end
		end
	end
end

function CastW(unit)
	if W.Ready() then
		if VIP_USER and MenuLulu.prConfig.pc then
			Packet("S_CAST", {spellId = _W, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_W, unit)
		end
	end
end

function CastE(unit)
	if E.Ready() then
		if VIP_USER and MenuLulu.prConfig.pc then
			Packet("S_CAST", {spellId = _E, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_E, unit)
		end
	end
end

function CastR(unit)
	if R.Ready() then
		if VIP_USER and MenuLulu.prConfig.pc then
			Packet("S_CAST", {spellId = _R, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_R, unit)
		end
	end
end

function Support()
	if MenuLulu.ss.umc then
		mikael = GetInventorySlotItem(3222)
		mikaelready = (mikael ~= nil and (myHero:CanUseSpell(mikael) == READY))
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 750) and ((((hero.health/hero.maxHealth)*100) < MenuLulu.ss.mchp) or HaveBuff(hero)) then
					if mikaelready then
						CastSpell(mikael)
					end
				end
			end
		end
	end
	if MenuLulu.ss.ufq then
		frost = GetInventorySlotItem(3092)
		frostready = (frost ~= nil and (myHero:CanUseSpell(frost) == READY))
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 880) and ((enemy.health/enemy.maxHealth)*100) < MenuLulu.ss.fqhp then
				if frostready then
					CastSpell(frost, enemy.x, enemy.z)
				end
			end
		end
	end
	if MenuLulu.ss.uis then
		solari = GetInventorySlotItem(3190)
		solariready = (solari ~= nil and (myHero:CanUseSpell(solari) == READY))
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 700) and ((hero.health/hero.maxHealth)*100) < MenuLulu.ss.ishp then
					if solariready then
						CastSpell(solari)
					end
				end
			end
		end
	end
	if MenuLulu.ss.uts then
		twin = GetInventorySlotItem(3023)
		twinready = (twin ~= nil and (myHero:CanUseSpell(twin) == READY))
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 1000) and ((enemy.health/enemy.maxHealth)*100) < MenuLulu.ss.tshp then
				if twinready then
					CastSpell(twin)
				end
			end
		end
	end
	if MenuLulu.ss.uex then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 550) and ((enemy.health/enemy.maxHealth)*100) < MenuLulu.ss.exhp then
				ExhaustReady = (ExhaustKey ~= nil and myHero:CanUseSpell(ExhaustKey) == READY)
				if ExhaustReady then
					CastSpell(ExhaustKey, enemy)
				end
			end
		end
	end
	if MenuLulu.ss.uh then
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 700) and ((hero.health/hero.maxHealth)*100) < MenuLulu.ss.hhp then
					HealReady = (HealKey ~= nil and myHero:CanUseSpell(HealKey) == READY)
					if HealReady then
						CastSpell(HealKey, enemy)
					end
				end
			end
		end
	end
end

function HaveBuff(unit)
	for i = 1, unit.buffCount, 1 do      
        local buff = unit:getBuff(i) 
        if (buff.valid == true) and (buff.type == BUFF_STUN or buff.type == BUFF_ROOT or buff.type == BUFF_FEAR or buff.type == BUFF_TAUNT or buff.type == BUFF_SILENCE) then
            return true                     
        end                    
    end
end

function autolvl()
	if not MenuLulu.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_W,_Q,_E,_Q,_R,_W,_W,_W,_W,_R,_E,_E,_E,_E,_R,_Q,_Q}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnProcessSpell(unit, spell)
	if unit and spell then
		if unit.isMe and spell.name == "LuluE" then
			ECasted = true
			ECastTime = os.clock()
		end
	end
	if MenuLulu.exConfig.UI and W.Ready() then
		for _, x in pairs(InterruptList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuLulu.exConfig.ES[x.spellName] and ValidTarget(unit) then
					if x.typ == "hard" and R.Ready() and GetDistance(unit) < 300 then
						CastR(myHero)
					elseif x.typ ~= "hard" and W.Ready() and GetDistance(unit) < W.range then
						CastW(unit)
					end
				end
			end
		end
	end
	if MenuLulu.exConfig.UG and W.Ready() then
		for _, x in pairs(GapCloserList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuLulu.exConfig.ES2[x.spellName] and ValidTarget(unit, W.range) then
					if spell.target and spell.target.isMe then
						CastW(unit)
					elseif not spell.target then
						local endPos1 = Vector(unit.visionPos) + 300 * (Vector(spell.endPos) - Vector(unit.visionPos)):normalized()
						local endPos2 = Vector(unit.visionPos) + 100 * (Vector(spell.endPos) - Vector(unit.visionPos)):normalized()
						if (GetDistanceSqr(myHero.visionPos, unit.visionPos) > GetDistanceSqr(myHero.visionPos, endPos1) or GetDistanceSqr(myHero.visionPos, unit.visionPos) > GetDistanceSqr(myHero.visionPos, endPos2))  then
							CastW(unit)
						end
					end
				end
			end
		end
	end
	if MenuLulu.sConfig.UAS then
        if unit and unit.team ~= myHero.team and not myHero.dead and unit.type == myHero.type and spell then
		    shottype,radius,maxdistance = 0,0,0
		    if unit.type == "obj_AI_Hero" and Shieldspells[spell.name] and MenuLulu.sConfig.ES[spell.name]then
			    spelltype, casttype = getSpellType(unit, spell.name)
			    if casttype == 4 or casttype == 5 or casttype == 6 then return end
			    if (spelltype == "Q" or spelltype == "W" or spelltype == "E" or spelltype == "R") then
				    shottype = skillData[unit.charName][spelltype]["type"]
				    radius = skillData[unit.charName][spelltype]["radius"]
				    maxdistance = skillData[unit.charName][spelltype]["maxdistance"]
			    end
		    end
		    for i=1, heroManager.iCount do
				local her = heroManager:GetHero(i)
				if MenuLulu.sConfig.UASA and MenuLulu.sConfig.uso[her.charName] then
					allytarget = her
				else
					allytarget = myHero
				end
			    if allytarget.team == myHero.team and not allytarget.dead and allytarget.health > 0 then
				    hitchampion = false
				    local allyHitBox = allytarget.boundingRadius
				    if shottype == 0 then hitchampion = spell.target and spell.target.networkID == allytarget.networkID
				    elseif shottype == 1 then hitchampion = checkhitlinepass(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				    elseif shottype == 2 then hitchampion = checkhitlinepoint(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				    elseif shottype == 3 then hitchampion = checkhitaoe(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				    elseif shottype == 4 then hitchampion = checkhitcone(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				    elseif shottype == 5 then hitchampion = checkhitwall(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				    elseif shottype == 6 then hitchampion = checkhitlinepass(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox) or checkhitlinepass(unit, Vector(unit)*2-spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				    elseif shottype == 7 then hitchampion = checkhitcone(spell.endPos, unit, radius, maxdistance, allytarget, allyHitBox)
				    end
				    if hitchampion then
					    if Shieldspells[spell.name] and MenuLulu.sConfig.ES[spell.name] and GetDistance(allytarget) <= E.range then
						    CastE(allytarget)
					    end
				    end
			    end
		    end	
		end
	end
end

function AutoR()
	if MenuLulu.uConfig.RKU then
		for _, enemy in pairs(GetEnemyHeroes()) do
			local count = EnemyCount(myHero, 300)
			if MenuLulu.uConfig[enemy.charName] and count >= MenuLulu.uConfig.RKUC then
				CastR(myHero)
			end
		end
	end
	if MenuLulu.uConfig.RST then
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if MenuLulu.uConfig[hero.charName] and ((hero.health/hero.maxHealth)*100) <= MenuLulu.uConfig.RSTHP and GetDistance(hero) <= R.range then
					CastR(hero)
				end
			end
		end
	end
end

function KillSteal()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local hp = Enemy.health
		local QDMG = getDmg("Q", Enemy, myHero, 3)
		local EDMG = getDmg("E", Enemy, myHero, 3)
		local IDMG = 50 + (20 * myHero.level)
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
			if hp < QDMG and MenuLulu.ksConfig.QKS and ValidTarget(Enemy, Q.range - 30) then
				CastQ(Enemy, myHero)
			elseif hp < EDMG and MenuLulu.ksConfig.EKS and ValidTarget(Enemy, E.range) then
				CastE(Enemy)
			elseif hp < IDMG and MenuLulu.ksConfig.IKS and ValidTarget(Enemy, 600) and IReady then
				CastSpell(IgniteKey, Enemy)
			end
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

function caa()
	if MenuLulu.comboConfig.oConfig.uaa then
		SxOrb:EnableAttacks()
	elseif not MenuLulu.comboConfig.oConfig.uaa then
		SxOrb:DisableAttacks()
	end
end

function Escape()
	CastW(myHero)
	myHero:MoveTo(mousePos.x, mousePos.z)
end

function GetHero()
	for i = 1, heroManager.iCount, 1 do
		local unit = heroManager:getHero(i)
		if not unit.dead and ValidTarget(unit) and ValidTarget(unit, E.range) and unit ~= myHero then 
			return unit
		end
	end
end

function GetMinion()
	AllMinions:update()
	for i, minion in pairs(AllMinions.objects) do
		if minion ~= nil and not minion.dead and GetDistance(minion) <= E.range then
			return minion
		end
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

function GetBestLineFarmPosition(range, width, objects)
	local BestPos 
	local BestHit = 0
	for i, object in ipairs(objects) do
		local EndPos = Vector(myHero.visionPos) + range * (Vector(object) - Vector(myHero.visionPos)):normalized()
		local hit = CountObjectsOnLineSegment(myHero.visionPos, EndPos, width, objects)
		if hit > BestHit then
			BestHit = hit
			BestPos = Vector(object)
			if BestHit == #objects then
			   break
			end
		 end
	end
	return BestPos, BestHit
end

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
	local n = 0
	for i, object in ipairs(objects) do
		local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
		if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width then
			n = n + 1
		end
	end
	return n
end

function OnApplyBuff(unit, source, buff)
	if unit.isMe and buff and buff.name == "recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit.isMe and buff and buff.name == "recall" then
		recall = false
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuLulu.comboConfig.oConfig.ST then
		local dist = 0
		local Selecttarget = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				if GetDistance(enemy, mousePos) <= dist or Selecttarget == nil then
					dist = GetDistance(enemy, mousePos)
					Selecttarget = enemy
				end
			end
		end
		if Selecttarget and dist < 300 then
			if SelectedTarget and Selecttarget.charName == SelectedTarget.charName then
				SelectedTarget = nil
				if MenuLulu.comboConfig.oConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuLulu.comboConfig.oConfig.ST then 
					print("New target selected: "..Selecttarget.charName) 
				end
			end
		end
	end
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

--[[		Code	by eXtragoZ	]]
local spellsFile = LIB_PATH.."missedspells.txt"
local spellslist = {}
local textlist = ""
local spellexists = false
local spelltype = "Unknown"

function writeConfigsspells()
	local file = io.open(spellsFile, "w")
	if file then
		textlist = "return {"
		for i=1,#spellslist do
			textlist = textlist.."'"..spellslist[i].."', "
		end
		textlist = textlist.."}"
		if spellslist[1] ~=nil then
			file:write(textlist)
			file:close()
		end
	end
end
if FileExist(spellsFile) then spellslist = dofile(spellsFile) end

local Others = {"Recall","recall","OdinCaptureChannel","LanternWAlly","varusemissiledummy","khazixqevo","khazixwevo","khazixeevo","khazixrevo","braumedummyvoezreal","braumedummyvonami","braumedummyvocaitlyn","braumedummyvoriven","braumedummyvodraven","braumedummyvoashe","azirdummyspell"}
local Items = {"RegenerationPotion","FlaskOfCrystalWater","ItemCrystalFlask","ItemMiniRegenPotion","PotionOfBrilliance","PotionOfElusiveness","PotionOfGiantStrength","OracleElixirSight","OracleExtractSight","VisionWard","SightWard","sightward","ItemGhostWard","ItemMiniWard","ElixirOfRage","ElixirOfIllumination","wrigglelantern","DeathfireGrasp","HextechGunblade","shurelyascrest","IronStylus","ZhonyasHourglass","YoumusBlade","randuinsomen","RanduinsOmen","Mourning","OdinEntropicClaymore","BilgewaterCutlass","QuicksilverSash","HextechSweeper","ItemGlacialSpike","ItemMercurial","ItemWraithCollar","ItemSoTD","ItemMorellosBane","ItemPromote","ItemTiamatCleave","Muramana","ItemSeraphsEmbrace","ItemSwordOfFeastAndFamine","ItemFaithShaker","OdynsVeil","ItemHorn","ItemPoroSnack","ItemBlackfireTorch","HealthBomb","ItemDervishBlade","TrinketTotemLvl1","TrinketTotemLvl2","TrinketTotemLvl3","TrinketTotemLvl3B","TrinketSweeperLvl1","TrinketSweeperLvl2","TrinketSweeperLvl3","TrinketOrbLvl1","TrinketOrbLvl2","TrinketOrbLvl3","OdinTrinketRevive","RelicMinorSpotter","RelicSpotter","RelicGreaterLantern","RelicLantern","RelicSmallLantern","ItemFeralFlare","trinketorblvl2","trinketsweeperlvl2","trinkettotemlvl2","SpiritLantern","RelicGreaterSpotter"}
local MSpells = {"JayceStaticField","JayceToTheSkies","JayceThunderingBlow","Takedown","Pounce","Swipe","EliseSpiderQCast","EliseSpiderW","EliseSpiderEInitial","elisespidere","elisespideredescent","gnarbigq","gnarbigw","gnarbige","GnarBigQMissile"}
local PSpells = {"CaitlynHeadshotMissile","RumbleOverheatAttack","JarvanIVMartialCadenceAttack","ShenKiAttack","MasterYiDoubleStrike","sonaqattackupgrade","sonawattackupgrade","sonaeattackupgrade","NocturneUmbraBladesAttack","NautilusRavageStrikeAttack","ZiggsPassiveAttack","QuinnWEnhanced","LucianPassiveAttack","SkarnerPassiveAttack","KarthusDeathDefiedBuff","AzirTowerClick","azirtowerclick","azirtowerclickchannel"}

local QSpells = {"TrundleQ","LeonaShieldOfDaybreakAttack","XenZhaoThrust","NautilusAnchorDragMissile","RocketGrabMissile","VayneTumbleAttack","VayneTumbleUltAttack","NidaleeTakedownAttack","ShyvanaDoubleAttackHit","ShyvanaDoubleAttackHitDragon","frostarrow","FrostArrow","MonkeyKingQAttack","MaokaiTrunkLineMissile","FlashFrostSpell","xeratharcanopulsedamage","xeratharcanopulsedamageextended","xeratharcanopulsedarkiron","xeratharcanopulsediextended","SpiralBladeMissile","EzrealMysticShotMissile","EzrealMysticShotPulseMissile","jayceshockblast","BrandBlazeMissile","UdyrTigerAttack","TalonNoxianDiplomacyAttack","LuluQMissile","GarenSlash2","VolibearQAttack","dravenspinningattack","karmaheavenlywavec","ZiggsQSpell","UrgotHeatseekingHomeMissile","UrgotHeatseekingLineMissile","JavelinToss","RivenTriCleave","namiqmissile","NasusQAttack","BlindMonkQOne","ThreshQInternal","threshqinternal","QuinnQMissile","LissandraQMissile","EliseHumanQ","GarenQAttack","JinxQAttack","JinxQAttack2","yasuoq","xeratharcanopulse2","VelkozQMissile","KogMawQMis","BraumQMissile","KarthusLayWasteA1","KarthusLayWasteA2","KarthusLayWasteA3","karthuslaywastea3","karthuslaywastea2","karthuslaywastedeada1","MaokaiSapling2Boom","gnarqmissile","GnarBigQMissile","viktorqbuff"}
local WSpells = {"KogMawBioArcaneBarrageAttack","SivirWAttack","TwitchVenomCaskMissile","gravessmokegrenadeboom","mordekaisercreepingdeath","DrainChannel","jaycehypercharge","redcardpreattack","goldcardpreattack","bluecardpreattack","RenektonExecute","RenektonSuperExecute","EzrealEssenceFluxMissile","DariusNoxianTacticsONHAttack","UdyrTurtleAttack","talonrakemissileone","LuluWTwo","ObduracyAttack","KennenMegaProc","NautilusWideswingAttack","NautilusBackswingAttack","XerathLocusOfPower","yoricksummondecayed","Bushwhack","karmaspiritbondc","SejuaniBasicAttackW","AatroxWONHAttackLife","AatroxWONHAttackPower","JinxWMissile","GragasWAttack","braumwdummyspell","syndrawcast","SorakaWParticleMissile"}
local ESpells = {"KogMawVoidOozeMissile","ToxicShotAttack","LeonaZenithBladeMissile","PowerFistAttack","VayneCondemnMissile","ShyvanaFireballMissile","maokaisapling2boom","VarusEMissile","CaitlynEntrapmentMissile","jayceaccelerationgate","syndrae5","JudicatorRighteousFuryAttack","UdyrBearAttack","RumbleGrenadeMissile","Slash","hecarimrampattack","ziggse2","UrgotPlasmaGrenadeBoom","SkarnerFractureMissile","YorickSummonRavenous","BlindMonkEOne","EliseHumanE","PrimalSurge","Swipe","ViEAttack","LissandraEMissile","yasuodummyspell","XerathMageSpearMissile","RengarEFinal","RengarEFinalMAX","KarthusDefileSoundDummy2"}
local RSpells = {"Pantheon_GrandSkyfall_Fall","LuxMaliceCannonMis","infiniteduresschannel","JarvanIVCataclysmAttack","jarvanivcataclysmattack","VayneUltAttack","RumbleCarpetBombDummy","ShyvanaTransformLeap","jaycepassiverangedattack", "jaycepassivemeleeattack","jaycestancegth","MissileBarrageMissile","SprayandPrayAttack","jaxrelentlessattack","syndrarcasttime","InfernalGuardian","UdyrPhoenixAttack","FioraDanceStrike","xeratharcanebarragedi","NamiRMissile","HallucinateFull","QuinnRFinale","lissandrarenemy","SejuaniGlacialPrisonCast","yasuordummyspell","xerathlocuspulse","tempyasuormissile","PantheonRFall"}

local casttype2 = {"blindmonkqtwo","blindmonkwtwo","blindmonketwo","infernalguardianguide","KennenMegaProc","sonawattackupgrade","redcardpreattack","fizzjumptwo","fizzjumpbuffer","gragasbarrelrolltoggle","LeblancSlideM","luxlightstriketoggle","UrgotHeatseekingHomeMissile","xeratharcanopulseextended","xeratharcanopulsedamageextended","XenZhaoThrust3","ziggswtoggle","khazixwlong","khazixelong","renektondice","SejuaniNorthernWinds","shyvanafireballdragon2","shyvanaimmolatedragon","ShyvanaDoubleAttackHitDragon","talonshadowassaulttoggle","viktorchaosstormguide","zedw2","ZedR2","khazixqlong","AatroxWONHAttackLife","viktorqbuff"}
local casttype3 = {"sonaeattackupgrade","bluecardpreattack","LeblancSoulShackleM","UdyrPhoenixStance","RenektonSuperExecute"}
local casttype4 = {"FrostShot","PowerFist","DariusNoxianTacticsONH","EliseR","JaxEmpowerTwo","JaxRelentlessAssault","JayceStanceHtG","jaycestancegth","jaycehypercharge","JudicatorRighteousFury","kennenlrcancel","KogMawBioArcaneBarrage","LissandraE","MordekaiserMaceOfSpades","mordekaisercotgguide","NasusQ","Takedown","NocturneParanoia","QuinnR","RengarQ","HallucinateFull","DeathsCaressFull","SivirW","ThreshQInternal","threshqinternal","PickACard","goldcardlock","redcardlock","bluecardlock","FullAutomatic","VayneTumble","MonkeyKingDoubleAttack","YorickSpectral","ViE","VorpalSpikes","FizzSeastonePassive","GarenSlash3","HecarimRamp","leblancslidereturn","leblancslidereturnm","Obduracy","UdyrTigerStance","UdyrTurtleStance","UdyrBearStance","UrgotHeatseekingMissile","XenZhaoComboTarget","dravenspinning","dravenrdoublecast","FioraDance","LeonaShieldOfDaybreak","MaokaiDrain3","NautilusPiercingGaze","RenektonPreExecute","RivenFengShuiEngine","ShyvanaDoubleAttack","shyvanadoubleattackdragon","SyndraW","TalonNoxianDiplomacy","TalonCutthroat","talonrakemissileone","TrundleTrollSmash","VolibearQ","AatroxW","aatroxw2","AatroxWONHAttackLife","JinxQ","GarenQ","yasuoq","XerathArcanopulseChargeUp","XerathLocusOfPower2","xerathlocuspulse","velkozqsplitactivate","NetherBlade","GragasQToggle","GragasW","SionW","sionpassivespeed"}
local casttype5 = {"VarusQ","ZacE","ViQ","SionQ"}
local casttype6 = {"VelkozQMissile","KogMawQMis","RengarEFinal","RengarEFinalMAX","BraumQMissile","KarthusDefileSoundDummy2","gnarqmissile","GnarBigQMissile","SorakaWParticleMissile"}
--,"PoppyDevastatingBlow"--,"Deceive" -- ,"EliseRSpider"
function getSpellType(unit, spellName)
	spelltype = "Unknown"
	casttype = 1
	if unit ~= nil and unit.type == "AIHeroClient" then
		if spellName == nil or unit:GetSpellData(_Q).name == nil or unit:GetSpellData(_W).name == nil or unit:GetSpellData(_E).name == nil or unit:GetSpellData(_R).name == nil then
			return "Error name nil", casttype
		end
		if spellName:find("SionBasicAttackPassive") or spellName:find("zyrapassive") then
			spelltype = "P"
		elseif (spellName:find("BasicAttack") and spellName ~= "SejuaniBasicAttackW") or spellName:find("basicattack") or spellName:find("JayceRangedAttack") or spellName == "SonaQAttack" or spellName == "SonaWAttack" or spellName == "SonaEAttack" or spellName == "ObduracyAttack" or spellName == "GnarBigAttackTower" then
			spelltype = "BAttack"
		elseif spellName:find("CritAttack") or spellName:find("critattack") then
			spelltype = "CAttack"
		elseif unit:GetSpellData(_Q).name:find(spellName) then
			spelltype = "Q"
		elseif unit:GetSpellData(_W).name:find(spellName) then
			spelltype = "W"
		elseif unit:GetSpellData(_E).name:find(spellName) then
			spelltype = "E"
		elseif unit:GetSpellData(_R).name:find(spellName) then
			spelltype = "R"
		elseif spellName:find("Summoner") or spellName:find("summoner") or spellName == "teleportcancel" then
			spelltype = "Summoner"
		else
			if spelltype == "Unknown" then
				for i=1,#Others do
					if spellName:find(Others[i]) then
						spelltype = "Other"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#Items do
					if spellName:find(Items[i]) then
						spelltype = "Item"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#PSpells do
					if spellName:find(PSpells[i]) then
						spelltype = "P"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#QSpells do
					if spellName:find(QSpells[i]) then
						spelltype = "Q"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#WSpells do
					if spellName:find(WSpells[i]) then
						spelltype = "W"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#ESpells do
					if spellName:find(ESpells[i]) then
						spelltype = "E"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#RSpells do
					if spellName:find(RSpells[i]) then
						spelltype = "R"
					end
				end
			end
		end
		for i=1,#MSpells do
			if spellName == MSpells[i] then
				spelltype = spelltype.."M"
			end
		end
		local spellexists = spelltype ~= "Unknown"
		if #spellslist > 0 and not spellexists then
			for i=1,#spellslist do
				if spellName == spellslist[i] then
					spellexists = true
				end
			end
		end
		if not spellexists then
			table.insert(spellslist, spellName)
			writeConfigsspells()
			PrintChat("Skill Detector - Unknown spell: "..spellName)
		end
	end
	for i=1,#casttype2 do
		if spellName == casttype2[i] then casttype = 2 end
	end
	for i=1,#casttype3 do
		if spellName == casttype3[i] then casttype = 3 end
	end
	for i=1,#casttype4 do
		if spellName == casttype4[i] then casttype = 4 end
	end
	for i=1,#casttype5 do
		if spellName == casttype5[i] then casttype = 5 end
	end
	for i=1,#casttype6 do
		if spellName == casttype6[i] then casttype = 6 end
	end

	return spelltype, casttype
end

-----SCRIPT STATUS------------
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("UHKIMKLHKGP") 
