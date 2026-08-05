
func_1700_skip_logical_check:


  lodsw   ; grab physical page

  cmp   al, PAGE_FRAME_COUNT
  jae   func_1700_physical_page_too_high

  ; bx has logical page and ax has page register index now

  cmp   al, SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA ; after 4 is conventional backfill in max mode
  ; default, lets assume backfill
  jb    func_1700_0_pageframe_register
  ; normalize to register 0x4000 hw value
  add   al, (SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000 - SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 
  out SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
 
  inc   bx    ; -1 check
  jz    handle_default_page_1700_conventional
func_1700_continue_page_write:
  ; default is not the -1 case
SELFMODIFY_SCAMP_add_page_offset_3:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 


  loop       func_1700_loop_next_page
  
  ; exits if we fall thru loop with no error
func_1700_exit:
IF COMPISA GE COMPILE_186
  POPA_MACRO
  xor        ah, ah  ; al will be popped after all
iret
ELSE
  xor        ah, ah
  func_1700_pop_and_exit:
  mov        byte ptr cs:[_temp_byte], ah
  POPA_MACRO
  mov        ah, byte ptr cs:[_temp_byte]
  iret
ENDIF

IF COMPISA GE COMPILE_186

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

ELSE


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

ENDIF

func_1700_0_pageframe_register:

SELFMODIFY_SCAMP_add_page_frame_offset_1:  
  add   al, 4 ; add page frame logical to physical translate
  out SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
 
  inc   bx    ; -1 check
  jnz   func_1700_continue_page_write

SELFMODIFY_SCAMP_add_page_frame_offset_13:  
  sub   al, 4  ;subtract page frame logical to physical translate

SELFMODIFY_SCAMP_add_page_offset_minus4_2:
  add   ax, 01000h - SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT ; add page offset minus 4 (we add 4 right after this..)

handle_default_page_1700_conventional:
  ; mapping to page -1
  ; add four to get the default page value for the page 
  add   ax, SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  loop       func_1700_loop_next_page

  
  ; fall thru if done..

IF COMPISA GE COMPILE_186

  POPA_MACRO
  xor        ah, ah
  iret
ELSE
  jmp func_1700_exit
ENDIF
