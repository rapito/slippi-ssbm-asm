#To be inserted at 800055f8
################################################################################
# Function: GetIsFollower
# Inject @ 800055f8
# ------------------------------------------------------------------------------
# Description: Returns whether or not the player is a follower
# ------------------------------------------------------------------------------
# in
#   r3 = player's data
# out
#   r3 = IsFollower
################################################################################
.include "Common/Common.s"

.set IsFollower,31
.set PlayerData,30

GetFrameIndex:
backup

mr  PlayerData,r3

# check if the player is a follower
  li IsFollower, 0 # initialize isFollower to false
  lbz	r3, 0x221F (PlayerData)
#Check If Subchar
  rlwinm.	r0, r3, 29, 31, 31
  beq	RETURN_IS_FOLLOWER
#Check If Follower
  lbz r3,0xC(PlayerData)
  branchl r12,0x80032330     #Get External Character ID
  load	r4,0x803bcde0			   #pdLoadCommonData table
  mulli	r0, r3, 3			       #struct length
  add	r3,r4,r0			         #get characters entry
  lbz	r0, 0x2 (r3)			     #get subchar functionality
  cmpwi	r0,0x0			         #if not a follower, exit
  bne	RETURN_IS_FOLLOWER
  li IsFollower, 1           # if we get here then we know this is nana
RETURN_IS_FOLLOWER:
  mr  r3,IsFollower

Exit:
#restore registers and sp
  restore
  blr