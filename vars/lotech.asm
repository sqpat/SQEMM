; Two-word pairs. first word is page frame (04000h, 04400h... etc) up to f000.  
;                 second word its physical ems index port
; 144 bytes long 
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)

  ; you can hardcode the chipset's mappable page list here for call 5800
mappable_phys_page_struct:

  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h


; for function 15/16 'push/pop' like operation.
page_stack: 
LENGTH_OF_STACK = (OFFSET page_stack - mappable_phys_page_struct) SHR 1
REPT LENGTH_OF_STACK
  dw 0
ENDM


; for function 8/9 'push/pop' like operation.
page_frame_stack:
dw 0, 0, 0, 0

