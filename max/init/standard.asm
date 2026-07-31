


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


  mov   ah, "P"  ; port
  call  parse_driver_params
  mov   ax, STANDARD_BOARD_PAGE_REGISTER_0   
  jnc   get_port_from_chipset
  xor   bx, bx
  xor   dx, dx


  loop_next_digit:
    mov   al, byte ptr es:[bx+di]
    sub   al, '0'
    jb    done_parsing_port
    cmp   al, 9
    jbe   mul_and_add_this_port_digit
    sub   al, 'A' - '0' - 10 ; A = 10, B = 11, etc.
    jb    done_parsing_port
    cmp   al, 0Fh
    ja    done_parsing_port



    mul_and_add_this_port_digit:
    SHIFT_MACRO shl dx 4
    add   dl, al
    inc   bx
    

    jmp  loop_next_digit
done_parsing_port: ; hit a non-hex char
  xchg  ax, dx  ; dx had parsed port. put it in ax
get_port_from_chipset:

  ; ax has port.

  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_1+1], ax
  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_2+1], ax
  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_3+1], ax
  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_4+1], ax
  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_5+1], ax
  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_6+1], ax
  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_7+1], ax
  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_8+1], ax
  mov   word ptr ds:[SELFMODIFY_STANDARD_set_page_select_register_9+1], ax


  mov   di, OFFSET STRING_good_port_param_EDIT_OFFSET
  mov   dx, OFFSET STRING_good_port_param
  stc   ; hex print
  call  print_driver_param


; todo: support page count being non 128?


  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], MAX_PAGE_COUNT
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], MAX_PAGE_COUNT
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], STANDARD_BOARD_CONST_PAGE_COUNT

