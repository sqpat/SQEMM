
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

; bp has first page ptr.
; di has num logical pages

func_1701_loop_next_page:
  ; next page in ax....

  lodsw   ; load logical page
  mov        bx, ax  ; in case its unmap, bx goes forward as -1
  inc        ax
  jz         func_1701_skip_logical_check
  cmp        bx, di   ; bx is the same 
  ja         func_1701_logical_page_too_high

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


func_1701_skip_logical_check:

  lodsw   ; grab physical page

  call COMMON_util_get_register_for_segment
    test       ax, ax
    js         func_1701_physical_page_too_high
    cmp        al, PAGE_FRAME_COUNT
    jae        func_1701_physical_page_too_high

  ; bx has logical page and ax has page register index now

  cmp   al, FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA ; after 4 is conventional backfill in max mode
  ; default, lets assume backfill
  jb    func_1701_0_pageframe_register
  ; normalize to register 0x4000 hw value
  add   al, (FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000 - FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  out FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
 
  inc  bx    ; -1 check
  jz    func_1701_handle_default_page
  ; default is not the -1 case
SELFMODIFY_FANTASY_set_page_offset_4:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 


  loop       func_1701_loop_next_page
  
  ; exits if we fall thru loop with no error
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

IF COMPISA GE COMPILE_186


func_1701_logical_page_too_high:
  POPA_MACRO
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  iret


func_1701_handle_not_found:
  POPA_MACRO
  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  iret

func_1701_physical_page_too_high:
  POPA_MACRO
  mov   ah, 08Bh  ; One or more of the physical pages is out of the range of mappable physical pages, or the log_to_phys_map_len exceeds the number of mappable pages in the system.
  iret


ELSE

func_1701_logical_page_too_high:
  mov   ah, 08Ah  ; One or more of the mapped logical pages is out of the range of logical pages allocated to the EMM handle.
  jmp func_1701_pop_and_exit


func_1701_handle_not_found:

  mov   ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
  jmp func_1701_pop_and_exit

func_1701_physical_page_too_high:

  mov   ah, 08Bh  ; One or more of the physical pages is out of the range of mappable physical pages, or the log_to_phys_map_len exceeds the number of mappable pages in the system.
  jmp func_1701_pop_and_exit
  

ENDIF


func_1701_0_pageframe_register:

SELFMODIFY_FANTASY_add_page_frame_offset_5:  
  add   al, 4 ; need to add 4 for d000 case for FANTASY...  c000, e000  not supported
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
  inc   bx    ; -1 check
  jz    func_1701_handle_default_page
SELFMODIFY_FANTASY_set_page_offset_5:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  loop       func_1701_loop_next_page
  

  ; exits if we fall thru loop with no error
IF COMPISA GE COMPILE_186

  POPA_MACRO
  xor   ah, ah
  iret
ELSE
  jmp func_1701_exit
ENDIF

func_1701_handle_default_page:
  ; mapping to page -1
  xchg ax, bx
  dec  ax
  out  FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  loop       func_1701_loop_next_page
  
  ; fall thru if done..
IF COMPISA GE COMPILE_186

  POPA_MACRO
  xor   ah, ah
  iret
ELSE
  jmp func_1701_exit
ENDIF
  _temp_byte:
  db, 0
