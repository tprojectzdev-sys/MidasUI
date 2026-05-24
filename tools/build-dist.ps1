param(
	[string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$sourceRoot = Join-Path $Root "src"
$outputPath = Join-Path $Root "dist\MidasUI.lua"
$modules = @(
	"Assets/Icons",
	"Core/Utility",
	"Core/Theme",
	"Core/Flags",
	"Core/Config",
	"Core/Notify",
	"Core/Tooltip",
	"Core/Keybinds",
	"Core/Dialog",
	"Core/Window",
	"Core/Tab",
	"Core/Section",
	"Elements/Button",
	"Elements/Toggle",
	"Elements/Slider",
	"Elements/Dropdown",
	"Elements/Input",
	"Elements/Keybind",
	"Elements/Paragraph",
	"Elements/Divider"
)

$builder = [System.Text.StringBuilder]::new()
[void]$builder.AppendLine("-- MidasUI V1.5 single-file bundle")
[void]$builder.AppendLine("-- Generated from src modules by tools/build-dist.ps1. Edit src/ first.")
[void]$builder.AppendLine("local ModuleCache = {}")
[void]$builder.AppendLine("local ModuleSources = {}")

foreach ($module in $modules) {
	$sourcePath = Join-Path $sourceRoot ($module + ".lua")
	$source = [System.IO.File]::ReadAllText($sourcePath)
	[void]$builder.AppendLine(('ModuleSources["{0}"] = function()' -f $module))
	[void]$builder.Append($source.TrimEnd())
	[void]$builder.AppendLine()
	[void]$builder.AppendLine("end")
}

[void]$builder.AppendLine(@'
local function requireModule(name)
	local cached = ModuleCache[name]
	if cached then
		return cached
	end

	local source = ModuleSources[name]
	assert(source, "MidasUI bundle missing module: " .. tostring(name))
	local result = source()
	ModuleCache[name] = result
	return result
end
'@.Trim())

$initPath = Join-Path $sourceRoot "Init.lua"
$init = [System.IO.File]::ReadAllText($initPath)
$imports = @'
local Utility = requireModule("Core/Utility")
local Theme = requireModule("Core/Theme")
local Flags = requireModule("Core/Flags")
local Config = requireModule("Core/Config")
local Notify = requireModule("Core/Notify")
local Tooltip = requireModule("Core/Tooltip")
local Keybinds = requireModule("Core/Keybinds")
local Dialog = requireModule("Core/Dialog")
local Icons = requireModule("Assets/Icons")
'@
$init = [regex]::Replace(
	$init,
	'(?s)^local root =.*?local Icons = assetsFolder and require\(assetsFolder:WaitForChild\("Icons"\)\) or nil\r?\n',
	$imports + [Environment]::NewLine
)
$init = $init.Replace('require(core:WaitForChild("Window"))', 'requireModule("Core/Window")')
$init = $init.Replace('require(core:WaitForChild("Tab"))', 'requireModule("Core/Tab")')
$init = $init.Replace('require(core:WaitForChild("Section"))', 'requireModule("Core/Section")')
foreach ($element in @("Button", "Toggle", "Slider", "Dropdown", "Input", "Keybind", "Paragraph", "Divider")) {
	$init = $init.Replace(
		('require(elementsFolder:WaitForChild("{0}"))' -f $element),
		('requireModule("Elements/{0}")' -f $element)
	)
}

[void]$builder.AppendLine()
[void]$builder.Append($init.TrimEnd())
[void]$builder.AppendLine()

[System.IO.Directory]::CreateDirectory((Split-Path -Parent $outputPath)) | Out-Null
[System.IO.File]::WriteAllText($outputPath, $builder.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Output ("Generated " + $outputPath)
