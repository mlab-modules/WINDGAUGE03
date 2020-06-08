import xml.etree.ElementTree as ET
import subprocess

tree = ET.parse('result.amf')
root = tree.getroot()
for vol in root.findall(".//volume"):
    if 'WINDGAUGE_R03_mod_X' in [ e.text for e in vol ]:
        for met in vol.iter('metadata'):
            if met.attrib['type'] == "slic3r.fill_density":
                print(met.text)
                met.text = "22%"
                print(met.text)
for met in root.findall(".//metadata"):
    print(met.text)

tree.write('tmp.amf')
subprocess.run('~/playground/OpenSCAD/kaklik/Slic3r/slic3r.pl -o tmp.gcode --no-gui -j 3 tmp.amf', shell=True)
subprocess.run('~/playground/OpenSCAD/kaklik/Slic3r/slic3r.pl -o tmp.gcode --no-gui -j 3 tmp.amf', shell=True)
