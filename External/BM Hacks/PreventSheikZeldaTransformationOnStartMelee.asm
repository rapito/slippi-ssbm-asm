################################################################################
# Address: 0x8016d978 # Addr in PlayerBlock_Initialize where the check starts 
# for A pressed in Zelda/Sheik Transform it ultimately checks if the input 
# is 100 to trigger the char swap
################################################################################

# original code line is lwz	r0, 0 (r3)
# Store 0 in loaded value 
li r0, 0
stw r0, 0(r3)
