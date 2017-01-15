-- I2C IO indexes (not GPIO numbers! Look up into GPIO map!)
SDA = 2 -- sda pin, GPIO4
SCL = 5 -- scl pin, GPIO5
SLA= 0x3c
disp=nil -- oled display

function print_setup()
   print("WiFi credentials:")
    print("-----------------------------")
    print("wifi_ssid     : " .. (wifi_ssid or ""))
    print("wifi_password : " .. (wifi_password or ""))
    print("wifi_ip : " .. (wifi_ip or ""))
    print("wifi_nm : " .. (wifi_nm or ""))
    print("wifi_gw : " .. (wifi_gw or ""))
    print("wifi_dhcp_start : " .. (wifi_dhcp_start or ""))
    print("router_wifi_ssid     : " .. (router_wifi_ssid or ""))
    print("router_wifi_password : " .. (router_wifi_password or ""))
    print("postinterval : " .. (postinterval or ""))
    print("iot_url : " .. (iot_url or ""))
    print("iot_channelid : " .. (iot_channelid or ""))
    print("iot_writeapikey : " .. (iot_writeapikey or ""))

    print("\n\rParameters: ")
    print("-----------------------------")
    print("parameter1 : " .. (parameter1 or ""))
    print("parameter2 : " .. (parameter2 or ""))
    print("parameter3 : " .. (parameter3 or ""))
	print("parameter4 : " .. (parameter4 or ""))
	print("parameter5 : " .. (parameter5 or ""))
	print("lua_init_script : " .. (lua_init_script or ""))
	print("lua_script : " .. (lua_script or ""))
	print("lua_commands : " .. (lua_commands or ""))
	
end

function run_setup()
    gpio.write(LBGI, gpio.LOW)
    wifi.sta.disconnect()
    
    wifi.setmode(wifi.SOFTAP)
   
    local cfg={}
	-- Set your own AP prefix. SHM = Smart Home Module.
    local cid=node.chipid()
    cfg.ssid="CITYTERM"..cid
    cfg.pwd="cityterm123456"
    cfg.auth=wifi.WPA2_PSK
    --cfg.channel=10
    wifi.ap.config(cfg)
    print("Opening WiFi credentials portal")    
    assert(loadfile("server_setup.lc"))(cfg.ssid,cfg.pwd)
--     assert(loadfile("server_fm.lc"))(cfg.ssid,cfg.pwd)

end

function read_wifi_credentials()
    if file.open("netcfg.lc", "r") then
        dofile('netcfg.lc')
        file.close()
    end

    if wifi_ssid ~= nil and wifi_ssid ~= "" and wifi_password ~= nil then
        return wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw,wifi_dhcp_start,router_wifi_ssid,router_wifi_password
    end
    return nil, nil, nil, nil, nil, nil, nil,nil
end

function read_parameters()
    if file.open("paramcfg.lc", "r") then
        dofile('paramcfg.lc')
        file.close()
    end

	if lua_init_script and file.open(lua_init_script, "r") then
		file.close()
	else
		lua_init_script=nil
	end 
	
	if lua_script and file.open(lua_script, "r") then
        file.close()
	else
		lua_script=nil
    end 
	
    if lua_commands and file.open(lua_commands, "r") then
        file.close()
	else
		lua_commands=nil
    end  
end


function try_connecting(wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw,wifi_dhcp_start,router_wifi_ssid,router_wifi_password)
gpio.write(LBGI, gpio.HIGH)
wifi.sta.disconnect()
wifi.setmode(wifi.NULLMODE)
wifi.setmode(wifi.STATIONAP)
if wifi_ip~=nil and wifi_ip~="" then
local dnscfg = {}
	dnscfg.ip=wifi_ip
	dnscfg.netmask=wifi_nm
	dnscfg.gateway=wifi_gw
	wifi.ap.setip(dnscfg)
       dnscfg=nil
end
if wifi_dhcp_start~=nil and wifi_dhcp_start~="" then
local dhcp_config ={}
dhcp_config.start = wifi_dhcp_start
wifi.ap.dhcp.config(dhcp_config)
wifi.ap.dhcp.start()
--wifi.ap.dhcp.stop()
dhcp_config=nil
end

local cfg={}
cfg.ssid=wifi_ssid
cfg.pwd=wifi_password
--cfg.save=true
wifi.ap.config(cfg)
cfg=nil
if router_wifi_ssid~=nil and router_wifi_ssid~="" then
	wifi.sta.config(router_wifi_ssid, router_wifi_password)
	wifi.sta.connect()
	wifi.sta.autoconnect(1)
	local attempt=1
	tmr.alarm(0, 2000, 1, function()
		if  attempt<6 then 
			if wifi.sta.status() ~= 5 then
					print("Connecting to AP...")
			else				
					tmr.stop(0)
					print("Connected as: " .. wifi.sta.getip())
					collectgarbage()
					tmr.unregister(0)
					assert(loadfile("server.lc"))(wifi_ssid,wifi_password)
		       end
		else
			tmr.stop(0)
			print("Failed to connect to \"" .. router_wifi_ssid .. "\".")
			print("Run server without "  .. router_wifi_ssid)
			collectgarbage()
			tmr.unregister(0)
			assert(loadfile("server.lc"))(wifi_ssid,wifi_password)
		end
	end)
else
	print("Router undefined...")
	assert(loadfile("server.lc"))(wifi_ssid,wifi_password)

end   
end

local function prepare_display()
    disp:setFont(u8g.font_unifont_0_8)
    disp:setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
    disp:undoScale()
end
function display(t)
if disp then
 disp:firstPage()
 repeat 
       t()
 until disp:nextPage() == false
end
end
-------------------------
------  MAIN  -----------
-------------------------
local setupflag
wifi.sta.disconnect()
wifi.setmode(wifi.NULLMODE)
dofile("button_setup.lc")  -- uses timer #5
if file.open("setup.flag", "r") then
	 setupflag=true
	file.close()
else	
	 setupflag=nil
end
wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw,wifi_dhcp_start,router_wifi_ssid,router_wifi_password = read_wifi_credentials()
read_parameters()
 
i2c.setup(0, SDA, SCL, i2c.SLOW)
disp = u8g.ssd1306_128x64_i2c(SLA)
prepare_display()  
display(function() disp:drawStr(0, 0, "") end)

if lua_init_script and lua_init_script~="" then
	--run customer init script
	local result,message=pcall(assert(loadfile(lua_init_script)))	
	if result==false then
		print("Error in "..lua_init_script..":"..message)
	end
end	

if setupflag and wifi_ssid ~= nil and wifi_password ~= nil then    
   print_setup()
    try_connecting(wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw,wifi_dhcp_start,router_wifi_ssid,router_wifi_password)
else
    run_setup()
end

