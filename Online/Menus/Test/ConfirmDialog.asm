################################################################################
# Address: 0x8024faa0 # Custom Confirm Dialog shows when hitting down on the erase data menu
################################################################################

.include "Common/Common.s"


# Playing a sound just to know this is being hit
li	r3, 3
branchl r12, SFX_Menu_CommonSound
branchl r12, 0x8024f924 # branch to adress after input is captured for A press on the think function.
b CreateDialog_Exit

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
li r5, 4 # Assigns the gx_link index
li r6, 0x80 # sets the priority
branchl r12, GObj_SetupGXLink # 0x8039069c

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
