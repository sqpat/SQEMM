  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count+1], RODNEY_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_handle_count+1], 01h


  mov       cx, 040h
  setdefaultpageloop:
  mov       ax, cx
  dec       ax
  out       RODNEY_PAGE_SELECT_REGISTER, al ; 040h to 1 loop becomes 03Fh to 0
  xor       ax, ax
  out       RODNEY_PAGE_SET_REGISTER, ax   ; 0
  loop      setdefaultpageloop

  out       RODNEY_EMS_ENABLE_REGISTER, al

ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS


  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count+1], FANTASY_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_handle_count+1], 01h

  ; set first four page registers for d000
  xor   cx, cx
  mov   cl, 4h  
  mov   ax, 4

  enablepageloop:
  out   FANTASY_PAGE_SELECT_REGISTER, al
  push  ax
  mov   ax, 0FFFFh
  out   FANTASY_PAGE_SET_REGISTER, ax
  pop   ax
  inc   ax
  loop enablepageloop


  ; NOTE: If we enable backfill, we must initialize page registers for backfill region
  ;  4-28 to be 4-28

  mov   ax, 0Ch
  mov   cl, 18h  ; 24 registers, 0C to 23

  ; 0c maps to 10, 
  ; 0d maps to 11, 
  ; ...
  ; 23 maps to 27

  enablebackfillloop:
  out   FANTASY_PAGE_SELECT_REGISTER, al
  push  ax
  mov   ax, 0FFFFh
  out   FANTASY_PAGE_SET_REGISTER, ax
  pop   ax
  inc   ax
  loop enablebackfillloop