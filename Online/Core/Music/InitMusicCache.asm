################################################################################
# Address: INJ_fileLoad_HPS # fileLoad_HPS right where DVDConvertPathToEntryNum 
# is called
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Core/Music/Music.s"

.set REG_DATA, 22
.set REG_HPS_ID, 23
.set REG_HPS_FILENAME, 24
.set REG_HPS_BUFFER_ADDRESS, 25
.set REG_HPS_BUFFER_SIZE, 26
.set REG_HEAP_BACKUP, 27


b CODE_START

################################################################################
# Data
################################################################################
.set EXT_HPS_FILENAME, 0x0  #u32
.set EXT_HPS_ID, EXT_HPS_FILENAME + 0x4 #u8
.set EXT_HPS_BUFFER_SIZE, EXT_HPS_ID + 0x1 #u32
.set EXT_HPS_BUFFER, EXT_HPS_BUFFER_SIZE + 0x4 #u32
.set EXT_HPS_HEAP_ID, EXT_HPS_BUFFER + 0x4 #u8
DATA_BLRL:
blrl
# Start with data that is accessible externally
.long 0 # filename
.byte 0 # entrynum
.long 0 # buffer size
.long 0 # buffer address
.byte 0 # custom heap id
.align 2


################################################################################
# Static Functions
################################################################################
FN_FETCH_HPS_SIZE:
blr

FN_FETCH_HPS_FILE:
blr

CODE_START:

# backup file name 
# convert filename to entrynum
# store entry num
# return r3 

# backup hps filename and id
mr REG_HPS_FILENAME, r3
backup  
branchl r12, 0x8033796c # DVDConvertPathToEntrynum(r3=filename)
mr REG_HPS_ID, r3 

# Check short circuit conditions
# branchl r12, FN_GetCommonMinorID
# cmpwi r3, 0x2 # Checks if we are in-game
# beq ALLOWED_COMMON_ID
# cmpwi r3, 0x3 # Checks if we are in-game sudden death
# beq ALLOWED_COMMON_ID
# cmpwi r3, 0x4 # Checks if we are in-game training mode
# bne RESTORE_AND_EXIT

ALLOWED_COMMON_ID:

# init properties
bl DATA_BLRL
mflr REG_DATA

# store hps filename and id into static data
stw REG_HPS_FILENAME, EXT_HPS_FILENAME(REG_DATA)
stb REG_HPS_ID, EXT_HPS_ID(REG_DATA)

lwz r4, EXT_HPS_STR(REG_DATA)
lbz r5, EXT_HPS_ID(REG_DATA)
lwz r6, EXT_HPS_BUFFER_SIZE(REG_DATA)
lwz r7, EXT_HPS_BUFFER(REG_DATA)
lwz r8, 0x0(r7)
lbz r9, EXT_HPS_HEAP_ID(REG_DATA)
oslogf "--- Struct --- \nIDO_HPS_STR:%s\nIDO_HPS_ID:%i\nIDO_HPS_BUFFER_SIZE:%i\nIDO_HPS_BUFFER:0x%x\nBuffer:0x%x\nHEAP ID:0x%x\n"

# TODO: this is causing issues I think, needs to be reviewed
# check if there's any file stored and clear it
lwz r3, EXT_HPS_BUFFER(REG_DATA)
mr REG_HPS_BUFFER_ADDRESS, r3
cmpwi r3, 0
beq SKIP_DATA_CLEAR

# back current heap before moving the our custom audio heap
#branchl r12, HSD_GetHeapID
#mr REG_HEAP_BACKUP, r3

# Set custom heap
#lbz r3, EXT_HPS_HEAP_ID(REG_DATA)
#branchl r12, HSD_SetHeapID

# clear data with HSD FREE
lwz r3, EXT_HPS_BUFFER(REG_DATA)
branchl r12, HSD_Free

# Restore heap
#mr r3, REG_HEAP_BACKUP
#branchl r12, HSD_SetHeapID
SKIP_DATA_CLEAR:

# fetch file size and store into static data 
mr r3, REG_HPS_FILENAME
branchl r12, File_GetSize
mr REG_HPS_BUFFER_SIZE, r3
stw REG_HPS_BUFFER_SIZE, EXT_HPS_BUFFER_SIZE(REG_DATA)

lwz REG_HPS_BUFFER_ADDRESS, EXT_HPS_BUFFER(REG_DATA) # source 
lwz r6, 0x0(REG_HPS_BUFFER_ADDRESS)
oslogf "===== Loading HPS size: %i - [%i] %s... (0x%x)", "mr r4, REG_HPS_BUFFER_SIZE", "mr r5, REG_HPS_ID", "mr r6, REG_HPS_FILENAME"

# back up current heap before allocating memory for HPS file
# branchl r12, HSD_GetHeapID
# mr REG_HEAP_BACKUP, r3

# Set custom heap
# lbz r3, EXT_HPS_HEAP_ID(REG_DATA)
# branchl r12, HSD_SetHeapID

# Prep buffer to store hps file into
mr r3, REG_HPS_BUFFER_SIZE
branchl r12, HSD_MemAlloc
mr REG_HPS_BUFFER_ADDRESS, r3
mr r4, REG_HPS_BUFFER_SIZE
branchl r12, Zero_AreaLength

# Read whole file and store it in static data
  mr r3, REG_HPS_ID                         # file entrynum
  li r4, 0                                  # offset
  mr r5, REG_HPS_BUFFER_ADDRESS             # addr
  mr r6, REG_HPS_BUFFER_SIZE                # size
  li r7,33                                  # main ram (i think)
  li r8, 1                                  # honestly no idea
  load r9, Disc_FinishedReadingFileCallback # callback
  li r10, 0                                 # cb arg 2
  branchl r12,File_Read                   # (int entrynum, int file_offset, void *buffer, int length, int flags, int r8, void *cb, int r10);

  WaitForFile:
    branchl r12, DVDWaitForRead
    cmpwi r3,0
    beq  WaitForFile

stw REG_HPS_BUFFER_ADDRESS, EXT_HPS_BUFFER(REG_DATA)

lwz r4, EXT_HPS_STR(REG_DATA)
lbz r5, EXT_HPS_ID(REG_DATA)  
lwz r6, EXT_HPS_BUFFER_SIZE(REG_DATA)
lwz r7, EXT_HPS_BUFFER(REG_DATA)
lwz r8, 0x0(r7)
lbz r9, EXT_HPS_HEAP_ID(REG_DATA)
oslogf "--- Struct --- \nIDO_HPS_STR:%s\nIDO_HPS_ID:%i\nIDO_HPS_BUFFER_SIZE:%i\nIDO_HPS_BUFFER:0x%x\nBuffer:0x%x\nHEAP ID:0x%x\n"

# Restore custom heap
# mr r3, REG_HEAP_BACKUP
# branchl r12, HSD_SetHeapID

RESTORE_AND_EXIT:

# restore hps id to r3
mr r3, REG_HPS_ID
restore

EXIT:

# menu sizes
# 2085824
# 2222976
# 2020960

# stage fd
# 3354112