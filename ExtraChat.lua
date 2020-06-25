script_name("ExtraChat")
script_author("TrenLok")
script_description("Display messages by key words in the extra chat")

-- libs
require 'lib.moonloader'
require 'lib.sampfuncs'
local imgui = require 'imgui'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
-- libs

-- global variables
local sW, sH = getScreenResolution()
local configName = 'config.ini'
local keywordsFile = 'moonloader/config/ExtraChat/keywords.txt'
local keywordsMessages = {}
local keywords = {}

encoding.default = 'CP1251'
u8 = encoding.UTF8
-- global variables

-- config
mIni = inicfg.load({
    Main = {
        PosX = sW/2,
        PosY = sH/2,
        maxMessage = 10,
    },
    Font = {
		font = 'Arial',
		fontSize = 10,
		fontStyleBold = false,
		fontStyleItalic = false,
		fontStyleStroke = false,
		fontStyleShadow = false,
	}
}, string.format('moonloader/config/ExtraChat/%s', configName))
-- config

-- check directory and config
if not doesDirectoryExist(getWorkingDirectory().."\\config\\ExtraChat") then
    createDirectory(getWorkingDirectory().."\\config\\ExtraChat")
end
local status = inicfg.load(mIni, string.format('ExtraChat/%s', configName))
if not doesFileExist(string.format('moonloader/config/ExtraChat/%s', configName)) then
    inicfg.save(mIni, string.format('ExtraChat/%s', configName))
end
-- check directory and config

-- imgui variable
local main_window_state = imgui.ImBool(false)
local iPosX = imgui.ImInt(mIni.Main.PosX)
local iPosY = imgui.ImInt(mIni.Main.PosY)
local iMaxMessage = imgui.ImInt(mIni.Main.maxMessage)
local iFontSize = imgui.ImInt(mIni.Font.fontSize)
local iFont = imgui.ImBuffer(tostring(mIni.Font.font), 30)
local iFontStyleBold = imgui.ImBool(mIni.Font.fontStyleBold)
local iFontStyleItalic = imgui.ImBool(mIni.Font.fontStyleItalic)
local iFontStyleStroke = imgui.ImBool(mIni.Font.fontStyleStroke)
local iFontStyleShadow = imgui.ImBool(mIni.Font.fontStyleShadow)
-- imgui variable

-- imgui
function imgui.OnDrawFrame()
    if main_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(500, 480), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(
            imgui.ImVec2(sW/2, sH/2), imgui.Cond.FirstUseEver,
            imgui.ImVec2(0.5, 0.5)
        )
        imgui.LockPlayer = true
        imgui.Begin(
            'ExtraChat Settings',
            main_window_state,
            imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize
        )
        if imgui.CollapsingHeader(u8'Íàñòðîéêè') then
            imgui.Text(u8'Îñíîâíûå íàñòðîéêè')
            imgui.PushItemWidth(180)
            imgui.InputInt(u8'Ïîçèöèÿ ïî X', iPosX)
            imgui.InputInt(u8'Ïîçèöèÿ ïî Y', iPosY)
            imgui.InputInt(u8'Ìàêñèìàëüíîå êîëè÷åñòâî ñòðîê', iMaxMessage)
            imgui.NewLine()
            imgui.Text(u8'Íàñòðîéêè øðèôòà')
            imgui.InputInt(u8'Ðàçìåð øðèôòà', iFontSize)
            imgui.InputText(u8'Øðèôò', iFont)
            imgui.Checkbox(u8'Ïîëóæèðíûé', iFontStyleBold)
            imgui.Checkbox(u8'Êóðñèâ', iFontStyleItalic)
            imgui.Checkbox(u8'Êîíòóð', iFontStyleStroke)
            imgui.Checkbox(u8'Òåíü', iFontStyleShadow)
            imgui.NewLine()
        end
        if imgui.CollapsingHeader(u8'Ñïèñîê ñëîâ') then
            imgui.Text(u8'Ñïèñîê çàãðóæåííûõ ñëîâ:')
            for index, data in ipairs(keywords) do
                imgui.Text(index..":".." "..u8(data))
            end
            if #keywords == 0 then
                imgui.Text(u8"Ñïèñîê ñëîâ ïóñò")
            end
            imgui.NewLine()
        end
        if imgui.CollapsingHeader(u8'Êîìàíäû') then
            imgui.Text(u8'Ñïèñîê êîìàíä:')
            imgui.NewLine()
            imgui.Text(u8'/clearechat - Î÷èñòèòü ExtraChat')
            imgui.Text(u8'/addkeyword - Äîáàâèòü ñëîâî â ñïèñîê')
            imgui.Text(u8'/removekeyword - Óäàëèòü ñëîâî èç ñïèñîêà')
            imgui.Text(u8'/reloadwords - Ïåðåçàãðóçèòü ñïèñîê ñëîâ')
            imgui.Text(u8'/keywordslist - Ïîñìîòðåòü âñå ñëîâà èç ñïèñêà')
            imgui.Text(u8'/extrachat - Íàñòðîéêà ExtraChat')
        end
        imgui.NewLine()
        if imgui.Button(u8'Ñîõðàíèòü íàñòðîéêè') then
            printStringNow('Settinges saved!', 1000)
            sampAddChatMessage('Save!', -1)
            mIni.Main.PosX = iPosX.v
            mIni.Main.PosY = iPosY.v
            mIni.Main.maxMessage = iMaxMessage.v
            mIni.Font.fontSize = iFontSize.v
            mIni.Font.font = iFont.v
            mIni.Font.fontStyleBold = iFontStyleBold.v
            mIni.Font.fontStyleItalic = iFontStyleItalic.v
            mIni.Font.fontStyleStroke = iFontStyleStroke.v
            mIni.Font.fontStyleShadow = iFontStyleShadow.v
            messageFont = renderCreateFont(
                iFont.v,
                iFontSize.v,
                getFontStyle(
                    iFontStyleBold.v,
                    iFontStyleItalic.v,
                    iFontStyleStroke.v,
                    iFontStyleShadow.v)
            )
            inicfg.save(mIni, string.format('ExtraChat/%s', configName))
        end
        imgui.End()
    end
end
-- imgui

function sampev.onServerMessage(color, message)
    for k = 1, #keywords do
        if message:find(replaceString(keywords[k])) then
            local hex = string.format("%016X", color)
            local hexcolor = hex:gsub("(%w%w%w%w%w%w%w%w(%w%w%w%w%w%w)%w%w)", "%2")
            table.insert
            (
                keywordsMessages,
                string.format("{%s}%s", hexcolor, message)
            )
            return {color, message}
        end
    end
end

-- main
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    -- commands
    sampRegisterChatCommand("clearchat", clearChat)
    sampRegisterChatCommand("addkeyword", addWord)
    sampRegisterChatCommand("reloadkeywords", reloadWords)
    sampRegisterChatCommand("keywordslist", wordsList)
    sampRegisterChatCommand("extrachat", extraChat)
    sampRegisterChatCommand("removekeyword", removeWord)
    -- commands

    messageFont = renderCreateFont(
        mIni.Font.font,
        mIni.Font.fontSize,
        getFontStyle(
            mIni.Font.fontStyleBold,
            mIni.Font.fontStyleItalic,
            mIni.Font.fontStyleStroke,
            mIni.Font.fontStyleShadow
        )
    )

    sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}Ñêðèïò óñïåøíî çàãðóæåí. Àâòîð: {a785e3}TrenLok', -1)
    keywordsInit()

    while true do
        wait(0)
        imgui.Process = main_window_state.v
        if #keywordsMessages > mIni.Main.maxMessage then
            table.remove(keywordsMessages, 1)
        end
        local startPosY = mIni.Main.PosY
        for k, v in ipairs(keywordsMessages) do
            renderFontDrawText(messageFont, v, mIni.Main.PosX, startPosY, -1)
            startPosY = startPosY + (mIni.Font.fontSize + 10)
        end
    end
end
-- main

function extraChat()
    main_window_state.v = not main_window_state.v
end

function keywordsInit()
    keywords = {}
    if doesFileExist(keywordsFile) then
        for keyword in io.lines(keywordsFile) do
            table.insert(keywords, u8:decode(keyword))
        end
        sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}Êëþ÷åâûõ ñëîâ çàãðóæåíî: {a785e3}'..#keywords, -1)
        if #keywords == 0 then
            sampAddChatMessage(
                '{a785e3}[ExtraChat] {fcfdfd}×òîáû äîáàâèòü êëþ÷åâûå ñëîâà èñïîëüçóéòå êîìàíäó {a785e3}/addkeyword [ñëîâî]', -1
            )
        end
    else
        sampAddChatMessage(
            '{a785e3}[ExtraChat] {fcfdfd}Ôàéë ñ êëþ÷åâûìè ñëîâàìè íå îáíàðóæåí è ñîçäàí àâòîìàòè÷åñêè', -1
        )
        sampAddChatMessage(
            '{a785e3}[ExtraChat] {fcfdfd}×òîáû äîáàâèòü êëþ÷åâûå ñëîâà èñïîëüçóéòå êîìàíäó {a785e3}/addkeyword [ñëîâî]', -1
        )
        sampAddChatMessage(
            '{a785e3}[ExtraChat] {fcfdfd}×òîáû ïîñìîòðåòü âåñü ñïèñîê êîìàíä íàáåðèòå {a785e3}/extrachat', -1
        )
        local file = io.open(keywordsFile, "w")
        file.close()
        file = nil
    end
end

function clearChat()
    keywordsMessages = {}
    sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}×àò áûë î÷èùåí!', -1)
end

function reloadWords()
    sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}Ñïèñîê êëþ÷åâûõ ñëîâ áûë ïåðåçàãðóæåí", -1)
    keywordsInit()
end

function wordsList()
    sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}Ñïèñîê êëþ÷åâûõ ñëîâ:", -1)
    for index, data in ipairs(keywords) do
        print(index..":", data)
        sampAddChatMessage(index..":".." "..data, -1)
    end
    if #keywords == 0 then
        sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}Ñïèñîê ñëîâ ïóñò", -1)
    end
end

function removeWord(arg)
    if #arg == 0 then
        sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}Èñïîëüçóéòå: {a785e3}/removekeyword [ñëîâî]", -1)
    else
        local newKeywords = {}
        local check = false
        for k = 1, #keywords do
            if keywords[k] ~= arg then
                table.insert(newKeywords, keywords[k])
            else
                check = true
            end
        end
        local wordFile = io.open(keywordsFile, "w")
        for j = 1, #newKeywords do
            wordFile:write(u8(newKeywords[j])..'\n')
        end
        wordFile:close()
        if check then
            sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}Ñëîâî {a785e3}'" ..arg.."'{fcfdfd} óäàëåíî", -1)
        else
            sampAddChatMessage(
                "{a785e3}[ExtraChat] {fcfdfd}Ñëîâî {a785e3}'" ..arg.."'{fcfdfd} áûëî íå íàéäåíî â ñïèñêå êëþ÷åâûõ ñëîâ", -1
            )
        end
        keywords = newKeywords
        keywordsInit()
    end
end

function addWord(arg)
    if #arg == 0 then
        sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}Èñïîëüçóéòå: {a785e3}/addkeyword [ñëîâî]", -1)
    else
        for k = 1, #keywords do
            if keywords[k] == arg then
                sampAddChatMessage(
                    "{a785e3}[ExtraChat] {fcfdfd}Ñëîâî {a785e3}'" ..arg.. "'{fcfdfd} óæå åñòü â ñïèñêå êëþ÷åâûõ ñëîâ", -1
                )
                return
            end
        end
        local text = u8(arg)
        local wordFile = io.open(keywordsFile, "a")
        wordFile:write(text..'\n')
        wordFile:close()
        sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}Ñëîâî {a785e3}'" ..arg .. "'{fcfdfd} äîáàâëåíî â ñïèñîê êëþ÷åâûõ ñëîâ", -1)
        keywordsInit()
    end
end

function getFontStyle(bold, italic, stroke, shadow)
    local numStyle = 0
    if bold then numStyle = numStyle + 1 end
    if italic then numStyle = numStyle + 2 end
    if stroke then numStyle = numStyle + 4 end
    if shadow then numStyle = numStyle + 8 end
    return numStyle
end

function replaceString(string)
    local result, number = string:gsub("([%(%)%%%.%+%-%*%[%]%?%^$])", "%1%1")
    return result
end
