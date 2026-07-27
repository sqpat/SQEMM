PUSHA_MACRO   ; includes ax


  ; physical page number mode


  mov   bp, dx          ; handle 
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
  inc   ax
  mov   dx, ax  ; if dx is zero then it carries forward
  jz    func_1700_skip_logical_check
  dec   dx
  cmp   dx, di  ; still decced
  ja    func_1700_logical_page_too_high

  ; get actual page bx for handle dx

  mov   bx, bp  ; first page
  dec   ax      ; ax was still plus one.

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
