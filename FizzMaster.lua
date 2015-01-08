--[[

	Script Name: FIZZ MASTER 
    	Author: kokosik1221
	Last Version: 1.33
	08.01.2015

]]--


if myHero.charName ~= "Fizz" then return end

_G.AUTOUPDATE = true
_G.USESKINHACK = false


local version = "1.33"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/FizzMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>FizzMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/FizzMaster.version")
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

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local DodgeSpells = {
  ['AkaliShadowDance'] = {charName = "Akali", spellSlot = "R", SpellType = "castcel"},
  ['BrandWildfire'] = {charName = "Brand", spellSlot = "R", SpellType = "castcel"},
  ['AceintheHole'] = {charName = "Caitlyn", spellSlot = "R", SpellType = "castcel"},
  ['Feast'] = {charName = "ChoGath", spellSlot = "R", SpellType = "castcel"},
  ['DariusExecute'] = {charName = "Darius", spellSlot = "R", SpellType = "castcel"},
  ['DianaTeleport'] = {charName = "Diana", spellSlot = "R", SpellType = "castcel"},
  ['FioraDance'] = {charName = "Fiora", spellSlot = "R", SpellType = "castcel"},
  ['GarenR'] = {charName = "Garen", spellSlot = "R", SpellType = "castcel"},
  ['BlindMonkRKick'] = {charName = "LeeSin", spellSlot = "R", SpellType = "castcel"},
  ['LissandraR'] = {charName = "Lissandra", spellSlot = "R", SpellType = "castcel"},
  ['AlZaharNetherGrasp'] = {charName = "Malzahar", spellSlot = "R", SpellType = "castcel"},
  ['MordekaiserChildrenOfTheGrave'] = {charName = "Mordekaiser", spellSlot = "R", SpellType = "castcel"},
  ['NautilusGandLine'] = {charName = "Nautilus", spellSlot = "R", SpellType = "castcel"},
  ['NocturneParanoia'] = {charName = "Nocturne", spellSlot = "R", SpellType = "castcel"},
  ['SkarnerImpale'] = {charName = "Skarner", spellSlot = "R", SpellType = "castcel"},
  ['SyndraR'] = {charName = "Syndra", spellSlot = "R", SpellType = "castcel"},
  ['BusterShot'] = {charName = "Tristana", spellSlot = "R", SpellType = "castcel"},
  ['TrundlePain'] = {charName = "Trundle", spellSlot = "R", SpellType = "castcel"},
  ['UrgotSwap2'] = {charName = "Urgot", spellSlot = "R", SpellType = "castcel"},
  ['VeigarPrimordialBurst'] = {charName = "Veigar", spellSlot = "R", SpellType = "castcel"},
  ['ViR'] = {charName = "Vi", spellSlot = "R", SpellType = "castcel"},
  ['InfiniteDuress'] = {charName = "Warwick", spellSlot = "R", SpellType = "castcel"},
  ['zedult'] = {charName = "Zed", spellSlot = "R", SpellType = "castcel"},
  ['AkaliMota'] = {charName = "Akali", spellSlot = "Q", SpellType = "castcel"},
  ['Pulverize'] = {charName = "Alistar", spellSlot = "Q", SpellType = "castcel"},
  ['Headbutt'] = {charName = "Alistar", spellSlot = "W", SpellType = "castcel"},
  ['Frostbite'] = {charName = "Anivia", spellSlot = "E", SpellType = "castcel"},
  ['Disintegrate'] = {charName = "Annie", spellSlot = "Q", SpellType = "castcel"},
  ['Incinerate'] = {charName = "Annie", spellSlot = "W", SpellType = "castcel"},
  ['BrandConflagration'] = {charName = "Brand", spellSlot = "E", SpellType = "castcel"},
  ['CassiopeiaTwinFang'] = {charName = "Cassiopeia", spellSlot = "E", SpellType = "castcel"},
  ['VorpalSpikes'] = {charName = "Chogath", spellSlot = "E", SpellType = "castcel"},
  ['Terrify'] = {charName = "FiddleSticks", spellSlot = "Q", SpellType = "castcel"},
  ['Drain'] = {charName = "FiddleSticks", spellSlot = "W", SpellType = "castcel"},
  ['FiddlesticksDarkWind'] = {charName = "FiddleSticks", spellSlot = "E", SpellType = "castcel"},
  ['FioraQ'] = {charName = "Fiora", spellSlot = "Q", SpellType = "castcel"},
  ['FizzPiercingStrike'] = {charName = "Fizz", spellSlot = "Q", SpellType = "castcel"},
  ['Parley'] = {charName = "Gangplank", spellSlot = "Q", SpellType = "castcel"},
  ['IreliaGatotsu'] = {charName = "Irelia", spellSlot = "Q", SpellType = "castcel"},
  ['IreliaEquilibriumStrike'] = {charName = "Irelia", spellSlot = "E", SpellType = "castcel"},
  ['SowTheWind'] = {charName = "Janna", spellSlot = "W", SpellType = "castcel"},
  ['JaxLeapStrike'] = {charName = "Jax", spellSlot = "Q", SpellType = "castcel"},
  ['JayceToTheSkies'] = {charName = "Jayce", spellSlot = "Q", SpellType = "castcel"},
  ['JayceThunderingBlow'] = {charName = "Jayce", spellSlot = "E", SpellType = "castcel"},
  ['KarmaSpiritBind'] = {charName = "Karma", spellSlot = "W", SpellType = "castcel"},
  ['NullLance'] = {charName = "Kassadin", spellSlot = "Q", SpellType = "castcel"},
  ['KatarinaQ'] = {charName = "Katarina", spellSlot = "Q", SpellType = "castcel"},
  ['JudicatorReckoning'] = {charName = "Kayle", spellSlot = "Q", SpellType = "castcel"},
  ['KennenShurikenHurlMissile1'] = {charName = "Kennen", spellSlot = "Q", SpellType = "castcel"},
  ['LeblancChaosOrb'] = {charName = "Leblanc", spellSlot = "Q", SpellType = "castcel"},
  ['LucianQ']= {charName = "Lucian", spellSlot = "Q", SpellType = "castcel"},
  ['LuluW'] = {charName = "Lulu", spellSlot = "W", SpellType = "castcel"},
  ['LuluE'] = {charName = "Lulu", spellSlot = "E", SpellType = "castcel"},
  ['SeismicShard'] = {charName = "Malphite", spellSlot = "Q", SpellType = "castcel"},
  ['AlZaharMaleficVisions'] = {charName = "Malzahar", spellSlot = "E", SpellType = "castcel"},
  ['MaokaiUnstableGrowth'] = {charName = "Maokai", spellSlot = "W", SpellType = "castcel"},
  ['AlphaStrike'] = {charName = "MasterYi", spellSlot = "Q", SpellType = "castcel"},
  ['MissFortuneRicochetShot'] = {charName = "MissFortune", spellSlot = "Q", SpellType = "castcel"},
  ['NamiW'] = {charName = "Nami", spellSlot = "W", SpellType = "castcel"},
  ['NasusW'] = {charName = "Nasus", spellSlot = "W", SpellType = "castcel"},
  ['NocturneUnspeakableHorror'] = {charName = "Nocturne", spellSlot = "E", SpellType = "castcel"},
  ['IceBlast'] = {charName = "Nunu", spellSlot = "E", SpellType = "castcel"},
  ['OlafRecklessStrike'] = {charName = "Olaf", spellSlot = "E", SpellType = "castcel"},
  ['Pantheon_Throw'] = {charName = "Pantheon", spellSlot = "Q", SpellType = "castcel"},
  ['Pantheon_LeapBash'] = {charName = "Pantheon", spellSlot = "W", SpellType = "castcel"},
  ['PoppyHeroicCharge'] = {charName = "Poppy", spellSlot = "E", SpellType = "castcel"},
  ['QuinnE'] = {charName = "Quinn", spellSlot = "E", SpellType = "castcel"},
  ['PuncturingTaunt'] = {charName = "Rammus", spellSlot = "E", SpellType = "castcel"},
  ['Overload'] = {charName = "Ryze", spellSlot = "Q", SpellType = "castcel"},
  ['RunePrison'] = {charName = "Ryze", spellSlot = "W", SpellType = "castcel"},
  ['SpellFlux'] = {charName = "Ryze", spellSlot = "E", SpellType = "castcel"},
  ['TwoShivPoisen'] = {charName = "Shaco", spellSlot = "E", SpellType = "castcel"},
  ['ShenVorpalStar'] = {charName = "Shen", spellSlot = "Q", SpellType = "castcel"},
  ['Fling'] = {charName = "Singed", spellSlot = "E", SpellType = "castcel"},
  ['CrypticGaze'] = {charName = "Sion", spellSlot = "Q", SpellType = "castcel"},
  ['SwainDecrepify'] = {charName = "Swain", spellSlot = "Q", SpellType = "castcel"},
  ['SwainTorment'] = {charName = "Swain", spellSlot = "E", SpellType = "castcel"},
  ['TalonCutthroat'] = {charName = "Talon", spellSlot = "E", SpellType = "castcel"},
  ['Dazzle'] = {charName = "Taric", spellSlot = "E", SpellType = "castcel"},
  ['BlindingDart'] = {charName = "Teemo", spellSlot = "Q", SpellType = "castcel"},
  ['DetonatingShot'] = {charName = "Tristana", spellSlot = "E", SpellType = "castcel"},
  ['TrundleTrollSmash'] = {charName = "Trundle", spellSlot = "Q", SpellType = "castcel"},
  ['VayneCondemm'] = {charName = "Vayne", spellSlot = "E", SpellType = "castcel"},
  ['VeigarBalefulStrike'] = {charName = "Veigar", spellSlot = "Q", SpellType = "castcel"},
  ['VladimirTransfusion'] = {charName = "Vladimir", spellSlot = "Q", SpellType = "castcel"},
  ['VolibearW'] = {charName = "Volibear", spellSlot = "W", SpellType = "castcel"},
  ['HungeringStrike'] = {charName = "Warwick", spellSlot = "Q", SpellType = "castcel"},
  ['MonkeyKingNimbus'] = {charName = "MonkeyKing", spellSlot = "E", SpellType = "castcel"},
  ['XenZhaoSweep'] = {charName = "Xin Zhao", spellSlot = "E", SpellType = "castcel"},
  ['YasuoDashWrapper'] = {charName = "Yasuo", spellSlot = "E", SpellType = "castcel"},
  ['YorickRavenous'] = {charName = "Yorick", spellSlot = "E", SpellType = "castcel"},
  ['TimeBomb'] = {charName = "Zilean", spellSlot = "Q", SpellType = "castcel"},
  ['TimeWarp'] = {charName = "Zilean", spellSlot = "E", SpellType = "castcel"},
  ['InfernalGuardian'] = {charName = "Annie", spellSlot = "R", SpellType = "skillshot", range = 600},
  ['KatarinaR'] = {charName = "Katarina", spellSlot = "R", SpellType = "skillshot", range = 600},
  ['CurseoftheSadMumm'] = {charName = "Amumu", spellSlot = "R", SpellType = "skillshot", range = 550},
  ['EnchantedCrystalArrow'] = {charName = "Ashe", spellSlot = "R", SpellType = "skillshot", range = 20000},
  ['FizzMarinerDoom'] = {charName = "Fizz", spellSlot = "R", SpellType = "skillshot", range = 1300},
  ['JinxRWrapper'] = {charName = "Jinx", spellSlot = "R", SpellType = "skillshot", range = 20000},
  ['UFSlash'] = {charName = "Malphite", spellSlot = "R", SpellType = "skillshot", range = 1000},
  ['OrianaDetonateCommand'] = {charName = "Orianna", spellSlot = "R", SpellType = "skillshot", range = 900},
  ['SonaCrescendo'] = {charName = "Sona", spellSlot = "R", SpellType = "skillshot", range = 1000},
  ['YasuoRKnockUpComboW'] = {charName = "Yasuo", spellSlot = "R", SpellType = "skillshot", range = 800},
  ['LeonaSolarFlare'] = {charName = "Leona", spellSlot = "R", SpellType = "skillshot", range = 600},
  ['VarusR'] = {charName = "Varus", spellSlot = "R", SpellType = "skillshot", range = 1075},
  ['VelkozR'] = {charName = "Velkoz", spellSlot = "R", SpellType = "skillshot", range = 1550},
  ['BraumR'] = {charName = "Braum", spellSlot = "R", SpellType = "skillshot", range = 1250},
  ['CassiopeiaPetrifyingGaze'] = {charName = "Cassiopeia", spellSlot = "R", SpellType = "skillshot", range = 825},
  ['EvelynnR'] = {charName = "Evelynn", spellSlot = "R", SpellType = "skillshot", range = 650},
  ['EzrealTruehotBarrage'] = {charName = "Ezreal", spellSlot = "R", SpellType = "skillshot", range = 20000},
  ['GragasExplosiveCask'] = {charName = "Gragas", spellSlot = "R", SpellType = "skillshot", range = 1150},
  ['RiftWalk'] = {charName = "Kassadin", spellSlot = "R", SpellType = "skillshot", range = 700},
  ['LuxMaliceCannon'] = {charName = "Lux", spellSlot = "R", SpellType = "skillshot", range = 3330},
 }
 
function Vars()
	Q = {name = "Urchin Strike", range = 550}
	W = {name = "Seastone Trident"}
	E = {name = "Playful", range = 400, speed = 1200, delay = 0.25, width = 330}
	E2 = {name = "Trickster", range = 400, speed = 1200, delay = 0.25, width = 270}
	R = {name = "Chum the Waters", range = 1175, speed = 1200, delay = 0.5, width = 80}
	killstring = {}
	QReady, WReady, EReady, RReady, IReady, zhonyaready, sac, mma = false, false, false, false, false, false, false, false
	abilitylvl, lastskin, aarange = 0, 0, 175
	EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	IgniteKey, zhonyaslot = nil, nil
	Spells = {_Q,_W,_E,_R}
	Spells2 = {"Q","W","E","R"}
	print("<b><font color=\"#6699FF\">Fizz Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
end

function OnLoad()
	Vars()
	Menu()
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Fizz Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
		mma = true
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Fizz Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
		sac = true
	end
end

function OnTick()
	Check()
	if Cel ~= nil and MenuFizz.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.comboConfig.manac then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuFizz.harrasConfig.HEnabled or MenuFizz.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.harrasConfig.manah then
		Harrass()
	end
	if MenuFizz.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.farm.manaf then
		Farm()
	end
	if MenuFizz.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.jf.manajf then
		JungleFarmm()
	end
	if MenuFizz.prConfig.AZ then
		autozh()
	end
	if MenuFizz.prConfig.ALS then
		autolvl()
	end
	if MenuFizz.exConfig.ESCAPE then
		Escape()
	end
	if MenuFizz.comboConfig.FU then
		if ValidTarget(Cel, R.range) and not Cel.dead then
			CastR(Cel)
		end
	end
	KillSteall()
end

function Menu()
	VP = VPrediction()
	MenuFizz = scriptConfig("Fizz Master "..version, "Fizz Master "..version)
	MenuFizz:addSubMenu("Orbwalking", "Orbwalking")
	SxOrb:LoadToMenu(MenuFizz.Orbwalking)
	MenuFizz:addSubMenu("Target selector", "STS")
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Fizz"
	MenuFizz.STS:addTS(TargetSelector)
	MenuFizz:addSubMenu("[Fizz Master]: Combo Settings", "comboConfig")
	MenuFizz.comboConfig:addParam("USEQ", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("USEW", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("USEE", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("USER", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("Kilable", "Only Use If Target Is Killable", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("FU", "Cast Ult To Target", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.comboConfig:addParam("CT", "Combo Type", SCRIPT_PARAM_LIST, 1, { "Q>R>W>E", "R>Q>W>E"})
	MenuFizz.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuFizz.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuFizz:addSubMenu("[Fizz Master]: Harras Settings", "harrasConfig")
	MenuFizz.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 2, {"|Q|", "|W|Q|", "|W|Q|E|"}) 
	MenuFizz.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuFizz.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuFizz.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuFizz:addSubMenu("[Fizz Master]: KS Settings", "ksConfig")
	MenuFizz.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.ksConfig:addParam("WKS", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.ksConfig:addParam("RKS", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz:addSubMenu("[Fizz Master]: Farm Settings", "farm")
	MenuFizz.farm:addParam("QF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuFizz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.farm:addParam("WF",  "Use " .. W.name .. "(W)", SCRIPT_PARAM_LIST, 2, { "No", "LaneClear"})
	MenuFizz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.farm:addParam("EF",  "Use " .. E.name .. "(E)", SCRIPT_PARAM_LIST, 2, { "No", "LaneClear"})
	MenuFizz.farm:addParam("EF2", "Use " .. E2.name .. "(E)", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuFizz.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuFizz:addSubMenu("[Fizz Master]: Jungle Farm Settings", "jf")
	MenuFizz.jf:addParam("QJF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.jf:addParam("WJF", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.jf:addParam("EJF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.jf:addParam("EJF2", "Use " .. E2.name .. "(E)", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	MenuFizz.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuFizz:addSubMenu("[Fizz Master]: Extra Settings", "exConfig")
	MenuFizz.exConfig:addSubMenu("Dodge Skills", "ES")
	Enemies = GetEnemyHeroes() 
    for i,enemy in pairs (Enemies) do
		for j,spell in pairs (Spells) do 
			if DodgeSpells[enemy:GetSpellData(spell).name] then 
				MenuFizz.exConfig.ES:addParam(tostring(enemy:GetSpellData(spell).name),"Dodge "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
			end 
		end 
	end 
	MenuFizz.exConfig:addParam("AE", "Dodge Spells With " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.exConfig:addParam("ESCAPE", "Small Escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuFizz.exConfig:addParam("EUE", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.exConfig:addParam("EUQ", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuFizz:addSubMenu("[Fizz Master]: Draw Settings", "drawConfig")
	MenuFizz.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.drawConfig:addParam("DAAR", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DAARC", "Draw AA Range Color", SCRIPT_PARAM_COLOR, {255,0,200,0})
	MenuFizz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuFizz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuFizz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
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
	MenuFizz.comboConfig:permaShow("CEnabled")
	MenuFizz.harrasConfig:permaShow("HEnabled")
	MenuFizz.harrasConfig:permaShow("HTEnabled")
	MenuFizz.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
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
	if MenuFizz.comboConfig.uaa then
		SxOrb:EnableAttacks()
	elseif not MenuFizz.comboConfig.uaa then
		SxOrb:DisableAttacks()
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

function Check()
	if RReady and MenuFizz.comboConfig.CT == 2 then
		TargetSelector.range = R.range
	else
		TargetSelector.range = Q.range
	end
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if sac or mma then
		SxOrb.SxOrbMenu.General.Enabled = false
	end
	SxOrb:ForceTarget(Cel)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if MenuFizz.prConfig.skin and VIP_USER and _G.USESKINHACK then
		if MenuFizz.prConfig.skin1 ~= lastSkin then
			GenModelPacket("Fizz", MenuFizz.prConfig.skin1)
			lastSkin = MenuFizz.prConfig.skin1
		end
	end
	if MenuFizz.drawConfig.DLC then 
		_G.DrawCircle = DrawCircle2 
	else 
		_G.DrawCircle = _G.oldDrawCircle 
	end
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
		if ValidTarget(Cel, Q.range) and not Cel.dead then
			CastQ(Cel)
		end
	end
	if MenuFizz.comboConfig.USER then
		if ValidTarget(Cel, R.range) and not Cel.dead then
			if MenuFizz.comboConfig.Kilable then
				local RDMG = getDmg("R", Cel, myHero, 1)
				if Cel.health < RDMG then
					CastR(Cel)
				end
			elseif not MenuFizz.comboConfig.Kilable then
				CastR(Cel)
			end
		end
	end
	if MenuFizz.comboConfig.USEW then
		if ValidTarget(Cel, aarange) and not Cel.dead then
			CastW()
		end
	end
	if MenuFizz.comboConfig.USEE then
		if ValidTarget(Cel, E.range + 50) and not Cel.dead then
			CastE(Cel)
		end
		if GetDistance(Cel, myHero) > 330 and not Cel.dead then
			CastE2(Cel)
		end
	end
end

function comboRQWE()
	if MenuFizz.comboConfig.USER then
		if ValidTarget(Cel, R.range) and not Cel.dead then
			if MenuFizz.comboConfig.Kilable then
				local RDMG = getDmg("R", Cel, myHero, 1)
				if Cel.health < RDMG then
					CastR(Cel)
				end
			elseif not MenuFizz.comboConfig.Kilable then
				CastR(Cel)
			end
		end
	end
	if MenuFizz.comboConfig.USEQ then
		if ValidTarget(Cel, Q.range) and not Cel.dead then
			CastQ(Cel)
		end
	end
	if MenuFizz.comboConfig.USEW then
		if ValidTarget(Cel, aarange) and not Cel.dead then
			CastW()
		end
	end
	if MenuFizz.comboConfig.USEE then
		if ValidTarget(Cel, E.range + 50) and not Cel.dead then
			CastE(Cel)
		end
		if GetDistance(Cel, myHero) > 330 and not Cel.dead then
			CastE2(Cel)
		end
	end
end

function Harrass()
	QMana = myHero:GetSpellData(_Q).mana
    WMana = myHero:GetSpellData(_W).mana
    EMana = myHero:GetSpellData(_E).mana
	if MenuFizz.harrasConfig.HM == 1 then
		if ValidTarget(Cel, Q.range) and myHero.mana > QMana then
			CastQ(Cel)
		end
	end
	if MenuFizz.harrasConfig.HM == 2 then
		if WReady and QReady and ValidTarget(Cel, Q.range) and myHero.mana > (WMana + QMana) then
			CastW()
			CastQ(Cel)
		end
	end
	if MenuFizz.harrasConfig.HM == 3 then
		if WReady and QReady and ValidTarget(Cel, Q.range) and myHero.mana > (WMana + QMana + EMana) then
			CastW()
			CastQ(Cel)
		end
		if EReady then
			CastSpell(_E, mousePos.x, mousePos.z)
		end
	end
	if ValidTarget(Cel, aarange) then
		myHero:Attack(Cel)
	end
end

function Farm()
	local myE = myHero:GetSpellData(_E)
	EnemyMinions:update()
	QMode =  MenuFizz.farm.QF
	WMode =  MenuFizz.farm.WF
	EMode =  MenuFizz.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastSpell(_Q, minion)
			end
		elseif QMode == 2 then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					CastSpell(_Q, minion)
				end
			end
		end
		if WMode == 2 then
			if WReady and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastW()
			end
		end
		if EMode == 2 then
			if EReady and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				local Pos, Hit = BestEFarmPos(E.range, E.width, EnemyMinions.objects)
				if Pos ~= nil then
					if myE.name == "FizzJump" then
						CastSpell(_E, Pos.x, Pos.z)
					end
					if MenuFizz.farm.EF2 then
						if myE.name == "fizzjumptwo" then
							CastSpell(_E, Pos.x, Pos.z)
						end
					end
				end
			end
		end
	end
end

function BestEFarmPos(range, radius, objects)
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

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function JungleFarmm()
	JungleMinions:update()
	local myE = myHero:GetSpellData(_E)
	for i, minion in pairs(JungleMinions.objects) do
		if MenuFizz.jf.QJF then
			if minion ~= nil and not minion.dead and GetDistance(minion) <= Q.range then
				CastQ(minion)
			end
		end
		if MenuFizz.jf.WJF then
			if minion ~= nil and not minion.dead and GetDistance(minion) <= aarange then
				CastW()
			end
		end
		if MenuFizz.jf.EJF then
			if EReady and minion ~= nil and not minion.dead and GetDistance(minion) <= E.range then
				local Pos, Hit = BestEFarmPos(E.range, E.width, EnemyMinions.objects)
				if Pos ~= nil then
					if myE.name == "FizzJump" then
						CastSpell(_E, Pos.x, Pos.z)
					end
					if MenuFizz.farm.EF2 then
						if myE.name == "fizzjumptwo" then
							CastSpell(_E, Pos.x, Pos.z)
						end
					end
				end
			end
		end
		myHero:Attack(minion)
	end
end

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

function OnDraw()
	if MenuFizz.drawConfig.DST and MenuFizz.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuFizz.drawConfig.DQRC[2], MenuFizz.drawConfig.DQRC[3], MenuFizz.drawConfig.DQRC[4]))
		end
	end
	if MenuFizz.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy, 2000) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuFizz.drawConfig.DAAR then			
		DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range + 65, RGB(MenuFizz.drawConfig.DAARC[2], MenuFizz.drawConfig.DAARC[3], MenuFizz.drawConfig.DAARC[4]))
	end
	if MenuFizz.drawConfig.DQR and QReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuFizz.drawConfig.DQRC[2], MenuFizz.drawConfig.DQRC[3], MenuFizz.drawConfig.DQRC[4]))
	end
	if MenuFizz.drawConfig.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuFizz.drawConfig.DERC[2], MenuFizz.drawConfig.DERC[3], MenuFizz.drawConfig.DERC[4]))
	end
	if MenuFizz.drawConfig.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuFizz.drawConfig.DRRC[2], MenuFizz.drawConfig.DRRC[3], MenuFizz.drawConfig.DRRC[4]))
	end
end

function KillSteall()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local hp = Enemy.health
		local QDMG = getDmg("Q", Enemy, myHero, 1)
		local WDMG = getDmg("W", Enemy, myHero, 3)
		local EDMG = getDmg("E", Enemy, myHero, 1)
		local RDMG = getDmg("R", Enemy, myHero, 1)
		local IDMG = 50 + (20 * myHero.level)
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if hp < QDMG and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.QKS then
				CastQ(Enemy)
			elseif hp < WDMG and ValidTarget(Enemy, aarange) and MenuFizz.ksConfig.WKS then
				CastW()
				myHero:Attack(Enemy)
			elseif hp < EDMG and ValidTarget(Enemy, E.range + 50) and MenuFizz.ksConfig.EKS then
				if EReady and ValidTarget(Enemy, E.range + 50) and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					CastE(Enemy)
				end
				if GetDistance(Enemy, myHero) > 330 and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					CastE2(Enemy)
				end
			elseif hp < RDMG and ValidTarget(Enemy, R.range) and MenuFizz.ksConfig.RKS then	
				CastR(Enemy)
			elseif hp < (QDMG+WDMG) and QReady and WReady and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.QKS and MenuFizz.ksConfig.WKS then
				CastW()
				CastQ(Enemy)
			elseif hp < (QDMG+EDMG) and QReady and EReady and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.QKS and MenuFizz.ksConfig.EKS then
				CastQ(Enemy)
				if EReady and ValidTarget(Enemy, E.range + 50) and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					CastE(Enemy)
				end
				if GetDistance(Enemy, myHero) > 330 and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					CastE2(Enemy)
				end			
			elseif hp < (QDMG+RDMG) and QReady and RReady and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.QKS and MenuFizz.ksConfig.RKS then
				CastR(Enemy)
				CastQ(Enemy)
			elseif hp < (RDMG+WDMG) and WReady and RReady and ValidTarget(Enemy, aarange) and MenuFizz.ksConfig.RKS and MenuFizz.ksConfig.WKS then
				CastR(Enemy)
				CastW()
				myHero:Attack(Enemy)
			elseif hp < (QDMG+WDMG+RDMG) and QReady and WReady and RReady and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.RKS and MenuFizz.ksConfig.QKS and MenuFizz.ksConfig.WKS then
				CastR(Enemy)
				CastW()
				CastQ(Enemy)
			end
			if IReady and hp < IDMG and MenuFizz.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end
	
function DmgCalc()
	for _, enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
			local hp = enemy.health
			local QDMG = getDmg("Q", enemy, myHero, 1)
			local WDMG = getDmg("W", enemy, myHero, 3)
			local EDMG = getDmg("E", enemy, myHero, 1)
			local RDMG = getDmg("R", enemy, myHero, 1)
			if hp > (QDMG+WDMG+EDMG+RDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif hp < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif hp < WDMG then
				killstring[enemy.networkID] = "W Kill!"
			elseif hp < EDMG then
				killstring[enemy.networkID] = "E Kill!"
            elseif hp < RDMG then
				killstring[enemy.networkID] = "R Kill!"
            elseif hp < (QDMG+WDMG) then
                killstring[enemy.networkID] = "Q+W Kill!"
			elseif hp < (QDMG+EDMG) then
                killstring[enemy.networkID] = "Q+E Kill!"
			elseif hp < (QDMG+RDMG) then
                killstring[enemy.networkID] = "Q+R Kill!"
			elseif hp < (WDMG+EDMG) then
                killstring[enemy.networkID] = "E+W Kill!"
			elseif hp < (WDMG+RDMG) then
                killstring[enemy.networkID] = "R+W Kill!"
			elseif hp < (QDMG+WDMG+EDMG+RDMG) then
                killstring[enemy.networkID] = "Q+W+E+R Kill!"
            end
        end
    end
end

function CastQ(unit)
	if QReady then
		if VIP_USER and MenuFizz.prConfig.pc then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_Q, unit)
		end
	end
end

function CastW()
	if WReady then
		if VIP_USER and MenuFizz.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if EReady then
		local myE = myHero:GetSpellData(_E)
		if myE.name == "FizzJump" then
			if MenuFizz.prConfig.pro == 1 then
				local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, E.delay, E.width, E.range, E.speed, myHero, false)
				if HitChance >= 0 then
					if VIP_USER and MenuFizz.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
					else
						CastSpell(_E, CastPosition.x, CastPosition.z)
					end
				end
			end
			if MenuFizz.prConfig.pro == 2 and VIP_USER and prodstatus then
				local Position, info = Prodiction.GetPrediction(unit, E.range, E.speed, E.delay, E.width)
				if Position ~= nil then
					if VIP_USER and MenuFizz.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
					else
						CastSpell(_E, Position.x, Position.z)
					end	
				end
			end
		end
	end
end

function CastE2(unit)
	if EReady then
		local myE = myHero:GetSpellData(_E)
		if myE.name == "fizzjumptwo" then
			if MenuFizz.prConfig.pro == 1 then
				local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, E2.delay, E2.width, E2.range, E2.speed, myHero, false)
				if HitChance >= 0 then
					if VIP_USER and MenuFizz.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
					else
						CastSpell(_E, CastPosition.x, CastPosition.z)
					end
				end
			end
			if MenuFizz.prConfig.pro == 2 and VIP_USER and prodstatus then
				local Position, info = Prodiction.GetPrediction(unit, E2.range, E2.speed, E2.delay, E2.width)
				if Position ~= nil then
					if VIP_USER and MenuFizz.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
					else
						CastSpell(_E, Position.x, Position.z)
					end	
				end
			end
		end
	end
end

function CastR(unit)
	if RReady then
		if MenuFizz.prConfig.pro == 1 then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, R.delay, R.width, R.range - 100, R.speed, myHero, false)
			if HitChance >= MenuFizz.prConfig.vphit - 1 then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MenuFizz.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetLineAOEPrediction(unit, R.range, R.speed, R.delay, R.width)
			if Position ~= nil then
				if VIP_USER and MenuFizz.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end	
			end
		end
	end
end
	
function OnProcessSpell(unit, spell)
	if MenuFizz.exConfig.AE then
		if unit and unit.team ~= myHero.team and not myHero.dead and unit.type == myHero.type and spell then
		    shottype,radius,maxdistance = 0,0,0
		    if unit.type == "obj_AI_Hero" and DodgeSpells[spell.name] and MenuMorg.exConfig.ES[spell.name]then
			    spelltype, casttype = getSpellType(unit, spell.name)
			    if casttype == 4 or casttype == 5 or casttype == 6 then return end
			    if (spelltype == "Q" or spelltype == "W" or spelltype == "E" or spelltype == "R") then
				    shottype = skillData[unit.charName][spelltype]["type"]
				    radius = skillData[unit.charName][spelltype]["radius"]
				    maxdistance = skillData[unit.charName][spelltype]["maxdistance"]
			    end
		    end
			allytarget = myHero
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
					if EReady and DodgeSpells[spell.name] and MenuFizz.exConfig.ES[spell.name] then
						CastSpell(_E, mousePos.x, mousePos.z)
				    end
			    end
		    end	
		end
	end
end

function Escape()
	if MenuFizz.exConfig.EUE and EReady then
		CastSpell(_E, mousePos.x, mousePos.z)
	end
	if MenuFizz.exConfig.EUQ and QReady then
		EnemyMinions:update()
		for i, minion in pairs(EnemyMinions.objects) do
			if ValidTarget(minion, Q.range) and minion ~= nil then
				if GetDistance(minion, mousePos) <= Q.range then
					CastQ(minion)
				end
			end
		end
	end
	myHero:MoveTo(mousePos.x, mousePos.z)
end

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

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuFizz.comboConfig.ST then
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
				if MenuFizz.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuFizz.comboConfig.ST then 
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
