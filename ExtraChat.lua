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
local logFile = 'moonloader/config/ExtraChat/log.txt'
local keywordsMessages = {}
local keywords = {}
local log = {}

encoding.default = 'CP1251'
u8 = encoding.UTF8
-- global variables

-- config
mIni = inicfg.load({
    Main = {
        PosX = sW/2,
        PosY = sH/2,
        maxMessage = 10,
        timestamp = false,
        log = false,
    },
    Font = {
		font = 'Arial',
		fontSize = 10,
		fontStyleBold = false,
		fontStyleItalic = false,
		fontStyleStroke = false,
		fontStyleShadow = false,
	},
    Commands = {
        clearChat = 'clearechat',
        addKeyword = 'addkeyword',
        removeKeyword = 'rmkeyword',
        reloadKeywords = 'reloadkeywords',
        keywordsList = 'keywordslist',
        removeAllKeywords = 'rmallkeywords',
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
local remove_window_state = imgui.ImBool(false)
local addkeyword_window_state = imgui.ImBool(false)
local rmkeyword_window_state = imgui.ImBool(false)
local iPosX = imgui.ImInt(mIni.Main.PosX)
local iPosY = imgui.ImInt(mIni.Main.PosY)
local iMaxMessage = imgui.ImInt(mIni.Main.maxMessage)
local iTimestamp = imgui.ImBool(mIni.Main.timestamp)
local iLog = imgui.ImBool(mIni.Main.log)
local iFontSize = imgui.ImInt(mIni.Font.fontSize)
local iFont = imgui.ImBuffer(tostring(mIni.Font.font), 30)
local iFontStyleBold = imgui.ImBool(mIni.Font.fontStyleBold)
local iFontStyleItalic = imgui.ImBool(mIni.Font.fontStyleItalic)
local iFontStyleStroke = imgui.ImBool(mIni.Font.fontStyleStroke)
local iFontStyleShadow = imgui.ImBool(mIni.Font.fontStyleShadow)

local iKeyword = imgui.ImBuffer(25)

local iClearChat = imgui.ImBuffer(tostring(mIni.Commands.clearChat), 30)
local iReloadKeywords = imgui.ImBuffer(tostring(mIni.Commands.reloadKeywords), 30)
local iRemoveKeyword = imgui.ImBuffer(tostring(mIni.Commands.removeKeyword), 30)
local iAddKeyword = imgui.ImBuffer(tostring(mIni.Commands.addKeyword), 30)
local iRemoveAllKeywords = imgui.ImBuffer(tostring(mIni.Commands.removeAllKeywords), 30)
local iKeywordsList = imgui.ImBuffer(tostring(mIni.Commands.keywordsList), 30)
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
        if imgui.CollapsingHeader(u8'���������') then
            imgui.Text(u8'�������� ���������')
            imgui.PushItemWidth(180)
            imgui.InputInt(u8'������� �� X', iPosX)
            imgui.InputInt(u8'������� �� Y', iPosY)
            imgui.InputInt(u8'������������ ���������� �����', iMaxMessage)
            imgui.Checkbox(u8'���������� ����� �������� ���������', iTimestamp)
            imgui.Checkbox(u8'��������� ��������� ��������� ����� ����� �� ����', iLog)
            imgui.NewLine()
            imgui.Text(u8'��������� ������')
            imgui.InputInt(u8'������ ������', iFontSize)
            imgui.InputText(u8'�����', iFont)
            imgui.Checkbox(u8'����������', iFontStyleBold)
            imgui.SameLine()
            imgui.Checkbox(u8'������', iFontStyleItalic)
            imgui.SameLine()
            imgui.Checkbox(u8'������', iFontStyleStroke)
            imgui.SameLine()
            imgui.Checkbox(u8'����', iFontStyleShadow)
            if imgui.Button(u8'��������� ���������') then
                sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}��������� ���������!', -1)
                mIni.Main.PosX = iPosX.v
                mIni.Main.PosY = iPosY.v
                mIni.Main.maxMessage = iMaxMessage.v
                mIni.Main.timestamp =  iTimestamp.v
                mIni.Main.log = iLog.v
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
                if not mIni.Main.log then
                    local file = io.open(logFile, "w")
                    file.close()
                    file = nil
                end
            end
            imgui.NewLine()
        end
        if imgui.CollapsingHeader(u8'��������� ������') then
            imgui.PushItemWidth(180)
            imgui.InputText(u8'�������� ExtraChat', iClearChat)
            imgui.InputText(u8'�������� ����� � ������', iAddKeyword)
            imgui.InputText(u8'������� ����� �� ������', iRemoveKeyword)
            imgui.InputText(u8'������� ��� �������� �����', iRemoveAllKeywords)
            imgui.InputText(u8'������������� ������ ����', iReloadKeywords)
            imgui.InputText(u8'���������� ��� ����� �� ������', iKeywordsList)
            if imgui.Button(u8'���������') then
                mIni.Commands.clearChat = iClearChat.v
                mIni.Commands.reloadKeywords = iReloadKeywords.v
                mIni.Commands.removeKeyword = iRemoveKeyword.v
                mIni.Commands.addKeyword = iAddKeyword.v
                mIni.Commands.removeAllKeywords = iRemoveAllKeywords.v
                mIni.Commands.keywordsList = iKeywordsList.v
                inicfg.save(mIni, string.format('ExtraChat/%s', configName))
                sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}������� ���������!', -1)
                showCursor(false)
                thisScript():reload()
            end
            imgui.NewLine()
        end
        if imgui.CollapsingHeader(u8'������ ����') then
            imgui.Text(u8'������ ����������� ����:')
            for index, data in ipairs(keywords) do
                imgui.Text(index..":".." "..u8(data))
            end
            if #keywords == 0 then
                imgui.Text(u8"������ ���� ����")
            end
            if imgui.Button(u8'�������� �������� �����') then
                addkeyword_window_state.v = true
                rmkeyword_window_state.v = false
                iKeyword.v = ''
            end
            imgui.SameLine()
            if imgui.Button(u8'������� �������� �����') then
                rmkeyword_window_state.v = true
                addkeyword_window_state.v = false
                iKeyword.v = ''
            end
            imgui.NewLine()
        end
        if imgui.CollapsingHeader(u8'�������') then
            imgui.Text(u8'������ ������:')
            imgui.NewLine()
            imgui.Text(u8('/extrachat - ��������� ExtraChat'))
            imgui.Text(u8('/'..mIni.Commands.clearChat..' - �������� ExtraChat'))
            imgui.Text(u8('/'..mIni.Commands.addKeyword..' - �������� ����� � ������'))
            imgui.Text(u8('/'..mIni.Commands.removeKeyword..' - ������� ����� �� ������'))
            imgui.Text(u8('/'..mIni.Commands.removeAllKeywords..' - ������� ��� �������� �����'))
            imgui.Text(u8('/'..mIni.Commands.reloadKeywords..' - ������������� ������ ����'))
            imgui.Text(u8('/'..mIni.Commands.keywordsList..' - ���������� ��� ����� �� ������'))
        end
        imgui.End()
    end
    if remove_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 80))
        imgui.SetNextWindowPos(
            imgui.ImVec2(sW/2, sH/2), imgui.Cond.FirstUseEver,
            imgui.ImVec2(0.5, 0.5)
        )
        imgui.Begin(
            u8'ExtraChat �������������',
            remove_window_state,
            imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize
        )
        imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"�� �������?").x) / 2)
        imgui.Text(u8'�� �������?')
        imgui.SetCursorPosX((imgui.GetWindowWidth() - 150 + imgui.GetStyle().ItemSpacing.x) /
         2)
        if imgui.Button(u8"��", imgui.ImVec2(75, 20)) then
            keywords = {}
            os.remove(keywordsFile)
            sampAddChatMessage(
                '{a785e3}[ExtraChat] {fcfdfd}��� �������� ����� ���� �������', -1
            )
            sampAddChatMessage(
                '{a785e3}[ExtraChat] {fcfdfd}����� �������� �������� ����� ����������� ������� {a785e3}/'..mIni.Commands.addKeyword..' [�����]', -1
            )

            local file = io.open(keywordsFile, "w")
            file.close()
            file = nil
            remove_window_state.v = not remove_window_state.v
        end
        imgui.SameLine()
        if imgui.Button(u8"���", imgui.ImVec2(75, 20)) then
            remove_window_state.v = not remove_window_state.v
        end
        imgui.End()
    end
    if addkeyword_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(360, 80))
        imgui.SetNextWindowPos(
            imgui.ImVec2(sW/2, sH/2), imgui.Cond.FirstUseEver,
            imgui.ImVec2(0.5, 0.5)
        )
        imgui.Begin(
            u8'�������� �������� �����',
            addkeyword_window_state,
            imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize
        )
        imgui.PushItemWidth(180)
        imgui.InputText(u8"������� �������� �����", iKeyword)
        if imgui.Button(u8"��������") then
            if #iKeyword.v == 0 then
                sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}������� �����', -1)
            else
                addWord(u8:decode(iKeyword.v))
                iKeyword.v = ''
            end
        end
        imgui.End()
    end
    if rmkeyword_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(360, 80))
        imgui.SetNextWindowPos(
            imgui.ImVec2(sW/2, sH/2), imgui.Cond.FirstUseEver,
            imgui.ImVec2(0.5, 0.5)
        )
        imgui.Begin(
            u8'������� �������� �����',
            rmkeyword_window_state,
            imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize
        )
        imgui.PushItemWidth(180)
        imgui.InputText(u8"������� �������� �����", iKeyword)
        if imgui.Button(u8"�������") then
            if #iKeyword.v == 0 then
                sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}������� �����', -1)
            else
                removeWord(u8:decode(iKeyword.v))
                iKeyword.v = ''
            end
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
            if mIni.Main.timestamp then
                table.insert
                (
                    keywordsMessages,
                    string.format("%s {%s}%s", os.date("[%H:%M:%S]"), hexcolor, message)
                )
                if mIni.Main.log then
                    writeLog(string.format("%s {%s}%s", os.date("[%H:%M:%S]"), hexcolor, message))
                end
            else
                table.insert
                (
                    keywordsMessages,
                    string.format("{%s}%s", hexcolor, message)
                )
                if mIni.Main.log then
                    writeLog(string.format("{%s}%s", hexcolor, message))
                end
            end
            return {color, message}
        end
    end
end

-- main
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    -- commands
    sampRegisterChatCommand(mIni.Commands.clearChat, clearChat)
    sampRegisterChatCommand(mIni.Commands.removeAllKeywords, rmKeywordsList)
    sampRegisterChatCommand(mIni.Commands.addKeyword, addWord)
    sampRegisterChatCommand(mIni.Commands.reloadKeywords, reloadWords)
    sampRegisterChatCommand(mIni.Commands.keywordsList, wordsList)
    sampRegisterChatCommand("extrachat", extraChat)
    sampRegisterChatCommand(mIni.Commands.removeKeyword, removeWord)
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

    sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}������ ������� ��������. �����: {a785e3}TrenLok', -1)
    keywordsInit()
    logInit()

    while true do
        wait(0)
        imgui.Process = main_window_state.v
                or remove_window_state.v
                or addkeyword_window_state.v
                or rmkeyword_window_state.v
        if #keywordsMessages > mIni.Main.maxMessage then
            table.remove(keywordsMessages, 1)
        end
        local startPosY = mIni.Main.PosY
        for _, v in ipairs(keywordsMessages) do
            renderFontDrawText(messageFont, v, mIni.Main.PosX, startPosY, -1)
            startPosY = startPosY + (mIni.Font.fontSize + 10)
        end
    end
end
-- main

function extraChat()
    main_window_state.v = not main_window_state.v
end

function writeLog(text)
    table.insert(log, text)
    if #log > mIni.Main.maxMessage then
        table.remove(log, 1)
    end
    local file = io.open(logFile, "w")
    for _, v in ipairs(log) do
        file:write(u8(v)..'\n')
    end
    file:close()
    file = nil
end

function  logInit()
    log = {}
    if doesFileExist(logFile) then
        for logMessage in io.lines(logFile) do
            table.insert(keywordsMessages, u8:decode(logMessage))
        end
        local file = io.open(logFile, "w")
        file.close()
        file = nil
    else
        local file = io.open(logFile, "w")
        file.close()
        file = nil
    end
end

function keywordsInit()
    keywords = {}
    if doesFileExist(keywordsFile) then
        for keyword in io.lines(keywordsFile) do
            table.insert(keywords, u8:decode(keyword))
        end
        sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}�������� ���� ���������: {a785e3}'..#keywords, -1)
        if #keywords == 0 then
            sampAddChatMessage(
                '{a785e3}[ExtraChat] {fcfdfd}����� �������� �������� ����� ����������� ������� {a785e3}/'..mIni.Commands.addKeyword..' [�����]', -1
            )
        end
    else
        sampAddChatMessage(
            '{a785e3}[ExtraChat] {fcfdfd}���� � ��������� ������� �� ��������� � ������ �������������', -1
        )
        sampAddChatMessage(
            '{a785e3}[ExtraChat] {fcfdfd}����� �������� �������� ����� ����������� ������� {a785e3}/'..mIni.Commands.addKeyword..' [�����]', -1
        )
        sampAddChatMessage(
            '{a785e3}[ExtraChat] {fcfdfd}����� ���������� ���� ������ ������ �������� {a785e3}/extrachat', -1
        )
        local file = io.open(keywordsFile, "w")
        file.close()
        file = nil
    end
end

function clearChat()
    keywordsMessages = {}
    sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}��� ��� ������!', -1)
end

function reloadWords()
    sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}������ �������� ���� ��� ������������", -1)
    keywordsInit()
end

function wordsList()
    sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}������ �������� ����:", -1)
    for index, data in ipairs(keywords) do
        print(index..":", data)
        sampAddChatMessage(index..":".." "..data, -1)
    end
    if #keywords == 0 then
        sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}������ ���� ����", -1)
    end
end

function removeWord(arg)
    if #arg == 0 then
        sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}�����������: {a785e3}/"..mIni.Commands.removeKeyword.." [�����]", -1)
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
            sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}����� {a785e3}'" ..arg.."'{fcfdfd} �������", -1)
        else
            sampAddChatMessage(
                "{a785e3}[ExtraChat] {fcfdfd}����� {a785e3}'" ..arg.."'{fcfdfd} ���� �� ������� � ������ �������� ����", -1
            )
        end
        keywords = newKeywords
        keywordsInit()
    end
end

function addWord(arg)
    if #arg == 0 then
        sampAddChatMessage(
            "{a785e3}[ExtraChat] {fcfdfd}�����������: {a785e3}/"..mIni.Commands.addKeyword.." [�����]", -1
        )
    elseif #arg < 3 or #arg > 25 then
        sampAddChatMessage(
            "{a785e3}[ExtraChat] {fcfdfd}����� ��������� ����� ������ ���� �� 3 �� 25 ��������", -1
        )
    else
        for k = 1, #keywords do
            if keywords[k] == arg then
                sampAddChatMessage(
                    "{a785e3}[ExtraChat] {fcfdfd}����� {a785e3}'" ..arg.. "'{fcfdfd} ��� ���� � ������ �������� ����", -1
                )
                return
            end
        end
        local text = u8(arg)
        local wordFile = io.open(keywordsFile, "a")
        wordFile:write(text..'\n')
        wordFile:close()
        sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}����� {a785e3}'" ..arg .. "'{fcfdfd} ��������� � ������ �������� ����", -1)
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

function rmKeywordsList()
    remove_window_state.v = not remove_window_state.v
end

function apply_custom_style()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.Alpha = 1.0
    colors[clr.WindowBg]              = ImVec4(0.00, 0.00, 0.00, 0.90)
    colors[clr.ChildWindowBg]         = ImVec4(0.00, 0.00, 0.00, 0.90)
    colors[clr.PopupBg]               = ImVec4(0.02, 0.02, 0.02, 1.00)
    colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30)
    colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00)
    colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68)
    colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57)
    colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00)
    colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31)
    colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78)
    colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00)
    colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00)
    colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24)
    colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44)
    colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86)
    colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00)
    colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76)
    colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86)
    colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20)
    colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78)
    colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.CloseButton]           = ImVec4(0.47, 0.25, 0.62, 1.00)
    colors[clr.CloseButtonHovered]    = ImVec4(0.56, 0.30, 0.65, 1.00)
    colors[clr.CloseButtonActive]     = ImVec4(0.56, 0.30, 0.65, 1.00)
    colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63)
    colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63)
    colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43)
    colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35)
    style.WindowRounding = 3.0
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 10.0
    style.ScrollbarRounding = 3
    style.GrabMinSize = 9.0
    style.GrabRounding = 2.0
    style.IndentSpacing = 25.0
end
apply_custom_style()
