--[[
╔══════════════════════════════════════════════════════╗
║        MAP LOADER v3.2  —  by gixss                  ║
║        Support: .rbxl & .rbxm  •  Studio Lite ✅     ║
╠══════════════════════════════════════════════════════╣
║   ✅ Free 100%    ❌ No Jual    💎 Ada Premium       ║
║   ✅ Size & posisi AKURAT sesuai map original        ║
║   ✅ TERRAIN support — bentuk & material ikut copy  ║
╚══════════════════════════════════════════════════════╝
]]

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local lp           = Players.LocalPlayer or Players.PlayerAdded:Wait()
local pg           = lp:WaitForChild("PlayerGui",10)
if not pg then pg = lp:FindFirstChildOfClass("PlayerGui") end

pcall(function()
    if pg:FindFirstChild("MapLoaderGUI") then pg.MapLoaderGUI:Destroy() end
end)

-- ══════════════════════════════════════════════════════
--  TERRAIN HANDLER
--  Copy voxel data dari loaded Terrain → workspace.Terrain
-- ══════════════════════════════════════════════════════
local function applyTerrain(srcTerrain)
    local dst = workspace.Terrain
    if not srcTerrain or not dst then return 0 end

    local voxCount = 0

    -- Copy visual properties
    local terrainProps = {
        "WaterColor","WaterReflectance","WaterTransparency",
        "WaterWaveSize","WaterWaveSpeed","GrassLength","Decoration",
    }
    for _, p in ipairs(terrainProps) do
        pcall(function() dst[p] = srcTerrain[p] end)
    end

    -- Copy voxel data via ReadVoxels / WriteVoxels
    local ok, err = pcall(function()
        local region = srcTerrain.MaxExtents
        -- Expand region sedikit biar gak miss edge
        local minVec = region.Min
        local maxVec = region.Max

        -- Cek apakah ada terrain (bukan kosong)
        if (maxVec - minVec).Magnitude < 4 then
            return -- terrain kosong, skip
        end

        local RESOLUTION = 4
        local materials, occupancies = srcTerrain:ReadVoxels(region, RESOLUTION)

        if materials and occupancies then
            dst:WriteVoxels(region, RESOLUTION, materials, occupancies)
            -- Hitung voxel yang terisi
            local sz = materials.Size
            for x = 1, sz.X do
                for y = 1, sz.Y do
                    for z = 1, sz.Z do
                        if occupancies[x][y][z] > 0.1 then
                            voxCount = voxCount + 1
                        end
                    end
                end
            end
        end
    end)

    if not ok then
        print("[MapLoader] Terrain voxel copy error: "..tostring(err))
    end

    -- Copy children of terrain (decals, scripts, etc)
    pcall(function()
        for _, child in ipairs(srcTerrain:GetChildren()) do
            local c = child:Clone()
            c.Parent = dst
        end
    end)

    -- Destroy src terrain (sudah dicopy)
    pcall(function() srcTerrain:Destroy() end)

    return voxCount
end

-- ══════════════════════════════════════════════════════
--  LOAD ENGINE
-- ══════════════════════════════════════════════════════
local function insertFile(path, onDone, onProgress)
    local fname = path:match("([^/\\]+)$") or path
    local ext   = (fname:match("%.(%w+)$") or "rbxm"):lower()
    local count = 0
    local terrainLoaded = false

    -- Helper: parent semua objek ke workspace, handle Terrain khusus
    local function parentAll(objs)
        for _, o in ipairs(objs) do
            pcall(function()
                if o:IsA("Terrain") then
                    -- Handle terrain khusus
                    if onProgress then onProgress("🌍  Loading terrain...") end
                    local vc = applyTerrain(o)
                    terrainLoaded = true
                    count = count + 1
                    print("[MapLoader] Terrain loaded, voxels: "..vc)
                elseif o.ClassName == "Workspace" or o.ClassName == "DataModel" then
                    -- Kalau dapat Workspace/DataModel wrapper, ambil childrennya
                    for _, child in ipairs(o:GetChildren()) do
                        pcall(function()
                            if child:IsA("Terrain") then
                                if onProgress then onProgress("🌍  Loading terrain...") end
                                local vc = applyTerrain(child)
                                terrainLoaded = true
                                count = count + 1
                            else
                                child.Parent = workspace
                                count = count + 1
                            end
                        end)
                    end
                else
                    o.Parent = workspace
                    count = count + 1
                end
            end)
        end
    end

    -- METODE 1: game:GetObjects(path) — paling akurat
    if onProgress then onProgress("📂  Membaca file...") end
    local ok1, objs1 = pcall(function() return game:GetObjects(path) end)
    if ok1 and objs1 and #objs1 > 0 then
        if onProgress then onProgress("🔧  Spawning "..#objs1.." objek...") end
        parentAll(objs1)
        onDone(true, count, terrainLoaded, "GetObjects"); return
    end

    -- METODE 2: readfile → tmp → GetObjects
    if onProgress then onProgress("📖  Mencoba readfile...") end
    local ok2, objs2 = pcall(function()
        local content = readfile(path)
        if not content or #content < 10 then error("empty") end
        local tmp = "___tmp_ml."..ext
        writefile(tmp, content)
        local r = game:GetObjects(tmp)
        pcall(function() delfile(tmp) end)
        return r
    end)
    if ok2 and objs2 and #objs2 > 0 then
        if onProgress then onProgress("🔧  Spawning "..#objs2.." objek...") end
        parentAll(objs2)
        onDone(true, count, terrainLoaded, "readfile+GetObjects"); return
    end

    -- METODE 3: rbxasset://
    local ok3, objs3 = pcall(function() return game:GetObjects("rbxasset://"..path) end)
    if ok3 and objs3 and #objs3 > 0 then
        parentAll(objs3)
        onDone(true, count, terrainLoaded, "rbxasset"); return
    end

    -- METODE 4: InsertService
    local ok4, r4 = pcall(function()
        local IS = game:GetService("InsertService")
        local m  = IS:LoadLocalAsset(path)
        if m then
            if m:IsA("Model") then
                for _, c in ipairs(m:GetChildren()) do
                    pcall(function()
                        if c:IsA("Terrain") then
                            applyTerrain(c); terrainLoaded=true; count=count+1
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
        end
        return 0
    end)
    if ok4 and r4 > 0 then
        onDone(true, count, terrainLoaded, "InsertService"); return
    end

    onDone(false, 0, false, "all failed")
end

-- ══════════════════════════════════════════════════════
--  WARNA TEMA
-- ══════════════════════════════════════════════════════
local C = {
    BG       = Color3.fromRGB(10,  12,  20),
    PANEL    = Color3.fromRGB(16,  20,  32),
    CARD     = Color3.fromRGB(20,  24,  38),
    CARD2    = Color3.fromRGB(26,  30,  48),
    ITEM     = Color3.fromRGB(22,  26,  42),
    ITEM_S   = Color3.fromRGB(28,  22,  55),
    GREEN    = Color3.fromRGB(40,  210,100),
    GREEN_D  = Color3.fromRGB(20,  110, 50),
    GREEN_H  = Color3.fromRGB(28,  130, 65),
    GOLD     = Color3.fromRGB(255, 200, 70),
    GOLD_D   = Color3.fromRGB(90,   70, 15),
    GOLD_L   = Color3.fromRGB(255, 220,110),
    RED      = Color3.fromRGB(255,  80, 80),
    BLUE     = Color3.fromRGB(100, 190,255),
    BLUE_D   = Color3.fromRGB(35,   70,140),
    ORANGE   = Color3.fromRGB(255, 160, 40),
    TEAL     = Color3.fromRGB(40,  200,180),
    TEAL_D   = Color3.fromRGB(15,   80, 70),
    TEXT     = Color3.fromRGB(215, 215,230),
    DIM      = Color3.fromRGB(100, 100,120),
    STROKE   = Color3.fromRGB(40,   45, 70),
    STROKE_G = Color3.fromRGB(30,  100, 55),
}

-- ══════════════════════════════════════════════════════
--  GUI ROOT
-- ══════════════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "MapLoaderGUI"
sg.ResetOnSpawn = false
sg.DisplayOrder = 9999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = pg

local win = Instance.new("Frame")
win.Size = UDim2.new(0,305,0,10)
win.Position = UDim2.new(0.5,-152,0.5,-230)
win.BackgroundColor3 = C.BG
win.BorderSizePixel = 0
win.Active = true; win.Draggable = true
win.Parent = sg
Instance.new("UICorner",win).CornerRadius = UDim.new(0,14)
local winStroke = Instance.new("UIStroke",win)
winStroke.Color = C.STROKE_G; winStroke.Thickness = 1.5

-- Top glow
local tg = Instance.new("Frame",win)
tg.Size=UDim2.new(0.55,0,0,1); tg.Position=UDim2.new(0.225,0,0,1)
tg.BackgroundColor3=C.GREEN_D; tg.BorderSizePixel=0
Instance.new("UICorner",tg).CornerRadius=UDim.new(0,99)

-- ── HEADER ────────────────────────────────────────────
local hdr = Instance.new("Frame",win)
hdr.Size=UDim2.new(1,0,0,50); hdr.BackgroundColor3=C.GREEN_H; hdr.BorderSizePixel=0
Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,14)
local hFix=Instance.new("Frame",hdr)
hFix.Size=UDim2.new(1,0,0.5,0); hFix.Position=UDim2.new(0,0,0.5,0)
hFix.BackgroundColor3=C.GREEN_H; hFix.BorderSizePixel=0

local hIcon=Instance.new("Frame",hdr)
hIcon.Size=UDim2.new(0,30,0,30); hIcon.Position=UDim2.new(0,12,0.5,-15)
hIcon.BackgroundColor3=Color3.fromRGB(18,90,42); hIcon.BorderSizePixel=0
Instance.new("UICorner",hIcon).CornerRadius=UDim.new(0,8)
local hIconL=Instance.new("TextLabel",hIcon)
hIconL.Size=UDim2.new(1,0,1,0); hIconL.BackgroundTransparency=1
hIconL.Text="📂"; hIconL.TextSize=16; hIconL.Font=Enum.Font.Gotham

local hTF=Instance.new("Frame",hdr)
hTF.Size=UDim2.new(1,-88,1,0); hTF.Position=UDim2.new(0,48,0,0); hTF.BackgroundTransparency=1
local hT=Instance.new("TextLabel",hTF)
hT.Text="MAP LOADER v3.2"
hT.Size=UDim2.new(1,0,0.52,0); hT.Position=UDim2.new(0,0,0.04,0)
hT.BackgroundTransparency=1; hT.TextColor3=Color3.fromRGB(255,255,255)
hT.TextSize=13; hT.Font=Enum.Font.GothamBold
hT.TextXAlignment=Enum.TextXAlignment.Left
local hS=Instance.new("TextLabel",hTF)
hS.Text="by gixss  •  .rbxl & .rbxm  •  Terrain ✅"
hS.Size=UDim2.new(1,0,0.38,0); hS.Position=UDim2.new(0,0,0.62,0)
hS.BackgroundTransparency=1; hS.TextColor3=Color3.fromRGB(180,255,200)
hS.TextSize=9; hS.Font=Enum.Font.Gotham
hS.TextXAlignment=Enum.TextXAlignment.Left

local xBtn=Instance.new("TextButton",hdr)
xBtn.Text="✕"; xBtn.Size=UDim2.new(0,26,0,26)
xBtn.Position=UDim2.new(1,-32,0.5,-13)
xBtn.BackgroundColor3=Color3.fromRGB(140,40,20)
xBtn.TextColor3=Color3.fromRGB(255,255,255)
xBtn.TextSize=12; xBtn.Font=Enum.Font.GothamBold; xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,6)
xBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Rules bar
local rules=Instance.new("TextLabel",win)
rules.Text="✅ Free  •  ❌ No Jual  •  Terrain ✅  •  Size Akurat 💯"
rules.Size=UDim2.new(1,-16,0,20); rules.Position=UDim2.new(0,8,0,57)
rules.BackgroundColor3=Color3.fromRGB(22,16,4)
rules.TextColor3=C.GOLD; rules.TextSize=9; rules.Font=Enum.Font.GothamBold
rules.BorderSizePixel=0; rules.TextXAlignment=Enum.TextXAlignment.Center
Instance.new("UICorner",rules).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",rules).Color=C.GOLD_D

-- ── STATUS BOX ────────────────────────────────────────
local statusBox=Instance.new("Frame",win)
statusBox.Size=UDim2.new(1,-16,0,44); statusBox.Position=UDim2.new(0,8,0,84)
statusBox.BackgroundColor3=C.PANEL; statusBox.BorderSizePixel=0
Instance.new("UICorner",statusBox).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",statusBox).Color=C.STROKE

local statusIco=Instance.new("TextLabel",statusBox)
statusIco.Text="📋"; statusIco.Size=UDim2.new(0,36,1,0)
statusIco.BackgroundTransparency=1; statusIco.TextColor3=C.BLUE
statusIco.TextSize=20; statusIco.Font=Enum.Font.Gotham

local statusLbl=Instance.new("TextLabel",statusBox)
statusLbl.Text="Pilih path lalu klik LOAD"
statusLbl.Size=UDim2.new(1,-42,0,20); statusLbl.Position=UDim2.new(0,38,0,4)
statusLbl.BackgroundTransparency=1; statusLbl.TextColor3=C.TEXT
statusLbl.TextSize=10; statusLbl.Font=Enum.Font.GothamBold
statusLbl.TextXAlignment=Enum.TextXAlignment.Left; statusLbl.TextWrapped=true

local statusSub=Instance.new("TextLabel",statusBox)
statusSub.Text="Support .rbxl & .rbxm + Terrain 🌍"
statusSub.Size=UDim2.new(1,-42,0,16); statusSub.Position=UDim2.new(0,38,0,26)
statusSub.BackgroundTransparency=1; statusSub.TextColor3=C.DIM
statusSub.TextSize=9; statusSub.Font=Enum.Font.Gotham
statusSub.TextXAlignment=Enum.TextXAlignment.Left

local function setStatus(main,sub,ico,col)
    statusLbl.Text=main or ""
    statusLbl.TextColor3=col or C.TEXT
    statusSub.Text=sub or ""
    statusIco.Text=ico or "📋"
end

-- ── TERRAIN TOGGLE ────────────────────────────────────
local terrToggleY = 134
local terrCard = Instance.new("Frame",win)
terrCard.Size=UDim2.new(1,-16,0,28); terrCard.Position=UDim2.new(0,8,0,terrToggleY)
terrCard.BackgroundColor3=C.CARD; terrCard.BorderSizePixel=0
Instance.new("UICorner",terrCard).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",terrCard).Color=C.STROKE

local terrIcon=Instance.new("TextLabel",terrCard)
terrIcon.Size=UDim2.new(0,28,1,0); terrIcon.BackgroundTransparency=1
terrIcon.Text="🌍"; terrIcon.TextSize=14; terrIcon.Font=Enum.Font.Gotham

local terrLbl=Instance.new("TextLabel",terrCard)
terrLbl.Size=UDim2.new(1,-80,1,0); terrLbl.Position=UDim2.new(0,28,0,0)
terrLbl.BackgroundTransparency=1; terrLbl.Text="Load Terrain  (voxel + bentuk)"
terrLbl.TextColor3=C.TEXT; terrLbl.TextSize=10; terrLbl.Font=Enum.Font.GothamBold
terrLbl.TextXAlignment=Enum.TextXAlignment.Left

-- Toggle switch
local terrToggleOn = true
local toggleOuter=Instance.new("Frame",terrCard)
toggleOuter.Size=UDim2.new(0,38,0,20); toggleOuter.Position=UDim2.new(1,-46,0.5,-10)
toggleOuter.BackgroundColor3=C.TEAL; toggleOuter.BorderSizePixel=0
Instance.new("UICorner",toggleOuter).CornerRadius=UDim.new(0,99)
local toggleKnob=Instance.new("Frame",toggleOuter)
toggleKnob.Size=UDim2.new(0,16,0,16); toggleKnob.Position=UDim2.new(1,-18,0.5,-8)
toggleKnob.BackgroundColor3=Color3.fromRGB(255,255,255); toggleKnob.BorderSizePixel=0
Instance.new("UICorner",toggleKnob).CornerRadius=UDim.new(0,99)

local toggleHit=Instance.new("TextButton",terrCard)
toggleHit.Size=UDim2.new(1,0,1,0); toggleHit.BackgroundTransparency=1; toggleHit.Text=""
toggleHit.MouseButton1Click:Connect(function()
    terrToggleOn = not terrToggleOn
    if terrToggleOn then
        toggleOuter.BackgroundColor3=C.TEAL
        toggleKnob.Position=UDim2.new(1,-18,0.5,-8)
        terrLbl.TextColor3=C.TEXT
    else
        toggleOuter.BackgroundColor3=Color3.fromRGB(55,50,75)
        toggleKnob.Position=UDim2.new(0,2,0.5,-8)
        terrLbl.TextColor3=C.DIM
    end
end)

-- ── QUICK PATH ────────────────────────────────────────
local qpY = terrToggleY + 35
local qpLabel=Instance.new("TextLabel",win)
qpLabel.Size=UDim2.new(1,-16,0,14); qpLabel.Position=UDim2.new(0,8,0,qpY)
qpLabel.BackgroundTransparency=1
qpLabel.Text="✦  QUICK PATH — tap untuk isi otomatis"
qpLabel.TextColor3=C.GOLD; qpLabel.TextSize=9; qpLabel.Font=Enum.Font.GothamBold
qpLabel.TextXAlignment=Enum.TextXAlignment.Left

local QUICK = {
    {label="Workspace/CopyMap.rbxl",        path="Workspace/CopyMap.rbxl",        ext="rbxl"},
    {label="Workspace/CopyMap.rbxm",        path="Workspace/CopyMap.rbxm",        ext="rbxm"},
    {label="workspace/CopyMap.rbxl",        path="workspace/CopyMap.rbxl",        ext="rbxl"},
    {label="workspace/CopyMap.rbxm",        path="workspace/CopyMap.rbxm",        ext="rbxm"},
    {label="/sdcard/CopyMap.rbxl",          path="/sdcard/CopyMap.rbxl",          ext="rbxl"},
    {label="/sdcard/CopyMap.rbxm",          path="/sdcard/CopyMap.rbxm",          ext="rbxm"},
    {label="/sdcard/Download/CopyMap.rbxl", path="/sdcard/Download/CopyMap.rbxl", ext="rbxl"},
    {label="/sdcard/Download/CopyMap.rbxm", path="/sdcard/Download/CopyMap.rbxm", ext="rbxm"},
}

local ROW_H = 28
local qpListY = qpY + 16
local qpH = math.min(#QUICK, 5) * ROW_H

local qpCont=Instance.new("Frame",win)
qpCont.Size=UDim2.new(1,-16,0,qpH+4); qpCont.Position=UDim2.new(0,8,0,qpListY)
qpCont.BackgroundColor3=C.CARD; qpCont.BorderSizePixel=0
Instance.new("UICorner",qpCont).CornerRadius=UDim.new(0,9)
Instance.new("UIStroke",qpCont).Color=C.STROKE

local qpScroll=Instance.new("ScrollingFrame",qpCont)
qpScroll.Size=UDim2.new(1,-2,1,-2); qpScroll.Position=UDim2.new(0,1,0,1)
qpScroll.BackgroundTransparency=1; qpScroll.BorderSizePixel=0
qpScroll.ScrollBarThickness=3
qpScroll.ScrollBarImageColor3=Color3.fromRGB(80,75,120)
qpScroll.CanvasSize=UDim2.new(0,0,0,#QUICK*ROW_H)
qpScroll.ScrollingDirection=Enum.ScrollingDirection.Y

local pathBoxRef -- forward ref

for i,qp in ipairs(QUICK) do
    local row=Instance.new("Frame",qpScroll)
    row.Size=UDim2.new(1,0,0,ROW_H)
    row.Position=UDim2.new(0,0,0,(i-1)*ROW_H)
    row.BackgroundTransparency=1

    if i>1 then
        local d=Instance.new("Frame",row)
        d.Size=UDim2.new(1,-12,0,1); d.Position=UDim2.new(0,6,0,0)
        d.BackgroundColor3=C.STROKE; d.BorderSizePixel=0
    end

    local extCol=(qp.ext=="rbxl") and C.BLUE or C.ORANGE
    local b=Instance.new("Frame",row)
    b.Size=UDim2.new(0,38,0,16); b.Position=UDim2.new(0,8,0.5,-8)
    b.BackgroundColor3=extCol; b.BackgroundTransparency=0.6; b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    local bL=Instance.new("TextLabel",b)
    bL.Size=UDim2.new(1,0,1,0); bL.BackgroundTransparency=1
    bL.Text="."..qp.ext; bL.TextColor3=Color3.fromRGB(255,255,255)
    bL.TextSize=8; bL.Font=Enum.Font.GothamBold

    local pL=Instance.new("TextLabel",row)
    pL.Size=UDim2.new(1,-56,1,0); pL.Position=UDim2.new(0,52,0,0)
    pL.BackgroundTransparency=1; pL.Text=qp.label
    pL.TextColor3=C.TEXT; pL.TextSize=9; pL.Font=Enum.Font.RobotoMono
    pL.TextXAlignment=Enum.TextXAlignment.Left
    pL.TextTruncate=Enum.TextTruncate.AtEnd

    local hit=Instance.new("TextButton",row)
    hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=5
    hit.MouseButton1Click:Connect(function()
        if pathBoxRef then pathBoxRef.Text=qp.path end
        row.BackgroundColor3=C.ITEM_S
        task.delay(0.25,function() row.BackgroundTransparency=1 end)
        setStatus("Path: "..qp.label,"Klik LOAD untuk mulai","📂",C.GOLD)
    end)
end

-- ── MANUAL PATH INPUT ─────────────────────────────────
local divY = qpListY + qpH + 10
local divLbl=Instance.new("TextLabel",win)
divLbl.Text="── atau ketik path manual ──"
divLbl.Size=UDim2.new(1,-16,0,14); divLbl.Position=UDim2.new(0,8,0,divY)
divLbl.BackgroundTransparency=1; divLbl.TextColor3=C.DIM
divLbl.TextSize=9; divLbl.Font=Enum.Font.Gotham
divLbl.TextXAlignment=Enum.TextXAlignment.Center

local pbY=divY+16
local pathBox=Instance.new("TextBox",win)
pathBox.Text=""
pathBox.PlaceholderText="Workspace/NamaFile.rbxl  atau  .rbxm"
pathBox.Size=UDim2.new(1,-16,0,32); pathBox.Position=UDim2.new(0,8,0,pbY)
pathBox.BackgroundColor3=C.PANEL
pathBox.TextColor3=C.TEXT; pathBox.PlaceholderColor3=C.DIM
pathBox.TextSize=10; pathBox.Font=Enum.Font.RobotoMono
pathBox.TextXAlignment=Enum.TextXAlignment.Left
pathBox.BorderSizePixel=0; pathBox.ClearTextOnFocus=false
Instance.new("UICorner",pathBox).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",pathBox).Color=C.STROKE
local pbPad=Instance.new("UIPadding",pathBox)
pbPad.PaddingLeft=UDim.new(0,10); pbPad.PaddingRight=UDim.new(0,10)
pathBoxRef=pathBox

-- ── PICK FILE BUTTON ──────────────────────────────────
local pickY=pbY+38
local pickBtn=Instance.new("TextButton",win)
pickBtn.Text="📁  PILIH FILE DARI HP"
pickBtn.Size=UDim2.new(1,-16,0,42); pickBtn.Position=UDim2.new(0,8,0,pickY)
pickBtn.BackgroundColor3=C.GREEN_H
pickBtn.TextColor3=Color3.fromRGB(255,255,255)
pickBtn.TextSize=13; pickBtn.Font=Enum.Font.GothamBold
pickBtn.BorderSizePixel=0; pickBtn.AutoButtonColor=false
Instance.new("UICorner",pickBtn).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",pickBtn).Color=C.GREEN

local spL=Instance.new("TextLabel",pickBtn)
spL.Text="Delta filepicker — .rbxl & .rbxm & Terrain"
spL.Size=UDim2.new(1,0,0,14); spL.Position=UDim2.new(0,0,1,-16)
spL.BackgroundTransparency=1; spL.TextColor3=Color3.fromRGB(180,255,200)
spL.TextSize=9; spL.Font=Enum.Font.Gotham
spL.TextXAlignment=Enum.TextXAlignment.Center

-- ── LOAD BUTTON ───────────────────────────────────────
local loadY=pickY+48
local loadGlow=Instance.new("Frame",win)
loadGlow.Size=UDim2.new(1,-16,0,40); loadGlow.Position=UDim2.new(0,8,0,loadY)
loadGlow.BackgroundColor3=C.GOLD_D; loadGlow.BorderSizePixel=0
Instance.new("UICorner",loadGlow).CornerRadius=UDim.new(0,11)
local loadInner=Instance.new("Frame",loadGlow)
loadInner.Size=UDim2.new(1,-2,1,-2); loadInner.Position=UDim2.new(0,1,0,1)
loadInner.BackgroundColor3=Color3.fromRGB(26,20,5); loadInner.BorderSizePixel=0
Instance.new("UICorner",loadInner).CornerRadius=UDim.new(0,10)
local shine=Instance.new("Frame",loadInner)
shine.Size=UDim2.new(0.5,0,0,1); shine.Position=UDim2.new(0.25,0,0,2)
shine.BackgroundColor3=C.GOLD_L; shine.BackgroundTransparency=0.5; shine.BorderSizePixel=0
Instance.new("UICorner",shine).CornerRadius=UDim.new(0,99)
local loadBtn=Instance.new("TextButton",loadInner)
loadBtn.Size=UDim2.new(1,0,1,0); loadBtn.BackgroundTransparency=1
loadBtn.Text="⬆  LOAD MAP + TERRAIN"; loadBtn.TextColor3=C.GOLD_L
loadBtn.TextSize=12; loadBtn.Font=Enum.Font.GothamBold; loadBtn.ZIndex=5

-- Watermark
local wmY=loadY+46
local wm=Instance.new("TextLabel",win)
wm.Text="© gixss — Free 100%, No Jual  |  Terrain + Size akurat 💯"
wm.Size=UDim2.new(1,0,0,14); wm.Position=UDim2.new(0,0,0,wmY)
wm.BackgroundTransparency=1; wm.TextColor3=C.DIM
wm.TextSize=8.5; wm.Font=Enum.Font.Gotham
wm.TextXAlignment=Enum.TextXAlignment.Center

win.Size=UDim2.new(0,305,0,wmY+18)

-- ── TWEEN ─────────────────────────────────────────────
pickBtn.MouseEnter:Connect(function()
    TweenService:Create(pickBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,165,85)}):Play()
end)
pickBtn.MouseLeave:Connect(function()
    TweenService:Create(pickBtn,TweenInfo.new(0.1),{BackgroundColor3=C.GREEN_H}):Play()
end)

-- ══════════════════════════════════════════════════════
--  LOAD LOGIC
-- ══════════════════════════════════════════════════════
local isLoading=false

local function resetBtns()
    pickBtn.Text="📁  PILIH FILE DARI HP"
    pickBtn.BackgroundColor3=C.GREEN_H
    loadBtn.Text="⬆  LOAD MAP + TERRAIN"
    loadBtn.TextColor3=C.GOLD_L
    loadGlow.BackgroundColor3=C.GOLD_D
end

local function doLoad(path)
    if isLoading then return end
    path=path:gsub("^%s+",""):gsub("%s+$","")
    if path=="" then
        setStatus("⚠️  Path kosong!","Tap quick path atau ketik manual","⚠️",C.GOLD)
        return
    end
    local fname=path:match("([^/\\]+)$") or path
    local ext=(fname:match("%.(%w+)$") or ""):lower()
    if ext~="rbxl" and ext~="rbxm" and ext~="rbxlx" and ext~="rbxmx" then
        setStatus("⚠️  Format salah!","Harus .rbxl atau .rbxm","⚠️",C.GOLD)
        return
    end

    isLoading=true
    setStatus("⏳  Loading: "..fname,"Mohon tunggu...","⏳",C.GOLD)
    pickBtn.Text="⏳  Loading..."
    pickBtn.BackgroundColor3=Color3.fromRGB(55,55,75)
    loadBtn.Text="⏳  Loading..."
    loadGlow.BackgroundColor3=Color3.fromRGB(50,50,30)

    task.spawn(function()
        insertFile(path,
            function(success, count, hasTerrain, method)
                isLoading=false
                if success then
                    local terrStr = hasTerrain and "  🌍 Terrain ✅" or "  🌍 Terrain (tidak ada)"
                    setStatus(
                        "✅  "..count.." objek loaded!"..terrStr,
                        "File: "..fname.."  •  Size & posisi akurat 💯",
                        "✅", C.GREEN
                    )
                    pickBtn.Text="✅  Berhasil!"
                    pickBtn.BackgroundColor3=Color3.fromRGB(25,120,55)
                    loadBtn.Text="✅  LOADED!"
                    loadBtn.TextColor3=C.GREEN
                    loadGlow.BackgroundColor3=C.GREEN_D
                    winStroke.Color=C.GREEN
                    print("[MapLoader v3.2] ✅ "..count.." obj, terrain="..tostring(hasTerrain)..", via "..(method or "?"))
                    task.wait(3)
                    resetBtns()
                    winStroke.Color=C.STROKE_G
                else
                    setStatus(
                        "❌  Gagal! Cek path & nama file",
                        "Pastikan file ada di: "..path,
                        "❌", C.RED
                    )
                    resetBtns()
                    winStroke.Color=C.RED
                    task.delay(2,function() winStroke.Color=C.STROKE_G end)
                    print("[MapLoader v3.2] ❌ Gagal: "..path)
                end
            end,
            function(progressMsg)
                setStatus(progressMsg,"Mohon tunggu...","⏳",C.GOLD)
            end
        )
    end)
end

-- ── BUTTON EVENTS ─────────────────────────────────────
pickBtn.MouseButton1Click:Connect(function()
    if isLoading then return end
    if filepicker then
        task.spawn(function()
            setStatus("📂  Membuka file picker...","Tunggu sebentar","📂",C.BLUE)
            pickBtn.Text="📂  Memilih file..."
            local ok,path=pcall(filepicker,{
                title="Pilih file .rbxl atau .rbxm",
                filter="*.rbxl;*.rbxm;*.rbxlx;*.rbxmx",
            })
            if ok and path and path~="" then
                pathBox.Text=path; doLoad(path)
            else
                setStatus("📋  Pilih Quick Path atau ketik manual","","📋",C.GOLD)
                pickBtn.Text="📁  PILIH FILE DARI HP"
                pickBtn.BackgroundColor3=C.GREEN_H
            end
        end)
    elseif getfilepath then
        task.spawn(function()
            setStatus("📂  Membuka file picker...","","📂",C.BLUE)
            local ok,path=pcall(getfilepath)
            if ok and path and path~="" then
                pathBox.Text=path; doLoad(path)
            else
                setStatus("📋  Pilih Quick Path atau ketik manual","","📋",C.GOLD)
                pickBtn.Text="📁  PILIH FILE DARI HP"
                pickBtn.BackgroundColor3=C.GREEN_H
            end
        end)
    else
        setStatus("ℹ️  Pakai Quick Path di atas","Tap salah satu path → klik LOAD","ℹ️",C.BLUE)
        if pathBox.Text=="" then pathBox.Text="Workspace/CopyMap.rbxl" end
    end
end)

loadBtn.MouseButton1Click:Connect(function() doLoad(pathBox.Text) end)
pathBox.FocusLost:Connect(function(entered) if entered then doLoad(pathBox.Text) end end)

setStatus("Tap Quick Path lalu klik LOAD","Support .rbxl & .rbxm + Terrain 🌍","📂",C.BLUE)
print("[MapLoader v3.2] By gixss | FREE 100% | Terrain + Size akurat 💯")
