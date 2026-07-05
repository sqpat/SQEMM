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
  dw 0D000h, 0018h, 0D400h, 0019h, 0D800h, 001Ah, 0DC00h, 001Bh




; for function 15/16 'push/pop' like operation.
page_stack: 
LENGTH_OF_STACK = (OFFSET page_stack - mappable_phys_page_struct) SHR 1
REPT LENGTH_OF_STACK
  dw 0
ENDM


; for function 8/9 'push/pop' like operation.
page_frame_stack:
dw 0, 0, 0, 0


; todo unused?
  default_page_struct:
  db 090h, 091h, 092h, 093h
  db 094h, 095h, 096h, 097h
  db 088h, 089h, 08Ah, 08Bh
  db 08Ch, 08Dh, 08Eh, 08Fh
  db 080h, 081h, 082h, 083h
  db 084h, 085h, 086h, 087h
  db 08Ch, 08Dh, 08Eh, 08Fh