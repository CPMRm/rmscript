-- 🌟 Car Parking Multiplayer - GG Script
-- Author: YT R&MGAME ⚡ RMSTUDIO ⚡
-- YouTube: RMGAMER
-- Telegram: @RM GAMER CPM

-- 🎬 Startup Animation
function showIntro()
    local intro = {
        "🚀 Loading RMGAMER Script...",
        "📺 YouTube: RMGAMER",
        "📢 Telegram: @RM GAMER CPM",
        "✅ Script Loaded!"
    }
    for _, text in ipairs(intro) do
        gg.toast(text)
        gg.sleep(800) -- Delay for animation effect
    end
end

function greenCurrency()
    gg.setVisible(false)
    gg.alert("Please go to 'Level 1' first, then click the GG logo to start modifying.")

    -- Wait for user to click GG logo
    while true do
        if gg.isVisible(true) then
            gg.setVisible(false)
            break
        end
    end

    -- Stage 1: Xa search and modify 50000000 → 999999999
    gg.clearResults()
    gg.setRanges(gg.REGION_CODE_APP)
    gg.searchNumber("50000000", gg.TYPE_FLOAT)
    local r1 = gg.getResults(100)
    for i, v in ipairs(r1) do
        v.value = 999999999
        v.flags = gg.TYPE_FLOAT
    end
    gg.setValues(r1)

    -- Stage 2: A search and modify 60 → 50000000
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("60", gg.TYPE_FLOAT)
    local r2 = gg.getResults(100)
    for i, v in ipairs(r2) do
        v.value = 50000000
        v.flags = gg.TYPE_FLOAT
    end
    gg.setValues(r2)

    -- Show completion message
    gg.toast("💸 1B money on ✅")
    gg.alert("Now go to 'Level 2' and complete it.\nIf you don’t see the timer change to 50,000,000 in Level 2, please restart the game and try again.")
end

function mainmenu()
    local now = os.date("*t")
    local datetime = string.format("Date: %04d/%02d/%02d  Time: %02d:%02d:%02d",
        now.year, now.month, now.day, now.hour, now.min, now.sec)

    local menu = gg.choice({
        "💸 1B money",
        "❌ Exit"
    }, nil, "🚗 Car Parking Multiplayer - GG Script\n📺 YouTube: RMGAMER\n📢 Telegram: @RM GAMER CPM\n"..datetime)

    if menu == 1 then
        greenCurrency()
    elseif menu == 2 then
        gg.toast("👋 Script exited")
        os.exit()
    end
end

-- 🔄 Script Loop
showIntro()
while true do
    if gg.isVisible(true) then
        gg.setVisible(false)
        mainmenu()
    end
    gg.sleep(100)
end
