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
if string.match(vars, "(parameter1.*)")==nil then return false end

--parse parameters
 _, _, nameparam1 = string.find(vars, "nameparam1\=([^&]+)")
 _, _, nameparam2 = string.find(vars, "nameparam2\=([^&]+)")
 _, _, nameparam3 = string.find(vars, "nameparam3\=([^&]+)")
 _, _, nameparam4 = string.find(vars, "nameparam4\=([^&]+)")
 _, _, nameparam5 = string.find(vars, "nameparam5\=([^&]+)")

 _, _, parameter1 = string.find(vars, "parameter1\=([^&]+)")
 _, _, parameter2 = string.find(vars, "parameter2\=([^&]+)")
 _, _, parameter3 = string.find(vars, "parameter3\=([^&]+)")
 _, _, parameter4 = string.find(vars, "parameter4\=([^&]+)")
 _, _, parameter5 = string.find(vars, "parameter5\=([^&]+)")
 _, _, lua_init_script = string.find(vars, "lua_init_script\=([^&]+)")
 _, _, lua_script = string.find(vars, "lua_script\=([^&]+)")
 _, _, lua_commands = string.find(vars, "lua_commands\=([^&]+)")


nameparam1=urldecode((nameparam1 or ""))
nameparam2=urldecode((nameparam2 or ""))
nameparam3=urldecode((nameparam3 or ""))
nameparam4=urldecode((nameparam4 or ""))
nameparam5=urldecode((nameparam5 or ""))

parameter1=parameter1 or ""
parameter2=parameter2 or ""
parameter3=parameter3 or ""
parameter4=parameter4 or ""
parameter5=parameter5 or ""

lua_init_script=lua_init_script or ""
lua_script=lua_script or ""
lua_commands=lua_commands or ""
	
--print("New parametereters received")
--print("-----------------------------")
--print("nameparam1 : " .. nameparam1)
--print("nameparam2 : " .. nameparam2)
--print("nameparam3 : " .. nameparam3)
--print("nameparam4 : " .. nameparam4)
--print("nameparam5 : " .. nameparam5)

--print("parameter1 : " .. parameter1)
--print("parameter2 : " .. parameter2)
--print("parameter3 : " .. parameter3)
--print("parameter4 : " .. parameter4)
--print("parameter5 : " .. parameter5)
--print("lua_init_script : " .. lua_init_script)
--print("lua_script : " .. lua_script)
--print("lua_commands : " .. lua_commands)
	

local paramcfg="paramcfg"

--save and compile patamcfg.lua
    if file.open(paramcfg..".lc", "r") then
        file.close()
        file.remove(paramcfg..".lc")
    end
   
    file.open(paramcfg..".lua", "w+")
    file.writeline("nameparam1='"..nameparam1.."'")
    file.writeline("nameparam2='"..nameparam2.."'")
    file.writeline("nameparam3='"..nameparam3.."'")   	
    file.writeline("nameparam4='"..nameparam4.."'")
    file.writeline("nameparam5='"..nameparam5.."'")   	

    file.writeline("parameter1='"..parameter1.."'")
    file.writeline("parameter2='"..parameter2.."'")
    file.writeline("parameter3='"..parameter3.."'")   
    file.writeline("parameter4='"..parameter4.."'")
    file.writeline("parameter5='"..parameter5.."'")   
    file.writeline("lua_init_script='"..lua_init_script.."'")   
    file.writeline("lua_script='"..lua_script.."'")   
    file.writeline("lua_commands='"..lua_commands.."'")   
    file.flush()
    file.close()
    pcall(node.compile,paramcfg..".lua")
    --file.remove(paramcfg..".lua")
    if file.open(paramcfg..".lc", "r") then
        file.close()
		result=true
	else 
		result=false		 
    end
	
    collectgarbage()
    return result
