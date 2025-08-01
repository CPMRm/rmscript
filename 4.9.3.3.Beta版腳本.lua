-- Constant Information
local GLabel = 'Car Parking'
local GProcess = 'com.olzhas.carparking.multyplayer'
local GVersion = '4.9.3'

-- Application Verification
local v = gg.getTargetInfo()
if v.processName ~= GProcess then
  gg.alert("Car Parking version you can use this script for:\n"..GLabel.."\n"..GProcess..
           "\n\nYour current version:\n"..v.label.."\n"..v.processName)
  os.exit()
end

if GVersion ~= v.versionName then
  gg.alert("Scripti kullanabileceÄŸiniz sÃ¼rÃ¼m:\n"..GVersion..
           "\n\nYour current version:\n"..v.versionName)
  os.exit()
end

-- TanÄ±mlÄ± Sabit Arama
gg.searchNumber(":Cebrail", 1)
gg.clearResults()

-- Memory Address Value Setting Function
function setvalue(address, flags, value)
  gg.setValues({[1] = {address = address, flags = flags, value = value}})
end

-- Main Menu
function anaMenu()
  local secenekler = {
    "Coin & Money Menu",
    "Race Menu",
    "Achievements Menu",
    "Unlock Menu",
    "Modification Menu",
    "Chrome Menu",
    "UFO Menu",
    "Body Kit Menu",
    "HP Menu",
    "Exit"
  }

  local secim = gg.choice(secenekler, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")
  if secim == nil then return end

  local fonksiyonlar = {
    coinparaMenu, yarisMenu, basarilarMenu, kilitAcmaMenu,
    modifiyeMenu, kromMenu, ufoMenu, govdeMenu, hp, cikisYap
  }

  fonksiyonlar[secim]()
end

function cikisYap()
  gg.clearResults()
  gg.clearList()
  gg.toast("Script Exit yapÄ±lÄ±yor...")
  os.exit()
end

-- Coin & Para Alt MenÃ¼sÃ¼
function coinparaMenu()
  local menu = gg.choice({
    "Coin MenÃ¼",
    "Para MenÃ¼",
    "0$ Araba SatÄ±n Al",
    "Geri"
  }, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")

  if menu == 1 then coinMenu()
  elseif menu == 2 then paraMenu()
  elseif menu == 3 then arabaBedava()
  elseif menu == 4 then anaMenu()
  end
end

-- 0â‚? Araba SatÄ±n Alma
function arabaBedava()
  degerarama("SellCarTrigger", "0x60", false, false, gg.TYPE_QWORD)
  local t = gg.getResults(150)
  for i, v in ipairs(t) do
    v.value = 0
    v.freeze = true
  end
  gg.addListItems(t)
  gg.clearResults()
  gg.alert("Pazarda bulunan tÃ¼m araÃ§lar 0â‚?")
end

-- Coin MenÃ¼sÃ¼
function coinMenu()
  local menu = gg.choice({
    "Coin ArtÄ±r",
    "Coin DÃ¼ÅŸÃ¼r",
    "Geri"
  }, nil, "YouTube: @R&MGAME\nTelegram: @RMSTUDIO MAIN")

  if menu == 1 then
    increaseMenu()
  elseif menu == 2 then
    decreaseMenu()
  elseif menu == 3 then
    coinparaMenu()
  end
end

-- Coin ArtÄ±rma
function increaseMenu()
  local menu = gg.choice({
    "10K Coin ArtÄ±r",
    "20K Coin ArtÄ±r",
    "30K Coin ArtÄ±r",
    "500K Coin ArtÄ±r",
    "Ã–zel Coin ArtÄ±r",
    "Geri"
  }, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")

  local miktarlar = {10000, 20000, 30000, 500000}
  if menu and menu >= 1 and menu <= 4 then
    setCoinToTarget(miktarlar[menu])
  elseif menu == 5 then
    applyCustomCoinIncrease()
  elseif menu == 6 then
    coinMenu()
  end
end

function setCoinToTarget(hedef)
  local input = gg.prompt({"Mevcut coin miktarÄ±nÄ± girin:"}, nil, {"number"})
  if not input then return gg.alert("Ä°ÅŸlem iptal edildi.") end

  local mevcut = tonumber(input[1])
  if not mevcut then return gg.alert("GeÃ§ersiz sayÄ± girdiniz.") end
  if hedef <= mevcut then return gg.alert("Sadece artÄ±rma yapÄ±labilir.") end

  local fark = hedef - mevcut
  degerarama("Prize", "0x10", false, false, 32)
  local results = gg.getResults(100)
  if #results == 0 then return gg.alert("SonuÃ§ bulunamadÄ±!") end

  for i, v in ipairs(results) do v.value = fark end
  gg.setValues(results)
gg.clearResults()
  gg.alert("Odaya girin ve gÃ¼nlÃ¼k gÃ¶revlerden birini tamamlayÄ±n.\nHangi gÃ¶revi yapmak istiyorsanÄ±z BaÅŸarÄ±lar menÃ¼sÃ¼nden hÄ±zlÄ±ca yapabilirsiniz.")
  gg.toast("Coin deÄŸeri " .. fark .. " artÄ±rÄ±ldÄ±.")
end

function applyCustomCoinIncrease()
  local input = gg.prompt({"Mevcut coin miktarÄ±:", "Hedef coin miktarÄ±:"}, nil, {"number", "number"})
  if not input then return gg.alert("Ä°ÅŸlem iptal edildi.") end

  local mevcut, hedef = tonumber(input[1]), tonumber(input[2])
  if not mevcut or not hedef then return gg.alert("GeÃ§ersiz sayÄ±.") end
  if hedef <= mevcut then return gg.alert("Sadece artÄ±rma yapÄ±labilir.") end

  local fark = hedef - mevcut
  degerarama("Prize", "0x10", false, false, 32)
  local results = gg.getResults(100)
  if #results == 0 then return gg.alert("SonuÃ§ bulunamadÄ±!") end

  for i, v in ipairs(results) do v.value = fark end
  gg.setValues(results)
gg.clearResults()
  gg.alert("Odaya girin ve gÃ¼nlÃ¼k gÃ¶revlerden birini tamamlayÄ±n.\nHangi gÃ¶revi yapmak istiyorsanÄ±z, BaÅŸarÄ±lar menÃ¼sÃ¼nden hÄ±zlÄ±ca yapabilirsiniz.")
  gg.toast("Coin deÄŸeri " .. fark .. " artÄ±rÄ±ldÄ±.")
end

-- Coin Azaltma
function decreaseMenu()
  local menu = gg.choice({
    "10K Coin Azalt",
    "20K Coin Azalt",
    "30K Coin Azalt",
    "500K Coin Azalt",
    "Ã–zel Coin Azalt",
    "Geri"
  }, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")

  local miktarlar = {10000, 20000, 30000, 500000}
  if menu and menu >= 1 and menu <= 4 then
    decreaseCoinByTarget(miktarlar[menu])
  elseif menu == 5 then
    applyCustomCoinDecrease()
  elseif menu == 6 then
    coinMenu()
  end
end

function decreaseCoinByTarget(hedef)
  gg.alert("LÃ¼tfen komutlarÄ± adÄ±m adÄ±m yapÄ±n:\n\n\n\naraba satÄ±n alma yerine gidip bir aracÄ± seÃ§in araba Ã¼zerinde bulunan ok iÅŸaretlerin den birine tÄ±klayÄ±n ve coinli  gÃ¶vde kitini seÃ§in ve ardÄ±ndan GG'yi tÄ±klayÄ±n.")
  repeat until gg.isVisible() gg.setVisible(false)

  local input = gg.prompt({"Mevcut coin miktarÄ±nÄ± girin:"}, nil, {"number"})
  if not input then return gg.alert("Ä°ÅŸlem iptal edildi.") end

  local mevcut = tonumber(input[1])
  if not mevcut then return gg.alert("GeÃ§ersiz sayÄ±.") end
  if hedef >= mevcut then return gg.alert("Sadece azaltma yapÄ±labilir.") end

  local fark = mevcut - hedef
  local yazilacakSayi = -fark
  degerarama("KitController", "0x44", false, false, 4)
  local results = gg.getResults(100)
  if #results == 0 then return gg.alert("SonuÃ§ bulunamadÄ±!") end

  for i, v in ipairs(results) do v.value = yazilacakSayi end
  gg.setValues(results)
gg.clearResults()
  gg.alert("aynÄ± kit saÄŸ oka ardÄ±ndan sol oka tÄ±klayÄ±n ve arabayÄ± satÄ±n alÄ±n.")
  gg.toast("Coin deÄŸeri " .. fark .. " azaltÄ±ldÄ±.")
end

function applyCustomCoinDecrease()
  gg.alert("LÃ¼tfen komutlarÄ± adÄ±m adÄ±m yapÄ±n:\n\n\n\naraba satÄ±n alma yerine gidip bir aracÄ± seÃ§in araba Ã¼zerinde bulunan ok iÅŸaretlerin den birine tÄ±klayÄ±n ve coinli  gÃ¶vde kitini seÃ§in ve ardÄ±ndan GG'yi tÄ±klayÄ±n.")
  repeat until gg.isVisible() gg.setVisible(false)

  local input = gg.prompt({"Mevcut coin:", "Hedef coin:"}, nil, {"number", "number"})
  if not input then return gg.alert("Ä°ÅŸlem iptal edildi.") end

  local mevcut, hedef = tonumber(input[1]), tonumber(input[2])
  if not mevcut or not hedef then return gg.alert("GeÃ§ersiz sayÄ±.") end
  if hedef >= mevcut then return gg.alert("Sadece azaltma yapÄ±labilir.") end

  local fark = mevcut - hedef
  local yazilacakSayi = -fark
  degerarama("KitController", "0x44", false, false, 4)
  local results = gg.getResults(100)
  if #results == 0 then return gg.alert("SonuÃ§ bulunamadÄ±!") end

  for i, v in ipairs(results) do v.value = yazilacakSayi end
  gg.setValues(results)
gg.clearResults()
  gg.alert("aynÄ± kit saÄŸ oka ardÄ±ndan sol oka tÄ±klayÄ±n ve arabayÄ± satÄ±n alÄ±n.")
  gg.toast("Coin deÄŸeri " .. fark .. " azaltÄ±ldÄ±.")
end

-- Para MenÃ¼
local sinirsizParaDurum = false
local paraDondurDurum = false

function paraMenu()
  local menu = gg.multiChoice({
    "SÄ±nÄ±rsÄ±z Para: " .. durumYaz(sinirsizParaDurum),
    "Para Dondur: " .. durumYaz(paraDondurDurum),
    "Geri"
  }, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")

  if menu == nil then return end

  if menu[1] then
    sinirsizParaDurum = not sinirsizParaDurum
    if sinirsizParaDurum then
      sinirsizParaAc()
    else
      sinirsizParaKapat()
    end
  end

  if menu[2] then
    paraDondurDurum = not paraDondurDurum
    if paraDondurDurum then
      paraDondurAc()
    else
      paraDondurKapat()
    end
  end

  if menu[3] then coinparaMenu() end
end

function durumYaz(durum)
  return durum and "AÃ‡IK" or "KAPALI"
end

function sinirsizParaAc()
  local base = gg.getRangesList('libil2cpp.so')[2].start
  local patch1 = {
    {address = base + 0x15234A0, value = '7E967699h', flags = 4}
  }
  gg.setValues(patch1)

  local patch2 = {
    {address = base + 0x2EA23C8, value = '528ED320h', flags = 4},
    {address = base + 0x2EA23C8 + 4, value = '72AFD2C0h', flags = 4},
    {address = base + 0x2EA23C8 + 8, value = '1E270000h', flags = 4},
    {address = base + 0x2EA23C8 + 12, value = 'D65F03C0h', flags = 4}
  }
  gg.setValues(patch2)
  gg.alert("Paraya tÄ±klayÄ±n ve sÄ±nÄ±rsÄ±z parayÄ± kapatÄ±n.")
end

function sinirsizParaKapat()
  local base = gg.getRangesList('libil2cpp.so')[2].start
  local patch = {
    {address = base + 0x2EA23C8, value = 'FC1D0FE8h', flags = 4},
    {address = base + 0x2EA23C8 + 4, value = 'A90157FEh', flags = 4},
    {address = base + 0x2EA23C8 + 8, value = 'A9024FF4h', flags = 4},
    {address = base + 0x2EA23C8 + 12, value = '90025355h', flags = 4}
  }
  gg.setValues(patch)
  gg.toast("SÄ±nÄ±rsÄ±z Para KapatÄ±ldÄ±")
end

function paraDondurAc()
  local base = gg.getRangesList('libil2cpp.so')[2].start
  local patch = {
    {address = base + 0x3258888, value = 'D2800000h', flags = 4},
    {address = base + 0x3258888 + 4, value = 'D65F03C0h', flags = 4}
  }
  gg.setValues(patch)
  gg.toast("Para Dondurma aÃ§Ä±k")
end

function paraDondurKapat()
  local base = gg.getRangesList('libil2cpp.so')[2].start
  local patch = {
    {address = base + 0x3258888, value = 'D10303FFh', flags = 4},
    {address = base + 0x3258888 + 4, value = '6D042BEBh', flags = 4}
  }
  gg.setValues(patch)
  gg.toast("Para Dondurma KapatÄ±ldÄ±")
end

-- Race Menu
elFrenHizliArabaAktif = false

function yarisMenu()
    local menu = gg.choice({
        "HÄ±z MenÃ¼",
        "Bug MenÃ¼",
        "El Fren HÄ±zlÄ± Araba [" .. (elFrenHizliArabaAktif and "AÃ§Ä±k" or "KapalÄ±") .. "]",
        "Geri"
    }, nil, "YouTube: @R&MGAME\nTelegram: @RMSTUDIO MAIN")

    if menu == nil then return end
    if menu == 1 then hizMenu() end
    if menu == 2 then bugMenu() end
    if menu == 3 then elFrenHizliAraba() end
    if menu == 4 then anaMenu() end
end

function elFrenHizliAraba()
    elFrenHizliArabaAktif = not elFrenHizliArabaAktif
    gg.setRanges(gg.REGION_ANONYMOUS)

    local yeniDeger = elFrenHizliArabaAktif and "-6800" or "6000"
    local arananDeger = elFrenHizliArabaAktif and "6000" or "-6800"
    local bilgiMesaj = elFrenHizliArabaAktif and "El Freni HÄ±zlÄ± Araba AÃ§Ä±ldÄ±" or "El Freni HÄ±zlÄ± Araba KapatÄ±ldÄ±"

    gg.searchNumber(arananDeger, gg.TYPE_DWORD)
    local sonuc = gg.getResults(10000)
    if #sonuc > 0 then
        for i, v in ipairs(sonuc) do
            v.value = tonumber(yeniDeger)
        end
        gg.setValues(sonuc)
    end
    gg.clearResults()

    if elFrenHizliArabaAktif then
        gg.alert("GÃ¶sterge 100'Ã¼ aÅŸtÄ±ÄŸÄ±nda park frenini Ã§ekmeyi unutmayÄ±n.")
    end

    gg.toast(bilgiMesaj)
end

local toggleValues = {}
local revertData = {}

for _, s in ipairs({0,1,2,3,5}) do
    toggleValues[s] = false
    revertData[s] = {}
end

function applyEdit(range, searchVal, editVal)
    gg.setRanges(range)
    gg.searchNumber(searchVal, gg.TYPE_FLOAT)
    local results = gg.getResults(1000)
    gg.editAll(editVal, gg.TYPE_FLOAT)
    gg.clearResults()
    return results
end

function revertEdits(seconds)
    local data = revertData[seconds]
    if data then
        for _, d in ipairs(data) do
            if d then gg.setValues(d) end
        end
        gg.toast(seconds .. " saniyelik iÅŸlem devre dÄ±ÅŸÄ±")
    end
end

function toggleValue(seconds)
    for s, aktif in pairs(toggleValues) do
        if s ~= seconds and aktif then
            toggleValues[s] = false
            revertEdits(s)
        end
    end

    toggleValues[seconds] = not toggleValues[seconds]

    if toggleValues[seconds] then
        gg.toast(seconds .. " saniye AÃ§Ä±ldÄ±")
        local r = {}
        r[1] = applyEdit(gg.REGION_ANONYMOUS, "2500", "-100000")

        if seconds == 5 then
            r[2] = applyEdit(gg.REGION_CODE_APP, "3.6", "30")
            r[3] = applyEdit(gg.REGION_CODE_APP, "10000000", "4E-4")
        elseif seconds == 3 then
            r[2] = applyEdit(gg.REGION_CODE_APP, "1.1", "3")
            r[3] = applyEdit(gg.REGION_CODE_APP, "3.6", "925")
            r[4] = applyEdit(gg.REGION_CODE_APP, "10000000", "4E-4")
        elseif seconds == 2 then
            r[2] = applyEdit(gg.REGION_CODE_APP, "1.1", "2.8")
            r[3] = applyEdit(gg.REGION_CODE_APP, "10000000", "8E-4")
        elseif seconds == 1 then
            r[2] = applyEdit(gg.REGION_CODE_APP, "1.1", "10")
            r[3] = applyEdit(gg.REGION_CODE_APP, "10000000", "3E-4")
        elseif seconds == 0 then
            r[2] = applyEdit(gg.REGION_CODE_APP, "1.1", "999")
            r[3] = applyEdit(gg.REGION_CODE_APP, "10000000", "3E-4")
        end

        revertData[seconds] = r
    else
        revertEdits(seconds)
    end
end

function hizMenu()
    local secim = gg.choice({
        "5 Saniye [" .. durumYaz(toggleValues[5]) .. "]",
        "3 Saniye [" .. durumYaz(toggleValues[3]) .. "]",
        "2 Saniye [" .. durumYaz(toggleValues[2]) .. "]",
        "1 Saniye [" .. durumYaz(toggleValues[1]) .. "]",
        "0 Saniye [" .. durumYaz(toggleValues[0]) .. "]",
        "Geri"
    }, nil, "YouTube: @R&MGAME\nTelegram: @RMSTUDIO MAIN")

    if secim == nil or secim == 6 then return end

    local saniyeler = {5,3,2,1,0}
    local secilen = saniyeler[secim]
    if secilen ~= nil then toggleValue(secilen) end
end

function durumYaz(d) return d and "AÃ§Ä±k" or "KapalÄ±" end

rakipKilitleAktif = false
yaristanCikAktif = false
sifirBitisAktif = false
sifirBitisAdresler = {}

function bugMenu()
    local labels = {
        "Rakibi Kilitle",
        "YarÄ±ÅŸtan Ã‡Ä±k",
        "00:00 BitiÅŸ",
        "Geri"
    }
    local kutular = {
        rakipKilitleAktif,
        yaristanCikAktif,
        sifirBitisAktif,
        false
    }

    local secim = gg.multiChoice(labels, kutular, "YouTube: @Cebrail_21.\nTelegram: @cebrail2")
    if secim == nil or secim[4] then return yarisMenu() end

    toggle(secim[1], "rakip", 0x31DFE80, {
        ac = {"000080D2h", "C0035FD6h"},
        kapat = {"F81D0FFEh", "A90157F6h"}
    })

    toggle(secim[2], "yaris", 0x31E3D7C, {
        ac = {"000080D2h", "C0035FD6h"},
        kapat = {"D10103FFh", "A9015FFEh"}
    })

    if secim[3] ~= sifirBitisAktif then
        sifirBitisAktif = secim[3]
        if sifirBitisAktif then sifirBitisAc() else sifirBitisKapat() end
    end
end

-- Genel AÃ§/Kapat Fonksiyonu
function toggle(durum, isim, offset, kodlar)
    local aktifDeger = _G[isim.."KilitleAktif"] or false
    if durum == aktifDeger then return end
    _G[isim.."KilitleAktif"] = durum
    local base = gg.getRangesList('libil2cpp.so')[2].start
    local values = {
        {address = base + offset,     value = durum and kodlar.ac[1] or kodlar.kapat[1], flags = 4},
        {address = base + offset + 4, value = durum and kodlar.ac[2] or kodlar.kapat[2], flags = 4}
    }
    gg.setValues(values)
    gg.toast(isim.." "..(durum and "aÃ§Ä±ldÄ±" or "kapatÄ±ldÄ±"))
end

-- 00:00 BitiÅŸ
function sifirBitisAc()
    degerarama("MultiDragRacingControll", "0x124", false, false, gg.TYPE_FLOAT)
    local t = gg.getResults(70)
    sifirBitisAdresler = {}
    for _, v in ipairs(t) do
        if v.flags == gg.TYPE_FLOAT then
            v.value = "0"
            v.freeze = true
            v.freezeType = gg.FREEZE_NORMAL
            table.insert(sifirBitisAdresler, v)
        end
    end
    gg.setValues(sifirBitisAdresler)
    gg.toast("SÃ¼re 00:00 yapÄ±ldÄ± ve donduruldu")
end

function sifirBitisKapat()
    for _, v in ipairs(sifirBitisAdresler) do
        v.freeze = false
    end
    gg.setValues(sifirBitisAdresler)
    sifirBitisAdresler = {}
    gg.toast("SÃ¼re dondurma kapatÄ±ldÄ±")
    gg.clearResults()
end

function basarilarMenu()
  local secim = gg.choice({
    "BaÅŸarÄ±lar 1",
    "BaÅŸarÄ±lar 2",
    "Geri"
  }, nil, "YouTube: @R&MGAME\nTelegram: @RMSTUDIO MAIN")

  if secim == 1 then basarilar1Menu()
  elseif secim == 2 then basarilar2Menu()
  elseif secim == 3 then anaMenu() end
end

function basarilar1Menu()
  local secim = gg.choice({
    "Park GÃ¶revi",
    "Taksi + Teslimat + Kargo",
    "Geri"
  }, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")

  if secim == 1 then parkGorevi()
  elseif secim == 2 then taksiTeslimatKargo()
  elseif secim == 3 then basarilarMenu() end
end

function parkGorevi()
  gg.alert("Seviyeler BÃ¶lÃ¼mÃ¼ne Gidin ve GG tÄ±kla")
  while not gg.isVisible() do end
  gg.setVisible(false)
  gg.setRanges(gg.REGION_CODE_APP)
  gg.searchNumber("0.1", 16)
  gg.getResults(500)
  gg.editAll("1E-40", 16)
  gg.toast("Park GÃ¶revi Aktif.")
  gg.clearResults()
  gg.alert("Seviye 1 baÅŸlat, Ã§oÄŸunu hÄ±zlÄ±ca atlayacak. BazÄ±larÄ±nÄ± manuel yapman gerekebilir.")
end

function taksiTeslimatKargo()
  local base = gg.getRangesList('libil2cpp.so')[2].start
  local patch = {
    {address = base + 0x3569074, value = '528BF520h'},
    {address = base + 0x3569078, value = '72AB0C60h'},
    {address = base + 0x356907C, value = '1E270000h'},
    {address = base + 0x3569080, value = 'D65F03C0h'}
  }
  for _, v in ipairs(patch) do v.flags = 4 end
  gg.setValues(patch)
  gg.toast("Aktif.")
  gg.alert("Taksi, teslimat ve kargo gÃ¶revlerinden birer tane tamamla.")
end

function basarilar2Menu()
  local adlar = {
    "YÄ±kama", "Duygular", "YakÄ±t", "Polis", "Lastik", "Tamirci",
    "YarÄ±ÅŸ", "HÄ±z", "BekÃ§i", "Yol KralÄ±", "Drift KralÄ±", "Offroad",
    "Drift UstasÄ±", "Maraton", "Yolcu", "Zaman", "Geri"
  }

  local kodlar = {
    {"FreeDriveDb", "0xDC"}, {"FreeDriveDb", "0xFC"}, {"FreeDriveDb", "0xCC"},
    {"FreeDriveDb", "0xAC"}, {"FreeDriveDb", "0xBC"}, {"FreeDriveDb", "0xEC"},
    {"FreeDriveDb", "0x9C"}, {"FreeDriveDb", "0x8C"}, {"FreeDriveDb", "0x7C"},
    {"Powertrain", "0x1A4"}, {"Powertrain", "0x1B8"}, {"Powertrain", "0x1CC"},
    {"Powertrain", "0x1E0"}, {"LatestMoving", "0xC4"}, {"LatestMoving", "0xD8"},
    {"AnalyticService", "0x20"}
  }

  local secim = gg.multiChoice(adlar, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")
  if not secim then return end

  for i = 1, #kodlar do
    if secim[i] then ortakFonksiyon(kodlar[i][1], kodlar[i][2], adlar[i]) end
  end
  if secim[17] then basarilarMenu() end
end

function ortakFonksiyon(tablo, offset, ad)
  degerarama(tablo, offset, false, false, 4)
  local results = gg.getResults(gg.getResultsCount())
  local degisenler = {}

  for i, v in ipairs(results) do
    local val = tostring(v.value)
    if #val == 10 and val:sub(1,1) == "1" then
      v.value = "999999"
      table.insert(degisenler, v)
    end
  end

  if #degisenler > 0 then
    gg.setValues(degisenler)
    gg.toast(ad .. " baÅŸarÄ±yla aktif edildi.")
  else
    gg.toast(ad .. " iÃ§in uygun deÄŸer bulunamadÄ±.")
  end

  gg.clearResults()
end

function kilitAcmaMenu()
  local menu = {
    "Evler Ãœcretsiz AÃ§",
    "Toyota Crown AÃ§",
    "Polis Siren AÃ§",
    "Oda Åžifresini Bul",
    "ID DeÄŸiÅŸtir",
    "Ãœcretli ArabalarÄ± AÃ§",
    "Geri"
  }

  local choice = gg.multiChoice(menu, nil, "YouTube: @R&MGAME.\nTelegram: RMSTUDIO MAIN")

  if not choice then
    gg.toast("MenÃ¼ kapatÄ±ldÄ±.")
    return
  end

  if choice[1] then evleriAc() end
  if choice[2] then toyotaAc() end
  if choice[3] then sirenAc() end
  if choice[4] then sifreBul() end
  if choice[5] then idDegistir() end
  if choice[6] then ucretliArabalarAc() end
  if choice[7] then anaMenu() end
end

function evleriAc()
  local C21 = gg.getRangesList("libil2cpp.so")[2].start
  local YT = {
    {address = C21 + 0x31EC2B8, value = "D2800000h", flags = 4},
    {address = C21 + 0x31EC2B8 + 4, value = "D65F03C0h", flags = 4}
  }
  gg.setValues(YT)
  gg.toast("Evler Ã¼cretsiz aÃ§Ä±ldÄ±!")
end

function toyotaAc()
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.searchNumber("3;0;218;-1:13", 4)
  gg.refineNumber(218, 4)
  gg.getResults(500)
  gg.editAll(0, 4)
  gg.clearResults()
  gg.toast("Toyota Crown aÃ§Ä±ldÄ±!")
end

function sirenAc()
  local C21 = gg.getRangesList("libil2cpp.so")[2].start
  local YT = {
    {address = C21 + 0x340A2D4, value = "D2800020h", flags = 4},
    {address = C21 + 0x340A2D4 + 4, value = "D65F03C0h", flags = 4}
  }
  gg.setValues(YT)
  gg.alert("TÃ¼m araÃ§larda polis sireni aÃ§Ä±ldÄ±.\n\nKalÄ±cÄ± olmasÄ± iÃ§in arabayÄ± yedek hesaba satÄ±n.")
  gg.toast("Polis Siren AÃ§Ä±ldÄ±")
end

function sifreBul()
  degerarama("RoomDataItem", "0x9C", false, false, 4)
  local results = gg.getResults(gg.getResultsCount())
  local valueList = {}
  for _, v in ipairs(results) do
    table.insert(valueList, tostring(v.value))
  end

  local choice = gg.choice(valueList, nil, "Oda ÅŸifresini tahmin et. Otomatik kopyalanÄ±r.")
  if choice then
    local selectedValue = valueList[choice]
    gg.copyText(selectedValue)
    gg.toast("KopyalandÄ±: " .. selectedValue)
    gg.clearResults()
  end
end

function idDegistir()
  local C21 = gg.getRangesList("libil2cpp.so")[2].start
  local YT = {
    {address = C21 + 0x36ECBE8, value = "D2800000h", flags = 4},
    {address = C21 + 0x36ECBE8 + 4, value = "D65F03C0h", flags = 4}
  }
  gg.setValues(YT)
  gg.alert("Hesaptan Ã§Ä±kÄ±ÅŸ yap ve tekrar giriÅŸ yap. Oyunu kapatma!")
  gg.toast("ID DeÄŸiÅŸtirme AÃ§Ä±ldÄ±")
end

function ucretliArabalarAc()
  local C21 = gg.getRangesList("libil2cpp.so")[2].start
  local aktif = {
    {address = C21 + 0x2EA20E0, value = "1286C000h", flags = 4},
    {address = C21 + 0x2EA20E0 + 4, value = "72A77340h", flags = 4},
    {address = C21 + 0x2EA20E0 + 8, value = "D65F03C0h", flags = 4}
  }
  gg.setValues(aktif)
  gg.alert("Ä°stediÄŸiniz arabayÄ± satÄ±n alÄ±n, ardÄ±ndan GG'ye tÄ±klayÄ±n.")
  gg.toast("AÃ§Ä±ldÄ±")

  while not gg.isVisible() do end
  gg.setVisible(false)

  local eski = {
    {address = C21 + 0x2EA20E0, value = "F81D0FFEh", flags = 4},
    {address = C21 + 0x2EA20E0 + 4, value = "A90157F6h", flags = 4},
    {address = C21 + 0x2EA20E0 + 8, value = "A9024FF4h", flags = 4}
  }
  gg.setValues(eski)
  gg.toast("Ãœcretli Arabalar AÃ§Ä±ldÄ±")
end

function modifiyeMenu()
    local menu = gg.choice({
        "Lastikler %100",
        "Lastikler %0",
        "HasarsÄ±z Araba",
        "HasarsÄ±z Motor",
        "Tampon SÃ¶k",
        "Geri"
    }, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")

    if menu == nil then return end
    if menu == 1 then lastik100() end
    if menu == 2 then lastik0() end
    if menu == 3 then hasarsizAraba() end
    if menu == 4 then hasarsizMotor() end
    if menu == 5 then tamponSok() end
    if menu == 6 then anaMenu() end
end

function lastik100()
    gg.alert("Lastikler %100 yapmak iÃ§in odada olmanÄ±z ÅŸat!")
    degerarama("Wheel", "0x23C", false, false, 16)
    gg.getResults(1000)
    gg.editAll(99999, 16)
    gg.clearResults()
    gg.toast("Lastikler %100 yapÄ±ldÄ±!")
end

function lastik0()
    gg.alert("Lastikler %0 yapmak iÃ§in odada olmanÄ±z ÅŸat!")
    degerarama("Wheel", "0x23C", false, false, 16)
    gg.getResults(1000)
    gg.editAll(0, 16)
    gg.clearResults()
    gg.toast("Lastikler %0 yapÄ±ldÄ±!")
end

function hasarsizAraba()
    local C21 = gg.getRangesList('libil2cpp.so')[2].start
    local YT = {}
    YT[1] = {address = C21 + 0x3610724, value = 'D2800000h', flags = 4}
    YT[2] = {address = C21 + 0x3610724 + 4, value = 'D65F03C0h', flags = 4}
    gg.setValues(YT)
    gg.toast("Araba hasarsÄ±z hale getirildi!")
end

function hasarsizMotor()
    local C21 = gg.getRangesList('libil2cpp.so')[2].start
    local YT = {}
    YT[1] = {address = C21 + 0x3358728, value = 'D2800000h', flags = 4}
    YT[2] = {address = C21 + 0x3358728 + 4, value = 'D65F03C0h', flags = 4}
    gg.setValues(YT)
    gg.toast("Motor hasarsÄ±z hale getirildi!")
end

function tamponSok()
    gg.alert("1. Tamponu satÄ±n alÄ±n ve GG'ye tÄ±klayÄ±n")

    while not gg.isVisible() do end
    gg.setVisible(false)

    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("0", gg.TYPE_DWORD)
    gg.alert("2. Tamponu satÄ±n alÄ±n")
    gg.sleep(5000)

    gg.refineNumber("1", gg.TYPE_DWORD)
    gg.alert("3. Tamponu satÄ±n alÄ±n")
    gg.sleep(5000)

    gg.refineNumber("2", gg.TYPE_DWORD)
    gg.alert("4. Tamponu satÄ±n alÄ±n")
    gg.sleep(5000)

    gg.refineNumber("3", gg.TYPE_DWORD)
    gg.getResults(200)
    gg.editAll("-1", gg.TYPE_DWORD)

    gg.alert("BaÅŸka bir araca gidin ve sonra aynÄ± arabaya tekrar dÃ¶nÃ¼n.")
    gg.toast("Tampon sÃ¶kÃ¼ldÃ¼")
    gg.clearResults()
end


function kromMenu()
    local submenu = gg.choice({
        "Krom = Araba + Jant",
        "Krom = Far + Ã‡akar + Kaliper + Cam",
        "Geri"
    }, nil, "YouTube: @R&MGAME\nTelegram: @RMSTUDIO MAIN")

    if submenu == nil then return end
    if submenu == 1 then kromArabaJant() 
    elseif submenu == 2 then kromFarCakarKaliperCam() 
    elseif submenu == 3 then anaMenu() 
    end
end

function kromAramaYap()
    for i = 1, 3 do
        gg.alert("Rengi yukarÄ± Ã§ekin.")
        gg.sleep(2000)
        gg.searchNumber(1, gg.TYPE_FLOAT)
        
        gg.alert("Rengi aÅŸaÄŸÄ± Ã§ekin.")
        gg.sleep(2000)
        gg.searchNumber(0, gg.TYPE_FLOAT)
    end
end

function kromArabaJant()
    gg.alert("Araba veya jant rengine gidin\nAYNASAL seÃ§in ve GG'ye tÄ±klayÄ±n")
    while not gg.isVisible() do end
    gg.setVisible(false)
    gg.setRanges(gg.REGION_ANONYMOUS)

    kromAramaYap()

    local results = gg.getResults(999)
    if #results > 0 then
        gg.editAll(4, gg.TYPE_FLOAT)
        gg.toast("Krom renk aktif!")
    else
        gg.alert("HiÃ§bir deÄŸer bulunamadÄ±!")
    end
    gg.clearResults()
end

function kromFarCakarKaliperCam()
    local renkler = {"Mavi", "YeÅŸil", "Beyaz", "KÄ±rmÄ±zÄ±", "SarÄ±", "Turuncu", "Lacivert", "Mor", "Pembe"}
    local renkKodlari = {
        ["Mavi"] = "#00FFFF", ["YeÅŸil"] = "#00FF00", ["Beyaz"] = "#FFFFFF",
        ["KÄ±rmÄ±zÄ±"] = "#FF0000", ["SarÄ±"] = "#FFFF00", ["Turuncu"] = "#FF9900",
        ["Lacivert"] = "#0000FF", ["Mor"] = "#9900FF", ["Pembe"] = "#FF00FF"
    }

    local secim = gg.choice(renkler, nil, "Krom Renk SeÃ§imi")
    if not secim then return end

    local renk = renkler[secim]
    local kod = renkKodlari[renk]

    gg.toast("SeÃ§ilen Renk Kodu: " .. kod)
    gg.copyText(kod)
    gg.alert("Kod kopyalandÄ±!\n\nRegi tam yukarÄ± Ã§ekin Renk altÄ±nda 'kod yeri' kÄ±smÄ±na yapÄ±ÅŸtÄ±rÄ±n, 'Tamam' deyin ve GG'yi aÃ§Ä±n.")

    while not gg.isVisible() do end
    gg.setVisible(false)
    gg.setRanges(gg.REGION_ANONYMOUS)

    kromAramaYap()

    gg.alert("Renk kodu yerine tÄ±klayÄ±n, 'Tamam' deyin ve GG'yi aÃ§Ä±n.")
    while not gg.isVisible() do end
    gg.setVisible(false)

    gg.getResults(999)
    gg.editAll(4, gg.TYPE_FLOAT)
    gg.toast("Krom renk aktif!")
    gg.clearResults()
end

function ufoMenu()
    local submenu = gg.choice({
        "UFO 70",
        "UFO 90",
        "UFO 120",
        "Ã–zel UFO",
        "Geri"
    }, nil, "YouTube: @R&MGAME.\nTelegram: @RMSTUDIO MAIN")

    if submenu == 1 then
        ortakSuspansiyon(70)
    elseif submenu == 2 then
        ortakSuspansiyon(90)
    elseif submenu == 3 then
        ortakSuspansiyon(120)
    elseif submenu == 4 then
        ozelUFO()
    elseif submenu == 5 or submenu == nil then
        anaMenu() 
    end
end

function ortakSuspansiyon(deger)
    gg.alert("ArabanÄ±n sÃ¼spansiyon kÄ±smÄ±nda kamber ve aks uzunluÄŸu her ikisinin Ã¶n ve arka Ã§ubuÄŸunu tam saÄŸa itir ve kaydet. Geri gel ve GG'ye tÄ±kla.")
    while not gg.isVisible() do end
    gg.setVisible(false)
    gg.setRanges(gg.REGION_ANONYMOUS)

    gg.searchNumber("-10", gg.TYPE_FLOAT)
    gg.refineNumber("-10", gg.TYPE_FLOAT)
    local results = gg.getResults(1000)
    gg.editAll("-" .. deger, gg.TYPE_FLOAT)
    gg.clearResults()

    gg.searchNumber("0.30", gg.TYPE_FLOAT)
    gg.refineNumber("0.30", gg.TYPE_FLOAT)
    gg.getResults(250)
    gg.editAll("3", gg.TYPE_FLOAT)
    gg.clearResults()

    gg.alert("SÃ¼spansiyon kÄ±smÄ±na git, 'bitti' tÄ±kla ve geri gel.")
    gg.toast("Ä°ÅŸlem tamamlandÄ±.")
end

function ozelUFO()
    gg.alert("ArabanÄ±n sÃ¼spansiyon kÄ±smÄ±nda kamber ve aks uzunluÄŸu her ikisinin Ã¶n ve arka Ã§ubuÄŸunu tam saÄŸa itir ve kaydet. Geri gel ve GG'ye tÄ±kla.")
    while not gg.isVisible() do end
    gg.setVisible(false)

    local input = gg.prompt({"LÃ¼tfen bir deÄŸer girin (Ã¶rnek: 100)"}, nil, {"number"})
    if not input or not tonumber(input[1]) then
        gg.alert("GeÃ§ersiz veya boÅŸ deÄŸer girildi.")
        return
    end

    local deger = tonumber(input[1])
    ortakSuspansiyon(deger)
end

function govdeMenu()
local submenu = gg.choice({
        "Ä°stediÄŸiniz GÃ¶vde Kitini Ekle",
        "Ä°stediÄŸiniz GÃ¶vde Kitinin Kodunu Bul",
        "Geri"
    }, nil, "ð˜ð¨ð®ð“ð®ð›ðž: @ð‚_ðŸðŸ\nð“ðžð¥ðžð ð«ðšð¦: @ðœðžð›ð«ðšð¢ð¥ðŸ")
    
    if submenu == 1 then ekgovde() end
    if submenu == 2 then degerAra() end
    if submenu == 3 then anaMenu() end
end

function ekgovde()
gg.alert ("eklemek istediÄŸin parÃ§ayÄ± seÃ§in ve GG tikla\neÄŸer kodlarÄ± Ã¶ÄŸrenmek istiyorsanÄ±z\nÄ°stediÄŸiniz GÃ¶vde Kitinin Kodunu Bul\nseÃ§eneÄŸini kullanarak kodlarÄ± Ã¶ÄŸrenebilirsiniz")
while true do
if gg.isVisible() then
break
else
end end gg.setVisible(false)
c=gg.prompt({" \n istediÄŸiniz kodu yazÄ±n\nÃ–RNEK: port bagaj: 6","iptal"},nil,{"number","checkbox"}) if not c then return end if c == nil then cebrail() end gg["clearResults"]() gg["setVisible"](false) if c[2] then return gg["setVisible"](true) end
degerarama("ExteriorTuning", "0xF0", false, false, 4)

local results = gg.getResults(gg.getResultsCount())
local filtered = {}

for i, v in ipairs(results) do
  local value = v.value
  if value > 0 and value <= 999 then
    table.insert(filtered, v)
  end
end

if #filtered == 0 then
  gg.alert("1, 2 veya 3 basamaklÄ± pozitif sonuÃ§ bulunamadÄ±.")
else
  for i, v in ipairs(filtered) do
    v.value = c[1]
    v.freeze = false
  end

  gg.setValues(filtered)
  gg.alert(" gÃ¶vde kiti satÄ±n alÄ±n")
  gg.clearResults()
end
end

function degerAra()
gg.alert ("kodunu almak istediÄŸin parÃ§ayÄ± seÃ§in ve GG tikla")
while true do
if gg.isVisible() then
break
else
end end gg.setVisible(false)
degerarama("ExteriorTuning", "0xF0", false, false, 4)

local results = gg.getResults(50)
local filteredValues = {}

for i, v in ipairs(results) do
    local valueStr = tostring(v.value)
    local valueNum = tonumber(v.value) 
    if valueNum and valueNum >= 1 and valueNum <= 999 and valueStr:sub(1, 1) ~= "0" then
        table.insert(filteredValues, valueNum)
    end
end
if #filteredValues > 0 then
    local resultText = table.concat(filteredValues, "\n")
    gg.copyText(resultText)
    gg.alert("kod:\n" .. resultText)
    gg.clearResults()
    gg.alert("kod kopyalandÄ±")
    gg.toast("kod kopyalandÄ±")
else
    gg.alert("Uygun deÄŸer bulunamadÄ±.")
end
end

function hp()
  local menu = gg.choice({
        "HP AyarlanmÄ±ÅŸ MenÃ¼",
        "HP Ã–zel",
        "ÅžanzÄ±man MenÃ¼",
        "Geri"
    }, nil, "ð˜ð¨ð®ð“ð®ð›ðž: @ð‚_ðŸðŸ\nð“ðžð¥ðžð ð«ðšð¦: @ðœðžð›ð«ðšð¢ð¥ðŸ")

    if menu == 1 then hpMenu() end
    if menu == 2 then hpOzel() end
    if menu == 3 then sanzimanMenu() end
    if menu == 4 then anaMenu() end
end

function hpMenu()
    local menu = gg.choice({
        "HP 99",
        "HP 300",
        "HP 324",
        "HP 400",
        "HP 414",
        "HP 925",
        "HP 1695",
        "HP 1695 (HÄ±zlÄ±)",
        "Geri"
    }, nil, "ð˜ð¨ð®ð“ð®ð›ðž: @ð‚_ðŸðŸ\nð“ðžð¥ðžð ð«ðšð¦: @ðœðžð›ð«ðšð¢ð¥ðŸ")

    if menu == 1 then hpAyarla("99", "2300", "8000", "7789") end
    if menu == 2 then hpAyarla("300", "3000", "8000", "7789") end
    if menu == 3 then hpAyarla("324", "2300", "8000", "7789") end
    if menu == 4 then hpAyarla("400", "2300", "8000", "7789") end
    if menu == 5 then hpAyarla("414", "2300", "8000", "7789") end
    if menu == 6 then hpAyarla("925", "2300", "8000", "7789") end
    if menu == 7 then hpAyarla("1695", "2254", "7000", "3500") end
    if menu == 8 then hpAyarla("1695", "2254", "1000", "1001") end
    if menu == 9 then hp() end
end

function hpAyarla(hp, deger2, deger3, deger4)
    gg.alert("L4 2.0 satÄ±n alÄ±n ve GG'ye tÄ±klayÄ±n")
    while not gg.isVisible() do gg.sleep(100) end
    gg.setVisible(false)
    gg.setRanges(gg.REGION_ANONYMOUS)

    local degerler = {
        {"150", hp},
        {"220", deger2},
        {"5900", deger3},
        {"4100", deger4}
    }

    for _, v in ipairs(degerler) do
        gg.searchNumber(v[1], gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
        local sonuc = gg.getResults(1000)
        gg.editAll(v[2], gg.TYPE_FLOAT)
        gg.clearResults()
    end

    gg.alert("UYGULA butonuna tÄ±klayÄ±n")
end

function hpOzel()
    local menu = gg.choice({
        "L4 2.0",
        "L4 2.5",
        "V6 3.0",
        "V6 3.5",
        "V8 4.0",
        "V8 4.5",
        "V10 5.0",
        "V10 6.0",
        "V12 6.0",
        "V16 8.0",
        "Geri"
    }, nil, "YouTube: @C_21\nTelegram: @cebrail2")

    if menu == 1 then L4_2_0() end
    if menu == 2 then L4_2_5() end
    if menu == 3 then V6_3_0() end
    if menu == 4 then V6_3_5() end
    if menu == 5 then V8_4_0() end
    if menu == 6 then V8_4_5() end
    if menu == 7 then V10_5_0() end
    if menu == 8 then V10_6_0() end
    if menu == 9 then V12_6_0() end
    if menu == 10 then V16_8_0() end
    if menu == 11 then hp() end
end

function bekle()
    while true do
        if gg.isVisible(true) then
            gg.setVisible(false)
            break
        end
        gg.sleep(100)
    end
end

function aramaVeDegistir(aranan, yeniDeger)
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber(aranan, gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    local sonuc = gg.getResults(1000)
    if #sonuc > 0 then
        gg.editAll(yeniDeger, gg.TYPE_FLOAT)
        gg.toast("DeÄŸer deÄŸiÅŸtirildi: " .. aranan .. " â†? " .. yeniDeger)
    else
        gg.toast("DeÄŸer bulunamadÄ±: " .. aranan)
    end
    gg.clearResults()
end

function surumIsle(hatirlatma, hp, tork, icHp, icTork)
    gg.alert(hatirlatma)
    bekle()

    local girdi = gg.prompt(
        {"AraÃ§ HP", "AraÃ§ Tork", "Ä°Ã§ HP", "Ä°Ã§ Tork", "MenÃ¼ye Geri DÃ¶n"},
        nil,
        {"number", "number", "number", "number", "checkbox"}
    )

    if not girdi then return end
    if girdi[5] then return gg.setVisible(true) end

    aramaVeDegistir(hp, girdi[1])
    aramaVeDegistir(tork, girdi[2])
    aramaVeDegistir(icHp, girdi[3])
    aramaVeDegistir(icTork, girdi[4])

    gg.alert("UYGULA'ya tÄ±klayÄ±n")
end

function L4_2_0() surumIsle("L4 2.0 satÄ±n al ve GG'ye tÄ±kla", "150", "220", "5900", "4100") end
function L4_2_5() surumIsle("L4 2.5 satÄ±n al ve GG'ye tÄ±kla", "90", "300", "5900", "4100") end
function V6_3_0() surumIsle("V6 3.0 satÄ±n al ve GG'ye tÄ±kla", "240", "310", "6800", "4500") end
function V6_3_5() surumIsle("V6 3.5 satÄ±n al ve GG'ye tÄ±kla", "280", "350", "6300", "4500") end
function V8_4_0() surumIsle("V8 4.0 satÄ±n al ve GG'ye tÄ±kla", "360", "500", "6300", "3400") end
function V8_4_5() surumIsle("V8 4.5 satÄ±n al ve GG'ye tÄ±kla", "415", "430", "7000", "4000") end
function V10_5_0() surumIsle("V10 5.0 satÄ±n al ve GG'ye tÄ±kla", "500", "620", "7000", "5600") end
function V10_6_0() surumIsle("V10 6.0 satÄ±n al ve GG'ye tÄ±kla", "580", "680", "7000", "5000") end
function V12_6_0() surumIsle("V12 6.0 satÄ±n al ve GG'ye tÄ±kla", "612", "1000", "7000", "3500") end
function V16_8_0() surumIsle("V16 8.0 satÄ±n al ve GG'ye tÄ±kla", "1120", "1250", "7000", "3500") end




function sanzimanMenu()
    local menu = gg.choice({
        "ÅžanzÄ±man 1E-20",
        "ÅžanzÄ±man 1E-30",
        "Ã–zel ÅžanzÄ±man",
        "Geri"
    }, nil, "YouTube: @R&MGAME\nTelegram: @RMSTUDIO MAIN")

    if menu == 1 then sanziman1E20() end
    if menu == 2 then sanziman1E30() end
    if menu == 3 then sanzimanOzel() end
    if menu == 4 then hp() end
end

function sanziman1E20()
   YouTube = gg.getRangesList('libil2cpp.so')[2].start
    local baseAddress = YouTube + 0x152348C
    setvalue(baseAddress + 0x00, 16, 1E-20)
    gg.alert("ÅžanzÄ±man 1E-20 ayarlandÄ±!\nÅžanzÄ±man satÄ±n al")
end

function sanziman1E30()
    YouTube = gg.getRangesList('libil2cpp.so')[2].start
    local baseAddress = YouTube + 0x152348C
    setvalue(baseAddress + 0x00, 16, 1E-30)
    gg.alert("ÅžanzÄ±man 1E-30 ayarlandÄ±!\nÅžanzÄ±man satÄ±n al")
end

function sanzimanOzel()
    local input = gg.prompt({"ÅžanzÄ±man Girin:"}, {""}, {"number"})  
if input == nil then  
    gg.toast("Ä°ÅŸlem iptal edildi!")  
    return  
end  

    YouTube = gg.getRangesList('libil2cpp.so')[2].start
    local baseAddress = YouTube + 0x152348C
    setvalue(baseAddress + 0x00, 16, input[1])

gg.toast("ÅžanzÄ±man baÅŸarÄ±yla\nÅžanzÄ±man satÄ±n al\n deÄŸiÅŸtirildi: " .. input[1])
end




function degerarama(sinif_adi, ofset, zorla, bit32_mi, deger_tipi)
    girdi_bilgileri = {}
    girdi_bilgileri[1] = sinif_adi
    girdi_bilgileri[2] = ofset
    girdi_bilgileri[3] = zorla
    girdi_bilgileri[4] = bit32_mi
    girdi_tipi = deger_tipi
    baslat()
end

function dongu_kontrol()
    if kullanici_modu == 1 then
        arayuz_goster()
    elseif hata_kodu == 3 then
        os.exit()
    end
end

function sonuc_kontrol(mesaj)
    if hata_kodu == 1 then
        ikinci_bulunamadi(mesaj)
    elseif hata_kodu == 2 then
        ucuncu_bulunamadi(mesaj)
    elseif hata_kodu == 3 then
        dorduncu_bulunamadi(mesaj)
    else
        ilk_bulunamadi(mesaj)
    end
end

function ilk_bulunamadi(mesaj)
    if sonuc_sayisi == 0 then
        gg.clearResults()
        gg.clearList()
        hata1 = mesaj
        hata_kodu = 1
        ikinci_baslat()
    end
end

function kullanici_girdisi_al()
::tekrar::
gg.clearResults()
if kullanici_modu == 1 then
    if girdi_bilgileri == nil then
        varsayilan1 = ""
        varsayilan2 = ""
        varsayilan3 = false
        varsayilan4 = false
    else
        varsayilan1 = girdi_bilgileri[1]
        varsayilan2 = girdi_bilgileri[2]
        varsayilan3 = girdi_bilgileri[3]
        varsayilan4 = girdi_bilgileri[4]
    end
    girdi_bilgileri = gg.prompt(
        {"SÄ±nÄ±f AdÄ±:", "Ofset:", "Daha Zorla -- (doÄŸruluÄŸu azaltÄ±r)", "32 bit iÃ§in dene"},
        {varsayilan1, varsayilan2, varsayilan3, varsayilan4},
        {"text", "text", "checkbox", "checkbox"}
    )
    if girdi_bilgileri ~= nil then
        if (girdi_bilgileri[1] == "") or (girdi_bilgileri[2] == "") then
            goto tekrar
        end
    else
        goto tekrar
    end
    girdi_tipi = gg.choice({"1. Bayt / Boolean", "2. Dword / 32 bit Tam sayÄ±", "3. Qword / 64 bit Tam sayÄ±", "4. Float", "5. Double"})
    if girdi_tipi == 1 then
        girdi_tipi = gg.TYPE_BYTE
    elseif girdi_tipi == 2 then
        girdi_tipi = gg.TYPE_DWORD
    elseif girdi_tipi == 3 then
        girdi_tipi = gg.TYPE_QWORD
    elseif girdi_tipi == 4 then
        girdi_tipi = gg.TYPE_FLOAT
    elseif girdi_tipi == 5 then
        girdi_tipi = gg.TYPE_DOUBLE
    end
    if girdi_tipi ~= gg.TYPE_BYTE then
        if (girdi_bilgileri[2] % 4) ~= 0 then
            goto tekrar
        end
    end
end
hata_kodu = 0
end

function O_ilk_aramasi()
    gg.setVisible(false)
    kullanici_girdisi = ":" .. girdi_bilgileri[1]
    if girdi_bilgileri[3] then
        ofset = 25
    else
        ofset = 0
    end
end

function O_detayli_arama()
    if hata_kodu > 1 then
        gg.setRanges(gg.REGION_C_ALLOC)
    else
        gg.setRanges(gg.REGION_OTHER)
    end
    gg.searchNumber(kullanici_girdisi, gg.TYPE_BYTE)
    sonuc_sayisi = gg.getResultsCount()
    if sonuc_sayisi == 0 then
        sonuc_kontrol("O_detayli_arama")
        return 0
    end
    aranan = gg.getResults(1)
    gg.refineNumber(aranan[1].value, gg.TYPE_BYTE)
    sonuc_sayisi = gg.getResultsCount()
    if sonuc_sayisi == 0 then
        sonuc_kontrol("O_detayli_arama")
        return 0
    end
    degerler = gg.getResults(sonuc_sayisi)
    gg.addListItems(degerler)
end

function CA_pointer_arama()
    gg.clearResults()
    gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_OTHER)
    gg.loadResults(gg.getListItems())
    gg.searchPointer(ofset)
    sonuc_sayisi = gg.getResultsCount()
    if sonuc_sayisi == 0 then
        sonuc_kontrol("CA_pointer_arama")
        return 0
    end
    sonuc = gg.getResults(sonuc_sayisi)
    gg.clearList()
    gg.addListItems(sonuc)
end

function CA_ofset_uygula()
    if girdi_bilgileri[4] then
        ofset_uygula = 0xfffffffffffffff8
    else
        ofset_uygula = 0xfffffffffffffff0
    end
    yer_degistir = false
    liste = gg.getListItems()
    if not yer_degistir then gg.removeListItems(liste) end
    for i, v in ipairs(liste) do
        v.address = v.address + ofset_uygula
        if yer_degistir then v.name = v.name .. " #2" end
    end
    gg.addListItems(liste)
end

function Q_dogrula_duzelt()
    gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_OTHER)
    gg.loadResults(gg.getListItems())
    gg.clearList()
    sonuc_sayisi = gg.getResultsCount()
    if sonuc_sayisi == 0 then
        sonuc_kontrol("Q_dogrula_duzelt")
        return 0
    end
    liste = gg.getResults(1000)
    gg.clearResults()
    i, c = 1, 1
    yeni = {}
    while (i - 1) < sonuc_sayisi do
        liste[i].address = liste[i].address + 0xb400000000000000
        gg.searchNumber(liste[i].address, gg.TYPE_QWORD)
        adet = gg.getResultsCount()
        if 0 < adet then
            sonuc = gg.getResults(adet)
            for n = 1, adet do
                yeni[c] = {}
                yeni[c].address = sonuc[n].address
                yeni[c].flags = 32
                c = c + 1
            end
        end
        gg.clearResults()
        i = i + 1
    end
    gg.addListItems(yeni)
end

function A_deger_al()
    gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_OTHER)
    gg.loadResults(gg.getListItems())
    gg.clearList()
    gg.searchPointer(ofset)
    sonuc_sayisi = gg.getResultsCount()
    if sonuc_sayisi == 0 then
        sonuc_kontrol("A_deger_al")
        return 0
    end
    bulunan = gg.getResults(sonuc_sayisi)
    gg.addListItems(bulunan)
end

function A_kesinlik_arttir()
    gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_OTHER)
    gg.loadResults(gg.getListItems())
    gg.clearList()
    gg.searchPointer(ofset)
    sonuc_sayisi = gg.getResultsCount()
    if sonuc_sayisi == 0 then
        sonuc_kontrol("A_kesinlik_arttir")
        return 0
    end
    liste = gg.getResults(sonuc_sayisi)
    yeni_liste = {}
    for i = 1, sonuc_sayisi do
        yeni_liste[i] = {address = liste[i].value, flags = 32}
    end
    gg.addListItems(yeni_liste)
end

function A_ofset_uygula()
    yerel_kayit = gg.getListItems()
    for i, v in ipairs(yerel_kayit) do
        v.address = v.address + girdi_bilgileri[2]
        v.flags = girdi_tipi
    end
    gg.clearResults()
    gg.clearList()
    gg.loadResults(yerel_kayit)
    sonuc_sayisi = gg.getResultsCount()
    if sonuc_sayisi == 0 then
        sonuc_kontrol("A_ofset_uygula")
        return 0
    end
end

function baslat()
    kullanici_girdisi_al()
    O_ilk_aramasi()
    O_detayli_arama()
    if hata_kodu > 0 then return 0 end
    CA_pointer_arama()
    if hata_kodu > 0 then return 0 end
    CA_ofset_uygula()
    if hata_kodu > 0 then return 0 end
    A_deger_al()
    if hata_kodu > 0 then return 0 end
    if ofset == 0 then A_kesinlik_arttir() end
    if hata_kodu > 0 then return 0 end
    A_ofset_uygula()
    if hata_kodu > 0 then return 0 end
    dongu_kontrol()
end


while true do
  if gg.isVisible(true) then
    gg.setVisible(false)
    anaMenu()
  end
end
