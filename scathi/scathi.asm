.286
.MODEL  tiny
.DATA
.CODE


SCAT_PAGE_REGISTER_OFFSET = 018h
SCAT_CHIPSET_CONFIG_REGISTER_SELECT = 022h
SCAT_CHIPSET_CONFIG_REGISTER_READWRITE = 023h
SCAT_EMS_CONFIG_REGISTER = 04Fh
SCAT_PAGE_SELECT_REGISTER = 020Ah
SCAT_PAGE_SET_REGISTER = 0208h
; 28h offset for conventional memory. 8000 is to mark bit 15 for free "ems enabled"
SCAT_PAGE_OFFSET_AMT = 08028h
SCAT_CHIPSET_UNMAP_VALUE = 03FFh

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

push dx

mov  al, 04Fh
out 022h, al
nop
nop
in   al, 023h
or  al, 040h   ; enable EMS i/o
nop
out 023h, al
nop
nop


mov dx, 020Ah 
mov al, 01Ch  ; page E000
out dx, al
mov ax, 08028h ; ems enable  page 28h
mov dx, 0208h 
out dx, ax

mov dx, 020Ah 
mov al, 01Dh  ; page E400
out dx, al
mov ax, 08029h ; ems enable  page 28h
mov dx, 0208h 
out dx, ax

mov dx, 020Ah 
mov al, 01Eh  ; page E800
out dx, al
mov ax, 0802Ah ; ems enable  page 28h
mov dx, 0208h 
out dx, ax

mov dx, 020Ah 
mov al, 01Fh  ; page EC00
out dx, al
mov ax, 0802Bh ; ems enable  page 28h
mov dx, 0208h 
out dx, ax


pop dx

mov        word ptr ds:[bx + 3], 0810Ch    ; general failure
mov        word ptr ds:[bx + 0eh], 0
mov        word ptr ds:[bx + 010h], cs
pop bx
retf
END