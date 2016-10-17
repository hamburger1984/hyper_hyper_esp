-- Connections:
--   ESP  --  OLED
-- -------||-------
--   3v3  --  VCC
--   GND  --  GND
--   D1   --  SDA
--   D2   --  SCL

local module = {}

-- Variables
sda = 1 -- SDA Pin
scl = 2 -- SCL Pin

local function init_OLED()
    local sla = 0x3C
    i2c.setup(0, sda, scl, i2c.SLOW)
    disp = u8g.ssd1306_128x64_i2c(sla)

     -- Ascent will be the largest ascent of "A", "1" or "(".
     -- Descent will be the larges descent of "g" or "(".
    disp:setFontRefHeightExtendedText()

    -- Ascent and descent will be the largest of all glyphs.
    --disp:setFontRefHeightAll()

    --disp:setRot180()           -- Rotate Display if needed
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
    init_OLED()

    tmr.alarm(0, 500, tmr.ALARM_AUTO, function() updateDisplay() end)
end

return module
