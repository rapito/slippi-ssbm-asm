################################################################################
# Address: FN_ExecDatMethod
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
################################################################################
# Description:
# Executes m-ex c Functions located at Slippi.dat
################################################################################
# Inputs:
# r3 - FX Offset of function to invoke based on the slpFunction symbol
# offset is calculated with (function index+1)*4 
################################################################################
backup
  .set REG_CSSDT_ADDR, 31
  .set REG_FN_OFFSET, 30

  mr REG_FN_OFFSET, r3      # backup fn offset

  loadwz REG_CSSDT_ADDR, CSSDT_BUF_ADDR
  lwz r3, CSSDT_SLPFX_ADDR(REG_CSSDT_ADDR) # get address to fx struct
  # find offset to function from fx struct table
  add r3, r3, REG_FN_OFFSET 
  lwz r4, 0x0(r3) # r4 is now the offset to the function from the fx array         

  # offset from fx array to OnCSSLoad
  lwz r3, CSSDT_SLPFX_ARRAY_ADDR(REG_CSSDT_ADDR) # get address to array of functions
  add r3, r3, r4

  mtctr r3
  bctrl 
  
restore
blr

