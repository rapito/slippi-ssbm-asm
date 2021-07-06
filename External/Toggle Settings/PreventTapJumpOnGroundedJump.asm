################################################################################
# Address: 0x800caf00 # Address is Interrupt_Jump_Grounded where tap jump threshold 
# is checked f0 is the threshold and f1 is the current value of the c-stick
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Settings/InitToggleSettings.s"

.set REG_BRANCH_TARGET_ADDR, 5
CanRunInGameTapChecks EXIT, REG_BRANCH_TARGET_ADDR

CODE_START:
    # Load the values of the buffer
    lbz r4, 0x0678 (r24) # current player index
    lbzx r3, r4, REG_BRANCH_TARGET_ADDR 
    cmpwi r3, 1
    beq EXIT
    lwz	r4, 0x002C (r31) # original code again
    branch r12, 0x800caf30

EXIT:
    lwz	r4, 0x002C (r31)
    lwz	r5, -0x514C (r13) # original code