# Responsiveness

A responsive UI scaling solution for Roblox, successor to QuickScale.

---

## Features

- Dynamic Ratio control  
- Constrained scaling Ranges  
- Resolution-based calculations  
- InnerRatios (Viewport display size specific scaling)  
- Automatic viewport tracking  
- Great for scaling UIStrokes, Scrollbars, AutomaticSize & AutomaticCanvasSize  

---

## Usage

1. Place a `UIScale` in a `GuiObject` (e.g. `Frame`) inside a `GuiContainer` (`ScreenGui`, `BillboardGui`, `DockWidgetPluginGui`, `SurfaceGui`).  
2. Configure attributes (see **Attribute Details**)  
3. Call `:Track()` to begin automatic scaling  

---

## Attribute Details

- **Ratio**: Base scaling multiplier. Higher values = larger UI. (default: `1`)  
- **Range**: `NumberRange(min, max)` to constrain scaling bounds. (default: `NumberRange.new(0, math.huge)`)  
- **Resolution**: `Vector2(width, height)` reference resolution for calculations. (default: `Vector2.new(1280, 720)`)  
- **InnerRatios**: JSON string mapping display sizes to ratio multipliers. (default: `{"Large": 1, "Medium": 1, "Small": 1}`) [View DisplaySize's Reference](https://create.roblox.com/docs/reference/engine/enums/DisplaySize)

## Example: 
```lua
local Responsiveness = require(path.to.Responsiveness)
local uiScale = path.to.UIScale

-- Configure scaling attributes
uiScale:SetAttribute("Ratio", 1.2)
uiScale:SetAttribute("Range", NumberRange.new(0.5, 2.0))
uiScale:SetAttribute("Resolution", Vector2.new(1920, 1080))
uiScale:SetAttribute("InnerRatios", '{"Large": 0.8, "Small": 1.3}')

local responsive = Responsiveness.new(uiScale)
responsive:Track()

-- Later cleanup
responsive:Destroy()
```

## Mentions / Projects Using Responsiveness & QuickScale

Below is a list of experiences, games, or projects that use or have used **Responsiveness** or **QuickScale**.  
If your project uses our libraries and you want it listed, feel free to contact [PcoiDev](https://pcoi.dev).

| Name | Link |
|-------------|----------------|
| Squid Game Tower | [View Game](https://www.roblox.com/games/103410145208388/Squid-Game-Tower) |
| Squid Game Troll Tower | [View Game](https://www.roblox.com/games/75139493550474/Squid-Game-Troll-Tower) |
