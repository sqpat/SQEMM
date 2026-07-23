PUSHA_MACRO   ; includes ax


  ; physical page number mode


  mov   bp, dx
  SHIFT_MACRO shl bp 2  ;  SIZE HANDLE_INFO
  mov   di, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bp + HANDLE_INFO.handle_num_pages]
  test  di, di
  js    func_1700_handle_not_found
  mov   bp, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bp + HANDLE_INFO.handle_first_page]

; bp has first page ptr.
; di has num logical pages

func_1700_loop_next_page:
  ; next page in ax....

  lodsw   ; load logical page
  mov        bx, ax  ; in case its unmap, bx goes forward as -1
  inc        ax
  jz         func_1700_skip_logical_check
  cmp        bx, di
  ja         func_1700_logical_page_too_high

  ; get actual page bx for handle dx

  ; ax is plus one

  mov   bx, bp  ; first page
  dec   ax

  jz  func_1700_done_looping

func_1700_loop_next_logical_page:
  mov   bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
  dec   ax
  jnz   func_1700_loop_next_logical_page
  
func_1700_done_looping:

  ; bx is now ptr to the actual page...
  sub   bx, OFFSET _RESIDENT_VARIABLE_page_list
  shr   bx, 1  ; board physical page number
  mov   dx, bx

func_1700_skip_logical_check:

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
