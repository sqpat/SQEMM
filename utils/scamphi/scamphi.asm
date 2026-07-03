.286
.MODEL  tiny
.DATA
.CODE

dw 0FFFFh
dw 0FFFFh
dw 8000h
dw OFFSET DRIVER_INIT
dw OFFSET DRIVER_CALL
db "FANTASYH"
driver_arguments dd 00000000h 
DRIVER_INIT:
mov  word ptr cs:[driver_arguments], bx  
mov  word ptr cs:[driver_arguments+2], es        
retf 
DRIVER_CALL:
push bx
push dx
mov  dx, 0260h
xor  ax, ax
out  dx, al
inc  dx
inc  ax
out  dx, al
inc  dx
inc  ax
out  dx, al
inc  dx
inc  ax
out  dx, al
inc  dx
inc  ax
out  dx, al
inc  dx
inc  ax
out  dx, al
inc  dx
inc  ax
out  dx, al
inc  dx
inc  ax
out  dx, al
inc  dx
inc  ax
mov  word ptr [bx + 3], 0810ch
mov  word ptr [bx + 0Eh], 0
mov  word ptr [bx + 010h], cs
pop  dx
pop  bx
retf 
END