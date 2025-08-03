local config_url = "https://raw.githubusercontent.com/CPMRm/rmscript/main/comfig.json"

local key_file_path = "/storage/emulated/0/key_data.txt"
local key_url = "https://raw.githubusercontent.com/CPMRm/rmstudio-gg-keydata/main/key_data.txt"

local telegram_bot_token = "8404020167:AAFZPUbKUUnwTDmHJEw_WEtRhH3Nx5dGIWI"
local telegram_chat_id = "6662550521"

local function checkupdating()
  local resp = gg.makeRequest(config_url)
  if not resp or resp.code ~= 200 or not resp.content then
    gg.alert("❌ 無法取得雲端資料，請檢查網路")
    os.exit()
  end

  local content = resp.content
  local enabled = content:match('"enabled"%s*:%s*(true)')
  enabled = enabled == "true"
  local message = content:match('"message"%s*:%s*"(.-)"') or "腳本目前正在進行維護更新 目前腳本已關閉 造成您的不便🙇。\nTelegram @ryderyo666\n" .."Facebook @Ryder Chang"

  if not enabled then
    gg.alert(message)
    os.exit()
  end
end

function sendTelegramNotification(message)
  local function urlencode(str)
    if (str) then
      str = str:gsub("\n", "%%0A")
      str = str:gsub(" ", "%%20")
      str = str:gsub("([^%w%%%-%.~])", function(c)
        return string.format("%%%02X", string.byte(c))
      end)
    end
    return str
  end
  local url = "https://api.telegram.org/bot"..telegram_bot_token.."/sendMessage?chat_id="..telegram_chat_id.."&text="..urlencode(message)
  gg.makeRequest(url)
end

function logoAnimation()
  local logo_text = {
    "⚡",
    "⚡R",
    "⚡RM",
    "⚡RMS",
    "⚡RMST",
    "⚡RMSTUD",
    "⚡RMSTUDIO⚡",
    "👤 Ryder Chang 🇹🇼",
    "✅ 初始化完成，歡迎使用！"
  }

  local delay = {400, 400, 400, 400, 400, 400, 800, 800, 1000}

  for i = 1, #logo_text do
    gg.toast(logo_text[i])
    gg.sleep(delay[i])
  end
end

function showMainScreenInfo()
  local now = os.date("*t")
  local datetime = string.format("%04d/%02d/%02d %02d:%02d",
    now.year, now.month, now.day, now.hour, now.min)
  gg.alert("⚡RMSTUDIO⚡ Ryder Chang 🇹🇼\n🕒 "..datetime)
end

function getDeviceId()
  if gg.getDeviceId then
    return gg.getDeviceId()
  else
    local file = io.open("/proc/sys/kernel/random/boot_id", "r")
    if not file then return "UNKNOWN" end
    local id = file:read("*l")
    file:close()
    return id or "UNKNOWN"
  end
end

function downloadKeyData()
  gg.toast("開始從雲端下載密鑰資料...")
  local resp = gg.makeRequest(key_url)
  if resp and resp.content and #resp.content > 0 then
    local f = io.open(key_file_path, "w+b")
    if f then
      f:write(resp.content)
      f:close()
      gg.toast("密鑰資料下載成功！")
      return true
    else
      gg.alert("❌ 無法寫入檔案！")
      return false
    end
  else
    gg.alert("❌ 下載失敗，請檢查網路或連結")
    return false
  end
end

function readKeyData()
  local data = {}
  local file = io.open(key_file_path, "r")
  if not file then return data end
  for line in file:lines() do
    local key, bind, user, name, expire = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)")
    if key then
      table.insert(data, {key = key, bind = bind, user = user, name = name, expire = expire})
    end
  end
  file:close()
  return data
end

function calculateRemainingDays(expireDate)
  if expireDate == "PERMANENT" then
    return 99999
  end
  local y, m, d = expireDate:match("(%d+)-(%d+)-(%d+)")
  if not y then return -1 end
  local expiry = os.time{year=tonumber(y), month=tonumber(m), day=tonumber(d)}
  local today = os.time()
  local diff = math.floor((expiry - today) / (60 * 60 * 24))
  return diff
end

function updateBindingData(key, newBinding)
  local keys = readKeyData()
  for i, v in ipairs(keys) do
    if v.key == key then
      v.bind = newBinding
    end
  end
  local f = io.open(key_file_path, "w")
  if not f then
    gg.alert("❌ 無法寫入綁定資料")
    return false
  end
  for _, v in ipairs(keys) do
    f:write(string.format("%s|%s|%s|%s|%s\n", v.key, v.bind, v.user, v.name, v.expire))
  end
  f:close()
  return true
end

function verifyKey()
  local keys = readKeyData()
  if #keys == 0 then
    gg.alert("❌ 密鑰資料讀取失敗或檔案為空")
    return false
  end
  local input = gg.prompt({"請輸入您的密鑰🔐："}, nil, {"text"})
  if not input or not input[1] then os.exit() end
  local inputKey = input[1]
  local device_id = getDeviceId()
  local now = os.date("%Y-%m-%d %H:%M:%S")

  for _, info in ipairs(keys) do
    if info.key == inputKey then
      if info.bind == "UNBOUND" then
        gg.toast("綁定裝置中...")
        if not updateBindingData(inputKey, device_id) then
          gg.alert("❌ 綁定裝置失敗")
          return false
        end
        info.bind = device_id
        local msg = string.format("📌 新裝置綁定\n🔑 密鑰：%s\n👤 使用者：%s\n📱 裝置ID：%s\n🕒 時間：%s", inputKey, info.user, device_id, now)
        sendTelegramNotification(msg)
      end
      if info.bind == device_id then
        local remaining = calculateRemainingDays(info.expire)
        if remaining >= 0 then
          gg.alert(string.format("✅ 驗證成功\n使用者: %s\n密鑰名稱: %s\n剩餘天數: %d 天", info.user, info.name, remaining))

          user_name = info.user
          key_name = info.name
          remaining_days = remaining

          local script_version = "⚡RMSTUDIO⚡️ VIP腳本👑 V1.2"
          local msg = string.format(
  "✅ 使用者登入通知\n" ..
  "👤 使用者：%s\n" ..
  "🔑 密鑰名稱：%s\n" ..
  "📱 裝置ID：%s\n" ..
  "🕒 時間：%s\n" ..
  "⏳ 剩餘天數：%d\n" ..
  "🧑‍💻 腳本版本：%s",
  info.user, info.name, device_id, now, remaining, script_version
)
          sendTelegramNotification(msg)
          return true
        else
          gg.alert("⛔ 此密鑰已過期")
          return false
        end
      else
        gg.alert("❌ 此密鑰已綁定其他裝置")
        local msg = string.format("⚠️ 密鑰綁定錯誤\n密鑰：%s\n欲使用裝置：%s\n已綁定：%s\n🕒 時間：%s", inputKey, device_id, info.bind, now)
        sendTelegramNotification(msg)
        return false
      end
    end
  end
  gg.alert("❌ 無效密鑰")
  local msg = string.format("❌ 無效密鑰嘗試\n輸入密鑰：%s\n裝置ID：%s\n🕒 時間：%s", inputKey, device_id, now)
  sendTelegramNotification(msg)
  return false
end

function mod_car_414hp()
  gg.setVisible(false)
  gg.alert("🔊 功能：修改414原廠聲浪數據\n請先按重置此車引擎\n並且記住現在車輛的現在4個馬力數值\n完成後再點擊 GG 的 Logo 開始修改")

  -- 等待使用者點擊 GG logo
  while true do
    if gg.isVisible(true) then
      gg.setVisible(false)
      break
    end
  end

  -- 左上
  local topLeft = gg.prompt({"左上：請輸入數字"}, nil, {"number"})
  if topLeft and topLeft[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(topLeft[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("414", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("左上數值已編輯")
  else
    gg.alert("已取消左上數值輸入。")
    return
  end

  -- 右上
  local topRight = gg.prompt({"右上：請輸入數字"}, nil, {"number"})
  if topRight and topRight[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(topRight[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("8000", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("右上數值已編輯")
  else
    gg.alert("已取消右上數值輸入。")
    return
  end

  -- 左下
  local bottomLeft = gg.prompt({"左下：請輸入數字"}, nil, {"number"})
  if bottomLeft and bottomLeft[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(bottomLeft[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("2254", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("左下數值已編輯")
  else
    gg.alert("已取消左下數值輸入。")
    return
  end

  -- 右下
  local bottomRight = gg.prompt({"右下：請輸入數字"}, nil, {"number"})
  if bottomRight and bottomRight[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(bottomRight[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("7997", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("右下數值已編輯")
  else
    gg.alert("已取消右下數值輸入。")
    return
  end
end

function mod_car_1695hp()
  gg.setVisible(false)
  gg.alert("🔊 功能：修改1695原廠聲浪\n請先按重置此車引擎\n並且記住現在車輛的現在4個馬力數值\n完成後再點擊 GG 的 Logo 開始修改")

  -- 等待使用者點擊 GG logo
  while true do
    if gg.isVisible(true) then
      gg.setVisible(false)
      break
    end
  end

  -- 左上
  local topLeft = gg.prompt({"左上：請輸入數字"}, nil, {"number"})
  if topLeft and topLeft[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(topLeft[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("1695", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("左上數值已編輯")
  else
    gg.alert("已取消左上數值輸入。")
    return
  end

  -- 右上
  local topRight = gg.prompt({"右上：請輸入數字"}, nil, {"number"})
  if topRight and topRight[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(topRight[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("7000", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("右上數值已編輯")
  else
    gg.alert("已取消右上數值輸入。")
    return
  end

  -- 左下
  local bottomLeft = gg.prompt({"左下：請輸入數字"}, nil, {"number"})
  if bottomLeft and bottomLeft[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(bottomLeft[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("2254", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("左下數值已編輯")
  else
    gg.alert("已取消左下數值輸入。")
    return
  end

  -- 右下
  local bottomRight = gg.prompt({"右下：請輸入數字"}, nil, {"number"})
  if bottomRight and bottomRight[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(bottomRight[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("3500", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("右下數值已編輯")
  else
    gg.alert("已取消右下數值輸入。")
    return
  end
end


function wallHack()
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.searchNumber("2.4611913e-38F;-10.0F;3.40282347e38F:512", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
  gg.refineNumber("-10", gg.TYPE_FLOAT)
  local results = gg.getResults(100)
  for i, v in ipairs(results) do
    v.value = 9999
    v.freeze = false
  end
  gg.setValues(results)
  gg.toast("✅穿牆修改完成")
end

function greenCurrency()
  gg.setVisible(false)
  gg.alert("請先到『第一關』，再點擊 GG 的 Logo 開始修改")

  -- 等待使用者點擊 GG logo
  while true do
    if gg.isVisible(true) then
      gg.setVisible(false)
      break
    end
  end

  -- 第一階段：Xa 搜尋並修改 50000000 → 999999999
  gg.clearResults()
  gg.setRanges(gg.REGION_CODE_APP) -- 替代原本的 gg.REGION_EXECUTABLE
  gg.searchNumber("50000000", gg.TYPE_FLOAT)
  local r1 = gg.getResults(100)
  for i, v in ipairs(r1) do
    v.value = 999999999
    v.flags = gg.TYPE_FLOAT
  end
  gg.setValues(r1)

  -- 第二階段：A 搜尋並修改 60 → 50000000
  gg.clearResults()
  gg.setRanges(gg.REGION_ANONYMOUS) -- A 區域
  gg.searchNumber("60", gg.TYPE_FLOAT)
  local r2 = gg.getResults(100)
  for i, v in ipairs(r2) do
    v.value = 50000000
    v.flags = gg.TYPE_FLOAT
  end
  gg.setValues(r2)

  -- 顯示完成提示
  gg.toast("修改綠鈔💸 開啟✅")
  gg.alert("請再到『第二關』，並且完成該關卡，如果第二關沒有看到秒數變成50,000,000，請重新打開遊戲重新修改")
end

function modifyshifttime()
  gg.setVisible(false)
  gg.alert("請先購買此車輛的變速箱\n完成後請點 GG 的圖示開始進行修改")

  -- 等待使用者點擊 GG Logo
  while true do
    if gg.isVisible(true) then
      gg.setVisible(false)
      break
    end
  end

  -- 搜尋與修改 變速箱值
  gg.clearResults()
  gg.setRanges(gg.REGION_CODE_APP) -- XA 區域
  gg.searchNumber("0.1", gg.TYPE_FLOAT)
  local results = gg.getResults(100)
  for i, v in ipairs(results) do
    v.value = 1e-12
    v.flags = gg.TYPE_FLOAT
  end
  gg.setValues(results)

  -- 顯示完成提示
  gg.toast("變速箱修改 啟動✅")
  gg.alert("修改完成，請再購買一次變速箱")
end

function modifyCarWeight()
  local animation = {
    "🚗 車重修改準備中...",
    "請稍候...",
    "🔧 準備開始修改車重..."
  }

  for i = 1, #animation do
    gg.toast(animation[i])
    gg.sleep(500)
  end

  gg.alert("📢 請進入此車輛的『購買畫面』\n進入後點擊 GG 圖示開始修改")

  -- 等待使用者點擊 GG Logo
  while true do
    if gg.isVisible(true) then
      gg.setVisible(false)
      break
    end
    gg.sleep(100)
  end

  local input = gg.prompt(
    {"👉請輸入要搜尋的原始數值 補充：MASS欄位的右邊數值（原始車重）", "👉請輸入要修改成的數值（想修改成的車重）"},
    nil,
    {"number", "number"}
  )

  if not input or not input[1] or not input[2] then
    gg.alert("❌ 已取消車重修改")
    return
  end

  local originalWeight = tonumber(input[1])
  local desiredWeight = tonumber(input[2])

  gg.clearResults()
  gg.setRanges(gg.REGION_CODE_APP) -- XA 區域
  gg.searchNumber(originalWeight, gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
  local results = gg.getResults(100)

  if #results == 0 then
    gg.alert("❌ 搜尋不到指定的數值，您可以重開遊戲再嘗試一次修改")
    return
  end

  for i, v in ipairs(results) do
    v.value = desiredWeight
    v.flags = gg.TYPE_FLOAT
  end
  gg.setValues(results)

  gg.toast("✅ 車重已修改為 " .. desiredWeight)
end

function realHoverCar()
  local animation = {
    "🚗 懸浮高度準備中...",
    "請稍候...",
    "🔧 準備開始修改懸浮數值..."
  }

  for i = 1, #animation do
    gg.toast(animation[i])
    gg.sleep(500)
  end

  gg.alert("📢 請進入遊戲場景畫面（例如車庫或房內    ）\n進入後點擊 GG 圖示開始修改")

  -- 等待使用者點擊 GG Logo
  while true do
    if gg.isVisible(true) then
      gg.setVisible(false)
      break
    end
    gg.sleep(100)
  end

  local originalValue = 0.34
  local input = gg.prompt(
    {"👉請輸入要修改成的新數值（例如 50.0）"},
    nil,
    {"number"}
  )

  if not input or not input[1] then
    gg.alert("❌ 已取消懸浮修改")
    return
  end

  local newValue = tonumber(input[1])

  gg.clearResults()
  gg.setRanges(gg.REGION_CODE_APP) -- 記憶範圍設為 XA
  gg.searchNumber(originalValue, gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
  local results = gg.getResults(100)

  if #results == 0 then
    gg.alert("❌ 沒有找到數值：" .. originalValue .. "\n請確認進入正確畫面或重試")
    return
  end

  for i, v in ipairs(results) do
    v.value = newValue
    v.flags = gg.TYPE_FLOAT
  end
  gg.setValues(results)

  gg.toast("✅ 懸浮數值已修改為 " .. newValue)
end

function modifyNameWithColorCode()
  gg.setVisible(false)

  -- 🔍 改名搜尋步驟（略，與前相同）
  gg.alert("提示：請將名字改為『1』\n完成後按 GG 修改器繼續。")
  while not gg.isVisible(true) do gg.sleep(500) end
  gg.setVisible(false)
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.searchNumber("12;1", gg.TYPE_DWORD)

  gg.alert("提示：請將名字改為『123』\n完成後按 GG 修改器繼續。")
  while not gg.isVisible(true) do gg.sleep(500) end
  gg.setVisible(false)
  gg.refineNumber("12;3", gg.TYPE_DWORD)

  gg.alert("提示：請將名字改為『1』\n完成後按 GG 修改器繼續。")
  while not gg.isVisible(true) do gg.sleep(500) end
  gg.setVisible(false)
  gg.refineNumber("12;1", gg.TYPE_DWORD)

  gg.alert("提示：請將名字改為『123』\n完成後按 GG 修改器繼續。")
  while not gg.isVisible(true) do gg.sleep(500) end
  gg.setVisible(false)
  gg.refineNumber("12;3", gg.TYPE_DWORD)

  -- 📌 記憶體修改
  local results = gg.getResults(100)
  if #results == 0 then
    gg.alert("❌ 沒有找到記憶體位置，請確認是否正確完成所有步驟。")
    return
  end
  for i, v in ipairs(results) do v.value = 500 end
  gg.setValues(results)

  gg.alert("✅ 修改成功！你現在可以自由修改名字，限制：色碼+名稱總共最多 20 字")

  local colorOptions = {
    "💛黃色（808000）", "💙亮藍（00BFFF）", "❤️紅色（FF0000）", "💚亮綠（00FF00）",
    "🖤黑色（000000）", "💜紫色（800080）", "🩶灰色（808080）", "🧡橘色（FFA500）",
    "🌸粉紅（FFC0CB）", "🩵青藍（00CED1）", "🟤棕色（8B4513）", "💙深藍（0000CD）",
    "💚暗綠（006400）", "🟡金黃（FFD700）", "🟥酒紅（8B0000）", "🌿草綠（7CFC00）",
    "🩷玫紅（FF1493）", "🔵寶藍（4169E1）", "🟣靛藍（4B0082）", "🌺紫紅（DA70D6）",
    "🍊橘紅（FF6347）", "🍋檸檬黃（FFFACD）", "🫐藍紫（6A5ACD）", "🌊淡藍（87CEFA）",
    "🌼奶黃（FAFAD2）", "🥝淺綠（98FB98）", "🫒橄欖綠（9ACD32）", "🪻薰衣草（E6E6FA）",
    "🍬嫩紫（D8BFD8）", "🫧天藍（ADD8E6）", "🌷淺粉紅（FFB6C1）", "🌿薄荷綠（AAF0D1）",
    "🌞杏黃（FFE4B5）", "🧊冰藍（AFEEEE）", "🪵赤陶（D2691E）", "🧁奶茶（F5DEB3）",
    "🌸櫻花粉（FF69B4）", "🩰淺紫紅（DB7093）", "🍡蜜桃紅（FFDAB9）", "🌻向日黃（FFF8DC）"
  }

  local colorValues = {
    "[808000]", "[00BFFF]", "[FF0000]", "[00FF00]",
    "[000000]", "[800080]", "[808080]", "[FFA500]",
    "[FFC0CB]", "[00CED1]", "[8B4513]", "[0000CD]",
    "[006400]", "[FFD700]", "[8B0000]", "[7CFC00]",
    "[FF1493]", "[4169E1]", "[4B0082]", "[DA70D6]",
    "[FF6347]", "[FFFACD]", "[6A5ACD]", "[87CEFA]",
    "[FAFAD2]", "[98FB98]", "[9ACD32]", "[E6E6FA]",
    "[D8BFD8]", "[ADD8E6]", "[FFB6C1]", "[AAF0D1]",
    "[FFE4B5]", "[AFEEEE]", "[D2691E]", "[F5DEB3]",
    "[FF69B4]", "[DB7093]", "[FFDAB9]", "[FFF8DC]"
  }

  -- UTF-8 字數計算函數
  local function utf8len(str)
    local len = 0
    for _, _ in utf8.codes(str) do
      len = len + 1
    end
    return len
  end

  -- 選擇色碼
  local choice = gg.choice(colorOptions, nil, "🎨 請選擇你想要的名字色碼")
  if choice == nil then
    gg.toast("❌ 你取消了操作")
    return
  end

  -- 輸入名稱
  local nameInput = gg.prompt({"🔤 請輸入名字（最多 12 字）"}, nil, {"text"})
  if nameInput == nil or nameInput[1] == "" then
    gg.toast("❌ 沒有輸入任何名字")
    return
  end

  local name = nameInput[1]
  local charCount = utf8len(name)

  if charCount > 12 then
    gg.alert("❌ 名字太長，最多只能輸入 12 字！\n你輸入了：" .. charCount .. " 字")
    return
  end

  local finalName = colorValues[choice] .. name
  gg.copyText(finalName)
  gg.alert("✅ 名字已複製 您現在可以去名字編輯地方直接貼上：\n\n" .. finalName)
end

function freeToyotaCrown()
    gg.alert("免費豐田皇冠")

    gg.setRanges(gg.REGION_ANONYMOUS)

    gg.searchNumber("3;0;218;-1:13", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
    gg.toast("搜索完成，正在篩選數據...")

    gg.refineNumber("218", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
    gg.toast("篩選完成，正在修改數據...")

    local results = gg.getResults(10)
    if #results > 0 then
        gg.editAll("0", gg.TYPE_DWORD)
        gg.toast("數據修改完成🤫")
    else
        gg.alert("未找到匹配數值，請重試！")
    end

    gg.clearResults()
    gg.alert("修改完成✅ 您現在可以去購車頁面找到豐田皇冠並且購買😆")
end

-- 初始狀態




function second1_race_on()
gg.clearResults()
gg.clearList()
-- main code on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2500", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-999999", gg.TYPE_FLOAT)
gg.processResume()
gg.setRanges(gg.REGION_CODE_APP)

gg.clearResults()
gg.searchNumber("1.1", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("99", gg.TYPE_FLOAT)

gg.clearResults()
gg.searchNumber("10000000", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1E-08", gg.TYPE_FLOAT)
gg.alert("1秒 開啟    ⃢🟢")
gg.processResume()
end

function second1_race_off()
gg.clearResults()
gg.clearList()
-- main code on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("-999999", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("2500", gg.TYPE_FLOAT)
gg.processResume()
gg.setRanges(gg.REGION_CODE_APP)

gg.clearResults()
gg.searchNumber("99", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1.1", gg.TYPE_FLOAT)

gg.clearResults()
gg.searchNumber("1E-08", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("10000000", gg.TYPE_FLOAT)
gg.alert("1 秒 關閉 🔴⃢  ")
gg.processResume()
end
function second2_race_on()
gg.clearResults()
gg.clearList()
-- main code on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2500", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-80000", gg.TYPE_FLOAT)
gg.processResume()

gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("1.1", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("3", gg.TYPE_FLOAT)

gg.clearResults()
gg.searchNumber("10000000", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("2E-44", gg.TYPE_FLOAT)
gg.alert("2秒 開啟   ⃢🟢")
gg.processResume()
end

function second2_race_off()
gg.clearResults()
gg.clearList()
-- main code on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("-80000", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("2500", gg.TYPE_FLOAT)
gg.processResume()

gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("3", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1.1", gg.TYPE_FLOAT)

gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("2E-08", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("10000000", gg.TYPE_FLOAT)
gg.alert("2秒 關閉 🔴⃢  ")
gg.processResume()
end

function second3_race_on()
gg.clearResults()
gg.clearList()
-- main code on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2500", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-80000", gg.TYPE_FLOAT)
gg.processResume()

gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("1.1", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("2.04", gg.TYPE_FLOAT)
gg.alert("3秒 開啟   ⃢🟢")
gg.processResume()
end

function second3_race_off()
gg.clearResults()
gg.clearList()
-- main code on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("-80000", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("2500", gg.TYPE_FLOAT)
gg.processResume()
gg.setRanges(gg.REGION_CODE_APP)

gg.clearResults()
gg.searchNumber("2.04", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1.1", gg.TYPE_FLOAT)
gg.alert("3秒 關閉 🔴⃢  ")
gg.processResume()
end

function hand_brake()
gg.clearResults()
gg.clearList()
-- main code
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("6000", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-6500", gg.TYPE_FLOAT)
gg.toast("手煞車開啟   ⃢🟢")
gg.processResume()
end

function bug_start()
gg.setVisible(false)
LibStart=gg.getRangesList('libil2cpp.so')[2].start
SP=nil
SP={}
SP[1]={}
SP[2]={}
SP[1].address=LibStart+0x31DFE80
SP[1].value='h200080D2'
SP[1].flags=4
SP[2].address=LibStart+(0x31DFE80+0x4)
SP[2].value='hC0035FD6'
SP[2].flags=4
gg.setValues(SP)

LibStart=gg.getRangesList('libil2cpp.so')[1].start
SP=nil
SP={}
SP[1]={}
SP[2]={}
SP[1].address=LibStart+0x31DFE80
SP[1].value='h200080D2'
SP[1].flags=4
SP[2].address=LibStart+(0x31DFE80+0x4)
SP[2].value='hC0035FD6'
SP[2].flags=4
gg.setValues(SP)
gg.setValues(SP)
gg.toast("ON")
gg.sleep(1000)
end

function control_glitch()
-- 控制秒車
gg.clearResults()
gg.clearList()
-- main code on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("9.18354962e-41;0.15000000596;0.25:17", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
gg.refineNumber("0.15000000596", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("0", gg.TYPE_FLOAT)
gg.alert("開啟    ⃢🟢")
gg.processResume()
end

function drift_car_on()
gg.clearResults()
gg.clearList()
-- main code
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("1.6", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("10", gg.TYPE_FLOAT)
gg.toast("開啟   ⃢🟢")
gg.processResume()
end

function drift_car_off()
gg.clearResults()
gg.clearList()
-- main code
gg.setRanges(gg.REGION_CODE_APP)
if revert ~= nil then gg.setValues(revert) end
gg.toast("關閉 🔴⃢  ")
gg.processResume()
end

car_dance1_on = false
on = "    ⃢🟢"
off = "🔴⃢  "
local saved_results = {}

function car_dance1(enable)
    -- 設定記憶體搜索範圍為 XA 區域
    gg.setRanges(gg.REGION_CODE_APP)

    -- 如果是啟用狀態，則進行搜索
    if enable then
        gg.clearResults()
        gg.searchNumber("10000000", gg.TYPE_FLOAT)
        saved_results = gg.getResults(1000) -- 獲取前1000個結果並保存

        -- 檢查是否找到結果
        if #saved_results == 0 then
            gg.toast("未找到符合條件的值")
            return
        end
    end

    -- 根據 enable 參數設置值
    local value = enable and "-50" or "1"

    -- 修改找到的浮點數值
    for i, v in ipairs(saved_results) do
        v.value = value
        v.flags = gg.TYPE_FLOAT
    end

    -- 將修改後的值寫回記憶體
    gg.setValues(saved_results)

    -- 提示修改完成
    gg.toast("修改完成")
end

car_dance2_on = false
on = "    ⃢🟢"
off = "🔴⃢  "
local saved_results = {}

function car_dance2(enable)
    -- 設定記憶體搜索範圍為 XA 區域
    gg.setRanges(gg.REGION_CODE_APP)

    -- 如果是啟用狀態，則進行搜索
    if enable then
        gg.clearResults()
        gg.searchNumber("10000000", gg.TYPE_FLOAT)
        saved_results = gg.getResults(1000) -- 獲取前1000個結果並保存

        -- 檢查是否找到結果
        if #saved_results == 0 then
            gg.toast("未找到符合條件的值")
            return
        end
    end

    -- 根據 enable 參數設置值
    local value = enable and "-15" or "1"

    -- 修改找到的浮點數值
    for i, v in ipairs(saved_results) do
        v.value = value
        v.flags = gg.TYPE_FLOAT
    end

    -- 將修改後的值寫回記憶體
    gg.setValues(saved_results)

    -- 提示修改完成
    gg.toast("修改完成")
end

car_dance3_on = false
on = "    ⃢🟢"
off = "🔴⃢  "
local saved_results = {}

function car_dance3(enable)
    -- 設定記憶體搜索範圍為 XA 區域
    gg.setRanges(gg.REGION_CODE_APP)

    -- 如果是啟用狀態，則進行搜索
    if enable then
        gg.clearResults()
        gg.searchNumber("10000000", gg.TYPE_FLOAT)
        saved_results = gg.getResults(1000) -- 獲取前1000個結果並保存

        -- 檢查是否找到結果
        if #saved_results == 0 then
            gg.toast("未找到符合條件的值")
            return
        end
    end

    -- 根據 enable 參數設置值
    local value = enable and "-1" or "1"

    -- 修改找到的浮點數值
    for i, v in ipairs(saved_results) do
        v.value = value
        v.flags = gg.TYPE_FLOAT
    end

    -- 將修改後的值寫回記憶體
    gg.setValues(saved_results)

    -- 提示修改完成
    gg.toast("修改完成")
end


function racemenu()
  local choice = gg.choice({
    "🚀1秒(400m)開啟    ⃢🟢",
    "🚀1秒(400m)關閉 🔴⃢  ",
    "🚀 2秒(400m)開啟    ⃢🟢",
    "🚀 2秒(400m)關閉 🔴⃢  ",
    "🚀 3秒(400m)開啟    ⃢🟢",
    "🚀 3秒(400m)關閉 🔴⃢  ",
    "🔥 手煞車 ",
    "🤭 Bug起跑 ",
    "🎛️ 強制控制秒車 ",
    "🔙 返回主選單"
  }, nil, "🏁比賽功能選單\n請選擇一個功能：")

  if choice == 1 then
    second1_race_on()
  elseif choice == 2 then
    second1_race_off()
    -- 1秒關閉
  elseif choice == 3 then
    second2_race_on()
  elseif choice == 4 then
    second2_race_off()
  elseif choice == 5 then
    second3_race_on()
  elseif choice == 6 then
    second3_race_off()
  elseif choice == 7 then
    hand_brake()
  elseif choice == 8 then
    bug_start()
  elseif choice == 9 then
    control_glitch()
  elseif choice == 10 or choice == nil then
    return
  end
end

function funmenu()
  local state = car_dance1_on and on or off
  local state = car_dance2_on and on or off
  local state = car_dance3_on and on or off
  local choice = gg.choice({
    state .."惡搞 汽車跳舞1😜",
    state .."惡搞 汽車跳舞2😜",
    state .."惡搞 汽車失重飄浮😜",
    "🧱穿牆",
    "🔙 返回主選單"
  }, nil, "😏好玩菜單功能選單\n請選擇一個功能：")

  if choice == 1 then
    car_dance1_on = not car_dance1_on
      car_dance1(car_dance1_on)
  elseif choice == 2 then
    car_dance2_on = not car_dance2_on
      car_dance2(car_dance2_on)
  elseif choice == 3 then
    car_dance3_on = not car_dance3_on
      car_dance3(car_dance3_on)
  -- 車輛跳舞漂浮
  elseif choice == 4 then
    wallHack()
  elseif choice == 5 or choice == nil then
    return
  end
end

function mod_car_menu()
  local choice = gg.choice({
    "🔧原廠聲浪414hp",
    "🔧原廠聲浪1695hp",
    "🔁修改車重",
    "☠️變速箱修改 1E-12秒",
    "🔙 返回主選單"
  }, nil, "⚒️車輛修改\n請選擇一個功能：")

  if choice == 1 then
    mod_car_414hp()
  elseif choice == 2 then
    mod_car_1695hp()
  elseif choice == 3 then
    modifyCarWeight()
  elseif choice == 4 then
    modifyshifttime()
  elseif choice == 5 or choice == nil then
    return
  end
end

function unlock_car_menu()
  local choice = gg.choice({
    "🔓解鎖購買豐田皇冠車",
    "🔙 返回主選單"
  }, nil, "🔓解鎖車輛項目菜單\n請選擇一個功能：")

  if choice == 1 then
    freeToyotaCrown()
  elseif choice == 2 or choice == nil then
    return
  end
end

function car_drift_on()
gg.clearResults()
gg.clearList()
-- main code
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("1.6", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("10", gg.TYPE_FLOAT)
gg.toast("甩尾已開啟    ⃢🟢")
gg.processResume()
end

function car_drift_off()
gg.clearResults()
gg.clearList()
-- main code
gg.setRanges(gg.REGION_CODE_APP)
if revert ~= nil then gg.setValues(revert) end
gg.toast("車輛甩尾已關閉 🔴⃢  ")
gg.processResume()
end



function car_drift_menu()
   local choice = gg.choice({
    "💨車輛甩尾 開啟    ⃢🟢 ",
    "💨車輛甩尾 關閉🔴⃢   ",
    "🔙 返回主選單"
  }, nil, "☄️車輛甩尾功能選單\n請選擇一個功能：")

  if choice == 1 then
    car_drift_on()
  elseif choice == 2 then
    car_drift_off()
  elseif choice == 3 or choice == nil then
    return
  end
end

function aboutAuthor()
  gg.alert(
    "👨‍💻 作者資訊\n\n" ..
    "名稱：⚡RMSTUDIO⚡ Ryder Chang 🇹🇼\n" ..
    "版本：RMSTUDIO CPM腳本 版本V1.5\n" ..
    "聯絡方式：\n" ..
    "Telegram @ryderyo666\n" ..
    "Facebook @Ryder Chang\n" ..
    "YouTube @R&MGAME\n\n" ..
    "如需購買其他腳本或者CPM1或CPM2都歡迎私訊購買😚\n" ..
    "感謝您的支持‼️"
  )
end

function mainMenu()
  while true do
    local now = os.date("*t")
    local datetime = string.format("%04d/%02d/%02d %02d:%02d:%02d",
      now.year, now.month, now.day, now.hour, now.min, now.sec)

    local title = string.format(
      "⚡RMSTUDIO⚡ 功能選單\n\n" ..
      "📅 時間：%s\n" ..
      "👤 使用者：%s\n" ..
      "🔑 密鑰名稱：%s\n" ..
      "⏳ 剩餘天數：%s 天\n" ..
      "🧑‍💻 腳本作者：⚡RMSTUDIO⚡ Ryder Chang🇹🇼\n",
      datetime,
      user_name or "未登入",
      key_name or "未知",
      remaining_days or "未知"
    )
    
    local choice = gg.choice({
      "💸綠鈔5000萬",
      "🥵真正的懸浮車",
      "📋修改長名含色碼",
      "🔓車輛解鎖菜單",
      "🔧🚗車輛修改菜單",
      "😏好玩菜單",
      "🏁比賽菜單",
      "💨車輛甩尾菜單",
      "📄 關於作者",
      "❌ 退出腳本"
    }, nil, title)

    if choice == nil then
     gg.setVisible(false) -- 不結束，只是隱藏腳本 UI
     break
    elseif choice == 1 then
      greenCurrency()
    elseif choice == 2 then
      realHoverCar()
    elseif choice == 3 then
      modifyNameWithColorCode()
    elseif choice == 4 then
      unlock_car_menu()
    elseif choice == 5 then
      mod_car_menu()
    elseif choice == 6 then
      funmenu()
    elseif choice == 7 then
      racemenu()
    elseif choice == 8 then
      car_drift_menu()
    elseif choice == 9 then
      aboutAuthor()
    elseif choice == 10 then
      gg.toast("腳本已退出 作者 ⚡RMSTUDIO⚡Ryder Chang🇹🇼")
      os.exit()
      break
    end
  end
end

checkupdating()

-- 這裡寫你的主要腳本內容
gg.toast("腳本啟動成功！")

-- 執行流程
logoAnimation()

if not downloadKeyData() then
  gg.alert("❌ 雲端密鑰下載失敗，腳本結束")
  os.exit()
end

showMainScreenInfo()

if not verifyKey() then
  gg.alert("⛔ 驗證失敗，腳本即將結束")
  os.exit()
end


gg.alert(string.format(
  "🎉 歡迎使用完整功能！\n\n👤 使用者：%s\n🔑 密鑰名稱：%s\n⏳ 剩餘天數：%s 天\n\n🚨 注意事項：\n1️⃣ 密鑰已綁定您的此部裝置\n2️⃣ 出現異常請重啟遊戲\n\n✅ 感謝支持 ⚡RMSTUDIO⚡Ryder Chang🇹🇼！",
  user_name or "未知",
  key_name or "未知",
  remaining_days or "未知"
))
mainMenu()

while true do
  if gg.isVisible(true) then
    gg.setVisible(false)
    mainMenu()
  end
  gg.sleep(100)
end

