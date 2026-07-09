  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], MAX_PAGE_COUNT
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], MAX_PAGE_COUNT
  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?




  mov       cx, 040h
  setdefaultpageloop:
  mov       ax, cx
  dec       ax
  out       RODNEY_PAGE_SELECT_REGISTER, al ; 040h to 1 loop becomes 03Fh to 0
  xor       ax, ax
  out       RODNEY_PAGE_SET_REGISTER, ax   ; 0
  loop      setdefaultpageloop

  out       RODNEY_EMS_ENABLE_REGISTER, al

