################################################################################
# Address: 0x8024fa9c # Confirm Dialog
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

.set REG_DLG_GOBJ, 25
.set REG_DLG_JOBJ, 26

backup

# Create GObj on snapshot menu
li r3, 6 # GObj Type (6 is menu type?)
li r4, 7 # On-Pause Function (dont run on pause)
li r5, 128 # some type of priority
branchl r12, GObj_Create
mr REG_DLG_GOBJ, r3 # store result

# Create JOBJ
load r3, 0x804a0a78
lwz r3, 0x0(r3)
#load r3, 0x811f9054
stw	r25, 0x0014 (r30)
branchl r12, 0x80370E44 # (this func only uses r3)
mr REG_DLG_JOBJ, r3 # store result

# Add JOBJ to GObj
mr r3,REG_DLG_GOBJ
lbz	r4, -0x3E57 (r13)
mr r5,REG_DLG_JOBJ
branchl r12, 0x80390A70

# Add GXLink
mr r3,REG_DLG_GOBJ
load r4, 0x80391070 # GX Callback func to use
li r5, 6 # Assigns the gx_link index
li r6, 0x80 # sets the priority
branchl r12, 0x8039069c

restore

li	r3, 2


