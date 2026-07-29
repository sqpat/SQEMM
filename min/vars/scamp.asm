; Two-word pairs. first word is page frame (04000h, 04400h... etc) up to f000.  
;                 second word its physical ems index port
; 144 bytes long 
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)

  ; you can hardcode the chipset's mappable page list here for call 5800
mappable_phys_page_struct:

  dw 04000h, 000Ch, 04400h, 000Dh, 04800h, 000Eh, 04C00h, 000Fh
  dw 05000h, 0010h, 05400h, 0011h, 05800h, 0012h, 05C00h, 0013h
  dw 06000h, 0014h, 06400h, 0015h, 06800h, 0016h, 06C00h, 0017h
  dw 07000h, 0018h, 07400h, 0019h, 07800h, 001Ah, 07C00h, 001Bh
  dw 08000h, 001Ch, 08400h, 001Dh, 08800h, 001Eh, 08C00h, 001Fh
  dw 09000h, 0020h, 09400h, 0021h, 09800h, 0022h, 09C00h, 0023h
mappable_phys_page_struct_page_frame:
  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h


; for function 15/16 'push/pop' like operation.
page_stack: 
LENGTH_OF_STACK = (OFFSET page_stack - mappable_phys_page_struct) SHR 1
REPT LENGTH_OF_STACK
  dw 0
ENDM


; for function 8/9 'push/pop' like operation.
_RESIDENT_VARIABLE_handle_page_stack:
dw 0, 0, 0, 0

