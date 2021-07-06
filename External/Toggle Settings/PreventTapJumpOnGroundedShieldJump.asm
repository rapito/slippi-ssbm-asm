################################################################################
# Address: 0x800cb074 # Address in Interrupt_GroundJumpFromShield  
# where tap jump threshold is checked 
# f0 is the threshold and f1 is the current value of the c-stick
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Settings/InitToggleSettings.s"


.set REG_BACKUP_R4, 6
.set REG_BACKUP_R5, 7

# backup
mr REG_BACKUP_R4, r4 
mr REG_BACKUP_R5, r5 

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
    mr r4, REG_BACKUP_R4 # restore r4 value
    branch r12, 0x800cb08c


EXIT:
    mr r5, REG_BACKUP_R5 # restore r5 value
    lbz	r3, 0x0671 (r4) # original code