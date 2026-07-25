

; determine page frame

  mov   ah, "F" 
  call  parse_driver_params

  ; chipset has no real default or set param, so use D000 by default if none defined.

  jnc   skip_page_frame_set   ; param not found, use default

  mov   ax, word ptr es:[di]
  cmp   ah, '0'
  jne   bad_page_frame_param  ; must be c000 d000 e000 f000, 2nd char must be 0.
  sub   al, 'C'
  jb    bad_page_frame_param
  cmp   al, 'F'-'C'
  jbe   set_page_frame

bad_page_frame_param:
  ; bad page frame param! error?
  mov  DX, OFFSET string_bad_page_frame_param
  jmp  DRIVER_NOT_INSTALLED

found_page_frame:
  dw 0
found_port:
  dw 0
found_page_count:
  dw 128   ; todo: determine programatically and default to 0 


set_page_frame:
; al is 0-3
  add   al, 0Ch  ; now C-F
  cbw   ; ah 0
  SHIFT_MACRO ROR ax 4  ; now C000, D000, E000, F000
  mov   bx, ax ; backup
  mov   word ptr ds:[found_page_frame], ax  ; store for now

  stc   ; hex print
  mov   di, OFFSET string_good_page_frame_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_frame_param
  call  print_driver_param


skip_page_frame_set:

  mov   ah, "P"  ; port
  call  parse_driver_params
  jnc   skip_port_set


  mov   ax, word ptr es:[di]
  cmp   ax, ("2" SHL 8) + "6" ; first two chars should be "26"
  jne   bad_port_param
  mov   al, byte ptr es:[di+2]
  sub   al, '0'
  je    set_port
  cmp   al, 4
  je    set_port
  cmp   al, 8
  je    set_port
  cmp   al, 'C' - '0'
  mov   al, 12
  je    set_port


bad_port_param:
  mov  DX, OFFSET STRING_bad_port_param
  jmp  DRIVER_NOT_INSTALLED
bad_page_count_param:
  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED

jmp_to_have_port_and_page_frame:
  jmp  have_port_and_page_frame
set_port:
  cbw
  add   ax, 0260h
  mov   word ptr ds:[found_page_frame], ax  ; store for now



skip_port_set:



  mov   ah, "C" ; page count
  call  parse_driver_params_get_int  ; no default. instead fetch from chipswt
  jnc   no_page_count_param
  cmp   ax, 256
  ja    bad_page_count_param
  mov   word ptr ds:[found_page_count], ax  ; store for now

  mov   di, OFFSET string_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_count_param
  call  print_driver_param_4_char_int


  no_page_count_param:

  ; ok - we have tried to parse the 3 params.
  ; but if the absense of any, lets try and determine the default.

  mov  ax, word ptr ds:[found_port]
  or   ax, word ptr ds:[found_page_frame]
  jnz  jmp_to_have_port_and_page_frame

  ; 1: decided on port and or loop
  mov  dx, word ptr ds:[found_port]
  mov  cx, 1
  test dx, dx
  jnz  skip_port_loop

  mov  cx, 4
  mov  dx, LOTECH_BASE_PAGE_REGISTER - 4

  skip_port_loop:
  do_port_loop:
    add   dx, 4
    push  cx

    mov  bx, word ptr ds:[found_page_frame]    
    mov  cx, 1
    test bx, bx
    jnz  skip_page_frame_loop

    mov  bx, 0C000h
    mov  cx, 4



    skip_page_frame_loop:
    do_page_frame_loop:
      add   bh, 010h
      jnc   page_frame_valid
      mov   bh, 0C0h
      page_frame_valid:

      xor   ax, ax
      out   dx, al  ; page 0. should make the page frame valid.

      mov   es, bx
      mov   al, byte ptr es:[0] ; store
      mov   ah, byte ptr es:[0] ; store
      cmp   al, ah
      jne   bad_memory_skip_page_frame
      cli
      xor   al, 0FFh
      mov   byte ptr es:[0], al
      cmp   byte ptr es:[0], al
      jne   bad_memory_skip_page_frame ; not writable?
      mov   byte ptr es:[0], ah  ; restore
      ; ah still has old value...      
      mov   al, 1
      out   dx, al

      mov   al, byte ptr es:[0] ; store
      inc   ah
      mov   byte ptr es:[0], ah
      cmp   byte ptr es:[0], ah
      jne   bad_memory_skip_page_frame  
      ; 2nd page writable. but are they different? 
      xchg  ax, si
      xor   ax, ax
      out   dx, al ; page 0 again.
      xchg  ax, si
      dec   ah
      cmp   byte ptr es:[0], ah
      je    found_port_and_page_frame
      ; 1st and 2nd page are the same after all.







      bad_memory_skip_page_frame:
      sti
      loop  do_page_frame_loop

    pop   cx
    loop  do_port_loop
  
  ; error, could not dynamically determine and was not specified
  
  mov  DX, OFFSET STRING_could_not_determine
  jmp  DRIVER_NOT_INSTALLED


  found_port_and_page_frame:
  mov   word ptr ds:[found_port], dx
  mov   word ptr ds:[found_page_frame], es
  pop   cx

  push  cs
  pop   es
  

  mov   DX, OFFSET STRING_dynamic_determine
  mov   ah, 9  ; PRINT_STRING
  int   021h


  mov   ax, word ptr ds:[found_page_frame]
  mov   di, OFFSET string_good_page_frame_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_frame_param
  stc   ; hex print
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_dynamic_parameter
  call  print_driver_param

  mov   ax, word ptr ds:[found_port]

  mov   di, OFFSET STRING_good_port_param_EDIT_OFFSET
  mov   dx, OFFSET STRING_good_port_param
  stc   ; hex print
  call  print_driver_param



  have_port_and_page_frame:
  mov   ax, word ptr ds:[found_port]


  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_3+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_4+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_5+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_7+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_8+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_10+1], ax

  
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_2+2], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_9+2], ax



  xchg  ax, dx
  xor   ax, ax   ; default pages 0-3 i guess.
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 


; todo parse
  mov   ax, word ptr ds:[found_page_frame]
  mov   word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], ax

  mov   al, ah
  mov   byte ptr ds:[chipset_page_lookup+0], al
  mov   byte ptr ds:[mappable_phys_page_struct_page_frame+0], al
  add   al, 4
  mov   byte ptr ds:[chipset_page_lookup+1], al
  mov   byte ptr ds:[mappable_phys_page_struct_page_frame+4], al
  add   al, 4
  mov   byte ptr ds:[chipset_page_lookup+2], al
  mov   byte ptr ds:[mappable_phys_page_struct_page_frame+8], al
  add   al, 4
  mov   byte ptr ds:[chipset_page_lookup+3], al
  mov   byte ptr ds:[mappable_phys_page_struct_page_frame+12], al

  mov   ax, word ptr ds:[found_page_count]


  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax
  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT



