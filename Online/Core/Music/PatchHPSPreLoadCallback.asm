################################################################################
# Address: 0x8038adbc # HPS_Pre-LoadCallback Overrides call to ScheduleFileLoad
# and creates a Proc that runs next 
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Core/Music/Music.s"

.set REG_GOBJ, 13
.set REG_DATA, 14
.set REG_OFFSET_TO_READ, 15
.set REG_LENGTH_TO_READ, 16
.set REG_TARGET_ADDR, 17

.set DATA_SIZE, 12

mr REG_OFFSET_TO_READ, r4
mr REG_LENGTH_TO_READ, r6
mr REG_TARGET_ADDR, r5

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
  branchl r12,ZeroAreaLength

# Store current read offset 
  stw REG_OFFSET_TO_READ, 0x0(REG_DATA)
  stw REG_LENGTH_TO_READ, 0x4(REG_DATA)
  stw REG_TARGET_ADDR, 0x8(REG_DATA)

#Attach Data
  mr  r3,REG_GOBJ
  li  r4,14
  load r5,HSD_Free
  mr  r6,REG_DATA
  branchl r12,GObj_AddUserData

#Attach Process
  mr  r3,REG_GOBJ
  bl  InvokeHPSPostLoadCallback
  mflr r4
  li  r5,23
  branchl r12,GObj_AddProc

restore
b Exit

InvokeHPSPostLoadCallback:
    mr REG_GOBJ, r3
    # get address of data buffer
    lwz REG_DATA, 0x2C(REG_GOBJ)

    # Get offset, length and target address
    lwz REG_OFFSET_TO_READ, 0x0(REG_DATA)
    lwz REG_LENGTH_TO_READ, 0x4(REG_DATA)
    lwz REG_TARGET_ADDR, 0x8(REG_DATA)

    # exit if target address is empty 
    cmpwi REG_TARGET_ADDR, 0
    ble START_POST_LOAD_CALLBACK

    # Get cached buffer and copy to target
    computeBranchTargetAddress r3, INJ_fileLoad_HPS
    lwz r4, IDO_HPS_BUFFER(r3) # source 
    cmpwi r4, 0
    ble END_PROC

    mr r3, REG_TARGET_ADDR # destination
    mr r5, REG_LENGTH_TO_READ
    branchl r12, memcpy

    START_POST_LOAD_CALLBACK:
    # invoke HPS_PostLoadCallback
    branchl r12, 0x8038ad60 # HPS_PostLoadCallback

    END_PROC:
    mr r3, REG_GOBJ
    branchl r12, GObj_Destroy


Exit: