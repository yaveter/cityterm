# cityterm
System automation smart home based ESP8266

ACT_CTL - control module, HTTP - server (REST), file manager

SENS_CTL - Sensor Module

ACT_CTL gets data from the sensor module and the user launches the script lua_script.lua.

Custom scripts:

  	lua_script.lua- a custom script to perform the control logic
	lua_init.lua - user initialization before starting http -server
	lua_сommands.lua - a custom script to handle the requests and commands for REST api
	lua_measure.lua - a custom script to perform the measurement sensors
