--[[-------------------
server_setup.lua  
HTTP:80 server for initial setting and setuping

url=index.html, parameters.html"

Input: default cfg_ssid, cfg_pwd
Return: none
---]]----------------

local cfg_ssid,cfg_pwd=...


-----------------------
--  Run timer for timeout in case no one was connected
function run_timeout()
----------------------
    tmr.unregister(0)
	tmr.alarm(0, 15 * 60 * 1000, 0, function() node.restart() end)
end
--------------------------
-- Transform encoded characters into readable symbols
function urldecode(instr)
-------------------------

  instr = instr:gsub('+', ' ') -- replace + with space
       :gsub('%%(%x%x)', function(h) -- replace non-alphabets with symbols
                           return string.char(tonumber(h, 16))
                         end)
  return instr
end
--------------------------------------------
function listen_setup(conn) 
----------------------------------------
local responseBytes = 0
local method=""
local url=""
local vars=""
local StatusUpload=false
local content_type="Content-Type:  text/html; charset=utf-8\r\n"
------------'on receive'-------------------
conn:on("receive",function(conn, payload) 
-----------------------------------------
--parse payload
 _, _, method, url, vars = string.find(payload, "([A-Z]+) /([^?]*)%??(.*) HTTP")
if method == nil then
		print("Received garbage via HTTP.")
		return
end

vars=vars or ""
url=url or ""
method=string.lower(method)

print("Heap   : " .. node.heap())
  print("Payload: " .. payload)
print("Method : " .. method)
print("URL    : " .. url)

--if url without index.html	
if url==nil or url=="" then 
      url="index.html"
end

	
-- Get the vars from POST: data is not passed in address.
if method == "post" and  url=="index.html" then
	_, _, vars = string.find(payload, "(wifi_ssid.*)")
	if vars~=nil then
		--parse index.html post
		local res=assert(loadfile("parse_wifi.lc"))(vars)
		if not res then   
			print( "error parse index.html post")
			return   --error parse index.html post
		else  
			--parse - OK!save and compile netcfg.lua - OK! 
			print("parse - OK!Save and compile netcfg.lua - OK!")				
			dofile("netcfg.lc") 
			if res =="Reboot" then
			     conn:send("HTTP/1.1 200 OK\r\n\r\n<!doctype html>\r\n<html>\r\n<head>\r\n</head>\r\n<body>\r\nRebooting node...\r\n</body>\r\n</html>\r\n")
				--reboot timeuot 5 sec.
			    print("reboot timeuot 1 sec.")
				tmr.alarm(2, 3000, 0, function() node.restart() end)  
			end	
		end
		
	end	
elseif method=="post" and  url=="parameters.html" then
		--parse parameters.html post
		if not assert(loadfile("parse_param.lc"))(payload) then   
			print("error parse parameters.html post")
			return  --error parse parameters.html post
		else
			dofile("paramcfg.lc")
		end	
		
end
   
if url~=nil and url~=""  then
	if file.open(url, "r")then
		file.close()
	else			
		--illegal url
		print(url.." 404 Not Found")
        conn:send("HTTP/1.1 404 Not Found\r\n\r\n<!doctype html>\r\n<html>\r\n<head>\r\n</head>\r\n<body>\r\n404 File not found.\r\n</body>\r\n</html>\r\n")
        responseBytes = -1
		collectgarbage()
        return
    end   
end  
--response OK, send 200   
responseBytes = 0
print("send 200") 
conn:send("HTTP/1.1 200 OK\r\n"..content_type.."\r\n")  
collectgarbage()
end) --end 'on receive'

-----------on send--------------------  
conn:on("sent",function(conn) 
-----------------------------------
-- Restart the timout timer, let user to enter the data.
run_timeout()
if responseBytes>=0 and (url=="index.html" or url=="parameters.html" ) then
	--read(as plain file)   
	if file.open(url, "r") then
		file.seek("set", responseBytes)
		--read next line
		local line=file.readline() 
		file.close()
        if line then			
			responseBytes=responseBytes+string.len(line) 			
			if url=="index.html" then
				--insert values in index.html
				-- Update the data to send with unit identifier
				holder = "generic_and_very_long_place_holder_keep_even_more"
				ident = node.chipid()
				ident=(string.sub(ident, 1, string.len(holder)))
				line=(string.gsub(line, holder, ident))				
				if  wifi_ssid~=nil then  line=(string.gsub(line, "placeholder='WiFi Name'", "value='"..wifi_ssid.."'")) end
				if  wifi_password~=nil then  line=(string.gsub(line, "placeholder='WiFi Password'", "value='"..wifi_password.."'")) end
				if  iot_url~=nil then  line=(string.gsub(line, "placeholder='IOT_URL'", "value='"..(iot_url or "").."'"))  end  
				if  iot_channelid~=nil then line=(string.gsub(line, "placeholder='IOT_ChannelId'", "value='"..(iot_channelid or "").."'"))  end 
				if  iot_writeapikey~=nil then line=(string.gsub(line, "placeholder='IOT_WriteAPIKey'", "value='"..(iot_writeapikey or "").."'")) end 
				if  postinterval~=nil then  line=(string.gsub(line, "placeholder='Post Interval'", "value='"..(postinterval or "").."'")) end
			elseif url=="parameters.html" then
				--insert values in parameters.html
				if  lua_init_script~=nil then  line=(string.gsub(line, "placeholder='lua_init_script'", "value='"..(lua_init_script or "").."'")) end
				if  lua_measure~=nil then  line=(string.gsub(line, "placeholder='lua_measure'", "value='"..(lua_measure or "").."'")) end					
			end
				--print("line="..line)	
                conn:send(line) 
			return               
        end
    end 
end
    responseBytes=-1 
    ident, holder,line = nil, nil,nil -- clean memory  
    collectgarbage() 
   conn:close()
  end)
end


--  Run the HTTP server
srv=net.createServer(net.TCP,1) 
srv:listen(80, listen_setup)


print("HTTP:80 Server Setup Started")
local ip=wifi.ap.getip()
print(ip)
print(cfg_ssid,cfg_pwd)



