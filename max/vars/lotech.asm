chipset_page_lookup:

  db 0E0h, 0E4h, 0E8h, 0ECh


_RESIDENT_VARIABLE_driver_local_page_cache:
  REPT CHIPSET_PAGE_FRAME_COUNT
     dw 0  ; we are actually only using 4 bytes, whatever.
  ENDM

; Two-word pairs. first word is page frame (04000h, 04400h... etc) up to f000.  
;                 second word its physical ems index port
; 144 bytes long 
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)

  ; you can hardcode the chipset's mappable page list here for call 5800
mappable_phys_page_struct:

mappable_phys_page_struct_page_frame:
  dw 0E000h, 0000h, 0E400h, 0001h, 0E800h, 0002h, 0EC00h, 0003h


