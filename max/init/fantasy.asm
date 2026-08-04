

  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter
  mov   ax, word ptr ds:[_INIT_PARAM_PAGEFRAME_ARG]
  test  ax, ax
  jnz   use_parsed_page_frame
  mov   ax, 0100h            ; corresponds to 0D000h
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_default_parameter
use_parsed_page_frame:

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



  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter

  mov   ax, word ptr ds:[_INIT_PARAM_OFFSET_ARG]
  test  ax, ax
  jnz   use_parsed_offset

  mov   ax, FANTASY_PAGE_OFFSET_AMT
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_default_parameter

use_parsed_offset:

  mov   word ptr ds:[_INIT_PARAM_OFFSET], ax

  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_6+1], ax
  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_7+1], ax
  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_8+1], ax
  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_9+1], ax
  dec   ax
  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_1+2], ax
  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_2+2], ax
  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_3+2], ax
  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_4+2], ax
  mov   word ptr ds:[SELFMODIFY_FANTASY_set_page_offset_5+2], ax
  inc   ax







  mov   di, OFFSET string_good_page_offset_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_offset_param
  call  print_driver_param_4_char_int



  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter

  mov   ax, word ptr ds:[_INIT_PARAM_PAGECOUNT_ARG]
  test  ax, ax
  jnz   use_parsed_pagecount

  mov   ax, MAX_PAGE_COUNT
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_default_parameter

use_parsed_pagecount:

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
  sub   ax, word ptr ds:[_INIT_PARAM_OFFSET] ; unallocate the default registers
  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax


  mov   di, OFFSET string_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_count_param
  call  print_driver_param_4_char_int


mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?

  mov   bx, 0FFFFh

COMMENT @
  ; set first four page registers for d000
  mov   cx, 4
  mov   al, byte ptr ds:[SELFMODIFY_FANTASY_add_page_frame_offset_1+1]
  cbw


  enablepageloop:
  out   FANTASY_PAGE_SELECT_REGISTER, al
  xchg  ax, bx
  out   FANTASY_PAGE_SET_REGISTER, ax
  xchg  ax, bx
  inc   ax
  loop enablepageloop



  ; NOTE: If we enable backfill, we must initialize page registers for backfill region
  ; todo is this true? or do -1??
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
  @



