function LoadScalability(config)
	return ReadIni{config, isScalability=true}
end

function LoadIni(config)
	return ReadIni{config, isScalability=false}
end

function SplitString(inputstr, sep)
	if sep == nil then
	  sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
	  table.insert(t, str)
	end
	return t
end

function ReadIni(input)
	setmetatable(input,{__index={config='',isScalability=false}})
	local config = input[1] or input.config
	local isScalability = input.isScalability

	local file = io.open(config, 'r')
	if not file then
		error(string.format("could not read file at path %s \n", config))
	end

	local iniData = {}
	local category

	local scalabilityGroup

	for line in file:lines() do
		line = line:match('^%s*(.-)%s*$') -- trim whitespace

		if line == '' or string.sub(line, 1, 1) == ';' then
			goto continue
		end

		local currentCategory = line:match('%[(.+)%]') -- match category lines
		if currentCategory then
			-- if we are loading scalability there is a nested table indexed by the scalability group index, else treat all values singular groups
			if isScalability then
				local split = SplitString(currentCategory, '@')
				currentCategory = split[1]
				category = currentCategory
				scalabilityGroup = split[2]

				if scalabilityGroup then
					iniData[currentCategory] = iniData[currentCategory] or {}
					iniData[currentCategory][scalabilityGroup] = {}
				end
			else
				category = currentCategory
				iniData[category] = iniData[category] or {}
			end
			goto continue
		end

		if isScalability and not scalabilityGroup then
			goto continue
		end

		local item, value = line:match('([^=]+)%s*=%s*([^;]+)') -- match items and values, ignore comments
		if item and value then
			item = item:match('^%s*(.-)%s*$')
			value = value:match('^%s*(.-)%s*$')

			if isScalability then
				iniData[category][scalabilityGroup][item] = value
			else
				iniData[category][item] = value
			end
			-- local success, result = pcall(Cyberpunk.SetOption, category, item, value)
			if not success then
				-- Logger.info('SetOption failed:', result)
			end
		end

		::continue::
	end
	file:close()

	return iniData
end