################################################################################
# Address: 0x800cafac # Address in Interrupt_AS_TurnRunActualChecks 
# where tap jump threshold is checked 
# f0 is the threshold and f1 is the current value of the c-stick
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Tap Jump/InitToggleTapJump.s"

getMinorMajor r3
cmpwi r3, SCENE_ONLINE_IN_GAME
bne CODE_START # If not online game, continue as normal

lbz r3, OFST_R13_ONLINE_MODE(r13)
cmpwi r3, ONLINE_MODE_DIRECT
bne EXIT # if not on DIRECT, exit

CODE_START:
    computeBranchTargetAddress r3, INJ_ToggleTapJump
    # Load the values of the buffer
    lbz r4, 0x0678 (r24) # current player index
    addi r4, r4, 8
    lbzx r3, r4, r3 
    cmpwi r3, 1
    beq EXIT
    branch r12, 0x800cafe8


EXIT:
    lwz	r4, -0x514C (r13) # original code