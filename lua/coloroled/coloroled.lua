local module = {}

--
-- HSPI CLK  = GPIO14 ~ D5 -- Serial Clock                -> SCL
-- HSPI MOSI = GPIO13 ~ D7 -- Master Output, Slave Input  -> SDA
-- HSPI MISO = GPIO12 ~ D6 -- Master Input, Slave Output  -> (not used)
-- HSPI MTDO = GPIO15 ~ D8 -- CS/SS                       -> (not used)
--
--             GPIO0  ~ D3                                -> CS
--             GPIO4  ~ D2                                -> DC
--             GPIO5  ~ D1                                -> RES
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

    disp:begin(ucg.FONT_MODE_TRANSPARENT)

    disp:clearScreen()

    disp:setColor(0, 255, 255, 255)
    disp:setColor(1, 0, 0, 0)

    disp:setFont(ucg.font_helvB08_hr)
end

function module.clear()
    disp:clearScreen()
end

function module.border(r, g, b, offset)
    disp:setColor(0, r, g, b)
    disp:drawFrame(offset, offset, disp:getWidth()-2*offset, disp:getHeight()-2*offset)
end

function module.text(r, g, b, value)

    disp:setColor(0, 0, 0, 0)
    disp:drawBox(15, 15, disp:getWidth()-30, disp:getHeight()-30)

    disp:setColor(0, r, g, b)
    disp:setFontPosCenter()
    disp:setPrintPos(15, disp:getHeight()/2)
    disp:print(value)
end

return module
