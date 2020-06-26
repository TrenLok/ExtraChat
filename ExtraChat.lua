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
        timestamp = false,
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
local remove_window_state = imgui.ImBool(false)
local addkeyword_window_state = imgui.ImBool(false)
local rmkeyword_window_state = imgui.ImBool(false)
local iPosX = imgui.ImInt(mIni.Main.PosX)
local iPosY = imgui.ImInt(mIni.Main.PosY)
local iMaxMessage = imgui.ImInt(mIni.Main.maxMessage)
local iTimestamp = imgui.ImBool(mIni.Main.timestamp)
local iFontSize = imgui.ImInt(mIni.Font.fontSize)
local iFont = imgui.ImBuffer(tostring(mIni.Font.font), 30)
local iFontStyleBold = imgui.ImBool(mIni.Font.fontStyleBold)
local iFontStyleItalic = imgui.ImBool(mIni.Font.fontStyleItalic)
local iFontStyleStroke = imgui.ImBool(mIni.Font.fontStyleStroke)
local iFontStyleShadow = imgui.ImBool(mIni.Font.fontStyleShadow)

local iKeyword = imgui.ImBuffer(25)
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
            imgui.NewLine()
            if imgui.Button(u8'��������� ���������') then
                sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}��������� ���������!', -1)
                mIni.Main.PosX = iPosX.v
                mIni.Main.PosY = iPosY.v
                mIni.Main.maxMessage = iMaxMessage.v
                mIni.Main.timestamp =  iTimestamp.v
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
        end
        if imgui.CollapsingHeader(u8'������ ����') then
            imgui.Text(u8'������ ����������� ����:')
            for index, data in ipairs(keywords) do
                imgui.Text(index..":".." "..u8(data))
            end
            if #keywords == 0 then
                imgui.Text(u8"������ ���� ����")
            end
            imgui.NewLine()
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
        end
        if imgui.CollapsingHeader(u8'�������') then
            imgui.Text(u8'������ ������:')
            imgui.NewLine()
            imgui.Text(u8'/clearechat - �������� ExtraChat')
            imgui.Text(u8'/addkeyword - �������� ����� � ������')
            imgui.Text(u8'/rmkeyword - ������� ����� �� �������')
            imgui.Text(u8'/reloadwords - ������������� ������ ����')
            imgui.Text(u8'/keywordslist - ���������� ��� ����� �� ������')
            imgui.Text(u8'/extrachat - ��������� ExtraChat')
            imgui.Text(u8'/rmallkeywords - ������� ��� �������� �����')
        end
        imgui.End()
    end
    if remove_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 100))
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
        imgui.NewLine()
        imgui.SetCursorPosX((imgui.GetWindowWidth() - 150 + imgui.GetStyle().ItemSpacing.x) /
         2)
        if imgui.Button(u8"��", imgui.ImVec2(75, 20)) then
            keywords = {}
            os.remove(keywordsFile)
            sampAddChatMessage(
                '{a785e3}[ExtraChat] {fcfdfd}��� �������� ����� ���� �������', -1
            )
            sampAddChatMessage(
                '{a785e3}[ExtraChat] {fcfdfd}����� �������� �������� ����� ����������� ������� {a785e3}/addkeyword [�����]', -1
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
        imgui.SetNextWindowSize(imgui.ImVec2(360, 100))
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
        imgui.NewLine()
        if imgui.Button(u8"��������") then
            if #iKeyword.v == 0 then
                sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}������� �����', -1)
            else
                addWord(iKeyword.v)
                iKeyword.v = ''
            end
        end
        imgui.End()
    end
    if rmkeyword_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(360, 100))
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
        imgui.NewLine()
        if imgui.Button(u8"�������") then
            if #iKeyword.v == 0 then
                sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}������� �����', -1)
            else
                removeWord(iKeyword.v)
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
                    string.format("%s {%s}%s", os.date("[%H:%M:%S] "), hexcolor, message)
                )
            else
                table.insert
                (
                    keywordsMessages,
                    string.format("{%s}%s", hexcolor, message)
                )
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
    sampRegisterChatCommand("clearechat", clearChat)
    sampRegisterChatCommand("rmallkeywords", rmKeywordsList)
    sampRegisterChatCommand("addkeyword", addWord)
    sampRegisterChatCommand("reloadkeywords", reloadWords)
    sampRegisterChatCommand("keywordslist", wordsList)
    sampRegisterChatCommand("extrachat", extraChat)
    sampRegisterChatCommand("rmkeyword", removeWord)
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

function keywordsInit()
    keywords = {}
    if doesFileExist(keywordsFile) then
        for keyword in io.lines(keywordsFile) do
            table.insert(keywords, u8:decode(keyword))
        end
        sampAddChatMessage('{a785e3}[ExtraChat] {fcfdfd}�������� ���� ���������: {a785e3}'..#keywords, -1)
        if #keywords == 0 then
            sampAddChatMessage(
                '{a785e3}[ExtraChat] {fcfdfd}����� �������� �������� ����� ����������� ������� {a785e3}/addkeyword [�����]', -1
            )
        end
    else
        sampAddChatMessage(
            '{a785e3}[ExtraChat] {fcfdfd}���� � ��������� ������� �� ��������� � ������ �������������', -1
        )
        sampAddChatMessage(
            '{a785e3}[ExtraChat] {fcfdfd}����� �������� �������� ����� ����������� ������� {a785e3}/addkeyword [�����]', -1
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
        sampAddChatMessage("{a785e3}[ExtraChat] {fcfdfd}�����������: {a785e3}/rmkeyword [�����]", -1)
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
            "{a785e3}[ExtraChat] {fcfdfd}�����������: {a785e3}/addkeyword [�����]", -1
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
