PUSHA_MACRO   ; includes ax


END_FUNC_17_ERROR MACRO

  IF COMPISA GE COMPILE_186
    POPA_MACRO
    iret
  ELSE
    jmp func_1700_pop_and_exit
  ENDIF

ENDM


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
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  END_FUNC_17_ERROR
func_1700_physical_page_too_high:

  mov   ah, 08Bh  ; One or more of the physical pages is out of the range of mappable physical pages, or the log_to_phys_map_len exceeds the number of mappable pages in the system.
  END_FUNC_17_ERROR

func_1700_handle_not_found:
  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  END_FUNC_17_ERROR

ELSE


func_1700_logical_page_too_high:
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  END_FUNC_17_ERROR  
func_1700_physical_page_too_high:
  mov   ah, 08Bh  ; One or more of the physical pages is out of the range of mappable physical pages, or the log_to_phys_map_len exceeds the number of mappable pages in the system.
  END_FUNC_17_ERROR

func_1700_handle_not_found:
  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  END_FUNC_17_ERROR

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
