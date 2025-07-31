local key_file_path = "/storage/emulated/0/key_data.txt"
local key_url = "https://raw.githubusercontent.com/CPMRm/rmstudio-gg-keydata/main/key_data.txt"

local telegram_bot_token = "8404020167:AAFZPUbKUUnwTDmHJEw_WEtRhH3Nx5dGIWI"
local telegram_chat_id = "6662550521"

function 發送Telegram通知(message)
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

function logo動畫()
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

function 顯示主畫面資訊()
  local now = os.date("*t")
  local datetime = string.format("%04d/%02d/%02d %02d:%02d",
    now.year, now.month, now.day, now.hour, now.min)
  gg.alert("⚡RMSTUDIO⚡ Ryder Chang 🇹🇼\n🕒 "..datetime)
end

function get_device_id()
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

function 下載密鑰資料()
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

function 讀取密鑰資料()
  local data = {}
  local file = io.open(key_file_path, "r")
  if not file then return data end
  for line in file:lines() do
    local key, bind, user, name, expire = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)")
    if key then
      table.insert(data, {密鑰=key, 綁定=bind, 使用者=user, 名稱=name, 到期日=expire})
    end
  end
  file:close()
  return data
end

function 計算剩餘天數(到期日)
  if 到期日 == "PERMANENT" then
    return 99999
  end
  local y, m, d = 到期日:match("(%d+)-(%d+)-(%d+)")
  if not y then return -1 end
  local expiry = os.time{year=tonumber(y), month=tonumber(m), day=tonumber(d)}
  local today = os.time()
  local diff = math.floor((expiry - today) / (60 * 60 * 24))
  return diff
end

function 修改綁定資料(密鑰, 新綁定)
  local keys = 讀取密鑰資料()
  for i, v in ipairs(keys) do
    if v.密鑰 == 密鑰 then
      v.綁定 = 新綁定
    end
  end
  local f = io.open(key_file_path, "w")
  if not f then
    gg.alert("❌ 無法寫入綁定資料")
    return false
  end
  for _, v in ipairs(keys) do
    f:write(string.format("%s|%s|%s|%s|%s\n", v.密鑰, v.綁定, v.使用者, v.名稱, v.到期日))
  end
  f:close()
  return true
end

function 驗證密鑰()
  local keys = 讀取密鑰資料()
  if #keys == 0 then
    gg.alert("❌ 密鑰資料讀取失敗或檔案為空")
    return false
  end
  local input = gg.prompt({"請輸入您的密鑰🔐："}, nil, {"text"})
  if not input or not input[1] then os.exit() end
  local inputKey = input[1]
  local device_id = get_device_id()
  local now = os.date("%Y-%m-%d %H:%M:%S")

  for _, info in ipairs(keys) do
    if info.密鑰 == inputKey then
      if info.綁定 == "UNBOUND" then
        gg.toast("綁定裝置中...")
        if not 修改綁定資料(inputKey, device_id) then
          gg.alert("❌ 綁定裝置失敗")
          return false
        end
        info.綁定 = device_id
        local msg = string.format("📌 新裝置綁定\n🔑 密鑰：%s\n👤 使用者：%s\n📱 裝置ID：%s\n🕒 時間：%s", inputKey, info.使用者, device_id, now)
        發送Telegram通知(msg)
      end
      if info.綁定 == device_id then
        local 剩餘 = 計算剩餘天數(info.到期日)
        if 剩餘 >= 0 then
          gg.alert(string.format("✅ 驗證成功\n使用者: %s\n密鑰名稱: %s\n剩餘天數: %d 天", info.使用者, info.名稱, 剩餘))
          
          user_name = info.使用者
          key_name = info.名稱
          remaining_days = 剩餘
          
          local script_version = "⚡RMSTUDIO⚡️ VIP腳本👑 V1.1"
          local msg = string.format(
  "✅ 使用者登入通知\n" ..
  "👤 使用者：%s\n" ..
  "🔑 密鑰名稱：%s\n" ..
  "📱 裝置ID：%s\n" ..
  "🕒 時間：%s\n" ..
  "⏳ 剩餘天數：%d\n" ..
  "🧑‍💻 腳本版本：%s",
  info.使用者, info.名稱, device_id, now, 剩餘, script_version
)
          發送Telegram通知(msg)
          return true
        else
          gg.alert("⛔ 此密鑰已過期")
          return false
        end
      else
        gg.alert("❌ 此密鑰已綁定其他裝置")
        local msg = string.format("⚠️ 密鑰綁定錯誤\n密鑰：%s\n欲使用裝置：%s\n已綁定：%s\n🕒 時間：%s", inputKey, device_id, info.綁定, now)
        發送Telegram通知(msg)
        return false
      end
    end
  end
  gg.alert("❌ 無效密鑰")
  local msg = string.format("❌ 無效密鑰嘗試\n輸入密鑰：%s\n裝置ID：%s\n🕒 時間：%s", inputKey, device_id, now)
  發送Telegram通知(msg)
  return false
end

function 原廠聲浪數據車()
  gg.alert("🔊 功能：414原廠聲浪數據車")

  -- 左上
  local 左上 = gg.prompt({"左上：請輸入數字"}, nil, {"number"})
  if 左上 and 左上[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(左上[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("414", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("左上數值已編輯為414")
  else
    gg.alert("已取消左上數值輸入。")
    return
  end

  -- 右上
  local 右上 = gg.prompt({"右上：請輸入數字"}, nil, {"number"})
  if 右上 and 右上[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(右上[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("8000", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("右上數值已編輯為8000")
  else
    gg.alert("已取消右上數值輸入。")
    return
  end

  -- 左下
  local 左下 = gg.prompt({"左下：請輸入數字"}, nil, {"number"})
  if 左下 and 左下[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(左下[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("2254", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("左下數值已編輯為2254")
  else
    gg.alert("已取消左下數值輸入。")
    return
  end

  -- 右下
  local 右下 = gg.prompt({"右下：請輸入數字"}, nil, {"number"})
  if 右下 and 右下[1] then
    gg.clearResults()
    gg.searchNumber(tonumber(右下[1]), gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(100)
    gg.editAll("7997", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("右下數值已編輯為7997")
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

function 綠鈔()
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

function 變速箱修改()
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

function 修改車重()
  local 動畫 = {
    "🚗 車重修改準備中...",
    "請稍候...",
    "🔧 準備開始修改車重..."
  }

  for i = 1, #動畫 do
    gg.toast(動畫[i])
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

  local 原始車重 = tonumber(input[1])
  local 想修改成的車重 = tonumber(input[2])

  gg.clearResults()
  gg.setRanges(gg.REGION_CODE_APP) -- XA 區域
  gg.searchNumber(原始車重, gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
  local results = gg.getResults(100)

  if #results == 0 then
    gg.alert("❌ 搜尋不到指定的數值，您可以重開遊戲再嘗試一次修改")
    return
  end

  for i, v in ipairs(results) do
    v.value = 想修改成的車重
    v.flags = gg.TYPE_FLOAT
  end
  gg.setValues(results)

  gg.toast("✅ 車重已修改為 " .. 想修改成的車重)
end

function 真正的懸浮車()
  local 動畫 = {
    "🚗 懸浮高度準備中...",
    "請稍候...",
    "🔧 準備開始修改懸浮數值..."
  }

  for i = 1, #動畫 do
    gg.toast(動畫[i])
    gg.sleep(500)
  end

  gg.alert("📢 請進入遊戲場景畫面（例如車庫或地圖）\n進入後點擊 GG 圖示開始修改")

  -- 等待使用者點擊 GG Logo
  while true do
    if gg.isVisible(true) then
      gg.setVisible(false)
      break
    end
    gg.sleep(100)
  end

  local 原始值 = 0.34
  local input = gg.prompt(
    {"👉請輸入要修改成的新數值（例如 50.0）"},
    nil,
    {"number"}
  )

  if not input or not input[1] then
    gg.alert("❌ 已取消懸浮修改")
    return
  end

  local 新值 = tonumber(input[1])

  gg.clearResults()
  gg.setRanges(gg.REGION_CODE_APP) -- 記憶範圍設為 XA
  gg.searchNumber(原始值, gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
  local results = gg.getResults(100)

  if #results == 0 then
    gg.alert("❌ 沒有找到數值：" .. 原始值 .. "\n請確認進入正確畫面或重試")
    return
  end

  for i, v in ipairs(results) do
    v.value = 新值
    v.flags = gg.TYPE_FLOAT
  end
  gg.setValues(results)

  gg.toast("✅ 懸浮數值已修改為 " .. 新值)
end

function 修改名字含色碼()
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

local 色碼選項 = {
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

local 色碼值 = {
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

local 選擇 = gg.choice(色碼選項, nil, "🎨 請選擇你想要的名字色碼")
if 選擇 == nil then
  gg.toast("❌ 你取消了操作")
  return
end

  local 選擇 = gg.choice(色碼選項, nil, "🎨 請選擇你想要的名字色碼")
  if 選擇 == nil then
    gg.toast("❌ 你取消了操作")
    return
  end

  local 名稱輸入 = gg.prompt({"🔤 請輸入名字（最多 12 字）"}, nil, {"text"})
  if 名稱輸入 == nil or 名稱輸入[1] == "" then
    gg.toast("❌ 沒有輸入任何名字")
    return
  end

  local 名稱 = 名稱輸入[1]
  if string.len(名稱) > 12 then
    gg.alert("❌ 名字太長，最多只能輸入 12 字元！\n你輸入了：" .. string.len(名稱))
    return
  end

  local 最終名稱 = 色碼值[選擇] .. 名稱
  gg.copyText(最終名稱)
  gg.alert("✅ 名字已複製：\n\n" .. 最終名稱 .. "\n\n📏 共 " .. string.len(最終名稱) .. " 字（上限 20）")
end

function 關於作者()
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

function 主選單()
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
      "🔧414hp原廠聲浪",
      "🧱穿牆",
      "💸綠鈔5000萬",
      "☠️變速箱修改 1E-12秒",
      "🔁修改車重",
      "🥵真正的懸浮車",
      "📋修改長名含色碼",
      "📄 關於作者",
      "🔐 驗證密鑰",
      "❌ 退出腳本"
    }, nil, title)

    if choice == nil then
     gg.setVisible(false) -- 不結束，只是隱藏腳本 UI
     break
    elseif choice == 1 then
      原廠聲浪數據車()
    elseif choice == 2 then
      wallHack()
    elseif choice == 3 then
      綠鈔()
    elseif choice == 4 then
      變速箱修改() 
    elseif choice == 5 then
      修改車重()
    elseif choice == 6 then  
      真正的懸浮車()
    elseif choice == 7 then
      修改名字含色碼()
    elseif choice == 8 then
      關於作者()
    elseif choice == 9 then
      驗證密鑰()
    elseif choice == 10 then
      gg.toast("腳本已退出 作者 ⚡RMSTUDIO⚡Ryder Chang🇹🇼")
      os.exit()
      break
    end
  end
end

-- 執行流程
logo動畫()

if not 下載密鑰資料() then
  gg.alert("❌ 雲端密鑰下載失敗，腳本結束")
  os.exit()
end

顯示主畫面資訊()

if not 驗證密鑰() then
  gg.alert("⛔ 驗證失敗，腳本即將結束")
  os.exit()
end

logo動畫()
gg.sleep(500)  
gg.alert(string.format(
  "🎉 歡迎使用完整功能！\n\n👤 使用者：%s\n🔑 密鑰名稱：%s\n⏳ 剩餘天數：%s 天\n\n🚨 注意事項：\n1️⃣ 密鑰已綁定您的此部裝置\n2️⃣ 出現異常請重啟遊戲\n\n✅ 感謝支持 ⚡RMSTUDIO⚡Ryder Chang🇹🇼！",
  user_name or "未知",
  key_name or "未知",
  remaining_days or "未知"
))
主選單()

while true do
  if gg.isVisible(true) then
    gg.setVisible(false)
    主選單()
  end
  gg.sleep(100)
end
