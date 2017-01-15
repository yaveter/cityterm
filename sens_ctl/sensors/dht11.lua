-- temperature & Humidity measure module for dht11/dht22 sensor.

-- Example 1: Read dht once.
--      dht11= require("dht11")
--      dht11.init(4,2)  -- pin=4(GPIO 2),timer_id=2.
--      dht11.get_dht(function(ok,temp, humi) if ok ==0 then print("temp="..temp,"humi=".. humi)end end)
--      dht11= nil
--      package.loaded["dht11"] = nil
--
-- Example 2: Read/print dht periodically
--      dht11= require("dht11")
--      dht11.init(4,2,2000)  -- pin=4(GPIO 2),timer_id=2, sample_interval=2000.
--      dht11.poll_dht(function(ok,temp, humi) if ok ==0 then print("temp="..temp,"humi=".. humi)end end)  -- Poll in background.
--      -- Do something here, don't tmr.delay!
--      dht11.stop_poll()      -- Enough polling.
--      dht11 = nil
--      package.loaded["dht11"] = nil

---- Example 3: Read dht once.
--      dht11= require("dht11")
--      dht11.init(4,2)  -- pin=4(GPIO 2),timer_id=2.
--     local status, temp, humi, temp_dec, humi_dec 
--    status, temp, humi, temp_dec, humi_dec = print(dht11.read_dht())
 --   if  status == dht.OK then  print("temp="..temp.." humi="..humi)  end  
--     dht11 = nil
--      package.loaded["dht11"] = nil
local moduleName = ...
local M = {}
_G[moduleName] = M 

local TID = 2        
local PIN = 4 -- gpio 2
local SAMPLE_INTERVAL = 150


function M.init(pin,timer_id,sample_interval)
    -- Initialize
    SAMPLE_INTERVAL = sample_interval or SAMPLE_INTERVAL
    PIN = pin or PIN  
    TID = timer_id or TID
end

--[[
function M.poll_dht(callback)
---  Read indication periodically by SAMPLE_INTERVAL.  ---
local status, temp, humi, temp_dec, humi_dec ,ok
    tmr.alarm(TID, SAMPLE_INTERVAL, 1, function()         
       status, temp, humi, temp_dec, humi_dec = dht.read(PIN)
       if status == dht.OK then
          ok=0  --ok
       elseif status == dht.ERROR_CHECKSUM then
         ok= -1   -- print( "DHT Checksum error." )
       elseif status == dht.ERROR_TIMEOUT then
         ok= -2 --print( "DHT timed out." )
       end
       callback(ok,temp, humi, temp_dec, humi_dec)
    end)
end

function M.stop_poll()
---  Stop distance polling. Clean.  ---
    tmr.stop(TID)
    tmr.unregister(TID)
    collectgarbage()
end

function M.get_dht(callback)
---  Read dht --- 
local status, temp, humi, temp_dec, humi_dec ,ok
    tmr.stop(TID)
    tmr.alarm(TID, SAMPLE_INTERVAL, tmr.ALARM_SINGLE, function()         
       status, temp, humi, temp_dec, humi_dec = dht.read(PIN)
       if status == dht.OK then
          ok=0  --ok
       elseif status == dht.ERROR_CHECKSUM then
         ok= -1   -- print( "DHT Checksum error." )
       elseif status == dht.ERROR_TIMEOUT then
         ok= -2 --print( "DHT timed out." )
       end
       callback(ok,temp, humi, temp_dec, humi_dec)
    end)
end
]]

function M.read_dht()
local status, temp, humi, temp_dec, humi_dec ,ok
 status, temp, humi, temp_dec, humi_dec = dht.read(PIN)
       if status == dht.OK then
          ok=0  --ok
       elseif status == dht.ERROR_CHECKSUM then
         ok= -1   -- print( "DHT Checksum error." )
       elseif status == dht.ERROR_TIMEOUT then
         ok= -2 --print( "DHT timed out." )
       end

 return ok,temp, humi
end

return M 
