--[[-------------------
post_iot.lua  - post senssors values to IOT system 

Input: sensors data - fieldslist={name={},value={}} 
Return: none
---]]----------------
local fieldlist=...
local requeststr=""
local connout = nil
local hoststr=string.match(iot_url, "http.-//(.-)/")
local url=string.match(iot_url,"http.+/.+/(.+)")
local Responce,Message=false,""
local cnt=#fieldlist.name
for i=1,cnt do 
	requeststr=requeststr.."&"..fieldlist.name[i].."="..(fieldlist.value[i] or "")
end
connout = net.createConnection(net.TCP, 0)   
    connout:on("receive", function(connout, payloadout)
       if (string.find(payloadout, "HTTP/1.1 200 OK") ~= nil) then
			Message="Posted IOT - OK"
			Responce=true;
			print(Message)	
		elseif (string.find(payloadout, "HTTP/1.1 400 Bad Request\r\n") ~= nil) then
			Message="Post IOT Status: 400 Bad Request"
			Responce=false;	
			print(Message)				
		end
	end)
 
    connout:on("connection", function(connout, payloadout)
		--gpio.serout(LBGI,gpio.LOW,{50000,50000},1,1)   
		print(iot_writeapikey)
		print(requeststr)
		print(hoststr)
		local req="POST /"..url
		.. " HTTP/1.1\r\n"
		.. "Host: "..hoststr.."\r\n"
		.. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n"
        .. "api_key="..iot_writeapikey..requeststr
		print(req)
		connout:send(req)       
    end)
 

    connout:on("disconnection", function(connout, payloadout)
        --print ("disconnect...");
		connout:close();
        collectgarbage();
    end)

connout:connect(80,hoststr)


