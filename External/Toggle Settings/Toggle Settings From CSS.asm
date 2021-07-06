################################################################################
# Address: INJ_ToggleTapJump
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Settings/InitToggleSettings.s"

.set REG_CURRENT_PLAYER, 23
.set REG_STATIC_MEMORY_ADDR, 8

b CODE_START

STATIC_MEMORY_TABLE_BLRL:
  blrl
  # tap jump values
  .byte 0x01
  .byte 0x01 
  .byte 0x01
  .byte 0x01  
  # auto l-cancel values
  .byte 0x00
  .byte 0x00 
  .byte 0x00
  .byte 0x00  

RESET_SETTINGS_AND_EXIT:
  bl STATIC_MEMORY_TABLE_BLRL
  mflr r3
  load r4, 0x01010101
  stw r4, 0x0(r3) # load default flags
  load r4, 0x00000000
  stw r4, 0x8(r3) # load default flags
  
  b EXIT

# r3 must be current player index
# returns 
# r5: boolean flag for tap jump
# r6: boolean flag for l cancel
FN_GET_SETTINGS: 
  lbzx r5, r3, REG_STATIC_MEMORY_ADDR # load current tap jump flag for player
  addi r3, r3, 4 # offset to l cancel settings
  lbzx r6, r3, REG_STATIC_MEMORY_ADDR # load current l cancel flag for player
  blr

CODE_START:

  getMinorMajor r3
  cmpwi r3, SCENE_ONLINE_CSS
  beq RESET_SETTINGS_AND_EXIT # If online CSS, exit

  lbz r3, 7(r31)
  cmpwi r3, 0x0
  bne- RUMBLE_CURSOR
  lbz r4, 4(r31)
  mr REG_CURRENT_PLAYER, r4 # get current player index

  bl STATIC_MEMORY_TABLE_BLRL
  mflr REG_STATIC_MEMORY_ADDR

  mr r3, REG_CURRENT_PLAYER
  branchl r12, Inputs_GetPlayerInstantInputs 

  mr r3, REG_CURRENT_PLAYER # pre set current player index again

  cmpwi r4, 0x01 # LEFT
  beq TOGGLE_TAP_JUMP

  cmpwi r4, 0x02 # UP
  beq TOGGLE_L_CANCEL

  b EXIT

TOGGLE_TAP_JUMP: # r3 is already set to current player index
  bl FN_GET_SETTINGS
  cmpwi r5, 1
  beq TOGGLE_TAP_JUMP_OFF
  # b TOGGLE_TAP_JUMP_ON

TOGGLE_TAP_JUMP_ON:
  li r4, 0x1
  li r5, 0 # TAP JUMP
  b SET_SETTING_FLAG

TOGGLE_TAP_JUMP_OFF:
  li r4, 0x0
  li r5, 0 # TAP JUMP
  b SET_SETTING_FLAG

TOGGLE_L_CANCEL: # r3 is already set to current player index
  bl FN_GET_SETTINGS
  cmpwi r6, 1
  beq TOGGLE_L_CANCEL_OFF
  # b TOGGLE_L_CANCEL_ON

TOGGLE_L_CANCEL_ON: 
  li r4, 1
  li r5, 4 # L CANCEL
  b SET_SETTING_FLAG

TOGGLE_L_CANCEL_OFF:
  li r4, 0
  li r5, 4 # L CANCEL

SET_SETTING_FLAG: # r5 offsets to setting type (0=TapJump,4=LCancel)
  add r3, REG_STATIC_MEMORY_ADDR, r5 # offset to setting type
  stbx r4, REG_CURRENT_PLAYER, r3 # Persist flag

  mr r3, r4
  branchl r12, SFX_Menu_CommonSound

  # rumble controller
  mr r3, REG_CURRENT_PLAYER
  li r4, 0x0
  li r5, 0xE
  li r6, 0x0
  subi r7, r13, 0x66B0
  branchl r12, HSD_PadRumbleActiveID

INIT_RUMBLE_ANIM:
  # Init Rumble Cursor Anim 
  li r4, 0x1
  stb r4, 7(r31)
  lis r4, 0xC040
  stw r4, 20(r31)

RUMBLE_CURSOR:
  lfs f1, 20(r31)
  lfs f2, -29172(r2)
  lfs f0, 12(r31)
  fadds f0, f1, f0
  stfs f0, 12(r31)
  fneg f3, f1
  fcmpo cr0, f3, f1
  bgt- RUMBLE_CURSOR_2
  fmuls f3, f3, f2

RUMBLE_CURSOR_2:
  stfs f3, 20(r31)
  blt- EXIT
  lfs f4, -32168(r2)
  fcmpo cr0, f3, f4
  bgt- EXIT
  li r4, 0x0
  stw r4, 20(r31)
  stb r4, 7(r31)

EXIT:
  lfs	f1, 0x0010 (r31)
