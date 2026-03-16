-- ============================================
--      LoadMap v2.0 | Delta Executor
--   Auto scan Workspace/ → tap → load
--
--   By  : gixss
--   Free: 100% - DILARANG DIPERJUALBELIKAN!
-- ============================================

-- Cleanup
for _, n in ipairs({"LoadMapGUI"}) do
    pcall(function() game:GetService("CoreGui"):FindFirstChild(n):Destroy() end)
    pcall(function()
        local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg and pg:FindFirstChild(n) then pg:FindFirstChild(n):Destroy() end
    end)
end

local gp
pcall(function() gp = game:GetService("CoreGui") end)
if not gp then gp = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

-- ============================================================
-- TEMA
-- ============================================================
local T = {
    BG       = Color3.fromRGB(8,  8,  15),
    PANEL    = Color3.fromRGB(13, 13, 24),
    CARD     = Color3.fromRGB(19, 19, 34),
    CARD2    = Color3.fromRGB(25, 25, 44),
    ITEM     = Color3.fromRGB(22, 22, 38),
    ITEM_SEL = Color3.fromRGB(30, 24, 58),
    INPUT_BG = Color3.fromRGB(11, 11, 20),
    GOLD     = Color3.fromRGB(212,175,55),
    GOLD_L   = Color3.fromRGB(255,215,100),
    GOLD_D   = Color3.fromRGB(95, 72, 15),
    GREEN    = Color3.fromRGB(50, 215,110),
    GREEN_D  = Color3.fromRGB(20,  90, 45),
    BLUE     = Color3.fromRGB(55, 120,245),
    BLUE_D   = Color3.fromRGB(20,  45,110),
    RED      = Color3.fromRGB(215, 55, 55),
    ORANGE   = Color3.fromRGB(225,135, 30),
    TXT_H    = Color3.fromRGB(242,236,212),
    TXT_M    = Color3.fromRGB(200,195,232),
    TXT_S    = Color3.fromRGB(118,112,155),
    TXT_D    = Color3.fromRGB(60,  55, 85),
    STROKE_G = Color3.fromRGB(90,  70, 15),
    STROKE   = Color3.fromRGB(42,  40, 68),
}

-- ============================================================
-- ROOT
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "LoadMapGUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 9999
SG.Parent = gp

local W = 295
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,W,0,10)
Main.Position = UDim2.new(0.5,-W/2,0.5,-210)
Main.BackgroundColor3 = T.PANEL
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,14)
local ms = Instance.new("UIStroke",Main)
ms.Color = T.STROKE_G; ms.Thickness = 1.5

local glowLine = Instance.new("Frame",Main)
glowLine.Size = UDim2.new(0.65,0,0,1)
glowLine.Position = UDim2.new(0.175,0,0,1)
glowLine.BackgroundColor3 = T.GOLD_D
glowLine.BorderSizePixel = 0
Instance.new("UICorner",glowLine).CornerRadius = UDim.new(0,99)

-- ============================================================
-- TOPBAR
-- ============================================================
local Topbar = Instance.new("Frame",Main)
Topbar.Size = UDim2.new(1,0,0,44)
Topbar.BackgroundColor3 = Color3.fromRGB(5,5,10)
Topbar.BorderSizePixel = 0
Instance.new("UICorner",Topbar).CornerRadius = UDim.new(0,14)
local tbFix = Instance.new("Frame",Topbar)
tbFix.Size=UDim2.new(1,0,0.5,0); tbFix.Position=UDim2.new(0,0,0.5,0)
tbFix.BackgroundColor3=Color3.fromRGB(5,5,10); tbFix.BorderSizePixel=0

local iconBox = Instance.new("Frame",Topbar)
iconBox.Size=UDim2.new(0,28,0,28); iconBox.Position=UDim2.new(0,10,0.5,-14)
iconBox.BackgroundColor3=T.GOLD_D; iconBox.BorderSizePixel=0
Instance.new("UICorner",iconBox).CornerRadius=UDim.new(0,7)
local iconLbl=Instance.new("TextLabel",iconBox)
iconLbl.Size=UDim2.new(1,0,1,0); iconLbl.BackgroundTransparency=1
iconLbl.Text="⬆"; iconLbl.TextColor3=T.GOLD_L; iconLbl.TextSize=14; iconLbl.Font=Enum.Font.GothamBold

local titleF=Instance.new("Frame",Topbar)
titleF.Size=UDim2.new(1,-84,1,0); titleF.Position=UDim2.new(0,44,0,0); titleF.BackgroundTransparency=1
local t1=Instance.new("TextLabel",titleF)
t1.Size=UDim2.new(1,0,0.55,0); t1.Position=UDim2.new(0,0,0.05,0); t1.BackgroundTransparency=1
t1.Text="LOADMAP v2.0  |  by gixss"; t1.TextColor3=T.TXT_H; t1.TextSize=12
t1.Font=Enum.Font.GothamBold; t1.TextXAlignment=Enum.TextXAlignment.Left
local t2=Instance.new("TextLabel",titleF)
t2.Size=UDim2.new(1,0,0.4,0); t2.Position=UDim2.new(0,0,0.6,0); t2.BackgroundTransparency=1
t2.Text="Auto scan Workspace/  •  FREE 100%"; t2.TextColor3=T.GOLD; t2.TextSize=9
t2.Font=Enum.Font.Gotham; t2.TextXAlignment=Enum.TextXAlignment.Left

local closeBox=Instance.new("Frame",Topbar)
closeBox.Size=UDim2.new(0,26,0,26); closeBox.Position=UDim2.new(1,-33,0.5,-13)
closeBox.BackgroundColor3=Color3.fromRGB(55,15,15); closeBox.BorderSizePixel=0
Instance.new("UICorner",closeBox).CornerRadius=UDim.new(0,7)
Instance.new("UIStroke",closeBox).Color=T.RED
local closeBtn=Instance.new("TextButton",closeBox)
closeBtn.Size=UDim2.new(1,0,1,0); closeBtn.BackgroundTransparency=1
closeBtn.Text="✕"; closeBtn.TextColor3=T.RED; closeBtn.TextSize=12; closeBtn.Font=Enum.Font.GothamBold
closeBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

local divTop=Instance.new("Frame",Main)
divTop.Size=UDim2.new(1,-20,0,1); divTop.Position=UDim2.new(0,10,0,44)
divTop.BackgroundColor3=T.STROKE_G; divTop.BorderSizePixel=0

-- ============================================================
-- STATUS PILL
-- ============================================================
local sPill=Instance.new("Frame",Main)
sPill.Size=UDim2.new(1,-20,0,26); sPill.Position=UDim2.new(0,10,0,51)
sPill.BackgroundColor3=T.CARD; sPill.BorderSizePixel=0
Instance.new("UICorner",sPill).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",sPill).Color=T.STROKE
local sDot=Instance.new("Frame",sPill)
sDot.Size=UDim2.new(0,7,0,7); sDot.Position=UDim2.new(0,9,0.5,-3.5)
sDot.BackgroundColor3=T.GOLD; sDot.BorderSizePixel=0
Instance.new("UICorner",sDot).CornerRadius=UDim.new(0,99)
local sLbl=Instance.new("TextLabel",sPill)
sLbl.Size=UDim2.new(1,-26,1,0); sLbl.Position=UDim2.new(0,22,0,0)
sLbl.BackgroundTransparency=1; sLbl.Text="Scanning Workspace/..."
sLbl.TextColor3=T.TXT_M; sLbl.TextSize=10; sLbl.Font=Enum.Font.Gotham
sLbl.TextXAlignment=Enum.TextXAlignment.Left; sLbl.TextWrapped=true

local function setStatus(msg,col)
    sLbl.Text=msg; sDot.BackgroundColor3=col or T.GOLD
end

-- ============================================================
-- FILE COUNT BADGE + REFRESH BTN
-- ============================================================
local topRow=Instance.new("Frame",Main)
topRow.Size=UDim2.new(1,-20,0,22); topRow.Position=UDim2.new(0,10,0,83)
topRow.BackgroundTransparency=1

local countLbl=Instance.new("TextLabel",topRow)
countLbl.Size=UDim2.new(0.6,0,1,0); countLbl.BackgroundTransparency=1
countLbl.Text="FILE DITEMUKAN"; countLbl.TextColor3=T.GOLD; countLbl.TextSize=9
countLbl.Font=Enum.Font.GothamBold; countLbl.TextXAlignment=Enum.TextXAlignment.Left

local refreshBox=Instance.new("Frame",topRow)
refreshBox.Size=UDim2.new(0,80,1,0); refreshBox.Position=UDim2.new(1,-80,0,0)
refreshBox.BackgroundColor3=T.CARD2; refreshBox.BorderSizePixel=0
Instance.new("UICorner",refreshBox).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",refreshBox).Color=T.STROKE
local refreshBtn=Instance.new("TextButton",refreshBox)
refreshBtn.Size=UDim2.new(1,0,1,0); refreshBtn.BackgroundTransparency=1
refreshBtn.Text="↺  Refresh"; refreshBtn.TextColor3=T.TXT_S; refreshBtn.TextSize=10
refreshBtn.Font=Enum.Font.GothamBold

-- ============================================================
-- SCROLL LIST
-- ============================================================
local listBg=Instance.new("Frame",Main)
listBg.Size=UDim2.new(1,-20,0,210); listBg.Position=UDim2.new(0,10,0,108)
listBg.BackgroundColor3=T.CARD; listBg.BorderSizePixel=0
Instance.new("UICorner",listBg).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",listBg).Color=T.STROKE

local scroll=Instance.new("ScrollingFrame",listBg)
scroll.Size=UDim2.new(1,-4,1,-4); scroll.Position=UDim2.new(0,2,0,2)
scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
scroll.ScrollBarThickness=3
scroll.ScrollBarImageColor3=Color3.fromRGB(80,75,120)
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.CanvasSize=UDim2.new(0,0,0,0)
scroll.ScrollingDirection=Enum.ScrollingDirection.Y
local sLayout=Instance.new("UIListLayout",scroll)
sLayout.Padding=UDim.new(0,3); sLayout.SortOrder=Enum.SortOrder.LayoutOrder
local sPad=Instance.new("UIPadding",scroll)
sPad.PaddingTop=UDim.new(0,4); sPad.PaddingBottom=UDim.new(0,4)
sPad.PaddingLeft=UDim.new(0,4); sPad.PaddingRight=UDim.new(0,4)

local emptyLbl=Instance.new("TextLabel",scroll)
emptyLbl.Size=UDim2.new(1,0,0,60); emptyLbl.BackgroundTransparency=1
emptyLbl.Text="Tidak ada file .rbxl / .rbxm\ndi folder Workspace/"
emptyLbl.TextColor3=T.TXT_D; emptyLbl.TextSize=10; emptyLbl.Font=Enum.Font.Gotham
emptyLbl.TextWrapped=true; emptyLbl.LayoutOrder=999
emptyLbl.RichText=false

-- ============================================================
-- LOAD TARGET BUTTONS
-- ============================================================
local divMid=Instance.new("Frame",Main)
divMid.Size=UDim2.new(1,-20,0,1); divMid.Position=UDim2.new(0,10,0,326)
divMid.BackgroundColor3=T.STROKE; divMid.BorderSizePixel=0

local tgtLbl=Instance.new("TextLabel",Main)
tgtLbl.Size=UDim2.new(1,-20,0,14); tgtLbl.Position=UDim2.new(0,10,0,333)
tgtLbl.BackgroundTransparency=1; tgtLbl.Text="LOAD KE:"
tgtLbl.TextColor3=T.GOLD; tgtLbl.TextSize=9; tgtLbl.Font=Enum.Font.GothamBold
tgtLbl.TextXAlignment=Enum.TextXAlignment.Left

local TARGETS={
    {name="Workspace",         short="WS",col=T.BLUE},
    {name="ReplicatedStorage", short="RS",col=T.ORANGE},
    {name="ServerStorage",     short="SS",col=T.RED},
}
local selTarget="Workspace"
local tBtns={}

for i,tgt in ipairs(TARGETS) do
    local xp=10+(i-1)*92
    local f=Instance.new("Frame",Main)
    f.Size=UDim2.new(0,84,0,24); f.Position=UDim2.new(0,xp,0,349)
    f.BackgroundColor3=(tgt.name=="Workspace") and T.CARD2 or T.CARD
    f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
    local fStroke=Instance.new("UIStroke",f)
    fStroke.Color=(tgt.name=="Workspace") and T.GOLD or T.STROKE; fStroke.Thickness=1
    local badge=Instance.new("Frame",f)
    badge.Size=UDim2.new(0,20,0,14); badge.Position=UDim2.new(0,5,0.5,-7)
    badge.BackgroundColor3=tgt.col; badge.BackgroundTransparency=0.55; badge.BorderSizePixel=0
    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,3)
    local bLbl=Instance.new("TextLabel",badge)
    bLbl.Size=UDim2.new(1,0,1,0); bLbl.BackgroundTransparency=1
    bLbl.Text=tgt.short; bLbl.TextColor3=Color3.fromRGB(255,255,255); bLbl.TextSize=8; bLbl.Font=Enum.Font.GothamBold
    local nLbl=Instance.new("TextLabel",f)
    nLbl.Size=UDim2.new(1,-30,1,0); nLbl.Position=UDim2.new(0,28,0,0); nLbl.BackgroundTransparency=1
    nLbl.Text=tgt.name=="ReplicatedStorage" and "ReplStorage" or tgt.name
    nLbl.TextColor3=(tgt.name=="Workspace") and T.TXT_H or T.TXT_S
    nLbl.TextSize=9; nLbl.Font=Enum.Font.GothamBold; nLbl.TextXAlignment=Enum.TextXAlignment.Left
    local hit=Instance.new("TextButton",f); hit.Size=UDim2.new(1,0,1,0)
    hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=5
    table.insert(tBtns,{f=f,stroke=fStroke,lbl=nLbl,name=tgt.name})
    hit.MouseButton1Click:Connect(function()
        selTarget=tgt.name
        for _,tb in ipairs(tBtns) do
            tb.f.BackgroundColor3=(tb.name==tgt.name) and T.CARD2 or T.CARD
            tb.stroke.Color=(tb.name==tgt.name) and T.GOLD or T.STROKE
            tb.lbl.TextColor3=(tb.name==tgt.name) and T.TXT_H or T.TXT_S
        end
    end)
end

-- ============================================================
-- LOAD BUTTON
-- ============================================================
local loadGlow=Instance.new("Frame",Main)
loadGlow.Size=UDim2.new(1,-16,0,38); loadGlow.Position=UDim2.new(0,8,0,382)
loadGlow.BackgroundColor3=T.GOLD_D; loadGlow.BorderSizePixel=0
Instance.new("UICorner",loadGlow).CornerRadius=UDim.new(0,11)
local loadInner=Instance.new("Frame",loadGlow)
loadInner.Size=UDim2.new(1,-2,1,-2); loadInner.Position=UDim2.new(0,1,0,1)
loadInner.BackgroundColor3=Color3.fromRGB(26,20,5); loadInner.BorderSizePixel=0
Instance.new("UICorner",loadInner).CornerRadius=UDim.new(0,10)
local loadShine=Instance.new("Frame",loadInner)
loadShine.Size=UDim2.new(0.5,0,0,1); loadShine.Position=UDim2.new(0.25,0,0,2)
loadShine.BackgroundColor3=T.GOLD_L; loadShine.BackgroundTransparency=0.5; loadShine.BorderSizePixel=0
Instance.new("UICorner",loadShine).CornerRadius=UDim.new(0,99)
local loadBtn=Instance.new("TextButton",loadInner)
loadBtn.Size=UDim2.new(1,0,1,0); loadBtn.BackgroundTransparency=1
loadBtn.Text="⬆  LOAD FILE TERPILIH"; loadBtn.TextColor3=T.GOLD_L
loadBtn.TextSize=12; loadBtn.Font=Enum.Font.GothamBold; loadBtn.ZIndex=5

-- Resize frame
Main.Size=UDim2.new(0,W,0,430)

-- ============================================================
-- STATE
-- ============================================================
local selectedFile=nil   -- {name, path}
local fileRows={}        -- list of row frames

-- ============================================================
-- FILE DETECTION
-- ============================================================
local function isMapFile(fname)
    local ext=(fname:match("%.([^%.]+)$") or ""):lower()
    return ext=="rbxl" or ext=="rbxm" or ext=="rbxlx" or ext=="rbxmx"
end

local function getExt(fname)
    return (fname:match("%.([^%.]+)$") or ""):lower()
end

local function getIcon(fname)
    local ext=getExt(fname)
    if ext=="rbxl" or ext=="rbxlx" then return "PLACE",T.BLUE end
    return "MODEL",T.ORANGE
end

-- ============================================================
-- BUILD FILE ROW
-- ============================================================
local function makeRow(fname, fpath, idx)
    local iconTxt,iconCol=getIcon(fname)
    local ext=getExt(fname)

    local row=Instance.new("Frame",scroll)
    row.Name="FileRow_"..idx
    row.Size=UDim2.new(1,0,0,40)
    row.BackgroundColor3=T.ITEM
    row.BorderSizePixel=0; row.LayoutOrder=idx
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local rowStroke=Instance.new("UIStroke",row)
    rowStroke.Color=T.STROKE; rowStroke.Thickness=1

    -- Left color bar
    local bar=Instance.new("Frame",row)
    bar.Size=UDim2.new(0,3,0.6,0); bar.Position=UDim2.new(0,5,0.2,0)
    bar.BackgroundColor3=iconCol; bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,99)

    -- Badge
    local badge=Instance.new("Frame",row)
    badge.Size=UDim2.new(0,42,0,18); badge.Position=UDim2.new(0,13,0.5,-9)
    badge.BackgroundColor3=iconCol; badge.BackgroundTransparency=0.6; badge.BorderSizePixel=0
    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,5)
    local bLbl=Instance.new("TextLabel",badge)
    bLbl.Size=UDim2.new(1,0,1,0); bLbl.BackgroundTransparency=1
    bLbl.Text=iconTxt; bLbl.TextColor3=Color3.fromRGB(255,255,255); bLbl.TextSize=9; bLbl.Font=Enum.Font.GothamBold

    -- File name
    local nameLbl=Instance.new("TextLabel",row)
    nameLbl.Size=UDim2.new(1,-66,0,18); nameLbl.Position=UDim2.new(0,60,0,4)
    nameLbl.BackgroundTransparency=1; nameLbl.Text=fname
    nameLbl.TextColor3=T.TXT_M; nameLbl.TextSize=10; nameLbl.Font=Enum.Font.Gotham
    nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    nameLbl.TextTruncate=Enum.TextTruncate.AtEnd

    -- Path label
    local pathLbl=Instance.new("TextLabel",row)
    pathLbl.Size=UDim2.new(1,-66,0,14); pathLbl.Position=UDim2.new(0,60,0,22)
    pathLbl.BackgroundTransparency=1
    local shortPath=fpath:gsub("\\","/"):match("([^/]+/[^/]+)$") or fpath
    pathLbl.Text=shortPath
    pathLbl.TextColor3=T.TXT_D; pathLbl.TextSize=9; pathLbl.Font=Enum.Font.Gotham
    pathLbl.TextXAlignment=Enum.TextXAlignment.Left
    pathLbl.TextTruncate=Enum.TextTruncate.AtEnd

    -- Hit button
    local hit=Instance.new("TextButton",row)
    hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=10

    hit.MouseButton1Click:Connect(function()
        -- Deselect all
        for _,r in ipairs(fileRows) do
            r.frame.BackgroundColor3=T.ITEM
            local sk=r.frame:FindFirstChildOfClass("UIStroke")
            if sk then sk.Color=T.STROKE end
        end
        -- Select this
        row.BackgroundColor3=T.ITEM_SEL
        rowStroke.Color=T.GOLD
        selectedFile={name=fname,path=fpath}
        setStatus("Dipilih: "..fname, T.BLUE)
    end)

    return row
end

-- ============================================================
-- SCAN FILES
-- ============================================================
local function clearList()
    for _,r in ipairs(fileRows) do pcall(function() r.frame:Destroy() end) end
    fileRows={}
    selectedFile=nil
    emptyLbl.Visible=true
end

local SCAN_PATHS={
    "Workspace/",
    "workspace/",
    "",
}

local function scanFiles()
    clearList()
    setStatus("Scanning...", T.GOLD)
    local found={}
    local seen={}

    for _,basePath in ipairs(SCAN_PATHS) do
        local ok,files=pcall(function()
            return (basePath=="" and listfiles("") or listfiles(basePath))
        end)
        if ok and files then
            for _,fpath in ipairs(files) do
                local norm=fpath:gsub("\\","/")
                local fname=norm:match("([^/\\]+)$") or norm
                if isMapFile(fname) and not seen[fname] then
                    seen[fname]=true
                    table.insert(found,{name=fname,path=fpath})
                end
            end
        end
        -- Also try listfiles on subfolder entries
        if ok and files then
            for _,fpath in ipairs(files) do
                -- Try as directory
                local ok2,sub=pcall(listfiles,fpath)
                if ok2 and sub then
                    for _,sfpath in ipairs(sub) do
                        local snorm=sfpath:gsub("\\","/")
                        local sfname=snorm:match("([^/\\]+)$") or snorm
                        if isMapFile(sfname) and not seen[sfname] then
                            seen[sfname]=true
                            table.insert(found,{name=sfname,path=sfpath})
                        end
                    end
                end
            end
        end
    end

    if #found>0 then
        emptyLbl.Visible=false
        for i,f in ipairs(found) do
            local row=makeRow(f.name,f.path,i)
            table.insert(fileRows,{frame=row,data=f})
        end
        countLbl.Text="FILE DITEMUKAN  ("..#found..")"
        setStatus("Ditemukan "..#found.." file  •  Tap untuk memilih", T.GREEN)
    else
        emptyLbl.Visible=true
        countLbl.Text="FILE DITEMUKAN  (0)"
        setStatus("Tidak ada file di Workspace/  •  Coba Refresh", T.ORANGE)
    end
end

refreshBtn.MouseButton1Click:Connect(function()
    if not refreshBtn.Active then return end
    refreshBtn.Active=false
    refreshBtn.TextColor3=T.TXT_D
    task.spawn(function()
        scanFiles()
        refreshBtn.Active=true
        refreshBtn.TextColor3=T.TXT_S
    end)
end)

-- ============================================================
-- XML UTILS
-- ============================================================
local function xd(s)
    return s:gsub("&amp;","&"):gsub("&lt;","<"):gsub("&gt;",">"):gsub("&quot;",'"'):gsub("&apos;","'")
end
local function fv(s) return tonumber(s) or 0 end

-- Apply property to instance from XML props block
local function applyProp(inst,pn,xml)
    -- string
    local v=xml:match('<string name="'..pn..'">(.-)</string>')
    if v then pcall(function() inst[pn]=xd(v) end); return end
    -- bool
    v=xml:match('<bool name="'..pn..'">([^<]+)</bool>')
    if v then pcall(function() inst[pn]=(v=="true") end); return end
    -- int
    v=xml:match('<int name="'..pn..'">([^<]+)</int>')
    if v then pcall(function() inst[pn]=fv(v) end); return end
    -- float
    v=xml:match('<float name="'..pn..'">([^<]+)</float>')
        if v then pcall(function() inst[pn]=fv(v) end); return end
    -- double
    v=xml:match('<double name="'..pn..'">([^<]+)</double>')
    if v then pcall(function() inst[pn]=fv(v) end); return end
    -- token
    v=xml:match('<token name="'..pn..'">([^<]+)</token>')
    if v then pcall(function() inst[pn]=fv(v) end); return end
    -- Vector3
    local b=xml:match('<Vector3 name="'..pn..'">(.-)</Vector3>')
    if b then
        pcall(function() inst[pn]=Vector3.new(
            fv(b:match('<X>([^<]+)</X>')),
            fv(b:match('<Y>([^<]+)</Y>')),
            fv(b:match('<Z>([^<]+)</Z>'))) end); return end
    -- CFrame
    b=xml:match('<CoordinateFrame name="'..pn..'">(.-)</CoordinateFrame>')
    if b then
        pcall(function() inst[pn]=CFrame.new(
            fv(b:match('<X>([^<]+)</X>')),fv(b:match('<Y>([^<]+)</Y>')),fv(b:match('<Z>([^<]+)</Z>')),
            fv(b:match('<R00>([^<]+)</R00>')),fv(b:match('<R01>([^<]+)</R01>')),fv(b:match('<R02>([^<]+)</R02>')),
            fv(b:match('<R10>([^<]+)</R10>')),fv(b:match('<R11>([^<]+)</R11>')),fv(b:match('<R12>([^<]+)</R12>')),
            fv(b:match('<R20>([^<]+)</R20>')),fv(b:match('<R21>([^<]+)</R21>')),fv(b:match('<R22>([^<]+)</R22>'))) end); return end
    -- Color3
    b=xml:match('<Color3 name="'..pn..'">(.-)</Color3>')
    if b then
        pcall(function() inst[pn]=Color3.new(fv(b:match('<R>([^<]+)</R>')),fv(b:match('<G>([^<]+)</G>')),fv(b:match('<B>([^<]+)</B>'))) end); return end
    -- BrickColor
    v=xml:match('<BrickColor name="'..pn..'">([^<]+)</BrickColor>')
    if v then pcall(function() inst[pn]=BrickColor.new(fv(v)) end); return end
    -- UDim2
    b=xml:match('<UDim2 name="'..pn..'">(.-)</UDim2>')
    if b then
        pcall(function() inst[pn]=UDim2.new(fv(b:match('<XS>([^<]+)</XS>')),fv(b:match('<XO>([^<]+)</XO>')),fv(b:match('<YS>([^<]+)</YS>')),fv(b:match('<YO>([^<]+)</YO>'))) end); return end
    -- UDim
    b=xml:match('<UDim name="'..pn..'">(.-)</UDim>')
    if b then pcall(function() inst[pn]=UDim.new(fv(b:match('<S>([^<]+)</S>')),fv(b:match('<O>([^<]+)</O>'))) end); return end
    -- Vector2
    b=xml:match('<Vector2 name="'..pn..'">(.-)</Vector2>')
    if b then pcall(function() inst[pn]=Vector2.new(fv(b:match('<X>([^<]+)</X>')),fv(b:match('<Y>([^<]+)</Y>'))) end); return end
end

local PROPS_ALL={
    "Name","Anchored","CanCollide","CanTouch","CastShadow","Locked","Massless",
    "Transparency","Reflectance","Color","Material","BrickColor",
    "TopSurface","BottomSurface","LeftSurface","RightSurface","FrontSurface","BackSurface",
    "CFrame","Size","Shape","MeshId","TextureID","TextureId","MeshType","Scale","Offset","MeshSize",
    "Source","Disabled","RunContext","Value",
    "Brightness","Range","Shadows","Enabled","Angle","Face",
    "SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp","SunAngularSize","MoonAngularSize","StarCount",
    "Ambient","OutdoorAmbient","ClockTime","FogColor","FogEnd","FogStart","ExposureCompensation",
    "ShadowSoftness","Technology","GlobalShadows","ColorShift_Bottom","ColorShift_Top",
    "Density","Haze","Glare","Decay","Cover",
    "BackgroundColor3","BackgroundTransparency","BorderColor3","BorderSizePixel",
    "Position","Size","Visible","ZIndex","ClipsDescendants","AnchorPoint","Rotation","LayoutOrder","AutomaticSize","Active",
    "Text","TextColor3","TextSize","Font","TextTransparency","TextScaled","TextWrapped",
    "TextXAlignment","TextYAlignment","RichText","LineHeight",
    "Image","ImageColor3","ImageTransparency","ScaleType","SliceCenter","TileSize",
    "CornerRadius","Thickness","Padding",
    "PaddingTop","PaddingBottom","PaddingLeft","PaddingRight",
    "FillDirection","HorizontalAlignment","VerticalAlignment","SortOrder","CellSize",
    "SoundId","Volume","Pitch","PlaybackSpeed","Looped","RollOffMaxDistance","RollOffMinDistance",
    "Texture","StudsPerTileU","StudsPerTileV",
    "C0","C1","MaxVelocity","Length","Stiffness","Damping",
    "Gravity","FallenPartsDestroyHeight","StreamingEnabled",
    "WaterColor","WaterReflectance","WaterTransparency","WaterWaveSize","WaterWaveSpeed","GrassLength",
    "MaxHealth","Health","WalkSpeed","JumpPower","HipHeight","AutoJumpEnabled",
    "AnimationId","LevelOfDetail","ScaleFactor",
    "ShirtTemplate","PantsTemplate",
    "HeadColor3","LeftArmColor3","LeftLegColor3","RightArmColor3","RightLegColor3","TorsoColor3",
    "PlaceholderText","MultiLine","ClearTextOnFocus",
    "CanvasSize","ScrollBarThickness","ScrollingDirection",
    "ResetOnSpawn","DisplayOrder","IgnoreGuiInset","ZIndexBehavior",
    "GripPos","GripUp","GripRight","GripForward","CanBeDropped","ToolTip",
    "Duration","AllowTeamChangeOnTouch","Neutral",
}

local SKIP={PackageLink=true,PluginManagementService=true,CoreGui=true,RobloxReplicatedStorage=true}
local SVC_MAP={Workspace=true,ReplicatedFirst=true,ReplicatedStorage=true,Lighting=true,StarterGui=true,StarterPlayer=true,ServerScriptService=true,ServerStorage=true}

-- Extract direct child <Item> blocks (depth-safe)
local function getChildItems(xml)
    local items={}
    local pos=1; local len=#xml
    while pos<=len do
        local s=xml:find('<Item ',pos,true)
        if not s then break end
        local depth=0; local scan=s; local e=nil
        while scan<=len do
            local o=xml:find('<Item ',scan,true)
            local c=xml:find('</Item>',scan,true)
            if not c then break end
            if o and o<c then depth=depth+1; scan=o+5
            else
                if depth==0 then e=c+6; break
                else depth=depth-1; scan=c+7 end
            end
        end
        if e then table.insert(items,xml:sub(s,e)); pos=e+1
        else break end
    end
    return items
end

-- Parse one <Item> block into an Instance and parent it
local function parseItem(xml, parent)
    local cls=xml:match('<Item class="([^"]+)"')
    if not cls or SKIP[cls] then return end
    local inst; if not pcall(function() inst=Instance.new(cls) end) then return end

    local propsXml=xml:match('<Properties>(.-)</Properties>') or ""
    -- Name first
    local nm=propsXml:match('<string name="Name">([^<]*)</string>')
    if nm then pcall(function() inst.Name=xd(nm) end) end
    -- All props
    for _,p in ipairs(PROPS_ALL) do
        if p~="Name" then pcall(function() applyProp(inst,p,propsXml) end) end
    end
    pcall(function() inst.Parent=parent end)

    -- Children
    local afterProps=xml
    local pe=xml:find('</Properties>',1,true)
    if pe then afterProps=xml:sub(pe+13) end
    local lc=afterProps:match("^(.-)%</Item%>%s*$")
    if lc then afterProps=lc end
    for _,childXml in ipairs(getChildItems(afterProps)) do
        pcall(function() parseItem(childXml,inst) end)
    end
end

-- ============================================================
-- LOAD XML INTO GAME
-- ============================================================
local function loadXML(xmlContent, targetSvc)
    local topItems=getChildItems(xmlContent)
    local count=0
    for _,itemXml in ipairs(topItems) do
        local cls=itemXml:match('<Item class="([^"]+)"')
        if not cls then continue end
        local dest=targetSvc

        -- If it's a service, load its children into that real service (or targetSvc)
        if SVC_MAP[cls] then
            local ok,realSvc=pcall(function() return game:GetService(cls) end)
            if ok and realSvc then dest=realSvc end
            local inner=itemXml
            local pe=inner:find('</Properties>',1,true)
            if pe then inner=inner:sub(pe+13) end
            local lc=inner:match("^(.-)%</Item%>%s*$"); if lc then inner=lc end
            for _,ch in ipairs(getChildItems(inner)) do
                pcall(function() parseItem(ch,dest); count=count+1 end)
                task.wait()
            end
        elseif cls=="Model" then
            -- rbxm wrapper
            local inner=itemXml
            local pe=inner:find('</Properties>',1,true)
            if pe then inner=inner:sub(pe+13) end
            local lc=inner:match("^(.-)%</Item%>%s*$"); if lc then inner=lc end
            for _,ch in ipairs(getChildItems(inner)) do
                pcall(function() parseItem(ch,dest); count=count+1 end)
                task.wait()
            end
        else
            pcall(function() parseItem(itemXml,dest); count=count+1 end)
            task.wait()
        end
    end
    return count
end

-- ============================================================
-- LOAD BUTTON ACTION
-- ============================================================
loadBtn.MouseButton1Click:Connect(function()
    if not loadBtn.Active then return end
    if not selectedFile then
        setStatus("Pilih file dulu dari daftar!", T.RED)
        return
    end
    loadBtn.Active=false
    loadBtn.Text="⏳  Loading..."
    loadBtn.TextColor3=T.TXT_S
    loadGlow.BackgroundColor3=T.TXT_D
    setStatus("Membaca "..selectedFile.name.."...", T.BLUE)

    task.spawn(function()
        local ok,result=pcall(function()
            -- Read file
            local content=readfile(selectedFile.path)
            if not content or #content<10 then
                error("File kosong atau tidak bisa dibaca!")
            end
            -- Get target service
            local tSvc; pcall(function() tSvc=game:GetService(selTarget) end)
            if not tSvc then tSvc=workspace end
            setStatus("Spawning instances...", T.BLUE)
            task.wait(0.05)
            local n=loadXML(content,tSvc)
            return n
        end)

        if ok then
            setStatus("SUKSES! "..tostring(result).." instance di-load ke "..selTarget, T.GREEN)
            loadGlow.BackgroundColor3=T.GREEN_D
        else
            setStatus("ERROR: "..tostring(result):sub(1,85), T.RED)
            loadGlow.BackgroundColor3=Color3.fromRGB(80,18,18)
        end
        loadBtn.Active=true
        loadBtn.Text="⬆  LOAD FILE TERPILIH"
        loadBtn.TextColor3=T.GOLD_L
    end)
end)

-- ============================================================
-- AUTO SCAN ON START
-- ============================================================
task.delay(0.3, function()
    task.spawn(scanFiles)
end)

setStatus("Scanning Workspace/...", T.GOLD)
print("[LoadMap v2.0] By gixss | FREE 100% - Jangan diperjualbelikan!")
