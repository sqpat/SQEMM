
  ; unlock chipset
  mov   dx, 0FC72h
  mov   ax, 0DAh
  ;out   dx, ax  ; not sure if required
  out   dx, al  ; unlock chipset.

  mov  dx, 06872h
  in   ax, dx
  ;mov  ax, 06001h   ; 1 for himem area?
  or   ax, 06400h   ; enable EMS 
                    ; - but dont change boundary (lo byte)
                    ; - enable page registers but dont remap
                    ; - set d000 page frame
                    ; - dont enable autoincrement
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
  mov   bx, 36

  ready_next_default_page_frame:
    mov   dx, si
    mov   ax, bx
    out   dx, ax
    mov   dx, di
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
  

  mov   ax, 0D000h
  
  mov   byte ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+2], ah
  
  mov   ax, PAGE_COUNT_4_MB  ; MAX_PAGE_COUNT
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax
  ;mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], MAX_PAGE_COUNT
  ;mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], MAX_PAGE_COUNT
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT

