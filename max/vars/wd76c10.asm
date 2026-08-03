chipset_page_lookup:

  db 080h, 084h, 088h, 08Ch
  db 090h, 094h, 098h, 09Ch
  db 020h, 024h, 028h, 02Ch
  db 030h, 034h, 038h, 03Ch
  db 040h, 044h, 048h, 04Ch
  db 050h, 054h, 058h, 05Ch
  db 060h, 064h, 068h, 06Ch
  db 070h, 074h, 078h, 07Ch
chipset_page_frame_lookup:
  db 0C0h, 0C4h, 0C8h, 0CCh ; possibly self modified
  db 0D0h, 0D4h, 0D8h, 0DCh
    ; you can hardcode the chipset's mappable page list here for call 5800


WF76C10_api_to_physical_page_lookup:

; page frame
  db 36, 37, 38, 39 ; page frame. possibly self modified

  db 16, 17, 18, 19 ; 4000
  db 20, 21, 22, 23 ; 5000
  db 24, 25, 26, 27 ; 6000
  db 28, 29, 30, 31 ; 7000
  db 00, 01, 02, 03 ; 8000
  db 04, 05, 06, 07 ; 9000

mappable_phys_page_struct:

  dw 04000h, 0004h, 04400h, 0005h, 04800h, 0006h, 04C00h, 0007h
  dw 05000h, 0008h, 05400h, 0009h, 05800h, 000Ah, 05C00h, 000Bh
  dw 06000h, 000Ch, 06400h, 000Dh, 06800h, 000Eh, 06C00h, 000Fh
  dw 07000h, 0010h, 07400h, 0011h, 07800h, 0012h, 07C00h, 0013h
  dw 08000h, 0014h, 08400h, 0015h, 08800h, 0016h, 08C00h, 0017h
  dw 09000h, 0018h, 09400h, 0019h, 09800h, 001Ah, 09C00h, 001Bh
mappable_phys_page_struct_page_frame:
  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h
