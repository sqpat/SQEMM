  ; enable EMS

  mov  al, NEAT_CHIPSET_DRAM_CONFIG_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  or   al, NEAT_CHIPSET_DRAM_CONFIG_REGISTER_EMS_ENABLE_BIT
  out  NEAT_CHIPSET_CONFIG_REGISTER_READWRITE, al


; fetch port from chipset

  mov  al, NEAT_CHIPSET_EMS_CONFIG_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and  ax, 0Fh  ; zero ah... keep just 4 low bits
  xchg ax, bx
  mov  al, byte ptr cs:[_NEAT_PORT_LOOKUP + bx]
  test al, al
  jz   bad_port_param_chipset
  mov   ah, 2

; high byte always 2. dont need to set...
  mov   byte ptr ds:[SELFMODIFY_NEAT_set_page_select_register_1+2], al
  mov   byte ptr ds:[SELFMODIFY_NEAT_set_page_select_register_2+2], al
  mov   byte ptr ds:[SELFMODIFY_NEAT_set_page_select_register_3+1], al
  mov   byte ptr ds:[SELFMODIFY_NEAT_set_page_select_register_4+1], al
  ; port set.

  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter
  mov   di, OFFSET STRING_good_port_param_EDIT_OFFSET
  mov   dx, OFFSET STRING_good_port_param
  stc   ; hex print
  call  print_driver_param


jmp  find_neat_page_offset; make some space for branches

bad_page_frame_param_chipset:
  ; bad page frame param! error?
  mov  DX, OFFSET STRING_bad_page_frame_chipset
  jmp  DRIVER_NOT_INSTALLED
bad_page_frame_param:
  ; bad page frame param! error?
  mov  DX, OFFSET string_bad_page_frame_param
  jmp  DRIVER_NOT_INSTALLED
bad_port_param_chipset:
  ; bad page frame param! error?
  mov  DX, OFFSET STRING_bad_port_chipset
  jmp  DRIVER_NOT_INSTALLED
bad_port_param:
  ; bad page frame param! error?
  mov  DX, OFFSET string_bad_port_param
  jmp  DRIVER_NOT_INSTALLED



; for now offset pages by 2 MB TODO 
find_neat_page_offset:




; init page frame to pages 0-3




; fetch page frame from chipset

  mov  al, NEAT_CHIPSET_EMS_CONFIG_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and  ax, 0F0h
  cmp  al, 080h
  ja   bad_page_frame_param_chipset

  SHIFT_MACRO shr al 2
  add  al, 0C0h
  

  mov   byte ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+2], al ; just write high byte.
  mov   byte ptr ds:[chipset_page_lookup+0], al
  mov   byte ptr ds:[mappable_phys_page_struct_page_frame+1], al
  add   al, 4
  mov   byte ptr ds:[chipset_page_lookup+1], al
  mov   byte ptr ds:[mappable_phys_page_struct_page_frame+5], al
  add   al, 4
  mov   byte ptr ds:[chipset_page_lookup+2], al
  mov   byte ptr ds:[mappable_phys_page_struct_page_frame+9], al
  add   al, 4
  mov   byte ptr ds:[chipset_page_lookup+3], al
  mov   byte ptr ds:[mappable_phys_page_struct_page_frame+13], al

  sub   al, 12
  mov   ah, al
  xor   al, al
  
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter
  stc   ; hex print
  mov   di, OFFSET string_good_page_frame_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_frame_param
  call  print_driver_param

COMMENT @
; are we really supposed to pre-allocate? dont think so...
  xor   ax, ax
  cwd
  call  UTIL_map_NEAT_write_page_full
  inc   ax
  inc   dx
  call  UTIL_map_NEAT_write_page_full
  inc   ax
  inc   dx
  call  UTIL_map_NEAT_write_page_full
  inc   ax
  inc   dx
  call  UTIL_map_NEAT_write_page_full
@



  mov  ax, NEAT_PAGE_OFFSET_AMT ; todo: get total system memory and subtract ems size.

  mov  word ptr ds:[SELFMODIFY_NEAT_add_page_offset+1], ax
  mov  word ptr ds:[SELFMODIFY_NEAT_sub_page_offset+1], ax




; todo determine size, offset, etc
; todo parse params.

  mov   ax, NEAT_CHIPSET_EMS_SIZE_REGISTER ; zero ah
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and  al, 0E0h  ; bits 5-7

  ; bits 5-7 = number of megabytes of EMS. one megabyte is 64 pages. 

  shl   ax, 1

  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax

  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter
  clc   ; hex print
  mov   di, OFFSET STRING_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET STRING_good_page_count_param
  mov   cx, 3
  call  print_driver_param


  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?

