

  mov   ah, "F" 
  call  parse_driver_params

  ; chipset has no real default or set param, so use D000 by default if none defined.
  mov   ax, 0100h            ; corresponds to 0D000h
  jnc   set_page_frame   ; param not found, use default

  mov   ax, word ptr es:[di]
  sub   al, 'C'
  jb    bad_page_frame_param
  cmp   al, 'E'-'C'
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

  ; ah is 0 1 or 2    (C D or E)
  ; al is 0 4 8 or 12


  mov   bx, ax
  SHIFT_MACRO  shl bh 2
  SHIFT_MACRO  shr bl 2
  or    bl, bh
  
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_1+1], bl
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_2+1], bl 
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_3+1], bl 
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_4+1], bl 
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_5+1], bl 
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_6+1], bl 
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_7+1], bl 
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_8+1], bl 
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_9+1], bl 
  mov   byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_10+1], bl 

  SHIFT_MACRO   shl ah 4  ; 0 1 2 to 00 10 20  (C D E)
  or    al, ah


  add   al, 0C0h
  mov   byte ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+2], al 

  mov   ah, al
  xor   al, al

  stc   ; hex print
  mov   di, OFFSET string_good_page_frame_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_frame_param
  call  print_driver_param



  mov   ah, "C" ; page count
  call  parse_driver_params_get_int  ; no default. instead fetch from chipswt
  
  jc    found_chipset_bounds_value

  mov   ax, MAX_PAGE_COUNT
  sub   ax, FANTASY_PAGE_OFFSET_AMT

found_chipset_bounds_value:

  cmp   ax, MAX_PAGE_COUNT
  jbe   page_count_bounds_ok

  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED

  page_count_bounds_ok:

  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax


  mov   di, OFFSET string_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_count_param
  call  print_driver_param_4_char_int


mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?



  ; set first four page registers for d000
  mov   cx, 4
  mov   al, byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_1+1]
  cbw
  mov   bx, 0FFFFh


  enablepageloop:
  out   FANTASY_PAGE_SELECT_REGISTER, al
  xchg  ax, bx
  out   FANTASY_PAGE_SET_REGISTER, ax
  xchg  ax, bx
  inc   ax
  loop enablepageloop


  ; NOTE: If we enable backfill, we must initialize page registers for backfill region
  ;  4-28 to be 4-28

  mov   ax, 0Ch
  mov   cl, 18h  ; 24 registers, 0C to 23

  ; 0c maps to 10, 
  ; 0d maps to 11, 
  ; ...

  ; 23 maps to 27


  enablebackfillloop:
  out   FANTASY_PAGE_SELECT_REGISTER, al
  xchg  ax, bx
  out   FANTASY_PAGE_SET_REGISTER, ax
  xchg  ax, bx
  inc   ax
  loop enablebackfillloop



