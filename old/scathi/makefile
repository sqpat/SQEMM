

CCOPTS = /d2 /omaxet /ml
#CCOPTS = /d2 /omaxet /zp1 /ei /j /zq /mt /zt100

GLOBOBJS = scatcfg.obj


scathi.exe : $(GLOBOBJS) 
 wlink @scathi.lnk
 wstrip scatcfg.exe

.c.obj :
 wcc $(CCOPTS) $[*


clean : .SYMBOLIC
 del *.obj
 del scatcfg.exe
