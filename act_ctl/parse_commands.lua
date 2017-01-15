--[[-------------------
parce_commands.lua  
 Parsing REST post control

Input:-post payload, format payload is  
  	url=https://192.168.4.1/commands?api_key=21321444&command_string1=OFF&command_string2=ON...  
	
Return: true, fieldslist={name={},value={}} 	- if exist commands
        nil,error string	- if not exist
---]]----------------
local vars=...
local fieldslist={name={},value={}}
if vars == nil or vars == "" then      
   return nil,"No incoming arguments"
end

print("parse commands")
print("-----------------------------")
local i=1
local value=""
local msg="Illegal api_key "
--check api_key
--api_key must be match chipid AP device
value= string.match(vars, "api_key\=([^&]+)")
if value then
	if value~=tostring(node.chipid()) then
		print(msg..value)
		--display(function() 	disp:drawStr(0, 0, msg) disp:drawStr(0, 12,value) end)
		return nil,msg
	end
end

while value do  
	value= string.match(vars, "command_string"..i.."\=([^&]+)")	
	if value then
		table.insert (fieldslist.name, "command_string"..i)
		table.insert (fieldslist.value, value)
		print(fieldslist.name[i].." : " .. fieldslist.value[i])
	end	
	i=i+1
end
collectgarbage()
return true,fieldslist
