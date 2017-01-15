--[[-------------------
parce_wifi.lua  

 Parsing post payload from index.html and save and compile config file netcfg.lua

Input:	-post payload
 		format payload is  
		wifi_ssid=CITYTERM&wifi_password=****&router_wifi_ssid=***...;
Return: "Save","Reboot"/nil  - succesful/unsuccessful
---]]----------------

local vars=...
--[[
local function valid_ip(instr, is_mask)
   local min, max = 1, 254
   if is_mask then
       min, max = 0, 255
   end
   if instr == nil or instr == "" then return false end
   _, _, ip1s, ip2s, ip3s, ip4s = string.find(instr, "(%d+)%.(%d+)%.(%d+)%.(%d+)")
   if ip1s/1 >= min and ip1s/1 <= max and ip2s/1 >= min and ip2s/1 <= max and 
      ip3s/1 >= min and ip3s/1 <= max and ip4s/1 >= min and ip4s/1 <= max then return true
   end
   return false
end
--]]


    if vars == nil and vars == "" then
        return nil    
    end
local _, _, click =string.find(vars, "click\=([^&]+)")
if click=="Reboot" then  collectgarbage() return click end

--parse index.html post
_, _, wifi_ssid = string.find(vars, "wifi_ssid\=([^&]+)")
wifi_ssid=wifi_ssid or ""
_, _, wifi_password = string.find(vars, "wifi_password\=([^&]+)")
wifi_password=wifi_password or ""
_, _, router_wifi_ssid = string.find(vars, "router_wifi_ssid\=([^&]+)")
router_wifi_ssid=router_wifi_ssid or ""
_, _, router_wifi_password = string.find(vars, "router_wifi_password\=([^&]+)")
router_wifi_password=router_wifi_password or ""

_, _, wifi_ip = string.find(vars, "wifi_ip\=(%d+%.%d+%.%d+%.%d+)")
wifi_ip=wifi_ip or ""
_, _, wifi_nm = string.find(vars, "wifi_nm\=(%d+%.%d+%.%d+%.%d+)")
wifi_nm=wifi_nm or ""
_, _, wifi_gw = string.find(vars, "wifi_gw\=(%d+%.%d+%.%d+%.%d+)")
wifi_gw=wifi_gw or ""
_, _, wifi_dhcp_start = string.find(vars, "wifi_dhcp_start\=(%d+%.%d+%.%d+%.%d+)")
wifi_dhcp_start=wifi_dhcp_start or ""

_, _, postinterval =string.find(vars, "postinterval\=(%d+)") 
_, _, iot_url =string.find(vars, "iot_url\=([^&]+)")	
iot_url=urldecode((iot_url or ""))

_, _, iot_channelid =string.find(vars, "iot_channelid\=(%d+)")
iot_channelid=iot_channelid or ""
_, _, iot_writeapikey =string.find(vars, "iot_writeapikey\=([^&]+)")
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
 --[[
	if not valid_ip(wifi_dhcp_start, false) then
	   wifi_dhcp_start = ""
	end
	
    if not valid_ip(wifi_ip, false) and not valid_ip(wifi_nm, true) and not valid_ip(wifi_gw, false) then
        wifi_ip = ""
        wifi_nm = ""
        wifi_gw = ""
    -- Request all network details again if one or more of them are not valid
    elseif not valid_ip(wifi_ip, false) or not valid_ip(wifi_nm, true) or not valid_ip(wifi_gw, false)  then
	   print("Network details are not valid!")
	return nil
    end
	
 --]]  
--    print("New WiFi credentials received")
--    print("-----------------------------")
--    print("wifi_ssid     : " .. wifi_ssid)
--    print("wifi_password : " .. wifi_password)
--    print("wifi_ip : " .. wifi_ip)
--    print("wifi_nm : " .. wifi_nm)
--    print("wifi_gw : " .. wifi_gw)
--    print("wifi_dhcp_start : " .. wifi_dhcp_start)
--    print("router_wifi_ssid     : " .. router_wifi_ssid)
--    print("router_wifi_password : " .. router_wifi_password)
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
    file.writeline("wifi_ip='"..wifi_ip.."'")
    file.writeline("wifi_nm='"..wifi_nm.."'")
    file.writeline("wifi_gw='"..wifi_gw.."'")
    file.writeline("wifi_dhcp_start='"..wifi_dhcp_start.."'")
    file.writeline("router_wifi_ssid='"..router_wifi_ssid.."'")
    file.writeline("router_wifi_password='"..router_wifi_password.."'")

    file.writeline("postinterval='"..postinterval.."'")
    file.writeline("iot_url='"..urldecode(iot_url).."'")
    file.writeline("iot_channelid='"..iot_channelid.."'")
    file.writeline("iot_writeapikey='"..iot_writeapikey.."'")

    file.flush()
    file.close()
    node.compile(netcfg..".lua")
    file.remove(netcfg..".lua")
    
    --save setup flag
     file.open("setup.flag", "w+")
     file.writeline("") 
     file.flush()
     file.close() 
     
     if file.open(netcfg..".lc", "r") then
        file.close()
--    	display(function()
--			     disp:drawStr(0, 0, netcfg..".lc")
--			     disp:drawStr(0, 12,"Save OK!")			     
--			     end)
		result=click	       		
	else	
--    	display(function()
--			     disp:drawStr(0, 0, netcfg..".lc")
--			     disp:drawStr(0, 12,"Save Failed!")			     
--			     end)
		result=nil	       
    end	
--    collectgarbage()
    return result
