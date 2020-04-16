AMF_DIR = ../amf
IMG_DIR = ../doc/img
SRC_DIR = ./src
DEP_DIR = ./dep
GCODE_DIR = /Users/jkt/playground/OpenSCAD/kaklik/WINDGAUGE03/amf/gcode
PLATE_DIMMENSIONS=120
SIMARRANGE=/usr/local/bin/simarrange
STLSORT = stlsort
OPENSCAD_APP = openscad
MERGE_APP = ./merge_modifiers.sh
SLICER_APP = /Users/jkt/playground/OpenSCAD/kaklik/Slic3r/slic3r.pl
VPATH = $(SRC_DIR):$(DEP_DIR):$(AMF_DIR):$(IMG_DIR)

SOURCES = $(wildcard $(SRC_DIR)/*.scad)
AMF = $(wildcard $(AMF_DIR)/*.amf)
TARGETS = $(patsubst $(SRC_DIR)/%.scad, $(AMF_DIR)/%.amf, $(SOURCES))
IMAGES = $(patsubst $(SRC_DIR)/%.scad, $(IMG_DIR)/%.png, $(SOURCES))
GCODE = $(patsubst $(AMF_DIR)/%.amf, $(GCODE_DIR)/%.gcode, $(AMF))
STL = $(patsubst $(SRC_DIR)/%.scad, $(AMF_DIR)/%.stl, $(SOURCES))

all : amf images stl

calibration:
	openscad -m make -o calibration.stl calibration.scad

amf : $(TARGETS)

$(AMF_DIR)/%.amf : $(SRC_DIR)/%.scad
	# Update dependencies and make no-draft version of model in AMF.
	$(OPENSCAD_APP) -D "draft = false" -m make -o $@ -d $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@) $<
	# Remove absolute paths in dependencies.
	sed -i "s|$(shell pwd)/||" $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@)
	# Sort deps file to keep git changes to minimum.
	sort -bf $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@) -o $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@)
	sed -i 's|[^\]$$|& \\|' $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@)
	# Add modifiers to AMF files.
	$(MERGE_APP) -v -a $@ -s $<

include $(wildcard $(DEP_DIR)/*.deps)

stl : $(STL)

$(AMF_DIR)/%.stl : $(SRC_DIR)/%.scad
	# Make no-draft version of model in STL.
	$(OPENSCAD_APP) -D "draft = false" -m make -o $@ $<
	# Sort stl file to keep git changes to minimum.
	$(STLSORT) $@ || :

images : $(IMAGES)

$(IMG_DIR)/%.png : $(AMF_DIR)/%.stl
	# Create temporary file for fast image rendering.
	-echo "import(\"$<\");" > tmp.scad
	# Render PNG image from temporary file.
	$(OPENSCAD_APP) -o $@ tmp.scad
	# Remove temporary file
	rm -f tmp.scad

gcode : $(GCODE)

$(GCODE_DIR)/%.gcode : $(realpath $(AMF_DIR))/%.amf
	# Generate gcode files.
	$(SLICER_APP) --load default.ini -o $@ --no-gui -j 3 $<

arrange : amf
	$(SIMARRANGE) -x $(PLATE_DIMMENSIONS) -y $(PLATE_DIMMENSIONS) $(ARRANGE_TARGETS)

clean:
	rm -f calibration.stl
	rm -f $(AMF_DIR)/*.amf
	rm -f $(AMF_DIR)/*.stl
	rm -f $(IMG_DIR)/*.png
