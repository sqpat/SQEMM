; consider pusha/popa?
; cli/sti? not sure

  push ax  ; restore into bx 
  push dx
  push cx
  push di
  push si
  
SELFMODIFY_LOTECH_set_page_select_register_10:
  mov   dx, LOTECH_BASE_PAGE_REGISTER

  cmp   byte ptr cs:[_current_call_subfunction_value], 2
  ja    func_16_bad_subfunction
  je    func_16_sub_02
  jpo   func_16_sub_01

; fall thru
func_16_sub_00:

; ds:si format
; partial_page_map_struct     STRUC
;             mappable_segment_count   DW  ?
;             mappable_segment         DW  (?)  DUP  (?)
;          partial_page_map_struct     ENDS

  lodsw
  stosw        ; count
  xchg  ax, cx ; count

func_16_sub_00_save_next_page_frame_register:
  lodsw
  ; ax has segment... 
  call  COMMON_util_get_physical_register_for_segment
  
  add   dl, al
  push  ax
  in    al, dx
  xor   ah, ah
  stosw
  pop   ax
  sub   dl, al  ; reset port

  loop  func_16_sub_00_save_next_page_frame_register

func_16_sub_00_done_recording_registers:
func_16_sub_01_done_recording_registers:
  xchg  ax, cx  ; zero ax

func_16_pop_and_return:
  pop   si
  pop   di
  pop   cx
  pop   dx
  pop   bx ; restore from ax
  pop   ax
  xor   ah, ah

iret


func_16_sub_02:
;          GET SIZE OF PARTIAL PAGE MAP SAVE ARRAY SUBFUNCTION
  pop   si
  pop   di
  pop   cx
  pop   dx
  pop   bx ; restore from ax

  pop   ax
  xor   ah, ah
  mov  al, bl ; num pages

  SHIFT_MACRO shl  al 2 ; two words per entry.
  add  al, 2  ; count
iret







func_16_sub_01:
  lodsw
  xchg ax, cx  ; count
func_16_sub_01_save_next_page_frame_register:
  lodsw
  push  ax
  add   dl, al
  lodsw
  out   dx, al
  pop   ax
  sub   dl, al
  loop  func_16_sub_01_save_next_page_frame_register
jmp func_16_sub_01_done_recording_registers


func_16_bad_subfunction:
  pop   si
  pop   di
  pop   cx
  pop   dx
  pop   bx ; restore from ax
  pop   ax

  mov        ah, 084h
  iret


