################################################################################
# Address: 0x802652ec # CSS_LoadFunction before slippi loads everything
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Menus/CSS/Teams/Teams.s"

# Ensure that this is an online CSS
getMinorMajor r3
cmpwi r3, SCENE_ONLINE_CSS
bne EXIT # If not online CSS, continue as normal

lbz r3, OFST_R13_ONLINE_MODE(r13)
cmpwi r3, ONLINE_MODE_TEAMS
bne EXIT # exit if not on TEAMS mode

CODE_START:
    # Store new Y POS for team toggle button
    computeBranchTargetAddress r3, INJ_InitTeamToggleButton
    
    load r4, 0xc0b00000 # -5.5f
    stw r4, IDO_TEAM_IDX+1+(0*4)(r3) # offset to toggle button top y bound (TPO_BOUNDS_ICON_TOP)

    load r4, 0xc11e6666 # -9.9f
    stw r4, IDO_TEAM_IDX+1+(1*4)(r3) # offset to toggle button bottom y bound (TPO_BOUNDS_ICON_BOTTOM)

    load r4, 0xc0e9999a # -7.3f
    stw r4, IDO_TEAM_IDX+1+(7*4)(r3) # offset to toggle button y pos (TPO_ICON_POS_Y)

EXIT:
    li	r3, 0 # original code line