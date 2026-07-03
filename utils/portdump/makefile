

CCOPTS = /d2 /omaxet /ml
#CCOPTS = /d2 /omaxet /zp1 /ei /j /zq /mt /zt100

GLOBOBJS = portdump.obj


portdump.exe : $(GLOBOBJS) 
 wlink @portdump.lnk
 wstrip portdump.exe

.c.obj :
 wcc $(CCOPTS) $[*


clean : .SYMBOLIC
 del *.obj
 del portdump.exe
