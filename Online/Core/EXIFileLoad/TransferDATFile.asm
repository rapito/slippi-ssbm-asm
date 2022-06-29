################################################################################
# Address: 0x8038f70c # on FileScheduledFileLoad? 
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

.set  REG_Buffer,31
.set  REG_FileString,30
.set  REG_FileLength,29
.set  REG_FileAlloc,30 # Set by parent function
.set  REG_Entrynum,29
.set  REG_Offset,25

# Original
  mr REG_FileAlloc, r5     
  mr REG_Entrynum, r3

# Init
  backup

# if theres no file alloc just dont do anything  
  lwz r3,0x0(REG_FileAlloc)
  cmpwi r3,0
  beq TransferFile_NO_REPLACEMENT

  li  r3,128
  branchl r12,HSD_MemAlloc
  mr REG_Buffer, r3

  # Get offset (stolen from DVDFastOpen)
  lwz	r3, -0x4424 (r13)
  mulli r4, REG_Entrynum, 12
  add	r3, r3, r4
  lwz	REG_Offset, 0x0004 (r3)

#########################
## Check if file exits ##
#########################
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
# Check if Slippi has a replacement file
  lwz REG_FileLength,0x0(REG_Buffer)
  cmpwi REG_FileLength,0
  ble TransferFile_NO_REPLACEMENT

###################
## Get file data ##
###################

TransferFile_HAS_REPLACEMENT:
  stw	REG_FileLength, 0(r28) # Parent function normally does this
# request file data
  li r3, CONST_SlippiCmdFileDATLoad        # store file length request ID
  stb r3,0x0(REG_Buffer)
  stw REG_Entrynum,0x1(REG_Buffer)
  stw REG_Offset,0x5(REG_Buffer)
  mr  r3,REG_Buffer        #Buffer Pointer
  li  r4, 0x8              #Buffer Length 
  li  r5,CONST_ExiWrite
  branchl r12,FN_EXITransferBuffer
TransferFile_RECEIVE_DATA:
# Transfer buffer over DMA
  mr  r3,REG_FileAlloc
  mr  r4,REG_FileLength    #Buffer Length
  li  r5,CONST_ExiRead
  branchl r12,FN_EXITransferBuffer
TransferFile_EXIT:
# Exit injection and return 1 (success)
  restore
  branch  r12,0x8038f924

#########################
## No replacement file ##
#########################

TransferFile_NO_REPLACEMENT:
# Resume the original function
  restore
  branchl r12, 0x80347364 # disable interrupts
