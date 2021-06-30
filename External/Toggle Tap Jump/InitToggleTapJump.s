################################################################################
# Injection locations
################################################################################
.set INJ_ToggleTapJumpCSS, 0x802622b4 # BigCSS_Func....
.set INJ_ToggleTapJumpReadyThink, 0x802f7484 # Address in Ready Think function 

.macro CanRunInGameTapChecks exitLabel, branchTargetReg
computeBranchTargetAddress \branchTargetReg, INJ_ToggleTapJumpCSS
addi \branchTargetReg, \branchTargetReg, 0xC # address to FN_CAN_RUN_CODE
mtctr \branchTargetReg
bctrl # execute FN_CAN_RUN_CODE
cmpwi r3, 0 # if cannot run, exit
beq \exitLabel 
.endm