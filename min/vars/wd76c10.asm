; Two-word pairs. first word is page frame (04000h, 04400h... etc) up to f000.  
;                 second word its physical ems index port
; 144 bytes long 
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)

  ; you can hardcode the chipset's mappable page list here for call 5800
mappable_phys_page_struct:

  dw 04000h, 0000h, 04400h, 0001h, 04800h, 0002h, 04C00h, 0003h
  dw 05000h, 0004h, 05400h, 0005h, 05800h, 0006h, 05C00h, 0007h
  dw 06000h, 0008h, 06400h, 0009h, 06800h, 000Ah, 06C00h, 000Bh
  dw 07000h, 000Ch, 07400h, 000Eh, 07800h, 000Eh, 07C00h, 000Fh
  dw 08000h, 0010h, 08400h, 0011h, 08800h, 0012h, 08C00h, 0013h
  dw 09000h, 0014h, 09400h, 0015h, 09800h, 0016h, 09C00h, 0017h
mappable_phys_page_struct_page_frame:
  dw 0D000h, 001Ch, 0D400h, 001Dh, 0D800h, 001Eh, 0DC00h, 001Fh




; for function 15/16 'push/pop' like operation.
page_stack: 
LENGTH_OF_STACK = (OFFSET page_stack - mappable_phys_page_struct) SHR 1
REPT LENGTH_OF_STACK
  dw 0
ENDM

WF76C10_api_to_physical_page_lookup:

; page frame
  db 32, 33, 34, 35 ; page frame

  db 16, 17, 18, 19 ; 4000
  db 20, 21, 22, 23 ; 5000
  db 24, 25, 26, 27 ; 6000
  db 28, 29, 30, 31 ; 7000
  db 00, 01, 02, 03 ; 8000
  db 04, 05, 06, 07 ; 9000





  dw 05000h, 0004h, 05400h, 0005h, 05800h, 0006h, 05C00h, 0007h
  dw 06000h, 0008h, 06400h, 0009h, 06800h, 000Ah, 06C00h, 000Bh
  dw 07000h, 000Ch, 07400h, 000Eh, 07800h, 000Eh, 07C00h, 000Fh
  dw 08000h, 0010h, 08400h, 0011h, 08800h, 0012h, 08C00h, 0013h
  dw 09000h, 0014h, 09400h, 0015h, 09800h, 0016h, 09C00h, 0017h
mappable_phys_page_struct_page_frame:
  dw 0D000h, 001Ch, 0D400h, 001Dh, 0D800h, 001Eh, 0DC00h, 001Fh



; for function 8/9 'push/pop' like operation.
_RESIDENT_VARIABLE_handle_page_stack:
:
dw 0, 0, 0, 0
