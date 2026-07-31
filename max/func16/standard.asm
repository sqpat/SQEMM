; consider pusha/popa?
; cli/sti? not sure


  xchg  ax, bx ; restore bx
  pop   ax


  cmp   al, 2
  ja    func_16_bad_subfunction
  cbw  
  je    func_16_sub_02
  test  al, al
  push ax
  push dx
  push cx
  push si
  push bx

  lodsw
  xchg ax, cx
  SELFMODIFY_STANDARD_set_page_select_register_9:
  mov   dx, STANDARD_BOARD_PAGE_REGISTER_0

  

  jnz   func_16_sub_01

; fall thru
func_16_sub_00:  
  push di
; ds:si format
; partial_page_map_struct     STRUC
;             mappable_segment_count   DW  ?
;             mappable_segment         DW  (?)  DUP  (?)
;          partial_page_map_struct     ENDS

  mov  ax, cx
  stosw        ; count
  jcxz func_16_00_no_pages


  xor   bx, bx  ; zero bh
func_16_sub_00_save_next_page_frame_register:
  lodsw
  ; ax has segment... 
  call  COMMON_util_get_physical_register_for_segment
  stosw
  SHIFT_MACRO  ror ax 2
  add   dx, ax



  in    al, dx
  xor   ah, ah
  stosw
  and   dh, 3Fh



  loop  func_16_sub_00_save_next_page_frame_register
  func_16_00_no_pages:
  pop   di
func_16_sub_00_done_recording_registers:
func_16_sub_01_done_recording_registers:

func_16_01_no_pages:
func_16_pop_and_return:
  pop   bx
  pop   si
  pop   cx
  pop   dx
  pop   ax ; ah already


iret


func_16_sub_02:
;          GET SIZE OF PARTIAL PAGE MAP SAVE ARRAY SUBFUNCTION

  mov  al, bl ; num pages
  shl  al, 1 ; times four, dword per page.
  inc  ax  ; plus two for cx
  shl  al, 1
iret







func_16_sub_01:


func_16_sub_01_save_next_page_frame_register:
  jcxz func_16_01_no_pages

  lodsw
  SHIFT_MACRO  ror ax 2
  add   dx, ax

  lodsw
  out   dx, al
  and   dh, 3Fh

  loop  func_16_sub_01_save_next_page_frame_register
jmp func_16_sub_01_done_recording_registers


func_16_bad_subfunction:

  mov        ah, 084h
  iret


