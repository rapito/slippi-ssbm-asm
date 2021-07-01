################################################################################
# Address: 0x802652f8 # CSS_LoadFunction after slippi loads everything
################################################################################
.include "Common/Common.s"
.include "Online/Online.s"
.include "Online/Menus/CSS/Teams/Teams.s"

.set REG_BACKUP_R3, 17 # this is later updated a couple lines down of where is hooked at
.set JOBJ_CHILD_OFFSET, 0x34 # Pointer to store Child JOBJ on the SP

mr REG_BACKUP_R3, r3

# Ensure that this is an online CSS
getMinorMajor r3
cmpwi r3, SCENE_ONLINE_CSS
bne EXIT # If not online CSS, continue as normal

lbz r3, OFST_R13_ONLINE_MODE(r13)
cmpwi r3, ONLINE_MODE_TEAMS
bne EXIT # exit if not on TEAMS mode

CODE_START:
    # Get Franchise icon
    lwz r3, -0x49E0(r13) # Points to SingleMenu live root Jobj
    addi r4, sp, JOBJ_CHILD_OFFSET # pointer where to store return value
    li r5, 0x2B # index of jboj child we want (franchise icon)
    li r6, -1
    branchl r12, JObj_GetJObjChild

    lwz r3, JOBJ_CHILD_OFFSET(sp) # Franchise Icon
    load r4, 0xc0f66660 # -7.699997
    stw r4, 0x3C(r3) # set Y position

EXIT:
    mr r3, REG_BACKUP_R3 # restore r3
    stw	r3, 0x0004 (r27) # original line