-- Distance measure module for SR04 / SR04T ultrasonic sensor.
-- Single measure or polling is available from 20cm to ~5m.
--
-- Example 1: Read distance once.
--      sr04 = require("sr04")
--      sr04.init(trig_pin, echo_pin,timer_id, sample_interval)  -- GPIO 0,2.
--      sr04.get_distance(function(distance) print(distance) end)
--      sr04 = nil
--      package.loaded["sr04"] = nil
--
-- Example 2: Read/print distance periodically
--      sr04 = require("sr04")
--      sr04.init(trig_pin, echo_pin,timer_id, sample_interval)  -- Every 2 sec. GPIO 0,2.
--      sr04.poll_distance(function(distance) print(distance))  -- Poll in background.
--      -- Do something here, don't tmr.delay!
--      sr04.stop_poll()      -- Enough polling.
--      sr04 = nil
--      package.loaded["sr04"] = nil
--
-- Author: iGrowing
-- License: MIT
--

local moduleName = ...
local M = {}
_G[moduleName] = M 
        
local TID = 0
local SAMPLE_INTERVAL = 150
local TRIG_PIN = 1  -- gpio 5
local ECHO_PIN = 2  -- gpio 4
local _start = 0
local _end = 0
local iterator=0

function M.init(trig_pin, echo_pin,timer_id, sample_interval)
-- Set longer sample_interval (1000 or more) for continuous polling --
    -- Initialize
    TID = timer_id or TID
    SAMPLE_INTERVAL = sample_interval or SAMPLE_INTERVAL
    TRIG_PIN = trig_pin or TRIG_PIN  -- gpio 5
    ECHO_PIN = echo_pin or ECHO_PIN  -- gpio 4

    gpio.mode(TRIG_PIN, gpio.OUTPUT)
    gpio.mode(ECHO_PIN, gpio.INPUT)
    gpio.mode(ECHO_PIN, gpio.INT)
    gpio.write(TRIG_PIN, gpio.LOW)
    
    function _trig_cb(level)  -- Internal function
        -- Register in variables the echo start/stop timestamps
        if level == gpio.HIGH then 
            _start = tmr.now() 
            gpio.trig(ECHO_PIN, "down")
            
        else 
            _end = tmr.now() 
             gpio.trig(ECHO_PIN,"none") --exlude bounce
        end
    end    
end

local function _trig()  -- Internal function
    -- Trigger the measure
    gpio.trig(ECHO_PIN, "up", _trig_cb)
    gpio.write(TRIG_PIN, gpio.HIGH)
    tmr.delay(10)
    gpio.write(TRIG_PIN, gpio.LOW)
    
end

local function _calc()  -- Internal function
    local d = _end - _start
    -- print("_start=".._start)
   -- print("_end=".._end)
   -- print("d="..d)
    if d > 58 and d < 30000 then -- ~5m max distance
        _end = 0  -- Disable wrong calculation on next attempt.
        return math.floor(d/58) 
    else 
        return -1
    end
end

function M.poll_distance(callback)
---  Read and print distance periodically by SAMPLE_INTERVAL.  ---
-- TODO: Rewrite the print with callback: True value comes with SAMPLE_INTERVAL delay.
    tmr.alarm(TID, SAMPLE_INTERVAL/2, 1, function()         
        if  iterator==0 then  
           _trig() 
           iterator=iterator+1
        else   
           local d = _calc()            
            callback(d) 
            iterator=0     
        end 
    end)
end

function M.stop_poll()
---  Stop distance polling. Clean.  ---
    tmr.stop(TID)
    tmr.unregister(TID)
    collectgarbage()
end


function M.get_distance(callback)
---  Read distance, return value in cm or -1.  ---
tmr.alarm(TID, 30, 1, function()         
        if  iterator==0 then  
           _trig() 
           iterator=iterator+1
        else   
           local d = _calc() 
            M.stop_poll()           
            callback(d) 
            iterator=0 
       end 
    end)
end
return M 
