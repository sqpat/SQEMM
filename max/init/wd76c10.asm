
  ; unlock chipset
  mov   dx, 0FC72h
  mov   ax, 0DAh
  ;out   dx, ax  ; not sure if required
  out   dx, al  ; unlock chipset.

  mov   ah, "F" 
  call  parse_driver_params

  ; chipset has no real default or set param, so use D000 by default if none defined.
  mov   ax, 0100h            ; corresponds to 0D000h
  jnc   set_page_frame   ; param not found, use default

  mov   ax, word ptr es:[di]
  sub   al, 'C'
  jb    bad_page_frame_param
  cmp   al, 'E'-'C'
  ja    bad_page_frame_param
  xchg  al, ah
  sub   al, '0'
  je    set_page_frame
  cmp   al, 4
  je    set_page_frame
  cmp   al, 8
  je    set_page_frame
  cmp   al, 'C' - '0'
  mov   al, 12
  je    set_page_frame

bad_page_frame_param:
  ; bad page frame param! error?
  mov  DX, OFFSET string_bad_page_frame_param
  jmp  DRIVER_NOT_INSTALLED

inc_and_cap_al:
  inc   ax
  cmp   al, 40
  jb    just_ret
  mov   al, 32
just_ret:
  ret

  chipset_page_offset:
  dw 0
  chipset_num_pages:
  dw 0


set_page_frame:

  test  ax, ax
  jz    bad_page_frame_param  ; cant be c000

  cmp   ah, 2
  jne   good_page_frame
  test  al, al
  jnz   bad_page_frame_param ; e000 only.
  good_page_frame:

  ; ah is 0 1    (C D)
  ; al is 0 4 8 or 12
  mov   bx, ax ; backup

  SHIFT_MACRO shl   ah, 4  ; 0 1to 00 10  (C D)
  or    al, ah
  add   al, 0C0h
  mov   byte ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+2], al 

  mov   ah, al
  xor   al, al

  stc   ; hex print
  mov   di, OFFSET string_good_page_frame_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_frame_param
  call  print_driver_param



  mov   ax, word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1]
  push  ax
  cmp   ax, 0D000h
  jbe   dont_relocate_registers

  mov   word ptr ds:[chipset_page_frame_lookup+0], 0E4E0h
  mov   word ptr ds:[chipset_page_frame_lookup+2], 0ECE8h

dont_relocate_registers:
  sub   ah, 0C0h
  shr   ax, 2  ; al  = 0-8
  mov   al, ah
  xor   ah, ah
  xchg  ax, bx
  mov   bl, byte ptr ds:[bx+_WD76C10_PAGE_FRAME_LOOKUP]
  xchg  ax, bx
  
  mov   byte ptr ds:[SELFMODIFY_WD76C10_set_page_frame_register_offset_1+1], al
  mov   byte ptr ds:[SELFMODIFY_WD76C10_set_page_frame_register_offset_2+1], al
  mov   byte ptr ds:[SELFMODIFY_WD76C10_set_page_frame_register_offset_3+1], al
  mov   byte ptr ds:[SELFMODIFY_WD76C10_set_page_frame_register_offset_4+1], al


  mov   cx, 4
  mov   di, OFFSET WF76C10_api_to_physical_page_lookup
  push  cs
  pop   es
loop_set_next_page_frame_index:
  stosb
  call  inc_and_cap_al
  loop  loop_set_next_page_frame_index


  pop   ax ; page frame again

  cmp   ax, 0E000h
  mov   ah, 00
  jne   use_pf_loc_00
  mov   ah, 60h
use_pf_loc_00:

  ; ah has PF_LOC.
  xchg  ax, bx   ; bx hold onto  OR mask for PF_LOC



  mov  dx, 06872h
  in   ax, dx
  ;mov  ax, 06001h   ; 1 for himem area?
  or   ax, 06400h   ; enable EMS 
                    ; - but dont change boundary (lo byte)
                    ; - enable page registers but dont remap
                    ; - dont enable autoincrement
  
  or   ah, bh       ; - set PF_LOC page frame
        
  out  dx, ax

  ; time to set page registers

  mov   cx, 24
  mov   bx, 8

  mov   di, 0E872h
  mov   si, 0E072h
  
  ready_next_default_4000_8000:
    mov   dx, si
    mov   ax, bx
    out   dx, ax
    mov   dx, di
    out   dx, ax
    inc   bx
    loop  ready_next_default_4000_8000

  mov   cx, 8
  xor   bx, bx

  ready_next_default_8000_A000:
    mov   dx, si
    mov   ax, bx
    out   dx, ax
    mov   dx, di
    add   al, 32
    out   dx, ax
    inc   bx
    loop  ready_next_default_8000_A000

  mov   cx, 4
SELFMODIFY_WD76C10_set_page_frame_register_offset_2:
  mov   bx, WD76C10_PAGE_C000_REGISTER_OFFSET

  ready_next_default_page_frame:
    mov   dx, si
    mov   ax, bx
    out   dx, ax
    mov   dx, di
    xor   ax, ax
    out   dx, ax
    inc   bx
    loop  ready_next_default_page_frame




  mov  dx, 06872h
  in   ax, dx
  ;mov  ax, 06001h   ; 1 for himem area?
  or   ax, 00C00h   ; enable EMS 
                    ; - dont enable autoincrement
                    ; - but dont change boundary (lo byte)
                    ; - enable page registers but dont remap
                    ; - set d000 page frame
  out  dx, ax


  mov   ax, WD76C10_PAGE_OFFSET_AMT
  mov  word ptr ds:[_INIT_PARAM_OFFSET], ax

  mov   word ptr ds:[SELFMODIFY_WD76C10_add_page_offset_and_enable_5+1], ax
  or    ax, WD76C10_PAGE_ENABLE_BIT
  dec   ax
  mov   word ptr ds:[SELFMODIFY_WD76C10_add_page_offset_1_minus_1+2], ax
  mov   word ptr ds:[SELFMODIFY_WD76C10_add_page_offset_2_minus_1+2], ax
  mov   word ptr ds:[SELFMODIFY_WD76C10_add_page_offset_3_minus_1+2], ax
  mov   word ptr ds:[SELFMODIFY_WD76C10_add_page_offset_and_enable_4+1], ax
  


  
  mov   ax, PAGE_COUNT_4_MB  ; MAX_PAGE_COUNT
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax
  ;mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], MAX_PAGE_COUNT
  ;mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], MAX_PAGE_COUNT
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT

