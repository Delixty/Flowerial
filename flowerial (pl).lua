-- flowerial | Prison Life: ESP + Aimbot + Misc + Sound
local HUB_NAME = "flowerial"
local DESIGN_W, DESIGN_H = 520, 460

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local SoundService     = game:GetService("SoundService")
local LocalPlayer      = Players.LocalPlayer
local genv = (getgenv and getgenv()) or _G

if genv.__FlowerialCleanup then pcall(genv.__FlowerialCleanup) end
if genv.__HubCleanup       then pcall(genv.__HubCleanup)       end

-- ═══════════════ УТИЛИТЫ ═══════════════
local WHITE   = Color3.new(1,1,1)
local GRAY    = Color3.fromRGB(140,140,150)
local OFF_COL = Color3.fromRGB(72,72,80)
local ROW_BG  = Color3.fromRGB(40,40,45)
local ACCENT  = Color3.fromRGB(240,110,175)
local AMBER   = Color3.fromRGB(240,180,60)
local GREEN   = Color3.fromRGB(80,210,130)
local RED     = Color3.fromRGB(226,52,60)
local CSK     = ColorSequenceKeypoint.new

local function new(class, props, parent)
    local o = Instance.new(class)
    if props then for k,v in pairs(props) do o[k]=v end end
    if parent then o.Parent = parent end
    return o
end
local function corner(o,r) return new("UICorner",{CornerRadius=UDim.new(0,r)},o) end
local function stroke(o,c,t,tr)
    return new("UIStroke",{Color=c,Thickness=t or 1,Transparency=tr or 0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)
end
local conns={}
local function connect(sig,fn) local c=sig:Connect(fn); conns[#conns+1]=c; return c end
local function safeDestroy(o) if o then pcall(function() o:Destroy() end) end end

-- ═══════════════ ЛОКАЛИЗАЦИЯ ═══════════════
local function T(en,ru) return {EN=en,RU=ru} end
local L = {
    tab_esp       = T("ESP","ESP"),
    tab_aimbot    = T("Aimbot","Аимбот"),
    tab_misc      = T("Misc","Разное"),
    tab_sound     = T("Sound","Музыка"),
    hd_control    = T("CONTROL","УПРАВЛЕНИЕ"),
    hd_settings   = T("SETTINGS","НАСТРОЙКИ"),
    guardian_esp  = T("Guardian ESP","ESP Надзирателей"),
    prisoner_esp  = T("Prisoner ESP","ESP Заключённых"),
    criminal_esp  = T("Criminal ESP","ESP Преступников"),
    fill_transp   = T("Highlight opacity","Прозрачность подсветки"),
    outline       = T("Outline only","Только контур"),
    aim_toggle    = T("Aimbot","Аимбот"),
    team_check    = T("Team check","Не целиться в своих"),
    ignore_prison = T("Ignore prisoners","Не целиться в заключённых"),
    aim_dist      = T("Max distance","Макс. дистанция"),
    aim_smooth    = T("Accuracy","Аккуратность прицеливания"),
    aim_fov       = T("FOV","FOV"),
    draw_fov      = T("Draw FOV","Показать FOV"),
    fly           = T("Fly","Полёт"),
    fly_speed     = T("Fly speed","Скорость полёта"),
    noclip        = T("Noclip","Ноуклип"),
    spin          = T("Spin","Кручение"),
    spin_speed    = T("Spin speed","Скорость кручения"),
    speedhack     = T("Speedhack","Спидхак"),
    speedhack_spd = T("Walk speed","Скорость ходьбы"),
    fling         = T("Fling player","Флинг игрока"),
    fling_nick    = T("Nickname","Никнейм"),
    fling_btn     = T("Fling!","Флинг!"),
    fling_notfound= T("Player not found","Игрок не найден"),
    fling_done    = T("Flinged!","Флинг выполнен!"),
    sound_id      = T("Sound ID","ID звука"),
    sound_play    = T("Play","Включить"),
    sound_stop    = T("Stop","Выключить"),
    sound_bind    = T("Bind key","Бинд клавиши"),
    bind_wait     = T("Press a key...","Нажмите клавишу..."),
    unload        = T("Unload","Выгрузить"),
    hint          = T("Insert - show / hide","Insert - показать / скрыть"),
    st_off        = T("Off","Выключено"),
    st_on         = T("Active","Активно"),
}
local lang="RU"
local bindings={}
local function tr(key) local e=L[key]; return e and e[lang] or key end
local function bind(obj,key,prop)
    prop=prop or "Text"; obj[prop]=tr(key)
    bindings[#bindings+1]={obj,key,prop}; return obj
end

-- ═══════════════ МОНТАЖ ═══════════════
local function mountGui(g)
    local ok=pcall(function() if gethui then g.Parent=gethui() else error("") end end)
    if not(ok and g.Parent) then ok=pcall(function() g.Parent=game:GetService("CoreGui") end) end
    if not(ok and g.Parent) then g.Parent=LocalPlayer:WaitForChild("PlayerGui") end
end
local gui=new("ScreenGui",{
    Name=HUB_NAME..tostring(math.random(1000,9999)),
    ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset=true,DisplayOrder=999,
})
mountGui(gui)

-- ═══════════════ ИКОНКИ ═══════════════
local function drawIcon(parent,kind)
    local root=new("Frame",{
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(30,30),BackgroundTransparency=1,
    },parent)
    local shapes={}
    local function shape(x,y,w,h,radius,rotation)
        local f=new("Frame",{
            AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(x,y),
            Size=UDim2.fromOffset(w,h),Rotation=rotation or 0,
            BackgroundColor3=ACCENT,BorderSizePixel=0,
        },root)
        if radius then corner(f,radius) end
        shapes[#shapes+1]=f; return f
    end
    if kind=="flower" then
        for i=0,4 do
            local a=i*math.pi*2/5
            shape(15+math.sin(a)*7.8,15-math.cos(a)*7.8,7,11,3.5,math.deg(a))
        end
        shape(15,15,6,6,6)
    elseif kind=="eye" then
        shape(15,15,20,20,10)
        shape(15,15,14,14,7).BackgroundColor3=Color3.fromRGB(20,20,23)
        shape(15,15,6,6,6)
    elseif kind=="crosshair" then
        shape(15,15,22,22,11)
        shape(15,15,16,16,8).BackgroundColor3=Color3.fromRGB(20,20,23)
        shape(15,7.5,2,7,1)
        shape(15,22.5,2,7,1)
        shape(7.5,15,7,2,1)
        shape(22.5,15,7,2,1)
        shape(15,15,4,4,2)
    elseif kind=="smiley" then
        shape(15,15,22,22,11)
        shape(15,15,16,16,8).BackgroundColor3=Color3.fromRGB(20,20,23)
        shape(11.5,12,3,4.5,1.5)
        shape(18.5,12,3,4.5,1.5)
        shape(15,19.5,9,3,1.5)
    elseif kind=="gear" then
        shape(15,15,20,20,10)
        shape(15,15,12,12,6).BackgroundColor3=Color3.fromRGB(20,20,23)
        for i=0,7 do
            local a=i*math.pi/4
            shape(15+math.sin(a)*11.5,15-math.cos(a)*11.5,5,5,2,math.deg(a))
        end
        shape(15,15,5,5,2.5)
    elseif kind=="close" then
        shape(15,15,17,2,1,45)
        shape(15,15,17,2,1,-45)
    end
    local cutouts={eye=2,crosshair=2,smiley=2,gear=2}
    return function(color,alpha)
        for i,f in ipairs(shapes) do
            if kind=="flower" then
                f.BackgroundColor3=(i==6) and color:Lerp(WHITE,0.72) or color
            elseif cutouts[kind]~=i then
                f.BackgroundColor3=color
            end
            f.BackgroundTransparency=alpha or 0
        end
    end
end

-- ═══════════════ ОКНО ═══════════════
local main=new("Frame",{
    Name="Main",AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(DESIGN_W,DESIGN_H),
    BackgroundColor3=WHITE,BorderSizePixel=0,ClipsDescendants=true,
},gui)
corner(main,14)
stroke(main,Color3.fromRGB(70,70,78),1,0.3)
local uiScale=new("UIScale",{Scale=1},main)
do
    local base=Color3.fromRGB(26,26,30)
    new("UIGradient",{Rotation=35,Color=ColorSequence.new({
        CSK(0,base),CSK(0.36,base),CSK(0.50,base:Lerp(ACCENT,0.30)),
        CSK(0.64,base),CSK(1,base:Lerp(ACCENT,0.08)),
    })},main)
end
local baseScale=1
local function fit()
    local cam=Workspace.CurrentCamera; if not cam then return end
    local vp=cam.ViewportSize
    baseScale=math.clamp(math.min(vp.X*0.9/DESIGN_W,vp.Y*0.9/DESIGN_H),0.4,1.2)
    uiScale.Scale=baseScale
end
local fitConn
local function watchCamera()
    if fitConn then fitConn:Disconnect() end
    local cam=Workspace.CurrentCamera
    if cam then fitConn=connect(cam:GetPropertyChangedSignal("ViewportSize"),fit) end
    fit()
end
watchCamera()
connect(Workspace:GetPropertyChangedSignal("CurrentCamera"),watchCamera)

-- ═══════════════ ХЕДЕР ═══════════════
local header=new("Frame",{Name="Header",Size=UDim2.new(1,0,0,60),BackgroundTransparency=1},main)
local logo=new("Frame",{Position=UDim2.fromOffset(12,11),Size=UDim2.fromOffset(38,38),BackgroundTransparency=1},header)
drawIcon(logo,"flower")(ACCENT)
new("TextLabel",{
    Position=UDim2.fromOffset(60,18),Size=UDim2.fromOffset(150,24),
    BackgroundTransparency=1,Text=HUB_NAME,Font=Enum.Font.GothamMedium,
    TextSize=19,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=ACCENT,
},header)
local closeBtn=new("TextButton",{
    AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,14),
    Size=UDim2.fromOffset(32,32),BackgroundTransparency=1,Text="",AutoButtonColor=false,
},header)
drawIcon(closeBtn,"close")(ACCENT)
local langPill=new("Frame",{
    AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-54,0,17),
    Size=UDim2.fromOffset(78,26),BackgroundColor3=Color3.fromRGB(30,30,34),BorderSizePixel=0,
},header)
corner(langPill,8)
stroke(langPill,Color3.fromRGB(70,70,78),1,0.4)
local function pillBtn(text,x)
    local b=new("TextButton",{
        Position=UDim2.new(0,x,0,2),Size=UDim2.new(0.5,-3,1,-4),
        BackgroundColor3=ACCENT,BackgroundTransparency=1,Text=text,
        Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=GRAY,
        AutoButtonColor=false,BorderSizePixel=0,
    },langPill)
    corner(b,6); return b
end
local enBtn=pillBtn("EN",2)
local ruBtn=pillBtn("RU",37)
local function paintLang()
    local en=(lang=="EN")
    enBtn.BackgroundTransparency=en and 0 or 1; enBtn.TextColor3=en and WHITE or GRAY
    ruBtn.BackgroundTransparency=en and 1 or 0; ruBtn.TextColor3=en and GRAY or WHITE
end
new("Frame",{
    Position=UDim2.new(0,0,0,60),Size=UDim2.new(1,0,0,1),
    BackgroundColor3=Color3.fromRGB(80,80,88),BackgroundTransparency=0.5,BorderSizePixel=0,
},main)

-- ═══════════════ САЙДБАР (4 вкладки) ═══════════════
local sidebar=new("Frame",{
    Name="Sidebar",Position=UDim2.fromOffset(0,61),
    Size=UDim2.new(0,68,1,-61),BackgroundColor3=Color3.fromRGB(20,20,23),
    BackgroundTransparency=0.1,BorderSizePixel=0,
},main)
local indicator=new("Frame",{
    Position=UDim2.fromOffset(0,14),Size=UDim2.fromOffset(3,26),
    BackgroundColor3=ACCENT,BorderSizePixel=0,
},sidebar)
corner(indicator,2)
local function sidebarBtn(yOff,icon)
    local b=new("TextButton",{
        Position=UDim2.fromOffset(0,yOff),Size=UDim2.fromOffset(68,38),
        BackgroundTransparency=1,Text="",AutoButtonColor=false,
    },sidebar)
    drawIcon(b,icon)(ACCENT)
    return b
end
local espTabBtn   = sidebarBtn(8,"eye")
local aimTabBtn   = sidebarBtn(50,"crosshair")
local miscTabBtn  = sidebarBtn(92,"smiley")
local soundTabBtn = sidebarBtn(134,"gear")

-- ═══════════════ ФУТЕР ═══════════════
local footer=new("Frame",{
    Name="Footer",Position=UDim2.new(0,0,1,-26),Size=UDim2.new(1,0,0,26),
    BackgroundColor3=Color3.fromRGB(18,18,20),BackgroundTransparency=0.05,
    BorderSizePixel=0,ZIndex=3,
},main)
bind(new("TextLabel",{
    Position=UDim2.fromOffset(14,0),Size=UDim2.fromOffset(200,26),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,
    TextColor3=GRAY,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4,
},footer),"hint")
local statusLbl=new("TextLabel",{
    AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,0),
    Size=UDim2.fromOffset(260,26),BackgroundTransparency=1,Text=" ",
    Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=ACCENT,
    TextXAlignment=Enum.TextXAlignment.Right,ZIndex=4,
},footer)
local toastToken=0
local function toast(key)
    toastToken+=1; local my=toastToken
    statusLbl.Text=tr(key)
    task.delay(2.4,function()
        if toastToken==my and statusLbl.Parent then statusLbl.Text=" " end
    end)
end

-- ═══════════════ КОНТЕНТ + 4 СТРАНИЦЫ ═══════════════
local content=new("Frame",{
    Name="Content",Position=UDim2.fromOffset(68,61),
    Size=UDim2.new(1,-68,1,-87),BackgroundTransparency=1,
},main)
local tabTitle=bind(new("TextLabel",{
    Position=UDim2.fromOffset(16,8),Size=UDim2.new(1,-30,0,20),
    BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=13,
    TextColor3=GRAY,TextXAlignment=Enum.TextXAlignment.Left,
},content),"tab_esp")

local function makePage()
    local p=new("ScrollingFrame",{
        Position=UDim2.fromOffset(0,32),Size=UDim2.new(1,0,1,-32),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,
        ScrollBarImageColor3=Color3.fromRGB(120,120,128),
        CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    },content)
    new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},p)
    new("UIPadding",{
        PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,16),
        PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,10),
    },p)
    return p
end
local page_esp   = makePage()
local page_aim   = makePage()
local page_misc  = makePage()
local page_sound = makePage()
page_aim.Visible   = false
page_misc.Visible  = false
page_sound.Visible = false

local currentTab="esp"
local TAB_Y={esp=14,aim=56,misc=98,sound=140}
local TAB_KEY={esp="tab_esp",aim="tab_aimbot",misc="tab_misc",sound="tab_sound"}
local function switchTab(tab)
    if currentTab==tab then return end
    currentTab=tab
    page_esp.Visible   = (tab=="esp")
    page_aim.Visible   = (tab=="aim")
    page_misc.Visible  = (tab=="misc")
    page_sound.Visible = (tab=="sound")
    tabTitle.Text=tr(TAB_KEY[tab])
    TweenService:Create(indicator,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
        Position=UDim2.fromOffset(0,TAB_Y[tab]),
    }):Play()
end
connect(espTabBtn.MouseButton1Click,  function() switchTab("esp")   end)
connect(aimTabBtn.MouseButton1Click,  function() switchTab("aim")   end)
connect(miscTabBtn.MouseButton1Click, function() switchTab("misc")  end)
connect(soundTabBtn.MouseButton1Click,function() switchTab("sound") end)

-- ═══════════════ UI КОМПОНЕНТЫ ═══════════════
local function rowBase(h,parent)
    local f=new("Frame",{
        Size=UDim2.new(1,0,0,h),BackgroundColor3=ROW_BG,
        BackgroundTransparency=0.35,BorderSizePixel=0,
    },parent)
    corner(f,9); return f
end
local function rowLabel(parent,key)
    return bind(new("TextLabel",{
        BackgroundTransparency=1,Position=UDim2.fromOffset(14,0),
        Size=UDim2.new(1,-84,1,0),Font=Enum.Font.GothamMedium,TextSize=15,
        TextColor3=Color3.fromRGB(235,235,240),TextXAlignment=Enum.TextXAlignment.Left,
    },parent),key)
end
local function addHeader(key,parent)
    return bind(new("TextLabel",{
        Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,
        Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=GRAY,
        TextXAlignment=Enum.TextXAlignment.Left,
    },parent),key)
end
local function flash(b)
    b.BackgroundTransparency=0.05
    TweenService:Create(b,TweenInfo.new(0.25),{BackgroundTransparency=0.35}):Play()
end
local function addToggle(key,parent,cb)
    local row=rowBase(42,parent)
    rowLabel(row,key)
    local sw=new("Frame",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(42,22),BackgroundColor3=OFF_COL,BorderSizePixel=0,
    },row)
    corner(sw,11)
    local knob=new("Frame",{
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),
        Size=UDim2.fromOffset(16,16),BackgroundColor3=WHITE,BorderSizePixel=0,
    },sw)
    corner(knob,8)
    local hit=new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},row)
    local state=false
    local obj={}
    function obj.Set(v,silent)
        state=v and true or false
        TweenService:Create(knob,TweenInfo.new(0.15),{
            Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0),
        }):Play()
        TweenService:Create(sw,TweenInfo.new(0.15),{
            BackgroundColor3=state and ACCENT or OFF_COL,
        }):Play()
        if not silent and cb then cb(state) end
    end
    connect(hit.MouseButton1Click,function() obj.Set(not state) end)
    return obj
end
local function addButton(key,parent,cb)
    local holder=new("Frame",{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1},parent)
    local b=new("TextButton",{
        Size=UDim2.fromScale(1,1),BackgroundColor3=ROW_BG,BackgroundTransparency=0.35,
        BorderSizePixel=0,Text="",AutoButtonColor=false,
    },holder)
    corner(b,9)
    local lbl=bind(new("TextLabel",{
        Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        Font=Enum.Font.GothamMedium,TextSize=14,TextColor3=ACCENT,TextWrapped=true,
    },b),key)
    connect(b.MouseButton1Click,function() flash(b); cb(b,lbl) end)
    return lbl
end
local function addSlider(key,minV,maxV,default,fmt,parent,cb)
    local row=rowBase(56,parent)
    bind(new("TextLabel",{
        Position=UDim2.fromOffset(14,4),Size=UDim2.new(1,-100,0,24),
        BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=15,
        TextColor3=Color3.fromRGB(235,235,240),TextXAlignment=Enum.TextXAlignment.Left,
    },row),key)
    local val=new("TextLabel",{
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,4),
        Size=UDim2.fromOffset(80,24),BackgroundTransparency=1,
        Font=Enum.Font.GothamMedium,TextSize=14,TextColor3=GRAY,
        TextXAlignment=Enum.TextXAlignment.Right,
    },row)
    local track=new("Frame",{
        Position=UDim2.new(0,14,0,38),Size=UDim2.new(1,-28,0,6),
        BackgroundColor3=OFF_COL,BorderSizePixel=0,
    },row)
    corner(track,3)
    local fill=new("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=ACCENT,BorderSizePixel=0},track)
    corner(fill,3)
    local knob=new("Frame",{
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),
        Size=UDim2.fromOffset(16,16),BackgroundColor3=WHITE,BorderSizePixel=0,
    },track)
    corner(knob,8)
    local hit=new("TextButton",{
        Position=UDim2.new(0,6,0,26),Size=UDim2.new(1,-12,0,28),
        BackgroundTransparency=1,Text=" ",ZIndex=5,
    },row)
    local value=default
    local function render()
        local a=(value-minV)/(maxV-minV)
        fill.Size=UDim2.fromScale(a,1)
        knob.Position=UDim2.fromScale(a,0.5)
        val.Text=fmt(value)
    end
    local function setFromX(x)
        local w=track.AbsoluteSize.X; if w<=0 then return end
        local a=math.clamp((x-track.AbsolutePosition.X)/w,0,1)
        value=minV+(maxV-minV)*a
        render(); cb(value)
    end
    local dragging=false
    connect(hit.InputBegan,function(input)
        local t=input.UserInputType
        if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
            dragging=true
            for _,p in ipairs({page_esp,page_aim,page_misc,page_sound}) do p.ScrollingEnabled=false end
            setFromX(input.Position.X)
        end
    end)
    connect(UserInputService.InputChanged,function(input)
        local t=input.UserInputType
        if dragging and (t==Enum.UserInputType.MouseMovement or t==Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    connect(UserInputService.InputEnded,function(input)
        local t=input.UserInputType
        if dragging and (t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch) then
            dragging=false
            for _,p in ipairs({page_esp,page_aim,page_misc,page_sound}) do p.ScrollingEnabled=true end
        end
    end)
    render()
end
local function addTextBox(key,parent)
    local row=rowBase(42,parent)
    rowLabel(row,key)
    local box=new("TextBox",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(150,28),BackgroundColor3=Color3.fromRGB(30,30,34),
        Text="",PlaceholderText="rbxassetid://...",
        Font=Enum.Font.Gotham,TextSize=13,TextColor3=WHITE,
        PlaceholderColor3=GRAY,ClearTextOnFocus=false,BorderSizePixel=0,
    },row)
    corner(box,6)
    stroke(box,Color3.fromRGB(70,70,78),1,0.4)
    return box
end

-- ═══════════════ СОСТОЯНИЕ ═══════════════
local ESP={
    guardian=false,prisoner=false,criminal=false,
    fillTransparency=0.75,outlineOnly=false,
    highlights={},
}
local Aimbot={
    enabled=false,teamCheck=true,ignorePrisoners=false,
    distance=300,smooth=0.5,fov=120,drawFov=false,conn=nil,
}
local Fly={enabled=false,speed=50,conn=nil,bv=nil,bg=nil}
local Noclip={enabled=false,conn=nil}
local Spin={enabled=false,speed=5,conn=nil,bav=nil}
local Speedhack={enabled=false,speed=50,conn=nil}
local SoundPlayer={playing=false,soundId="",bindKey=nil,sound=nil,waitingForBind=false}

local COLORS={
    Guardian=Color3.fromRGB(50,140,255),
    Prisoner=Color3.fromRGB(255,170,50),
    Criminal=Color3.fromRGB(255,60,60),
}

-- ═══════════════ КОМАНДЫ ═══════════════
local function getPlayerTeam(plr)
    local team=plr.Team
    if team then
        local tn=team.Name:lower()
        if tn:find("guard") or tn:find("police") or tn:find("cop") then return "Guardian" end
        if tn:find("inmate") or tn:find("prisoner") or tn:find("convict") then return "Prisoner" end
        if tn:find("criminal") then return "Criminal" end
    end
    if plr.TeamColor==Enum.TeamColor.NewYeller  then return "Prisoner"  end
    if plr.TeamColor==Enum.TeamColor.BrightBlue then return "Guardian"  end
    if plr.TeamColor==Enum.TeamColor.BrightRed  then return "Criminal"  end
    return nil
end

-- ═══════════════ РЕЙКАСТ ═══════════════
local function isTargetVisible(targetPart,targetChar)
    local cam=Workspace.CurrentCamera
    if not cam then return false end
    local origin=cam.CFrame.Position
    local targetPos=targetPart.Position
    local direction=targetPos-origin
    local dist=direction.Magnitude
    local rayParams=RaycastParams.new()
    rayParams.FilterType=Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances={LocalPlayer.Character}
    rayParams.IgnoreWater=true
    local result=Workspace:Raycast(origin,direction,rayParams)
    if not result then return true end
    local hitDist=(result.Position-origin).Magnitude
    if hitDist>=dist-2 then return true end
    local inst=result.Instance
    while inst do
        if inst==targetChar then return true end
        inst=inst.Parent
    end
    return false
end

-- ═══════════════ ESP ENGINE ═══════════════
local function removeHighlight(plr)
    if ESP.highlights[plr] then safeDestroy(ESP.highlights[plr]); ESP.highlights[plr]=nil end
end
local function applyHighlight(plr,teamKey)
    if plr==LocalPlayer then return end
    local char=plr.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local color=COLORS[teamKey] or WHITE
    if ESP.highlights[plr] and ESP.highlights[plr].Parent~=char then
        safeDestroy(ESP.highlights[plr]); ESP.highlights[plr]=nil
    end
    if not ESP.highlights[plr] then
        ESP.highlights[plr]=new("Highlight",{
            Name="FlowerialESP",DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,
        },char)
    end
    local h=ESP.highlights[plr]; if not h then return end
    h.FillColor=color; h.OutlineColor=color
    if ESP.outlineOnly then
        h.FillTransparency=1; h.OutlineTransparency=0
    else
        h.FillTransparency=ESP.fillTransparency; h.OutlineTransparency=0
    end
end
local function espNeeded(plr)
    if plr==LocalPlayer then return false end
    local team=getPlayerTeam(plr)
    if team=="Guardian" then return ESP.guardian end
    if team=="Prisoner" then return ESP.prisoner end
    if team=="Criminal" then return ESP.criminal end
    return false
end
local function refreshESPForPlayer(plr)
    if espNeeded(plr) then applyHighlight(plr,getPlayerTeam(plr))
    else removeHighlight(plr) end
end
local function refreshAllESP()
    for _,plr in ipairs(Players:GetPlayers()) do refreshESPForPlayer(plr) end
end

-- ═══════════════ ОТСЛЕЖИВАНИЕ ИГРОКОВ ═══════════════
local playerConns={}
local function trackPlayer(plr)
    if playerConns[plr] then return end
    local list={}
    list[#list+1]=connect(plr.CharacterAdded,function()
        task.delay(0.5,function() if gui.Parent then refreshESPForPlayer(plr) end end)
    end)
    list[#list+1]=connect(plr.CharacterRemoving,function() removeHighlight(plr) end)
    list[#list+1]=connect(plr:GetPropertyChangedSignal("Team"),function()
        task.defer(function() if gui.Parent then refreshESPForPlayer(plr) end end)
    end)
    playerConns[plr]=list
end
local function untrackPlayer(plr)
    local list=playerConns[plr]
    if list then for _,c in ipairs(list) do pcall(function() c:Disconnect() end) end; playerConns[plr]=nil end
end
for _,plr in ipairs(Players:GetPlayers()) do
    if plr~=LocalPlayer then trackPlayer(plr) end
end
connect(Players.PlayerAdded,function(plr) if plr~=LocalPlayer then trackPlayer(plr) end end)
connect(Players.PlayerRemoving,function(plr) removeHighlight(plr); untrackPlayer(plr) end)

-- ═══════════════ ESP LOOP ═══════════════
local espConn=nil
local function anyESPOn() return ESP.guardian or ESP.prisoner or ESP.criminal end
local function startESP()
    if espConn then return end
    espConn=connect(RunService.Heartbeat,function() pcall(refreshAllESP) end)
end
local function stopESP()
    if espConn then espConn:Disconnect(); espConn=nil end
end
local function onESPToggle()
    if anyESPOn() then startESP(); refreshAllESP()
    else stopESP(); refreshAllESP() end
end

-- ═══════════════ AIMBOT ENGINE ═══════════════
local fovCircle=new("Frame",{
    AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
    BackgroundTransparency=1,ZIndex=50,Visible=false,
},gui)
corner(fovCircle,999)
new("UIStroke",{Color=ACCENT,Thickness=1.5,Transparency=0.4},fovCircle)

local function updateFovCircle()
    if not Aimbot.drawFov then fovCircle.Visible=false; return end
    fovCircle.Visible=true
    local cam=Workspace.CurrentCamera; if not cam then return end
    local vp=cam.ViewportSize
    local radiusPx=(Aimbot.fov/cam.FieldOfView)*(vp.Y/2)
    fovCircle.Size=UDim2.fromOffset(radiusPx*2,radiusPx*2)
end
local function isAlly(plr)
    if not Aimbot.teamCheck then return false end
    local myTeam=LocalPlayer.Team; local theirTeam=plr.Team
    if myTeam and theirTeam and myTeam==theirTeam then return true end
    return false
end
local function aimbotStep()
    if not Aimbot.enabled then return end
    local cam=Workspace.CurrentCamera; if not cam then return end
    updateFovCircle()
    local bestTarget=nil; local bestAngle=math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LocalPlayer then continue end
        if isAlly(plr) then continue end
        if Aimbot.ignorePrisoners and getPlayerTeam(plr)=="Prisoner" then continue end
        local char=plr.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum and hum.Health>0) then continue end
        local dist=(cam.CFrame.Position-hrp.Position).Magnitude
        if dist>Aimbot.distance then continue end
        local dir=(hrp.Position-cam.CFrame.Position).Unit
        local dot=math.clamp(cam.CFrame.LookVector:Dot(dir),-1,1)
        local angle=math.deg(math.acos(dot))
        if angle<=Aimbot.fov/2 and angle<bestAngle then
            if isTargetVisible(hrp,char) then
                bestAngle=angle; bestTarget=hrp
            end
        end
    end
    if bestTarget then
        local targetCF=CFrame.new(cam.CFrame.Position,bestTarget.Position)
        cam.CFrame=cam.CFrame:Lerp(targetCF,Aimbot.smooth)
    end
end
local function startAimbot()
    if Aimbot.conn then return end
    Aimbot.conn=connect(RunService.RenderStepped,function() pcall(aimbotStep) end)
end
local function stopAimbot()
    if Aimbot.conn then Aimbot.conn:Disconnect(); Aimbot.conn=nil end
    fovCircle.Visible=false
end

-- ═══════════════ FLY ═══════════════
local function startFly()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    Fly.bg=new("BodyGyro",{
        MaxTorque=Vector3.new(math.huge,math.huge,math.huge),
        CFrame=hrp.CFrame,
    },hrp)
    Fly.bv=new("BodyVelocity",{
        MaxForce=Vector3.new(math.huge,math.huge,math.huge),
        Velocity=Vector3.zero,
    },hrp)
    Fly.conn=connect(RunService.RenderStepped,function()
        if not Fly.enabled then return end
        local cam=Workspace.CurrentCamera; if not cam then return end
        Fly.bg.CFrame=cam.CFrame
        local dir=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
        Fly.bv.Velocity=dir.Magnitude>0 and dir.Unit*Fly.speed or Vector3.zero
    end)
end
local function stopFly()
    if Fly.conn then Fly.conn:Disconnect(); Fly.conn=nil end
    if Fly.bv then safeDestroy(Fly.bv); Fly.bv=nil end
    if Fly.bg then safeDestroy(Fly.bg); Fly.bg=nil end
end

-- ═══════════════ NOCLIP (исправленный) ═══════════════
local function startNoclip()
    Noclip.conn=connect(RunService.Stepped,function()
        local char=LocalPlayer.Character
        if not char then return end
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide=false
            end
        end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CanCollide=false end
    end)
end
local function stopNoclip()
    if Noclip.conn then Noclip.conn:Disconnect(); Noclip.conn=nil end
end

-- ═══════════════ SPIN (исправленный) ═══════════════
local function startSpin()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    Spin.bav=new("BodyAngularVelocity",{
        AngularVelocity=Vector3.new(0,Spin.speed,0),
        MaxTorque=Vector3.new(0,math.huge,0),
    },hrp)
    Spin.conn=connect(RunService.RenderStepped,function()
        if Spin.bav and Spin.bav.Parent then
            Spin.bav.AngularVelocity=Vector3.new(0,Spin.speed,0)
        end
    end)
end
local function stopSpin()
    if Spin.conn then Spin.conn:Disconnect(); Spin.conn=nil end
    if Spin.bav then safeDestroy(Spin.bav); Spin.bav=nil end
end

-- ═══════════════ SPEEDHACK ═══════════════
local function startSpeedhack()
    Speedhack.conn=connect(RunService.RenderStepped,function()
        local char=LocalPlayer.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=Speedhack.speed end
    end)
end
local function stopSpeedhack()
    if Speedhack.conn then Speedhack.conn:Disconnect(); Speedhack.conn=nil end
    local char=LocalPlayer.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed=16 end
end

-- ═══════════════ FLING ═══════════════
local function flingPlayer(nickname)
    local target=nil
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower()==nickname:lower() then target=plr; break end
    end
    if not target then toast("fling_notfound"); return end
    local char=target.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then toast("fling_notfound"); return end
    local part=new("Part",{
        Anchored=false,CanCollide=false,CanQuery=false,CanTouch=false,
        Transparency=1,Size=Vector3.new(1,1,1),CFrame=hrp.CFrame,Massless=true,
    },Workspace)
    new("BodyVelocity",{
        MaxForce=Vector3.new(math.huge,math.huge,math.huge),
        Velocity=Vector3.new(math.random(-500,500),math.random(300,600),math.random(-500,500)),
    },part)
    new("WeldConstraint",{Part0=part,Part1=hrp},part)
    task.delay(0.4,function() safeDestroy(part) end)
    toast("fling_done")
end

-- ═══════════════ SOUNDPLAYER ═══════════════
local function getOrCreateSound()
    if not SoundPlayer.sound then
        SoundPlayer.sound=new("Sound",{Volume=0.5,Looped=true},SoundService)
    end
    return SoundPlayer.sound
end
local function playSound()
    local id=tonumber(soundIdBox and soundIdBox.Text or "")
    if not id then return end
    local s=getOrCreateSound()
    s.SoundId="rbxassetid://"..id
    s:Play()
    SoundPlayer.playing=true
end
local function stopSound()
    if SoundPlayer.sound then SoundPlayer.sound:Stop() end
    SoundPlayer.playing=false
end
local function toggleSoundByBind()
    if SoundPlayer.playing then stopSound() else playSound() end
end

-- ═══════════════ СТРАНИЦА ESP ═══════════════
addHeader("hd_control",page_esp)
addToggle("guardian_esp",page_esp,function(v) ESP.guardian=v; onESPToggle(); toast(v and "st_on" or "st_off") end)
addToggle("prisoner_esp",page_esp,function(v) ESP.prisoner=v; onESPToggle(); toast(v and "st_on" or "st_off") end)
addToggle("criminal_esp",page_esp,function(v) ESP.criminal=v; onESPToggle(); toast(v and "st_on" or "st_off") end)
addHeader("hd_settings",page_esp)
addSlider("fill_transp",0,100,75,function(v) return math.floor(v).."%" end,page_esp,function(v) ESP.fillTransparency=v/100 end)
addToggle("outline",page_esp,function(v) ESP.outlineOnly=v end)

-- ═══════════════ СТРАНИЦА AIMBOT ═══════════════
addHeader("hd_control",page_aim)
addToggle("aim_toggle",page_aim,function(v)
    Aimbot.enabled=v
    if v then startAimbot() else stopAimbot() end
    toast(v and "st_on" or "st_off")
end)
addToggle("team_check",page_aim,function(v) Aimbot.teamCheck=v end)
addToggle("ignore_prison",page_aim,function(v) Aimbot.ignorePrisoners=v end)
addHeader("hd_settings",page_aim)
addSlider("aim_dist",10,1000,300,function(v) return math.floor(v).." st" end,page_aim,function(v) Aimbot.distance=v end)
addSlider("aim_smooth",1,100,50,function(v) return math.floor(v).."%" end,page_aim,function(v) Aimbot.smooth=v/100 end)
addSlider("aim_fov",10,360,120,function(v) return math.floor(v).."°" end,page_aim,function(v) Aimbot.fov=v end)
addToggle("draw_fov",page_aim,function(v) Aimbot.drawFov=v; if not v then fovCircle.Visible=false end end)

-- ═══════════════ СТРАНИЦА MISC ═══════════════
addHeader("hd_control",page_misc)
addToggle("fly",page_misc,function(v)
    Fly.enabled=v
    if v then startFly() else stopFly() end
    toast(v and "st_on" or "st_off")
end)
addSlider("fly_speed",10,300,50,function(v) return math.floor(v).." st/s" end,page_misc,function(v) Fly.speed=v end)
addToggle("noclip",page_misc,function(v)
    Noclip.enabled=v
    if v then startNoclip() else stopNoclip() end
    toast(v and "st_on" or "st_off")
end)
addToggle("spin",page_misc,function(v)
    Spin.enabled=v
    if v then startSpin() else stopSpin() end
    toast(v and "st_on" or "st_off")
end)
addSlider("spin_speed",1,30,5,function(v) return math.floor(v).."°/f" end,page_misc,function(v) Spin.speed=v end)
addToggle("speedhack",page_misc,function(v)
    Speedhack.enabled=v
    if v then startSpeedhack() else stopSpeedhack() end
    toast(v and "st_on" or "st_off")
end)
addSlider("speedhack_spd",16,200,50,function(v) return math.floor(v).." st/s" end,page_misc,function(v) Speedhack.speed=v end)
addHeader("hd_settings",page_misc)
local flingBox=addTextBox("fling",page_misc)
addButton("fling_btn",page_misc,function()
    local nick=flingBox.Text
    if nick and nick~="" then flingPlayer(nick) end
end)

-- ═══════════════ СТРАНИЦА SOUND ═══════════════
addHeader("hd_control",page_sound)
local soundIdBox=addTextBox("sound_id",page_sound)

local playLbl=addButton("sound_play",page_sound,function() playSound(); toast("st_on") end)
local stopLbl=addButton("sound_stop",page_sound,function() stopSound(); toast("st_off") end)

local bindBtnLbl
local function updateBindText()
    if not bindBtnLbl then return end
    if SoundPlayer.waitingForBind then
        bindBtnLbl.Text=tr("bind_wait")
    elseif SoundPlayer.bindKey then
        local keyName=SoundPlayer.bindKey.Name
        bindBtnLbl.Text=tr("sound_bind")..": "..keyName
    else
        bindBtnLbl.Text=tr("sound_bind")
    end
end
bindBtnLbl=addButton("sound_bind",page_sound,function(btn,lbl)
    SoundPlayer.waitingForBind=true
    lbl.Text=tr("bind_wait")
end)

connect(UserInputService.InputBegan,function(input,gpe)
    if SoundPlayer.waitingForBind then
        if input.UserInputType==Enum.UserInputType.Keyboard then
            SoundPlayer.bindKey=input.KeyCode
            SoundPlayer.waitingForBind=false
            updateBindText()
        end
        return
    end
    if SoundPlayer.bindKey and input.KeyCode==SoundPlayer.bindKey and not gpe then
        if not UserInputService:GetFocusedTextBox() then
            toggleSoundByBind()
        end
    end
end)

-- ═══════════════ UNLOAD ═══════════════
addButton("unload",page_esp,function()
    if genv.__FlowerialCleanup then genv.__FlowerialCleanup() end
end)

-- ═══════════════ ЯЗЫК ═══════════════
local function setLang(l)
    lang=l
    for _,b in ipairs(bindings) do b[1][b[3]]=tr(b[2]) end
    updateBindText()
    paintLang()
end
connect(enBtn.MouseButton1Click,function() setLang("EN") end)
connect(ruBtn.MouseButton1Click,function() setLang("RU") end)

-- ═══════════════ SHOW / HIDE ═══════════════
local shown,transition=true,0
local function setShown(v)
    transition+=1; local token=transition
    shown=v
    if v then
        main.Visible=true
        uiScale.Scale=baseScale*0.84
        TweenService:Create(uiScale,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=baseScale}):Play()
    else
        TweenService:Create(uiScale,TweenInfo.new(0.17,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=baseScale*0.84}):Play()
        task.delay(0.17,function()
            if token==transition and gui.Parent then main.Visible=false end
        end)
    end
end
connect(closeBtn.MouseButton1Click,function() setShown(false) end)
connect(UserInputService.InputBegan,function(input,gpe)
    if gpe or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode==Enum.KeyCode.Insert then setShown(not shown) end
end)

-- ═══════════════ DRAG ═══════════════
local dragging,dragStart,startPos=false,nil,nil
connect(header.InputBegan,function(input)
    local t=input.UserInputType
    if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
        dragging,dragStart,startPos=true,input.Position,main.Position
    end
end)
connect(UserInputService.InputChanged,function(input)
    local t=input.UserInputType
    if dragging and (t==Enum.UserInputType.MouseMovement or t==Enum.UserInputType.Touch) then
        local d=input.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
connect(UserInputService.InputEnded,function(input)
    local t=input.UserInputType
    if dragging and (t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch) then dragging=false end
end)

-- ═══════════════ CLEANUP ═══════════════
genv.__FlowerialCleanup=function()
    stopESP(); stopAimbot(); stopFly(); stopNoclip(); stopSpin(); stopSpeedhack(); stopSound()
    if SoundPlayer.sound then safeDestroy(SoundPlayer.sound); SoundPlayer.sound=nil end
    for plr,_ in pairs(ESP.highlights) do removeHighlight(plr) end
    for plr,_ in pairs(playerConns) do untrackPlayer(plr) end
    for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    table.clear(conns)
    safeDestroy(gui)
    genv.__FlowerialCleanup=nil
end

-- ═══════════════ СТАРТ ═══════════════
setLang("RU")
uiScale.Scale=baseScale*0.9
TweenService:Create(uiScale,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=baseScale}):Play()