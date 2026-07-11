  push cx
  push si
  push dx
  push bx


  ; physical page number mode
  cli
  func1701_loop_next_page:

  ; preselect the register for the page on/off 

  mov dx, HT12_CHIPSET_CONFIG_REGISTER_SELECT
  mov ax, HT12_EMS_CONFIG_REGISTER
  out dx, al
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  in  al, dx   ; read in the port. we are going to AND the page on...

  mov bl, al   ; store value in bl..

  ; lets load next argument.
  lodsw

  push cx
  mov        cl, al


  ; read two words - dx and ax

  
  mov dl, 1
  sal dl, cl ; turn on the bit for this page

  lodsw
  call COMMON_util_get_register_for_segment

  
  ; bl has previous config register  contents  
  ; cl has page number
  ; dl is ready to be ored etc
  
  
  cmp   ax, 0FFFFh   ; -1 check
  je    func17_01_handle_default_page

  xchg ax, bx
  or  al, dl  ; page is turned on
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  out dx, al  ; page has been turned on (in case it was off)

  mov ax, cx
  add al, HT12_PAGE_REGISTER_0  ; add by page 0 offset
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_SELECT
  out dx, al    ; select page

  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  mov ax, bx
  add al, HT12_PAGE_OFFSET_AMT
  out dx, al ; write page

  pop cx

  loop       func1701_loop_next_page
  sti

  ; exit fall thru
  xor ax, ax
  pop bx
  pop dx
  pop si
  pop cx
  iret

  func17_01_handle_default_page:
  ; mapping to page -1

  
  mov al, bl  
  not dl
  and al, dl  ; page is turned off
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  out dx, al  ; page has been turned on (in case it was off)

  pop cx

  loop       func1701_loop_next_page
  sti


  ; exit fall thru
  xor ax, ax
  pop bx
  pop dx
  pop si
  pop cx
  iret