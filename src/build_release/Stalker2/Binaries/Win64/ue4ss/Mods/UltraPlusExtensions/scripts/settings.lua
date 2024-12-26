UltraSettings = {}

function applySetting(setting, current, setFunction)
    if current ~= 'game' and setting.Modified then
        for k,v in pairs(setting.Commands[string.upper(current)]) do
            setFunction(v[1], v[2], setting.FirstDelay)
        end
    end

    setting.FirstDelay = 0
    setting.Modified = false
end

function applyCustomSetting(setting, current, setFunction)
    if current ~= 'game' and setting.Modified then
        for k,v in pairs(setting.Commands[string.upper(current)]) do
            setFunction(v[1], v[2])
        end
    end

    setting.Modified = false
end

UltraSettings.settings = {
    ChromaticAberration = {
        Comment = 'game/off/on; off is recommended due to the games implementation of chromatic aberration - it just blurs the image',
        Commands = { GAME = {{}},
                     OFF = {{'r.SceneColorFringeQuality', '0'}}, 
                     ON =  {{'r.SceneColorFringeQuality', '1'}}},
        UserSettings = { OFF = 'off', ON = 'on'},
        UserSettingsOrder = { a = 'off', b = 'on' },
        CurrentSetting = 'game',
        FirstDelay = 0,
        Modified = true,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.ChromaticAberration, UltraSettings.settings.ChromaticAberration.CurrentSetting, setFunction)
        end
    },

    Denoiser = {
        Comment = 'game/none/temporal/rayreconstruction',
        Commands = { GAME = {{}},
                     NONE = {{'r.NGX.DLSS.DenoiserMode', '0'},
                             {'r.Lumen.Reflections.Temporal', '0'}},
                     TEMPORAL = {{'r.NGX.DLSS.DenoiserMode', '0'},
                                 {'r.Lumen.Reflections.Temporal', '1'}}, 
                     RAYRECONSTRUCTION = {{'r.NGX.DLSS.DenoiserMode', '1'},
                                          {'r.Lumen.Reflections.Temporal', '0'}}},
        UserSettings = { NONE = 'none', TEMPORAL = 'temporal', RAYRECONSTRUCTION = 'rayreconstruction'},
        UserSettingsOrder = { a = 'none', b = 'temporal', c = 'rayreconstruction'},
        CurrentSetting = 'game',
        FirstDelay = 10000,
        Modified = true,
        Shortcut = 'F2',
        ShortcutCtrlModifier = false,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.Denoiser, UltraSettings.settings.Denoiser.CurrentSetting, setFunction)
        end
    },

    DLSSPreset = {
        Comment = 'game/a/c/e/f/g',
        Commands = { GAME = {{}},
                     A = {{'r.NGX.DLSS.Preset', '1'}},
                     C = {{'r.NGX.DLSS.Preset', '3'}},
                     E = {{'r.NGX.DLSS.Preset', '5'}},
                     F = {{'r.NGX.DLSS.Preset', '6'}},
                     G = {{'r.NGX.DLSS.Preset', '7'}}},
        UserSettings = { A = 'a', C = 'c', E = 'E', F = 'f', G = 'g'},
        UserSettingsOrder = { a = 'a', b = 'c', c = 'e', d = 'f', e = 'g'},
        CurrentSetting = 'game',
        FirstDelay = 0,
        Modified = true,
        Shortcut = 'F6',
        ShortcutCtrlModifier = false,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.DLSSPreset, UltraSettings.settings.DLSSPreset.CurrentSetting, setFunction)
        end
    },

    EnableKeybinds = {
        Comment = 'off/on; off disables all keybinds except for F12 which loads the current configuration file in game - can be toggled on in-game by setting to on in config and pressing F12',
        Commands = { OFF = {{ 'Keybinds', '0'}},
                     ON = {{'Keybinds', '1'}}},
        CurrentSetting = 'off',
        UserSettings = { OFF = 'off', ON = 'on'},
        UserSettingsOrder = { a = 'off', b = 'on' },
        ApplyCustom = function(setFunction)
            applyCustomSetting(UltraSettings.settings.EnableKeybinds, UltraSettings.settings.EnableKeybinds.CurrentSetting, setFunction)
        end
    },

    GameQualityPreset = {
        Comment = 'low/medium/high/epic; this is separate from the game graphics menus - set to the same as your in-game graphics quality',
        Commands = { LOW = {{ 'Scalability', '0'}},
                     MEDIUM = {{'Scalability', '1'}},
                     HIGH = {{'Scalability', '2'}},
                     EPIC = {{'Scalability', '3'}}},
        UserSettings = { LOW = 'low', MEDIUM = 'medium', HIGH = 'high', EPIC = 'epic' },
        UserSettingsOrder = { a = 'low', b = 'medium', c = 'high', d = 'epic' },
        CurrentSetting = 'high',
        FirstDelay = 0,
        Modified = true,
        Shortcut = 'F10',
        ShortcutCtrlModifier = true,
        Apply = function(setFunction)
        end,
        -- not a UE engine call, handled by main
        ApplyCustom = function(setFunction)
            applyCustomSetting(UltraSettings.settings.GameQualityPreset, UltraSettings.settings.GameQualityPreset.CurrentSetting, setFunction)
        end
    },
    
    HDR = {
        Comment = 'game/off/on; this setting provides a mechanism for using HDR in borderless fullscreen which the game does not support by default',
        Commands = { GAME = {{}},
                     OFF = {{'r.AllowHDR', '0'},
                            {'r.HDR.EnableHDROutput', '0'},
                            {'r.HDR.Display.OutputDevice', '0'},
                            {'r.HDR.Display.ColorGamut', '0'},
                            {'r.HDR.UI.CompositeMode', '0',}}, 
                     ON = {{'r.AllowHDR', '1'},
                           {'r.HDR.EnableHDROutput', '1'},
                           {'r.HDR.Display.OutputDevice', '3'},
                           {'r.HDR.Display.ColorGamut', '2'},
                           {'r.HDR.UI.CompositeMode', '1',}}},
        UserSettings = { OFF = 'off', ON = 'on' },
        UserSettingsOrder = { a = 'off', b = 'on' },
        CurrentSetting = 'game',
        FirstDelay = 0,
        Modified = true,
        Shortcut = 'F8',
        ShortcutCtrlModifier = true,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.HDR, UltraSettings.settings.HDR.CurrentSetting, setFunction)
        end
    },

    LightShafts = {
        Comment = 'game/off/on',
        Commands = { GAME = {{}},
                     OFF = {{'r.LightShaftQuality', '0'}}, 
                     ON =  {{'r.LightShaftQuality', '1'}}},
        UserSettings = { OFF = 'off', ON = 'on' },
        UserSettingsOrder = { a = 'off', b = 'on' },
        CurrentSetting = 'game',
        FirstDelay = 0,
        Modified = true,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.LightShafts, UltraSettings.settings.LightShafts.CurrentSetting, setFunction)
        end
    },

    MotionBlur = {
        Comment = 'game/off/low/medium/high',
        Commands = { GAME = {{}},
                     OFF = {{'r.MotionBlur.Amount', '0'}}, 
                     LOW = {{'r.MotionBlur.Amount', '0.2'}},
                     MEDIUM = {{'r.MotionBlur.Amount', '0.4'}},
                     HIGH = {{'r.MotionBlur.Amount', '0.6'}}},
        UserSettings = { OFF = 'off', LOW = 'low', MEDIUM = 'medium', HIGH = 'high' },
        UserSettingsOrder = { a = 'off', b = 'low', c = 'medium', d = 'high' },
        CurrentSetting = 'game',
        FirstDelay = 0,
        Modified = true,
        Shortcut = 'F4',
        ShortcutCtrlModifier = false,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.MotionBlur,  UltraSettings.settings.MotionBlur.CurrentSetting, setFunction)
        end
    },

    ReflectionBias = {
        Comment = 'game/off/low/medium/high; controls smoothness of reflective surfaces - some bias is preferred for visual quality',
        Commands = { GAME = {{}},
                     OFF = {{'r.Lumen.Reflections.SmoothBias', '0'}}, 
                     LOW = {{'r.Lumen.Reflections.SmoothBias', '0.2'}},
                     MEDIUM = {{'r.Lumen.Reflections.SmoothBias', '0.4'}},
                     HIGH = {{'r.Lumen.Reflections.SmoothBias', '0.6'}}},
        UserSettings = { OFF = 'off', LOW = 'low', MEDIUM = 'medium', HIGH = 'high' },
        UserSettingsOrder = { a = 'off', b = 'low', c = 'medium', d = 'high' },
        CurrentSetting = 'game',
        FirstDelay = 0,
        Modified = true,
        Shortcut = 'F9',
        ShortcutCtrlModifier = false,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.ReflectionBias,  UltraSettings.settings.ReflectionBias.CurrentSetting, setFunction)
        end
    },

    ReflectionQuality = {
        Comment = 'game/vanilla/high/ultra; maximum roughness of surfaces considered to be reflective - a higher quality means more surfaces will be included in reflections',
        Commands = { GAME = {{}}, 
                     VANILLA = {{'r.Lumen.Reflections.MaxRoughnessToTrace', '0.4'}},
                     HIGH = {{'r.Lumen.Reflections.MaxRoughnessToTrace', '0.55'}},
                     ULTRA = {{'r.Lumen.Reflections.MaxRoughnessToTrace', '0.86'}}},
        UserSettings = { VANILLA = 'vanilla', HIGH = 'high', ULTRA = 'ultra' },
        UserSettingsOrder = { a = 'vanilla', b = 'high', c = 'ultra' },
        CurrentSetting = 'game',
        FirstDelay = 0,
        Modified = true,
        Shortcut = 'F10',
        ShortcutCtrlModifier = false,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.ReflectionQuality,  UltraSettings.settings.ReflectionQuality.CurrentSetting, setFunction)
        end
    },

    Reflex = {
        Comment = 'game/off/on; enables reflex low latency with boost - the game does not support this by default',
        Commands = { GAME = {{}},
                     OFF = {{'t.Streamline.Reflex.Enable', '0'}}, 
                     ON =  {{'t.Streamline.Reflex.Enable', '1'},
                            {'t.Streamline.Reflex.Mode', '2'}}},
        UserSettings = { OFF = 'off', ON = 'on' },
        UserSettingsOrder = { a = 'off', b = 'on' },
        CurrentSetting = 'game',
        FirstDelay = 5000,
        Modified = true,
        Shortcut = 'F6',
        ShortcutCtrlModifier = true,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.LightShafts, UltraSettings.settings.LightShafts.CurrentSetting, setFunction)
        end
    },

    Vignette = {
        Comment = 'game/off/on',
        Commands = { GAME = {{}},
                     OFF = {{'r.Tonemapper.Quality', '1'}}, 
                     ON = {{'r.Tonemapper.Quality', '5'}}},
        UserSettings = { OFF = 'off', ON = 'on'},
        UserSettingsOrder = { a = 'off', b = 'on' },
        CurrentSetting = 'game',
        FirstDelay = 0,
        Modified = true,
        Shortcut = 'F3',
        ShortcutCtrlModifier = false,
        Apply = function(setFunction)
            applySetting(UltraSettings.settings.Vignette, UltraSettings.settings.Vignette.CurrentSetting, setFunction)
        end
    }
}

function UltraSettings.write(ini_path)
    local file = io.open(ini_path, 'w')

    header	 = [[
; In-game keybinds are disabled by default, set EnableKeybinds=on below to enable them on game start - or it can be turned on in game
; Press F12 to load the current configuration file while in-game - you can now edit the configuration file and load the changes while in-game
; If a setting does not specify a keybind, then it can only be changed via the configuration file
; The 'game' option for settings below tells Ultra Plus to leave the setting at game default

]]

    file:write(header)

    local function writeSetting(k)
        if UltraSettings.settings[k].ShortcutCtrlModifier then
            file:write('; CTRL + ' .. UltraSettings.settings[k].Shortcut .. '\n')
        elseif UltraSettings.settings[k].Shortcut then
            file:write('; ' .. UltraSettings.settings[k].Shortcut .. '\n')
        end

        file:write('; ' .. UltraSettings.settings[k].Comment .. '\n')
        file:write(tostring(k) .. '=' .. UltraSettings.settings[k].CurrentSetting .. '\n\n')
    end

    UltraSettings.iterateSortedSettings(writeSetting)

    file:close()
end

function UltraSettings.read(ini_path)
    local file = io.open(ini_path, 'r')

    -- create file with defaults if it doesnt exist
    if not file then
        UltraSettings.write(ini_path)
        return
    end

    for line in file:lines() do
		-- strip anything after ';' and trim excess spaces
		local cleanLine = line:match('^[^;]*'):gsub('^%s*(.-)%s*$', '%1')

		-- only process line if not empty after removing comments
		if cleanLine ~= '' then
			for key, value in cleanLine:gmatch('([^=]+)%s*=%s*(.+)') do
				key = key:match('^%s*(.-)%s*$')						-- trim whitespace
				value = string.lower(value:match('^%s*(.-)%s*$'))	-- trim whitespace
                
                if UltraSettings.settings[key].UserSettings[string.upper(value)] ~= nil then
                    if value ~= UltraSettings.settings[key].CurrentSetting then
                        UltraSettings.settings[key].CurrentSetting = value 
                        UltraSettings.settings[key].Modified = true
                    end
                end
			end
		end
	end

    file:close()
end

function UltraSettings.applyAll(setFunction, setCustomFunction)
    local function applySetting(k)

        -- custom functions handled through main
        if UltraSettings.settings[k].ApplyCustom then
            UltraSettings.settings[k].ApplyCustom(setCustomFunction)
            return
        end

        UltraSettings.settings[k].Apply(setFunction)
    end

    UltraSettings.iterateSortedSettings(applySetting)
end

function UltraSettings.cycleCurrentSetting(setting)
    local sorted_keys = {}
    
    for k in pairs(setting.UserSettingsOrder) do table.insert(sorted_keys, k) end

    table.sort(sorted_keys)

    index = 0
    count = 0
    for i, k in pairs(sorted_keys) do
        if setting.UserSettingsOrder[k] == setting.CurrentSetting then
            index = i
        end
        count = count + 1
    end

    index = index + 1

    if index > count then
        index = 1
    end

    setting.CurrentSetting = string.lower(setting.UserSettingsOrder[sorted_keys[index]])
    setting.Modified = true
end

function UltraSettings.iterateSortedSettings(delegate)
    local sorted_keys = {}
    -- populate the table that holds the keys
    for k in pairs(UltraSettings.settings) do table.insert(sorted_keys, k) end

    table.sort(sorted_keys)

    for _, k in ipairs(sorted_keys) do
        delegate(k)
    end
end