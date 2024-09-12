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

; TOPCAT SPECIFIC


mov  al, 08h
out 0E8h, al
nop
mov  ax, 0F830h
out 0EAh, ax   ; set a page for e000
nop

mov  al, 09h
out 0E8h, al
nop
mov  ax, 0F831h
out 0EAh, ax   ; set a page for e400
nop

mov  al, 0Ah
out 0E8h, al
nop
mov  ax, 0F832h
out 0EAh, ax   ; set a page for e800
nop

mov  al, 0Bh
out 0E8h, al
nop
mov  ax, 0F833h
out 0EAh, ax   ; set a page for ec00
nop

mov  al, 02h
out 0E8h, al
nop
mov  ax, 0F834h
out 0EAh, ax   ; set a page for c800
nop
nop



mov        word ptr ds:[bx + 3], 0810Ch    ; general failure
mov        word ptr ds:[bx + 0eh], 0
mov        word ptr ds:[bx + 010h], cs
pop bx
retf
END