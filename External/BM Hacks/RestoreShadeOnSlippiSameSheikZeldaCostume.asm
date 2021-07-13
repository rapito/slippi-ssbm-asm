################################################################################
# Address: 0x8016e750 # StartMelee after all slippi stuff has run
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Menus/CSS/Teams/Teams.s"


.set REG_BACKUP_R3, 7
.set REG_MATCH_INFO, 31 # from parent

# backup r3
mr REG_BACKUP_R3, r3

# Ensure that this is an online CSS
getMinorMajor r3
cmpwi r3, SCENE_ONLINE_IN_GAME
bne EXIT # If not online GAME, continue as normal

lbz r3, OFST_R13_ONLINE_MODE(r13)
cmpwi r3, ONLINE_MODE_TEAMS
beq EXIT # continue as normal if on teams mode

CODE_START:
    lbz r3, 0x60(REG_MATCH_INFO) # get p1 char
    lbz r4, 0x60+0x24(REG_MATCH_INFO) # get p2 char


CHECK_P1_ZELDA:
    cmpwi r3, 0x12 # check if zelda
    beq CHECK_P2_SHEIK

CHECK_P1_SHEIK:
    cmpwi r3, 0x13 # check if sheik
    beq CHECK_P2_ZELDA
    
    b EXIT # continue as normal if not zelda or sheik

CHECK_P2_ZELDA:
    cmpwi r4, 0x12 # check if zelda
    beq CHECK_COLORS
    b EXIT

CHECK_P2_SHEIK:
    cmpwi r4, 0x13 # check if sheik
    bne EXIT # continue as normal if not zelda or sheik

CHECK_COLORS:
    lbz r3, 0x63(REG_MATCH_INFO) # get p1 color
    lbz r4, 0x63+0x24(REG_MATCH_INFO) # get p2 color

    cmpw r3, r4 
    bne EXIT # exit if not same colors

    # clear out p2's shade
    li r3, 0
    stb r3, 0x67+0x24(REG_MATCH_INFO)


EXIT:
    mr r3, REG_BACKUP_R3 # restore backup
    lis	r4, 0x8017 # original code line