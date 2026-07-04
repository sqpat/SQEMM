
  ; initialization of registers
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_EMS_CONFIG_REGISTER 
  out   dx, al   

  ; enable ems
  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, 0CFh  ; select all 4 pages on, D000 page frame, EMS ON
  out   dx, al   

  ; set default page 0
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_PAGE_REGISTER_0
  out   dx, al   

  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, HT12_PAGE_OFFSET_AMT + 0
  out   dx, al   
  ; set default page 1
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_PAGE_REGISTER_1
  out   dx, al   

  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, HT12_PAGE_OFFSET_AMT + 1
  out   dx, al   
  ; set default page 2
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_PAGE_REGISTER_2
  out   dx, al   

  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, HT12_PAGE_OFFSET_AMT + 2
  out   dx, al   
  ; set default page 3
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_PAGE_REGISTER_3
  out   dx, al   

  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, HT12_PAGE_OFFSET_AMT + 3
  out   dx, al   


  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], PAGE_COUNT_4_MB
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], HT12_PAGE_FRAME_COUNT
