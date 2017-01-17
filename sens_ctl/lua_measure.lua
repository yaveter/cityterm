-- lua_measure.lua - a custom script to perform the measurement sensors
-- Initialize the sensors in lua_init.lc

-- Return fieldslist={name={},value={}}

-- Add your functionality here

--init fieldslist  field1 - temperature (Celsius degree), field2 - humidity (%), field3 - distance (centimeters), field4- system voltage (millivolts)
local fieldslist={name={"field1","field2","field3","field4"},value={"","","",""}}

local status,temp, humi =dht_11.read_dht()
fieldslist.value[1],fieldslist.value[2]=temp,humi

if status<0 then	
	fieldslist.value[1],fieldslist.value[2]=-1,-1
end
fieldslist.value[3]=SR4_DIST or -1 

if fieldslist.value[1]==-1 or fieldslist.value[2]==-1 or fieldslist.value[1]==-1 then
	gpio.serout(LBGI,gpio.LOW,{300000,300000},4,1) -- Failed read senssors, blink 4 times  	
end      

fieldslist.value[4]=3300*adc.readvdd33(0)/65535

print("measure field")
print("-----------------------------")
print("Status : "..status)
local cnt=#fieldslist.name
for i=1,cnt do
print(fieldslist.name[i].." : "..fieldslist.value[i])
end
		
return fieldslist