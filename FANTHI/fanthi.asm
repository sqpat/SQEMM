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
lds bx,  cs:[driver_arguments]


;out 0FBh, al  ; dummy write config enable

; FANTASY SPECIFIC

mov  al, 48h        ; auto increment on
out 0E8h, al
nop
mov  ax, 01F8h
out 0EAh, ax   ; set a page for e000
inc ax
out 0EAh, ax   ; set a page for e400
inc ax
out 0EAh, ax   ; set a page for e800
inc ax
out 0EAh, ax   ; set a page for ec00




mov        word ptr ds:[bx + 3], 0810Ch    ; general failure
mov        word ptr ds:[bx + 0eh], 0
mov        word ptr ds:[bx + 010h], cs
pop bx
retf
END