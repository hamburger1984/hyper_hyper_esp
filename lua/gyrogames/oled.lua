local module = {}

addr_ssd1306 = 0x3c

function module.initialize()
    disp = u8g.ssd1306_128x64_i2c(addr_ssd1306)

    disp:setFontRefHeightExtendedText()
end

values = {}

function module.setMPU(x1, y1, z1, x2, y2, z2, t)
    values.x1 = x1
    values.y1 = y1
    values.z1 = z1
    values.x2 = x2
    values.y2 = y2
    values.z2 = z2
    values.t = t
end

local function updateDisplay()
    local width = disp:getWidth()
    local column = width/3

    local height = disp:getHeight()

    local idStr = string.format("%06x", node.chipid())

    disp:setFont(u8g.font_profont10)
    disp:setFontPosBottom()
    local line = disp:getFontAscent() - disp:getFontDescent() + 2

    disp:firstPage()
    repeat
        disp:drawStr(0+column/2, line, "X")
        disp:drawStr(column+column/2, line, "Y")
        disp:drawStr(2*column+column/2, line, "Z")

        disp:drawStr(column - disp:getStrWidth(values.x1), 2*line, values.x1)
        disp:drawStr(2*column - disp:getStrWidth(values.y1), 2*line, values.y1)
        disp:drawStr(width - disp:getStrWidth(values.z1), 2*line, values.z1)

        disp:drawStr(column - disp:getStrWidth(values.x2), 3*line, values.x2)
        disp:drawStr(2*column - disp:getStrWidth(values.y2), 3*line, values.y2)
        disp:drawStr(width - disp:getStrWidth(values.z2), 3*line, values.z2)

        tStr = "temperature "..values.t
        disp:drawStr(width - disp:getStrWidth(tStr), 4*line, tStr)

        -- id -> bottom right
        disp:drawStr(width - disp:getStrWidth(idStr), height, idStr)
    until disp:nextPage() == false
end

-- function module.start()
--     local refresher = tmr:create()
--     refresher:register(200, tmr.ALARM_AUTO, function(t) updateDisplay(); end)
--     refresher:start()
-- end
--
function module.render()
    updateDisplay()
end

return module
