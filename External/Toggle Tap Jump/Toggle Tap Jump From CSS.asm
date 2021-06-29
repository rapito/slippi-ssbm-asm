################################################################################
# Address: INJ_ToggleTapJump
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "External/Toggle Tap Jump/InitToggleTapJump.s"

.set REG_CURRENT_PLAYER, 23

b CODE_START

STATIC_MEMORY_TABLE_BLRL:
  blrl
  .byte 0x01
  .byte 0x01 
  .byte 0x01
  .byte 0x01  

RESET_SETTINGS_AND_EXIT:
  bl STATIC_MEMORY_TABLE_BLRL
  mflr r3
  load r4, 0x01010101
  stw r4, 0x0(r3) # load current flag for player
  b EXIT

CODE_START:

  getMinorMajor r3
  cmpwi r3, SCENE_ONLINE_CSS
  beq RESET_SETTINGS_AND_EXIT # If online CSS, exit

  lbz r3, 7(r31)
  cmpwi r3, 0x0
  bne- RUMBLE_CURSOR
  lbz r4, 4(r31)
  mr REG_CURRENT_PLAYER, r4
  
  bl STATIC_MEMORY_TABLE_BLRL
  mflr r3
  lbzx r5, REG_CURRENT_PLAYER, r3 # load current flag for player

  mr r3, REG_CURRENT_PLAYER
  branchl r12, Inputs_GetPlayerInstantInputs 
  cmpwi r4, 0x02
  beq TOGGLE_TAMP_JUMP_ON
  cmpwi r4, 0x01
  beq TOGGLE_TAMP_JUMP_OFF
  b EXIT

TOGGLE_TAMP_JUMP_ON:
  cmplwi r5, 1 # if already on exit
  beq- EXIT
  mr r3, REG_CURRENT_PLAYER
  li r4, 0x0
  li r5, 0xE
  li r6, 0x0
  subi r7, r13, 0x66B0
  branchl r12, HSD_PadRumbleActiveID
  li r4, 0x1
  b SET_TAP_JUMP_FLAG

TOGGLE_TAMP_JUMP_OFF:
  cmplwi r5, 0 # if already off exit
  beq- EXIT
  li r4, 0x0

SET_TAP_JUMP_FLAG:
  bl STATIC_MEMORY_TABLE_BLRL
  mflr r3
  stbx r4, REG_CURRENT_PLAYER, r3 # Persist flag

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
