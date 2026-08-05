func_1701_skip_logical_check:

  mov   dx, bx

  ; dx has what to page in..
  ; next page in ax....

  lodsw
  call COMMON_util_get_register_for_segment


  xchg  ax, dx ; put both where they need to be..
  call  UTIL_map_NEAT_write_page_full


  loop       func_1701_loop_next_page



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
