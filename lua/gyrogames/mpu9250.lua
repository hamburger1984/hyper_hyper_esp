local module = {}

-- this heavily relies on code from the ESP8266 Smartwatch project
-- see: https://github.com/Jeija/esp8266-smartwatch

-- MPU9250
addr_mpu9250 = 0x68

MPU9250_RA_GYRO_CONFIG = 0x1b
MPU9250_RA_ACCEL_CONFIG = 0x1c
MPU9250_RA_INT_PIN_CFG = 0x37
MPU9250_RA_ACCEL_XOUT_H = 0x3b
MPU9250_RA_ACCEL_XOUT_L = 0x3c
MPU9250_RA_ACCEL_YOUT_H = 0x3d
MPU9250_RA_ACCEL_YOUT_L = 0x3e
MPU9250_RA_ACCEL_ZOUT_H = 0x3f
MPU9250_RA_ACCEL_ZOUT_L = 0x40
MPU9250_RA_TEMP_OUT_H = 0x41
MPU9250_RA_TEMP_OUT_L = 0x42
MPU9250_RA_GYRO_XOUT_H = 0x43
MPU9250_RA_GYRO_XOUT_L = 0x44
MPU9250_RA_GYRO_YOUT_H = 0x45
MPU9250_RA_GYRO_YOUT_L = 0x46
MPU9250_RA_GYRO_ZOUT_H = 0x47
MPU9250_RA_GYRO_ZOUT_L = 0x48

MPU9250_RA_PWR_MGMT_1 = 0x6b
MPU9250_RA_PWR_MGMT_2 = 0x6c
MPU9250_RA_WHO_AM_I = 0x75

MPU9250_ACC_SCALE_2G = 0
MPU9250_ACC_SCALE_4G = 1
MPU9250_ACC_SCALE_8G = 2
MPU9250_ACC_SCALE_16G = 3

MPU9250_GYR_SCALE_250DPS = 0
MPU9250_GYR_SCALE_500DPS = 1
MPU9250_GYR_SCALE_1000DPS = 2
MPU9250_GYR_SCALE_2000DPS = 3

MPU9250_PWR1_DEVICE_RESET_BIT = 7

MPU9250_INTCFG_I2C_BYPASS_EN_BIT = 1

-- AK8963
addr_ak8963 = 0x0c

AK8963_RA_CNTL2 = 0x0b


local function mpu_write(reg, value)
    return i2c_helper.write(addr_mpu9250, reg, value)
end

local function ak_write(reg, value)
    return i2c_helper.write(addr_ak8963, reg, value)
end

local function mpu_writebit(reg, position, value)
    return i2c_helper.writebit(addr_mpu9250, reg, position, value)
end

local function ak_writebit(reg, position, value)
    return i2c_helper.writebit(addr_ak8963, reg, position, value)
end

local function mpu_read(reg, len)
    return i2c_helper.read(addr_mpu9250, reg, len)
end

local function ak_read(reg, len)
    return i2c_helper.read(addr_ak8963, reg, len)
end

local function mpu_readbit(reg, position)
    return i2c_helper.readbit(addr_mpu9250, reg, position)
end

local function ak_readbit(reg, position)
    return i2c_helper.readbit(addr_ak8963, reg, position)
end


local function mpu_initialize()
    -- reset MPU9250
    mpu_write(MPU9250_RA_PWR_MGMT_1, bit.lshift(1, MPU9250_PWR1_DEVICE_RESET_BIT))
    tmr.delay(10*1000) -- 10ms

    -- select clock source, enable accelerometer and gyrometer
    mpu_write(MPU9250_RA_PWR_MGMT_1, 0x01)
    mpu_write(MPU9250_RA_PWR_MGMT_2, 0x00)

    -- dummy read
    local me = mpu_read(MPU9250_RA_WHO_AM_I, 1)
    print(string.format("I am %02x", string.byte(me)))

    -- set I²C Bypass for Compass
    mpu_writebit(MPU9250_RA_INT_PIN_CFG, MPU9250_INTCFG_I2C_BYPASS_EN_BIT, true)
    tmr.delay(1000) -- 1ms
end

local function ak_initialize()
    -- reset AK8963
    ak_write(AK8963_RA_CNTL2, 1)
    tmr.delay(1000) -- 1ms
end

local function mpu_acc_config(scale)
    -- set accelerometer resolution
    mpu_writebit(MPU9250_RA_ACCEL_CONFIG, 3, bit.isset(scale, 0))
    mpu_writebit(MPU9250_RA_ACCEL_CONFIG, 4, bit.isset(scale, 1))
end

local function mpu_gyr_config(scale)
    -- set gyrometer resolution
    mpu_writebit(MPU9250_RA_GYRO_CONFIG, 3, bit.isset(scale, 0))
    mpu_writebit(MPU9250_RA_GYRO_CONFIG, 4, bit.isset(scale, 1))
end

function module.initialize()
    mpu_initialize()
    ak_initialize()

    tmr.delay(10*1000)
    i2c_helper.scanbus()

    mpu_acc_config(MPU9250_ACC_SCALE_2G)
    mpu_gyr_config(MPU9250_GYR_SCALE_250DPS)
end

function module.read_acceleration()
    local out = mpu_read(MPU9250_RA_ACCEL_XOUT_H, 6)
    x, y, z = struct.unpack(">i2i2i2", out)
    return x, y, z
end

function module.read_temperature()
    local out = mpu_read(MPU9250_RA_TEMP_OUT_H, 2)
    t = struct.unpack(">i2", out)
    return t
end

function module.read_orientation()
    local out = mpu_read(MPU9250_RA_GYRO_XOUT_H, 6)
    x, y, z = struct.unpack(">i2i2i2", out)
    return x, y, z
end

return module
