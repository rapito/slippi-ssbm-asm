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

.set JOBJ_DESC_DLG, 0x804a0938 # memory address of dialog jobj
.set JOBJ_DESC_DLG_ANIM_JOINT, 0x804a093C # memory address of dialog anim joint
.set JOBJ_DESC_DLG_MAT_JOINT, 0x804a0940 # memory address of dialog mat joint
.set JOBJ_DESC_DLG_SHAPE_JOINT, 0x804a0944 # memory address of dialog shape joint

# 804a0938: Pointer to Dialog DAT file
# offsets:
# 0x0: JOBJ
# 0x4: ANIMATION JOINT
# 0x8: MATERIAL ANIM JOINT
# 0xC: SHAPE ANIM JOINT


# Playing a sound just to know this is being hit
li	r3, 3
branchl r12, SFX_Menu_CommonSound

backup

# Create GObj on snapshot menu
li r3, 6 # GObj Type (6 is menu type?)
li r4, 7 # On-Pause Function (dont run on pause)
li r5, 0x80 # some type of priority
branchl r12, GObj_Create
mr REG_DLG_GOBJ, r3 # 0x803901f0 store result

# Create JOBJ
load r3, JOBJ_DESC_DLG
lwz r3, 0x0(r3) # JOBJ for dialog
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
branchl r12, GObj_SetupGXLink # 0x8039069c

load r4, JOBJ_DESC_DLG_ANIM_JOINT
load r5, JOBJ_DESC_DLG_MAT_JOINT
load r6, JOBJ_DESC_DLG_SHAPE_JOINT

mr r3, REG_DLG_JOBJ
lwz r4, 0x0(r4)
lwz r5, 0x0(r5)
lwz r6, 0x0(r6)
branchl r12, JObj_AddAnimAll

mr r3, REG_DLG_JOBJ
branchl r12, JObj_ReqAnimAll# (jobj, frames)

mr r3, REG_DLG_JOBJ
branchl r12, JObj_AnimAll


restore

