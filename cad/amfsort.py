#!/usr/bin/env python3

import xml.etree.ElementTree as ET
import sys

# Read command line arguments and check there is only one
arguments = sys.argv
if len(arguments) != 2:
    print("Usage: amfprint [FILE]")
    sys.exit(2)

amf = arguments[1]

# Read AMF file
try:
    tree = ET.parse(amf)
    root = tree.getroot()
except ET.ParseError:
    print(arguments[0], ": ", amf, ": File not in valid XML format", sep='')
    sys.exit(2)
except FileNotFoundError:
    print(arguments[0], ": ", amf, ": No such file or directory", sep='')
    sys.exit(2)
except:
    print("Unexpected error:", sys.exc_info()[0])
    sys.exit(2)

# Make list of lists from vertices
vertices = []
for group in root.findall(".//coordinates"):
    vertices.append([])
    for x in [ x for x in group ]:
        vertices[-1].append(float(x.text))

# Make list of lists from volumes
volumes = []
for group in root.findall(".//triangle"):
    volumes.append([])
    for x in [ x for x in group ]:
        volumes[-1].append(int(x.text))

# Test data:
#vertices = [[-54.3898, 38.8428, 6.0], [-54.9202, 38.7432, 6.0], [-54.9202, 34.7432, 6.0],
#            [-54.9202, 34.7432, 2.0], [-54.9202, -8.7432, 1.0], [-54.3877, 38.8293, 6.0],
#            [-54.9225, 38.7567, 6.0], [-55.1983, 39.1807, 6.0]]
#volumes = [[0, 1, 2], [2, 1, 3], [0, 4, 1], [1, 4, 3],
#           [2, 4, 1], [1, 5, 6], [2, 4, 6], [3, 5, 7]]

# Get order of vertices:
# - Enumerate will make (index; value) pairs.
# - Sorted with given key will sort based on values
# - b[0] will return indexes
order = [b[0] for b in sorted(enumerate(vertices), key=lambda i:i[1])]

# Create sorted list of vertices:
sorted_vertices = [ vertices[order[i]] for i in range(len(vertices)) ]

# Creation of sorted volumes as list of lists:
# TODO after volumes are sorted, slic3r returns errors.
#sorted_volumes = sorted([[ order.index(x) for x in triangle ] for triangle in volumes ])
sorted_volumes = [[ order.index(x) for x in triangle ] for triangle in volumes ]

# Change vertices order in AMF file:
i = 0
for group in root.findall(".//coordinates"):
    j = 0
    for x in [ x for x in group ]:
        x.text = str(sorted_vertices[i][j])
        j += 1
    i += 1

# Change volumes order in AMF file:
i = 0
for group in root.findall(".//triangle"):
    j = 0
    for x in [ x for x in group ]:
        x.text = str(sorted_volumes[i][j])
        j += 1
    i += 1

# Write back to AMF file
tree.write(amf, encoding="UTF-8", xml_declaration=True)
