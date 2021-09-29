local services = setmetatable({}, {
	__index = function(index, service)
		return game:GetService(service)
	end,
	__newindex = function(index, value)
		index[value] = nil
		return
	end
})

local plrs = services.Players
local plr = services.Players.LocalPlayer
local mouse = plr:GetMouse()

-- Library Start --

local library 
local utilities
library = {flags={},storage={objects={},functions={},tabs={},currentTab={}},destroyed=false,binds={},binding=false,unload=function()
    library.ui:Destroy()
    library.binding=false
    library.destroyed=true
end,updateToggle=function(flag,boolean)
    local toggleModule = library.storage.objects[flag]
    if not toggleModule then return end
    local currentVal = library.flags[flag]
    if boolean == nil then boolean = not currentVal end
    if currentVal == nil or currentVal == boolean then return end
    local on = toggleModule.ToggleDisplayOn
    local off = toggleModule.ToggleDisplayOff
    library.flags[flag] = boolean
    spawn(function() library.storage.functions[flag](boolean) end)
    utilities.tween(on, {
        BackgroundTransparency = (boolean and 0 or 1)
    })
    utilities.tween(off, {
        BackgroundTransparency = (boolean and 1 or 0)
    })
end,updateSlider=function(flag, value, min, max)
	local slider = library.storage.objects[flag]
	local bar = slider.SliderBack
	local box = slider.SliderBack.SliderVal

	local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X

	if value then
		percent = (value - min) / (max - min)
	end

	percent = math.clamp(percent, 0, 1)
	value = value or math.floor(min + (max - min) * percent)

	library.flags[flag] = value

	box.Text = tostring(value)

	bar.SliderBar.Size = UDim2.new(percent, 0, 1, 0)

	library.storage.functions[flag](tonumber(value))
	return tonumber(value)
end}

utilities = {
    tween = function(obj,props,info)
        info = info or TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tween = services.TweenService:Create(obj,info,props):Play()
        return tween
    end,
    drag = function(frame, hold)
        if not hold then
            hold = frame
        end
        local dragging
        local dragInput
        local dragStart
        local startPos
    
        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    
        hold.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
    
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
    
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
    
        services.UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end,
    ripple = function(obj)
	    spawn(function()
            if obj.ClipsDescendants ~= true then
                obj.ClipsDescendants = true
            end
            local Ripple = Instance.new("ImageLabel")
            Ripple.Name = "Ripple"
            Ripple.Parent = obj
            Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Ripple.BackgroundTransparency = 1.000
            Ripple.ZIndex = 8
            Ripple.Image = "rbxassetid://2708891598"
            Ripple.ImageTransparency = 0.800
            Ripple.ScaleType = Enum.ScaleType.Fit
            Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
            Ripple.Position = UDim2.new((mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X, 0, (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y, 0)
            local a = utilities.tween(Ripple, {Position = UDim2.new(-5.5, 0, -5.5, 0), Size = UDim2.new(12, 0, 12, 0)})
            wait(0.1)
            local b = utilities.tween(Ripple, {ImageTransparency = 1})
            wait(0.2)
            Ripple:Destroy()
	    end)
    end,
    hover = function(obj)
        obj.MouseEnter:Connect(function()
            utilities.tween(obj, {
                BackgroundTransparency = 0.6
            })
        end)
        obj.MouseLeave:Connect(function()
            utilities.tween(obj, {
                BackgroundTransparency = 0
            })
        end)
    end,
    switchTab = function(tabInfo)
        library.storage.currentTab.Tab.Visible = false
        library.storage.currentTab.Button.TextColor3 = Color3.fromRGB(255,255,255)
        library.storage.currentTab = tabInfo
        library.storage.currentTab.Tab.Visible = true
        library.storage.currentTab.Button.TextColor3 = Color3.fromRGB(165, 138, 255)
    end
}

local function isreallypressed(bind, inp)
	local key = bind
	if typeof(key) == "Instance" then
		if key.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == key.KeyCode then
			return true;
		elseif tostring(key.UserInputType):find('MouseButton') and inp.UserInputType == key.UserInputType then
			return true
		end
	end
	if tostring(key):find'MouseButton1' then
		return key == inp.UserInputType
	else
		return key == inp.KeyCode
	end
end

pcall(function()
	services.UserInputService.InputBegan:Connect(function(input, gp)
		if library.destroyed then return end
		if gp then else
			if (not library.binding) then
				for idx, binds in next, library.binds do
					local real_binding = binds.location[idx];
					if real_binding and isreallypressed(real_binding, input) then
						binds.callback()
					end
				end
			end
		end
	end)
end)

library.initiate = function(name)
    library.ui.Enabled = true
    library.storage.tabs[1].Tab.Visible = true
    library.storage.tabs[1].Button.TextColor3 = Color3.fromRGB(165, 138, 255)
    library.storage.currentTab = library.storage.tabs[1]
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = library.ui.Main
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.Position = UDim2.new(0.0199999996, 0, 0.00999999978, 0)
    Title.Size = UDim2.new(0, 400, 0, 26)
    Title.Font = Enum.Font.GothamBold
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18.000
    Title.TextXAlignment = Enum.TextXAlignment.Left
    utilities.drag(library.ui.Main, Title)
end

local BubblyUi = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local MainC = Instance.new("UICorner")
local MainGrad = Instance.new("UIGradient")
local Bottom = Instance.new("Frame")
local BottomC = Instance.new("UICorner")
local TabBtns = Instance.new("Frame")
local TabBtnsL = Instance.new("UIListLayout")
local Tabs = Instance.new("Frame")

library.ui = BubblyUi

if syn and syn.protect_gui then syn.protect_gui(BubblyUi) end

BubblyUi.Name = "BubblyUi"
BubblyUi.Parent = get_hidden_gui and get_hidden_gui() or gethui and gethui() or services.CoreGui
BubblyUi.Enabled = false
BubblyUi.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = BubblyUi
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 497, 0, 314)
Main.AnchorPoint = Vector2.new(0.5, 0.5)

MainC.CornerRadius = UDim.new(0, 6)
MainC.Name = "MainC"
MainC.Parent = Main

MainGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(209, 166, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(110, 105, 255))}
MainGrad.Rotation = 60
MainGrad.Name = "MainGrad"
MainGrad.Parent = Main

Bottom.Name = "Bottom"
Bottom.Parent = Main
Bottom.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Bottom.BackgroundTransparency = 0.800
Bottom.BorderSizePixel = 0
Bottom.Position = UDim2.new(0.0100000026, 0, 0.0920000002, 0)
Bottom.Size = UDim2.new(0, 488, 0, 281)

BottomC.CornerRadius = UDim.new(0, 6)
BottomC.Name = "BottomC"
BottomC.Parent = Bottom

TabBtns.Name = "TabBtns"
TabBtns.Parent = Bottom
TabBtns.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TabBtns.BackgroundTransparency = 1.000
TabBtns.Size = UDim2.new(0, 487, 0, 26)

TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.FillDirection = Enum.FillDirection.Horizontal
TabBtnsL.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.VerticalAlignment = Enum.VerticalAlignment.Center

Tabs.Name = "Tabs"
Tabs.Parent = Bottom
Tabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tabs.BackgroundTransparency = 1.000
Tabs.BorderSizePixel = 0
Tabs.Position = UDim2.new(0, 0, 0.0925266892, 0)
Tabs.Size = UDim2.new(0, 487, 0, 255)

library.addtab = function(name)
    local TabBtn = Instance.new("TextButton")
    local Tab = Instance.new("ScrollingFrame")
    local TabG = Instance.new("UIGridLayout")
    
    TabBtn.Name = "TabBtn"
    TabBtn.Parent = TabBtns
    TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.BackgroundTransparency = 1.000
    TabBtn.BorderSizePixel = 0
    TabBtn.Size = UDim2.new(0, 60, 0, 26)
    TabBtn.Font = Enum.Font.GothamBlack
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.TextSize = 14.000
    TabBtn.Size = UDim2.new(0, TabBtn.TextBounds.X+12, 0, 26)
    
    Tab.Name = "Tab"
    Tab.Parent = Tabs
    Tab.Active = true
    Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Tab.BackgroundTransparency = 1.000
    Tab.BorderSizePixel = 0
    Tab.Size = UDim2.new(0, 487, 0, 255)
    Tab.ScrollBarThickness = 2
    Tab.Visible = false
    
    TabG.Name = "TabG"
    TabG.Parent = Tab
    TabG.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabG.SortOrder = Enum.SortOrder.LayoutOrder
    TabG.CellPadding = UDim2.new(0, 6, 0, 6)
    TabG.CellSize = UDim2.new(0, 230, 0, 80)

    TabG:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.CanvasSize = UDim2.new(0, 0, 0, TabG.AbsoluteContentSize.Y + 6)
    end)
    
    table.insert(library.storage.tabs, {Tab = Tab, Button = TabBtn})
    
    TabBtn.MouseButton1Click:Connect(function()
        utilities.switchTab({Tab = Tab, Button = TabBtn})    
    end)

    local modules = {}

    modules.button = function(properties,callback)
        properties.header = properties.header or "Header"
        properties.description = properties.description or "No Description Provided."
        properties.text = properties.text or "Click Me!"
        callback = callback or function()end
        local BtnModule = Instance.new("Frame")
        local BtnModuleC = Instance.new("UICorner")
        local BtnTitle = Instance.new("TextLabel")
        local BtnDesc = Instance.new("TextLabel")
        local BtnClick = Instance.new("TextButton")
        local BtnClickGrad = Instance.new("UIGradient")
        local BtnClickC = Instance.new("UICorner")
        local BtnClickText = Instance.new("TextLabel")
        
        BtnModule.Name = "BtnModule"
        BtnModule.Parent = Tab
        BtnModule.BackgroundColor3 = Color3.fromRGB(173, 148, 255)
        BtnModule.BorderSizePixel = 0
        BtnModule.Size = UDim2.new(0, 100, 0, 100)
        
        BtnModuleC.CornerRadius = UDim.new(0, 6)
        BtnModuleC.Name = "BtnModuleC"
        BtnModuleC.Parent = BtnModule
        
        BtnTitle.Name = "BtnTitle"
        BtnTitle.Parent = BtnModule
        BtnTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BtnTitle.BackgroundTransparency = 1.000
        BtnTitle.Position = UDim2.new(0.0260869563, 0, 0.075000003, 0)
        BtnTitle.Size = UDim2.new(0, 194, 0, 14)
        BtnTitle.Font = Enum.Font.GothamBold
        BtnTitle.Text = properties.header
        BtnTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        BtnTitle.TextSize = 14.000
        BtnTitle.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        BtnTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        BtnDesc.Name = "BtnDesc"
        BtnDesc.Parent = BtnModule
        BtnDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BtnDesc.BackgroundTransparency = 1.000
        BtnDesc.Position = UDim2.new(0.0260869563, 0, 0.324999988, 0)
        BtnDesc.Size = UDim2.new(0, 194, 0, 14)
        BtnDesc.Font = Enum.Font.GothamBold
        BtnDesc.Text = "- " .. properties.description
        BtnDesc.TextColor3 = Color3.fromRGB(226, 226, 226)
        BtnDesc.TextSize = 14.000
        BtnDesc.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        BtnDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        BtnClick.Name = "BtnClick"
        BtnClick.Parent = BtnModule
        BtnClick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BtnClick.BorderSizePixel = 0
        BtnClick.Position = UDim2.new(0.0260869563, 0, 0.574999988, 0)
        BtnClick.Size = UDim2.new(0, 218, 0, 28)
        BtnClick.AutoButtonColor = false
        BtnClick.Font = Enum.Font.GothamBold
        BtnClick.Text = ""
        BtnClick.TextColor3 = Color3.fromRGB(255, 255, 255)
        BtnClick.TextSize = 14.000
        
        BtnClickGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(209, 166, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(110, 105, 255))}
        BtnClickGrad.Rotation = 60
        BtnClickGrad.Name = "BtnClickGrad"
        BtnClickGrad.Parent = BtnClick
        
        BtnClickC.CornerRadius = UDim.new(0, 6)
        BtnClickC.Name = "BtnClickC"
        BtnClickC.Parent = BtnClick
        
        BtnClickText.Name = "BtnClickText"
        BtnClickText.Parent = BtnClick
        BtnClickText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BtnClickText.BackgroundTransparency = 1.000
        BtnClickText.BorderSizePixel = 0
        BtnClickText.Size = UDim2.new(0, 218, 0, 28)
        BtnClickText.Font = Enum.Font.GothamBold
        BtnClickText.Text = properties.text
        BtnClickText.TextColor3 = Color3.fromRGB(255, 255, 255)
        BtnClickText.TextSize = 14.000        

        BtnClick.MouseButton1Click:Connect(function()
            spawn(callback)
            spawn(function()utilities.ripple(BtnClick)end)
        end) 
        utilities.hover(BtnClick)
    end
    modules.toggle = function(properties, callback)
        properties.header = properties.header or "Header"
        properties.description = properties.description or "No Description Provided."
        library.flags[properties.flag] = false
        library.storage.functions[properties.flag] = callback or function() end
        local ToggleModule = Instance.new("Frame")
        library.storage.objects[properties.flag] = ToggleModule
        local ToggleModuleC = Instance.new("UICorner")
        local ToggleTitle = Instance.new("TextLabel")
        local ToggleDesc = Instance.new("TextLabel")
        local ToggleDisplayOff = Instance.new("TextButton")
        local ToggleDisplayOffGrad = Instance.new("UIGradient")
        local ToggleDisplayOffC = Instance.new("UICorner")
        local ToggleDisplayOn = Instance.new("TextButton")
        local ToggleDisplayOnGrad = Instance.new("UIGradient")
        local ToggleDisplayOnC = Instance.new("UICorner")
        local ToggleClick = Instance.new("TextButton")
        
        ToggleModule.Name = "ToggleModule"
        ToggleModule.Parent = Tab
        ToggleModule.BackgroundColor3 = Color3.fromRGB(173, 148, 255)
        ToggleModule.BorderSizePixel = 0
        ToggleModule.Size = UDim2.new(0, 100, 0, 100)
        
        ToggleModuleC.CornerRadius = UDim.new(0, 6)
        ToggleModuleC.Name = "ToggleModuleC"
        ToggleModuleC.Parent = ToggleModule
        
        ToggleTitle.Name = "ToggleTitle"
        ToggleTitle.Parent = ToggleModule
        ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleTitle.BackgroundTransparency = 1.000
        ToggleTitle.Position = UDim2.new(0.0260869563, 0, 0.075000003, 0)
        ToggleTitle.Size = UDim2.new(0, 194, 0, 14)
        ToggleTitle.Font = Enum.Font.GothamBold
        ToggleTitle.Text = properties.header
        ToggleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleTitle.TextSize = 14.000
        ToggleTitle.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleDesc.Name = "ToggleDesc"
        ToggleDesc.Parent = ToggleModule
        ToggleDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDesc.BackgroundTransparency = 1.000
        ToggleDesc.Position = UDim2.new(0.0260869563, 0, 0.324999988, 0)
        ToggleDesc.Size = UDim2.new(0, 194, 0, 14)
        ToggleDesc.Font = Enum.Font.GothamBold
        ToggleDesc.Text = "- " .. properties.description
        ToggleDesc.TextColor3 = Color3.fromRGB(226, 226, 226)
        ToggleDesc.TextSize = 14.000
        ToggleDesc.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleDisplayOff.Name = "ToggleDisplayOff"
        ToggleDisplayOff.Parent = ToggleModule
        ToggleDisplayOff.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDisplayOff.BorderSizePixel = 0
        ToggleDisplayOff.Position = UDim2.new(0.0260869563, 0, 0.574999988, 0)
        ToggleDisplayOff.Size = UDim2.new(0, 218, 0, 28)
        ToggleDisplayOff.AutoButtonColor = false
        ToggleDisplayOff.Font = Enum.Font.GothamBold
        ToggleDisplayOff.Text = ""
        ToggleDisplayOff.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDisplayOff.TextSize = 14.000
        
        ToggleDisplayOffGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 38, 41)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 88, 91))}
        ToggleDisplayOffGrad.Rotation = 60
        ToggleDisplayOffGrad.Name = "ToggleDisplayOffGrad"
        ToggleDisplayOffGrad.Parent = ToggleDisplayOff
        
        ToggleDisplayOffC.CornerRadius = UDim.new(0, 6)
        ToggleDisplayOffC.Name = "ToggleDisplayOffC"
        ToggleDisplayOffC.Parent = ToggleDisplayOff
        
        ToggleDisplayOn.Name = "ToggleDisplayOn"
        ToggleDisplayOn.Parent = ToggleModule
        ToggleDisplayOn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDisplayOn.BackgroundTransparency = 1.000
        ToggleDisplayOn.BorderSizePixel = 0
        ToggleDisplayOn.Position = UDim2.new(0.0260869563, 0, 0.574999988, 0)
        ToggleDisplayOn.Size = UDim2.new(0, 218, 0, 28)
        ToggleDisplayOn.AutoButtonColor = false
        ToggleDisplayOn.Font = Enum.Font.GothamBold
        ToggleDisplayOn.Text = ""
        ToggleDisplayOn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDisplayOn.TextSize = 14.000
        
        ToggleDisplayOnGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(74, 255, 101)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 255, 67))}
        ToggleDisplayOnGrad.Rotation = 60
        ToggleDisplayOnGrad.Name = "ToggleDisplayOnGrad"
        ToggleDisplayOnGrad.Parent = ToggleDisplayOn
        
        ToggleDisplayOnC.CornerRadius = UDim.new(0, 6)
        ToggleDisplayOnC.Name = "ToggleDisplayOnC"
        ToggleDisplayOnC.Parent = ToggleDisplayOn
        
        ToggleClick.Name = "ToggleClick"
        ToggleClick.Parent = ToggleModule
        ToggleClick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleClick.BackgroundTransparency = 1.000
        ToggleClick.Position = UDim2.new(0.0260869563, 0, 0.574999988, 0)
        ToggleClick.Size = UDim2.new(0, 218, 0, 28)
        ToggleClick.Font = Enum.Font.SourceSans
        ToggleClick.Text = ""
        ToggleClick.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleClick.TextSize = 14.000

        if properties.enabled then
            library.updateToggle(properties.flag, true)
        end

        ToggleClick.MouseButton1Click:Connect(function()
            spawn(function() 
                utilities.ripple(ToggleClick)
            end)
            library.updateToggle(properties.flag)
        end)
    end
    modules.slider = function(properties, callback) 
        properties.header = properties.header or "Header"
        properties.description = properties.description or "No Description Provided."       
        library.flags[properties.flag] = (properties.default or properties.min)
        library.storage.functions[properties.flag] = callback or function() end
        local SliderModule = Instance.new("Frame")
        local SliderModuleC = Instance.new("UICorner")
        local SliderTitle = Instance.new("TextLabel")
        local SliderDesc = Instance.new("TextLabel")
        local SliderBack = Instance.new("TextButton")
        local SliderBackGrad = Instance.new("UIGradient")
        local SliderBackC = Instance.new("UICorner")
        local SliderVal = Instance.new("TextLabel")
        local SliderBar = Instance.new("Frame")
        local SliderBarC = Instance.new("UICorner")
        local SliderBarGrad = Instance.new("UIGradient")
        
        library.storage.objects[properties.flag] = SliderModule

        SliderModule.Name = "SliderModule"
        SliderModule.Parent = Tab
        SliderModule.BackgroundColor3 = Color3.fromRGB(173, 148, 255)
        SliderModule.BorderSizePixel = 0
        SliderModule.Size = UDim2.new(0, 100, 0, 100)
        
        SliderModuleC.CornerRadius = UDim.new(0, 6)
        SliderModuleC.Name = "SliderModuleC"
        SliderModuleC.Parent = SliderModule
        
        SliderTitle.Name = "SliderTitle"
        SliderTitle.Parent = SliderModule
        SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.BackgroundTransparency = 1.000
        SliderTitle.Position = UDim2.new(0.0260869563, 0, 0.075000003, 0)
        SliderTitle.Size = UDim2.new(0, 194, 0, 14)
        SliderTitle.Font = Enum.Font.GothamBold
        SliderTitle.Text = properties.header
        SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.TextSize = 14.000
        SliderTitle.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        SliderDesc.Name = "SliderDesc"
        SliderDesc.Parent = SliderModule
        SliderDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderDesc.BackgroundTransparency = 1.000
        SliderDesc.Position = UDim2.new(0.0260869563, 0, 0.324999988, 0)
        SliderDesc.Size = UDim2.new(0, 194, 0, 14)
        SliderDesc.Font = Enum.Font.GothamBold
        SliderDesc.Text = "- " .. properties.description
        SliderDesc.TextColor3 = Color3.fromRGB(226, 226, 226)
        SliderDesc.TextSize = 14.000
        SliderDesc.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        SliderDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        SliderBack.Name = "SliderBack"
        SliderBack.Parent = SliderModule
        SliderBack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderBack.BorderSizePixel = 0
        SliderBack.Position = UDim2.new(0.0260869563, 0, 0.574999988, 0)
        SliderBack.Size = UDim2.new(0, 218, 0, 28)
        SliderBack.AutoButtonColor = false
        SliderBack.Font = Enum.Font.GothamBold
        SliderBack.Text = ""
        SliderBack.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderBack.TextSize = 14.000
        
        SliderBackGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(209, 166, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(110, 105, 255))}
        SliderBackGrad.Rotation = 60
        SliderBackGrad.Name = "SliderBackGrad"
        SliderBackGrad.Parent = SliderBack
        
        SliderBackC.CornerRadius = UDim.new(0, 6)
        SliderBackC.Name = "SliderBackC"
        SliderBackC.Parent = SliderBack
        
        SliderVal.Name = "SliderVal"
        SliderVal.Parent = SliderBack
        SliderVal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderVal.BackgroundTransparency = 1.000
        SliderVal.BorderSizePixel = 0
        SliderVal.Position = UDim2.new(0.5, 0, 0.5, 0)
        SliderVal.ZIndex = 10
        SliderVal.Font = Enum.Font.GothamBold
        SliderVal.Text = ""
        SliderVal.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderVal.TextSize = 14.000
        
        SliderBar.Name = "SliderBar"
        SliderBar.Parent = SliderBack
        SliderBar.BackgroundColor3 = Color3.fromRGB(111, 44, 255)
        SliderBar.BackgroundTransparency = 0.700
        SliderBar.BorderSizePixel = 0
        SliderBar.Size = UDim2.new(0, 54, 0, 28)
        
        SliderBarC.CornerRadius = UDim.new(0, 6)
        SliderBarC.Name = "SliderBarC"
        SliderBarC.Parent = SliderBar
        
        SliderBarGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(209, 166, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(110, 105, 255))}
        SliderBarGrad.Rotation = 60
        SliderBarGrad.Name = "SliderBarGrad"
        SliderBarGrad.Parent = SliderBar        

        library.updateSlider(properties.flag, library.flags[properties.flag], properties.min, properties.max)
        local dragging = false

        SliderBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                library.updateSlider(properties.flag, nil, properties.min, properties.max)
            end
        end)

        SliderBack.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        services.UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                library.updateSlider(properties.flag, nil, properties.min, properties.max)
            end
        end)
    end
    modules.bind = function(properties, callback)
        properties.header = properties.header or "Header"
        properties.description = properties.description or "No Description Provided."
        local callback = callback or function() end
        local default = properties.default
        local flag = properties.flag
			
        local banned = {
            Return = true;
            Space = true;
            Tab = true;
            Unknown = true;
        }
        local shortNames = {
            RightControl = 'Right Ctrl',
            LeftControl = 'Left Ctrl',
            LeftShift = 'Left Shift',
            RightShift = 'Right Shift',
            Semicolon = ";",
            Quote = '"',
            LeftBracket = '[',
            RightBracket = ']',
            Equals = '=',
            Minus = '-',
            RightAlt = 'Right Alt',
            LeftAlt = 'Left Alt'
        }
        local allowed = {
            MouseButton1 = false,
            MouseButton2 = false
        }      
        local nm = (default and (shortNames[default.Name] or default.Name) or "None")
        library.flags[flag] = default or "None"

        local KeybindModule = Instance.new("Frame")
        local KeybindModuleC = Instance.new("UICorner")
        local KeybindTitle = Instance.new("TextLabel")
        local KeybindDesc = Instance.new("TextLabel")
        local KeybindBtn = Instance.new("TextButton")
        local KeybindBtnGrad = Instance.new("UIGradient")
        local KeybindBtnC = Instance.new("UICorner")
        local KeybindBtnText = Instance.new("TextLabel")
        
        KeybindModule.Name = "KeybindModule"
        KeybindModule.Parent = Tab
        KeybindModule.BackgroundColor3 = Color3.fromRGB(173, 148, 255)
        KeybindModule.BorderSizePixel = 0
        KeybindModule.Size = UDim2.new(0, 100, 0, 100)
        
        KeybindModuleC.CornerRadius = UDim.new(0, 6)
        KeybindModuleC.Name = "KeybindModuleC"
        KeybindModuleC.Parent = KeybindModule
        
        KeybindTitle.Name = "KeybindTitle"
        KeybindTitle.Parent = KeybindModule
        KeybindTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindTitle.BackgroundTransparency = 1.000
        KeybindTitle.Position = UDim2.new(0.0260869563, 0, 0.075000003, 0)
        KeybindTitle.Size = UDim2.new(0, 194, 0, 14)
        KeybindTitle.Font = Enum.Font.GothamBold
        KeybindTitle.Text = properties.header
        KeybindTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindTitle.TextSize = 14.000
        KeybindTitle.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        KeybindDesc.Name = "KeybindDesc"
        KeybindDesc.Parent = KeybindModule
        KeybindDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindDesc.BackgroundTransparency = 1.000
        KeybindDesc.Position = UDim2.new(0.0260869563, 0, 0.324999988, 0)
        KeybindDesc.Size = UDim2.new(0, 194, 0, 14)
        KeybindDesc.Font = Enum.Font.GothamBold
        KeybindDesc.Text = "- " .. properties.description
        KeybindDesc.TextColor3 = Color3.fromRGB(226, 226, 226)
        KeybindDesc.TextSize = 14.000
        KeybindDesc.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        KeybindDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        KeybindBtn.Name = "KeybindBtn"
        KeybindBtn.Parent = KeybindModule
        KeybindBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindBtn.BorderSizePixel = 0
        KeybindBtn.Position = UDim2.new(0.0260869563, 0, 0.574999988, 0)
        KeybindBtn.Size = UDim2.new(0, 218, 0, 28)
        KeybindBtn.AutoButtonColor = false
        KeybindBtn.Font = Enum.Font.GothamBold
        KeybindBtn.Text = ""
        KeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindBtn.TextSize = 14.000
        
        KeybindBtnGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(209, 166, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(110, 105, 255))}
        KeybindBtnGrad.Rotation = 60
        KeybindBtnGrad.Name = "KeybindBtnGrad"
        KeybindBtnGrad.Parent = KeybindBtn
        
        KeybindBtnC.CornerRadius = UDim.new(0, 6)
        KeybindBtnC.Name = "KeybindBtnC"
        KeybindBtnC.Parent = KeybindBtn
        
        KeybindBtnText.Name = "KeybindBtnText"
        KeybindBtnText.Parent = KeybindBtn
        KeybindBtnText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindBtnText.BackgroundTransparency = 1.000
        KeybindBtnText.BorderSizePixel = 0
        KeybindBtnText.Size = UDim2.new(0, 218, 0, 28)
        KeybindBtnText.Font = Enum.Font.GothamBold
        KeybindBtnText.Text = nm
        KeybindBtnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindBtnText.TextSize = 14.000

        KeybindBtn.MouseButton1Click:Connect(function()
            spawn(function()
                utilities.ripple(KeybindBtn)
            end)
            library.binding = true
            KeybindBtnText.Text = "..."
            local a, b = services.UserInputService.InputBegan:wait()
            local name = tostring(a.KeyCode.Name)
            local typeName = tostring(a.UserInputType.Name)
            if (a.UserInputType ~= Enum.UserInputType.Keyboard and (allowed[a.UserInputType.Name]) and (not data.KbOnly)) or (a.KeyCode and (not banned[a.KeyCode.Name])) then
                local name = (a.UserInputType ~= Enum.UserInputType.Keyboard and a.UserInputType.Name or a.KeyCode.Name)
                library.flags[flag] = (a)
                KeybindBtnText.Text = shortNames[name] or name
            else
                if (library.flags[flag]) then
                    if (not pcall(function()
                            return library.flags[flag].UserInputType
                        end)) then
                        local name = tostring(library.flags[flag])
                        KeybindBtnText.Text = shortNames[name] or name
                    else
                        local name = (library.flags[flag].UserInputType ~= Enum.UserInputType.Keyboard and library.flags[flag].UserInputType.Name or library.flags[flag].KeyCode.Name)
                        KeybindBtnText.Text = shortNames[name] or name
                    end
                end
            end
            wait()  
            library.binding = false
        end)
        if library.flags[flag] then
            KeybindBtnText.Text = shortNames[tostring(library.flags[flag].Name)] or tostring(library.flags[flag].Name)
        end
        library.binds[flag] = {
            location = library.flags,
            callback = function()
                callback()	
            end
        }
    end
    modules.box = function(properties, callback)
        callback = callback or function() end
        properties.header = properties.header or "Header"
        properties.description = properties.description or "No Description Provided."
        library.flags[properties.flag] = properties.default or ""
        local TextboxModule = Instance.new("Frame")
        local TextboxModuleC = Instance.new("UICorner")
        local TextboxTitle = Instance.new("TextLabel")
        local TextboxDesc = Instance.new("TextLabel")
        local BoxBG = Instance.new("TextButton")
        local BoxBGGrad = Instance.new("UIGradient")
        local BoxBGC = Instance.new("UICorner")
        local TextBox = Instance.new("TextBox")
        
        TextboxModule.Name = "TextboxModule"
        TextboxModule.Parent = Tab
        TextboxModule.BackgroundColor3 = Color3.fromRGB(173, 148, 255)
        TextboxModule.BorderSizePixel = 0
        TextboxModule.Size = UDim2.new(0, 100, 0, 100)
        
        TextboxModuleC.CornerRadius = UDim.new(0, 6)
        TextboxModuleC.Name = "TextboxModuleC"
        TextboxModuleC.Parent = TextboxModule
        
        TextboxTitle.Name = "TextboxTitle"
        TextboxTitle.Parent = TextboxModule
        TextboxTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextboxTitle.BackgroundTransparency = 1.000
        TextboxTitle.Position = UDim2.new(0.0260869563, 0, 0.075000003, 0)
        TextboxTitle.Size = UDim2.new(0, 194, 0, 14)
        TextboxTitle.Font = Enum.Font.GothamBold
        TextboxTitle.Text = properties.header
        TextboxTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextboxTitle.TextSize = 14.000
        TextboxTitle.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        TextboxTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        TextboxDesc.Name = "TextboxDesc"
        TextboxDesc.Parent = TextboxModule
        TextboxDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextboxDesc.BackgroundTransparency = 1.000
        TextboxDesc.Position = UDim2.new(0.0260869563, 0, 0.324999988, 0)
        TextboxDesc.Size = UDim2.new(0, 194, 0, 14)
        TextboxDesc.Font = Enum.Font.GothamBold
        TextboxDesc.Text = "- " .. properties.description
        TextboxDesc.TextColor3 = Color3.fromRGB(226, 226, 226)
        TextboxDesc.TextSize = 14.000
        TextboxDesc.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        TextboxDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        BoxBG.Name = "BoxBG"
        BoxBG.Parent = TextboxModule
        BoxBG.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BoxBG.BorderSizePixel = 0
        BoxBG.Position = UDim2.new(0.0260869563, 0, 0.574999988, 0)
        BoxBG.Size = UDim2.new(0, 218, 0, 28)
        BoxBG.AutoButtonColor = false
        BoxBG.Font = Enum.Font.GothamBold
        BoxBG.Text = ""
        BoxBG.TextColor3 = Color3.fromRGB(255, 255, 255)
        BoxBG.TextSize = 14.000
        
        BoxBGGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(209, 166, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(110, 105, 255))}
        BoxBGGrad.Rotation = 60
        BoxBGGrad.Name = "BoxBGGrad"
        BoxBGGrad.Parent = BoxBG
        
        BoxBGC.CornerRadius = UDim.new(0, 6)
        BoxBGC.Name = "BoxBGC"
        BoxBGC.Parent = BoxBG
        
        TextBox.Parent = BoxBG
        TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.BackgroundTransparency = 1.000
        TextBox.BorderSizePixel = 0
        TextBox.Size = UDim2.new(0, 218, 0, 28)
        TextBox.Font = Enum.Font.GothamBold
        TextBox.Text = library.flags[properties.flag]
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = 14.000

        TextBox.Focused:Connect(function()
            utilities.tween(BoxBG, {
                BackgroundTransparency = 0.6
            })
        end)
        TextBox.FocusLost:Connect(function()
            library.flags[properties.flag] = TextBox.Text
            callback(library.flags[properties.flag])
            utilities.tween(BoxBG, {
                BackgroundTransparency = 0
            })
        end)
    end
    modules.text = function(properties)
        properties.header = properties.header or "Header"
        properties.description = properties.description or "No Description Provided."

        local TextModule = Instance.new("Frame")
        local TextModuleC = Instance.new("UICorner")
        local Header = Instance.new("TextLabel")
        local SubText = Instance.new("TextLabel")
        
        TextModule.Name = "TextModule"
        TextModule.Parent = Tab
        TextModule.BackgroundColor3 = Color3.fromRGB(173, 148, 255)
        TextModule.BorderSizePixel = 0
        TextModule.Size = UDim2.new(0, 100, 0, 100)
        
        TextModuleC.CornerRadius = UDim.new(0, 6)
        TextModuleC.Name = "TextModuleC"
        TextModuleC.Parent = TextModule
        
        Header.Name = "Header"
        Header.Parent = TextModule
        Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Header.BackgroundTransparency = 1.000
        Header.Position = UDim2.new(0.0260869563, 0, 0.075000003, 0)
        Header.Size = UDim2.new(0, 194, 0, 14)
        Header.Font = Enum.Font.GothamBold
        Header.Text = properties.header
        Header.TextColor3 = Color3.fromRGB(255, 255, 255)
        Header.TextSize = 14.000
        Header.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        Header.TextXAlignment = Enum.TextXAlignment.Left
        
        SubText.Name = "SubText"
        SubText.Parent = TextModule
        SubText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubText.BackgroundTransparency = 1.000
        SubText.Position = UDim2.new(0.0260869563, 0, 0.324999988, 0)
        SubText.Size = UDim2.new(0, 218, 0, 48)
        SubText.Font = Enum.Font.GothamBold
        SubText.Text = properties.description
        SubText.TextColor3 = Color3.fromRGB(226, 226, 226)
        SubText.TextSize = 14.000
        SubText.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        SubText.TextXAlignment = Enum.TextXAlignment.Left
        SubText.TextYAlignment = Enum.TextYAlignment.Top        

        return TextModule
    end
    return modules
end
return library
