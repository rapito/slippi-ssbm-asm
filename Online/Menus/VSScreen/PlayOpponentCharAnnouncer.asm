################################################################################
# Address: 0x80184de4 # VSMode_Think line that decides char id to announce
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

.set REG_MSRB_ADDR, 31
.set REG_RESULT, 30

# Ensure that this is an online VS
getMinorMajor r12
cmpwi r12, SCENE_ONLINE_VS
bne REPLACED_CODE_LINE # If online VS, skip line

backup

# Get match state info
li r3, 0
branchl r12, FN_LoadMatchState
mr REG_MSRB_ADDR, r3

# Get the ext char ID of the remote player
lbz r3, MSRB_REMOTE_PLAYER_INDEX(REG_MSRB_ADDR)
mulli r3, r3, 0x24
addi r4, REG_MSRB_ADDR, MSRB_GAME_INFO_BLOCK + 0x60 # load char 2 id
lbzx REG_RESULT, r4, r3

# Free the buffer we allocated to get match settings
mr r3, REG_MSRB_ADDR
branchl r12, HSD_Free

mr r3, REG_RESULT
bl FN_PLAY_CHAR_SFX

# Set result
mr r3, REG_RESULT

RESTORE_AND_EXIT:
restore
b EXIT

REPLACED_CODE_LINE:
# replaced code line
lbz r3, 0x00F4 (r30)

b EXIT




################################################################################
# Function: Play Select Fighter SFX
################################################################################
.set REG_PORT_SELECTIONS_ADDR, 14
.set REG_INTERNAL_CHAR_ID, 15
FN_PLAY_CHAR_SFX:
backup

mr REG_INTERNAL_CHAR_ID, r3

# map char fx data to r4
bl CHAR_FX_DATA_BLRL
mflr r4

mulli r3, REG_INTERNAL_CHAR_ID, 4 # get offset we want for internal char
add r3, r3, r4
lwz r3, 0x0(r3) # get sound id

logf LOG_LEVEL_NOTICE, "FN_PLAY_CHAR_SFX Value: %d sound id: %x", "mr r5, REG_INTERNAL_CHAR_ID", "mr r6, r3"

branchl r12, SoundTest_PlaySFX

restore
blr

CHAR_FX_DATA_BLRL:
blrl
.long 0xeaa6 # Captn. Falcon
.long 0x000138a8 # DK
.long 0x0001adcf # Fox
.long 0x00046ce5 # G&W
.long 0x00022323 # Kirby
.long 0x00024a07 # Bowser
.long 0x00027110 # Link
.long 0x00029811 # Luigi
.long 0x0002bf72 # Mario
.long 0x0002e65b # Marth
.long 0x00030d44 # Mewtwo
.long 0x00033462 # Ness
.long 0x00035b67 # Peach
.long 0x0003a9a2 # Pikachu
.long 0x0001fbe5 # Ice Climbers
.long 0x0003d0c4 # Puff
.long 0x0003f7ac # Samus
.long 0x000445ca # Yoshi
.long 0x00041ec4 # Zelda
.long 0x00041ef4 # 0x00041f4e # Sheik
.long 0x000186a6 # Falco
.long 0x00011180 # Y Link
.long 0x00015fd8 # Dr. Mario
.long 0x0004bb14 # Roy
.long 0x00038280 # Pichu
.long 0x000493e6 # Ganondorf




EXIT:
