--[[
    Title: emergency call
    Version : 1
    Author: MARD
    Description: CMD Haye  Marbot Be In System /call100 /a110
]]
local POLICE_FACTION_ID = 1

local callConversations = {}

function startEmergencyConversation(thePlayer, command)
    if callConversations[thePlayer] then
        outputChatBox("شما در حال حاضر در یک مکالمه با پلیس هستید. لطفاً با دستور /a110 به سوالات پاسخ دهید.", thePlayer, 255, 150, 0)
        return
    end

    local callerName = getPlayerName(thePlayer):gsub("_", " ")
    
    callConversations[thePlayer] = {
        state = 1, 
        data = {
            name = callerName
        }
    }

    outputChatBox(" ", thePlayer)
    outputChatBox("سلام علیکم آقا/خانم با اداره پلیس تماس گرفتید", thePlayer, 0, 200, 255, true)
    outputChatBox("لطفاً موضوع تماس خود را با دستور زیر بنویسید", thePlayer, 0, 200, 255)
    outputChatBox("/a110 [موضوع تماس]", thePlayer, 255, 255, 255)
end
addCommandHandler("call110", startEmergencyConversation)

function handlePlayerResponse(thePlayer, command, ...)
    local message = table.concat({...}, " ")

    if not callConversations[thePlayer] then
        outputChatBox("شما در حال حاضر مکالمه فعالی با پلیس ندارید. برای شروع از /call110 استفاده کنید.", thePlayer, 255, 150, 0)
        return
    end

    if message == "" then
        outputChatBox("لطفاً پاسخ خود را بعد از دستور بنویسید. مثال: /a110 پاسخ شما", thePlayer, 255, 150, 0)
        return
    end

    local conversation = callConversations[thePlayer]
    
    if conversation.state == 1 then
        conversation.data.subject = message
        conversation.state = 2
        outputChatBox("موضوع دریافت شد. لطفاً جزئیات بیشتری با دستور زیر ارائه دهید:", thePlayer, 0, 200, 255)
        outputChatBox("/a110 [جزئیات کامل]", thePlayer, 255, 255, 255)
    
    elseif conversation.state == 2 then
        conversation.data.details = message
        conversation.state = 3
        outputChatBox("جزئیات ثبت شد. لطفاً شماره تلفن خود را با دستور زیر وارد کنید:", thePlayer, 0, 200, 255)
        outputChatBox("/a110 [شماره تلفن]", thePlayer, 255, 255, 255)

    elseif conversation.state == 3 then
        if not tonumber(message) then
            outputChatBox("لطفاً یک شماره تلفن معتبر (فقط عدد) با دستور زیر وارد کنید:", thePlayer, 255, 50, 50)
            outputChatBox("/a110 [شماره تلفن]", thePlayer, 255, 255, 255)
            return
        end
        
        conversation.data.phoneNumber = message

        sendReportToPolice(conversation.data)

        outputChatBox("از تماس شما متشکریم. گزارش شما ثبت شد.", thePlayer, 50, 255, 50)
        outputChatBox("اعضا پلیس در اولین فرصت با شما تماس میگیرند.", thePlayer, 50, 255, 50)

        callConversations[thePlayer] = nil
    end
end
addCommandHandler("a110", handlePlayerResponse)


function sendReportToPolice(data)
    local policeFound = false
    
    for _, policePlayer in ipairs(getElementsByType("player")) do
        if getElementData(policePlayer, "faction") == POLICE_FACTION_ID then
            policeFound = true
            outputChatBox(" ", policePlayer)
            outputChatBox("======= گزارش تماس شهروندی جدید =======", policePlayer, 255, 50, 50)
            outputChatBox("نام تماس‌گیرنده: #ffffff" .. data.name, policePlayer, 255, 204, 0, true)
            outputChatBox("موضوع اصلی: #ffffff" .. data.subject, policePlayer, 255, 204, 0, true)
            outputChatBox("جزئیات کامل: #ffffff" .. data.details, policePlayer, 255, 204, 0, true)
            outputChatBox("شماره تماس برای پیگیری: #ffffff" .. data.phoneNumber, policePlayer, 255, 204, 0, true)
            outputChatBox("====================================", policePlayer, 255, 50, 50)
        end
    end
    if not policeFound then
    end
end

function cleanupOnPlayerQuit()
    if callConversations[source] then
        callConversations[source] = nil
    end
end
addEventHandler("onPlayerQuit", root, cleanupOnPlayerQuit)
