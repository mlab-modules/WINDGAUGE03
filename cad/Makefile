AMF_DIR := ../amf
STL_DIR := ../doc/stl
ASSEMBLY_STL_DIR := $(STL_DIR)
IMG_DIR := ../doc/img
SRC_DIR := ./src
ASSEMBLY_DIR := ./src/assembly
DEP_DIR := ./dep
GCODE_DIR := ../amf/gcode
PLATE_DIMMENSIONS=120
SIMARRANGE=/usr/local/bin/simarrange
STLSORT := stlsort
AMFSORT := ./amfsort.py
OPENSCAD_APP := $(shell which openscad || which openscad-nightly)
MERGE_APP := ./merge_modifiers.sh
SLICER_APP := slic3r
SLICER_CFG := default.ini
SLICER_PM_CFG := default_prusa_m.ini
#$(GCODE_DIR)/WINDGAUGE_R04.gcode : override SLICER_CFG = default_prusa_m.ini
VPATH := $(SRC_DIR):$(DEP_DIR):$(AMF_DIR):$(IMG_DIR)

SOURCES := $(wildcard $(SRC_DIR)/*.scad)
ASSEMBLIES := $(wildcard $(ASSEMBLY_DIR)/*.scad)
AMF := $(wildcard $(AMF_DIR)/*.amf)
STL := $(patsubst $(SRC_DIR)/%.scad, $(STL_DIR)/%.stl, $(SOURCES))
ASSEMBLY := $(patsubst $(ASSEMBLY_DIR)/%.scad, $(ASSEMBLY_STL_DIR)/%.stl, $(ASSEMBLIES))
TARGETS := $(patsubst $(SRC_DIR)/%.scad, $(AMF_DIR)/%.amf, $(SOURCES))
IMAGES := $(patsubst $(SRC_DIR)/%.scad, $(IMG_DIR)/%.png, $(SOURCES))
GCODE := $(patsubst $(AMF_DIR)/%.amf, $(GCODE_DIR)/%.gcode, $(AMF))

all : amf gcode stl images

print : amf gcode

view : stl images

calibration:
	openscad -m make -o calibration.stl calibration.scad

amf : $(TARGETS)

$(AMF_DIR)/%.amf : $(SRC_DIR)/%.scad
	####################################################################################
	# MAKING AMF FOR $<
	####################################################################################
	#
	# Update dependencies and make no-draft version of model in AMF.
	$(OPENSCAD_APP) -D "draft = false" -m make -o $@ -d $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@) $<
	# Remove absolute paths in dependencies.
	sed -i "s|$(shell pwd)/||" $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@)
	# Sort deps file to keep git changes to minimum.
	sort -rf $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@) -o $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@)
	sed -i 's|[^\]$$|& \\|' $(patsubst $(AMF_DIR)/%.amf, $(DEP_DIR)/%.deps, $@)
	# Sort AMF file to keep git changes to minimum.
	$(AMFSORT) $@
	# Add modifiers to AMF files.
	$(MERGE_APP) -a $@ -s $<

include $(wildcard $(DEP_DIR)/*.deps)

stl : $(STL)

$(STL_DIR)/%.stl : $(AMF_DIR)/%.amf
	####################################################################################
	# MAKING STL FOR $<
	####################################################################################
	#
	# Make no-draft version of model in STL.
	$(OPENSCAD_APP) -D "draft = false" -m make -o $@ $(patsubst $(STL_DIR)/%.stl, $(SRC_DIR)/%.scad, $@)
	# Sort stl file to keep git changes to minimum.
	$(STLSORT) $@ || :

images : $(IMAGES)

$(IMG_DIR)/%.png : $(STL_DIR)/%.stl
	####################################################################################
	# MAKING PNG FOR $<
	####################################################################################
	#
	# Create temporary file for fast image rendering.
	echo "import(\"$<\");" > tmp.scad
	# Render PNG image from temporary file.
	$(OPENSCAD_APP) -o $@ tmp.scad
	# Remove temporary file
	rm -f tmp.scad

assembly : $(ASSEMBLY)

$(ASSEMBLY_STL_DIR)/%.stl : $(ASSEMBLY_DIR)/%.scad
	####################################################################################
	# MAKING STL FOR $<
	####################################################################################
	# $(ASSEMBLY_STL_DIR)
	# Update dependencies and make no-draft version of model in STL.
	$(OPENSCAD_APP) -D 'stl_dir = "../../../stl/"' -D "draft = false" -m make -o $@ -d $(patsubst $(ASSEMBLY_STL_DIR)/%.stl, $(DEP_DIR)/%.deps, $@) $<
	# Remove absolute paths in dependencies.
	sed -i "s|$(shell pwd)/||" $(patsubst $(ASSEMBLY_STL_DIR)/%.stl, $(DEP_DIR)/%.deps, $@)
	# Sort deps file to keep git changes to minimum.
	sort -rf $(patsubst $(ASSEMBLY_STL_DIR)/%.stl, $(DEP_DIR)/%.deps, $@) -o $(patsubst $(ASSEMBLY_STL_DIR)/%.stl, $(DEP_DIR)/%.deps, $@)
	sed -i 's|[^\]$$|& \\|' $(patsubst $(ASSEMBLY_STL_DIR)/%.stl, $(DEP_DIR)/%.deps, $@)

gcode : $(GCODE)

$(GCODE_DIR)/%.gcode : $(AMF_DIR)/%.amf
	####################################################################################
	# MAKING GCODE FOR $<
	####################################################################################
	#
	# Generate gcode files.
	$(SLICER_APP) --load $(GCODE_DIR)/$(SLICER_CFG) -o $@ -j 3 $<
	$(SLICER_APP) --load $(GCODE_DIR)/$(SLICER_PM_CFG) -o $(patsubst %.gcode, %_pm.gcode, $@) -j 3 $<

arrange : amf
	$(SIMARRANGE) -x $(PLATE_DIMMENSIONS) -y $(PLATE_DIMMENSIONS) $(ARRANGE_TARGETS)

clean:
	rm -f calibration.stl
	rm -f $(AMF_DIR)/*.amf
	rm -f $(STL_DIR)/*.stl
	rm -f $(IMG_DIR)/*.png
