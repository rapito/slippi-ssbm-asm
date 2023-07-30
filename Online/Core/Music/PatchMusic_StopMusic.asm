################################################################################
# Address: 0x8038e994 # on method called to stop music before setting return value 
# Cleans up data buffer of currently cached music file.
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Core/Music/Music.s"

.set REG_DATA, 31
.set REG_HPS_BUFFER_ADDRESS, 30
.set REG_HPS_BUFFER_SIZE, 29
.set REG_HEAP_BACKUP, 28

backup 

# get current music file buffer address and check if empty
computeBranchTargetAddress REG_DATA, INJ_fileLoad_HPS
lwz REG_HPS_BUFFER_ADDRESS, IDO_HPS_BUFFER(REG_DATA) # source 



lbz r4, IDO_HPS_ID(REG_DATA)  
lwz r5, IDO_HPS_STR(REG_DATA)  
lwz r6, 0x0(REG_HPS_BUFFER_ADDRESS)
oslogf "===== Cleaning up HPS file: [%i] %s... (0x%x)"

lwz r4, IDO_HPS_STR(REG_DATA)  
lbz r5, IDO_HPS_ID(REG_DATA)  
lwz r6, IDO_HPS_BUFFER_SIZE(REG_DATA)
lwz r7, IDO_HPS_BUFFER(REG_DATA)
lwz r8, 0x0(r7)
oslogf "--- Struct --- \nIDO_HPS_STR:%s\nIDO_HPS_ID:%i\nIDO_HPS_BUFFER_SIZE:%i\nIDO_HPS_BUFFER:0x%x\nBuffer:0x%x\n"

cmpwi REG_HPS_BUFFER_ADDRESS, 0 # if empty just return
# b RESTORE_AND_EXIT
beq RESTORE_AND_EXIT

# back current heap before moving the our custom audio heap
#mr r3, REG_HEAP_BACKUP
#branchl r12, HSD_GetHeapID

# Set custom heap
#lbz r3, IDO_HPS_HEAP_ID(REG_DATA)
#branchl r12, HSD_SetHeapID

# free up buffer
mr r3, REG_HPS_BUFFER_ADDRESS
branchl r12, HSD_Free 

# Restore previous HSD Heap
#lbz r3, IDO_HPS_HEAP_ID(REG_DATA)
#branchl r12, HSD_SetHeapID

# cleanup data
load r3, 0
stw r3, IDO_HPS_BUFFER(REG_DATA)  
stw r3, IDO_HPS_BUFFER_SIZE(REG_DATA)  


RESTORE_AND_EXIT:
restore

Exit:
li r3, 1 # original line