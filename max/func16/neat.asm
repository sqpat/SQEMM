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



func_16_sub_00_save_next_page_frame_register:
  lodsw
  ; ax has segment... 
  call  COMMON_util_get_physical_register_for_segment
  stosw
  call  UTIL_map_NEAT_read_page_full
  stosw



  loop  func_16_sub_00_save_next_page_frame_register
  func_16_00_no_pages:
  pop   di
func_16_sub_00_done_recording_registers:
func_16_sub_01_done_recording_registers:

func_16_01_no_pages:
func_16_pop_and_return:

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
  xchg  ax, dx  ; port
  lodsw
  call  UTIL_map_NEAT_write_page_full

  loop  func_16_sub_01_save_next_page_frame_register
jmp func_16_sub_01_done_recording_registers


func_16_bad_subfunction:

  mov        ah, 084h
  iret


