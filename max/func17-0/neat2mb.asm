  SELFMODIFY_NEAT_set_page_offset_2:
  add   bx, NEAT_PAGE_OFFSET_AMT   ; turn on EMS ON bit

func_1700_skip_logical_check:

  mov  dx, bx
; dx has page to write.
  lodsw
  SHIFT_MACRO ror  ax 2
  SELFMODIFY_NEAT_set_page_select_register_1:
  add   ax, NEAT_PAGE_REGISTER_0
  xchg  ax, dx ; put both where they need to be..
  
    
  out   dx, al   ; write 8 bit page num. 

  loop       func_1700_loop_next_page
  sti


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
