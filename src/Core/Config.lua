local HttpService = game:GetService("HttpService")

local Config = {}

local function callable(name)
	local env = type(getgenv) == "function" and getgenv() or getfenv()
	local value = env[name]
	return type(value) == "function" and value or nil
end

local function fileFunctions()
	return {
		writefile = callable("writefile"),
		readfile = callable("readfile"),
		isfile = callable("isfile"),
		makefolder = callable("makefolder"),
		isfolder = callable("isfolder"),
		listfiles = callable("listfiles"),
		delfile = callable("delfile"),
		deletefile = callable("deletefile"),
	}
end

function Config:SanitizeProfile(profile)
	local name = tostring(profile or "default")
	name = string.gsub(name, "[^%w_%-]", "_")
	name = string.gsub(name, "_+", "_")

	if name == "" or name == "_" then
		name = "default"
	end

	return name
end

function Config:Path(library, profile)
	local folder = library._configFolder or "MidasUI"
	local profileName = self:SanitizeProfile(profile)
	local fileName = profileName .. ".json"
	return folder, folder .. "/" .. fileName
end

function Config:IsAvailable()
	local files = fileFunctions()
	return files.writefile ~= nil and files.readfile ~= nil and files.isfile ~= nil
end

function Config:SerializeValue(value)
	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value.Name
	end

	if typeof(value) == "EnumItem" then
		return {
			__MidasType = "EnumItem",
			EnumType = tostring(value.EnumType),
			Name = value.Name,
		}
	end

	if typeof(value) == "table" then
		local serialized = {}
		for key, child in pairs(value) do
			serialized[key] = self:SerializeValue(child)
		end
		return serialized
	end

	return value
end

function Config:DeserializeValue(value)
	if typeof(value) == "table" then
		if value.__MidasType == "EnumItem" and value.EnumType == "Enum.KeyCode" and typeof(value.Name) == "string" then
			local ok, keyCode = pcall(function()
				return Enum.KeyCode[value.Name]
			end)
			return ok and keyCode or nil
		end

		local decoded = {}
		for key, child in pairs(value) do
			decoded[key] = self:DeserializeValue(child)
		end
		return decoded
	end

	return value
end

function Config:SerializeFlags(flags)
	local serialized = {}
	for flag, value in pairs(flags or {}) do
		serialized[flag] = self:SerializeValue(value)
	end
	return serialized
end

function Config:Save(library, profile)
	local files = fileFunctions()
	if not files.writefile then
		return false, "File functions are not available"
	end

	local window = library._activeWindow
	if window and window.Main then
		local size = window._restoreSize or window.Main.Size
		library._windowSettings = {
			Minimized = window.Minimized == true,
			Size = {
				X = size.X.Offset,
				Y = size.Y.Offset,
			},
		}
	end

	local folder, path = self:Path(library, profile)
	if files.makefolder then
		local ok = true
		if files.isfolder then
			ok = pcall(function()
				return files.isfolder(folder)
			end)
		end

		if ok then
			pcall(function()
				files.makefolder(folder)
			end)
		end
	end

	local payload = {
		Version = library.Version,
		Theme = library.ThemeName,
		Flags = self:SerializeFlags(library.Flags),
		Window = library._windowSettings or {},
	}

	local encoded = HttpService:JSONEncode(payload)
	local ok, err = pcall(function()
		files.writefile(path, encoded)
	end)

	return ok, err
end

function Config:Load(library, profile)
	local files = fileFunctions()
	if not (files.readfile and files.isfile) then
		return false, "File functions are not available"
	end

	local folder, path = self:Path(library, profile)
	local exists = false
	pcall(function()
		exists = files.isfile(path)
	end)

	if not exists and profile == nil then
		local legacyPath = folder .. "/" .. (library._configFile or "config.json")
		pcall(function()
			exists = files.isfile(legacyPath)
		end)

		if exists then
			path = legacyPath
		end
	end

	if not exists then
		return false, "Config file does not exist"
	end

	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(files.readfile(path))
	end)

	if not ok or typeof(decoded) ~= "table" then
		return false, "Config JSON could not be decoded"
	end

	if typeof(decoded.Flags) == "table" then
		for flag, value in pairs(decoded.Flags) do
			library:SetFlag(flag, self:DeserializeValue(value), false)
		end
	end

	if typeof(decoded.Theme) == "string" then
		library:SetTheme(decoded.Theme)
	end

	if typeof(decoded.Window) == "table" then
		library._windowSettings = decoded.Window
		local window = library._activeWindow

		if window and window.Main then
			local size = decoded.Window.Size
			if typeof(size) == "table" and tonumber(size.X) and tonumber(size.Y) then
				window.Main.Size = UDim2.fromOffset(size.X, size.Y)
			end

			if decoded.Window.Minimized == true then
				task.defer(function()
					if window.Main and window.Main.Parent then
						window:SetMinimized(true)
					end
				end)
			end
		end
	end

	return true
end

function Config:Delete(library, profile)
	local files = fileFunctions()
	local delete = files.delfile or files.deletefile
	if not (files.isfile and delete) then
		return false, "Delete file function is not available"
	end

	local _, path = self:Path(library, profile)
	local exists = false
	pcall(function()
		exists = files.isfile(path)
	end)

	if not exists then
		return false, "Config file does not exist"
	end

	local ok, err = pcall(function()
		delete(path)
	end)

	return ok, err
end

function Config:List(library)
	local files = fileFunctions()
	if not files.listfiles then
		return {}
	end

	local folder = library._configFolder or "MidasUI"
	local ok, results = pcall(function()
		return files.listfiles(folder)
	end)

	if not ok or typeof(results) ~= "table" then
		return {}
	end

	local profiles = {}
	for _, path in ipairs(results) do
		local name = tostring(path):match("([^/\\]+)%.json$")
		if name then
			table.insert(profiles, name)
		end
	end

	table.sort(profiles)
	return profiles
end

return Config
