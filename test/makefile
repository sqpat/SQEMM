

CCOPTS = /d2 /omaxet /ml
#CCOPTS = /d2 /omaxet /zp1 /ei /j /zq /mt /zt100

GLOBOBJS = test.obj


#newtest.exe : test.obj
test.exe : $(GLOBOBJS) 
 wlink @test.lnk
 wstrip test.exe

.c.obj :
 wcc $(CCOPTS) $[*


clean : .SYMBOLIC
 del *.obj
 del test.exe
