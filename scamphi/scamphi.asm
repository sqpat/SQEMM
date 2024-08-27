.286
.MODEL  tiny
.DATA
.CODE

dw 0FFFFh
dw 0FFFFh
dw 8000h
dw OFFSET DRIVER_INIT
dw OFFSET DRIVER_CALL
db "SCAMPUMB"
driver_arguments dd 00000000h 
DRIVER_INIT:
mov  word ptr cs:[driver_arguments], bx  
mov  word ptr cs:[driver_arguments+2], es        
retf 
DRIVER_CALL:
push bx
lds bx,  cs:[driver_arguments]


out 0FBh, al  ; dummy write config enable

mov  al, 00Fh
out 0ECh, al
nop
nop
in   al, 0EDh
or  al, 030h   ; turn on c800-cc00 for umbs
nop
out 0EDh, al
nop
nop

mov  al, 011h
out 0ECh, al
nop
nop
in   al, 0EDh
or  al, 00Fh   ; turn on e000-efff for umbs
nop
out 0EDh, al
nop
nop



mov        word ptr ds:[bx + 3], 0810Ch    ; general failure
mov        word ptr ds:[bx + 0eh], 0
mov        word ptr ds:[bx + 010h], cs
pop bx
retf
END