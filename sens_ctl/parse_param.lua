--[[-------------------
parce_param.lua  

 Parsing post payload from parameters.html and save and compile parameters file paramcfg.lua

Input:	-post payload
 		format payload is  
		parameter1=**&parameter2=**...;
Return: true/false - succesful/unsuccessful
---]]----------------
local vars=...
local result=false

print("parse_parameter_config\r\n")

-- input arguments
if vars == nil  then
	return false
elseif  vars == "" then      
   return false
end

--is payload for parameters.html post?
if string.match(vars, "(lua_init_script.*)")==nil then return false end

--parse parameters
local _, _, lua_init_script = string.find(vars, "lua_init_script\=([^&]+)")
local _, _, lua_measure = string.find(vars, "lua_measure\=([^&]+)")


lua_init_script=lua_init_script or ""
lua_measure=lua_measure or ""
	
print("New parametereters received")
print("-----------------------------")
print("lua_init_script : " .. lua_init_script)
print("lua_measure : " .. lua_measure)
	

local paramcfg="paramcfg"

--save and compile patamcfg.lua
    if file.open(paramcfg..".lc", "r") then
        file.close()
        file.remove(paramcfg..".lc")
    end
   
    file.open(paramcfg..".lua", "w+")
    file.writeline("lua_init_script='"..lua_init_script.."'")   
    file.writeline("lua_measure='"..lua_measure.."'")   
    file.flush()
    file.close()
    pcall(node.compile,paramcfg..".lua")
    file.remove(paramcfg..".lua")
    if file.open(paramcfg..".lc", "r") then
        file.close()
		result=true
	else
		result=false		 
    end
	
    collectgarbage()
    return result
