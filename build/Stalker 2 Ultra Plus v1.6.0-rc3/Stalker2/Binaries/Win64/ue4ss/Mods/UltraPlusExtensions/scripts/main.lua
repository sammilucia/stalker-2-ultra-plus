---@diagnostic disable: undefined-global
UltraExtensions = {
	__VERSION	 = '3.1-stalker-2',
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
local UEHelpers = require('UEHelpers')
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local ksl = GetKismetSystemLibrary()
local engine = FindFirstOf('Engine')
local iniPath='ue4ss/Mods/UltraPlusExtensions/scripts/config/'
local runtimeIniFile = 'RuntimeSettings.ini'
local scalabilityIniFile = 'ScalabilitySettings.ini'

local shortcut = {
	-- for a complete list: https://docs.ue4ss.com/lua-api/table-definitions/key.html
	Denoiser		         = Key.F2,
	Vignette		         = Key.F5,
	DLSSPreset		         = Key.F6,
	Reflex			         = Key.F6,	-- CTRL + F6
	ReflectionBias           = Key.F9,
	HDR				         = Key.F8, -- CTRL + F8
	ReflectionQuality        = Key.F10,
	LumenPercent	         = Key.F12,
	GameQualityPreset        = Key.F10, -- CTRL + F10
	EnableFGCutscenes        = Key.F5, -- CTRL + F5
	EnableModGranularControl = Key.F2, -- CTRL + F2
	UltraPlusQuality         = Key.F12, -- CTRL + F12
}
shortcut.sortOrder = {
	Denoiser		  = 1,
	Vignette		  = 2,
	DLSSPreset		  = 3,
	ReflectionBias	  = 4,
	ReflectionQuality = 5,
	LumenPercent	  = 6,
	EnableModGranularControl = 7,
	EnableFGCutscenes = 8,
	Reflex			  = 9,
	HDR				  = 10,
	GameQualityPreset = 11,
	UltraPlusQuality = 12
}
shortcut.comment = {
	Denoiser		         = {'; F2:  Reflections denoiser: None, Temporal, RayReconstruction'},
	Vignette		         = {'; F5:  Vignette: True/False'},
	DLSSPreset		         = {'; F6:  DLSS preset:', ';      A = 1', ';      C = 3', ';      E = 5', ';      F = 6', ';      G = 7 (DLSS 3.8+ only)'},
	ReflectionBias	         = {'; F9:  Cycles between reflection smoothing bias (higher makes', '; reflections more mirror-like. Ultra+ default is 0.6)',';          Vanilla = 0',';          Light = 0.2',';          Medium = 0.4', ';          High = 0.6'},
	ReflectionQuality        = {'; F10: Lumen reflections quality:', ';      Vanilla, High, Ultra'},
	LumenPercent	         = {'; IGNORED FOR STALKER 2 F12: Cycles between Lumen screen upscaling percent:', ';          Full = 1.0', ';          Ultra Quality = 0.77', ';          Quality = 0.67', ';          Balanced = 0.58', ';          Performance = 0.5', ';          Ultra Performance = 0.33'},
	EnableModGranularControl = {'; CTRL + F2:  Disable Ultra+ Quality Presets: True/False', '; When \'True\', disables UltraPlusQuality and enables the more granular', '; controls above. (To disable granular controls, set to \'False\' and', '; restart the game.)'},
	EnableFGCutscenes        = {'; CTRL + F5:  Enable Frame Generation in cut scenes: True/False', '; (Not set by UltraPlusQuality)'},
	Reflex			         = {'; CTRL + F6:  Nvidia Reflex with Boost+: True/False', '; (Ignored when using AMD Frame Generation)'},
	HDR				         = {'; CTRL + F8:  Force HDR: True/False', '; (Not set by UltraPlusQuality)'},
	GameQualityPreset        = {'; CTRL + F10: Graphics Menu Quality:', '; (Not set by UltraPlusQuality)', '; Forces settings which can\'t be changed from Unreal Engines\' in-game', '; graphics menus. Set to the same as your in-game graphics quality.', ';             Low (0), Medium (1), High (2), Epic(3)'},
	UltraPlusQuality         = {'; CTRL + F12: Ultra+ Quality Preset:', '; When EnableModGranularControl is False, this setting controls Ultra+\'s', '; quality level.', ';             Low, Medium, High, Ultra'},
}
local isInitialized = false
local configFilePath = 'UltraPlusConfig.ini'

local var = {
	Denoiser = {
		TEMPORAL = 'temporal',
		RR		 = 'rayreconstruction',
		NONE	 = 'none',
	},
	DLSSPreset = {
		A = '1',
		C = '3',
		E = '5',
		F = '6',
		G = '7',
	},
	ReflectionQuality = {
		VANILLA	= 'vanilla',
		HIGH	= 'high',
		ULTRA	= 'ultra',
	},
	LumenPercent = {
		ULTRAPERF = '0.33',
		PERFORMANCE = '0.5',
		BALANCED = '0.58',
		QUALITY = '0.67',
		ULTRAQUALITY = '0.77',
		FULL = '1.0',
	},
	ReflectionBias = {
		VANILLA	= '0.0',
		LIGHT	= '0.2',
		MEDIUM	= '0.4',
		HIGH	= '0.6',
	},
	GameQualityPreset = {
		LOW		= '0',
		MEDIUM	= '1',
		HIGH	= '2',
		EPIC	= '3',
	},
	UltraPlusQuality = {
		LOW = 'low',
		MEDIUM = 'medium',
		HIGH = 'high',
		ULTRA = 'ultra',
	}
}
local UltraPlusQualityPresets = {
	LOW = {
		ReflectionQuality = var.ReflectionQuality.VANILLA,
		Denoiser = var.Denoiser.NONE, 
		LumenPercent = var.LumenPercent.QUALITY,
		ReflectionBias = var.ReflectionBias.LIGHT, 
		GameQualityPreset = var.GameQualityPreset.LOW,
		EnableFGCutscenes = true
		-- vignette left at user setting
		-- HDR left at user setting
		-- Reflex left at user settings
		-- DLSS Preset left at user setting
	},
	MEDIUM = {
		ReflectionQuality = var.ReflectionQuality.HIGH,
		Denoiser = var.Denoiser.TEMPORAL, 
		LumenPercent = var.LumenPercent.QUALITY,
		ReflectionBias = var.ReflectionBias.LIGHT,
		GameQualityPreset = var.GameQualityPreset.HIGH,
		EnableFGCutscenes = true
	},
	HIGH = {
		ReflectionQuality = var.ReflectionQuality.HIGH,
		Denoiser = var.Denoiser.RR,
		LumenPercent = var.LumenPercent.QUALITY,
		ReflectionBias = var.ReflectionBias.LIGHT,
		GameQualityPreset = var.GameQualityPreset.HIGH,
		EnableFGCutscenes = true
	},
	ULTRA  = {
		ReflectionQuality = var.ReflectionQuality.ULTRA,
		Denoiser = var.Denoiser.RR,
		LumenPercent = var.LumenPercent.FULL,
		ReflectionBias = var.ReflectionBias.LIGHT,
		GameQualityPreset = var.GameQualityPreset.EPIC,
		EnableFGCutscenes = true
	}
}
local config = {
	Vignette = true, -- will be left at default in "simplified" mode
	DLSSPreset = var.DLSSPreset.G, -- TODO should we set this or leave at user preference/default
	Reflex = true, -- we should just force enable this if the user uses the nvidiafg version
	HDR = false, -- power user option
	ReflectionQuality = var.ReflectionQuality.VANILLA,
	Denoiser = var.Denoiser.NONE, -- TODO denoiser is kind of user preference, but with a high quality baseline RR denoiser causes issues with trees, puddle reflections, and FPS loss - others report that it helps in specific scenes - users with low quality baseline have more gains from RR
	LumenPercent = var.LumenPercent.QUALITY, -- TODO lumen percent is currently disabled below - the logic is still present but doesn't seem to work correctly in Stalker 2
	GameQualityPreset = var.GameQualityPreset.HIGH,
	ReflectionBias = var.ReflectionBias.HIGH, -- recommend light (0.2) as a baseline
	EnableFGCutscenes = true, -- TODO UI flicker in cutscenes, still worth using imo
	EnableModGranularControl = false, -- simplified version is two buttons, one to cycle the quality mode and one to enable granular control for all of the buttons, granular control disables toggling UltraPlusQuality
	UltraPlusQuality = var.UltraPlusQuality.HIGH -- default to high
}
local UltraPlusQuality = {
	LOW = {
		ReflectionQuality = var.ReflectionQuality.VANILLA,
		Denoiser = var.Denoiser.NONE, 
		LumenPercent = var.LumenPercent.QUALITY,
		ReflectionBias = var.ReflectionBias.HIGH, 
		GameQualityPreset = var.GameQualityPreset.LOW,
		EnableFGCutscenes = true
		-- vignette left at user setting
		-- HDR left at user setting
		-- Reflex left at user settings
		-- DLSS Preset left at user setting
	},
	MEDIUM = {
		ReflectionQuality = var.ReflectionQuality.HIGH,
		Denoiser = var.Denoiser.TEMPORAL, 
		LumenPercent = var.LumenPercent.QUALITY,
		ReflectionBias = var.ReflectionBias.HIGH,
		GameQualityPreset = var.GameQualityPreset.HIGH,
		EnableFGCutscenes = true
	},
	HIGH = {
		ReflectionQuality = var.ReflectionQuality.HIGH,
		Denoiser = var.Denoiser.RR,
		LumenPercent = var.LumenPercent.QUALITY,
		ReflectionBias = var.ReflectionBias.HIGH,
		GameQualityPreset = var.GameQualityPreset.HIGH,
		EnableFGCutscenes = true
	},
	ULTRA  = {
		ReflectionQuality = var.ReflectionQuality.ULTRA,
		Denoiser = var.Denoiser.RR,
		LumenPercent = var.LumenPercent.FULL,
		ReflectionBias = var.ReflectionBias.HIGH,
		GameQualityPreset = var.GameQualityPreset.EPIC,
		EnableFGCutscenes = true
	}
}

local scalabilityGroups

-- default to nvidia, will get loaded from config/RuntimeSettings.ini [FrameGenerationMode]
local frameGenerationCvar = "r.Streamline.DLSSG.Enable"
local frameGenerationCvarEnableValue = "1"
local isFSRFI = false

--- @param msg string
local function __log(msg)
	print(string.format('[UltraExtensions]: %s\n', msg))
end

--- @param cases table keys are the possible values, values are the corresponding results
--- @param value any the value to switch on
--- @param default any the default result if no cases match
--- @return any
local function switch(cases, value, default)
	local result = cases[value]
	return result ~= nil and result or default
end

local function saveConfig()
	local file = io.open(configFilePath, 'w')
	if file then
		-- sort by shortcut.sortOrder
		local sortedKeys = {}
		for k in pairs(shortcut.comment) do
			table.insert(sortedKeys, k)
		end
		table.sort(sortedKeys, function(a, b)
			return shortcut.sortOrder[a] < shortcut.sortOrder[b]
		end)

		for _, key in ipairs(sortedKeys) do
			local comments = shortcut.comment[key]

			for _, comment in ipairs(comments) do
				file:write(comment .. '\n')
			end

			file:write(key .. '=' .. tostring(config[key]) .. '\n')
			file:write('\n')
		end

		file:close()
		__log('Settings saved to ' .. configFilePath)
	else
		__log('Error saving settings')
	end
end

local function loadConfig()
	local file = io.open(configFilePath, 'r')
	if not file then
		__log('No config file found, creating a new one')
		saveConfig()
		return
	end

	__log('Loading settings')
	local keysFound = {}

	for line in file:lines() do
		-- strip anything after ';' and trim excess spaces
		local cleanLine = line:match('^[^;]*'):gsub('^%s*(.-)%s*$', '%1')

		-- only process line if not empty after removing comments
		if cleanLine ~= '' then
			for key, value in cleanLine:gmatch('([^=]+)%s*=%s*(.+)') do
				key = key:match('^%s*(.-)%s*$')						-- trim whitespace
				value = string.lower(value:match('^%s*(.-)%s*$'))	-- trim whitespace

				if config[key] ~= nil then
					if value == 'true' then
						value = true
					elseif value == 'false' then
						value = false
					end

					config[key] = value
					keysFound[key] = true
				else
					__log('Unknown config: ' .. key)
				end
			end
		end
	end

	file:close()

	for key, defaultValue in pairs(config) do
		if not keysFound[key] then
			__log('No config for: ' .. key .. ', using default')
			config[key] = defaultValue
		end
	end
end

--- @param cmd string
--- @param val string
local function setCVar(cmd, val)
	if not ksl:IsValid() then
		error('KismetSystemLibrary is not valid\n')
	end

	ExecuteInGameThread(function()
		ksl:ExecuteConsoleCommand(
			engine, cmd .. ' ' .. val, nil
		)
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
			-- __log(string.format("float CVar %s returned: %s \n", cvar, gameValue))
		else
			gameValue = getCVar(cvar, 'int')
			-- __log(string.format("int CVar %s returned: %s \n", cvar, gameValue))
		end
		
	else
		uplusValue = uplusValue:lower() == 'true'
		gameValue = getCVar(cvar, 'bool')
		-- __log(string.format("bool CVar %s returned: %s", cvar, gameValue))
	end
	uplusValue = tostring(uplusValue)
	if gameValue ~= uplusValue then
		-- __log(string.format("VALUES NOT EQUAL: %s %s expected: %s", cvar, gameValue, uplusValue))
		if (forceSetExpected) then
			setCVar(cvar, uplusValue)
		
			if checkCvar(cvar, uplusValue, false) then
				__log(string.format("set %s to %s from: %s", cvar, uplusValue, gameValue))
			else
				__log(string.format("check ingame console, unsure if %s is set as to expected value: %s", cvar, uplusValue))
			end
		end
		return false
	else
		setCVar(cvar, uplusValue) -- we can't be sure the getCVar function is correct....
	end
	return true
end

local function validateInis(forceSetExpected)
	local iniData = LoadIni(iniPath .. runtimeIniFile)	

	__log(string.format("Loading runtime ini"))
	
	if iniData then
		for k, v in pairs(iniData) do
			for cvar, cvarValue in pairs(iniData[k]) do

				if k == 'UltraPlusDelayed' then
					ExecuteWithDelay(2000, function()
						checkCvar(cvar, cvarValue, forceSetExpected)	
					end)
				elseif k == 'FrameGenerationMode' then
					frameGenerationCvar = cvar
					frameGenerationCvarEnableValue = cvarValue
					
					__log(string.format("Frame generation settings loaded: %s %s", frameGenerationCvar, frameGenerationCvarEnableValue))
					if string.find(frameGenerationCvar, "FidelityFX") then
						__log("Detected FSRFI")
						isFSRFI = true
					end
				else
					checkCvar(cvar, cvarValue, forceSetExpected)
				end
			end
		end
	else
		__log("Could not read from INI " .. iniPath .. runtimeIniFile)
	end
end

local function loadScalabilityGroups()
	if not scalabilityGroups then
		scalabilityGroups = LoadScalability(iniPath .. scalabilityIniFile)	
	end

	__log(string.format("Setting scalability preset to %s", config.GameQualityPreset))
	
	if scalabilityGroups then
		for k, v in pairs(scalabilityGroups) do
			for cvar, cvarValue in pairs(scalabilityGroups[k][config.GameQualityPreset]) do
				checkCvar(cvar, cvarValue, true)
			end
		end
	else
		__log("Could not read from INI " .. iniPath .. scalabilityIniFile)
	end
end

local firstTimeDenoiser = true
local function pushDenoiser()
	local switchDenoiser = {
		[var.Denoiser.NONE] = function()
			setCVar('r.NGX.DLSS.DenoiserMode', '0')
			setCVar('r.Lumen.Reflections.Temporal', '0')
		end,
		[var.Denoiser.TEMPORAL] = function()
			setCVar('r.NGX.DLSS.DenoiserMode', '0')
			setCVar('r.Lumen.Reflections.Temporal', '1')
		end,
		[var.Denoiser.RR] = function()
			if firstTimeDenoiser then
				firstTimeDenoiser = false
				-- some weird bug with other settings we are applying and the order of them wants this to be initialize after...
				ExecuteWithDelay(10000, function()
					__log("10 second delayed execution of enabling RayReconstruction for first time")
					setCVar('r.Lumen.Reflections.Temporal', '0')
					setCVar('r.NGX.DLSS.DenoiserMode', '1')
				end)
			else
				setCVar('r.Lumen.Reflections.Temporal', '0')
				setCVar('r.NGX.DLSS.DenoiserMode', '1')
			end
		end,
	}
	local switchFunction = switchDenoiser[config.Denoiser]
	switchFunction()
end

local function pushVignette()
	setCVar('r.Tonemapper.Quality', config.Vignette and '5' or '1')
end

local function pushDLSSPreset()
	setCVar('r.NGX.DLSS.Preset', tostring(config.DLSSPreset))
end

local firstTimeReflex = true
local function pushReflex()
	if isFSRFI then
		__log("Skipping reflex, FSRFI detected")
		return
	end
	
	setCVar('t.Streamline.Reflex.Enable', config.Reflex and '1' or '0')
	if firstTimeReflex then
		firstTimeReflex = false
		-- idk why but this needs a delay on startup
		ExecuteWithDelay(5000, function()
			setCVar('t.Streamline.Reflex.Mode', config.Reflex and '2' or '0')
		end)
	else
		setCVar('t.Streamline.Reflex.Mode', config.Reflex and '2' or '0')
	end
end

local function pushReflectionQuality()
	local switchQuality = {
		[var.ReflectionQuality.VANILLA] = function()
			setCVar('r.Lumen.Reflections.MaxRoughnessToTrace', '0.4')
		end,
		[var.ReflectionQuality.HIGH] = function()
			setCVar('r.Lumen.Reflections.MaxRoughnessToTrace', '0.55')
		end,
		[var.ReflectionQuality.ULTRA] = function()
			setCVar('r.Lumen.Reflections.MaxRoughnessToTrace', '0.86')
		end,
	}
	local switchFunction = switchQuality[config.ReflectionQuality]
	switchFunction()
end


local function pushLumenPercent()
	-- DISABLED - in Stalker 2 this just changes DLSS scale
	-- setCVar('r.ScreenPercentage', tostring(config.LumenPercent * 100))
end

local function pushReflectionBias()
	setCVar('r.Lumen.Reflections.SmoothBias', tostring(config.ReflectionBias))
end

local function pushHDR()
	setCVar('r.AllowHDR', config.HDR and '1' or '0')
	setCVar('r.HDR.EnableHDROutput', config.HDR and '1' or '0')
	setCVar('r.HDR.Display.OutputDevice', config.HDR and '3' or '0')
	setCVar('r.HDR.Display.ColorGamut', config.HDR and '2' or '0')
	setCVar('r.HDR.UI.CompositeMode', config.HDR and '1' or '0')
end

local function pushGameQualityPreset()
	loadScalabilityGroups()
end

local function pushEnableFGCutscenes()
	-- nothing to do, maintaining pattern
end

local keybindsRegistered = false

-- All keybinds except for EnableModGranularControl and UltraPlusQuality go in this function
local function RegisterUltraKeybinds() 
	RegisterKeyBind(shortcut.Denoiser, function()
		if not config.EnableModGranularControl then
			return
		end
		
		config.Denoiser = switch({
			[var.Denoiser.TEMPORAL]	= var.Denoiser.RR,
			[var.Denoiser.RR]		= var.Denoiser.NONE,
			[var.Denoiser.NONE]		= var.Denoiser.TEMPORAL
		}, config.Denoiser, var.Denoiser.TEMPORAL)
		__log('Denoiser cycled to ' .. config.Denoiser)
		pushDenoiser()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.Vignette, function()
		if not config.EnableModGranularControl then
			return
		end

		__log((config.Vignette and 'Enabling' or 'Disabling') .. ' vignette')
		config.Vignette = not config.Vignette
		pushVignette()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.DLSSPreset, function()
		if not config.EnableModGranularControl then
			return
		end

		config.DLSSPreset = switch({
			[var.DLSSPreset.A] = var.DLSSPreset.C,
			[var.DLSSPreset.C] = var.DLSSPreset.E,
			[var.DLSSPreset.E] = var.DLSSPreset.F,
			[var.DLSSPreset.F] = var.DLSSPreset.G,
			[var.DLSSPreset.G] = var.DLSSPreset.A,
		}, config.DLSSPreset, var.DLSSPreset.E)
		__log('DLSS preset cycled to ' .. tostring(config.DLSSPreset))
		pushDLSSPreset()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.Reflex, {ModifierKey.CONTROL}, function()
		if not config.EnableModGranularControl then
			return
		end

		config.Reflex = not config.Reflex
		pushReflex()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.HDR, {ModifierKey.CONTROL}, function()
		if not config.EnableModGranularControl then
			return
		end

		__log((config.HDR and 'Disabling' or 'Enabling') .. ' HDR')
		config.HDR = not config.HDR
		pushHDR()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.ReflectionQuality, function()
		if not config.EnableModGranularControl then
			return
		end

		config.ReflectionQuality = switch({
			[var.ReflectionQuality.HIGH] = var.ReflectionQuality.ULTRA,
			[var.ReflectionQuality.ULTRA] = var.ReflectionQuality.VANILLA,
			[var.ReflectionQuality.VANILLA] = var.ReflectionQuality.HIGH,
		}, config.ReflectionQuality, var.ReflectionQuality.VANILLA)
		__log('Reflection quality cycled to ' .. tostring(config.ReflectionQuality))
		pushReflectionQuality()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.LumenPercent, function()
		if not config.EnableModGranularControl then
			return
		end

		config.LumenPercent = switch({
			[var.LumenPercent.QUALITY] = var.LumenPercent.ULTRAQUALITY,
			[var.LumenPercent.ULTRAQUALITY] = var.LumenPercent.FULL,
			[var.LumenPercent.FULL] = var.LumenPercent.ULTRAPERF,
			[var.LumenPercent.ULTRAPERF] = var.LumenPercent.PERFORMANCE,
			[var.LumenPercent.PERFORMANCE] = var.LumenPercent.BALANCED,
			[var.LumenPercent.BALANCED] = var.LumenPercent.QUALITY,
		}, config.LumenPercent, var.LumenPercent.QUALITY)
		__log('Screen percentage cycled to ' .. tostring(config.DLSSPercent))
		pushLumenPercent()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.ReflectionBias, function()
		if not config.EnableModGranularControl then
			return
		end

		config.ReflectionBias = switch({
			[var.ReflectionBias.VANILLA] = var.ReflectionBias.LIGHT,
			[var.ReflectionBias.LIGHT] = var.ReflectionBias.MEDIUM,
			[var.ReflectionBias.MEDIUM] = var.ReflectionBias.HIGH,
			[var.ReflectionBias.HIGH] = var.ReflectionBias.VANILLA,
		}, config.ReflectionBias, var.ReflectionBias.VANILLA)
		__log('Reflection bias cycled to ' .. tostring(config.ReflectionBias))
		pushReflectionBias()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.GameQualityPreset, {ModifierKey.CONTROL}, function()
		if not config.EnableModGranularControl then
			return
		end

		config.GameQualityPreset = switch({
			[var.GameQualityPreset.LOW] = var.GameQualityPreset.MEDIUM,
			[var.GameQualityPreset.MEDIUM] = var.GameQualityPreset.HIGH,
			[var.GameQualityPreset.HIGH] = var.GameQualityPreset.EPIC,
			[var.GameQualityPreset.EPIC] = var.GameQualityPreset.LOW,
		}, config.GameQualityPreset, var.GameQualityPreset.LOW)
		__log('GameQualityPreset cycled to ' .. tostring(config.GameQualityPreset))
		pushGameQualityPreset()
		saveConfig()
	end)

	RegisterKeyBind(shortcut.EnableFGCutscenes, {ModifierKey.CONTROL}, function()
		if not config.EnableModGranularControl then
			return
		end

		__log((config.EnableFGCutscenes and 'Disabling' or 'Enabling') .. ' EnableFGCutscenes')
		config.EnableFGCutscenes = not config.EnableFGCutscenes
		pushEnableFGCutscenes()
		saveConfig()
	end)
end -- RegisterUltraKeybinds

local function pushEnableModGranularControl()
	if not config.EnableModGranularControl then
		return
	end

	if not keybindsRegistered then
	    keybindsRegistered = true	
		RegisterUltraKeybinds()
	end
end

RegisterKeyBind(shortcut.EnableModGranularControl, {ModifierKey.CONTROL}, function()
	__log((config.EnableModGranularControl and 'Disabling' or 'Enabling') .. ' EnableModGranularControl')
	config.EnableModGranularControl = not config.EnableModGranularControl
	pushEnableModGranularControl()
	saveConfig()
end)

local function restoreConfig()
	__log('Restoring configuration')
	pushDenoiser()
	pushVignette()
	pushDLSSPreset()
	pushReflex()
	pushHDR()
	pushReflectionQuality()
	pushLumenPercent()
	pushReflectionBias()
	pushGameQualityPreset()
	pushEnableFGCutscenes()
	pushEnableModGranularControl()
end

-- these need to be below restoreConfig
local function pushUltraPlusQuality()
	if config.EnableModGranularControl then
		__log("Ignoring UltraPlusQuality change because EnableModGranularControl is enabled")
		return
	end

	local quality = UltraPlusQualityPresets.HIGH

	local switchQuality = {
		[var.UltraPlusQuality.LOW] = function()
			quality = UltraPlusQualityPresets.LOW
		end,
		[var.UltraPlusQuality.MEDIUM] = function()
			quality = UltraPlusQualityPresets.MEDIUM
		end,
		[var.UltraPlusQuality.HIGH] = function()
			quality = UltraPlusQualityPresets.HIGH
		end,
		[var.UltraPlusQuality.ULTRA] = function()
			quality = UltraPlusQualityPresets.ULTRA
		end,
	}

	switchQuality[config.UltraPlusQuality]()

	-- config.DLSSPreset = quality.DLSSPreset TODO should we set this
	config.LumenPercent = quality.LumenPercent
	config.Denoiser = quality.Denoiser
	config.ReflectionQuality = quality.ReflectionQuality
	config.ReflectionBias = quality.ReflectionBias
	config.GameQualityPreset = quality.GameQualityPreset
	config.EnableFGCutscenes = quality.EnableFGCutscenes

	-- since we are changing many variables just call restoreConfig
	restoreConfig()
end

RegisterKeyBind(shortcut.UltraPlusQuality, {ModifierKey.CONTROL}, function()
	config.UltraPlusQuality = switch({
		[var.UltraPlusQuality.LOW] = var.UltraPlusQuality.MEDIUM,
		[var.UltraPlusQuality.MEDIUM] = var.UltraPlusQuality.HIGH,
		[var.UltraPlusQuality.HIGH] = var.UltraPlusQuality.ULTRA,
		[var.UltraPlusQuality.ULTRA] = var.UltraPlusQuality.LOW,
	}, config.UltraPlusQuality, var.UltraPlusQuality.LOW)

	__log("Loading UltraPlusQuality of " .. config.UltraPlusQuality)
	pushUltraPlusQuality()
	saveConfig()
end)

local function initUltraExtensions()
	if isInitialized then
		return
	end

	loadConfig()
	restoreConfig()
	pushUltraPlusQuality()
	isInitialized = true
end

local init = false
local function delayedInjection()
	if not init then
		init = true	
		__log("injected")
		ExecuteWithDelay(100, function()
			__log("init")
			initUltraExtensions()
			validateInis(true)
		end)
	end
end

NotifyOnNewObject('/Script/Engine.Level', function()
	delayedInjection()
end)

local fgCutsceneDebounce = false
local function overrideCutsceneFg()
	if fgCutsceneDebounce then
		return
	end

	fgCutsceneDebounce = true

	ExecuteWithDelay(100, function()
		if config.EnableFGCutscenes then
			setCVar(frameGenerationCvar, frameGenerationCvarEnableValue)
			__log("OVERRIDE CUTSCENE DLSSG")
		end
		-- DISABLED - we could still set this to 100% for cutscenes if we want to try that
		-- setCVar('r.ScreenPercentage', tostring(config.LumenPercent * 100))
		fgCutsceneDebounce = false
	end)
end

NotifyOnNewObject('/Script/MovieScene.MovieSceneSequencePlayer', function ()
	overrideCutsceneFg()
end)