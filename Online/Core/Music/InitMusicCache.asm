################################################################################
# Address: INJ_fileLoad_HPS # fileLoad_HPS right where DVDConvertPathToEntryNum 
# is called
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Core/Music/Music.s"

.set REG_PROPERTIES, 14
.set REG_HPS_ID, 15
.set REG_HPS_FILENAME, 16


b CODE_START

################################################################################
# Data
################################################################################
.set EXT_HPS_FILENAME, 0x0 
.set EXT_HPS_ID, EXT_HPS_FILENAME + 4
.set EXT_HPS_BUFFER, EXT_HPS_ID + 1
.set EXT_HPS_FETCH_SIZE, EXT_HPS_BUFFER + 4
.set EXT_HPS_FETCH_FILE, EXT_HPS_FETCH_SIZE + 4
DATA_BLRL:
blrl
# Start with data that is accessible externally
.long 0 
.byte 0
.long 0
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

# init properties
bl DATA_BLRL
mflr REG_PROPERTIES

# store hps filename and id into static data
stw REG_HPS_FILENAME, EXT_HPS_FILENAME(REG_PROPERTIES)
stb REG_HPS_ID, EXT_HPS_ID(REG_PROPERTIES)

# restore hps id to r3
mr r3, REG_HPS_ID
restore 

EXIT: