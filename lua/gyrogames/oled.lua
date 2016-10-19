local module = {}

addr_ssd1306 = 0x3c

function module.initialize()
    disp = u8g.ssd1306_128x64_i2c(addr_ssd1306)

    disp:setFontRefHeightExtendedText()
end

local function updateDisplay()
    -- tmr.now() wraps around at 35:47.483.647 (31bit, microseconds)
    local seconds = tmr.now()/1000000
    local minutes = seconds/60
    seconds = seconds - (minutes*60)
    local uptime = string.format("%02d:%02d", minutes, seconds)
    local width = disp:getWidth()
    local height = disp:getHeight()

    local idStr = string.format("%06x", node.chipid())

    disp:firstPage()
    repeat
        -- say Hello
        disp:setFont(u8g.font_profont22)
        disp:setFontPosTop()
        disp:drawStr(0, 0, "Hello")
        top = disp:getFontAscent() + -1*disp:getFontDescent()

        -- testing icon font.
        disp:setFont(u8g.font_m2icon_7)
        disp:setFontPosTop()
        h = disp:getFontAscent() + -1*disp:getFontDescent() + 2
        disp:drawStr(0, top, "\64\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79")
        disp:drawStr(0, top+h, "\80\81\82\83\84\85\86\87\88\89\90\91\92\93\94\95")
        disp:drawStr(0, top+h+h, "\96\97\98\99\100\101\102\103\104\105\106\107\108\109\110\111")

        -- printing node id & uptime to bottom line
        disp:setFont(u8g.font_profont10)
        disp:setFontPosBottom()
        disp:drawStr(0, height, idStr)
        uptimeWidth = disp:getStrWidth(uptime)
        disp:drawStr(width-uptimeWidth, height, uptime)
    until disp:nextPage() == false
end

function module.start()
    tmr.alarm(0, 1000, tmr.ALARM_AUTO, function() updateDisplay() end)
end

return module
