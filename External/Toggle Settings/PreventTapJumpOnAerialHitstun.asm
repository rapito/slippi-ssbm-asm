################################################################################
# Address: 0x8008feec # Address in Animation_DamageFlyTop where the frame
# where tap jump was input is checked to allow jump or not
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
    lwz	r4, 0x002C (r31) # restore r4
    branch r12, 0x8008ff18 

EXIT:
    lwz	r4, 0x002C (r31) # restore r4
    lwz	r3, -0x514C (r13) # original code