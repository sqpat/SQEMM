

func_1701_skip_logical_check:
  mov   dx, bx

  ; next page in ax....

  lodsw
  call COMMON_util_get_register_for_segment
  mov  bx, ax
  SELFMODIFY_LOTECH_set_page_select_register_8:
  add   ax, LOTECH_BASE_PAGE_REGISTER
  xchg  ax, dx

  out   dx, al   ; write 8 bit page num. 
  mov   byte ptr cs:[bx + _RESIDENT_VARIABLE_driver_local_page_cache], al

  loop       func_1701_loop_next_page
  sti


  ; exit fall thru

  func_1701_exit:
IF COMPISA GE COMPILE_186
  POPA_MACRO
  xor        ah, ah  ; al will be popped after all
ELSE
  xor        ah, ah
  func_1701_pop_and_exit:
  mov        byte ptr cs:[_temp_byte], ah
  POPA_MACRO
  mov        ah, byte ptr cs:[_temp_byte]
ENDIF

  iret

func_1701_handle_not_found:
  POPA_MACRO
  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  iret
func_1701_logical_page_too_high:
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  jmp func_1701_pop_and_exit
_temp_byte:
  db, 0
