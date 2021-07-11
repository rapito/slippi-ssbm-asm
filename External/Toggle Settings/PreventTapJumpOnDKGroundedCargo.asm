################################################################################
# Address: 0x8009bb2c # Address in before checking if should jump, if 
# f1 > f0 then should tap jump
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
    
    # after we get to this point then lets just check f1 against f2 to see if  
    # the game was going to tap jump
    fcmpo cr0,  f1, f0
    blt EXIT # continue to original code

    # Branch to end of function
    branch r3, 0x8009bb4c 
    

EXIT:
    mr r3, r31 # original code