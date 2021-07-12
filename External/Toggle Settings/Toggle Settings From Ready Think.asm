################################################################################
# Address: INJ_ToggleSettingsReadyThink # Address in Ready Think function 
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Settings/InitToggleSettings.s"

.set REG_CURRENT_PLAYER, 5
.set REG_DATA_BUFFER_ADDR, 6
.set REG_BACKUP_R3, 8

mr REG_BACKUP_R3, r3
b CODE_START

CODE_START:

  # check if a few frames have passed before checking
  # f2 holds current frames since READY/GO is being shown
  lfs f1, -0xF70(r13) # 25.0 
  fcmpo cr0, f2, f1  
  blt EXIT # if lower than threshold, exit

  # Load the values of the buffer
  computeBranchTargetAddress REG_DATA_BUFFER_ADDR, INJ_ToggleSettingsCSS

  li REG_CURRENT_PLAYER, 0 # start loop at 0
Loop:

  #Get players inputs
  mr r3,REG_CURRENT_PLAYER
  branchl r12, Inputs_GetPlayerHeldInputs
  cmpwi r4, 1 # PAD LEFT
  beq TurnTapJumpOff
  cmpwi r4, 0x40 # LEFT Trigger
  beq TurnLCancelOn
  cmpwi r4, 0x10 # Z
  beq TurnLCancelOn
  cmpwi r4, 0x41 # Both Buttons(L Trigger & PadLeft)
  beq TurnTapJumpOffAndLCancelOn
  cmpwi r4, 0x11 # Both Buttons (Z & PadLeft)
  beq TurnTapJumpOffAndLCancelOn

  # check if L trigger is being pressed at least a bit
  mr r3, REG_CURRENT_PLAYER
  addi r4, REG_DATA_BUFFER_ADDR, 0xC+4+0x2C # offset to FN_IS_ANALOG_L_PRESSED
  mtctr r4
  bctrl # execute FN_IS_ANALOG_L_PRESSED
  bgt TurnLCancelOn

  b LoopInc

TurnTapJumpOn:
  li r3, 1
  b PersistTapJump
TurnTapJumpOff:

  mr r3, REG_CURRENT_PLAYER
  addi r4, REG_DATA_BUFFER_ADDR, 0xC+4+0x2C # offset to FN_IS_ANALOG_L_PRESSED
  mtctr r4
  bctrl # execute FN_IS_ANALOG_L_PRESSED
  bgt TurnTapJumpOffAndLCancelOn

  li r3, 0
PersistTapJump: 
  addi r4, REG_CURRENT_PLAYER, 8
  stbx r3, r4, REG_DATA_BUFFER_ADDR 
  b LoopInc

TurnTapJumpOffAndLCancelOn:
  li r3, 0
  addi r4, REG_CURRENT_PLAYER, 8
  stbx r3, r4, REG_DATA_BUFFER_ADDR 
  li r3, 1
  addi r4, REG_CURRENT_PLAYER, 8+4
  stbx r3, r4, REG_DATA_BUFFER_ADDR 
  b LoopInc

TurnLCancelOn:
  li r3, 1
  b PersistLCancel
TurnLCancelOff:
  li r3, 0
PersistLCancel: 
  addi r4, REG_CURRENT_PLAYER, 8+4
  stbx r3, r4, REG_DATA_BUFFER_ADDR 

LoopInc:
  addi  REG_CURRENT_PLAYER,REG_CURRENT_PLAYER,1
  cmpwi REG_CURRENT_PLAYER,4
  blt Loop

EXIT:
  mr r3, REG_BACKUP_R3 # restore r3
  cmpwi	r3, 0 # original function