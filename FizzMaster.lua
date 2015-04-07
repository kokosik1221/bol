--[[

	Script Name: FIZZ MASTER 
    	Author: kokosik1221
	Last Version: 1.64
	07.04.2015
	
]]--


if myHero.charName ~= "Fizz" then return end

local autoupdate = true
local version = 1.64
 
class "_ScriptUpdate"
function _ScriptUpdate:__init(LocalVersion, UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '3' or '4')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '3' or '4')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    --AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end
function _ScriptUpdate:OnDraw()
    DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(255,255,255,255))
end
function _ScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end
function _ScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
function _ScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        local recv,sent,time = self.Socket:getstats()
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end
    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</size>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</s'..'ize>')-1)) + self.File:len()
        end
        self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*self.File:len(),2)..'%)'
    end
    if not (self.Receive or (#self.Snipped > 0)) and self.RecvStarted and self.Size and math.round(100/self.Size*self.File:len(),2) > 95 then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = tonumber(self.File:sub(ContentStart + 1,ContentEnd-1))
            if self.OnlineVersion~=nil and self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end
function _ScriptUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        local recv,sent,time = self.Socket:getstats()
        self.DownloadStatus = 'Downloading Script (0%)'
    end
    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1)) + self.File:len()
        end
        self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*self.File:len(),2)..'%)'
    end
    if not (self.Receive or (#self.Snipped > 0)) and self.RecvStarted and math.round(100/self.Size*self.File:len(),2) > 95 then
        self.DownloadStatus = 'Downloading Script (100%)'
        local HeaderEnd, ContentStart = self.File:find('<sc'..'ript>')
        local ContentEnd, _ = self.File:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local f = io.open(self.SavePath,"w+b")
            f:write(self.File:sub(ContentStart + 1,ContentEnd-1))
            f:close()
            if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
            end
        end
        self.GotScriptUpdate = true
    end
end
function Update()
	if not autoupdate then return end
	local scriptName = "FizzMaster"
    local ToUpdate = {}
    ToUpdate.Version = version
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/kokosik1221/bol/master/"..scriptName..".version"
    ToUpdate.ScriptPath = "/kokosik1221/bol/master/"..scriptName..".lua"
    ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) PrintMessage("Updated to "..NewVersion..". Please reload with 2x F9.") end
    ToUpdate.CallbackNoUpdate = function(OldVersion) PrintMessage("No Updates Found.") end
    ToUpdate.CallbackNewVersion = function(NewVersion) PrintMessage("New Version found ("..NewVersion..").") end
    ToUpdate.CallbackError = function(NewVersion) PrintMessage("Error while downloading.") end
    _ScriptUpdate(ToUpdate.Version, ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
end
function PrintMessage(message)
    print("<font color=\"#FFFFFF\"><b>" .. "FizzMaster" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
end
if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
	require("SxOrbWalk")
end
if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require("VPrediction")
	VP = VPrediction()
end
if VIP_USER and FileExist(LIB_PATH .. "/Prodiction.lua") then
	require("Prodiction")
	prodstatus = true
end
if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
	require "DivinePred" 
	DP = DivinePred()
end

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local DodgeSpells = {
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
 
local Q = {name = "Urchin Strike", range = 550, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Seastone Trident", Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Playful", range = 400, speed = 1200, delay = 0.25, width = 330, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local E2 = {name = "Trickster", range = 400, speed = 1200, delay = 0.25, width = 270}
local R = {name = "Chum the Waters", range = 1175, speed = 1200, delay = 0.5, width = 80, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local killstring = {}
local recall = false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local Spells = {_Q,_W,_E,_R}
local Spells2 = {"Q","W","E","R"}
local TargetTable = {
	AP = {
		"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Annie", "Heimerdinger", "Karthus",
		"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
		"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
	},	
	Support = {
		"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
	},	
	Tank = {
		"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
		"Warwick", "Yorick", "Zac"
	},
	AD_Carry = {
		"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
		"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
	},
	Bruiser = {
		"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
		"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
	}
}

function OnLoad()
	DelayAction(function()
		Update()
	end,0.1)
	Menu()
	SSpells = SumSpells()
	print("<b><font color=\"#FF0000\">Fizz Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Fizz Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Fizz Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if Cel ~= nil and MenuFizz.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.comboConfig.manac and not recall then
		Combo()
	end
	if Cel ~= nil and (MenuFizz.harrasConfig.HEnabled or MenuFizz.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.harrasConfig.manah and not recall then
		Harrass()
	end
	if MenuFizz.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.farm.manaf and not recall then
		Farm()
	end
	if MenuFizz.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuFizz.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuFizz.prConfig.AZ and not recall then
		autozh()
	end
	if MenuFizz.prConfig.ALS and not recall then
		autolvl()
	end
	if MenuFizz.exConfig.ESCAPE and not recall then
		Escape()
	end
	if MenuFizz.comboConfig.FU and not recall then
		if ValidTarget(Cel, R.range) and not Cel.dead then
			CastR(Cel)
		end
	end
	if not recall then
		KillSteall()
	end
end

function Menu()
	MenuFizz = scriptConfig("Fizz Master "..version, "Fizz Master "..version)
	MenuFizz:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuFizz:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuFizz.orb == 1 then
		MenuFizz:addSubMenu("[Fizz Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuFizz.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Fizz"
	MenuFizz:addTS(TargetSelector)
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
	MenuFizz.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuFizz.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuFizz.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuFizz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuFizz.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "MID"})
	MenuFizz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuFizz.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuFizz.comboConfig:permaShow("CEnabled")
	MenuFizz.harrasConfig:permaShow("HEnabled")
	MenuFizz.harrasConfig:permaShow("HTEnabled")
	MenuFizz.prConfig:permaShow("AZ")
	if heroManager.iCount < 10 then
		print("<font color=\"#FF0000\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
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
	if R.Ready() and MenuFizz.comboConfig.CT == 2 then
		TargetSelector.range = R.range
	else
		TargetSelector.range = Q.range
	end
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, TargetSelector.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuFizz.orb == 1 then
		SxOrb:ForceTarget(Cel)
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
		if ValidTarget(Cel, Q.range) then
			CastQ(Cel)
		end
	end
	if MenuFizz.comboConfig.USER then
		if ValidTarget(Cel, R.range) then
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
		if ValidTarget(Cel, myHero.range+120) then
			CastW()
		end
	end
	if MenuFizz.comboConfig.USEE then
		if ValidTarget(Cel, E.range + 50) then
			CastE(Cel)
		end
		if GetDistance(Cel, myHero) > 330 then
			CastE2(Cel)
		end
	end
end

function comboRQWE()
	if MenuFizz.comboConfig.USER then
		if ValidTarget(Cel, R.range) then
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
		if ValidTarget(Cel, Q.range) then
			CastQ(Cel)
		end
	end
	if MenuFizz.comboConfig.USEW then
		if ValidTarget(Cel, myHero.range+120) then
			CastW()
		end
	end
	if MenuFizz.comboConfig.USEE then
		if ValidTarget(Cel, E.range + 50) then
			CastE(Cel)
		end
		if GetDistance(Cel, myHero) > 330 then
			CastE2(Cel)
		end
	end
end

function Harrass() 
	local QMana = myHero:GetSpellData(_Q).mana
    local WMana = myHero:GetSpellData(_W).mana
    local EMana = myHero:GetSpellData(_E).mana
	if MenuFizz.harrasConfig.HM == 1 then
		if ValidTarget(Cel, Q.range) and myHero.mana > QMana then
			CastQ(Cel)
		end
	end
	if MenuFizz.harrasConfig.HM == 2 then
		if W.Ready() and Q.Ready() and ValidTarget(Cel, Q.range) and myHero.mana > (WMana + QMana) then
			CastW()
			CastQ(Cel)
		end
	end
	if MenuFizz.harrasConfig.HM == 3 then
		if W.Ready() and Q.Ready() and ValidTarget(Cel, Q.range) and myHero.mana > (WMana + QMana + EMana) then
			CastW()
			CastQ(Cel)
		end
		if E.Ready() then
			CastSpell(_E, mousePos.x, mousePos.z)
		end
	end
end

function Farm()
	local myE = myHero:GetSpellData(_E)
	EnemyMinions:update()
	local QMode =  MenuFizz.farm.QF
	local WMode =  MenuFizz.farm.WF
	local EMode =  MenuFizz.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				CastSpell(_Q, minion)
			end
		elseif QMode == 2 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					CastSpell(_Q, minion)
				end
			end
		end
		if WMode == 2 then
			if W.Ready() and minion ~= nil and ValidTarget(minion, W.range) then
				CastW()
			end
		end
		if EMode == 2 then
			if E.Ready() and minion ~= nil and ValidTarget(minion, E.range) then
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

function _GetDistanceSqr(p1, p2)
    p2 = p2 or player
    if p1 and p1.networkID and (p1.networkID ~= 0) and p1.visionPos then p1 = p1.visionPos end
    if p2 and p2.networkID and (p2.networkID ~= 0) and p2.visionPos then p2 = p2.visionPos end
    return GetDistanceSqr(p1, p2)
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if _GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function BestEFarmPos(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object or object, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function JungleFarmm()
	JungleMinions:update()
	local myE = myHero:GetSpellData(_E)
	for i, minion in pairs(JungleMinions.objects) do
		if MenuFizz.jf.QJF then
			if minion ~= nil and GetDistance(minion) <= Q.range then
				CastQ(minion)
			end
		end
		if MenuFizz.jf.WJF then
			if minion ~= nil and GetDistance(minion) <= myHero.range+120 then
				CastW()
			end
		end
		if MenuFizz.jf.EJF then
			if E.Ready() and minion ~= nil and GetDistance(minion) <= E.range then
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

function autozh()
	local count = EnemyCount(myHero, MenuFizz.prConfig.AZMR)
	local zhonyaslot = GetInventorySlotItem(3157)
	local zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuFizz.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuFizz.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_W,_Q,_E,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuFizz.drawConfig.DST and MenuFizz.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuFizz.drawConfig.DQRC[2], MenuFizz.drawConfig.DQRC[3], MenuFizz.drawConfig.DQRC[4]))
		end
	end
	if MenuFizz.drawConfig.DD then
		for _,enemy in pairs(GetEnemyHeroes()) do
			DmgCalc()
            if ValidTarget(enemy, 2000) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuFizz.drawConfig.DAAR then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, myHero.range + 65, RGB(MenuFizz.drawConfig.DAARC[2], MenuFizz.drawConfig.DAARC[3], MenuFizz.drawConfig.DAARC[4]))
	end
	if MenuFizz.drawConfig.DQR and Q.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuFizz.drawConfig.DQRC[2], MenuFizz.drawConfig.DQRC[3], MenuFizz.drawConfig.DQRC[4]))
	end
	if MenuFizz.drawConfig.DER and E.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuFizz.drawConfig.DERC[2], MenuFizz.drawConfig.DERC[3], MenuFizz.drawConfig.DERC[4]))
	end
	if MenuFizz.drawConfig.DRR and R.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuFizz.drawConfig.DRRC[2], MenuFizz.drawConfig.DRRC[3], MenuFizz.drawConfig.DRRC[4]))
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
		if Enemy ~= nil and ValidTarget(Enemy, 1500) then
			if hp < QDMG and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.QKS then
				CastQ(Enemy)
			elseif hp < WDMG and ValidTarget(Enemy, myHero.range+120) and MenuFizz.ksConfig.WKS then
				CastW()
				myHero:Attack(Enemy)
			elseif hp < EDMG and ValidTarget(Enemy, E.range + 50) and MenuFizz.ksConfig.EKS then
				if E.Ready() and ValidTarget(Enemy, E.range + 50) and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					CastE(Enemy)
				end
				if GetDistance(Enemy, myHero) > 330 and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					CastE2(Enemy)
				end
			elseif hp < RDMG and ValidTarget(Enemy, R.range) and MenuFizz.ksConfig.RKS then	
				CastR(Enemy)
			elseif hp < (QDMG+WDMG) and Q.Ready() and W.Ready() and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.QKS and MenuFizz.ksConfig.WKS then
				CastW()
				CastQ(Enemy)
			elseif hp < (QDMG+EDMG) and Q.Ready() and E.Ready() and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.QKS and MenuFizz.ksConfig.EKS then
				CastQ(Enemy)
				if E.Ready() and ValidTarget(Enemy, E.range + 50) and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					CastE(Enemy)
				end
				if GetDistance(Enemy, myHero) > 330 and Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead then
					CastE2(Enemy)
				end			
			elseif hp < (QDMG+RDMG) and Q.Ready() and R.Ready() and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.QKS and MenuFizz.ksConfig.RKS then
				CastR(Enemy)
				CastQ(Enemy)
			elseif hp < (RDMG+WDMG) and W.Ready() and R.Ready() and ValidTarget(Enemy, myHero.range+120) and MenuFizz.ksConfig.RKS and MenuFizz.ksConfig.WKS then
				CastR(Enemy)
				CastW()
				myHero:Attack(Enemy)
			elseif hp < (QDMG+WDMG+RDMG) and Q.Ready() and W.Ready() and R.Ready() and ValidTarget(Enemy, Q.range) and MenuFizz.ksConfig.RKS and MenuFizz.ksConfig.QKS and MenuFizz.ksConfig.WKS then
				CastR(Enemy)
				CastW()
				CastQ(Enemy)
			end
			local IReady = SSpells:Ready("summonerdot")
			if IReady and hp < IDMG and MenuFizz.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(SSpells:GetSlot("summonerdot"), Enemy)
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
	if Q.Ready() then
		if VIP_USER and MenuFizz.prConfig.pc then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_Q, unit)
		end
	end
end

function CastW()
	if W.Ready() then
		if VIP_USER and MenuFizz.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if E.Ready() then
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
			if MenuFizz.prConfig.pro == 3 and VIP_USER then
				local unit = DPTarget(unit)
				local FizzE = CircleSS(E.speed, E.range, E.width, E.delay*1000, math.huge)
				local State, Position, perc = DP:predict(unit, FizzE)
				if State == SkillShot.STATUS.SUCCESS_HIT then 
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
	if E.Ready() then
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
			if MenuFizz.prConfig.pro == 3 and VIP_USER then
				local unit = DPTarget(unit)
				local FizzE2 = CircleSS(E2.speed, E2.range, E2.width, E.delay*1000, math.huge)
				local State, Position, perc = DP:predict(unit, FizzE2)
				if State == SkillShot.STATUS.SUCCESS_HIT then 
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
	if R.Ready() then
		local Position = nil
		if MenuFizz.prConfig.pro == 1 then
			local CastPosition, HitChance, Positionn = VP:GetLineCastPosition(unit, R.delay, R.width, R.range, R.speed, myHero)
			if HitChance >= 2 then
				Position = CastPosition
			end
		end
		if MenuFizz.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Posss, info = Prodiction.GetPrediction(unit, R.range, R.speed, R.delay, R.width, myHero)
			if Posss ~= nil then
				Position = Posss
			end
		end
		if MenuFizz.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local FizzR = LineSS(R.speed, R.range, R.width, R.delay*1000, math.huge)
			local State, Pos, perc = DP:predict(unit, FizzR)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				Position = Pos
			end
		end
		if Position then
			local x,y,z = (Vector(Position) - Vector(myHero)):normalized():unpack()
			posX = Position.x + (x * 100)
			posY = Position.y + (y * 100)
			posZ = Position.z + (z * 100)
			if VIP_USER and MenuFizz.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = posX, fromY = posZ, toX = posX, toY = posZ}):send()
			else
				CastSpell(_R, posX, posZ)
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
					if E.Ready() and DodgeSpells[spell.name] and MenuFizz.exConfig.ES[spell.name] then
						CastSpell(_E, mousePos.x, mousePos.z)
				    end
			    end
		    end	
		end
	end
end

function Escape()
	if MenuFizz.exConfig.EUE and E.Ready() then
		CastSpell(_E, mousePos.x, mousePos.z)
	end
	if MenuFizz.exConfig.EUQ and Q.Ready() then
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

function OnApplyBuff(unit, source, buff)
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = false
	end
end

function SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end

function arrangePrioritysTT()
    for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(TargetTable.AD_Carry, enemy, 1)
		SetPriority(TargetTable.AP,       enemy, 1)
		SetPriority(TargetTable.Support,  enemy, 2)
		SetPriority(TargetTable.Bruiser,  enemy, 2)
		SetPriority(TargetTable.Tank,     enemy, 3)
    end
end

function arrangePrioritys()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(TargetTable.AD_Carry, enemy, 1)
		SetPriority(TargetTable.AP, enemy, 2)
		SetPriority(TargetTable.Support, enemy, 3)
		SetPriority(TargetTable.Bruiser, enemy, 4)
		SetPriority(TargetTable.Tank, enemy, 5)
	end
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

class 'SumSpells'
function SumSpells:__init()
	names = {"summonerdot", "summonerflash", "summonerexhaust", "summonerheal", "summonersmite"}
end

function SumSpells:Ready(name)
	local Ready = false
	local Spel = self:GetSlot(name)
	Ready = (Spel ~= nil and myHero:CanUseSpell(Spel) == READY)
	return Ready
end

function SumSpells:GetSlot(name)
	if myHero:GetSpellData(SUMMONER_1).name == name then 
		return SUMMONER_1 
	end
	if myHero:GetSpellData(SUMMONER_2).name == name then 
		return SUMMONER_2 
	end
end

-----SCRIPT STATUS------------
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("UHKIIOHNMOK") 
