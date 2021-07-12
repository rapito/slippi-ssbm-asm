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


# TODO: move to a function, expect r3 to be player index
.macro IsLTriggerPressed
load r4, 0x804c21cc #static mem to finding input data

# offset by player index
mulli r3, r3, 68  
add r3, r4, r3  

lfs f0, 0x30(r3) # check if L is pressed
lfs	f1, -0x778C (r2) # 0.0
fcmpo cr0, f0, f1 
.endm
