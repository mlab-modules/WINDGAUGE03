#!/usr/bin/env python3

import math
import numpy as np
import xml.etree.ElementTree as ET
import subprocess

# I used this function to recalculate YAGV results.
# Used here to make script work without YAGV.
def get_gcode_cog_2(filename):
    parameters = {}
    with open(filename, 'r') as fp:
        line = fp.readline()
        while line:
            cmd = line.split()
            if not cmd:
                line = fp.readline()
                continue
            if cmd[0] == ';' and '=' in cmd:
                param_name = ' '.join(cmd[1:cmd.index('=')])
                param_value = ' '.join(cmd[cmd.index('=') + 1:])
                parameters[param_name] = param_value
            line = fp.readline()
    cgx = float(parameters['cog_x'])
    cgy = float(parameters['cog_y'])
    cgz = float(parameters['cog_z'])
    mass = float(parameters['filament used'].strip('g'))
    x_move = int(parameters['new_offset_X']) - int(parameters['original_offset_X'])
    y_move = int(parameters['new_offset_Y']) - int(parameters['original_offset_Y'])
    z_move = int(parameters['new_offset_Z']) - int(parameters['original_offset_Z'])
    return cgx - x_move, cgy - y_move, cgz - z_move, mass

def bisect(lst, current_index, direction):
    if direction == "UP":
        new_value = (lst[current_index] + lst[current_index + 1]) / 2
        if new_value in lst:
            return lst, current_index
        new_list = lst[:current_index + 1] + [int(new_value)] + lst[current_index + 1:]
        new_index = current_index + 1
    else:
        new_value = (lst[current_index] + lst[current_index - 1]) / 2
        new_list = lst[:current_index] + [int(new_value)] + lst[current_index:]
        new_index = current_index
        if new_value in lst:
            return lst, current_index
    return new_list, new_index

def new_density(value, density, req = 0):
    if value > req:
        density = (density + 100) / 2
    else:
        density = density / 2
    return density

# Find density for given modifier name
def get_mod(amf, mod_name):
    tree = ET.parse(amf)
    root = tree.getroot()
    for vol in root.findall(".//volume"):
        if mod_name in [ e.text for e in vol ]:
            for met in vol.iter('metadata'):
                if met.attrib['type'] == "slic3r.fill_density":
                    # strip % sign
                    return int(met.text[:-1])

def update_mod(amf, mod_name, density):
    tree = ET.parse(amf)
    root = tree.getroot()
    for vol in root.findall(".//volume"):
        if mod_name in [ e.text for e in vol ]:
            for met in vol.iter('metadata'):
                if met.attrib['type'] == "slic3r.fill_density":
                    met.text = str(density) + "%"
    tree.write(amf)

def rotate(point, angle):
    """
    Rotate a point counterclockwise by a given angle around (0, 0).

    The angle should be given in radians.
    """
    px, py = point
    qx = math.cos(angle) * px - math.sin(angle) * py
    qy = math.sin(angle) * px + math.cos(angle) * py
    return qx, qy

def rotate_3d(point, rotations):
    """
    Rotate a point as in openscad

    Angles should be given in degrees.
    """
    x, y, z = point
    r1, r2, r3 = rotations
    y, z = rotate((y, z), math.radians(r1))
    z, x = rotate((z, x), math.radians(r2))
    x, y = rotate((x, y), math.radians(r3))
    return x, y, z

def get_component_cog(rotations, movements, filename):
    mx, my, mz = movements
    x, y, z, m = get_gcode_cog_2(filename)
    nx, ny, nz = rotate_3d([x, y, z], rotations)
    return nx + mx, ny + my, nz + mz, m

xc = [] # x of components
yc = [] # y of components
zc = [] # z of components
mc = [] # m of components

#TODO read components from assembly?
# Columns are path to gcode | rotations | movements | mass in grams
components = [
    ["../amf/gcode/WINDGAUGE_R03_mod.gcode", [270,  0,   0], [    0,    -84,   198], 0],
    ["../amf/gcode/WINDGAUGE_R04.gcode"    , [  0,  0,   0], [    0,     48,   219], 0],
    ["../amf/gcode/WINDGAUGE_R05.gcode"    , [ 90,  0, 270], [    0, -111.7,   198], 0],
    ["../amf/gcode/BOLT_M3x12.gcode"       , [0  , 0,   90], [-13.6,   45.5,   216], 1],
    ["../amf/gcode/BOLT_M3x12.gcode"       , [0  , 0,   90], [ 13.6,   45.5,   216], 1],
    ["../amf/gcode/BOLT_M3x12.gcode"       , [0  , 90,   0], [-4.65,  -77.7, 222.3], 1],
    ["../amf/gcode/BOLT_M3x12.gcode"       , [0  , 90,   0], [-4.65,  -77.7, 173.7], 1],
]

print("########################## START ##################################################")

for c in components:
  print("Calculating component:", c[0])
  x, y, z, m = get_component_cog(c[1], c[2], c[0])
  if c[3] > 0:
    m = c[3]
  print(c[0], round(x, 2), round(y, 2), round(z, 2), round(m, 3))
#TODO write back to assembly?
  print("translate([", x,"," , y, ",", z, "])\n\n")
  xc.append(x)
  yc.append(y)
  zc.append(z)
  mc.append(m)

cgx = np.sum(np.multiply(xc, mc))/np.sum(mc)
cgy = np.sum(np.multiply(yc, mc))/np.sum(mc)
cgz = np.sum(np.multiply(zc, mc))/np.sum(mc)

print("Assembly COG is:", round(cgx, 2), round(cgy, 2), round(cgz, 2))
print("Desired  COG is:", 0, 0, 100)
print("translate([", cgx,"," , cgy, ",", cgz, "])")

subprocess.run('cp ../amf/WINDGAUGE_R03_mod.amf result.amf', shell=True)

mod_file = "result.amf" # Modifiable Component
mod_x = "WINDGAUGE_R03_mod_X" # X axis modificator name
mod_y = "WINDGAUGE_R03_mod_Y"
mod_z = "WINDGAUGE_R03_mod_Z"

#TODO add offset to COG to replace hard coded value 198
mods = {'x':{'used_dens':[0, get_mod(mod_file, mod_x), 101], 'index':1, 'mod_name':mod_x, 'cog':cgx},
        'y':{'used_dens':[0, get_mod(mod_file, mod_y), 101], 'index':1, 'mod_name':mod_y, 'cog':cgy},
        'z':{'used_dens':[0, get_mod(mod_file, mod_z), 101], 'index':1, 'mod_name':mod_z, 'cog':cgz - 198}}

while abs(mods['x']['cog']) > 0.1 or abs(mods['y']['cog']) > 0.1 or abs(mods['z']['cog']) > 0.1:
    print("########################## START ##################################################")

    for axis in ['x', 'y', 'z']:
        if mods[axis]['cog'] > 0.1:
            new_list, new_index = bisect(mods[axis]['used_dens'], mods[axis]['index'], "DOWN")
        elif mods[axis]['cog'] < -0.1:
            new_list, new_index = bisect(mods[axis]['used_dens'], mods[axis]['index'], "UP")
        else:
            new_list = mods[axis]['used_dens']
        if len(new_list) != len(mods[axis]['used_dens']):
            mods[axis]['used_dens'] = list(new_list)
            print("Changing", axis, "density to:", mods[axis]['used_dens'][new_index])
            update_mod(mod_file, mods[axis]['mod_name'], mods[axis]['used_dens'][new_index])
            mods[axis]['index'] = new_index
            #print(mods[axis]['index'], mods[axis]['used_dens'])

#TODO replace hard coded slicer paths
    print("Slic3r running...")
    subprocess.run('Slic3r --load ../amf/gcode/default.ini --no-gui -j 6 -o result.gcode result.amf > /dev/null', shell=True)

    print("Calculating CoG...")
#TODO replace hard coded input file result.gcode
    xc[0], yc[0], zc[0], mc[0] = get_component_cog(components[0][1], components[0][2], "result.gcode")
#TODO add offset to COG to replace hard coded value 198
    mods['x']['cog'] = np.sum(np.multiply(xc, mc))/np.sum(mc)
    mods['y']['cog'] = np.sum(np.multiply(yc, mc))/np.sum(mc)
    mods['z']['cog'] = np.sum(np.multiply(zc, mc))/np.sum(mc) - 198

    print("Assembly COG is:", round(mods['x']['cog'], 2), round(mods['y']['cog'], 2), round(mods['z']['cog'], 2))
