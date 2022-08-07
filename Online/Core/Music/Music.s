# This patch works by caching the whole audio HPS file needed into an address
# and making the game buffer from the cache instead of disc reads.
# Process:
#- Store current HPS file string
#- Store current HPS file ID
#- Load whole file into a buffer and store the static address to it
#- Hook into HPS_Pre-LoadCallback (LoadNextChunk) and make it use the cached static address instead.
#- On Game Scene exit, heap should be cleared on its own

# This injection contains static data related to cached music
.set INJ_fileLoad_HPS, 0x8038e90c

# Injection Data Offsets
.set IDO_HPS_STR, 0x8 # u32
.set IDO_HPS_ID, IDO_HPS_STR+0x4 # u8
.set IDO_HPS_BUFFER_SIZE, IDO_HPS_ID+1 # u32
.set IDO_HPS_BUFFER, IDO_HPS_BUFFER_SIZE+0x4 # u32
.set IDP_HPS_SIZE, IDO_HPS_BUFFER+4