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
  mov   bl, al
  stosw



  mov   al, byte ptr cs:[bx + _RESIDENT_VARIABLE_driver_local_page_cache]
  xor   ah, ah
  stosw



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

SELFMODIFY_LOTECH_set_page_select_register_10:
  mov   dx, LOTECH_BASE_PAGE_REGISTER

func_16_sub_01_save_next_page_frame_register:
  jcxz func_16_01_no_pages

  lodsw
  mov   bl, al
  add   dl, bl
  lodsw
  out   dx, al
  mov   byte ptr cs:[bx + _RESIDENT_VARIABLE_driver_local_page_cache], al


  sub   dl, bl
  loop  func_16_sub_01_save_next_page_frame_register
jmp func_16_sub_01_done_recording_registers


func_16_bad_subfunction:

  mov        ah, 084h
  iret


