  ; enable EMS

  mov  al, NEAT_CHIPSET_DRAM_CONFIG_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  or   al, NEAT_CHIPSET_DRAM_CONFIG_REGISTER_EMS_ENABLE_BIT
  out  NEAT_CHIPSET_CONFIG_REGISTER_READWRITE, al


  mov   ah, "P"  ; port
  call  parse_driver_params
  jnc   get_port_from_chipset


  mov   ax, word ptr es:[di]
  cmp   al, "2" ; first char should be "2"
  jne   bad_port_param
  cmp   byte ptr es:[di+2], "8"
  jne   bad_port_param
  mov   al, ah
  sub   al, '0'
  je    set_port
  cmp   al, 9
  jb    set_port
  sub   al, 'A' - '0' - 10 ; A = 10, B = 11, etc.
  jb    bad_port_param
  cmp   al, 0Fh
  jbe   set_port


bad_port_param:
  mov  DX, OFFSET STRING_bad_port_param
  jmp  DRIVER_NOT_INSTALLED
bad_port_param_chipset:
  ; bad page frame param! error?
  mov  DX, OFFSET STRING_bad_port_chipset
  jmp  DRIVER_NOT_INSTALLED

set_port:
  ; al is 0-F
  cbw
  xchg  ax, bx
  cmp  byte ptr ds:[_NEAT_PORT_LOOKUP + bx], bh ; check for zero
  je   bad_port_param_chipset
  
  mov  al, NEAT_CHIPSET_EMS_CONFIG_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and  al, 0F0h  ; zero ah... keep just 4 low bits
  or   al, bl
  out  NEAT_CHIPSET_CONFIG_REGISTER_READWRITE, al  
  
  mov  al, byte ptr ds:[_NEAT_PORT_LOOKUP + bx] ; get this now

  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter
  jmp   got_port

get_port_from_chipset:


; fetch port from chipset

  mov  al, NEAT_CHIPSET_EMS_CONFIG_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and  ax, 0Fh  ; zero ah... keep just 4 low bits
  xchg ax, bx
  mov  al, byte ptr ds:[_NEAT_PORT_LOOKUP + bx]
  test al, al
  jz   bad_port_param_chipset
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter

got_port:
  mov   ah, 2
; high byte always 2. dont need to set...
  mov   byte ptr ds:[SELFMODIFY_NEAT_set_page_select_register_1+2], al
  mov   byte ptr ds:[SELFMODIFY_NEAT_set_page_select_register_2+2], al
  mov   byte ptr ds:[SELFMODIFY_NEAT_set_page_select_register_3+1], al
  mov   byte ptr ds:[SELFMODIFY_NEAT_set_page_select_register_4+1], al
  ; port set.

  mov   di, OFFSET STRING_good_port_param_EDIT_OFFSET
  mov   dx, OFFSET STRING_good_port_param
  stc   ; hex print
  call  print_driver_param


jmp  find_neat_page_offset; make some space for branches

get_page_frame_from_chipset:
; fetch page frame from chipset


  mov  al, NEAT_CHIPSET_EMS_CONFIG_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and  ax, 0F0h
  cmp  al, 080h
  ja   bad_page_frame_param_chipset

  SHIFT_MACRO shr al 2

  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter
  jmp  got_page_frame

bad_page_frame_param_chipset:
  ; bad page frame param! error?
  mov  DX, OFFSET STRING_bad_page_frame_chipset
  jmp  DRIVER_NOT_INSTALLED
bad_page_frame_param:
  ; bad page frame param! error?
  mov  DX, OFFSET string_bad_page_frame_param
  jmp  DRIVER_NOT_INSTALLED




; for now offset pages by 2 MB TODO 
find_neat_page_offset:




; init page frame to pages 0-3


; determine page frame

  mov   ah, "F" 
  call  parse_driver_params

  jnc   get_page_frame_from_chipset   ; param not found, use default

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
  jne   bad_page_frame_param


  set_page_frame:

  ; ah is 0 1 or 2    (C D or E)
  ; al is 0 4 8 or 12
  cmp   ah, 2
  jne   skip_e000_plus_check
  test  al, al
  jnz   bad_page_frame_param
  skip_e000_plus_check:
  mov   bx, ax ; backup
  mov   dx, ax ; backup

; program the chipset with this value

  mov  al, NEAT_CHIPSET_EMS_CONFIG_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and  al, 0Fh

  xchg ax, bx ; restore backup, store IN value in bx.
  
  SHIFT_MACRO shr   al, 2     ; 0 4 8 C to 1 2 3  (C D E)
  SHIFT_MACRO shl   ah, 2     ; 0 1 2 to 0 4 8  (C D E)
  or   al, ah
  SHIFT_MACRO shl   al, 4
  or   al, bl
  out  NEAT_CHIPSET_CONFIG_REGISTER_READWRITE, al  ; programmed our EMS page frame. 


  xchg  ax, dx ; restore again
  SHIFT_MACRO shl   ah, 4  ; 0 1 2 to 00 10 20  (C D E)
  or    al, ah

  mov  word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter


got_page_frame:

  add   al, 0C0h
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

  mov   ah, "C"  ; page count
  call  parse_driver_params_get_int  ; no default. instead fetch from chipswt
  jnc   no_page_count_param
  cmp   ax, PAGE_COUNT_7_MB
  ja    bad_page_count_param
  mov  word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter

got_page_count:

  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax


  clc   ; int print
  mov   di, OFFSET STRING_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET STRING_good_page_count_param
  mov   cx, 3
  call  print_driver_param





; offset

  ; todo why is this not working....
  mov   ah, "O"  ; page offset
  call  parse_driver_params_get_int  ; no default. instead fetch from chipswt

  jnc   get_offset_from_chipset 

  mov  word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter
  ; todo any checks?
  jmp   got_offset

no_page_count_param:
  mov   ax, NEAT_CHIPSET_EMS_SIZE_REGISTER ; zero ah
  out   NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in    al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and   al, 0E0h  ; bits 5-7

  ; bits 5-7 = number of megabytes of EMS. one megabyte is 64 pages. 

  shl   ax, 1
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter
  jmp   got_page_count

bad_page_count_param:
  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED



get_offset_from_chipset:


  mov  ax, NEAT_CHIPSET_MEMORY_SIZE_BANK01_REGISTER ; zero ah
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  mov  ah, al

  mov  al, NEAT_CHIPSET_MEMORY_SIZE_BANK23_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and  ax, 00E0E0h  ; bits 5-7

  SHIFT_MACRO shr ax 5
  sub  ax, 0303h


  xor  bx, bx
  mov  bl, al
  mov  al, byte ptr ds:[bx+_NEAT_DRAM_BANK_LOOKUP]
  mov  bl, ah
  xor  ah, ah
  mov  bl, byte ptr ds:[bx+_NEAT_DRAM_BANK_LOOKUP]
  inc  ax
  inc  bx
  add  ax, bx
  ; now bx has system memory in pages.

  
  sub   ax, word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count] ; subtract page count to get EMS start position.
  ; do we have to add 4 for umb sanity...? i.e 7 MB setting
  ; tested and it seems fine? because no xms/UMBs are allocated in 7mb setting?

  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter
got_offset:

  mov  word ptr ds:[SELFMODIFY_NEAT_add_page_offset+1], ax
  mov  word ptr ds:[SELFMODIFY_NEAT_sub_page_offset+1], ax
  mov  word ptr ds:[_INIT_PARAM_OFFSET], ax


  clc   ; int print
  mov   di, OFFSET STRING_good_page_offset_param_EDIT_OFFSET
  mov   dx, OFFSET STRING_good_page_offset_param
  mov   cx, 3
  call  print_driver_param


  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT

