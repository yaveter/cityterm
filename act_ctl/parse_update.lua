--[[-------------------
parce_update.lua  

 Parsing REST post from sensor device 

Input:-post payload, format payload is  
  	url=https://192.168.4.1/update?api_key=21321444&field1=10&field1=20&field2=20...  
Return: true, fieldslist={name={},value={}} 	- if exist data from senssors 
        nil,error string	- if not exist
		
		
---]]----------------

local function search_list(list,val)
------------------------------
  for i, v in ipairs(list) do
    if v == val then return i end
  end
  return nil
end

local vars=...
local fieldslist={name={},value={}}
if vars == nil or vars == "" then      
   return nil,"No incoming arguments"
end

print("parse field")
print("-----------------------------")
local i=1
local value=""
local msg="Illegal api_key "
--parse update REST post
value= string.match(vars, "api_key\=([^&]+)")
if value then
	--check api_key
	--api_key must be defined in setup
	if search_list(sensor_apikey,value) ==nil then
		print(msg..value)
--		display(function() 	disp:drawStr(0, 0,msg) disp:drawStr(0, 12,value) end)
		return nil,msg
	end 
end
local i=1
while value do  
	value= string.match(vars, "field"..i.."\=([^&]+)")
	if value then
		table.insert (fieldslist.name, "field"..i)
		table.insert (fieldslist.value, value)
		print(fieldslist.name[i].." : " .. fieldslist.value[i])
	end	
	i=i+1
end
 
collectgarbage()
return true,fieldslist

