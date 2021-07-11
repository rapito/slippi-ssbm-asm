################################################################################
# Injection locations
################################################################################
.set INJ_ToggleSettingsCSS, 0x802622b4 # BigCSS_Func....
.set INJ_ToggleSettingsReadyThink, 0x802f7484 # Address in Ready Think function 

.macro CanRunInGameTapChecks exitLabel, branchTargetReg
computeBranchTargetAddress \branchTargetReg, INJ_ToggleSettingsCSS
addi \branchTargetReg, \branchTargetReg, 0xC+4 # address to FN_CAN_RUN_CODE
mtctr \branchTargetReg
bctrl # execute FN_CAN_RUN_CODE
cmpwi r3, 0 # if cannot run, exit
subi \branchTargetReg, \branchTargetReg, 0x8 # move back to static data addr
beq \exitLabel 
.endm 
