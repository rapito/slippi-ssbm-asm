################################################################################
# Address: 0x801a5858 # Part of the above function where Match Struct Address
# Is Obtained on VSCopyCSSInfo function
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

.set REG_STRUCT, 31
backup

mr REG_STRUCT, r31

# Ensure that this is an online CSS
getMinorMajor r3
cmpwi r3, SCENE_ONLINE_CSS
bne RESTORE # If not online CSS, continue as normal

load r3, 0x80480530 # static memory address to Match struct info
b EXIT

RESTORE:
mr r3, REG_STRUCT
# original line
branchl r12, 0x801A427C # GetMinorSceneData1

EXIT:
restore
