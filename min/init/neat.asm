; offset pages by 2 MB

mov al, NEAT_CHIPSET_ADDRESS_EXTENSION_REGISTER
out NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
mov al, 055h
out NEAT_CHIPSET_CONFIG_REGISTER_READWRITE, al

  mov   dx, 0208h
  mov   ax, NEAT_PAGE_OFFSET_AMT
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 

  ; page frame d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], MAX_PAGE_COUNT
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], MAX_PAGE_COUNT
  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?

