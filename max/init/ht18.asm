








  mov   ah, "F" 
  call  parse_driver_params

  ; chipset has no real default or set param, so use D000 by default if none defined.
  mov   ax, 0100h            ; corresponds to 0D000h
  jnc   set_page_frame   ; param not found, use default

  mov   ax, word ptr es:[di]
  sub   al, 'C'
  jb    bad_page_frame_param
  cmp   al, 'D'-'C'
  ja    bad_page_frame_param
  xchg  al, ah
  sub   al, '0'
  je    set_page_frame
  cmp   al, 4
  je    set_page_frame
  cmp   al, 8
  je    set_page_frame
  cmp   al, 'C' - '0'
  mov   al, 12
  je    set_page_frame

  bad_page_frame_param:
  ; bad page frame param! error?
  mov  DX, OFFSET string_bad_page_frame_param
  jmp  DRIVER_NOT_INSTALLED

  set_page_frame:

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
  mov al, HT18_EMS_CONFIG_REGISTER
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

  mov  byte ptr ds:[SELFMODIFY_HT18_set_page_frame_register_offset_5+1], al
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




  mov   ah, "C" ; page count
  call  parse_driver_params_get_int  ; no default. instead fetch from chipswt
  
  jc    found_chipset_bounds_value

; TODO
  ;call  get_HT18_chipset_bounds_value

  xchg  ax, dx
; TODO
  ;call  get_HT18_chipset_total_memory_pages
  sub   ax, dx

  found_chipset_bounds_value:

  xchg  ax, dx
; TODO
  ;call  get_HT18_chipset_bounds_value
  add   ax, dx
  xchg  ax, cx   ; cx = bounds + page count
; TODO
  ;call  get_HT18_chipset_total_memory_pages

  


  cmp   cx, ax
  xchg  ax, dx
  jbe   page_count_bounds_ok

  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED

  page_count_bounds_ok:

; for now set to max. then parse offset and subtract.
  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax ;  we don't subtract, because this chipset does not include backfill in its total memory count i guess.
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax



  mov   di, OFFSET string_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_count_param
  call  print_driver_param_4_char_int



  mov   ah, "O"  ; page offset
  call  parse_driver_params_get_int  ; no default. instead fetch from chipswt

  jc    found_page_offset_bounds

;TODO
  ;call  get_HT18_chipset_bounds_value
  found_page_offset_bounds:

  ; ax has offset..

  xchg  ax, dx
;TODO
  ;call  get_HT18_chipset_total_memory_pages

  mov   cx, dx
  add   cx, word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1] ; cx = ems page count + offset
  cmp   cx, ax                             ; compare to total ems pages
  xchg  ax, dx  ; get page offset back in ax
  jbe   done_with_page_offset_bounds_check

  ; overーallocated?

  mov  DX, OFFSET string_bad_page_offset_param
  jmp  DRIVER_NOT_INSTALLED

  done_with_page_offset_bounds_check:

  ; add this back for conventional region
  add   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], 24

  mov  word ptr ds:[_INIT_PARAM_OFFSET], ax

  push  ax

  mov   di, OFFSET string_good_page_offset_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_offset_param
  call  print_driver_param_4_char_int

  pop   ax

  
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_5+1], ax
  dec  ax
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_4_minus_1+1], ax
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_2_minus_1+2], ax
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_1_minus_1+2], ax
  mov  word ptr ds:[SELFMODIFY_HT18_add_page_offset_3_minus_1+2], ax

  
  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?





