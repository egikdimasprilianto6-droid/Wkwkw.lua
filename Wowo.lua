-- ============================================
--        LoadMap v1.0 | Delta Executor
--    Load .rbxl & .rbxm ke dalam Game
--
--   By  : gixss
--   Free: 100% - DILARANG DIPERJUALBELIKAN!
-- ============================================

-- Cleanup GUI lama
pcall(function()
    local cg = game:GetService("CoreGui")
    if cg:FindFirstChild("LoadMapGUI") then cg:FindFirstChild("LoadMapGUI"):Destroy() end
end)
pcall(function()
    local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg and pg:FindFirstChild("LoadMapGUI") then pg:FindFirstChild("LoadMapGUI"):Destroy() end
end)

local guiParent
pcall(function() guiParent = game:GetService("CoreGui") end)
if not guiParent then
    guiParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- ===== WARNA =====
local C = {
    BG       = Color3.fromRGB(14, 14, 22),
    TOPBAR   = Color3.fromRGB(8,  8,  16),
    CARD     = Color3.fromRGB(20, 20, 34),
    CARD2    = Color3.fromRGB(26, 26, 42),
    ITEM     = Color3.fromRGB(24, 24, 40),
    ITEM_SEL = Color3.fromRGB(35, 55, 110),
    STROKE   = Color3.fromRGB(60, 60, 110),
    GREEN    = Color3.fromRGB(45, 185, 85),
    BLUE     = Color3.fromRGB(50, 110, 230),
    ORANGE   = Color3.fromRGB(220, 130, 30),
    RED      = Color3.fromRGB(200, 45, 45),
    YELLOW   = Color3.fromRGB(220, 200, 40),
    TXTMAIN  = Color3.fromRGB(220, 220, 255),
    TXTSUB   = Color3.fromRGB(130, 130, 175),
    TXTFILE  = Color3.fromRGB(190, 210, 255),
}

-- ===== ROOT GUI =====
local SG = Instance.new("ScreenGui")
SG.Name = "LoadMapGUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 9999
SG.Parent = guiParent

local MAIN_W, MAIN_H = 290, 430
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
Main.Position = UDim2.new(0.5, -MAIN_W/2, 0.5, -MAIN_H/2)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 13)
local ms = Instance.new("UIStroke", Main)
ms.Color = C.STROKE
ms.Thickness = 1.5

-- ===== TOPBAR =====
local Topbar = Instance.new("Frame", Main)
Topbar.Size = UDim2.new(1, 0, 0, 38)
Topbar.BackgroundColor3 = C.TOPBAR
Topbar.BorderSizePixel = 0
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 13)
local TFix = Instance.new("Frame", Topbar)
TFix.Size = UDim2.new(1, 0, 0.5, 0)
TFix.Position = UDim2.new(0, 0, 0.5, 0)
TFix.BackgroundColor3 = C.TOPBAR
TFix.BorderSizePixel = 0

local TitleLbl = Instance.new("TextLabel", Topbar)
TitleLbl.Size = UDim2.new(1, -42, 1, 0)
TitleLbl.Position = UDim2.new(0, 11, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "LoadMap v1.0  |  by gixss"
TitleLbl.TextColor3 = C.TXTMAIN
TitleLbl.TextSize = 12
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Topbar)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = C.RED
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

-- ===== STATUS =====
local StatusBox = Instance.new("Frame", Main)
StatusBox.Size = UDim2.new(1, -20, 0, 32)
StatusBox.Position = UDim2.new(0, 10, 0, 45)
StatusBox.BackgroundColor3 = C.CARD
StatusBox.BorderSizePixel = 0
Instance.new("UICorner", StatusBox).CornerRadius = UDim.new(0, 7)
local StatusLbl = Instance.new("TextLabel", StatusBox)
StatusLbl.Size = UDim2.new(1, -10, 1, 0)
StatusLbl.Position = UDim2.new(0, 5, 0, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Tekan Scan untuk cari file .rbxl / .rbxm"
StatusLbl.TextColor3 = C.TXTSUB
StatusLbl.TextSize = 10
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextWrapped = true
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ===== PATH INPUT =====
local PathLbl = Instance.new("TextLabel", Main)
PathLbl.Size = UDim2.new(1, -20, 0, 14)
PathLbl.Position = UDim2.new(0, 10, 0, 83)
PathLbl.BackgroundTransparency = 1
PathLbl.Text = "Folder Scan (default: Workspace/):"
PathLbl.TextColor3 = C.TXTSUB
PathLbl.TextSize = 10
PathLbl.Font = Enum.Font.GothamBold
PathLbl.TextXAlignment = Enum.TextXAlignment.Left

local PathBox = Instance.new("TextBox", Main)
PathBox.Size = UDim2.new(1, -20, 0, 26)
PathBox.Position = UDim2.new(0, 10, 0, 99)
PathBox.BackgroundColor3 = C.CARD2
PathBox.BorderSizePixel = 0
PathBox.Text = "Workspace/"
PathBox.PlaceholderText = "Workspace/"
PathBox.TextColor3 = C.TXTFILE
PathBox.TextSize = 11
PathBox.Font = Enum.Font.Gotham
PathBox.ClearTextOnFocus = false
Instance.new("UICorner", PathBox).CornerRadius = UDim.new(0, 6)
local pathStroke = Instance.new("UIStroke", PathBox)
pathStroke.Color = C.STROKE
pathStroke.Thickness = 1

-- ===== SCAN BUTTON =====
local ScanBtn = Instance.new("TextButton", Main)
ScanBtn.Size = UDim2.new(1, -20, 0, 28)
ScanBtn.Position = UDim2.new(0, 10, 0, 131)
ScanBtn.BackgroundColor3 = C.BLUE
ScanBtn.Text = "SCAN FILE"
ScanBtn.TextColor3 = Color3.fromRGB(255,255,255)
ScanBtn.TextSize = 12
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.BorderSizePixel = 0
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 8)

-- ===== FILE LIST =====
local ListLbl = Instance.new("TextLabel", Main)
ListLbl.Size = UDim2.new(1, -20, 0, 14)
ListLbl.Position = UDim2.new(0, 10, 0, 165)
ListLbl.BackgroundTransparency = 1
ListLbl.Text = "File Ditemukan:"
ListLbl.TextColor3 = C.TXTSUB
ListLbl.TextSize = 10
ListLbl.Font = Enum.Font.GothamBold
ListLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Scroll container
local ScrollBg = Instance.new("Frame", Main)
ScrollBg.Size = UDim2.new(1, -20, 0, 160)
ScrollBg.Position = UDim2.new(0, 10, 0, 181)
ScrollBg.BackgroundColor3 = C.CARD
ScrollBg.BorderSizePixel = 0
Instance.new("UICorner", ScrollBg).CornerRadius = UDim.new(0, 8)

local ScrollFrame = Instance.new("ScrollingFrame", ScrollBg)
ScrollFrame.Size = UDim2.new(1, -4, 1, -4)
ScrollFrame.Position = UDim2.new(0, 2, 0, 2)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 130)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
local listLayout = Instance.new("UIListLayout", ScrollFrame)
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
local listPad = Instance.new("UIPadding", ScrollFrame)
listPad.PaddingTop = UDim.new(0, 4)
listPad.PaddingLeft = UDim.new(0, 4)
listPad.PaddingRight = UDim.new(0, 4)
listPad.PaddingBottom = UDim.new(0, 4)

-- Empty label
local EmptyLbl = Instance.new("TextLabel", ScrollFrame)
EmptyLbl.Size = UDim2.new(1, 0, 0, 40)
EmptyLbl.BackgroundTransparency = 1
EmptyLbl.Text = "Belum ada file. Tekan SCAN dulu."
EmptyLbl.TextColor3 = C.TXTSUB
EmptyLbl.TextSize = 10
EmptyLbl.Font = Enum.Font.Gotham
EmptyLbl.TextWrapped = true
EmptyLbl.LayoutOrder = 999

-- ===== LOAD TARGET OPTION =====
local TargetLbl = Instance.new("TextLabel", Main)
TargetLbl.Size = UDim2.new(1, -20, 0, 14)
TargetLbl.Position = UDim2.new(0, 10, 0, 348)
TargetLbl.BackgroundTransparency = 1
TargetLbl.Text = "Load ke:"
TargetLbl.TextColor3 = C.TXTSUB
TargetLbl.TextSize = 10
TargetLbl.Font = Enum.Font.GothamBold
TargetLbl.TextXAlignment = Enum.TextXAlignment.Left

local selectedTarget = "Workspace"
local targetOptions = {"Workspace", "ReplicatedStorage", "ServerStorage"}
local targetBtns = {}

for i, tgt in ipairs(targetOptions) do
    local xPos = 10 + (i - 1) * 90
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 84, 0, 22)
    btn.Position = UDim2.new(0, xPos, 0, 363)
    btn.BackgroundColor3 = (tgt == "Workspace") and C.GREEN or C.CARD2
    btn.Text = tgt == "Workspace" and "Workspace" or (tgt == "ReplicatedStorage" and "ReplStorage" or "ServerStorage")
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = Main
    table.insert(targetBtns, {btn=btn, name=tgt})

    btn.MouseButton1Click:Connect(function()
        selectedTarget = tgt
        for _, tb in ipairs(targetBtns) do
            tb.btn.BackgroundColor3 = (tb.name == tgt) and C.GREEN or C.CARD2
        end
    end)
end

-- ===== LOAD BUTTON =====
local LoadBtn = Instance.new("TextButton", Main)
LoadBtn.Size = UDim2.new(1, -20, 0, 34)
LoadBtn.Position = UDim2.new(0, 10, 0, 391)
LoadBtn.BackgroundColor3 = C.GREEN
LoadBtn.Text = "LOAD FILE TERPILIH"
LoadBtn.TextColor3 = Color3.fromRGB(255,255,255)
LoadBtn.TextSize = 13
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.BorderSizePixel = 0
Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 9)

-- ===== HELPER =====
local function setStatus(msg, r, g, b)
    StatusLbl.Text = msg
    StatusLbl.TextColor3 = Color3.fromRGB(r or 130, g or 130, b or 175)
end

local selectedFile = nil

-- ===== FILE EXTENSION DETECT =====
local function getExt(fname)
    return fname:match("%.([^%.]+)$") or ""
end

local function isMapFile(fname)
    local ext = getExt(fname):lower()
    return ext == "rbxl" or ext == "rbxm" or ext == "rbxlx" or ext == "rbxmx"
end

local function getIcon(fname)
    local ext = getExt(fname):lower()
    if ext == "rbxl" or ext == "rbxlx" then return "PLACE", C.BLUE
    elseif ext == "rbxm" or ext == "rbxmx" then return "MODEL", C.ORANGE
    end
    return "FILE", C.TXTSUB
end

-- ===== SCAN FILES =====
local function clearList()
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    EmptyLbl.Visible = true
    selectedFile = nil
end

local function makeFileRow(fname, fullPath, idx)
    local iconLabel, iconColor = getIcon(fname)

    local row = Instance.new("Frame", ScrollFrame)
    row.Name = "Row_"..idx
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = C.ITEM
    row.BorderSizePixel = 0
    row.LayoutOrder = idx
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    -- Icon badge
    local badge = Instance.new("Frame", row)
    badge.Size = UDim2.new(0, 44, 0, 22)
    badge.Position = UDim2.new(0, 7, 0.5, -11)
    badge.BackgroundColor3 = iconColor
    badge.BorderSizePixel = 0
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)
    local badgeLbl = Instance.new("TextLabel", badge)
    badgeLbl.Size = UDim2.new(1, 0, 1, 0)
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Text = iconLabel
    badgeLbl.TextColor3 = Color3.fromRGB(255,255,255)
    badgeLbl.TextSize = 9
    badgeLbl.Font = Enum.Font.GothamBold

    -- File name
    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(1, -62, 1, 0)
    nameLbl.Position = UDim2.new(0, 57, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = fname
    nameLbl.TextColor3 = C.TXTFILE
    nameLbl.TextSize = 10
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Hit button
    local hitBtn = Instance.new("TextButton", row)
    hitBtn.Size = UDim2.new(1, 0, 1, 0)
    hitBtn.BackgroundTransparency = 1
    hitBtn.Text = ""
    hitBtn.ZIndex = 5

    hitBtn.MouseButton1Click:Connect(function()
        -- Deselect semua
        for _, child in ipairs(ScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.BackgroundColor3 = C.ITEM
            end
        end
        -- Select ini
        row.BackgroundColor3 = C.ITEM_SEL
        selectedFile = {name=fname, path=fullPath}
        setStatus("Dipilih: "..fname, 80, 200, 255)
    end)

    return row
end

-- Paths yang discan
local function getScanPaths(baseFolder)
    local folder = baseFolder
    if folder:sub(-1) ~= "/" then folder = folder .. "/" end
    return {
        folder,
        "",  -- root
        "workspace/",
        "Workspace/",
    }
end

local function scanFiles(baseFolder)
    clearList()
    local found = {}
    local seen = {}

    local folder = baseFolder
    if folder == "" then folder = "Workspace/" end
    if folder:sub(-1) ~= "/" then folder = folder.."/" end

    -- Coba listfiles di berbagai path
    local tryPaths = {folder, "Workspace/", "", "workspace/"}

    -- Tambah path dari input jika beda
    if folder ~= "Workspace/" and folder ~= "workspace/" then
        table.insert(tryPaths, 1, folder)
    end

    for _, path in ipairs(tryPaths) do
        local ok, files = pcall(function()
            return (path == "") and listfiles("") or listfiles(path)
        end)
        if ok and files then
            for _, fpath in ipairs(files) do
                -- Normalize path separator
                local normalized = fpath:gsub("\\", "/")
                local fname = normalized:match("([^/]+)$") or normalized
                if isMapFile(fname) and not seen[fname] then
                    seen[fname] = true
                    table.insert(found, {name=fname, path=fpath})
                end
            end
        end
    end

    -- Hapus empty label kalau ada file
    if #found > 0 then
        EmptyLbl.Visible = false
        for i, f in ipairs(found) do
            makeFileRow(f.name, f.path, i)
        end
        setStatus("Ditemukan "..#found.." file map!", 50, 210, 90)
    else
        EmptyLbl.Visible = true
        setStatus("Tidak ada .rbxl/.rbxm di folder ini", 220, 150, 40)
    end

    return #found
end

-- ===== PARSE XML =====
-- Parse XML rbxl/rbxm dan rebuild Instance ke dalam game
local function parseAndLoad(xmlContent, targetService)
    local loaded = 0
    local errors = 0

    -- Cari semua <Item class="..."> di level pertama
    local function getAttr(tag, attr)
        return tag:match(attr..'="([^"]*)"')
    end

    local function getPropValue(propsXml, propName, propType)
        local pattern = '<'..propType..' name="'..propName..'">(.-)</'..propType..'>'
        return propsXml:match(pattern)
    end

    -- Fungsi rekursif parse XML → Instance
    local function parseItem(itemXml, parent)
        local className = itemXml:match('<Item class="([^"]+)"')
        if not className then return end

        -- Buat instance
        local inst
        local ok, err = pcall(function()
            inst = Instance.new(className)
        end)
        if not ok or not inst then return end

        -- Ambil Properties block
        local propsXml = itemXml:match('<Properties>(.-)</Properties>') or ""

        -- Name
        local name = propsXml:match('<string name="Name">([^<]*)</string>')
        if name then pcall(function() inst.Name = name end) end

        -- Coba set parent dulu
        pcall(function() inst.Parent = parent end)
        loaded = loaded + 1

        -- Parse child items langsung
        -- Ini versi simplified: ambil semua direct child <Item>
        local depth = 0
        local pos = 1
        local xmlLen = #itemXml
        -- skip opening <Item ...> tag
        local firstClose = itemXml:find(">", 1, true)
        if firstClose then pos = firstClose + 1 end

        while pos <= xmlLen do
            local iStart = itemXml:find('<Item ', pos, true)
            if not iStart then break end

            -- Cari matching </Item> dengan depth counting
            local scanPos = iStart
            local itemDepth = 0
            local itemEnd = nil

            while scanPos <= xmlLen do
                local openTag = itemXml:find('<Item ', scanPos, true)
                local closeTag = itemXml:find('</Item>', scanPos, true)

                if not closeTag then break end

                if openTag and openTag < closeTag then
                    itemDepth = itemDepth + 1
                    scanPos = openTag + 5
                else
                    if itemDepth == 0 then
                        itemEnd = closeTag + 6
                        break
                    else
                        itemDepth = itemDepth - 1
                        scanPos = closeTag + 7
                    end
                end
            end

            if itemEnd then
                local childXml = itemXml:sub(iStart, itemEnd)
                pcall(function() parseItem(childXml, inst) end)
                pos = itemEnd + 1
            else
                break
            end
        end
    end

    -- ===== MAIN LOAD LOGIC =====
    -- Cari semua top-level <Item> di XML
    local target = targetService
    local pos = 1
    local xmlLen = #xmlContent

    while pos <= xmlLen do
        local iStart = xmlContent:find('<Item ', pos, true)
        if not iStart then break end

        -- Cari matching </Item>
        local scanPos = iStart
        local depth = 0
        local itemEnd = nil

        while scanPos <= xmlLen do
            local openTag = xmlContent:find('<Item ', scanPos, true)
            local closeTag = xmlContent:find('</Item>', scanPos, true)

            if not closeTag then break end

            if openTag and openTag < closeTag then
                depth = depth + 1
                scanPos = openTag + 5
            else
                if depth == 0 then
                    itemEnd = closeTag + 6
                    break
                else
                    depth = depth - 1
                    scanPos = closeTag + 7
                end
            end
        end

        if itemEnd then
            local itemXml = xmlContent:sub(iStart, itemEnd)
            local className = itemXml:match('<Item class="([^"]+)"')
            local itemName = itemXml:match('<string name="Name">([^<]*)</string>') or className

            -- Skip service containers, load isinya ke target
            local serviceClasses = {
                Workspace=true, ReplicatedFirst=true, ReplicatedStorage=true,
                Lighting=true, StarterGui=true, StarterPlayer=true,
                ServerScriptService=true, ServerStorage=true,
                DataModel=true, Model=true
            }

            if serviceClasses[className] then
                -- Load children of this service into target
                local childPos = 1
                local childXml = itemXml
                -- skip to first child
                local propsEnd = childXml:find('</Properties>', 1, true)
                if propsEnd then childPos = propsEnd + 13 end

                local childLen = #childXml
                while childPos <= childLen do
                    local cStart = childXml:find('<Item ', childPos, true)
                    if not cStart then break end

                    local cScan = cStart
                    local cDepth = 0
                    local cEnd = nil

                    while cScan <= childLen do
                        local co = childXml:find('<Item ', cScan, true)
                        local cc = childXml:find('</Item>', cScan, true)
                        if not cc then break end
                        if co and co < cc then
                            cDepth = cDepth + 1
                            cScan = co + 5
                        else
                            if cDepth == 0 then
                                cEnd = cc + 6
                                break
                            else
                                cDepth = cDepth - 1
                                cScan = cc + 7
                            end
                        end
                    end

                    if cEnd then
                        pcall(function() parseItem(childXml:sub(cStart, cEnd), target) end)
                        childPos = cEnd + 1
                    else
                        break
                    end
                end
            else
                -- Load langsung ke target
                pcall(function() parseItem(itemXml, target) end)
            end

            pos = itemEnd + 1
        else
            break
        end
    end

    return loaded, errors
end

-- ===== LOAD ACTION =====
LoadBtn.MouseButton1Click:Connect(function()
    if not LoadBtn.Active then return end

    if not selectedFile then
        setStatus("Pilih file dulu dari daftar!", 230, 80, 80)
        return
    end

    LoadBtn.Active = false
    LoadBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    LoadBtn.Text = "Loading..."
    setStatus("Membaca file: "..selectedFile.name.."...", 100, 180, 255)

    task.spawn(function()
        local ok, result = pcall(function()
            -- Baca file
            local content = readfile(selectedFile.path)
            if not content or content == "" then
                error("File kosong atau tidak bisa dibaca!")
            end

            -- Dapatkan target service
            local targetSvc
            pcall(function() targetSvc = game:GetService(selectedTarget) end)
            if not targetSvc then
                -- fallback ke workspace
                targetSvc = workspace
            end

            setStatus("Parsing XML...", 100, 180, 255)
            task.wait(0.05)

            local loaded, errs = parseAndLoad(content, targetSvc)
            return loaded, errs
        end)

        if ok then
            local loaded, errs = result, 0
            setStatus("SUKSES! "..tostring(loaded).." instance di-load ke "..selectedTarget, 50, 210, 90)
        else
            setStatus("ERROR: "..tostring(result):sub(1, 85), 230, 70, 70)
        end

        LoadBtn.Active = true
        LoadBtn.BackgroundColor3 = C.GREEN
        LoadBtn.Text = "LOAD FILE TERPILIH"
    end)
end)

-- ===== SCAN ACTION =====
ScanBtn.MouseButton1Click:Connect(function()
    if not ScanBtn.Active then return end
    ScanBtn.Active = false
    ScanBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ScanBtn.Text = "Scanning..."
    setStatus("Mencari file .rbxl / .rbxm ...", 100, 180, 255)

    task.spawn(function()
        local count = 0
        pcall(function()
            count = scanFiles(PathBox.Text)
        end)

        if count == 0 then
            -- Coba scan root juga
            pcall(function()
                local ok, files = pcall(listfiles, "")
                if ok and files then
                    for _, f in ipairs(files) do
                        local fname = f:match("([^/\\]+)$") or f
                        if isMapFile(fname) then
                            EmptyLbl.Visible = false
                            makeFileRow(fname, f, 1)
                            count = count + 1
                        end
                    end
                end
            end)
        end

        ScanBtn.Active = true
        ScanBtn.BackgroundColor3 = C.BLUE
        ScanBtn.Text = "SCAN FILE"
    end)
end)

-- Auto scan on start
task.delay(0.3, function()
    pcall(function() scanFiles("Workspace/") end)
end)

setStatus("Tekan Scan untuk cari file .rbxl / .rbxm")
print("[LoadMap v1.0] By gixss | FREE 100% - Jangan diperjualbelikan!")
