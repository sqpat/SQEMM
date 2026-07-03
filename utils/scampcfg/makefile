

CCOPTS = /d2 /omaxet /ml
#CCOPTS = /d2 /omaxet /zp1 /ei /j /zq /mt /zt100

GLOBOBJS = scampcfg.obj


scampcfg.exe : $(GLOBOBJS) 
 wlink @scampcfg.lnk
 wstrip scampcfg.exe

.c.obj :
 wcc $(CCOPTS) $[*


clean : .SYMBOLIC
 del *.obj
 del scampcfg.exe
