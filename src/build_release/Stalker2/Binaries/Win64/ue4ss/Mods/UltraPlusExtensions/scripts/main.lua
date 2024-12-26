---@diagnostic disable: undefined-global
UltraExtensions = {
	__VERSION	 = '4.0-stalker-2',
	__DESCRIPTION = 'Extensions for Ultra+ for S.T.A.L.K.E.R. 2',
	__URL		 = 'https://github.com/sammilucia/sh2-ultra-plus-extensions',
	__LICENSE	 = [[
	MIT License

	Copyright 2024 Samantha Glocker (SammiLucia) and Lazorr

	Permission is hereby granted, free of charge, to any person obtaining a copy of this
	software and associated documentation files (the 'Software'), to deal in the Software
	without restriction, including without limitation the rights to use, copy, modify, merge
	publish, distribute, sublicense, and/or sell copies of the Software, and to permit
	persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or
	substantial portions of the Software.

	THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
	INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
	PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]
}

require('ultraini')
local UltraPlusSettings = require('settings')
local UEHelpers = require('UEHelpers')
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local ksl = GetKismetSystemLibrary()
local engine = FindFirstOf('Engine')
local iniPath='ue4ss/Mods/UltraPlusExtensions/scripts/config/'
local runtimeIniFile = 'RuntimeSettings.ini'
local scalabilityIniFile = 'ScalabilitySettings.ini'
local configIni = "UltraPlusConfig.ini"

local scalabilityGroups

local enableFGCutscenes = false
local nvFrameGenerationCvar = "r.Streamline.DLSSG.Enable"
local nvFrameGenerationCvarEnableValue = "1"
local amdFrameGenerationCvar = "r.FidelityFX.FI.Enabled"
local amdFrameGenerationCvarEnableValue = "1" 

-- default to nvidia, will get queried from engine later
local frameGenerationCvar = "r.Streamline.DLSSG.Enable"
local frameGenerationCvarEnableValue = "1" 

UltraSettings.settings.FGCutscenes = {
	Comment = 'off/on; enables support for frame generation in cutscenes - both DLSSG and FSRFG are supported',
	Commands = { OFF = {{ 'Cutscenes', '0'}},
				 ON = {{'Cutscenes', '1'}}},
	CurrentSetting = 'off',
	UserSettings = { OFF = 'off', ON = 'on'},
	UserSettingsOrder = { a = 'off', b = 'on' },
	ApplyCustom = function(setFunction)
		applyCustomSetting(UltraSettings.settings.FGCutscenes, UltraSettings.settings.FGCutscenes.CurrentSetting, setFunction)
	end
}

--- @param msg string
local function __log(msg)
	print(string.format('[UltraExtensions]: %s\n', msg))
end

local cvarTimer = 0
--- @param cmd string
--- @param val string
local function setCVar(cmd, val, delay)
	if not ksl:IsValid() then
		error('KismetSystemLibrary is not valid\n')
	end

	if not delay then
		delay = 0
	end

	cvarTimer = cvarTimer + 50
	ExecuteWithDelay(cvarTimer + delay, function()
		cvarTimer = cvarTimer - 50
		__log(string.format("Timer %s setting cvar %s to %s", cvarTimer, cmd, tostring(val)))
		ExecuteInGameThread(function()
			ksl:ExecuteConsoleCommand(
				engine, cmd .. ' ' .. val, nil
			)
		end)
	end)
end

--- @param cmd string
--- @param type string ('float', 'int', 'bool', 'string')
local function getCVar(cmd, type)
	if not ksl:IsValid() then
		error('KismetSystemLibrary is not valid\n')
	end

	ksl = GetKismetSystemLibrary(true)

	if type == 'float' then
		return tostring(ksl:GetConsoleVariableFloatValue(cmd))
	elseif type == 'int' then
		return tostring(ksl:GetConsoleVariableIntValue(cmd))
	elseif type == 'bool' then
		return tostring(ksl:GetConsoleVariableBoolValue(cmd))
	else
		error('Unknown CVar type')
	end
end

--- @param cmd string
local function sendCommand(cmd)
	if not ksl:IsValid() then
		error('KismetSystemLibrary is not valid\n')
	end

	ExecuteInGameThread(function()
		ksl:ExecuteConsoleCommand(
			engine, cmd, nil
		)
	end)
end

-- getCVar sucks so we could remove some things, but other logic can be useful for dev purposes and checking many values
local function checkCvar(cvar, expectedValue, forceSetExpected)
	local uplusValue = expectedValue
	local gameValue

	if tonumber(uplusValue) then
		if uplusValue:find("%D") then
			gameValue = string.format("%.3f", tonumber(getCVar(cvar, 'float')))
			uplusValue = string.format("%.3f", uplusValue)
		else
			gameValue = getCVar(cvar, 'int')
		end
		
	else
		uplusValue = uplusValue:lower() == 'true'
		gameValue = getCVar(cvar, 'bool')
	end
	uplusValue = tostring(uplusValue)
	if gameValue ~= uplusValue then
		-- __log(string.format("VALUES NOT EQUAL: %s %s expected: %s", cvar, gameValue, uplusValue))
		if (forceSetExpected) then
			setCVar(cvar, uplusValue)
		end
	end
end

local function validateInis(forceSetExpected)
	local iniData = LoadIni(iniPath .. runtimeIniFile)	

	__log(string.format("Loading runtime ini"))
	
	if iniData then
		for k, v in pairs(iniData) do
			for cvar, cvarValue in pairs(iniData[k]) do
				checkCvar(cvar, cvarValue, forceSetExpected)
			end
		end
	else
		__log("Could not read from INI " .. iniPath .. runtimeIniFile)
	end
end

local function loadScalabilityGroups(group)
	scalabilityGroups = LoadScalability(iniPath .. scalabilityIniFile)	
	
	__log(string.format("Setting scalability preset to %s", group))
	
	if scalabilityGroups then
		for k, v in pairs(scalabilityGroups) do
			for cvar, cvarValue in pairs(scalabilityGroups[k][group]) do
				checkCvar(cvar, cvarValue, true)
			end
		end
	else
		__log("Could not read from INI " .. iniPath .. scalabilityIniFile)
	end
end

local registered = false
local function registerKeybinds()
	if registered then
		return
	end
	registered = true

	local function register(k)
		-- some settings don't have shortcuts
		if not UltraSettings.settings[k].Shortcut then
			return
		end

		if UltraSettings.settings[k].ShortcutCtrlModifier then
			__log("Registering ctrl keybind " .. UltraSettings.settings[k].Shortcut .. " for " .. k)
			RegisterKeyBind(Key[UltraSettings.settings[k].Shortcut], {ModifierKey.CONTROL}, function()
				UltraSettings.cycleCurrentSetting(UltraSettings.settings[k])
				UltraSettings.applyAll(setCVar, setCustom)
				UltraSettings.write(configIni)
			end)
		else
			__log("Registering keybind " .. UltraSettings.settings[k].Shortcut .. " for " .. k)
			RegisterKeyBind(Key[UltraSettings.settings[k].Shortcut], function()
				UltraSettings.cycleCurrentSetting(UltraSettings.settings[k])
				UltraSettings.applyAll(setCVar, setCustom)
				UltraSettings.write(configIni)
			end)
		end
	end

	UltraSettings.iterateSortedSettings(register)
end

local function setCustom(key, value)
	if key == 'Scalability' then
		loadScalabilityGroups(value)
	elseif key == 'Keybinds' then
		if value == '1' then
			registerKeybinds()
		end
	elseif key == 'Cutscenes' then
		if value == '1' then
			enableFGCutscenes = true
		else
			enableFGCutscenes = false
		end
	end
end

local function applySettings()
	UltraSettings.read(configIni)
	UltraSettings.applyAll(setCVar, setCustom)
	UltraSettings.write(configIni)
end

-- one keybind to apply settings
RegisterKeyBind(Key.F12, function()
	applySettings()
end)



local init = false
local function delayedInjection()
	if not init then
		init = true	
		ExecuteWithDelay(100, function()
			applySettings()
			validateInis(true)
		end)
	end
end

NotifyOnNewObject('/Script/Engine.Level', function()
	delayedInjection()
end)

local function detectFrameGeneration()
	local amdValue = getCVar(amdFrameGenerationCvar, 'int')
	
	if tostring(amdValue) == amdFrameGenerationCvarEnableValue then
		return amdFrameGenerationCvar, amdFrameGenerationCvarEnableValue
	end

	-- will always fall back to nvidia if we don't detect AMD
	return nvFrameGenerationCvar, nvFrameGenerationCvarEnableValue
end

local fgCutsceneDebounce = false
local function overrideCutsceneFg()
	if fgCutsceneDebounce then
		return
	end

	if not enableFGCutscenes then
		return
	end

	fgCutsceneDebounce = true

	-- from my testing, this happens before the game decides to change FG - not sure if the timing holds true on all PCs 
	frameGenerationCvar, frameGenerationCvarEnableValue = detectFrameGeneration()
	__log(string.format("movie scene detected FG %s %s", frameGenerationCvar, frameGenerationCvarEnableValue))

	ExecuteWithDelay(100, function()
		setCVar(frameGenerationCvar, frameGenerationCvarEnableValue)
		__log("OVERRIDE CUTSCENE DLSSG")
		fgCutsceneDebounce = false
	end)
end

NotifyOnNewObject('/Script/MovieScene.MovieSceneSequencePlayer', function ()
	overrideCutsceneFg()
end)