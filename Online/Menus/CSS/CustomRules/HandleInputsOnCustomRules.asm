################################################################################
# Address: 0x80229c18 # CSSRules_CustomRulesThinkGlobal think function that
# runs when Custom Rules is open regardless of page
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

START:

backup
mr r31, r3 # backup r3

# Ensure that this is an online CSS
getMinorMajor r3
cmpwi r3, SCENE_ONLINE_CSS
bne EXIT # If not online CSS, continue as normal

lbz r4, OFST_R13_ONLINE_MODE(r13)
cmpwi r4, ONLINE_MODE_DIRECT
blt EXIT # exit if not on DIRECT or TEAMS mode

# 806638f8
lbz r3, -0x49B0(r13) # get input of player that opened the menu
branchl	r12, 0x801A36A0 # Inputs_GetPlayerInstantInputs
cmpwi r4, 0x10 # check if BTN_Z was pressed
bne EXIT

logf LOG_LEVEL_NOTICE, "Test"

b EXIT

DATA:
blrl
.long 0x00350102 # Custom Rules 1
.long 0x04000A00 # Custom Rules 2
.long 0x08010000 # Additional Rules 1
.long 0x00000808 # Additional Rules 2

.long 0xFF000000 # Items Speed Switch
.long 0xffffffff # Items Selections 1
.long 0xffffffff # Items Selections 2
.long 0x01010101 # Rumble Settings (ignore)
.long 0x00010100 # Screen Settings (ignore)
.long 0xE70000B0 # Stage Selections

EXIT:
mr r3, r31 # restore r3
restore
lis	r4, 0x804A # original line
li	r5, 4 # original line
crset 6
