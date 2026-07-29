
  ; enable d000 register and backfill


  ; todo offset and self modify!
  mov   ax, SCAMP_PAGE_OFFSET_AMT

  mov  word ptr ds:[_INIT_PARAM_OFFSET], ax

  

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
  
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_1+1], bl
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_2+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_3+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_4+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_5+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_6+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_8+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_9+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_10+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_11+1], bl 

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

found_chipset_bounds_value:

  cmp   ax, MAX_PAGE_COUNT
  jbe   page_count_bounds_ok

  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED

  page_count_bounds_ok:

  ; start with 4096KB (256 pages)
  ; subtract 16 pages 256 KB for backfill system (not pageable but shadowable). 
  ;  - NOT IN PAGE LIST
  ; subtract 24 pages 344 KB for backfill pageable
  ;  - IN OS PAGE LIST AT START
  ; subtract 12 pages 192 KB for C000-EFFF region defaults  (todo dont waste this, repage and waste only 4)
  ;  - NOT IN PAGE LIST (?)
  ; left with 3264KB (204 pages)
  ;  - In default pagelist.

  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax
  sub   ax, SCAMP_PAGE_OFFSET_AMT ; unallocate the default registers
  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax


  mov   di, OFFSET string_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_count_param
  call  print_driver_param_4_char_int


mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?


; Program the registers now.


out   0FBh, al  ; dummy write enable

  ; pre-enit these. they seem to crash (emulator at least) otherwise?
  mov   cx, 4
  
  loop_init_page_registers:
    SELFMODIFY_SCAMP_add_page_frame_offset_11:
    mov   al, 4
    add   al, 4
    sub   al, cl
    out   SCAMP_PAGE_SELECT_REGISTER, al
    
    cbw
    add   ax, SCAMP_PAGE_OFFSET_AMT
    out   SCAMP_PAGE_SET_REGISTER, ax
    loop  loop_init_page_registers

      ; NOTE: If we enable backfill, we must initialize page registers for backfill region
  ;  4-28 to be 4-28

  mov   ax, 0Ch
  mov   cl, 18h  ; 24 registers, 0C to 23

  ; 0c maps to 10, 
  ; 0d maps to 11, 
  ; ...
  ; 23 maps to 27

  enablebackfillloop:
  out   SCAMP_PAGE_SELECT_REGISTER, al
  add   ax, 4
  xchg  ax, ax ; delay
  xchg  ax, ax
  out   SCAMP_PAGE_SET_REGISTER, ax
  sub   ax, 3       ; inc included..
  loop enablebackfillloop



  mov   al, 0Bh
  out   0ECh, al
  mul   al  ; delay
  ;mov   al, 0A0h   ; turn on ems 
  mov   al, 0E0h   ; turn on ems, backfill
  out   0EDh, al
  
  mov   al, 0Ch
  out   0ECh, al
  mul   al  ; delay
  mov   al, 0F0h  ; turn on d000 as page frame
  out   0EDh, al



