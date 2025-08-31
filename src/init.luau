--!strict
--// SOURCE & LICENSE: https://github.com/blox-libs/Responsiveness

debug.setmemorycategory(script.Name)

local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera


local GUI_CONTAINERS = {"ScreenGui", "BillboardGui", "DockWidgetPluginGui", "SurfaceGui"}

local DEFAULT_RANGE = NumberRange.new(0, math.huge)
local DEFAULT_RATIO = 1
local DEFAULT_RESOLUTION = Vector2.new(1280, 720)


export type Attributes = {
	Range: NumberRange,
	Ratio: number,
	Resolution: Vector2
}

-- DockWidgetPluginGui does not exist as a type.
type DockWidgetPluginGui = ScreenGui & {
	HostWidgetWasRestored: boolean,
	Title: string,
}

export type GuiContainer = ScreenGui
| DockWidgetPluginGui
| BillboardGui
| SurfaceGui

export type Responsiveness = {
	_isTracking: boolean,
	_uiScale: UIScale,
	_guiContainer: GuiContainer?,
	_connections: {RBXScriptConnection},
	_scaleConnection: RBXScriptConnection?,
	_innerRatios: {[string]: number}?,
	 
	CleanOnDestroy: (self: Responsiveness) -> (),
	ComputeScale: (self: Responsiveness) -> number?,
	GetAttributes: (self: Responsiveness, displaySize: Enum.DisplaySize?) -> Attributes,
	GetAbsoluteSize: (self: Responsiveness) -> Vector2?,
	UpdateContainer: (self: Responsiveness) -> (),
	UpdateInnerRatios: (self: Responsiveness) -> (),
	UpdateScale: (self: Responsiveness) -> (),
	Track: (self: Responsiveness) -> (),
	UnTrack: (self: Responsiveness) -> (),
	Destroy: (self: Responsiveness) -> (),
}


local function getGuiContainer(uiScale: UIScale): GuiContainer?
	for _, GUI_CONTAINER in GUI_CONTAINERS  do
		local guiContainer = uiScale:FindFirstAncestorOfClass(GUI_CONTAINER) :: any
		if guiContainer then
			return guiContainer
		end
	end
	
	return nil
end


local Responsiveness = {}
Responsiveness.__index = Responsiveness

function Responsiveness.new(uiScale: UIScale): Responsiveness
	local self = setmetatable({}, Responsiveness) :: Responsiveness & any
	
	self._connections = {}
	self._isTracking = false
	
	self._uiScale = uiScale
	self._guiContainer = getGuiContainer(uiScale)
	
	return self
end

function Responsiveness.ComputeScale(self: Responsiveness): number?
	if not self._guiContainer then
		return nil
	end

	local attributes = self:GetAttributes(GuiService.ViewportDisplaySize)
	local size = self:GetAbsoluteSize() :: Vector2
	
	local ratio = attributes.Ratio
	local range = attributes.Range
	local resolution = attributes.Resolution

	local axis = math.min(size.X, size.Y)
	local compute = 1 / resolution.X * size.X / (1 / resolution.Y * axis)
	
	local reference = 1 / resolution.Y * math.clamp(compute, 0, 1)
	return math.clamp(reference * axis, range.Min, range.Max) * ratio
end

function Responsiveness.GetAttributes(self: Responsiveness, displaySize: Enum.DisplaySize?)
	local attributes = self._uiScale:GetAttributes() :: Attributes
	
	attributes.Range = attributes.Range or DEFAULT_RANGE
	attributes.Ratio = attributes.Ratio or DEFAULT_RATIO
	attributes.Resolution = attributes.Resolution or DEFAULT_RESOLUTION
	
	if not displaySize then
		return attributes
	end

	local innerRatios = self._innerRatios
	if not innerRatios then
		return attributes
	end

	local innerRatio = innerRatios[displaySize.Name]
	if innerRatio then
		attributes.Ratio *= innerRatio
	end
	
	return attributes
end

function Responsiveness.UpdateInnerRatios(self: Responsiveness): ()
	local innerRatios = self._uiScale:GetAttribute("InnerRatios")
	if type(innerRatios) ~= "string" then
		self._innerRatios = nil
		return
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, innerRatios)
	if not success or type(result) ~= "table" then
		self._innerRatios = nil
		return
	end
	
	self._innerRatios = result
end

function Responsiveness.UpdateContainer(self: Responsiveness): ()
	self._guiContainer = getGuiContainer(self._uiScale)
	
	if self._scaleConnection then
		self._scaleConnection:Disconnect()
		self._scaleConnection = nil
	end
	
	if self._guiContainer and self._isTracking then
		self._scaleConnection = self._guiContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self:UpdateScale()
		end)
	end
end

function Responsiveness.GetAbsoluteSize(self: Responsiveness): Vector2?
	if self._guiContainer then
		return self._guiContainer.AbsoluteSize
	end
	
	return nil
end

function Responsiveness.UpdateScale(self: Responsiveness): ()
	local compute = self:ComputeScale()
	
	if compute then
		self._uiScale.Scale = compute
	end
end

function Responsiveness.Track(self: Responsiveness)
	if self._isTracking then
		return
	end
	
	self._isTracking = true
	self:UpdateContainer()
	self:UpdateInnerRatios()
	
	RunService.RenderStepped:Once(function()
		self:UpdateScale()
	end)
	
	table.insert(self._connections, self._uiScale.AncestryChanged:Connect(function()
		self:UpdateContainer()
	end))

	table.insert(self._connections, self._uiScale.AttributeChanged:Connect(function(attribute)
		if attribute == "InnerRatios" then
			self:UpdateInnerRatios()
		end
		
		self:UpdateScale()
	end))
	
	table.insert(self._connections, GuiService:GetPropertyChangedSignal("ViewportDisplaySize"):Connect(function()
		self:UpdateScale()
	end))
end

function Responsiveness.UnTrack(self: Responsiveness)
	if not self._isTracking then
		return
	end
	
	self._isTracking = false
	
	if self._scaleConnection then
		self._scaleConnection:Disconnect()
	end
	
	for _, connection in self._connections do
		connection:Disconnect()
	end
	
	table.clear(self._connections)
end

Responsiveness.Destroy = Responsiveness.UnTrack

return Responsiveness
