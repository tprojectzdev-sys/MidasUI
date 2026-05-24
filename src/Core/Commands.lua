local Commands = {}

local function lower(value)
	return string.lower(tostring(value or ""))
end

local function objectExists(object, kind)
	if not object or object.Destroyed or object.Closed then
		return false
	end

	if kind == "Window" then
		return object.Gui ~= nil and object.Gui.Parent ~= nil
	elseif kind == "Tab" then
		return object.Button ~= nil and object.Button.Parent ~= nil
	elseif kind == "Section" then
		return object.Frame ~= nil and object.Frame.Parent ~= nil
	end

	return object.Instance ~= nil and object.Instance.Parent ~= nil
end

local function isLiveObject(object, kind)
	if not objectExists(object, kind) then
		return false
	end
	if kind == "Tab" then
		return object.Button.Visible
	elseif kind == "Section" then
		return object.Frame.Visible and (not object.Tab.Button or object.Tab.Button.Visible)
	elseif kind ~= "Window" then
		local section = object.Section
		local tab = section and section.Tab
		return object.Instance.Visible
			and (not section or section.Frame.Visible)
			and (not tab or not tab.Button or tab.Button.Visible)
	end
	return true
end

local function getTitle(object, kind)
	if kind == "Window" then
		return object.Title or "Window"
	end
	return object.Name or kind
end

local function getDescription(object, kind)
	if kind == "Window" then
		return object.Subtitle or "Open window"
	elseif kind == "Tab" then
		return "Open tab in " .. tostring(object.Window and object.Window.Title or "window")
	elseif kind == "Section" then
		return "Open section in " .. tostring(object.Tab and object.Tab.Name or "tab")
	end

	local section = object.Section
	return "Find control in " .. tostring(section and section.Name or "section")
end

local function searchableText(result)
	local keywords = result.Keywords
	if typeof(keywords) == "table" then
		keywords = table.concat(keywords, " ")
	end

	return lower(result.Title)
		.. " "
		.. lower(result.Description)
		.. " "
		.. lower(result.Category)
		.. " "
		.. lower(keywords)
end

local function fuzzyContains(text, token)
	local index = 1
	for character in string.gmatch(token, ".") do
		local found = string.find(text, character, index, true)
		if not found then
			return false
		end
		index = found + 1
	end
	return true
end

local function rank(result, query)
	if query == "" then
		return result.Type == "Command" and 20 or 1
	end

	local title = lower(result.Title)
	local text = searchableText(result)
	local total = 0
	for token in string.gmatch(query, "%S+") do
		local found = string.find(text, token, 1, true)
		if found then
			total = total + 24
			if string.find(title, token, 1, true) == 1 then
				total = total + 20
			elseif string.find(title, token, 1, true) then
				total = total + 8
			end
		elseif fuzzyContains(text, token) then
			total = total + 4
		else
			return nil
		end
	end

	if result.Type == "Command" then
		total = total + 3
	end
	return total
end

function Commands:Init(library)
	library._commands = library._commands or {}
	library._searchItems = library._searchItems or {}
	library._commandSequence = library._commandSequence or 0
	library._searchSequence = library._searchSequence or 0
end

function Commands:Register(library, options)
	self:Init(library)
	if typeof(options) ~= "table" then
		library:_Warn("Command", "RegisterCommand expected an options table")
		return nil
	end

	local title = options.Title or options.Name
	local action = options.Callback or options.Action
	if typeof(title) ~= "string" or title == "" then
		library:_Warn("Command", "RegisterCommand ignored: Title or Name must be a non-empty string")
		return nil
	end
	if typeof(action) ~= "function" then
		library:_Warn("Command", "RegisterCommand ignored '" .. title .. "': callback/action must be a function")
		return nil
	end

	local id = options.Id
	if id ~= nil and (typeof(id) ~= "string" or id == "") then
		library:_Warn("Command", "RegisterCommand ignored '" .. title .. "': Id must be a non-empty string")
		return nil
	end
	if id == nil then
		library._commandSequence = library._commandSequence + 1
		id = "command_" .. library._commandSequence
	end
	if library._commands[id] then
		library:_Warn("Command", "RegisterCommand ignored duplicate Id '" .. id .. "'")
		return nil
	end

	local keywords = options.Keywords
	if typeof(keywords) == "table" then
		local normalized = {}
		for _, keyword in ipairs(keywords) do
			table.insert(normalized, tostring(keyword))
		end
		keywords = normalized
	elseif keywords ~= nil and typeof(keywords) ~= "string" then
		library:_Warn("Command", "RegisterCommand ignored invalid Keywords on '" .. title .. "'")
		keywords = nil
	end

	local controller = { Id = id }
	local record = {
		Id = id,
		Type = "Command",
		Title = title,
		Description = tostring(options.Description or ""),
		Category = tostring(options.Category or "Actions"),
		Keywords = keywords,
		Action = action,
		CloseOnRun = options.CloseOnRun ~= false,
		Owner = options.Owner,
		Controller = controller,
	}

	function controller:Unregister()
		library:UnregisterCommand(id)
		return self
	end

	function controller:Run()
		library:RunCommand(id)
		return self
	end

	library._commands[id] = record
	return controller
end

function Commands:Unregister(library, idOrController)
	self:Init(library)
	local id = typeof(idOrController) == "table" and idOrController.Id or idOrController
	if typeof(id) ~= "string" or library._commands[id] == nil then
		return false
	end
	library._commands[id] = nil
	return true
end

function Commands:RemoveOwner(library, owner)
	self:Init(library)
	for id, command in pairs(library._commands) do
		if command.Owner == owner then
			library._commands[id] = nil
		end
	end
end

function Commands:Execute(library, idOrResult)
	self:Init(library)
	local result = idOrResult
	if typeof(idOrResult) == "string" then
		result = library._commands[idOrResult]
	end
	if not result then
		library:_Warn("Command", "Attempted to execute a missing command")
		return false, true
	end

	if result.Type == "Command" then
		if result.Owner and (result.Owner.Destroyed or result.Owner.Closed) then
			self:Unregister(library, result.Id)
			library:_Warn("Command", "Ignored command whose owner was destroyed: " .. result.Title)
			return false, true
		end
		library:_InvokeCallback("Command", result.Action, result.Controller)
		return true, result.CloseOnRun
	end

	return self:Navigate(library, result), true
end

function Commands:IndexObject(library, object, kind)
	self:Init(library)
	if not object or object._midasSearchId then
		return
	end

	library._searchSequence = library._searchSequence + 1
	local id = "item_" .. library._searchSequence
	object._midasSearchId = id
	library._searchItems[id] = {
		Id = id,
		Type = kind,
		Object = object,
	}

	if typeof(object.Destroy) == "function" and not object._midasSearchWrapped then
		object._midasSearchWrapped = true
		local originalDestroy = object.Destroy
		object.Destroy = function(target, ...)
			local result = originalDestroy(target, ...)
			Commands:RemoveObject(library, target)
			return result
		end
	end
end

function Commands:RemoveObject(library, object)
	self:Init(library)
	if object and object._midasSearchId then
		library._searchItems[object._midasSearchId] = nil
		object._midasSearchId = nil
	end
	self:RemoveOwner(library, object)
end

function Commands:Navigate(library, result)
	local object = result and result.Object
	local kind = result and result.Type
	if not isLiveObject(object, kind) then
		library:_Warn("Search", "Navigation target is no longer available")
		return false
	end

	local window
	local tab
	if kind == "Window" then
		window = object
	elseif kind == "Tab" then
		window = object.Window
		tab = object
	elseif kind == "Section" then
		tab = object.Tab
		window = tab and tab.Window
	else
		local section = object.Section
		tab = section and section.Tab
		window = tab and tab.Window
	end

	if window then
		window:Show()
		window:Restore()
	end
	if tab and window then
		window:SelectTab(tab)
	end

	if kind == "Dropdown" and object.Enabled ~= false and object.SetExpanded then
		object:SetExpanded(true)
	end

	if tab and object ~= tab then
		local guiObject = kind == "Section" and object.Frame or object.Instance
		if guiObject and tab.Page then
			task.defer(function()
				if guiObject.Parent and tab.Page.Parent then
					local targetY = tab.Page.CanvasPosition.Y + guiObject.AbsolutePosition.Y - tab.Page.AbsolutePosition.Y - 12
					local maximum = math.max(0, tab.Page.AbsoluteCanvasSize.Y - tab.Page.AbsoluteSize.Y)
					tab.Page.CanvasPosition = Vector2.new(0, math.clamp(targetY, 0, maximum))
				end
			end)
		end
	end

	return true
end

function Commands:Search(library, query, options)
	self:Init(library)
	options = typeof(options) == "table" and options or {}
	query = lower(query)
	local results = {}

	for id, command in pairs(library._commands) do
		if command.Owner and (command.Owner.Destroyed or command.Owner.Closed) then
			library._commands[id] = nil
		else
			local score = rank(command, query)
			if score then
				table.insert(results, {
					Id = command.Id,
					Type = command.Type,
					Title = command.Title,
					Description = command.Description,
					Category = command.Category,
					Keywords = command.Keywords,
					Score = score,
					_Record = command,
				})
			end
		end
	end

	if not options.CommandsOnly and (query ~= "" or options.IncludeItems == true) then
		for id, item in pairs(library._searchItems) do
			if not objectExists(item.Object, item.Type) then
				library._searchItems[id] = nil
			elseif isLiveObject(item.Object, item.Type) then
				local result = {
					Id = item.Id,
					Type = item.Type,
					Title = tostring(getTitle(item.Object, item.Type)),
					Description = getDescription(item.Object, item.Type),
					Category = "Navigate",
					Keywords = item.Type,
					_Record = item,
				}
				local score = rank(result, query)
				if score then
					result.Score = score
					table.insert(results, result)
				end
			end
		end
	end

	table.sort(results, function(left, right)
		if left.Score == right.Score then
			return left.Title < right.Title
		end
		return left.Score > right.Score
	end)
	return results
end

return Commands
