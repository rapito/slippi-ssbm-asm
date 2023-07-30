import argparse
import os


gc_start_address = 0x8065cc80 + 0x8
gecko_codes = []
offset = 0
last_function_name = ''
processing_code = False
lines_to_process=0

# Function to parse a Gecko code block and generate a symbol map entry
def parse_gecko_code(gecko_code):
    global offset
    global processing_code
    global last_function_name
    global lines_to_process
    # Split the gecko code by spaces
    gecko_code_parts = gecko_code.split()

    # Parse the address, number of lines, and function name
    address = int(f'0x80{gecko_code_parts[0][2:]}', 16)
    code_lines = int(gecko_code_parts[1], 16)
    function_name = " ".join(gecko_code_parts[2:]).replace(' ', '_')
    if len(function_name) == 0:
        function_name = last_function_name

    address = gc_start_address + offset

    print(function_name)

    # Calculate the size of the code (in bytes)
    code_size = code_lines * 2 * 4

    if gecko_code.startswith("C2"):
        processing_code = True
        lines_to_process = code_lines
        offset += code_size
        address += 0x8 # (first line)
    elif gecko_code.startswith("06"):
        processing_code = True
        lines_to_process = code_lines
        offset += code_size
        address += 0x8 # (first line)
    elif gecko_code.startswith("04"):
        code_size = 0x4

    offset += 0x8

    symbol_map_entry = f'{address:08x} {code_size:08x} {address:08x} 0 {function_name}\n'
    last_function_name = function_name
    return symbol_map_entry

# Create the parser
parser = argparse.ArgumentParser(description='Generate a symbol map from a Gecko codes file.')

# Add the arguments
parser.add_argument('InputFile', metavar='input file', type=str, help='the input file containing Gecko codes',)
parser.add_argument('-o', '--output', default='./Output/Maps/GALE01r2.map', metavar='output filename', type=str, help='the output map file', required=False)

# Parse the arguments
args = parser.parse_args()

# Read the input text file
with open(args.InputFile, 'r') as f:
    lines = f.read().splitlines()

# Initialize an empty string to hold the symbol map
symbol_map = ''

# Parse each line in the text file
for line in lines:
    if lines_to_process > 0:
        lines_to_process -= 1
        processing_code = False
    else:
        # If the line starts with 'C2', parse it and add the symbol map entry to the symbol map
        starts_with_prefix = any(line.startswith(prefix) for prefix in ["C2","04","06"])
        if starts_with_prefix and not processing_code:
            gecko_codes.append(line)
            symbol_map += parse_gecko_code(line)


# Write the symbol map to a file
if not os.path.exists(os.path.dirname(args.output)):
    os.makedirs(os.path.dirname(args.output))

with open(args.output, 'w') as f:
    f.write(symbol_map)

print(symbol_map)  # Display the symbol map

# 0x8065cc80
# 0x8065cd28 - 0x8065cc80
# 0x8065cd28 - 0x801AF6F4 = 0x4AD634