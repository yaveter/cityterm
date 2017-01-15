--[[-------------------
post_iot.lua  - post senssors values to IOT system 

Input: sensors data - fieldslist={name={},value={}} 
Return: none
---]]----------------
local fieldslist=...
local cnt=#fieldslist.name
local requeststr=""
local connout = nil
local host=string.match(iot_url, "http.-//(.-)/")
local url=string.match(iot_url,"http.+/.+/(.+)")
local Message=false,""
print("post_iot")
print("-------------")
print("host="..host)
print("url="..url)


for i=1,cnt do 
	requeststr=requeststr.."&"..fieldslist.name[i].."="..(fieldslist.value[i] or "")
end

connout = net.createConnection(net.TCP, 0)   
    connout:on("receive", function(connout, payloadout)		
        if (string.find(payloadout, "HTTP/1.1 200 OK") ~= nil) then
			Message="Posted IOT - OK"
			print(Message)	
		elseif (string.find(payloadout, "HTTP/1.1 400 Bad Request\r\n") ~= nil) then
			Message="Post IOT Status: 400 Bad Request"
			print(Message)				
		end
    end)
 
    connout:on("connection", function(connout, payloadout)        			 
		requeststr="POST /"..url.."?api_key="..iot_writeapikey..requeststr
			.. " HTTP/1.1\r\n"
			.. "Host: "..host.."\r\n"
			.. "Connection: close\r\n"
			.. "Accept: */*\r\n"
			.. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
			.. "\r\n"
		--print(requeststr)
		connout:send(requeststr)       
    end)
 

    connout:on("disconnection", function(connout, payloadout)
        --print ("disconnect...");
		connout:close();
        collectgarbage();
    end)

connout:connect(80,host)



