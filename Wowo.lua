--[[
╔══════════════════════════════════════════════════════╗
║        MAP LOADER v4.0  —  by gixss                  ║
║        Studio Lite ✅  •  Fix HTTP 404 ✅            ║
╠══════════════════════════════════════════════════════╣
║   ✅ Free 100%    ❌ No Jual    💎 Ada Premium       ║
║   ✅ Upload .rbxl & .rbxm langsung di Studio Lite   ║
║   ✅ Terrain ✅   Size akurat 💯                     ║
╚══════════════════════════════════════════════════════╝

CARA PAKAI DI STUDIO LITE:
1. Paste di Script editor Studio Lite → Play
2. Tap UPLOAD FILE → pilih .rbxl atau .rbxm dari HP
3. LOAD → semua asset + terrain masuk Workspace ✅
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
local pg = lp:WaitForChild("PlayerGui", 10)
if not pg then pg = lp:FindFirstChildOfClass("PlayerGui") end

pcall(function()
    if pg:FindFirstChild("MapLoaderGUI") then pg.MapLoaderGUI:Destroy() end
end)

-- ══════════════════════════════════════════════════════
--  TERRAIN HANDLER
-- ══════════════════════════════════════════════════════
local function applyTerrain(src)
    local dst = workspace.Terrain
    if not src or not dst then return 0 end
    local vc = 0
    -- Props
    for _, p in ipairs({"WaterColor","WaterReflectance","WaterTransparency",
        "WaterWaveSize","WaterWaveSpeed","GrassLength","Decoration"}) do
        pcall(function() dst[p] = src[p] end)
    end
    -- Voxels
    pcall(function()
        local reg = src.MaxExtents
        if (reg.Max - reg.Min).Magnitude < 4 then return end
        local mat, occ = src:ReadVoxels(reg, 4)
        if mat and occ then
            dst:WriteVoxels(reg, 4, mat, occ)
            local sz = mat.Size
            for x=1,sz.X do for y=1,sz.Y do for z=1,sz.Z do
                if occ[x][y][z] > 0.1 then vc = vc + 1 end
            end end end
        end
    end)
    -- Children
    for _, c in ipairs(src:GetChildren()) do
        pcall(function() c:Clone().Parent = dst end)
    end
    pcall(function() src:Destroy() end)
    return vc
end

-- ══════════════════════════════════════════════════════
--  CORE LOAD ENGINE
--  FIX: Tidak pakai rbxasset:// atau HTTP — hanya local path
-- ══════════════════════════════════════════════════════
local function doInsert(path, onDone, onProg)
    local ext = (path:match("%.(%w+)$") or "rbxm"):lower()
    local count = 0
    local hasTerrain = false

    local function parentObjs(objs)
        for _, o in ipairs(objs) do
            pcall(function()
                if o:IsA("Terrain") then
                    local vc = applyTerrain(o)
                    hasTerrain = true
                    count = count + 1
                    print("[MapLoader] Terrain voxels: "..vc)
                elseif o.ClassName == "Workspace" then
                    -- Unwrap Workspace container
                    for _, ch in ipairs(o:GetChildren()) do
                        pcall(function()
                            if ch:IsA("Terrain") then
                                local vc = applyTerrain(ch)
                                hasTerrain = true
                                count = count + 1
                            elseif ch.ClassName ~= "Camera" then
                                ch.Parent = workspace
                                count = count + 1
                            end
                        end)
                    end
                elseif o.ClassName == "Model" then
                    -- Unwrap Model wrapper (rbxm biasanya wrapped)
                    for _, ch in ipairs(o:GetChildren()) do
                        pcall(function()
                            if ch:IsA("Terrain") then
                                local vc = applyTerrain(ch)
                                hasTerrain = true
                                count = count + 1
                            else
                                ch.Parent = workspace
                                count = count + 1
                            end
                        end)
                    end
                    -- Kalau model itu sendiri punya konten langsung
                    if count == 0 then
                        o.Parent = workspace
                        count = count + 1
                    end
                else
                    o.Parent = workspace
                    count = count + 1
                end
            end)
        end
    end

    -- METODE 1: game:GetObjects dengan path LOKAL saja
    -- TIDAK pakai http:// atau rbxasset:// → fix HTTP 404
    if onProg then onProg("📂  Membaca file lokal...") end
    local ok1, objs1 = pcall(game.GetObjects, game, path)
    if ok1 and objs1 and #objs1 > 0 then
        if onProg then onProg("🔧  Spawning "..#objs1.." objek...") end
        parentObjs(objs1)
        if count > 0 then onDone(true, count, hasTerrain, "GetObjects"); return end
    end

    -- METODE 2: Delta readfile → tmp → GetObjects
    if onProg then onProg("📖  Mencoba readfile...") end
    local ok2, objs2 = pcall(function()
        local content = readfile(path)
        if not content or #content < 10 then error("empty") end
        local tmp = "___mltmp."..ext
        writefile(tmp, content)
        local r = game:GetObjects(tmp)
        pcall(delfile, tmp)
        return r
    end)
    if ok2 and objs2 and #objs2 > 0 then
        parentObjs(objs2)
        if count > 0 then onDone(true, count, hasTerrain, "readfile+GetObjects"); return end
    end

    -- METODE 3: InsertService LoadLocalAsset
    if onProg then onProg("🔌  Mencoba InsertService...") end
    local ok3, r3 = pcall(function()
        local IS = game:GetService("InsertService")
        local m = IS:LoadLocalAsset(path)
        if not m then return 0 end
        if m:IsA("Model") then
            for _, c in ipairs(m:GetChildren()) do
                pcall(function()
                    if c:IsA("Terrain") then
                        applyTerrain(c); hasTerrain=true; count=count+1
                    else
                        c.Parent=workspace; count=count+1
                    end
                end)
            end
            m:Destroy()
        else
            m.Parent=workspace; count=count+1
        end
        return count
    end)
    if ok3 and r3 > 0 then
        onDone(true, count, hasTerrain, "InsertService"); return
    end

    onDone(false, 0, false, "failed")
end

-- ══════════════════════════════════════════════════════
--  ANDROID PATH SUGGESTIONS
--  Path umum di HP Android untuk Studio Lite
-- ══════════════════════════════════════════════════════
local ANDROID_ROOTS = {
    "/sdcard/",
    "/storage/emulated/0/",
    "/sdcard/Download/",
    "/storage/emulated/0/Download/",
    "/sdcard/Documents/",
    "/data/user/0/com.roblox.client/files/",
}

local FILENAMES = { "CopyMap.rbxl", "CopyMap.rbxm" }

local function buildPathSuggestions()
    local paths = {}
    -- Delta internal paths
    table.insert(paths, {label="Workspace/CopyMap.rbxl",  path="Workspace/CopyMap.rbxl",  ext="rbxl"})
    table.insert(paths, {label="Workspace/CopyMap.rbxm",  path="Workspace/CopyMap.rbxm",  ext="rbxm"})
    table.insert(paths, {label="workspace/CopyMap.rbxl",  path="workspace/CopyMap.rbxl",  ext="rbxl"})
    table.insert(paths, {label="workspace/CopyMap.rbxm",  path="workspace/CopyMap.rbxm",  ext="rbxm"})
    -- Android paths
    for _, root in ipairs(ANDROID_ROOTS) do
        for _, fname in ipairs(FILENAMES) do
            local ext = (fname:match("%.(%w+)$") or ""):lower()
            table.insert(paths, {label=root..fname, path=root..fname, ext=ext})
        end
    end
    return paths
end

local QUICK = buildPathSuggestions()

-- ══════════════════════════════════════════════════════
--  WARNA
-- ══════════════════════════════════════════════════════
local C = {
    BG      = Color3.fromRGB(10,  12,  20),
    PANEL   = Color3.fromRGB(16,  20,  32),
    CARD    = Color3.fromRGB(20,  24,  38),
    CARD2   = Color3.fromRGB(26,  30,  48),
    ITEM    = Color3.fromRGB(22,  26,  42),
    ITEM_S  = Color3.fromRGB(30,  24,  58),
    GREEN   = Color3.fromRGB(40,  210,100),
    GREEN_D = Color3.fromRGB(20,  110, 50),
    GREEN_H = Color3.fromRGB(28,  130, 65),
    GOLD    = Color3.fromRGB(255, 200, 70),
    GOLD_D  = Color3.fromRGB(90,   70, 15),
    GOLD_L  = Color3.fromRGB(255, 220,110),
    RED     = Color3.fromRGB(255,  80, 80),
    BLUE    = Color3.fromRGB(100, 190,255),
    BLUE_D  = Color3.fromRGB(35,   70,140),
    TEAL    = Color3.fromRGB(40,  200,180),
    ORANGE  = Color3.fromRGB(255, 160, 40),
    PURPLE  = Color3.fromRGB(160,  80,255),
    TEXT    = Color3.fromRGB(215, 215,230),
    DIM     = Color3.fromRGB(100, 100,120),
    STROKE  = Color3.fromRGB(40,   45, 70),
    STR_G   = Color3.fromRGB(30,  100, 55),
}

-- ══════════════════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "MapLoaderGUI"; sg.ResetOnSpawn = false
sg.DisplayOrder = 9999; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = pg

local W = 305
local win = Instance.new("Frame")
win.Size = UDim2.new(0,W,0,10)
win.Position = UDim2.new(0.5,-W/2,0.5,-240)
win.BackgroundColor3 = C.BG; win.BorderSizePixel = 0
win.Active = true; win.Draggable = true; win.Parent = sg
Instance.new("UICorner",win).CornerRadius = UDim.new(0,14)
local winSK = Instance.new("UIStroke",win); winSK.Color=C.STR_G; winSK.Thickness=1.5

local gLine = Instance.new("Frame",win)
gLine.Size=UDim2.new(0.55,0,0,1); gLine.Position=UDim2.new(0.225,0,0,1)
gLine.BackgroundColor3=C.GREEN_D; gLine.BorderSizePixel=0
Instance.new("UICorner",gLine).CornerRadius=UDim.new(0,99)

-- HEADER
local hdr = Instance.new("Frame",win)
hdr.Size=UDim2.new(1,0,0,50); hdr.BackgroundColor3=C.GREEN_H; hdr.BorderSizePixel=0
Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,14)
local hFix = Instance.new("Frame",hdr)
hFix.Size=UDim2.new(1,0,0.5,0); hFix.Position=UDim2.new(0,0,0.5,0)
hFix.BackgroundColor3=C.GREEN_H; hFix.BorderSizePixel=0

local hIco = Instance.new("Frame",hdr)
hIco.Size=UDim2.new(0,30,0,30); hIco.Position=UDim2.new(0,12,0.5,-15)
hIco.BackgroundColor3=Color3.fromRGB(18,90,42); hIco.BorderSizePixel=0
Instance.new("UICorner",hIco).CornerRadius=UDim.new(0,8)
local hIcoL = Instance.new("TextLabel",hIco)
hIcoL.Size=UDim2.new(1,0,1,0); hIcoL.BackgroundTransparency=1
hIcoL.Text="📂"; hIcoL.TextSize=16; hIcoL.Font=Enum.Font.Gotham

local hTF = Instance.new("Frame",hdr)
hTF.Size=UDim2.new(1,-88,1,0); hTF.Position=UDim2.new(0,48,0,0); hTF.BackgroundTransparency=1
local hT = Instance.new("TextLabel",hTF)
hT.Text="MAP LOADER v4.0"
hT.Size=UDim2.new(1,0,0.52,0); hT.Position=UDim2.new(0,0,0.04,0)
hT.BackgroundTransparency=1; hT.TextColor3=Color3.fromRGB(255,255,255)
hT.TextSize=13; hT.Font=Enum.Font.GothamBold; hT.TextXAlignment=Enum.TextXAlignment.Left
local hS = Instance.new("TextLabel",hTF)
hS.Text="by gixss  •  Studio Lite ✅  •  Fix 404 ✅"
hS.Size=UDim2.new(1,0,0.38,0); hS.Position=UDim2.new(0,0,0.62,0)
hS.BackgroundTransparency=1; hS.TextColor3=Color3.fromRGB(180,255,200)
hS.TextSize=9; hS.Font=Enum.Font.Gotham; hS.TextXAlignment=Enum.TextXAlignment.Left

local xBtn = Instance.new("TextButton",hdr)
xBtn.Text="✕"; xBtn.Size=UDim2.new(0,26,0,26)
xBtn.Position=UDim2.new(1,-32,0.5,-13)
xBtn.BackgroundColor3=Color3.fromRGB(140,40,20)
xBtn.TextColor3=Color3.fromRGB(255,255,255)
xBtn.TextSize=12; xBtn.Font=Enum.Font.GothamBold; xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,6)
xBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Rules
local rules = Instance.new("TextLabel",win)
rules.Text="✅ Free  •  ❌ No Jual  •  Terrain ✅  •  Fix HTTP 404 ✅"
rules.Size=UDim2.new(1,-16,0,20); rules.Position=UDim2.new(0,8,0,57)
rules.BackgroundColor3=Color3.fromRGB(22,16,4)
rules.TextColor3=C.GOLD; rules.TextSize=9; rules.Font=Enum.Font.GothamBold
rules.BorderSizePixel=0; rules.TextXAlignment=Enum.TextXAlignment.Center
Instance.new("UICorner",rules).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",rules).Color=C.GOLD_D

-- STATUS BOX
local sBx = Instance.new("Frame",win)
sBx.Size=UDim2.new(1,-16,0,44); sBx.Position=UDim2.new(0,8,0,84)
sBx.BackgroundColor3=C.PANEL; sBx.BorderSizePixel=0
Instance.new("UICorner",sBx).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",sBx).Color=C.STROKE

local sIco = Instance.new("TextLabel",sBx)
sIco.Text="📋"; sIco.Size=UDim2.new(0,36,1,0)
sIco.BackgroundTransparency=1; sIco.TextColor3=C.BLUE
sIco.TextSize=20; sIco.Font=Enum.Font.Gotham

local sLbl = Instance.new("TextLabel",sBx)
sLbl.Text="Upload file .rbxl / .rbxm dari HP"
sLbl.Size=UDim2.new(1,-42,0,20); sLbl.Position=UDim2.new(0,38,0,4)
sLbl.BackgroundTransparency=1; sLbl.TextColor3=C.TEXT
sLbl.TextSize=10; sLbl.Font=Enum.Font.GothamBold
sLbl.TextXAlignment=Enum.TextXAlignment.Left; sLbl.TextWrapped=true

local sSub = Instance.new("TextLabel",sBx)
sSub.Text="Studio Lite + Delta  •  Terrain + Size akurat 💯"
sSub.Size=UDim2.new(1,-42,0,16); sSub.Position=UDim2.new(0,38,0,26)
sSub.BackgroundTransparency=1; sSub.TextColor3=C.DIM
sSub.TextSize=9; sSub.Font=Enum.Font.Gotham
sSub.TextXAlignment=Enum.TextXAlignment.Left

local function setStatus(main,sub,ico,col)
    sLbl.Text=main or ""; sLbl.TextColor3=col or C.TEXT
    sSub.Text=sub or ""; sIco.Text=ico or "📋"
end

-- ══════════════════════════════════════════════════════
--  UPLOAD BUTTON (tombol utama — filepicker/getfilepath)
-- ══════════════════════════════════════════════════════
local upY = 135
local upCard = Instance.new("Frame",win)
upCard.Size=UDim2.new(1,-16,0,52); upCard.Position=UDim2.new(0,8,0,upY)
upCard.BackgroundColor3=C.PURPLE; upCard.BackgroundTransparency=0.1; upCard.BorderSizePixel=0
Instance.new("UICorner",upCard).CornerRadius=UDim.new(0,11)
local upSK = Instance.new("UIStroke",upCard); upSK.Color=C.PURPLE; upSK.Thickness=1.5

local upShine = Instance.new("Frame",upCard)
upShine.Size=UDim2.new(0.5,0,0,1); upShine.Position=UDim2.new(0.25,0,0,2)
upShine.BackgroundColor3=Color3.fromRGB(200,160,255); upShine.BackgroundTransparency=0.5; upShine.BorderSizePixel=0
Instance.new("UICorner",upShine).CornerRadius=UDim.new(0,99)

local upBtn = Instance.new("TextButton",upCard)
upBtn.Size=UDim2.new(1,0,1,0); upBtn.BackgroundTransparency=1
upBtn.Text="📤  UPLOAD FILE DARI HP"; upBtn.TextColor3=Color3.fromRGB(240,220,255)
upBtn.TextSize=13; upBtn.Font=Enum.Font.GothamBold; upBtn.ZIndex=5

local upSub = Instance.new("TextLabel",upCard)
upSub.Size=UDim2.new(1,0,0,14); upSub.Position=UDim2.new(0,0,1,-16)
upSub.BackgroundTransparency=1; upSub.Text="Pilih .rbxl atau .rbxm langsung dari File Manager HP"
upSub.TextColor3=Color3.fromRGB(180,150,230); upSub.TextSize=9; upSub.Font=Enum.Font.Gotham
upSub.TextXAlignment=Enum.TextXAlignment.Center

-- TERRAIN TOGGLE
local terrY = upY + 60
local terrCard = Instance.new("Frame",win)
terrCard.Size=UDim2.new(1,-16,0,28); terrCard.Position=UDim2.new(0,8,0,terrY)
terrCard.BackgroundColor3=C.CARD; terrCard.BorderSizePixel=0
Instance.new("UICorner",terrCard).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",terrCard).Color=C.STROKE

local tIco = Instance.new("TextLabel",terrCard)
tIco.Size=UDim2.new(0,28,1,0); tIco.BackgroundTransparency=1
tIco.Text="🌍"; tIco.TextSize=14; tIco.Font=Enum.Font.Gotham

local tLbl = Instance.new("TextLabel",terrCard)
tLbl.Size=UDim2.new(1,-80,1,0); tLbl.Position=UDim2.new(0,28,0,0)
tLbl.BackgroundTransparency=1; tLbl.Text="Load Terrain (voxel + bentuk)"
tLbl.TextColor3=C.TEXT; tLbl.TextSize=10; tLbl.Font=Enum.Font.GothamBold
tLbl.TextXAlignment=Enum.TextXAlignment.Left

local terrOn = true
local tOuter = Instance.new("Frame",terrCard)
tOuter.Size=UDim2.new(0,38,0,20); tOuter.Position=UDim2.new(1,-46,0.5,-10)
tOuter.BackgroundColor3=C.TEAL; tOuter.BorderSizePixel=0
Instance.new("UICorner",tOuter).CornerRadius=UDim.new(0,99)
local tKnob = Instance.new("Frame",tOuter)
tKnob.Size=UDim2.new(0,16,0,16); tKnob.Position=UDim2.new(1,-18,0.5,-8)
tKnob.BackgroundColor3=Color3.fromRGB(255,255,255); tKnob.BorderSizePixel=0
Instance.new("UICorner",tKnob).CornerRadius=UDim.new(0,99)

local tHit = Instance.new("TextButton",terrCard)
tHit.Size=UDim2.new(1,0,1,0); tHit.BackgroundTransparency=1; tHit.Text=""
tHit.MouseButton1Click:Connect(function()
    terrOn = not terrOn
    tOuter.BackgroundColor3 = terrOn and C.TEAL or Color3.fromRGB(55,50,75)
    tKnob.Position = terrOn and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    tLbl.TextColor3 = terrOn and C.TEXT or C.DIM
end)

-- ── QUICK PATH ────────────────────────────────────────
local qpY = terrY + 36
local qpLbl = Instance.new("TextLabel",win)
qpLbl.Size=UDim2.new(1,-16,0,14); qpLbl.Position=UDim2.new(0,8,0,qpY)
qpLbl.BackgroundTransparency=1; qpLbl.Text="✦  QUICK PATH — tap untuk isi"
qpLbl.TextColor3=C.GOLD; qpLbl.TextSize=9; qpLbl.Font=Enum.Font.GothamBold
qpLbl.TextXAlignment=Enum.TextXAlignment.Left

local ROW_H = 26
local SHOW_ROWS = 4
local qpListY = qpY + 16

local qpBg = Instance.new("Frame",win)
qpBg.Size=UDim2.new(1,-16,0,SHOW_ROWS*ROW_H+4); qpBg.Position=UDim2.new(0,8,0,qpListY)
qpBg.BackgroundColor3=C.CARD; qpBg.BorderSizePixel=0
Instance.new("UICorner",qpBg).CornerRadius=UDim.new(0,9)
Instance.new("UIStroke",qpBg).Color=C.STROKE

local qpSc = Instance.new("ScrollingFrame",qpBg)
qpSc.Size=UDim2.new(1,-2,1,-2); qpSc.Position=UDim2.new(0,1,0,1)
qpSc.BackgroundTransparency=1; qpSc.BorderSizePixel=0
qpSc.ScrollBarThickness=3; qpSc.ScrollBarImageColor3=Color3.fromRGB(80,75,120)
qpSc.CanvasSize=UDim2.new(0,0,0,#QUICK*ROW_H)
qpSc.ScrollingDirection=Enum.ScrollingDirection.Y

local pathBoxRef

for i,qp in ipairs(QUICK) do
    local row = Instance.new("Frame",qpSc)
    row.Size=UDim2.new(1,0,0,ROW_H); row.Position=UDim2.new(0,0,0,(i-1)*ROW_H)
    row.BackgroundTransparency=1

    if i>1 then
        local d=Instance.new("Frame",row)
        d.Size=UDim2.new(1,-12,0,1); d.Position=UDim2.new(0,6,0,0)
        d.BackgroundColor3=C.STROKE; d.BorderSizePixel=0
    end

    local extCol = (qp.ext=="rbxl") and C.BLUE or C.ORANGE
    local b=Instance.new("Frame",row)
    b.Size=UDim2.new(0,36,0,15); b.Position=UDim2.new(0,8,0.5,-7.5)
    b.BackgroundColor3=extCol; b.BackgroundTransparency=0.55; b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    local bL=Instance.new("TextLabel",b)
    bL.Size=UDim2.new(1,0,1,0); bL.BackgroundTransparency=1
    bL.Text="."..qp.ext; bL.TextColor3=Color3.fromRGB(255,255,255)
    bL.TextSize=8; bL.Font=Enum.Font.GothamBold

    local pL=Instance.new("TextLabel",row)
    pL.Size=UDim2.new(1,-54,1,0); pL.Position=UDim2.new(0,50,0,0)
    pL.BackgroundTransparency=1; pL.Text=qp.label
    pL.TextColor3=C.TEXT; pL.TextSize=9; pL.Font=Enum.Font.RobotoMono
    pL.TextXAlignment=Enum.TextXAlignment.Left; pL.TextTruncate=Enum.TextTruncate.AtEnd

    local hit=Instance.new("TextButton",row)
    hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=5
    hit.MouseButton1Click:Connect(function()
        if pathBoxRef then pathBoxRef.Text=qp.path end
        row.BackgroundColor3=C.ITEM_S
        task.delay(0.2,function() row.BackgroundTransparency=1 end)
        setStatus("Path: "..qp.label,"Klik LOAD untuk mulai","📂",C.GOLD)
    end)
end

-- ── MANUAL PATH BOX ───────────────────────────────────
local pbY = qpListY + SHOW_ROWS*ROW_H + 10
local pbBox = Instance.new("TextBox",win)
pbBox.Text=""; pbBox.PlaceholderText="Ketik path file .rbxl / .rbxm"
pbBox.Size=UDim2.new(1,-16,0,32); pbBox.Position=UDim2.new(0,8,0,pbY)
pbBox.BackgroundColor3=C.PANEL
pbBox.TextColor3=C.TEXT; pbBox.PlaceholderColor3=C.DIM
pbBox.TextSize=10; pbBox.Font=Enum.Font.RobotoMono
pbBox.TextXAlignment=Enum.TextXAlignment.Left
pbBox.BorderSizePixel=0; pbBox.ClearTextOnFocus=false
Instance.new("UICorner",pbBox).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",pbBox).Color=C.STROKE
local pbPad=Instance.new("UIPadding",pbBox)
pbPad.PaddingLeft=UDim.new(0,10); pbPad.PaddingRight=UDim.new(0,10)
pathBoxRef = pbBox

-- ── LOAD BUTTON ───────────────────────────────────────
local loadY = pbY + 38
local loadGlow = Instance.new("Frame",win)
loadGlow.Size=UDim2.new(1,-16,0,40); loadGlow.Position=UDim2.new(0,8,0,loadY)
loadGlow.BackgroundColor3=C.GOLD_D; loadGlow.BorderSizePixel=0
Instance.new("UICorner",loadGlow).CornerRadius=UDim.new(0,11)
local loadIn = Instance.new("Frame",loadGlow)
loadIn.Size=UDim2.new(1,-2,1,-2); loadIn.Position=UDim2.new(0,1,0,1)
loadIn.BackgroundColor3=Color3.fromRGB(26,20,5); loadIn.BorderSizePixel=0
Instance.new("UICorner",loadIn).CornerRadius=UDim.new(0,10)
local lShine = Instance.new("Frame",loadIn)
lShine.Size=UDim2.new(0.5,0,0,1); lShine.Position=UDim2.new(0.25,0,0,2)
lShine.BackgroundColor3=C.GOLD_L; lShine.BackgroundTransparency=0.5; lShine.BorderSizePixel=0
Instance.new("UICorner",lShine).CornerRadius=UDim.new(0,99)
local loadBtn = Instance.new("TextButton",loadIn)
loadBtn.Size=UDim2.new(1,0,1,0); loadBtn.BackgroundTransparency=1
loadBtn.Text="⬆  LOAD MAP KE WORKSPACE"; loadBtn.TextColor3=C.GOLD_L
loadBtn.TextSize=12; loadBtn.Font=Enum.Font.GothamBold; loadBtn.ZIndex=5

-- Watermark
local wmY = loadY + 46
local wm = Instance.new("TextLabel",win)
wm.Text="© gixss — Free 100%, No Jual  |  v4.0 Fix 404 + Terrain 🌍"
wm.Size=UDim2.new(1,0,0,14); wm.Position=UDim2.new(0,0,0,wmY)
wm.BackgroundTransparency=1; wm.TextColor3=C.DIM
wm.TextSize=8.5; wm.Font=Enum.Font.Gotham; wm.TextXAlignment=Enum.TextXAlignment.Center

win.Size = UDim2.new(0,W,0,wmY+18)

-- ══════════════════════════════════════════════════════
--  LOGIC
-- ══════════════════════════════════════════════════════
local isLoading = false

local function resetUI()
    upBtn.Text="📤  UPLOAD FILE DARI HP"
    upBtn.TextColor3=Color3.fromRGB(240,220,255)
    upCard.BackgroundColor3=C.PURPLE
    loadBtn.Text="⬆  LOAD MAP KE WORKSPACE"
    loadBtn.TextColor3=C.GOLD_L
    loadGlow.BackgroundColor3=C.GOLD_D
end

local function runLoad(path)
    if isLoading then return end
    path = path:gsub("^%s+",""):gsub("%s+$","")
    if path=="" then
        setStatus("⚠️  Path kosong!","Tap quick path atau ketik manual","⚠️",C.GOLD); return
    end
    local ext=(path:match("%.(%w+)$") or ""):lower()
    if ext~="rbxl" and ext~="rbxm" and ext~="rbxlx" and ext~="rbxmx" then
        setStatus("⚠️  Format salah!","Harus .rbxl atau .rbxm","⚠️",C.GOLD); return
    end
    local fname=path:match("([^/\\]+)$") or path
    isLoading=true
    setStatus("⏳  Loading: "..fname,"Mohon tunggu...","⏳",C.GOLD)
    loadBtn.Text="⏳  Loading..."; loadGlow.BackgroundColor3=Color3.fromRGB(50,50,30)
    upBtn.Text="⏳  Loading..."; upCard.BackgroundColor3=Color3.fromRGB(55,50,75)

    task.spawn(function()
        doInsert(path,
            function(ok, cnt, hasTerr, method)
                isLoading=false
                if ok then
                    local tStr = hasTerr and "  🌍 Terrain ✅" or ""
                    setStatus("✅  "..cnt.." objek!"..tStr,"File: "..fname.."  •  Size akurat 💯","✅",C.GREEN)
                    loadBtn.Text="✅  SUKSES!"; loadBtn.TextColor3=C.GREEN
                    loadGlow.BackgroundColor3=C.GREEN_D
                    upBtn.Text="✅  SUKSES!"; upCard.BackgroundColor3=C.GREEN_D
                    winSK.Color=C.GREEN
                    print("[MapLoader v4] ✅ "..cnt.." obj, terrain="..tostring(hasTerr).." via "..(method or "?"))
                    task.wait(3); resetUI(); winSK.Color=C.STR_G
                else
                    setStatus("❌  Gagal! Cek path file","Path: "..path,"❌",C.RED)
                    resetUI(); winSK.Color=C.RED
                    task.delay(2,function() winSK.Color=C.STR_G end)
                    print("[MapLoader v4] ❌ Gagal: "..path)
                end
            end,
            function(msg)
                setStatus(msg,"Mohon tunggu...","⏳",C.GOLD)
            end
        )
    end)
end

-- UPLOAD BTN — filepicker / getfilepath / fallback
upBtn.MouseButton1Click:Connect(function()
    if isLoading then return end

    -- Coba filepicker (Delta)
    if filepicker then
        task.spawn(function()
            setStatus("📂  Membuka file picker...","Pilih .rbxl atau .rbxm","📂",C.BLUE)
            upBtn.Text="📂  Memilih file..."
            local ok,path=pcall(filepicker,{
                title="Pilih .rbxl atau .rbxm",
                filter="*.rbxl;*.rbxm;*.rbxlx;*.rbxmx",
            })
            if ok and path and path~="" then
                pbBox.Text=path; runLoad(path)
            else
                setStatus("ℹ️  Pilih Quick Path atau ketik path manual","","ℹ️",C.BLUE)
                resetUI()
            end
        end)

    -- Coba getfilepath (executor lain)
    elseif getfilepath then
        task.spawn(function()
            setStatus("📂  Membuka file picker...","","📂",C.BLUE)
            local ok,path=pcall(getfilepath)
            if ok and path and path~="" then
                pbBox.Text=path; runLoad(path)
            else
                setStatus("ℹ️  Ketik path manual di bawah","","ℹ️",C.BLUE)
                resetUI()
            end
        end)

    -- Studio Lite / tidak ada filepicker
    -- Auto scan path umum
    else
        setStatus("🔍  Auto-scan path umum...","Mencari CopyMap.rbxl/.rbxm","🔍",C.BLUE)
        upBtn.Text="🔍  Scanning..."
        task.spawn(function()
            local found=nil
            -- Coba semua path umum
            for _, qp in ipairs(QUICK) do
                local ok=pcall(function()
                    local objs=game:GetObjects(qp.path)
                    if objs and #objs>0 then
                        found=qp.path
                    end
                end)
                if found then break end
                -- Juga coba readfile
                if not found then
                    pcall(function()
                        local c=readfile(qp.path)
                        if c and #c>10 then found=qp.path end
                    end)
                end
                if found then break end
            end

            if found then
                pbBox.Text=found
                setStatus("✅  File ketemu: "..found,"Klik LOAD untuk lanjut","✅",C.GREEN)
                resetUI()
            else
                setStatus("⚠️  File tidak ditemukan otomatis","Ketik path manual di bawah atau scroll Quick Path","⚠️",C.GOLD)
                if pbBox.Text=="" then pbBox.Text="Workspace/CopyMap.rbxl" end
                resetUI()
            end
        end)
    end
end)

-- LOAD BTN
loadBtn.MouseButton1Click:Connect(function() runLoad(pbBox.Text) end)
pbBox.FocusLost:Connect(function(e) if e then runLoad(pbBox.Text) end end)

-- Hover effects
TweenService:Create(upBtn,TweenInfo.new(0),{}):Play()
upBtn.MouseEnter:Connect(function()
    TweenService:Create(upCard,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(140,70,240)}):Play()
end)
upBtn.MouseLeave:Connect(function()
    TweenService:Create(upCard,TweenInfo.new(0.1),{BackgroundColor3=C.PURPLE}):Play()
end)

setStatus("Tap UPLOAD FILE untuk pilih dari HP","Studio Lite + Delta  •  Fix HTTP 404 ✅","📂",C.BLUE)
print("[MapLoader v4.0] By gixss | FREE 100% | Fix 404 | Terrain | Studio Lite")
