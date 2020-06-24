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
        PosY = sY/2,
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
-- config

-- check directory and config
if not doesDirectoryExist(getWorkingDirectory().."\\config\\ExtraChat") then createDirectory(getWorkingDirectory().."\\config\\ExtraChat") end
local status = inicfg.load(mainIni, string.format('ExtraChat/%s', configName))
if not doesFileExist(string.format('moonloader/config/ExtraChat/%s', configName)) then
	sampAddChatMessage(string.format('���� %s ��� ������', configName), -1);
	inicfg.save(mIni, string.format('ExtraChat/%s', configName)) end
-- check directory and config

-- imgui variable
local main_window_state = imgui.ImBool(false)
local iPosX = imgui.ImInt(mainIni.Main.PosX)
local iPosY = imgui.ImInt(mainIni.Main.PosY)
local iMaxMessage = imgui.ImInt(mainIni.Main.maxMessage)
local iFontSize = imgui.ImInt(mainIni.Font.fontSize)
local iFont = imgui.ImBuffer(tostring(mainIni.Font.font), 30)
local iFontStyleBold = imgui.ImBool(mainIni.Font.fontStyleBold)
local iFontStyleItalic = imgui.ImBool(mainIni.Font.fontStyleItalic)
local iFontStyleStroke = imgui.ImBool(mainIni.Font.fontStyleStroke)
local iFontStyleShadow = imgui.ImBool(mainIni.Font.fontStyleShadow)
-- imgui variable

-- imgui
function imgui.OnDrawFrame()
    if main_window_state.v then -- ������ � ������ �������� ����� ���������� �������������� ����� ���� v (��� Value)
        imgui.SetNextWindowSize(imgui.ImVec2(500, 480), imgui.Cond.FirstUseEver) -- ������ ������
        imgui.SetNextWindowPos(imgui.ImVec2(sX/2, sY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.LockPlayer = true
        -- ��� main_window_state ���������� � ������� imgui.Begin, ����� ����� ���� ��������� �������� ���� �������� �� �������
        imgui.Begin('AdvancedChat Settings', main_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
        if imgui.CollapsingHeader(u8'���������') then
            imgui.Text(u8'�������� ���������')
            imgui.PushItemWidth(180)
            imgui.InputText(u8'Nick', nk)
            imgui.InputInt(u8'������� �� X', iPosX)
            imgui.InputInt(u8'������� �� Y', iPosY)
            imgui.InputInt(u8'������������ ���������� �����', iMaxMessage)
            imgui.NewLine()
            imgui.Text(u8'��������� ������')
            imgui.InputInt(u8'������ ������', iFontSize)
            imgui.InputText(u8'�����', iFont)
            imgui.Checkbox(u8'����������', iFontStyleBold)
            imgui.Checkbox(u8'������', iFontStyleItalic)
            imgui.Checkbox(u8'������', iFontStyleStroke)
            imgui.Checkbox(u8'����', iFontStyleShadow)
            imgui.NewLine()
        end
        if imgui.CollapsingHeader(u8'������ ����') then
            imgui.Text(u8'������ ����������� ����:')
            for index, data in ipairs(Words) do
                imgui.Text(index..":".." "..u8(data))
            end
            if #Words == 0 then
                imgui.Text(u8"������ ���� ����")
            end
            imgui.NewLine()
        end
        if imgui.CollapsingHeader(u8'�������') then
            imgui.Text(u8'������ ������:')
            imgui.NewLine()
            imgui.Text(u8'/clearechat - �������� ExtraChat')
            imgui.Text(u8'/addkeyword - �������� ����� � ������')
            imgui.Text(u8'/removekeyword - ������� ����� �� �������')
            imgui.Text(u8'/reloadwords - ������������� ������ ����')
            imgui.Text(u8'/keywordslist - ���������� ��� ����� �� ������')
            imgui.Text(u8'/extrachat - ��������� ExtraChat')
        end
        imgui.NewLine()
        if imgui.Button(u8'��������� ���������') then
            printStringNow('Settinges saved!', 1000)
            sampAddChatMessage('Save!', -1)
            mainIni.Test.NickName = nk.v
            mainIni.Test.PosX = iPosX.v
            mainIni.Test.PosY = iPosY.v
            mainIni.Test.maxMessage = iMaxMessage.v
            mainIni.Font.fontSize = iFontSize.v
            mainIni.Font.font = iFont.v
            mainIni.Font.fontStyleBold = iFontStyleBold.v
            mainIni.Font.fontStyleItalic = iFontStyleItalic.v
            mainIni.Font.fontStyleStroke = iFontStyleStroke.v
            mainIni.Font.fontStyleShadow = iFontStyleShadow.v
            messageFont = renderCreateFont(
                iFont.v,
                iFontSize.v,
                getFontStyle(
                    iFontStyleBold.v,
                    iFontStyleItalic.v,
                    iFontStyleStroke.v,
                    iFontStyleShadow.v)
            )
            inicfg.save(mainIni, string.format('ExtraChat/%s', configName))
        end
        imgui.End()
    end
end
-- imgui

function sampev.onServerMessage(color, message)
    for k = 1, #Words do
        if message:find(Words[k]) then
            table.insert(keywordsMessage, string.format("%s", message))
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

    sampAddChatMessage('[ExtraChat] ������ ������� ��������. �����: TrenLok', -1)
    keywordsInit()

    while true do
        wait(0)
        imgui.Process = main_window_state.v
        if #keywordsMessages > mIni.Main.maxMessage then
            table.remove(keywordsMessages, 1)
        end
        local startPosY = mIni.Main.PosY
        for _, v in ipairs(mess) do
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
    if doesFileExist(keywordsFile) then
        for keyword in io.lines(keywordsFile) do
            table.insert(keywords, u8:decode(keyword))
        end
        sampAddChatMessage('[ExtraChat] �������� ���� ���������: '..#keywords, -1)
        if #keywords == 0 then
            sampAddChatMessage(
                '[ExtraChat] ����� �������� �������� ����� ����������� ������� /addkeyword [�����]', -1
            )
        end
    else
        sampAddChatMessage(
            '[ExtraChat] ���� � ��������� ������� �� ���������, ���� ������ �������������', -1
        )
        sampAddChatMessage(
            '[ExtraChat] ����� �������� �������� ����� ����������� ������� /addkeyword [�����]', -1
        )
        sampAddChatMessage(
            '[ExtraChat] ����� ���������� ���� ������ ������ �������� /extrachat', -1
        )
        local file = io.open(keywordsFile, "w")
        file.close()
        file = nil
    end
end

function clearChat()
    keywordsMessages = {}
    sampAddChatMessage('[ExtraChat] ��� ��� ������!', -1)
end

function reloadWords()
    sampAddChatMessage("[ExtraChat] ������ �������� ���� ��� ������������", -1)
    keywordsInit()
end

function wordsList()
    sampAddChatMessage("[ExtraChat] ������ �������� ����:", -1)
    for index, data in ipairs(keywords) do
        print(index..":", data)
        sampAddChatMessage(index..":".." "..data, -1)
    end
    if #keywords == 0 then
        sampAddChatMessage("[ExtraChat] ������ ���� ����", -1)
    end
end

function removeWord(arg)
    if #arg == 0 then
        sampAddChatMessage("[ExtraChat] �����������: /removekeyword [�����]", -1)
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
            sampAddChatMessage("[ExtraChat] ����� " ..arg.." �������", -1)
        else
            sampAddChatMessage(
                "[ExtraChat] ����� " ..arg.." ���� �� ������� � ������ �������� ����", -1
            )
        end
        keywords = newKeywords
        keywordsInit()
    end
end

function addWord(arg)
    if #arg == 0 then
        sampAddChatMessage("[ExtraChat] �����������: /addkeyword [�����]", -1)
    else
        for k = 1, #Words do
            if Words[k] == arg then
                sampAddChatMessage(
                    "[ExtraChat] ����� " ..arg.. " ��� ���� � ������ �������� ����", -1
                )
                return
            end
        end
        local text = u8(arg)
        local wordFile = io.open(MessageFile, "a")
        wordFile:write(text..'\n')
        wordFile:close()
        sampAddChatMessage("[ExtraChat] �����: " ..arg .. "��������� � ������ �������� ����", -1)
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
