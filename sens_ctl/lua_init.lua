----lua_init.lua - customer init script
-- Add your functionality here for initial 
--
-- LED + Button multiplexer GPIO
LBGI=3  -- GPIO 0    -- Failed to AP connect, blink 3 times
		     -- Failed read senssor, blink 4 times 
SR4_DIST=0 --sr4 measurement



gpio.mode(LBGI, gpio.OUTPUT,gpio.PULLUP) 
 --gpio.write(LBGI, gpio.LOW) --LED ON
 
--init dht sensor
dht_11timer = tmr.create()
dht_11= require("dht11") 
dht_11.init(5,dht_11timer)  -- pin=5(GPIO 14)

--init SR04 sensor 
sr4_timer = tmr.create()
sr04 = require("sr04")
sr04.init(7, 6,sr4_timer,1000)   -- Every 1 sec. trig_pin=7(GPIO 13),echo_pin=6(GPIO12)
--sr04.get_distance(function(distance) DIST=distance end) 

sr04.poll_distance(function(distance) SR4_DIST=distance end)  -- Read distance periodically in background.
 
