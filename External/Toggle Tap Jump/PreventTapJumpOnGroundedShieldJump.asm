################################################################################
# Address: 0x800cb074 # Address in Interrupt_GroundJumpFromShield  
# where tap jump threshold is checked 
# f0 is the threshold and f1 is the current value of the c-stick
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Tap Jump/InitToggleTapJump.s"

.set REG_BRANCH_TARGET_ADDR, 5
CanRunInGameTapChecks EXIT, REG_BRANCH_TARGET_ADDR

CODE_START:
    # Load the values of the buffer
    lbz r4, 0x0678 (r24) # current player index
    addi r4, r4, 8
    lbzx r3, r4, REG_BRANCH_TARGET_ADDR 
    cmpwi r3, 1
    beq EXIT
    branch r12, 0x800cb08c


EXIT:
    lbz	r3, 0x0671 (r4) # original code