






; determine chipset offset, memory amount in case needed later.



  mov   al, HT18_MEMORY_CONFIG_REGISTER
  mov   dx, HT18_CHIPSET_CONFIG_REGISTER_SELECT
  out   dx, al
  inc   dx
  inc   dx
  in    al,  dx
  and   al, 0E0h  ; get high 3 bits  clear CF
  rcl   al, 1    ; carry flag = dram type

  mov   ah, 32   ; one bank of 256k = 512KB, or 32 pages of 16KB memory
  jnc   use_256k_banks
use_1M_banks:
  mov   ah, 128  ; one bank of 1M = 2MB, or 128 pages of 16KB memory
use_256k_banks:

  rol   al, 2    ; al = 0-3 
                 ; ah = pages per bank
  inc   ax       ; al = num banks (1-4 not 0-3 so it needs an inc)
  mul   ah       ; ax = total num 16k memory pages (banks * pages per bank)

  ; TODO: there is a special 640k case involving control register 1 bit 6. 
  ; Supposedly only works on REV A/B boards. This implementation is mostly for REV C anyway.


  xchg ax, bx ; bx stores this.

  mov   ax, HT18_EXTENDED_BOUNDARY_CONFIG_REGISTER ; zero ah
  dec   dx
  dec   dx
  out   dx, al

; GC-103 check
  in    al, dx
  test  al, al
  cmp   al, HT18_EXTENDED_BOUNDARY_CONFIG_REGISTER  ; todo NOT SURE IF THIS WORKS ON REAL HARDWARE, DEFINITELY DOESN'T WORK ON 86BOX. 
  mov   ax, 68  ; default value for GC-103?
  jne   use_default_fallback_offset_for_gc103
; end GC-103 check

  inc   dx
  inc   dx
  in    al, dx   ; al = number of 64kb pages to extended boundary.
  shl   ax, 2    ; ax = number of 16kb pages to extended boundary.

use_default_fallback_offset_for_gc103:
  sub  bx, ax    ; bx was total system memory
  mov  word ptr ds:[chipset_num_pages], bx
  mov  word ptr ds:[chipset_page_offset], ax

 mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter
  mov   ax, word ptr ds:[_INIT_PARAM_PAGEFRAME_ARG]
  test  ax, ax
  jnz   use_parsed_page_frame
  mov   ax, 0100h            ; corresponds to 0D000h
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_default_parameter


use_parsed_page_frame:

  test  ah, ah
  jz    good_page_frame
  test  al, al
  jnz   bad_page_frame_param ; d400, d800, dc00 
  good_page_frame:

  ; ah is 0 1    (C D)
  ; al is 0 4 8 or 12
  mov   bx, ax ; backup

  SHIFT_MACRO shl   ah, 4  ; 0 1to 00 10  (C D)
  or    al, ah
  add   al, 0C0h
  mov   byte ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+2], al 

  mov   ah, al
  xor   al, al

  stc   ; hex print
  mov   di, OFFSET string_good_page_frame_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_frame_param
  call  print_driver_param




; enable writes to registers...
  mov al, HT18_MEMORY_CONFIG_REGISTER
  mov dx, HT18_CHIPSET_CONFIG_REGISTER_SELECT
  out dx, al
  mov dx, HT18_CHIPSET_CONFIG_REGISTER_READWRITE
  in al,  dx
  or al,  02h ; enable EMS flag on
  out dx, al

  xchg ax, bx  ; retrieve page


  shr  al, 2   ; 0 4 8 C to 0 1 2 3
  shl  ah, 2   ; 0 1 2 to 0 4 8  (C D 0)
  or   al, ah  ; combine


  mov  byte ptr ds:[SELFMODIFY_HT18_set_page_frame_register_offset_12+1], al


  add  al, HT18_PAGE_C000_REGISTER_OFFSET

  mov  byte ptr ds:[SELFMODIFY_HT18_add_page_frame_register_offset_4+1], al
  mov  byte ptr ds:[SELFMODIFY_HT18_add_page_frame_register_offset_6+1], al

; additional 4 for minus cases.
  add  al, (HT18_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA)
  mov  byte ptr ds:[SELFMODIFY_HT18_add_page_frame_register_offset_1+1], al
  mov  byte ptr ds:[SELFMODIFY_HT18_add_page_frame_register_offset_7+1], al


  mov  byte ptr ds:[SELFMODIFY_HT18_add_page_frame_register_offset_8+1], al
  mov  byte ptr ds:[SELFMODIFY_HT18_add_page_frame_register_offset_9+1], al
  mov  byte ptr ds:[SELFMODIFY_HT18_add_page_frame_register_offset_10+1], al




  sub  al, (HT18_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA)

  ;or   al, HT18_CHIPSET_AUTOINCREMENT_FLAG

  mov  dx, HT18_PAGE_SELECT_REGISTER
  out  dx, al


  mov  dx, HT18_PAGE_SET_REGISTER 
  mov  ax, 08040h  ; 080h flag to enable ems. 40h to map to page at 1 MB (64 * 16384)   ; todo proper offset not 40h!
  out  dx, ax ; map page 0 to 1MB + 0*16384
  inc  ax 
  out  dx, ax ; map page 1 to 1MB + 1*16384
  inc  ax 
  out  dx, ax ; map page 2 to 1MB + 2*16384
  inc  ax 
  out  dx, ax ; map page 3 to 1MB + 3*16384




  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter

  mov   ax, word ptr ds:[_INIT_PARAM_PAGECOUNT_ARG]
  test  ax, ax
  jnz   use_parsed_pagecount

  mov   ax, word ptr ds:[chipset_num_pages]
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter

use_parsed_pagecount:


  test  ax, ax
  jnz   memory_count_ok
bad_memory_count_error:
  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED
memory_count_ok:
  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax ;  we don't subtract, because this chipset does not include backfill in its total memory count i guess.
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax



  mov   di, OFFSET string_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_count_param
  call  print_driver_param_4_char_int





  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter

  mov   ax, word ptr ds:[_INIT_PARAM_OFFSET_ARG]
  test  ax, ax
  jnz   use_parsed_offset

  mov   ax, word ptr ds:[chipset_page_offset]
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter

use_parsed_offset:

  mov   word ptr ds:[_INIT_PARAM_OFFSET], ax

  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_5+1], ax
  dec  ax
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_4_minus_1+1], ax
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_2_minus_1+2], ax
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_1_minus_1+2], ax
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_3_minus_1+2], ax
  inc  ax

  mov   di, OFFSET string_good_page_offset_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_offset_param
  call  print_driver_param_4_char_int

  

  
  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?





