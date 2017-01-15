-- OPTIONAL SETTINGS
-- I2C IO indexes (not GPIO numbers! Look up into GPIO map!)
--SDA = 2 -- sda pin, GPIO4
--SCL = 5 -- scl pin, GPIO5
--SLA= 0x3c

-----------------------------------
function print_setup()
----------------------------------
   print("WiFi credentials:")
    print("-----------------------------")
    print("wifi_ssid     : " .. (wifi_ssid or ""))
    print("wifi_password : " .. (wifi_password or ""))
    print("postinterval : " .. (postinterval or ""))
    print("iot_url : " .. (iot_url or ""))
    print("iot_channelid : " .. (iot_channelid or ""))
    print("iot_writeapikey : " .. (iot_writeapikey or ""))

    print("\n\rParameters: ")
    print("-----------------------------")
	if lua_init_script then
        print("lua_init_script : " .. lua_init_script)
    end
	if lua_measure then
        print("lua_measure : " .. lua_measure)
    end
	
end
----------------------------------
function run_setup()
---------------------------------
    gpio.write(LBGI, gpio.LOW)
    wifi.sta.disconnect()
    
    wifi.setmode(wifi.SOFTAP)
   
    local cfg={}
	-- Set your own AP prefix. SHM = Smart Home Module.
    local cid=node.chipid()
    cfg.ssid="CITYTERM"..cid
    cfg.pwd="cityterm123456"
    cfg.auth=wifi.WPA2_PSK
    cfg.save=false
 
--    local ipcfg={}
--    ipcfg.ip="192.168.4.2"
--    ipcfg.netmask="255.255.255.0"
--    ipcfg.gateway="192.168.4.2"
--    wifi.ap.setip(ipcfg)
    
    --cfg.channel=10
    wifi.ap.config(cfg)
     tmr.alarm(1, 1000, 0, function()
	    print("Opening WiFi credentials portal")    
	    assert(loadfile("server_setup.lc"))(cfg.ssid,cfg.pwd)
    end)
end
------------------------------------------------
function read_wifi_credentials()
------------------------------------------------
    if file.open("netcfg.lc", "r") then
        dofile('netcfg.lc')
        file.close()
    end

    if wifi_ssid ~= nil and wifi_ssid ~= "" and wifi_password ~= nil then
        return wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw,wifi_dhcp_start,router_wifi_ssid,router_wifi_password
    end
    return nil, nil, nil, nil, nil, nil, nil,nil
end
------------------------------------------
function read_parameters()
-------------------------------------------
    if file.open("paramcfg.lc", "r") then
        dofile('paramcfg.lc')
        file.close()
    end
	if lua_init_script and file.open(lua_init_script, "r") then
        file.close()
	else
		lua_init_script=nil
    end    
    if lua_measure and file.open(lua_measure, "r") then
        file.close()
	else
		lua_measure=nil
    end  
end


-----------------------------------------------
function enter_sleep(interval) 
----------------------------------------------
  wifi.sta.disconnect()
  wifi.nullmodesleep(true)
  wifi.setmode(wifi.NULLMODE) 
  tmr.alarm(6, 100, 1,function()
	if (wifi.getmode()==0) then
		tmr.stop(6)
		tmr.unregister(6)
		node.dsleep(interval,0)
	end
  end)
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function try_connecting(wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw,wifi_dhcp_start,router_wifi_ssid,router_wifi_password)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gpio.write(LBGI, gpio.HIGH)
   -- wifi.sta.disconnect()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(wifi_ssid, wifi_password)
    wifi.sta.connect()
    --wifi.sta.autoconnect(1)

    tmr.alarm(0, 2000, 1, function()
        if wifi.sta.status() ~= 5 then
			print("Connecting to AP...")
        else
			tmr.stop(1)
			tmr.stop(0)
			print("Connected as: " .. wifi.sta.getip())
			collectgarbage()
			tmr.unregister(0)
			tmr.unregister(1)
			
		 -- TODO: Add your functionality here to do AFTER connection established.
			if lua_measure and lua_measure~="" then
				----run customer senssors measure script  
				local status,result=pcall(assert(loadfile(lua_measure)))	
				if status==false then
					print("Error in "..lua_measure..":"..result)
				end	
				-- post data in IOT
				assert(loadfile("post_iot.lc"))(result)
			end	
			 tmr.alarm(0, 3000, 0, function() enter_sleep(postinterval  * 1000 * 1000) end)				        	
       end
    end)

    tmr.alarm(1, 15000, 0, function()
        -- Sleep (save power until WiFi gets back),         
        if wifi.sta.status() ~= 5 then
            tmr.stop(0)
            tmr.unregister(0)
            print("Failed to connect to \"" .. wifi_ssid .. "\".")
                print("Sleep 1 min + retry...")
                print("Press the button 5 seconds on the next boot to enter WiFi configuration captive mode.")
                -- No sense to run setup if the settings present. Sleep and retry.  
                -- Failed to AP connect, blink 3 times and  1 min sleep            
              gpio.serout(LBGI,1,{300000,300000},3, enter_sleep(1 * 60 * 1000 * 1000))                              

        end
    end)
end

-------------------------
------  MAIN  -----------
-------------------------
local setupflag

dofile("button_setup.lc")  -- uses timer #5
if file.open("setup.flag", "r") then
	 setupflag=true
	file.close()
else	
	 setupflag=nil
end
wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw,wifi_dhcp_start,router_wifi_ssid,router_wifi_password = read_wifi_credentials()
read_parameters()

-- TODO: Add your functionality here to do BEFORE connection established.
if lua_init_script and lua_init_script~="" then
	--run customer init script
	local result,message=pcall(assert(loadfile(lua_init_script)))
	if result==false then
		print("Error in "..lua_init_script..":"..message)
	else
		print("Run "..lua_init_script)
	end	
end	
  
if setupflag and wifi_ssid ~= nil and wifi_password ~= nil then    
   print_setup()
    try_connecting(wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw,wifi_dhcp_start,router_wifi_ssid,router_wifi_password)
   
else
    run_setup()
end

