local TweenService = game:GetService("TweenService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Toggle - Missing Title")

	local Toggle = {
		Value = Config.Default or false,
		Callback = Config.Callback or function(Value) end,
		Type = "Toggle",
	}

	local ToggleFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true)
	ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

	Toggle.SetTitle = ToggleFrame.SetTitle
	Toggle.SetDesc = ToggleFrame.SetDesc

	local ToggleCircle = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(0, 3, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.3,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local ToggleGlow = New("UIStroke", {
		Thickness = 1.5,
		Transparency = 1,
		ThemeTag = { Color = "Accent" },
	})

	local ToggleBorder = New("UIStroke", {
		Transparency = 0.5,
		ThemeTag = { Color = "ToggleSlider" },
	})

	local ToggleSlider = New("Frame", {
		Size = UDim2.fromOffset(36, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Parent = ToggleFrame.Frame,
		BackgroundTransparency = 0.85,
		ThemeTag = { BackgroundColor3 = "Accent" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		ToggleBorder,
		ToggleGlow,
		ToggleCircle,
	})

	function Toggle:OnChanged(Func)
		Toggle.Changed = Func
		Func(Toggle.Value)
	end

	function Toggle:SetValue(Value)
		Value = not not Value
		Toggle.Value = Value

		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(ToggleCircle, tweenInfo, {
			Position = UDim2.new(0, Toggle.Value and 21 or 3, 0.5, 0),
			Size = UDim2.fromOffset(Toggle.Value and 12 or 12, 12),
			BackgroundColor3 = Toggle.Value and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
		}):Play()
		TweenService:Create(ToggleSlider, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = Toggle.Value and 0.1 or 0.85,
		}):Play()
		TweenService:Create(ToggleGlow, TweenInfo.new(0.3), {
			Transparency = Toggle.Value and 0.3 or 1,
		}):Play()
		TweenService:Create(ToggleBorder, TweenInfo.new(0.3), {
			Transparency = Toggle.Value and 1 or 0.5,
		}):Play()

		Library:SafeCallback(Toggle.Callback, Toggle.Value)
		Library:SafeCallback(Toggle.Changed, Toggle.Value)
	end

	function Toggle:Destroy()
		ToggleFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
		Toggle:SetValue(not Toggle.Value)
	end)

	Toggle:SetValue(Toggle.Value)

	Library.Options[Idx] = Toggle
	return Toggle
end

return Element
