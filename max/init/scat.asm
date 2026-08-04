  ; determine port via chipset register.

  mov   al, SCAT_EMS_CONFIG_REGISTER   ; 
  out   SCAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in    al, SCAT_CHIPSET_CONFIG_REGISTER_READWRITE
  test  al, 1
  mov   ax, 0208h  ; defau
  je    use_default_ports
  ; use port 218/21A not 208/20A
  mov   al, 010h

  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_set_register_2+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_set_register_3+1], al

  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_2+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_3+1], al

  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_set_register_4+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_5+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_6+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_7+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_8+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_9+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_10+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_11+1], al


  use_default_ports:

  stc   ; hex print
  mov   di, OFFSET string_good_port_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_port_param
  call  print_driver_param

  call  get_SCAT_chipset_bounds_value
  mov   word ptr ds:[chipset_page_offset], ax

  ;mov   si, ax

  call  get_SCAT_chipset_total_memory_pages
  mov   word ptr ds:[chipset_total_memory_pages], ax

  sub   ax, word ptr ds:[chipset_page_offset]
  mov   word ptr ds:[chipset_num_pages], ax


  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter
  mov   ax, word ptr ds:[_INIT_PARAM_PAGEFRAME_ARG]
  test  ax, ax
  jnz   use_parsed_page_frame
  mov   ax, 0100h            ; corresponds to 0D000h
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_default_parameter


use_parsed_page_frame:


  ; ah is 0 1 or 2    (C D or E)
  ; al is 0 4 8 or 12
  mov   bx, ax ; backup

  SHIFT_MACRO shl   ah, 4  ; 0 1 2 to 00 10 20  (C D E)
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
  mov al, SCAT_EMS_CONFIG_REGISTER
  out SCAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, SCAT_CHIPSET_CONFIG_REGISTER_READWRITE
  or   al, 0C0h   ; enable EMS, and make registers writeable
  out  SCAT_CHIPSET_CONFIG_REGISTER_READWRITE, al

  xchg ax, bx  ; retrieve page

  shr  al, 2   ; 0 4 8 C to 0 1 2 3
  shl  ah, 2   ; 0 1 2 to 0 4 8  (C D 0)
  or   al, ah  ; combine


  add  al, SCAT_PAGE_C000_REGISTER_OFFSET

  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_4+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_6+1], al

; additional 4 for minus cases.
  add  al, (SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA)
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_1+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_7+1], al


  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_8+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_9+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_10+1], al



  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter
  mov   ax, word ptr ds:[_INIT_PARAM_PAGECOUNT_ARG]
  test  ax, ax
  jnz   use_parsed_pagecount_skip_page_offset_check

  mov   ax, word ptr ds:[chipset_num_pages]
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter

use_parsed_pagecount:


  mov   dx, word ptr ds:[chipset_page_offset]
  add   dx, ax

  cmp   dx, word ptr ds:[chipset_total_memory_pages]
  jbe   page_count_bounds_ok

  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED

use_parsed_pagecount_skip_page_offset_check:
page_count_bounds_ok:

; for now set to max. then parse offset and subtract.
  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax
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

  mov  word ptr ds:[_INIT_PARAM_OFFSET], ax

  push  ax

  mov   di, OFFSET string_good_page_offset_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_offset_param
  call  print_driver_param_4_char_int

  pop   ax


  mov  word ptr ds:[SELFMODIFY_SCAT_add_page_offset_and_enable_5+1], ax
  or   ax, SCAT_PAGE_ENABLE_BIT
  
  
  mov  word ptr ds:[SELFMODIFY_SCAT_add_page_offset_and_enable_4+1], ax

  dec  ax
  mov  word ptr ds:[SELFMODIFY_SCAT_add_page_offset_and_enable_2_minus_1+2], ax
  mov  word ptr ds:[SELFMODIFY_SCAT_add_page_offset_and_enable_1_minus_1+2], ax
  mov  word ptr ds:[SELFMODIFY_SCAT_add_page_offset_and_enable_3_minus_1+2], ax

COMMENT @

; not needed...?
  inc   ax
  and   ax, (NOT SCAT_PAGE_ENABLE_BIT)
  ; ax has offset..

  xchg  ax, dx
  mov   ax, word ptr ds:[chipset_total_memory_pages]


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


@