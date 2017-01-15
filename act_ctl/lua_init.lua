--lua_init.lua - customer init script
-- Add your functionality here for start initial 


-- LED + Button multiplexer GPIO
LBGI=3  -- GPIO 0    -- Failed to AP connect, blink 3 times
		     -- Failed read senssor, blink 4 times 


gpio.mode(LBGI, gpio.OUTPUT,gpio.PULLUP) 
gpio.write(LBGI, gpio.HIGH) --LED OFF
 
--relay 1 off 
gpio.write(1, gpio.LOW) 