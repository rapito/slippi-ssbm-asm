################################################################################
# Address: 0x8024faa0 # Custom Confirm Dialog shows when hitting down on the erase data menu
################################################################################

.include "Common/Common.s"


.set REG_DLG_GOBJ, 29
.set REG_DLG_JOBJ, 28

# Stack Pointer Offsets
#.set JOBJ_DESC_DLG, 0x811f9054 # memory address of dialog jobj
#.set JOBJ_DESC_DLG_ANIM_JOINT, 0x811fc160 # memory address of dialog anim joint
#.set JOBJ_DESC_DLG_MAT_JOINT, 0x811fc3e8 # memory address of dialog mat joint
#.set JOBJ_DESC_DLG_SHAPE_JOINT, 0x811fc4e0 # memory address of dialog shape joint

#.set JOBJ_DESC_DLG, 0x804a0938 # memory address of dialog jobj # value is actually: 81202714
#.set JOBJ_DESC_DLG_ANIM_JOINT, 0x804a093C # memory address of dialog anim joint: 81205820
#.set JOBJ_DESC_DLG_MAT_JOINT, 0x804a0940 # memory address of dialog mat joint: 81205AA8
#.set JOBJ_DESC_DLG_SHAPE_JOINT, 0x804a0944 # memory address of dialog shape joint: 81205BA0

# 804a0938: Pointer to Dialog DAT file
# 80250170: Function that opens/creates erase data menu
# 80250270: Function address where loadFile2 is called
# 80016af0: Function that loads Dialog Dat file into memory
# stw	r8, 0x002C (sp) # pointer to pointer of dialog jbobj address is stoed here before assingment
# stw	r28, 0x0034 (sp) #  pointer to pointer of dialog anim joint jbobj address is stoed here before assingment
# stw	r30, 0x003C (sp) #  pointer to pointer of dialog mat joint jbobj address is stoed here before assingment
# stw	r12, 0x0044 (sp) #  pointer to pointer of dialog shape joint jbobj address is stoed here before assingment
# offsets:
# 0x0: JOBJ
# 0x4: ANIMATION JOINT
# 0x8: MATERIAL ANIM JOINT
# 0xC: SHAPE ANIM JOINT
# 8130d620: Archive Address of Dialog?  loaded on LoadFile2 in a loop  used with HSD_ArchiveGetPublicAddress(r3=archive=8130d620, r4=char* symbols = 803ef928)
# JBOJ loading: HSD_ArchiveGetPublicAddress(r3=archive=8130d620, r4=char* symbols = 803efa0c) "MenMainWarCmn_Top_joint"
# ABOJ loading: HSD_ArchiveGetPublicAddress(r3=archive=8130d620, r4=char* symbols = 803efa24)
# MBOJ loading: HSD_ArchiveGetPublicAddress(r3=archive=8130d620, r4=char* symbols = 803efa40)
# SBOJ loading: HSD_ArchiveGetPublicAddress(r3=archive=8130d620, r4=char* symbols = 803efa60)

# Starts dialog file pointers 810f904c

# Playing a sound just to know this is being hit
li	r3, 3
branchl r12, SFX_Menu_CommonSound

backup

.set JOBJ_DESC_DLG, 0x81202714 # memory address of dialog jobj # value is actually: 81202714

# Create GObj on snapshot menu
li r3, 6 # GObj Type (6 is menu type?)
li r4, 7 # On-Pause Function (dont run on pause)
li r5, 0x80 # some type of priority
branchl r12, GObj_Create
mr REG_DLG_GOBJ, r3 # 0x803901f0 store result

# Create JOBJ
load r3, JOBJ_DESC_DLG
#lwz r3, 0x0(r3) # JOBJ for dialog
branchl r12, JObj_LoadJoint # 0x80370E44 # (this func only uses r3)
mr REG_DLG_JOBJ, r3 # store result

# Add JOBJ to GObj
mr r3,REG_DLG_GOBJ
li	r4, 3
mr r5,REG_DLG_JOBJ
branchl r12, GObj_AddToObj # 0x80390A70

# AddGXLink
mr r3, REG_DLG_GOBJ
load r4, 0x80391070 # GX Callback func to use
li r5, 6 # Assigns the gx_link index
li r6, 0x80 # sets the priority
branchl r12, GObj_SetupGXLink # 0xz

#8137d238 d250
#C0600000 # -3.5
#400c0000 # 3.5

# 0x38: X Position
# 0x50: Real X Position

mr r3,REG_DLG_JOBJ # jobj
addi r4, sp, 0x34 # pointer where to store return value
mr r5, 10 # index
li r6, -1
branchl r12, JObj_GetJObjChild

# Set invisible flag on JObj
lwz r4, 0x34(sp)
lwz r3, 0x14(r4) # Get current flags
ori r3, r3, 0x10 # Set invisible flag
stw r3, 0x14(r4)

; load r4, JOBJ_DESC_DLG_ANIM_JOINT
; load r5, JOBJ_DESC_DLG_MAT_JOINT
; load r6, JOBJ_DESC_DLG_SHAPE_JOINT
;
; mr r3, REG_DLG_JOBJ
; lwz r4, 0x0(r4)
; lwz r5, 0x0(r5)
; lwz r6, 0x0(r6)
; branchl r12, JObj_AddAnimAll
;
; mr r3, REG_DLG_JOBJ
; branchl r12, JObj_ReqAnimAll# (jobj, frames)
;
; mr r3, REG_DLG_JOBJ
; branchl r12, JObj_AnimAll


restore
