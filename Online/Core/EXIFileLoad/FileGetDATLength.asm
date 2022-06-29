################################################################################
# Address: 0x80016368 # On FileGetDATLength 
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

.set  REG_Buffer,31
.set  REG_Entrynum,30
.set  REG_Offset,29

# Original
mr	REG_Entrynum, r31      #save pointer to file string

# Init
backup

li  r3,128
branchl r12,HSD_MemAlloc
mr REG_Buffer, r3

# Get offset (stolen from DVDFastOpen)
lwz	r3, -0x4424 (r13)
mulli r4, REG_Entrynum, 12
add	r3, r3, r4
lwz	REG_Offset, 0x0004 (r3)

GetFileLength_REQUEST_DATA:
# request game information from slippi
  li r3, CONST_SlippiCmdFileDATLength        # store file length request ID
  stb r3,0x0(REG_Buffer)
  stw REG_Entrynum,0x1(REG_Buffer)
  stw REG_Offset,0x5(REG_Buffer)
  mr  r3,REG_Buffer        #Buffer Pointer
  li  r4, 0x8              #Buffer Length 
  li  r5,CONST_ExiWrite
  branchl r12,FN_EXITransferBuffer
GetFileLength_RECEIVE_DATA:
# Transfer buffer over DMA
  mr  r3,REG_Buffer
  li  r4,0x4               #Buffer Length
  li  r5,CONST_ExiRead
  branchl r12,FN_EXITransferBuffer
GetFileLength_CHECK_STATUS:
# restore stack frame
  mr  r3,REG_Buffer
  restore
# Check if Slippi has a replacement file
  lwz r3,0x0(r3)
  cmpwi r3,0
  ble GetFileLength_NO_REPLACEMENT

GetFileLength_HAS_REPLACEMENT:
# Exit injection and return slippi's file's length
  branch  r12, 0x800163c0

GetFileLength_NO_REPLACEMENT:
# Resume the original function
  mr r3, REG_Entrynum # restore r3 value
  addi	r30, r3, 0