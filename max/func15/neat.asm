FUNCTION_15_GET_PAGE_MAP:




  xor   ax, ax
  call  UTIL_map_NEAT_read_page_full
  stosw
  
  mov   ax, 1
  call  UTIL_map_NEAT_read_page_full
  stosw

  mov   ax, 2
  call  UTIL_map_NEAT_read_page_full
  stosw

  mov   ax, 3
  call  UTIL_map_NEAT_read_page_full
  stosw

  sub   di, 8


  ret



; fall thru and run this one

FUNCTION_15_SAVE_PAGE_MAP:
public FUNCTION_15_SAVE_PAGE_MAP
  push  dx


  xor   dx, dx   ; dx 0
  lodsw
  call  UTIL_map_NEAT_write_page_full

  inc   dx
  lodsw
  call  UTIL_map_NEAT_write_page_full

  inc   dx
  lodsw
  call  UTIL_map_NEAT_write_page_full

  inc   dx
  lodsw
  call  UTIL_map_NEAT_write_page_full

  sub   si, 8

  pop   dx
  ret


