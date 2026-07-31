
xchg   ax, bx
pop    ax
PUSHA_MACRO

  ; segment mode

  mov   bp, dx
  SHIFT_MACRO shl bp 2  ;  SIZE HANDLE_INFO
  mov   di, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bp + HANDLE_INFO.handle_num_pages]
  test  di, di
  js    func_1701_handle_not_found
  mov   bp, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bp + HANDLE_INFO.handle_first_page]

  cli

func_1701_loop_next_page:
  ; next page in ax....

  lodsw   ; load logical page
  inc   ax
  mov   dx, ax  ; in case its unmap, bx goes forward as -1
  jz    func_1701_skip_logical_check
  dec   dx
  cmp   dx, di   ; bx is the same 
  ja    func_1701_logical_page_too_high

  ; get actual page bx for handle dx

  ; ax is plus one.

  mov   bx, bp  ; first page
  dec   ax

  jz  func_1701_done_looping

func_1701_loop_next_logical_page:
  mov   bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
  dec   ax
  jnz   func_1701_loop_next_logical_page
  
func_1701_done_looping:

  ; bx is now ptr to the actual page...
  sub   bx, OFFSET _RESIDENT_VARIABLE_page_list
  shr   bx, 1  ; board physical page number
  mov   dx, bx

  or   dl, STANDARD_BOARD_PAGE_ON_BIT

func_1701_skip_logical_check:

  ; dx has what to page in..
  ; next page in ax....

  lodsw
  call COMMON_util_get_register_for_segment


  SHIFT_MACRO ror  ax 2
  SELFMODIFY_STANDARD_set_page_select_register_2:
  add   ax, STANDARD_BOARD_PAGE_REGISTER_0
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
