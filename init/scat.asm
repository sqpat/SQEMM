  ; determine port via chipset register.

  mov   al, SCAT_EMS_CONFIG_REGISTER   ; 
  out   SCAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in    al, SCAT_CHIPSET_CONFIG_REGISTER_READWRITE
  test  al, 1
  mov   ax, 0208h  ; defau
  je    use_default_ports
  ; use port 218/21A not 208/20A
  mov   al, 010h

  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_set_register_1+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_set_register_2+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_set_register_3+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_1+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_2+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_3+1], al
IF COMPILE_VERSION GE DRIVER_VERSION_SMALL
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_4+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_5+1], al
ENDIF

IF COMPILE_VERSION GE DRIVER_VERSION_FULL
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_set_register_4+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_6+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_7+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_8+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_9+1], al
  add   byte ptr ds:[SELFMODIFY_SCAT_set_page_select_register_10+1], al
ENDIF
  mov   ax, 0218h

  use_default_ports:

  stc   ; hex print
  mov   di, OFFSET string_good_port_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_port_param
  call  print_driver_param


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

IF COMPILE_VERSION GE DRIVER_VERSION_SMALL
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_2+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_3+1], al
ENDIF

IF COMPILE_VERSION GE DRIVER_VERSION_FULL
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_4+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_6+1], al
ENDIF  

  add  al, 0Ch
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_1+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_7+1], al

IF COMPILE_VERSION GE DRIVER_VERSION_FULL
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_5+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_8+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_9+1], al
  mov  byte ptr ds:[SELFMODIFY_SCAT_add_page_frame_register_offset_10+1], al
ENDIF
  sub  al, 0Ch

  or   al, SCAT_CHIPSET_AUTOINCREMENT_FLAG

SELFMODIFY_SCAT_set_page_select_register_1:
  mov  dx, SCAT_PAGE_SELECT_REGISTER
  out  dx, al

SELFMODIFY_SCAT_set_page_set_register_1:
  mov  dx, SCAT_PAGE_SET_REGISTER 
  mov  ax, 08040h  ; 080h flag to enable ems. 40h to map to page at 1 MB (64 * 16384)
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

  call  get_SCAT_chipset_bounds_value

  xchg  ax, dx

  call  get_SCAT_chipset_total_memory_pages
  sub   ax, dx

  found_chipset_bounds_value:

  xchg  ax, dx
  call  get_SCAT_chipset_bounds_value
  add   ax, dx
  xchg  ax, cx   ; cx = bounds + page count
  call  get_SCAT_chipset_total_memory_pages

  cmp   cx, ax
  xchg  ax, dx
  jbe   page_count_bounds_ok

  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED

  page_count_bounds_ok:

  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], ax
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax


  mov   di, OFFSET string_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_count_param
  call  print_driver_param_4_char_int



  mov   ah, "O"  ; page offset
  call  parse_driver_params_get_int  ; no default. instead fetch from chipswt

  jc    found_page_offset_bounds


  call  get_SCAT_chipset_bounds_value
  found_page_offset_bounds:

  ; ax has offset..

  xchg  ax, dx
  call  get_SCAT_chipset_total_memory_pages

  mov   cx, dx
  add   cx, word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1] ; cx = ems page count + offset
  cmp   cx, ax                             ; compare to total ems pages
  xchg  ax, dx  ; get page offset back in ax
  jbe   done_with_page_offset_bounds_check

  ; overーallocated?

  mov  DX, OFFSET string_bad_page_offset_param
  jmp  DRIVER_NOT_INSTALLED

  done_with_page_offset_bounds_check:

  push  ax

  mov   di, OFFSET string_good_page_offset_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_offset_param
  call  print_driver_param_4_char_int

  pop   ax

  or    ax, SCAT_PAGE_ENABLE_BIT
  
  mov  word ptr ds:[SELFMODIFY_SCAT_add_page_offset_and_enable_1+2], ax
  mov  word ptr ds:[SELFMODIFY_SCAT_add_page_offset_and_enable_2+2], ax
  
IF COMPILE_VERSION GE DRIVER_VERSION_FULL
  mov  word ptr ds:[SELFMODIFY_SCAT_add_page_offset_and_enable_3+2], ax
ENDIF

