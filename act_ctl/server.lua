--[[-------------------
server.lua  
REST HTTP:80 server and actuator

rest api update senssors value
url=https://192.168.4.1/update?api_key=21321444&field1=10&field1=20&field2=20...  

rest api commands
url=https://192.168.4.1/commands?api_key=21321444&field1=10&command_string1=OFF&command_string2=ON...  

JSON responce 
{"Response":0,"Message":["OK","command respond message"]} - successful
{"Response":-1,"Message":"Error message"} - unsuccessful


Input: None
Return: none
---]]----------------


------------------------------
--Search value by name in table kind fieldslist={name={},value={}} 
function search_name(t, name)
------------------------------
  for k, v in ipairs(t.name) do
    if v == name then return t.value[k] end
  end
  return nil
end


--  Run the server
srv=net.createServer(net.TCP,1) 
srv:listen(80, function(conn) 
  

local responseBytes = 0
local method=""
local url=""
local vars=""
local StatusUpload=false
local dynamic_html=nil
local filelist,fileindex=nil,nil
local filelistsort={}
---------------on receive-------------------------
conn:on("receive",function(conn, payload)
-----------------------------------------  

local http_200_ok="HTTP/1.1 200 OK\r\n"
local content_type="Content-Type: application/json; charset=utf-8\r\n"
local str="\r\n"
local result,message	
responseBytes=0
	_, _, method, url, vars = string.find(payload, "([A-Z]+) /([^?]*)%??(.*) HTTP")
	if method == nil then
		print("Received garbage via HTTP.")
		return
	end
	vars=vars or ""
	url=url or ""
	print("Heap   : " .. node.heap())
	--print("Payload: " .. payload)
	print("Method : " .. method)
	print("URL    : " .. url)
	method=string.lower(method)
	url=string.lower(url)
	
	-- Get the vars from POST: data is not passed in address.
	if method== "post" and url=="update" then
	responseBytes=-1 --close connect	 indicator
	str=content_type..'\r\n\r\n{"Response":0,"Message":"OK"}\r\n'
		_, _, vars = string.find(payload, "(api_key.*)")
		if vars~=nil then
			display(function()
			disp:drawStr(0, 0, method)
			disp:drawStr(0, 12,url)
			disp:drawStr(0, 24,"vars:"..string.sub(vars,1,11))
			disp:drawStr(0, 36,string.sub(vars,12,28))
			disp:drawStr(0, 48,string.sub(vars,29,45)) 
			end)
			--parse REST update data from sensors
			local res=nil
			res,Values_List=assert(loadfile("parse_update.lc"))(vars)
			if res  then 
				if #Values_List.name>0  then
					--post to IOT
					if  iot_writeapikey and iot_writeapikey~="" and wifi.sta.getip() then
					   assert(loadfile("post_iot.lc"))(Values_List)
					end  
					--run lua_script
					if lua_script and lua_script~="" then
						result,message=pcall(assert(loadfile(lua_script)),Values_List)	
						if result==false then
							str=content_type..'\r\n\r\n{"Response":-1,"Message":"'.."Error in "..lua_script..":"..message..'"}\r\n'													
						end						
					end							
				end	
			else	
				str=content_type..'\r\n\r\n{"Response":-1,"Message":"'..Values_List..'"}\r\n'
							
			end	    
		end							
	elseif method == "post" and url=="commands" then
		responseBytes=-1 --close connect	 indicator
		str=content_type..'\r\n\r\n{"Response":0,"Message":"OK"}\r\n'
		_, _, vars = string.find(payload, "(api_key.*)")
		if vars~=nil then              
			--parse REST commands
			local res,fieldslist=assert(loadfile("parse_commands.lc"))(vars)
			if res then
				if #fieldslist.name>0  then   			
					--is received commands - run lua_commands
					if lua_commands and lua_commands~=""  then
						result,message=pcall(assert(loadfile(lua_commands)),fieldslist)								
					end
					if result then
						if message then								
							str=content_type.."\r\n\r\n"..message
						end
					else
						str=content_type..'\r\n\r\n{"Response":-1,"Message":"'.."Error in "..lua_commands..":"..message..'"}\r\n'						
					end	
				end
			else
				str=content_type..'\r\n\r\n{"Response":-1,"Message":"'..fieldslist..'"}\r\n'			
			end
		end	
	elseif  method=="post" and  url=="filelist" then
		_, _, vars = string.find(payload, "(fileaction.*)")
		local _, _, fileaction = string.find(vars, "fileaction\=([^&]+)")
		if fileaction then
			local _, _, filename = string.find(vars, "filename\=([^&]+)")			  
			if fileaction=="Compile" then
				--Compile
				local result,message=pcall(node.compile,filename)	
				if result then
					str=content_type..'\r\n\r\n{"File":"'..filename..'","Compile":"OK"}\r\n'
				else
					str=content_type..'\r\n\r\n{"File":"'..filename..'","Compile errors":"'..message..'"}\r\n'				
				end
			elseif fileaction=="Remove" then
				--Remove
				file.remove(filename)
				str=content_type..'\r\n\r\n{"File":"'..filename..'","Remove":"OK"}\r\n'

			elseif fileaction=="Reboot" then
				str=content_type..'\r\n\r\n{"Reboot!"}\r\n'
				tmr.alarm(2, 3000, 0, function() node.restart() end)  
			end

		end
		
	elseif method=="post" and  url=="upload" then
		--is payload for upload.html post? 
		if string.match(payload, "boundary=")==nil then 
			responseBytes = -1
			str=content_type..'\r\n\r\n{"Illegal upload format"}\r\n'
		end
		--parse upload.html post
		local boundary=string.match(payload,'.*boundary=([^\r\n]+)')
		local filename=string.match(payload,'.-'..boundary..'\r\n.-Content.Disposition.-name="(.-)"')
		if boundary==nil and  filename==nil then StatusUpload=false return end
		local linenumber=string.match(payload,'.-'..boundary..'\r\n.-Content.Disposition.-name="'..filename..'"..line=(.-)\r\n')
		local line=string.match(payload,'.-'..boundary..'\r\n.-Content.Disposition.-\r\n\r\n(.-)\r\n')
		if linenumber then
			str=content_type..'\r\n\r\n'
			responseBytes = 0
			--post next line
			--print("boundary="..boundary)
			--print("filename="..filename)
			--print("linenumber="..linenumber)
			--print("line="..line)

			if tonumber(linenumber) ==1 then
				--if first line - rewrite file
				file.open(filename, "w+")
			elseif tonumber(linenumber) >1 then
				--if next line - append file
				file.open(filename, "a+")
			end
			--write line and close file
			if tonumber(linenumber) >=1 then
			if file.write(line..'\r\n')==nil then StatusUpload=false  end
				file.flush()
				file.close()
				str=content_type..'\r\n\r\n{"Line":'..linenumber..',"Save":"OK"}\r\n'
			end
			
			if tonumber(linenumber) ==-1 then			
				str=content_type..'\r\n\r\n{"File":"'..filename..'","Upload":"OK"}\r\n'
			end
		else
			StatusUpload=false  
			responseBytes = -1
			str=content_type..'\r\n\r\n{"Illegal upload format"}\r\n'
		end
	end
	
if url~=nil and url~="" and url~="update"  and url~="commands"  and url~="filelist"  and url~="upload"   then
	if file.open(url, "r") and  url~="index.html"  and  url~="parameters.html" then
		file.close()
	else			
		--illegal url
		print(url.." 404 Not Found")
		display(function()
		disp:drawStr(0, 0, url)
		disp:drawStr(0, 12,"404 Not Found")
		end)	
		conn:send("HTTP/1.1 404 Not Found\r\n\r\n<!doctype html>\r\n<html>\r\n<head>\r\n</head>\r\n<body>\r\n404 File not found.\r\n</body>\r\n</html>\r\n")
		responseBytes = -1
		collectgarbage()
		return
    end   
end  	
tmr.alarm(0, 50, 0, function() print("Send "..http_200_ok..str)	 conn:send(http_200_ok..str) end)  
collectgarbage()
end)

-----------on send--------------------  
conn:on("sent",function(conn) 
-----------------------------------
local function get_html_file_next(tabsort,tab,index)

	--index,filesize=next(tab,index)
	if index and index<=#tabsort then
		
		local str='<tr>\r\n'
		..'<td>'..index..'.</td>'
		..'<td><a href="'..tabsort[index]..'">'..tabsort[index]..'</a></td>\r\n'	   
		..'<td>'..tab[tabsort[index]]..'</td>\r\n'
		if string.match(tabsort[index],'.lua') then
			str=str..'<td><a href="#'..tabsort[index]..'" id="'..tabsort[index]..'" onclick="sendForm(ge(id),\'Compile\')" >Compile</a></td>\r\n'
		else
			str=str..'<td></td>\r\n'
		end
		str=str..'<td><a href="#'..tabsort[index]..'" id="'..tabsort[index]..'" onclick="sendForm(ge(id),\'Remove\')" >Remove</a></td>\r\n'
		..'<td><a href="'..tabsort[index]..'">Download</a>\r\n'
		..'</tr>\r\n'
		--<tr>		   
		--<td><a href="script.lua">script.lua</a></td>
		--<td>12345</td>
		--<td><a href="#script.lua" id="script.lua"  onclick="sendForm(ge(id),'Compile')" >Compile</a></td>
		--<td><a href="#script.lua" id="script.lua"  onclick="sendForm(ge(id),'Remove')">Remove</a>
		--<td><a href="script.lua">Download</a>
		--</tr>
		return index+1,str
	else
		return nil,nil
	end
end


local str
if responseBytes>=0 and  url=="fm.html" then
	if dynamic_html then
		--write next file html
		fileindex,str=get_html_file_next(filelistsort,filelist,fileindex)
		if str then
			line=str
		else
			line='\r\n'
			dynamic_html,fileindex=nil,nil
		end	
		conn:send(line) 
		return 	
	else
		--read(as plain file)   
		if file.open(url, "r") then
			file.seek("set", responseBytes)
			--read next line
			local line=file.readline() 
			file.close()
			if line then
				responseBytes=responseBytes+string.len(line) 										
				dynamic_html=string.match(line, "luafileslistplaceholder")
				if dynamic_html then			
					-- start create dynamic html
					filelist = file.list()
					if filelist then
						for k,v in pairs(filelist) do
							table.insert(filelistsort,k)
						end
						table.sort (filelistsort)
						fileindex=1
						fileindex,str=get_html_file_next(filelistsort,filelist,fileindex)
						--print(fileindex,str)

						if str then
							line=string.gsub(line, "luafileslistplaceholder",str)
						end
					else
						line=string.gsub(line, "luafileslistplaceholder",'\r\n')
						dynamic_html,fileindex=nil,nil		
					end	
				else
					line=string.gsub(line, "luafileslistplaceholder",'\r\n')
					dynamic_html,fileindex=nil,nil		
				end
			--print("line="..line)	
			conn:send(line) 
			return               		
			end
		end 
	end
elseif responseBytes>=0 then
	--read(as binary file) and send upload.html 
	if file.open(url, "r") then
        file.seek("set", responseBytes)
        local line=file.read(250)          
        file.close()
        if line then
			--print(line)			
			conn:send(line) 
			responseBytes=responseBytes+250
			if (string.len(line)==250) then
				return
			end                 
        end
	end 
end
    responseBytes=-1 
    ident, holder,line,filelistsort,filelist = nil, nil,nil,nil,nil	 -- clean memory  
    collectgarbage() 
   conn:close()
  end)
  end)

print("HTTP Server: Started")
local apip=wifi.ap.getip()

print(wifi_ssid.."/"..wifi_password)
print(apip)
local ip =wifi.sta.getip()
display(function()
disp:drawStr(0, 0, "Server: Started")
disp:drawStr(0, 12, wifi_ssid or "" )
disp:drawStr(0, 24, wifi_password or "")
disp:drawStr(0, 36, (apip or ""))
disp:drawStr(0, 48,(ip or ""))
end)



