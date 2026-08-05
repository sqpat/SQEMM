
SELFMODIFY_NEAT_set_page_offset_3:
  add   bx, NEAT_PAGE_OFFSET_AMT   ; turn on EMS ON bit
func_1701_skip_logical_check:
  mov   dx, bx

  ; dx has what to page in..
  ; next page in ax....

  lodsw
  call COMMON_util_get_register_for_segment


  SHIFT_MACRO ror  ax 2
  SELFMODIFY_NEAT_set_page_select_register_2:
  add   ax, NEAT_PAGE_REGISTER_0
  xchg  ax, dx ; put both where they need to be..

  out   dx, al   ; write 8 bit page num. 

  loop       func_1701_loop_next_page
  sti


  ; exit fall thru

  func_1701_exit:
  POPA_MACRO
  xor        ah, ah

  iret

func_1701_handle_not_found:
  POPA_MACRO
  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  iret
func_1701_logical_page_too_high:
  POPA_MACRO
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  iret
_temp_byte:
  db, 0
