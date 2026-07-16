chipset_page_lookup:

  db 0C0h, 0C4h, 0C8h, 0CCh
  db 0D0h, 0D4h, 0D8h, 0DCh
  db 0E0h, 0E4h, 0E8h, 0ECh
  db 040h, 044h, 048h, 04Ch
  db 050h, 054h, 058h, 05Ch
  db 060h, 064h, 068h, 06Ch
  db 070h, 074h, 078h, 07Ch
  db 080h, 084h, 088h, 08Ch
  db 090h, 094h, 098h, 09Ch

; Two-word pairs. first word is page frame (04000h, 04400h... etc) up to f000.  
;                 second word its physical ems index port
; 144 bytes long 
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)

  ; you can hardcode the chipset's mappable page list here for call 5800
mappable_phys_page_struct:

  dw 04000h, 0004h, 04400h, 0005h, 04800h, 0006h, 04C00h, 0007h
  dw 05000h, 0008h, 05400h, 0009h, 05800h, 000Ah, 05C00h, 000Bh
  dw 06000h, 000Ch, 06400h, 000Dh, 06800h, 000Eh, 06C00h, 000Fh
  dw 07000h, 0010h, 07400h, 0011h, 07800h, 0012h, 07C00h, 0013h
  dw 08000h, 0014h, 08400h, 0015h, 08800h, 0016h, 08C00h, 0017h
  dw 09000h, 0018h, 09400h, 0019h, 09800h, 001Ah, 09C00h, 001Bh
mappable_phys_page_struct_page_frame:
  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h
  

