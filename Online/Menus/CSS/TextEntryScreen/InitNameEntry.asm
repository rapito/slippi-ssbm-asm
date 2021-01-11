################################################################################
# Address: 0x8023e994
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

lbz r3, OFST_R13_NAME_ENTRY_MODE(r13)
cmpwi r3, 0
beq EXIT

b CODE_START

DATA_BLRL:
blrl
# Base Text Properties
.set DOFST_TEXT_BASE_Z, 0
.float 17
.set DOFST_TEXT_BASE_CANVAS_SCALING, DOFST_TEXT_BASE_Z + 4
.float 0.0665

# Line Text Properties
.set DOFST_TEXT_X_POS, DOFST_TEXT_BASE_CANVAS_SCALING + 4
.float -144
.set DOFST_TEXT_Y_POS_LINE1, DOFST_TEXT_X_POS + 4
.float 114
.set DOFST_TEXT_Y_POS_LINE2, DOFST_TEXT_Y_POS_LINE1 + 4
.float 125
.set DOFST_TEXT_OPP_STR_X_POS, DOFST_TEXT_Y_POS_LINE2 + 4
.float -71.5
.set DOFST_TEXT_FONT_SIZE, DOFST_TEXT_OPP_STR_X_POS + 4
.float 0.35

.set DOFST_TEXT_HIGHLIGHT_COLOR, DOFST_TEXT_FONT_SIZE + 4
.long 0xFFCB00FF

# Line Text Strings
.set DOFST_TEXT_STRING_LINE1, DOFST_TEXT_HIGHLIGHT_COLOR + 4
.string "Enter your %s above."
.set DOFST_TEXT_STRING_LINE2, DOFST_TEXT_STRING_LINE1 + 21
.string "Your opponent will also need to enter yours"
.set DOFST_TEXT_STRING_OPP_CONNECT_CODE, DOFST_TEXT_STRING_LINE2 + 44
.string "opponent's connect code"
.align 2

################################################################################
# Initialize instruction text
################################################################################
.set REG_DATA_ADDR, 31
.set REG_TEXT_STRUCT, 30
.set REG_CHAT_GOBJ, 29
.set REG_CHAT_JOBJ, 28
CODE_START:
backup

bl DATA_BLRL
mflr REG_DATA_ADDR

# Create Text Struct
li r3, 0
li r4, 0
branchl r12, Text_CreateStruct
mr REG_TEXT_STRUCT, r3

# Set text kerning to close
li r4, 0x1
stb r4, 0x49(REG_TEXT_STRUCT)
# Set text to align left
li r4, 0x0
stb r4, 0x4A(REG_TEXT_STRUCT)

# Store Base Z Offset
lfs f1, DOFST_TEXT_BASE_Z(REG_DATA_ADDR) #Z offset
stfs f1, 0x8(REG_TEXT_STRUCT)

# Scale Canvas Down
lfs f1, DOFST_TEXT_BASE_CANVAS_SCALING(REG_DATA_ADDR)
stfs f1, 0x24(REG_TEXT_STRUCT)
stfs f1, 0x28(REG_TEXT_STRUCT)

# Initialize Line 1
lfs f1, DOFST_TEXT_X_POS(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_Y_POS_LINE1(REG_DATA_ADDR)
mr r3, REG_TEXT_STRUCT
addi r4, REG_DATA_ADDR, DOFST_TEXT_STRING_LINE1
addi r5, REG_DATA_ADDR, DOFST_TEXT_STRING_OPP_CONNECT_CODE
branchl r12, Text_InitializeSubtext

# Set Line 1 text size
mr r4, r3
mr r3, REG_TEXT_STRUCT
lfs f1, DOFST_TEXT_FONT_SIZE(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_FONT_SIZE(REG_DATA_ADDR)
branchl r12, Text_UpdateSubtextSize

# Initialize Line 2
lfs f1, DOFST_TEXT_X_POS(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_Y_POS_LINE2(REG_DATA_ADDR)
mr r3, REG_TEXT_STRUCT
addi r4, REG_DATA_ADDR, DOFST_TEXT_STRING_LINE2
branchl r12, Text_InitializeSubtext

# Set Line 2 text size
mr r4, r3
mr r3, REG_TEXT_STRUCT
lfs f1, DOFST_TEXT_FONT_SIZE(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_FONT_SIZE(REG_DATA_ADDR)
branchl r12, Text_UpdateSubtextSize

# Initialize highlight text
lfs f1, DOFST_TEXT_OPP_STR_X_POS(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_Y_POS_LINE1(REG_DATA_ADDR)
mr r3, REG_TEXT_STRUCT
addi r4, REG_DATA_ADDR, DOFST_TEXT_STRING_OPP_CONNECT_CODE
branchl r12, Text_InitializeSubtext

# Set highlight text size
mr r4, r3
mr r3, REG_TEXT_STRUCT
lfs f1, DOFST_TEXT_FONT_SIZE(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_FONT_SIZE(REG_DATA_ADDR)
branchl r12, Text_UpdateSubtextSize

# Set port label color
mr r3, REG_TEXT_STRUCT
li r4, 2
addi r5, REG_DATA_ADDR, DOFST_TEXT_HIGHLIGHT_COLOR
branchl r12, Text_ChangeTextColor

# Get Memory Buffer for Chat Window Data Table
li r3, CSSCWDT_SIZE # Buffer Size
branchl r12, HSD_MemAlloc
mr r23, r3 # save result address into r23
li r4, CSSCWDT_SIZE
branchl r12, Zero_AreaLength

# create gobj for think function
li r3, 0x4
li r4, 0x5
li r5, 0x80
branchl r12, GObj_Create
mr REG_CHAT_GOBJ, r3 # save GOBJ pointer

#0x804a06f0 # static pointer to loaded file when opening NameEntryScreen
# 0x40 is the first empty offset

# create jbobj (custom chat window background)
lwz r3, -0x49eC(r13) # = 804db6a0 pointer to MnSlChar file
lwz r3, 0x1C(r3) # pointer to our custom bg jobj
branchl r12,0x80370e44 #Create Jboj
mr  REG_CHAT_JOBJ,r3

# Add JOBJ To GObj
mr  r3,REG_CHAT_GOBJ
li r4, 4
mr  r5,REG_CHAT_JOBJ
branchl r12,0x80390a70 # void GObj_AddObject(GOBJ *gobj, u8 unk, void *object)

# Add GX Link that draws the background
mr  r3,REG_CHAT_GOBJ
load r4,0x80391070 # 80302608, 80391044, 8026407c, 80391070, 803a84bc
li  r5, 4
li  r6, 128
branchl r12,GObj_SetupGXLink # void GObj_AddGXLink(GOBJ *gobj, void *cb, int gx_link, int gx_pri)

# Add User Data to GOBJ ( Our buffer )
mr r3, REG_CHAT_GOBJ
li r4, 4 # user data kind
load r5, HSD_Free # destructor
mr r6, r23 # memory pointer of allocated buffer above
branchl r12, GObj_Initialize

# Set Think Function that runs every frame
mr r3, REG_CHAT_GOBJ # set r3 to GOBJ pointer
bl CSS_ONLINE_CHAT_WINDOW_THINK
mflr r4 # Function to Run
li r5, 4 # Priority. 4 runs after CSS_LoadButtonInputs (3)
branchl r12, GObj_AddProc


restore
b EXIT

################################################################################
# CHAT MSG THINK Function: Looping function to keep on
# updating the text until timer runs out
################################################################################
CSS_ONLINE_CHAT_WINDOW_THINK:
blrl
backup

CSS_ONLINE_CHAT_WINDOW_THINK_EXIT:
restore
blr



EXIT:
li r3, 0
