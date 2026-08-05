func_1700_skip_logical_check:


  mov   dx, bx ; dx gets page
  lodsw
  mov   bx, ax
  SELFMODIFY_LOTECH_set_page_select_register_7:
  add   ax, LOTECH_BASE_PAGE_REGISTER
  xchg  ax, dx ; put both where they need to be..
  out   dx, al   ; write 8 bit page num. 
  
  mov   byte ptr cs:[bx + _RESIDENT_VARIABLE_driver_local_page_cache], al



  loop       func_1700_loop_next_page
  sti


IF COMPISA GE COMPILE_186
  POPA_MACRO
  xor        ah, ah  ; al will be popped after all
ELSE
  xor        ah, ah
  func_1700_pop_and_exit:
  mov        byte ptr cs:[_temp_byte], ah
  POPA_MACRO
  mov        ah, byte ptr cs:[_temp_byte]
ENDIF

  iret


func_1700_logical_page_too_high:
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  jmp func_1700_pop_and_exit
func_1700_physical_page_too_high:
  mov   ah, 08Bh  ; One or more of the physical pages is out of the range of mappable physical pages, or the log_to_phys_map_len exceeds the number of mappable pages in the system.
  jmp func_1700_pop_and_exit

func_1700_handle_not_found:
  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  jmp func_1700_pop_and_exit
