################################################################################
# Address: 0x8038adbc # HPS_Pre-LoadCallback Overrides call to ScheduleFileLoad
# and creates a Proc that runs next 
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Core/Music/Music.s"

.set REG_GOBJ, 31
.set REG_DATA, 30
.set REG_OFFSET_TO_READ, 29
.set REG_LENGTH_TO_READ, 28
.set REG_TARGET_ADDR, 27

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
  branchl r12,Zero_AreaLength

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
    blrl
    backup 

    mr REG_GOBJ, r3
    # get address of data buffer
    lwz REG_DATA, 0x2C(REG_GOBJ)

    # Get offset, length and target address
    lwz REG_OFFSET_TO_READ, 0x0(REG_DATA)
    lwz REG_LENGTH_TO_READ, 0x4(REG_DATA)
    lwz REG_TARGET_ADDR, 0x8(REG_DATA)

    # exit if target address is empty 
    cmpwi REG_TARGET_ADDR, 0
    beq START_POST_LOAD_CALLBACK

    # Get cached buffer and copy to target
    computeBranchTargetAddress r3, INJ_fileLoad_HPS
    lwz r7, IDO_HPS_BUFFER(r3) # source 
    cmpwi r7, 0
    beq END_PROC

# TODO: this is working perfectly for sound, but I'm not sure if this is the cause of the problem I'm seeing with corrupted memory
    # this part of the memory is copied to ARAM instead so we need to 
    # mimic how the game does it using ARQPostRequest
    load r3, 0x804c62a0 # request
    li r4, 0 # owner
    li r5, 0 # type
    li r6, 1 # prio
    add r7, r7, REG_OFFSET_TO_READ # source + offset
    mr r8, REG_TARGET_ADDR 
    mr r9, REG_LENGTH_TO_READ
    load r10, 0x8038f098 # callback
    branchl r12, 0x80352114 # ARQPostRequest(r3=request,r4=owner,r5=type,r6=prio,r7-source,r8=dest,r9=length,r10=callback)

    # mr r3, REG_TARGET_ADDR # destination
    # add r4, r4, REG_OFFSET_TO_READ # source + offset
    # mr r5, REG_LENGTH_TO_READ
    # branchl r12, memcpy

    START_POST_LOAD_CALLBACK:
    # invoke HPS_PostLoadCallback
    branchl r12, 0x8038ad60 # HPS_PostLoadCallback

    END_PROC:
    mr r3, REG_GOBJ
    branchl r12, GObj_Destroy

    restore
    blr

Exit: