################################################################################
# Address: 0x80229944 # Start of MainMenu_CheckIfOptionsIsUnlocked we backup
# the parameters so we can use them later
################################################################################

.include "External/BM Hacks/OnlineMenu/Common.s"
.include "Common/Common.s"
.include "Online/Online.s"

.set REG_BACKUP_MENU_OPTION, 31
.set REG_BACKUP_SUBMENU_OPTION, 30
stwu sp, -0x0008 (sp) #original code

backup # make space for backup registers
# backup original parameters
mr REG_BACKUP_MENU_OPTION, r3
mr REG_BACKUP_SUBMENU_OPTION, r4