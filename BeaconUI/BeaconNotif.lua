
local function init()
    -- init()
    local players = game:GetService("Players")
    local tween = game:GetService("TweenService")
    local run = game:GetService("RunService")
    local http = game:GetService("HttpService")
    local localplayer = players.LocalPlayer
    local good = type(syn) == "table" and type(syn.protect_gui) == "function"
    local bad = type(gethui) == "function"
    local eh = false
    pcall(function() if gethui then eh = true end end)

-- instances
local screen = Instance.new("ScreenGui")
local container = Instance.new("Frame")    
local left = Instance.new("ImageLabel")
local frame = Instance.new("Frame")
local corner = Instance.new("UICorner")
local right = Instance.new("Frame")
local titlelabel = Instance.new("TextLabel")
local bar = Instance.new("Frame")
local shadow = Instance.new("Frame")
local contentlabel = Instance.new("TextLabel")
local barbg = Instance.new("Frame")
local sound = Instance.new("Sound")
local btn = Instance.new("TextButton")


    screen.Name = "notifs_ui_lib"
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 2147483647

    local function g(sg)

        if good then
            pcall(function() syn.protect_gui(sg) end)
        end

        local ok, core = pcall(function() return game:GetService("CoreGui") end)
        if ok and core and pcall(function() sg.Parent = core end) then
            return true
        end

        if bad then
            local ok2, gui = pcall(function() return gethui() end)
            if ok2 and gui and pcall(function() sg.Parent = gui end) then
                return true
            end
        end
 
        if localplayer and localplayer:FindFirstChild("PlayerGui") then
            sg.Parent = localplayer:WaitForChild("PlayerGui")
            return true
        end

        sg.Parent = workspace
        return false end
    g(screen)

    
    container.Name = "notification_container"
    container.BackgroundTransparency = 1
    container.AnchorPoint = Vector2.new(1, 1) 
    container.Position = UDim2.new(1, -12, 1, -12)
    container.Size = UDim2.new(0, 320, 0, 200)
    container.ClipsDescendants = false
    container.Parent = screen

    local active = {}

    local base = 1366
    local function viewport_size()
        local cam = workspace.CurrentCamera
        if cam then
        return cam.ViewportSize end
        return Vector2.new(base, 768)
    end
    local function scale()
        local v = viewport_size()
        local s = math.clamp(math.min(v.X, v.Y) / base, 0.6, 1.6)
        return s
    end
    local function anims(inst, props, info)
        info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local ok, t = pcall(function() return tween:Create(inst, info, props) end)
        if ok and t then
            t:Play()
            return t else
            for k, v in pairs(props) do
                pcall(function() inst[k] = v end)
            end
            return nil end
    end

    local function uid()
        return tostring(math.floor(tick()*1000)) .. "-" .. http:GenerateGUID(false)
    end

    local function compute_size()
        local s = scale()
        local w = math.clamp(320 * s, 200, 520)
        local h = math.clamp(72 * s, 54, 140)
        return w, h
    end
    local function calc()
        local spacing = 8 * scale()
        local yoffset = 0
        for i = #active, 1, -1 do
            local node = active[i]
            if node and node.frame and node.frame.Parent then
                local target_y = -12 - yoffset - node.sizeY
                local target_pos = UDim2.new(1, -12, 1, target_y)
                anims(node.frame, {Position = target_pos}, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
                yoffset = yoffset + node.sizeY + spacing
            end
        end
    end

    local function check(id)
        for i = 1, #active do
            if active[i].id == id then
                table.remove(active, i)
                break
            end
        end
        calc()
    end

    local notifs = {}
    function notifs.CreateNode(opts)
        opts = opts or {}
        local title = tostring(opts.Title or opts.title or "Notification")
        local content = tostring(opts.Content or opts.content or "")
        local audio_id = opts.Audio or opts.audio
        local image_id = opts.Image or opts.image
        local length = tonumber(opts.Length or opts.length) or 5
        local always = (opts.AlwaysOnTop ~= nil) and (opts.AlwaysOnTop or opts.alwaysontop or opts.always) or false

        if length < 0 then length = 0 end

        local w, h = compute_size()

        frame.Name = "notif_" .. uid()
        frame.BackgroundTransparency = 0
        frame.BackgroundColor3 = Color3.fromRGB(26,26,26)
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(0, w, 0, h)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.Position = UDim2.new(1, -12, 1, -12 - h - 16)
        frame.ClipsDescendants = false

        
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        left.Name = "left_image"
        left.BackgroundTransparency = 1
        left.Size = UDim2.new(0, h, 1, 0)
        left.Position = UDim2.new(0, 0, 0, 0)
        left.Image = image_id and tostring(image_id) or ""
        left.ScaleType = Enum.ScaleType.Crop
        left.Parent = frame

        right.Name = "text_holder"
        right.BackgroundTransparency = 1
        right.Position = UDim2.new(0, h + 8, 0, 8)
        right.Size = UDim2.new(1, -(h + 12), 1, -16)
        right.Parent = frame

        titlelabel.Name = "title"
        titlelabel.BackgroundTransparency = 1
        titlelabel.Size = UDim2.new(1, 0, 0, math.floor(h*0.4))
        titlelabel.Position = UDim2.new(0, 0, 0, 0)
        titlelabel.Font = Enum.Font.GothamSemibold
        titlelabel.TextSize = math.clamp(14 * scale(), 12, 20)
        titlelabel.TextXAlignment = Enum.TextXAlignment.Left
        titlelabel.TextYAlignment = Enum.TextYAlignment.Top
        titlelabel.TextColor3 = Color3.fromRGB(255,255,255)
        titlelabel.Text = title
        titlelabel.Parent = right

        contentlabel.Name = "content"
        contentlabel.BackgroundTransparency = 1
        contentlabel.Size = UDim2.new(1, 0, 0, math.floor(h*0.5))
        contentlabel.Position = UDim2.new(0, 0, 0, math.floor(h*0.4))
        contentlabel.Font = Enum.Font.Gotham
        contentlabel.TextSize = math.clamp(12 * scale(), 10, 16)
        contentlabel.TextXAlignment = Enum.TextXAlignment.Left
        contentlabel.TextYAlignment = Enum.TextYAlignment.Top
        contentlabel.TextColor3 = Color3.fromRGB(200,200,200)
        contentlabel.Text = content
        contentlabel.TextWrapped = true
        contentlabel.Parent = right

        shadow.Name = "shadow"
        shadow.BackgroundTransparency = 0.85
        shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
        shadow.BorderSizePixel = 0
        shadow.Size = UDim2.new(1, 4, 1, 4)
        shadow.Position = UDim2.new(0, -2, 0, -2)
        shadow.ZIndex = frame.ZIndex - 1
        shadow.Parent = frame

        barbg.Name = "bar_bg"
        barbg.BackgroundTransparency = 0.9
        barbg.BorderSizePixel = 0
        barbg.Size = UDim2.new(1, 0, 0, 4)
        barbg.Position = UDim2.new(0, 0, 1, -4)
        barbg.Parent = frame

        bar.Name = "bar"
        bar.BorderSizePixel = 0
        bar.Size = UDim2.new(1, 0, 1, 0)
        bar.Position = UDim2.new(0, 0, 0, 0)
        bar.BackgroundTransparency = 0
        bar.BackgroundColor3 = Color3.fromRGB(90, 170, 255)
        bar.Parent = barbg

        sound.Name = "notif_sound"
        sound.Looped = false
        if audio_id and tostring(audio_id) ~= "" then
            sound.SoundId = tostring(audio_id)
            sound.Volume = 1
        end
        sound.Parent = frame

        if always then
            pcall(function() screen.DisplayOrder = 2147483647 end)
            if good then
            pcall(function() syn.protect_gui(screen) end) end 
		end
        frame.Parent = container
        if not image_id or tostring(image_id) == "" then
            left.Visible = false
            right.Position = UDim2.new(0, 8, 0, 8)
            right.Size = UDim2.new(1, -16, 1, -16)
        end

        pcall(function() if sound.SoundId and sound.SoundId ~= "" then sound:Play() end end)

        local function wait_for_abs()
            local attempts = 0
            while (frame.AbsoluteSize.X == 0 or frame.AbsoluteSize.Y == 0) and attempts < 60 do
                run.RenderStepped:Wait()
                attempts = attempts + 1 end
            return frame.AbsoluteSize end
        local abs = wait_for_abs()
        local sizeY = abs and abs.Y or h

        local id = uid()
        table.insert(active, {id = id, frame = frame, sizeY = sizeY})
        calc()
        local final_y = -12
        local function calc_target_for_id()
            local spacing = 8 * scale()
            local yoff = 0
            for i = #active, 1, -1 do
                local nd = active[i]
                if nd.id == id then
                    return -12 - yoff - nd.sizeY
                else
                    yoff = yoff + nd.sizeY + spacing
                end
            end
            return -12 end
        frame.Position = UDim2.new(1, -12, 1, calc_target_for_id() + 8)
        anims(frame, {Position = UDim2.new(1, -12, 1, calc_target_for_id())}, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out))

        local closed = false
        local gandalf = false

        local function togl()
            if closed or gandalf then return end
            gandalf = true
            local outinfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            pcall(function() if sound.IsPlaying then sound:Stop() end end)
            anims(frame, {Position = UDim2.new(1, 16, frame.Position.Y.Scale, frame.Position.Y.Offset), BackgroundTransparency = 1}, outinfo)
            pcall(function()
                local t1 = anims(titlelabel, {TextTransparency = 1}, outinfo)
                local t2 = anims(contentlabel, {TextTransparency = 1}, outinfo)
                local t3 = anims(left, {ImageTransparency = 1}, outinfo)
                local t4 = anims(bar, {Size = UDim2.new(0, 0, 1, 0)}, outinfo)
                if t1 then
                    t1.Completed:Wait()
                else
                    run.RenderStepped:Wait()
                end end)

            closed = true
            pcall(function() frame:Destroy() end)
            check(id)
        end
        if length and length > 0 then
            spawn(function()
                local start = tick()
                local ok, barTween = pcall(function()
                    return tween:Create(bar, TweenInfo.new(length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, 0)})
                end)
                if ok and barTween then
                    barTween:Play()
                end
                while tick() - start < length and not closed do
                    run.RenderStepped:Wait()
                end
                if not closed then
                    togl()
                end
            end)
        end 
        
        btn.Name = "clickblock"
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = frame.ZIndex + 10
        btn.Parent = frame
        btn.MouseButton1Click:Connect(function()
            togl()
        end)

        local handle = {}
        function handle:Close()
        togl() end
        function handle:IsClosed()
        return closed end
        function handle:GetFrame()
        return frame end

        return handle
    end
    local mt = getmetatable(notifs) or {}
    mt.__call = function(self, opts) return self.CreateNode(opts) end
    setmetatable(notifs, mt)
    function notifs.ClearAll()
        for i = #active, 1, -1 do
            pcall(function() active[i].frame:Destroy() end)
            table.remove(active, i)
        end end

    return notifs end



return init()
