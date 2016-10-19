local module = {}

function module.initialize()
    i2c.setup(0, config.i2c_sda, config.i2c_scl, i2c.SLOW)
end

function module.read(addr, reg, len)
    i2c.start(0)
    i2c.address(0, addr, i2c.TRANSMITTER)
    i2c.write(0, reg)
    i2c.stop(0)
    i2c.start(0)
    i2c.address(0, addr, i2c.RECEIVER)
    local result = i2c.read(0, len)
    i2c.stop(0)

    return result
end

function module.readbit(addr, reg, position)
    local value = string.byte(module.read(addr, reg, 1))

    return bit.isset(value, position)
end

function module.write(addr, reg, value)
    i2c.start(0)
    i2c.address(0, addr, i2c.TRANSMITTER)
    local written = i2c.write(0, reg, value)
    i2c.stop(0)

    return written
end

function module.writebit(addr, reg, position , value)
    local old = string.byte(module.read(addr, reg, 1))
    local new = 0

    if value then
        new = bit.set(old, position)
    else
        new = bit.clear(old, position)
    end

    return module.write(addr, reg, new)
end


function module.scanbus()
    for i = 0, 127 do
        v = string.byte(module.read(i, 0, 1))
        if v ~= 0xff then
            print(string.format("Found I²C device at %02x (Reg 0:%02x)", i, v))
        end
    end
end

return module
