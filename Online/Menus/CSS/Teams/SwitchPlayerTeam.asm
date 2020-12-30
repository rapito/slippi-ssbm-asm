################################################################################
# Address: FN_SwitchPlayerTeam
################################################################################
# Description:
# Switches selection to next team
# Updates Graphics and memory values for new team selection
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"


.set REG_CSSDT_ADDR, 30
.set REG_PORT_SELECTIONS_ADDR, 28
.set REG_INTERNAL_CHAR_ID, 27
.set REG_EXTERNAL_CHAR_ID, 26
.set REG_TEAM_IDX, 25
.set REG_COSTUME_IDX, 24
.set REG_ICON_JOBJ, 21

FN_SWITCH_PLAYER_TEAM:

backup

loadwz REG_CSSDT_ADDR, CSSDT_BUF_ADDR # Load where buf is stored
lwz REG_ICON_JOBJ, CSSDT_ICON_JOBJ_ADDR(REG_CSSDT_ADDR)

# Get location from which we can find selected character
lwz r4, -0x49F0(r13) # base address where css selections are stored
lbz r3, -0x49B0(r13) # player index
mulli r3, r3, 0x24
add REG_PORT_SELECTIONS_ADDR, r4, r3

lbz r3, 0x70(REG_PORT_SELECTIONS_ADDR)
mr REG_INTERNAL_CHAR_ID, r3

# Get Char Id
load r3, 0x803f0a48
mr r4, r3
addi r5, r3, 0x03C2
lbzu r3, 0x0(r5)
mulli r3, r3, 28
add	r4, r4, r3
lbz	r3, 0x00DC (r4) # char id
mr REG_EXTERNAL_CHAR_ID, r3

# Get Custom Team Index increment and store
lbz r4, CSSDT_TEAM_IDX(REG_CSSDT_ADDR)
addi r4, r4, 1
cmpwi r4, 4
blt FN_SWITCH_PLAYER_TEAM_SKIP_RESET_TEAM
li r4, 1 # reset to 1 (RED)

FN_SWITCH_PLAYER_TEAM_SKIP_RESET_TEAM:

# Store Custom Team selection in data table
stb r4, CSSDT_TEAM_IDX(REG_CSSDT_ADDR)
mr REG_TEAM_IDX, r4

# Animate the team icon based on team index
cmpwi REG_TEAM_IDX, 3
beq FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_G
cmpwi REG_TEAM_IDX, 2
beq FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_B
cmpwi REG_TEAM_IDX, 1
ble FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_R

FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_B:
li r3, 0
b FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_SKIP
FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_G:
li r3, 1
b FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_SKIP
FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_R:
li r3, 2

FN_SWITCH_PLAYER_TEAM_CHANGE_ICON_COLOR_SKIP:
branchl r12, FN_IntToFloat

mr r3, REG_ICON_JOBJ
branchl r12, JObj_ReqAnimAll # (jobj, frames)

mr r3, REG_ICON_JOBJ
branchl r12, JObj_AnimAll

# Kind of hacky I know :) things get messed up so I just back everything up :D
backupall
mr r3, REG_TEAM_IDX
bl FN_CHANGE_PORTRAIT_BG
restoreall

mr r3, REG_TEAM_IDX
mr r4, REG_INTERNAL_CHAR_ID
bl FN_GET_TEAM_COSTUME_IDX
mr REG_COSTUME_IDX, r3

# Check if character has been selected, if not, do nothing
lbz r3, -0x49A9(r13)
cmpwi r3, 0
beq FN_SWITCH_PLAYER_TEAM_EXIT

# Store costume index selection in game
lwz	r5, -0x49F0 (r13) # P1 Players Selections
stb	REG_COSTUME_IDX, 0x73 (r5)
load r5, 0x803F0E09 # P1 Char Menu Data
stb REG_COSTUME_IDX, 0x0(r5)
stb REG_COSTUME_IDX, CSSDT_TEAM_COSTUME_IDX(REG_CSSDT_ADDR)

# Calculate Costume ID from costume Index
mulli	r4, REG_COSTUME_IDX, 30
add	r4, REG_EXTERNAL_CHAR_ID, r4

li r3, 0 # player index
li	r5, 0
branchl r12, 0x8025D5AC # CSS_UpdateCharCostume?

# Play team switch sound
li	r3, 2
branchl r12, SFX_Menu_CommonSound

FN_SWITCH_PLAYER_TEAM_EXIT:
restore
blr


################################################################################
# Function: Returns Proper Costume Index for a give custom team index and char
################################################################################
# Inputs:
# r3: Team IDX
# r4: External Char ID (fighter ext id)
################################################################################
# Returns
# r3: Costume Index
################################################################################
FN_GET_TEAM_COSTUME_IDX:
cmpwi r4, 3
beq FN_GET_TEAM_COSTUME_IDX_GREEN
cmpwi r4, 2
beq FN_GET_TEAM_COSTUME_IDX_BLUE
cmpwi r4, 1
beq FN_GET_TEAM_COSTUME_IDX_RED

FN_GET_TEAM_COSTUME_IDX_BLUE:
branchl r12, 0x801692bc # CSS_GetCharBlueCostumeIndex
b FN_GET_TEAM_COSTUME_IDX_EXIT
FN_GET_TEAM_COSTUME_IDX_GREEN:
branchl r12, 0x80169290 # CSS_GetCharGreenCostumeIndex
b FN_GET_TEAM_COSTUME_IDX_EXIT
FN_GET_TEAM_COSTUME_IDX_RED:
branchl r12, 0x80169264 # CSS_GetCharRedCostumeIndex

FN_GET_TEAM_COSTUME_IDX_EXIT:
blr


################################################################################
# Function: Changes the portrait bg of the player based on custom team index
################################################################################
# Inputs:
# r3: Team IDX
################################################################################
FN_CHANGE_PORTRAIT_BG:
backup
mr REG_TEAM_IDX, r3

cmpwi REG_TEAM_IDX, 3
beq FN_CHANGE_PORTRAIT_BG_GREEN
cmpwi REG_TEAM_IDX, 2
beq FN_CHANGE_PORTRAIT_BG_BLUE
cmpwi REG_TEAM_IDX, 1
beq FN_CHANGE_PORTRAIT_BG_RED

FN_CHANGE_PORTRAIT_BG_BLUE:
li r4, 0
b FN_CHANGE_PORTRAIT_BG_SKIP_COLOR
FN_CHANGE_PORTRAIT_BG_GREEN:
li r4, 1
b FN_CHANGE_PORTRAIT_BG_SKIP_COLOR
FN_CHANGE_PORTRAIT_BG_RED:
li r4, 2
b FN_CHANGE_PORTRAIT_BG_SKIP_COLOR

FN_CHANGE_PORTRAIT_BG_SKIP_COLOR:

# Store team idx on r13 offset that stores port for P1-4
lbz r5, -0x49B0(r13) # player index
subi r3, r13, 26056
add r3, r3, r5 # Add player index offset
stb r4, 0(r3)

# Call game method to trigger the bg change
li r3, 0
branchl r12, 0x8025db34 # CSS_CursorHighlightUpdateCSPInfo

FN_CHANGE_PORTRAIT_BG_EXIT:
restore
blr