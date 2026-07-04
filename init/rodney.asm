  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], PAGE_COUNT_4_MB
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], RODNEY_PAGE_FRAME_COUNT



  mov       cx, 040h
  setdefaultpageloop:
  mov       ax, cx
  dec       ax
  out       RODNEY_PAGE_SELECT_REGISTER, al ; 040h to 1 loop becomes 03Fh to 0
  xor       ax, ax
  out       RODNEY_PAGE_SET_REGISTER, ax   ; 0
  loop      setdefaultpageloop

  out       RODNEY_EMS_ENABLE_REGISTER, al

