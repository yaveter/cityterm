--use timer 6
--for Vitalik Fadeev
local fieldslist=...
print("\r\nlua_script")
print("-----------------------------")
local dist=search_name(fieldslist,"field3")

if dist and  tonumber(dist)>tonumber(parameter2) and gpio.read(1)==0 then
	gpio.write(1, gpio.HIGH)
	display(function()
	disp:setScale2x2()
	disp:drawStr(2,0, dist..string.char(225,220))   
	disp:drawStr(0, 12, string.char(178,218,219).."."..parameter3.."c") 
	disp:undoScale()
	end)	
	tmr.alarm(6, tonumber(parameter3)*1000, 0, function() gpio.write(1, gpio.LOW) 
	--	display(function()
	--		disp:drawStr(0, 0, string.char(180,216,225,226,208,221,230,216,239)..": "..dist ..string.char(225,220))   
	--		disp:drawStr(0, 12,string.char(178,219,214,221,222,225,226,236)..": "..search_name(fieldslist,"field2").."%")     
	--		disp:drawStr(0, 24, string.char(194,213,220,223,46)..": "..search_name(fieldslist,"field1").."C'")   
	--		disp:drawStr(0, 48, "GPIO5="..gpio.read(1))  
	--		end)
		display(function()
		        disp:setScale2x2()
			disp:drawStr(2,0, dist..string.char(225,220))   
			disp:drawStr(0, 12, string.char(178,235,218,219)) 
			disp:undoScale()
			end)	
	end)   
else  
	gpio.write(1, gpio.LOW)
	display(function()
	disp:setScale2x2()
	disp:drawStr(2,0, dist..string.char(225,220))   
	disp:undoScale()
	end)
end		
collectgarbage()

