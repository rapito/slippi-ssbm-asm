################################################################################
# Address: 0x800cb984 # Address in Interrupt_AerialJump where the bounds of control 
# stick are checked to allow tap jump f0 is the threshold and f1 is the current 
# value of the c-stick
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Settings/InitToggleSettings.s"

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
    li r4, 0 # original code again
    branch r12, 0x800cb9ac 

EXIT:
    li r4, 0
    lwz	r5, -0x514C (r13) # original code