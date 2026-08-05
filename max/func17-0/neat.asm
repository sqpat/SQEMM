func_1700_skip_logical_check:

  mov   dx, bx
; dx has page to write.
  lodsw
  
  xchg  ax, dx
  call  UTIL_map_NEAT_write_page_full

  loop       func_1700_loop_next_page



  POPA_MACRO
  xor        ah, ah

  iret


func_1700_logical_page_too_high:
  POPA_MACRO
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  iret
func_1700_physical_page_too_high:
  POPA_MACRO
  mov   ah, 08Bh  ; One or more of the physical pages is out of the range of mappable physical pages, or the log_to_phys_map_len exceeds the number of mappable pages in the system.
  iret

func_1700_handle_not_found:
  POPA_MACRO
  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  iret
