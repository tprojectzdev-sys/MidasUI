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
	}
end

function Config:Path(library)
	local folder = library._configFolder or "MidasUI"
	local fileName = library._configFile or "config.json"
	return folder, folder .. "/" .. fileName
end

function Config:IsAvailable()
	local files = fileFunctions()
	return files.writefile ~= nil and files.readfile ~= nil and files.isfile ~= nil
end

function Config:Save(library)
	local files = fileFunctions()
	if not (files.writefile and files.readfile and files.isfile) then
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

	local folder, path = self:Path(library)
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
		Flags = library.Flags,
		Window = library._windowSettings or {},
	}

	local encoded = HttpService:JSONEncode(payload)
	local ok, err = pcall(function()
		files.writefile(path, encoded)
	end)

	return ok, err
end

function Config:Load(library)
	local files = fileFunctions()
	if not (files.readfile and files.isfile) then
		return false, "File functions are not available"
	end

	local _, path = self:Path(library)
	local exists = false
	pcall(function()
		exists = files.isfile(path)
	end)

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
			library:SetFlag(flag, value, false)
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

return Config
