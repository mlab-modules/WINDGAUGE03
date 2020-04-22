#!/bin/bash
######################################################################
#
#       Function: parse_params
#
#    Description: Parses params $*.
#
# Inputs/Outputs: $*
#                -h, --help ........... HELP=true
#                -o, --output <file> .. out=<file>
#                -a, --amf <file> ..... amf=<file>
#                -s, --scad <file> .... scad=<file>
#                -v, --verbose ........ VERBOSE=true
#
#        Outputs: N/A
#
#  Return values: 0 - OK
######################################################################
function parse_params {
  for param in HELP VERBOSE ; do
    # !param means $($param) -> if $param=one and $one=two then ${!param}=two
    if [ -z "${!param}" ] ; then
      eval ${param}=false
    fi
  done

  param_prev=""
  param=""

  for param in $* ; do
    if [ ${param:0:1} != "-" ] ; then
      case ${param_prev} in
        --amf )
          amf="${param}"
          verbose_print "Using ${amf} as base."
          param_prev=""
        ;;
        --output )
          out="${param}"
          verbose_print "Output to ${out}."
          param_prev=""
        ;;
        --scad )
          scad="${param}"
          verbose_print "Merge based on file ${scad}."
          param_prev=""
        ;;
        * )
          verbose_print "Unknown parameter [${param}]."
      esac
      continue
    fi

    case ${param} in
      -a | --amf )
         param_prev="--amf"
      ;;
      -h | --help )
         HELP=true
         param_prev=""
      ;;
      -o | --output )
         param_prev="--output"
      ;;
      -s | --scad )
         param_prev="--scad"
      ;;
      -v | --verbose )
         param_prev=""
         VERBOSE=true
         verbose_print "VERBOSE set to TRUE"
      ;;
      * )
        verbose_print "Unknown parameter [${param}]."
    esac

  done
}
######################################################################
#
#         Function: verbose_print
#
#      Description: Looks for -v in $OPTION to set verbose mode.
#
#           Inputs:
#
# Global variables: VERBOSE
#
#          Outputs: Prints given text if VERBOSE is set
#
#    Return values: 0 - OK
######################################################################
function verbose_print {
  if $VERBOSE ; then
    local text="$*"
    printf "${text}\n" >&2
  fi
}

######################################################################
#
#         Function: merge_modifiers
#
#      Description: Render AMF from modifiers.
#                   Merge AMF files.
#
#           Inputs: -a, --amf <file> ..... Base AMF file
#                   -h, --help ........... Print help and exit
#                   -o, --output <file> .. Ouput file (by default, the file will be
#                                          saved in amf directory with suffix _mod)
#                   -s, --scad <file> .... Base SCAD file
#                   -v, --verbose ........ VERBOSE=true
#
#          Outputs: Merged AMF from Base and modifiers.
#
#    Return values: 0 - OK
#                   1 - Error
######################################################################

function merge_modifiers {
  # Read parameters:
  parse_params $*

  # If -h/--help in params, print help and exit:
  if ${HELP}; then
   echo "Usage ./merge_modifiers.sh [OPTIONS] -s [FILE.scad] -a [FILE.amf]

    Description: Render AMF from modifiers.
                 Merge AMF files.

         Inputs: -a, --amf <file> ..... Base AMF file
                 -h, --help ........... Print this help and exit
                 -o, --output <file> .. Ouput file (by default, the file will be
                                        saved in amf directory with suffix _mod)
                 -s, --scad <file> .... Base SCAD file
                 -v, --verbose ........ VERBOSE=true

        Outputs: Merged AMF from Base and modifiers.

  Return values: 0 - OK
                 1 - Error"
    exit 1
  fi

  # If file is missing in parameters:
  if [ "${scad}" == "" ] || [ "${amf}" == "" ]; then
    echo "ERROR: Missing SCAD or AMF file."
    echo "Usage ./merge_modifiers.sh [OPTIONS] -s [FILE.scad] -a [FILE.amf]"
    echo "Try './merge_modifiers.sh --help' for more information."
    exit 1
  fi

  # Make sure there are no tmp files from previous run:
  rm -f vertices.tmp volumes.tmp ini_parameters.tmp local_parameters.tmp\
        parameters.tmp tmp.scad 2>/dev/null

  # Set variables:
  _num_of_vertices=0

  # Check if file contains any modifiers, if not exit:
  grep -s -e '//@set_modifier(' ${scad} > /dev/null ||\
  { verbose_print "File does not contain any modifier." ; exit 0 ; }

  # Get base ini file:
  ini_file=$(grep "set_slicing_config([^,]*)$" ${scad} |\
             sed 's/.*(\(.*\))/\1/')
  # Save parameters from base file to local_parameters.tmp:
  grep "set_slicing_parameter(" ${scad} |\
  sed "s/.*(\([^,]*\), \(.*\))/\1 = \2/" >> local_parameters.tmp
  # If ini file exists in given path, get parameters from file:
  if test -e "${ini_file}"; then
    verbose_print "Ini file for base is [${ini_file}]."
    cat ${ini_file} > ini_parameters.tmp
    # Merge parameters to file parameters.tmp (skip local parameters present in ini):
    cat local_parameters.tmp | sed 's/\([^ ]*\).*/-e "^\1 "/' | tr -s '\n' ' ' |\
    xargs grep -v ini_parameters.tmp > parameters.tmp
  else
    verbose_print "Ini file for base not found."
    rm -f parameters.tmp
  fi
  cat local_parameters.tmp >> parameters.tmp
  # Add vertices opening tag:
  echo "  <vertices>" >> vertices.tmp
  # Write all vertices from base amf to temporary vertices file:
  sed -n '/<vertex>/,/<\/vertex>/p' ${amf} >> vertices.tmp
  # Add volume opening tag:
  echo "  <volume>" >> volumes.tmp
  # Write volume from current file:
  sed -n '/<triangle>/,/<\/triangle>/p' ${amf} |\
  # With renumbered indexes of vertices:
  perl -pe "s/>(\d+)</sprintf(\">%d<\", \$1+${_num_of_vertices})/e"\
  >> volumes.tmp
  # Wrap parameters in tags and add them to volumes.tmp:
  cat parameters.tmp |\
  sed 's/^\([^ ]*\) *= *\(.*\)/  <metadata type="slic3r.\1">\2<\/metadata>/'\
  >> volumes.tmp
  # Add volume closing tag:
  echo "  </volume>" >> volumes.tmp
  # Get current number of vertices in tmp file (used for next volumes offset):
  _num_of_vertices=$(grep '<vertex>' vertices.tmp | wc -l | sed 's/ //g')
  # Make modifiers:
  for mod in $(grep '//@set_modifier(' ${scad} | sed 's/.*(\(.*\))/\1/'); do
    # Clean parameters for next modifier
    ini_file=""
    verbose_print "Rendering modifier [${mod}]"
    # Create temporary scad file for rendering of modifier:
    echo "use <${scad}>;" > tmp.scad
    echo "${mod}();" >> tmp.scad
    # Render temporary modifier file:
    openscad -o tmp_mod.amf tmp.scad
    # Get modifier ini file:
    ini_file=$(grep "set_slicing_config.*, *${mod})" ${scad} |\
               sed 's/.*(\([^,]*\).*/\1/')
    # Save parameters from base file to local_parameters.tmp:
    grep "set_modifier_parameter(${mod}," ${scad} |\
    sed "s/.*(${mod}, *\([^,]*\), \(.*\))/\1 = \2/" > local_parameters.tmp
    # If ini file exists in given path, get parameters from file:
    if test -e "${ini_file}"; then
      verbose_print "Ini file for modifier [${mod}] is [${ini_file}]."
      cat ${ini_file} > ini_parameters.tmp
      # Merge parameters to file parameters.tmp (skip local parameters present in ini):
      cat local_parameters.tmp | sed 's/\([^ ]*\).*/-e "^\1 "/' | tr -s '\n' ' ' |\
      xargs grep -v ini_parameters.tmp > parameters.tmp
    else
      verbose_print "Ini file for modifier [${mod}] not found."
      # Delete any old parameters.tmp
      rm -f parameters.tmp
    fi
    cat local_parameters.tmp >> parameters.tmp
    # Write all vertices from current modifier amf to temporary vertices file:
    sed -n '/<vertex>/,/<\/vertex>/p' tmp_mod.amf >> vertices.tmp
    # Add volume opening tag:
    echo "  <volume>" >> volumes.tmp
    # Write volume from current file:
    sed -n '/<triangle>/,/<\/triangle>/p' tmp_mod.amf |\
    # With renumbered indexes of verties:
    perl -pe "s/>(\d+)</sprintf(\">%d<\", \$1+${_num_of_vertices})/e"\
    >> volumes.tmp
    # Add modifier=1 parameter to all modifier volumes:
    echo '  <metadata type="slic3r.modifier">1</metadata>' >> volumes.tmp
    # Wrap parameters in tags and add them to volumes.tmp:
    cat parameters.tmp |\
    sed 's/^\([^ ]*\) *= *\(.*\)/  <metadata type="slic3r.\1">\2<\/metadata>/'\
    >> volumes.tmp
    # Add volume closing tag:
    echo "  </volume>" >> volumes.tmp
    # Get current number of vertices in tmp file (used for next volumes offset):
    _num_of_vertices=$(grep '<vertex>' vertices.tmp | wc -l | sed 's/ //g')
    # Remove temoporary modifier file:
    rm -f tmp_mod.amf
  done

  # Add vertices closing tag:
  echo "  </vertices>" >> vertices.tmp

  # Merge temporary files into one AMF file:
  sed -n '/xml/,/<mesh>/p' ${amf} | sed 's/\r//' > result.amf
  cat vertices.tmp volumes.tmp | sed 's/\r//' >> result.amf
  sed -n '/<\/mesh>/,//p' ${amf} | sed 's/\r//' >> result.amf

  # Move merged AMF to amf folder with _mod suffix:
  if [ -n "${out}" ]; then
    mv result.amf ${out}
  else
    mv result.amf $(echo ${amf} | sed 's/\.amf$/_mod.amf/')
  fi

  # Clean-up tmp files
  rm -f vertices.tmp volumes.tmp ini_parameters.tmp local_parameters.tmp\
        parameters.tmp tmp.scad 2>/dev/null
}

merge_modifiers $*
