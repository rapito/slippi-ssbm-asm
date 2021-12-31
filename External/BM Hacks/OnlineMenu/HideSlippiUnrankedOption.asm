################################################################################
# Address: 0x802299f8 # Before MainMenu_CheckIfOptionsIsUnlocked returns
# we check the original paremeters and only allow the menu options we want
################################################################################

.include "External/BM Hacks/OnlineMenu/Common.s"
.include "Common/Common.s"
.include "Online/Online.s"

.set REG_BACKUP_MENU_OPTION, 31
.set REG_BACKUP_SUBMENU_OPTION, 30
.set REG_ORIG_RETURN_VALUE, 29

mr REG_ORIG_RETURN_VALUE, r3 # backup what the fn was about to return
# grab original parameters
mr r3, REG_BACKUP_MENU_OPTION
mr r4, REG_BACKUP_SUBMENU_OPTION

# if not online mode just continue as normal
cmpwi r3, 0x8 # online mode
bne- RETURN_NORMAL

lbz r3, OFST_R13_APP_STATE(r13)
cmpwi r3, 0
beq RETURN_NORMAL
cmpwi r3, 2
beq RETURN_NORMAL

# everything here are the only options allowed, so leave their default value as is
cmpwi r4, OPTION_DIRECT_IDX
beq RETURN_NORMAL
cmpwi r4, OPTION_TEAMS_IDX
beq RETURN_NORMAL
cmpwi r4, OPTION_LOGOUT_IDX
beq RETURN_NORMAL
cmpwi r4, OPTION_UPDATE_IDX
beq RETURN_NORMAL
cmpwi r4, OPTION_UNRANKED_IDX
li r4, 1 # enable it
beq EXIT

# anything else block it
li r3, 0
b EXIT

RETURN_NORMAL:
mr r3, REG_ORIG_RETURN_VALUE

EXIT:
restore # restore backup registers
addi sp, sp, 8 #original code
