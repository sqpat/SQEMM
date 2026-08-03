  PUSHA_MACRO  ; includes ax


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

  mov   bx, ax  ; in case its unmap, bx goes forward as -1
  inc   ax
  jz    func_1700_skip_logical_check
  cmp   bx, di
  ja    func_1700_logical_page_too_high

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


func_1700_skip_logical_check:
  lodsw   ; grab physical page

  mov   dx, WD76C10_PAGE_SELECT_REGISTER

  xchg  ax, bx
  mov   bl, byte ptr cs:[WF76C10_api_to_physical_page_lookup+bx]
  xchg  ax, bx
  
  out   dx, ax   ; select EMS page

  mov   dx, WD76C10_PAGE_SET_REGISTER

  inc   bx    ; -1 check
  jz    func_1700_handle_default_page
  SELFMODIFY_WD76C10_add_page_offset_1_minus_1:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page

  out   dx, ax   ; write 16 bit page num. 

  loop  func_1700_loop_next_page



  ; exit fall thru
  POPA_MACRO
  xor ah, ah  ; success
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

func_1700_handle_default_page:

  ; mapping to page -1
  cmp   al, 8
  jb    func_1700_adjust_08000h
  cmp   al, 32
  jb    func_1700_write_ax
  xchg  ax, bx  ; zero
  func_1700_write_ax:
;  does 0x8000 flag matter?
  ; mapping to page -1
  out   dx, ax   ; write 16 bit page num. 
  loop  func_1700_loop_next_page

  ; exit fall thru
  POPA_MACRO
  xor ah, ah  ; success
  iret
func_1700_adjust_08000h:
  add   al, 32
  out   dx, ax   ; write 16 bit page num. 
  loop  func_1700_loop_next_page

  ; exit fall thru
  POPA_MACRO
  xor ah, ah  ; success
  iret
