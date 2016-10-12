local module = {}

--
--             GPIO5  ~ D1                                -> RES
--             GPIO4  ~ D2                                -> DC
--             GPIO0  ~ D3                                -> CS
--
-- HSPI CLK  = GPIO14 ~ D5 -- Serial Clock                -> SCL
-- HSPI MISO = GPIO12 ~ D6 -- Master Input, Slave Output  -> (not used)
-- HSPI MOSI = GPIO13 ~ D7 -- Master Output, Slave Input  -> SDA
-- HSPI MTDO = GPIO15 ~ D8 -- CS/SS                       -> (not used)
--

CS, DC, RES = 3, 2, 1

disp = nil

function module.initialize()
    -- id, mode, clock polarity, clock phase, databits, clock divider
    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)

    -- HSPI/CS line unused - disable
    gpio.mode(CS, gpio.INPUT, gpio.PULLUP)

    -- initialize ssd1331 driver
    disp = ucg.ssd1331_18x96x64_uvis_hw_spi(CS, DC, RES)

    --disp:begin(ucg.FONT_MODE_TRANSPARENT)
    disp:begin(ucg.FONT_MODE_SOLID)

    disp:clearScreen()

    disp:setColor(0, 255, 255, 255)
    disp:setColor(1, 0, 0, 0)
end

function module.clear()
    disp:clearScreen()
end

function module.border(r, g, b, offset)
    disp:setColor(0, r, g, b)
    disp:drawFrame(offset, offset, disp:getWidth()-2*offset, disp:getHeight()-2*offset)
end

function module.text(r, g, b, value, size, ypos, right_align)
    if size == 'small' then
        disp:setFont(ucg.font_profont10_mf)
    elseif size == 'large' then
        disp:setFont(ucg.font_profont22_mf)
    else
        disp:setFont(ucg.font_profont15_mf)
    end

    local tw = disp:getStrWidth(value)
    local offset = 12

    disp:setColor(0, r, g, b)
    disp:setFontPosTop()
    if right_align then
        disp:setPrintPos(disp:getWidth()-offset-tw, ypos)
    else
        disp:setPrintPos(offset, ypos)
    end
    disp:print(value)

    -- clear remainder of line
    disp:setColor(0, 0, 0, 0)
    -- ascent is char height above baseline
    -- descent is below baseline (negative)
    if right_align then
        disp:drawBox(offset, ypos, disp:getWidth()-2*offset-tw, disp:getFontAscent()+(-1*disp:getFontDescent()))
    else
        disp:drawBox(offset+tw, ypos, disp:getWidth()-2*offset-tw, disp:getFontAscent()+(-1*disp:getFontDescent()))
    end
end

return module
