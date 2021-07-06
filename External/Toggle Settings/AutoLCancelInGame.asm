################################################################################
# Address: 0x8006b618 # PlayerThink_Interrupt where L cancel check starts
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Settings/InitToggleSettings.s"

.set REG_LOCAL_PLAYER_INDEX, 6

.set REG_BRANCH_TARGET_ADDR, 7
CanRunInGameTapChecks ORIGINAL_CODE_START, REG_BRANCH_TARGET_ADDR

lbz REG_LOCAL_PLAYER_INDEX, 0xC(r31) # Load port of current character
b CODE_START

DO_L_CANCEL:
    branch r12, 0x8006B624

NO_L_CANCEL:
    branch r12, 0x8006B630

CODE_START:
    addi r4, REG_LOCAL_PLAYER_INDEX, 4
    lbzx r3, r4, REG_BRANCH_TARGET_ADDR 
    cmpwi r3, 1
    beq DO_L_CANCEL

ORIGINAL_CODE_START:
    lwz	r3, 0x0668 (r31)
    rlwinm.	r3, r3, 0, 0, 0 
    beq- NO_L_CANCEL
    
    b DO_L_CANCEL