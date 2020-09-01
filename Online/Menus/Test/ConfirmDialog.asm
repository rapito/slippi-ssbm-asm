################################################################################
# Address: 0x8024faa0 # Custom Confirm Dialog shows when hitting down on the erase data menu
################################################################################

.include "Common/Common.s"
.set REG_DLG_GOBJ, 29
.set REG_DLG_JOBJ, 28

# Stack Pointer Offsets
.set JOBJ_DESC_DLG, 0x811f9054 # memory address of dialog jobj
.set JOBJ_DESC_DLG_ANIM_JOINT, 0x811fc160 # memory address of dialog anim joint
.set JOBJ_DESC_DLG_MAT_JOINT, 0x811fc3e8 # memory address of dialog mat joint
.set JOBJ_DESC_DLG_SHAPE_JOINT, 0x811fc4e0 # memory address of dialog shape joint


# Playing a saund just to know this is being hit
li	r3, 3
branchl r12, SFX_Menu_CommonSound

backup

#lwz	r3, -0x3E68 (r13)
#branchl r12, 0x8038fe24 # address that calls function(8038fe24) blocks further innput in the erase menu?

# get some space
li  r4,516
branchl r12, Zero_AreaLength
# the above is me trying to free some space for the return pointer on calling GetJObjChild
# but I don't really understand the process of freeing memory and then accessing it.

# Create GObj on snapshot menu
li r3, 6 # GObj Type (6 is menu type?)
li r4, 7 # On-Pause Function (dont run on pause)
li r5, 0x80 # some type of priority
branchl r12, GObj_Create
mr REG_DLG_GOBJ, r3 # 0x803901f0 store result

# Create JOBJ
load r3, 0x811f9054 # JOBJ for dialog
branchl r12, JObj_LoadJoint # 0x80370E44 # (this func only uses r3)
mr REG_DLG_JOBJ, r3 # store result

# Add JOBJ to GObj
mr r3,REG_DLG_GOBJ
lbz	r4, -0x3E57 (r13)
mr r5,REG_DLG_JOBJ
branchl r12, GObj_AddToObj # 0x80390A70

# AddGXLink
mr r3, REG_DLG_GOBJ
load r4, 0x80391070 # GX Callback func to use
li r5, 6 # Assigns the gx_link index
li r6, 0x80 # sets the priority
branchl r12, GObj_SetupGXLink # 0x8039069c

# AddAnimAll
mr r3, REG_DLG_JOBJ
load r4, JOBJ_DESC_DLG_ANIM_JOINT
load r5, JOBJ_DESC_DLG_MAT_JOINT
load r6, JOBJ_DESC_DLG_SHAPE_JOINT
branchl r12, JObj_AddAnimAll #0x8036FB5C

# ReqAnimAll
loadf f1, r3, 0x00000000000000000 # start frame
mr r3, REG_DLG_JOBJ
branchl r12, JObj_ReqAnimAll #0x8036F8BC
# AnimAll
mr r3, REG_DLG_JOBJ
branchl r12, JObj_AnimAll #0x80370928


# GetJObj is called after the above on the snapshot menu, so I'm trying to use it, however
# it stores a lot of values on some offset of the sp which I'm not really sure where
# they are further used so I'm commenting them out
li	r0, 8
crclr	6
#stw	r0, 0x0008 (sp)
li	r0, 10
li	r3, 11
#stw	r0, 0x000C (sp)
li	r5, 13
li	r0, -1
#stw	r3, 0x0010 (sp)
mr r3, REG_DLG_JOBJ
addi	r4, sp, 0x035C # This is me trying to access the memory I freed upstairs (dunno if this is a valid offset)
#stw	r5, 0x0014 (sp)
li	r5, 0
li	r6, 2
#stw	r0, 0x0018 (sp)
li	r7, 4
li	r8, 5
li	r9, 6
li	r10, 7
branchl r12, JObj_GetJObjChild# 0x80011E24
# the above is all stolen from: 8025888c - 802588d8

# schedules original think function on the erase data menu
#mr r3, REG_DLG_GOBJ # GOBJ
#load r4, 0x8024eccc
#li r5, 0
#branchl r12, GObj_AddProc # Add To Proc

# schedule my own think funct
#bl ThinkDialog
#mflr r4 # Function to Run
#li r5, 0
#branchl r12, GObj_AddProc # Add To Proc

restore

b CreateDialog_Exit

################################################################################
# Routine: ThinkDialog
# ------------------------------------------------------------------------------
# Description: My belief is that this think function should make sure the dialog is being drawn, but I don't really know how... yet
################################################################################

ThinkDialog:
blrl


backup


ThinkDialog_Exit:
  restore
  blr

CreateDialog_Exit:

