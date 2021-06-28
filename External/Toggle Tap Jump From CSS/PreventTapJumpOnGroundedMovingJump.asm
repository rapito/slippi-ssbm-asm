################################################################################
# Address: 0x800cafac # Address in Interrupt_AS_TurnRunActualChecks 
# where tap jump threshold is checked 
# f0 is the threshold and f1 is the current value of the c-stick
################################################################################
.include "Common/Common.s"
.include "External/Toggle Tap Jump From CSS/InitToggleTapJump.s"

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