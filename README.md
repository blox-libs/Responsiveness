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
- **InnerRatios**: JSON string mapping display sizes to ratio multipliers. (default: `{"Large": 1, "Medium": 1, "Small": 1}`)
→ applies 0.8x ratio on large screens, 1.2x on small screens. [View DisplaySize's Reference](https://create.roblox.com/docs/reference/engine/enums/DisplaySize)

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

-- Later cleanup (IMPORTANT)
responsive:Destroy()

```
