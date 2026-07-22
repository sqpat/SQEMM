

; todo parse
  mov   ax, LOTECH_BASE_PAGE_REGISTER


  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_3+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_4+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_5+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_7+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_8+1], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_10+1], ax

  
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_2+2], ax
  mov   word ptr ds:[SELFMODIFY_LOTECH_set_page_select_register_9+2], ax



  xchg  ax, dx
  mov   ax, 000h 
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 


; todo parse
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0E000h

; todo parse
  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], MAX_PAGE_COUNT
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], MAX_PAGE_COUNT
  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT

; todo setup chipset_page_lookup, etc in vars.