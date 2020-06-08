######################################################################
#Function: do_all
#
#Description: Render AMF, STL and PNG from base.
#             Render AMF from modificators.
#             Merge AMF files.
#             Generate GCode from merged AMF file.
#
#Inputs: SCAD file.
#
#Outputs: AMF, STL, PNG from Base, AMF from midificators and GCODE.
#
#Return values: 0 - OK
#               1 - Error
######################################################################


mod_X=0
mod_Y=0
mod_Z=0

# If no parameter is passed, print help
if [ -z "${1}" ]; then
    echo "Usage ./do_all.sh file.scad"
    echo "Try './do_all.sh --help' for more information."
    exit 0
elif [ "${1}" == "--help" ] || [ "${1}" == "-h" ] ; then
    echo "Usage ./do_all.sh file.scad

Description: Render AMF, STL and PNG from base.
             Render AMF from modificators.
             Merge AMF files.
             Generate GCode from merged AMF file.

Inputs: SCAD file.

Outputs: AMF, STL, PNG from Base, AMF from midificators and GCODE.

Return values: 0 - OK
               1 - Error"
    exit 0
fi

# Make sure there aint no tmp files from previous run:
rm vertices.tmp volumes.tmp ini_parameters.tmp local_parameters.tmp\
   parameters.tmp tmp.scad 2>/dev/null

# Read parameters and set variables
scad=${1}
amf=$(echo ${scad} | sed 's/.scad/.amf/' | sed 's/^/..\/..\/amf\//')
stl=$(echo ${scad} | sed 's/.scad/.stl/' | sed 's/^/..\/..\/amf\//')
png=$(echo ${scad} | sed 's/.scad/.png/' | sed 's/^/..\/..\/doc\/img\//')
gcode=$(echo ${scad} | sed 's/.scad/.gcode/' | sed 's/^/..\/..\/amf\/gcode\//')
_num_of_vertices=0

# Make base
#TODO REMOVE# echo "Rendering base ${amf}"
#TODO REMOVE# openSCAD -D "draft = false" -o ${amf} ${scad}
#TODO REMOVE# echo "Rendering base ${stl}"
#TODO REMOVE# openscad -o ${stl} ${scad}
# TODO - Render PNG from STL? - Much faster.
#TODO REMOVE# echo "Rendering base ${png}"
#TODO REMOVE# openscad -o ${png} ${scad}

# Get base ini file:
ini_file=$(grep "set_slicing_config([^,]*)$" ${scad} |\
           sed 's/.*(\(.*\))/\1/')
# Save parameters from base file to local_parameters.tmp:
grep "set_slicing_parameter(" ${scad} |\
sed "s/.*(\([^,]*\), \(.*\))/\1 = \2/" >> local_parameters.tmp
# If ini file exists in given path, get parameters from file:
if test -e "${ini_file}"; then
    echo "Ini file for base is [${ini_file}]."
    cat ${ini_file} > ini_parameters.tmp
    # Merge parameters to file parameters.tmp (skip local parameters present in ini):
    cat local_parameters.tmp | sed 's/\([^ ]*\).*/-e "^\1 "/' | tr -s '\n' ' ' |\
    xargs grep -v ini_parameters.tmp > parameters.tmp
else
    echo "Ini file for base not found."
    rm parameters.tmp
fi
cat local_parameters.tmp >> parameters.tmp
# Add vertices opening tag:
echo "   <vertices>" >> vertices.tmp
# Write all vertices from base amf to temporary vertices file:
sed -n '/<vertex>/,/<\/vertex>/p' ${amf} >> vertices.tmp
# Add volume opening tag:
echo "   <volume>" >> volumes.tmp
# Write volume from current file:
sed -n '/<triangle>/,/<\/triangle>/p' ${amf} |\
# With renumbered indexes of vertices:
# For each occurence of <v[1-3]>[0-9]*.... save <v[1-3]> to buffer \1, [0-9]* to
# buffer \2 and the rest to buffer \3.
# Add _num_of_vertices to \2 and print \1\2\3
# Note: sed is too slow - using perl instead.
# sed "s/\( *<v[1-3]>\)\([0-9]*\)\(.*\)/echo \"\1\$((\2+${_num_of_vertices}))\3\"/e"\
perl -pe "s/>(\d+)</sprintf(\">%d<\", \$1+${_num_of_vertices})/e"\
>> volumes.tmp
# Wrap parameters in tags and add them to volumes.tmp:
cat parameters.tmp |\
sed 's/^\([^ ]*\) *= *\(.*\)/    <metadata type="slic3r.\1">\2<\/metadata>/'\
>> volumes.tmp
# Add volume closing tag:
echo "   </volume>" >> volumes.tmp
# Get current number of vertices in tmp file (used for next volumes offset):
_num_of_vertices=$(grep '<vertex>' vertices.tmp | wc -l | sed 's/ //g')

# Make modificators:
for mod in $(grep '//@set_modificator(' ${scad} | sed 's/.*(\(.*\))/\1/'); do
    # Clean parameters for next modificator
    axis=""
    axis_value=""
    ini_file=""
    echo "Rendering modificator [${mod}]"
# NOT USED #    # If modificator name ends with mod_X, mod_Y or mod_Z:
# NOT USED #    if $(echo ${mod} | grep -q "mod_[XYZ]$"); then
# NOT USED #        # Save modificator axis:
# NOT USED #        axis=$(echo ${mod} | sed 's/.*mod_//')
# NOT USED #        # Bash workaround for dictionary:
# NOT USED #        eval axis_value='$'mod_${axis}
# NOT USED #        echo "This modificator is used for manipulation of COG on ${axis} axis. Current offset used is [${axis_value}]"
    fi
    # Create temporary scad file for rendering of modificator:
    echo -e "use <${scad}>;\n${mod}();" > tmp.scad
    # Render modificator:
    openSCAD -o ${mod}.amf tmp.scad
    # Get modificator ini file:
    ini_file=$(grep "set_slicing_config.*, *${mod})" ${scad} |\
               sed 's/.*(\([^,]*\).*/\1/')
    # Save parameters from base file to local_parameters.tmp:
    grep "set_modificator_parameter(${mod}," ${scad} |\
    sed "s/.*(${mod}, *\([^,]*\), \(.*\))/\1 = \2/" > local_parameters.tmp
    # If ini file exists in given path, get parameters from file:
    if test -e "${ini_file}"; then
        echo "Ini file for modificator [${mod}] is [${ini_file}]."
        cat ${ini_file} > ini_parameters.tmp
        # Merge parameters to file parameters.tmp (skip local parameters present in ini):
        cat local_parameters.tmp | sed 's/\([^ ]*\).*/-e "^\1 "/' | tr -s '\n' ' ' |\
        xargs grep -v ini_parameters.tmp > parameters.tmp
    else
        #DEBUG# echo "Ini file for modificator [${mod}] not found."
        # Delete any old parameters.tmp
        rm parameters.tmp
    fi
    cat local_parameters.tmp >> parameters.tmp
    # Change axis parameters, if present
    if [ "axis_value" != "" ]; then
        perl -pi -e "s/fill_density = (\d+)/sprintf(\"fill_density = %d\", \$1+${axis_value})/e" parameters.tmp
        cat parameters.tmp
    fi
    # Write all vertices from current modifier amf to temporary vertices file:
    sed -n '/<vertex>/,/<\/vertex>/p' ${mod}.amf >> vertices.tmp
    # Add volume opening tag:
    echo "   <volume>" >> volumes.tmp
    # Write volume from current file:
    sed -n '/<triangle>/,/<\/triangle>/p' ${mod}.amf |\
    # With renumbered indexes of vertices:
    # For each occurence of <v[1-3]>[0-9]*.... save <v[1-3]> to buffer \1, [0-9]* to
    # buffer \2 and the rest to buffer \3.
    # Add _num_of_vertices to \2 and print \1\2\3
    # Note: sed is too slow - using perl instead.
    # sed "s/\( *<v[1-3]>\)\([0-9]*\)\(.*\)/echo \"\1\$((\2+${_num_of_vertices}))\3\"/e"\
    perl -pe "s/>(\d+)</sprintf(\">%d<\", \$1+${_num_of_vertices})/e"\
    >> volumes.tmp
    # Add modifier=1 parameter to all modifier volumes.
    echo '    <metadata type="slic3r.modifier">1</metadata>' >> volumes.tmp
    # Wrap parameters in tags and add them to volumes.tmp:
    cat parameters.tmp |\
    sed 's/^\([^ ]*\) *= *\(.*\)/    <metadata type="slic3r.\1">\2<\/metadata>/'\
    >> volumes.tmp
    # Add volume closing tag:
    echo "   </volume>" >> volumes.tmp
    # Get current number of vertices in tmp file (used for next volumes offset):
    _num_of_vertices=$(grep '<vertex>' vertices.tmp | wc -l | sed 's/ //g')
done

# Add vertices closing tag:
echo "   </vertices>" >> vertices.tmp

# TODO add header/footer
sed -n '/xml/,/<mesh>/p' ${amf} | sed 's/\r//' > result.amf
cat vertices.tmp volumes.tmp | sed 's/\r//' >> result.amf
sed -n '/<\/mesh>/,//p' ${amf} | sed 's/\r//' >> result.amf

mv result.amf 

# Clean-up tmp files
rm vertices.tmp volumes.tmp ini_parameters.tmp local_parameters.tmp\
   parameters.tmp tmp.scad 2>/dev/null

# NOT USED # Call slic3r:
# NOT USED # echo ~/playground/OpenSCAD/kaklik/Slic3r/slic3r.pl -o ${gcode} result.amf

# NOT USED # Get COG:
# NOT USED # echo ~/playground/OpenSCAD/kaklik/yagv/get_cog.py

# NOT USED # eval mod_X=$(expr ${mod_X} + 1)
