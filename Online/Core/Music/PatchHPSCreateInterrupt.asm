################################################################################
# Address: 0x8038b100 # HPS_CreateInterrupt Overrides call to ScheduleFileLoad
# and creates a Proc that runs next 
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Core/Music/Music.s"

.set REG_GOBJ, 31
.set REG_DATA, REG_GOBJ-1
.set REG_OFFSET_TO_READ, REG_DATA-1
.set REG_LENGTH_TO_READ, REG_OFFSET_TO_READ-1
.set REG_TARGET_ADDR, REG_LENGTH_TO_READ-1
.set REG_CALLBACK_OFFSET, REG_TARGET_ADDR-1


.set DATA_SIZE, 0x4*4


mr REG_OFFSET_TO_READ, r4
mr REG_LENGTH_TO_READ, r6
mr REG_TARGET_ADDR, r5
mr REG_CALLBACK_OFFSET, r10

backup 

#Create GObj
  li  r3,22
  li  r4,23
  li  r5,0
  branchl r12,GObj_Create
  mr  REG_GOBJ,r3

#Alloc Mem
  li  r3,DATA_SIZE
  branchl r12,HSD_MemAlloc
  mr  REG_DATA,r3

#Zero Data
  mr  r3,REG_DATA
  li  r4,DATA_SIZE
  branchl r12,Zero_AreaLength

# Store params on callback
  stw REG_OFFSET_TO_READ, 0(REG_DATA)
  stw REG_LENGTH_TO_READ, 4(REG_DATA)
  stw REG_TARGET_ADDR, 8(REG_DATA)
  stw REG_CALLBACK_OFFSET, 12(REG_DATA)

#Attach Data
  mr  r3,REG_GOBJ
  li  r4,14
  load r5,HSD_Free
  mr  r6,REG_DATA
  branchl r12,GObj_AddUserData

#Attach Process
  mr  r3,REG_GOBJ
  bl  InvokeHPSPreloadCallbackLoadNextChunk
  mflr r4
  li  r5,23
  branchl r12,GObj_AddProc

restore
b Exit

InvokeHPSPreloadCallbackLoadNextChunk:
    blrl
    backup

    mr REG_GOBJ, r3
    # get address of data buffer
    lwz REG_DATA, 0x2C(REG_GOBJ)

    # Get offset, length and target address
    lwz REG_OFFSET_TO_READ, 0(REG_DATA)
    lwz REG_LENGTH_TO_READ, 4(REG_DATA)
    lwz REG_TARGET_ADDR, 8(REG_DATA)
    lwz REG_CALLBACK_OFFSET, 12(REG_DATA)

    # exit if target address is empty 
    cmpwi REG_TARGET_ADDR, 0
    beq START_LOAD_NEXT_CHUNK

    # Get cached buffer and copy to target
    computeBranchTargetAddress r3, INJ_fileLoad_HPS
    lwz r4, IDO_HPS_BUFFER(r3) # source 
    cmpwi r4, 0
    beq END_PROC

    mr r3, REG_TARGET_ADDR # destination
    #add r3, r3, REG_OFFSET_TO_READ # destination + offset
    add r4, r4, REG_OFFSET_TO_READ # source + offset
    mr r5, REG_LENGTH_TO_READ
    branchl r12, memcpy

    START_LOAD_NEXT_CHUNK:
    # invoke HPS_Pre-LoadCallback (LoadNextChunk) 
    li r3, 0 # I think this is current time in seconds (the function ignores it)
    # addi r4, REG_OFFSET_TO_READ, 0x20 # offset to read from
    mr r4, REG_CALLBACK_OFFSET # next offset to read from (increase 20 is what the game does)
    branchl r12, 0x8038ad74 # HPS_Pre-LoadCallback (LoadNextChunk) 

    END_PROC:
    mr r3, REG_GOBJ
    branchl r12, GObj_Destroy

    restore
    blr

Exit: