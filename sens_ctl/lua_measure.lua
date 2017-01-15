-- Add your functionality here

local fieldslist={name={"field1","field2","field3"},value={"","",""}}

local status,temp, humi =dht_11.read_dht()
fieldslist.value[1],fieldslist.value[2]=temp,humi

if status<0 then	
	fieldslist.value[1],fieldslist.value[2]=-1,-1
end
fieldslist.value[3]=SR4_DIST or -1 

if fieldslist.value[1]==-1 or fieldslist.value[2]==-1 or fieldslist.value[1]==-1 then
	gpio.serout(LBGI,gpio.LOW,{300000,300000},4,1) -- Failed read senssors, blink 4 times  	
end      

print("measure field")
print("-----------------------------")
print("Status : "..status)
local cnt=#fieldslist.name
for i=1,cnt do
print(fieldslist.name[i].." : "..fieldslist.value[i])
end
		
return fieldslist