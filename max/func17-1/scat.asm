
func_1701_skip_logical_check:
  lodsw   ; grab physical page
  call COMMON_util_get_register_for_segment

SELFMODIFY_SCAT_set_page_select_register_8:
  mov   dx, SCAT_PAGE_SELECT_REGISTER

  sub   al, SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   func_1701_do_conventional_map
  SELFMODIFY_SCAT_add_page_frame_register_offset_8:
  add   al, SCAT_PAGE_C000_REGISTER_OFFSET ; convert 0-4 to page frame. adds back subtracted SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA too
  func_1701_do_conventional_map:   ; conventional page should be good.

  
  out   dx, al   ; select EMS page
SELFMODIFY_SCAT_set_page_set_register_4:
  mov   dx, SCAT_PAGE_SET_REGISTER
  inc   bx   ; -1 check
  jz    func_1701_handle_default_page
  SELFMODIFY_SCAT_add_page_offset_and_enable_3_minus_1:
  lea   ax, [BX + SCAT_PAGE_OFFSET_AMT - 1]   ; offset by default starting page

  out   dx, ax   ; write 16 bit page num. 

  loop  func_1701_loop_next_page



  ; exit fall thru
  POPA_MACRO
  xor ah, ah  ; success
  iret

func_1701_logical_page_too_high:
  POPA_MACRO
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  iret
func_1701_physical_page_too_high:
  POPA_MACRO
  mov   ah, 08Bh  ; One or more of the physical pages is out of the range of mappable physical pages, or the log_to_phys_map_len exceeds the number of mappable pages in the system.
  iret

func_1701_handle_not_found:
  POPA_MACRO
  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  iret

  func_1701_handle_default_page:
  ; mapping to page -1
  xchg  ax, bx   ; get 0
  out   dx, ax   ; write 16 bit page num. 
  loop  func_1701_loop_next_page



  ; exit fall thru
  POPA_MACRO
  xor ah, ah  ; success
  iret