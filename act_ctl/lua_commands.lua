--use timer 1
local fieldslist=...
for k,v in ipairs(fieldslist.name) do 
	if fieldslist.value[k]=="SETUP" then
		tmr.alarm(2, 2000, 0, function() 
		file.remove("setup.flag")
		node.restart() 
		end)   
	
	elseif fieldslist.value[k]=="REBOOT" then	
		tmr.alarm(2, 2000, 0, function() node.restart() end)  
-- customer commands	
	elseif fieldslist.value[k]=="GPIO5_OFF" then	
		gpio.write(1, gpio.LOW)
		tmr.alarm(1,100,0, function() 
		display(function()
			disp:drawStr(0, 0, "GPIO5="..gpio.read(1))  
			end)
		end) 
		return '{"Response":0,"GPIO5":'..tostring(gpio.read(1))..'}\r\n'
	elseif fieldslist.value[k]=="GPIO5_ON" then
		gpio.write(1, gpio.HIGH)
		tmr.alarm(1,100,0, function() 
		display(function()
			disp:drawStr(0, 0, "GPIO5="..gpio.read(1))  
			end)
		end) 
		return '{"Response":0,"GPIO5":'..tostring(gpio.read(1))..'}\r\n' 	 
	elseif fieldslist.value[k]=="GET_STATUS_GPIO5" then			         
		return '{"Response":0,"GPIO5":'..tostring(gpio.read(1))..'}\r\n' 	
	elseif fieldslist.value[k]=="GET_FIELDS" then	
		if  Values_List and #Values_List.name>0  then
			local val1,val2,val3=search_name(Values_List, "field1"),search_name(Values_List, "field2"),search_name(Values_List, "field3")
			return '{"Response":0,"field1":"'..val1..'","field2":"'..val2..'","field3":"'..val3..'"}\r\n' 	
		else
			return '{"Response":-1,"fields":"undefined"}\r\n' 
		end		
	end
end
return nil

