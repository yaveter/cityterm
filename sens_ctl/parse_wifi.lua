--[[-------------------
parce_wifi.lua  

 Parsing post payload from index.html and save and compile config file netcfg.lua

Input:	-post payload
 		format payload is  
		wifi_ssid=CITYTERM&wifi_password=****&router_wifi_ssid=***...;
Return: "Save","Reboot"/nil  - succesful/unsuccessful
---]]----------------

local vars=...

    if vars == nil and vars == "" then
        return nil    
    end
local _, _, click =string.find(vars, "click\=([^&]+)")
if click=="Reboot" then  collectgarbage() return click end

--parse index.html post
    local _, _, wifi_ssid = string.find(vars, "wifi_ssid\=([^&]+)")
	wifi_ssid=wifi_ssid or ""
    local _, _, wifi_password = string.find(vars, "wifi_password\=([^&]+)")
    wifi_password=wifi_password or ""	
    local _, _, postinterval =string.find(vars, "postinterval\=(%d+)") 
    local _, _, iot_url =string.find(vars, "iot_url\=([^&]+)")	
    iot_url=iot_url or ""
    local _, _, iot_channelid =string.find(vars, "iot_channelid\=(%d+)")
    iot_channelid=iot_channelid or ""
    local _, _, iot_writeapikey =string.find(vars, "iot_writeapikey\=([^&]+)")
    iot_writeapikey=iot_writeapikey or ""
	
    
    

    if postinterval ==nil then
      postinterval=15*60   --15 min default sleep interval
    else
      postinterval=tonumber(postinterval)
     if postinterval>60*60 or postinterval<=0 then
        postinterval=15*60   --15 min default sleep interval
     end
    end  
	
    if  wifi_ssid == "" or wifi_password == "" then
        return nil
    end
   
--    print("New WiFi credentials received")
--    print("-----------------------------")
--    print("wifi_ssid     : " .. wifi_ssid)
--    print("wifi_password : " .. wifi_password)
--    print("postinterval : " .. postinterval)
--    print("iot_url : " .. urldecode(iot_url))
--    print("iot_channelid : " .. iot_channelid)
--    print("iot_writeapikey : " .. iot_writeapikey)

local netcfg="netcfg"

--save and compile netcfg.lua
    if file.open(netcfg..".lc", "r") then
        file.close()
        file.remove(netcfg..".lc")
    end

    file.open(netcfg..".lua", "w+")
    file.writeline("wifi_ssid='"..wifi_ssid.."'")
    file.writeline("wifi_password='"..wifi_password.."'")

    file.writeline("postinterval='"..postinterval.."'")
    file.writeline("iot_url='"..urldecode(iot_url).."'")
    file.writeline("iot_channelid='"..iot_channelid.."'")
    file.writeline("iot_writeapikey='"..iot_writeapikey.."'")

    file.flush()
    file.close()
    node.compile(netcfg..".lua")
    --file.remove(netcfg..".lua")
	
	--save setup flag
    file.open("setup.flag", "w+")
    file.writeline("") 
    file.flush()
    file.close() 
	
    if file.open(netcfg..".lc", "r") then
        file.close()
    	result=click	       		
	else	
		result=nil	       
    end	
    collectgarbage()
    return result
