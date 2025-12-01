#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-d] -r -m mode_value -p product_value tag_name

Script to cleanup directory for release or debug build:
- Remove git management files / directories
- Remove unsupported platform files
- Remove unused libraries
- For release, remove debug code (APP_HAS_DEBUG / APP_HAS_PRINTF / APP_HAS_LINAA
- To include LINAA, use mode release_linaa or debug_linaa

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-d, --doc       Keep doc(s) construction folders
-r, --run       Run script (mandatory)
-m, --mode      Selected mode (mandatory)
-p, --product   Product family (mandatory)
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
  msg "${GREEN}End -> cleanup${NOFORMAT}"
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''
  cleanDoc=1

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -r | --run) runFlag=1 ;; # example flag
    -d | --doc) cleanDoc=0 ;;
    -m | --mode)
      mode="${2-}"
      shift
      ;;
    -p | --product)
      product="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${runFlag-}" ]] && die "Missing required parameter: run (use -h to show usage)"
  [[ -z "${mode-}" ]] && die "Missing required parameter: mode (use -h to show usage)"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments (use -h to show usage)"

  return 0
}

setup_colors
parse_params "$@"

# script logic here

msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${runFlag}"
msg "- mode: ${mode}"
msg "- doc: ${cleanDoc}"
msg "- product: ${product}"
msg "- arguments: ${args[*]-}"
msg " "

# Remove GIT info
msg " "
msg "${YELLOW}Remove GIT info.${NOFORMAT}"
msg " "

find . -type f | grep -i "\.git" | xargs rm
find . -type d | grep -i "\.git" | xargs rm -rf


# Clean up code/camcu_platform folder
msg " "
msg "${YELLOW}Cleaning platform include folder:${NOFORMAT}"
msg " "

cd ./code/camcu_platform
# Clean up bin folder
cd ./bin
rm melibu_nodegen.exe
cd ..
# Clean up libsrc folder
msg "${YELLOW}Include directory:${NOFORMAT}"
cd ./include
for folder in *;
do
  folder_name=${folder##*/}
  if [ -d $folder ]
  then
    if ([ $product == "81160" ] && [[ $folder_name == *"81160"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81330"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81332"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81334"* ]])
    then
      msg "${GREEN}Leaving $folder ${NOFORMAT}"
    elif ([[ $product == *"8134"* ]] && [[ $folder_name == *"81340"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $folder_name == *"81344"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $folder_name == *"81346"* ]])
    then
      msg "${GREEN}Removing UDS ${NOFORMAT}"
      cd $folder
      ls | grep -P ".*(uds).*" | xargs -d"\n" rm
      cd ..
    else
      msg "${RED}Removing $folder ${NOFORMAT}"
      rm -r $folder
    fi
  fi
done;
cd ..
msg "${YELLOW}Lib directory:${NOFORMAT}"
cd ./lib
for folder in *;
do
  folder_name=${folder##*/}
  if [ -d $folder ]
  then
    if ([ $product == "81160" ] && [[ $folder_name == *"81160"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81330"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81332"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81334"* ]]) || \
       [ $folder_name == "ldscripts" ]
    then
      msg "${GREEN}Leaving $folder ${NOFORMAT}"
    elif ([[ $product == *"8134"* ]] && [[ $folder_name == *"81340"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $folder_name == *"81344"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $folder_name == *"81346"* ]])
    then
      msg "${GREEN}Removing UDS ${NOFORMAT}"
      msg "${GREEN}Removing UDS ${NOFORMAT}"
      cd $folder
      ls | grep -P ".*(uds).*" | xargs -d"\n" rm
      cd ..
    else
      msg "${RED}Removing $folder ${NOFORMAT}" 
      rm -r $folder
    fi
  fi
done;
msg "${YELLOW}Ldscripts directory:${NOFORMAT}"
cd ./ldscripts
for file in *;
do
  file_name=${file##*/}
  if [ -e $file ]
  then
    if ([ $product == "81160" ] && [[ $file_name == *"81160"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $file_name == *"81330"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $file_name == *"81332"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $file_name == *"81334"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $file_name == *"81340"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $file_name == *"81344"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $file_name == *"81346"* ]])
    then
      msg "${GREEN}Leaving $file ${NOFORMAT}"
    else
      msg "${RED}Removing $file ${NOFORMAT}"
      rm -r $file
    fi
  fi
done;
cd ..
cd ..
msg "${YELLOW}Src directory:${NOFORMAT}"
cd ./src
for folder in *;
do
  folder_name=${folder##*/}
  if [ -d $folder ]
  then
    if [ $folder_name == "app_descriptor" ] || \
       [ $folder_name == "fw_sys_services" ] || \
       [ $folder_name == "mls_api" ] || \
       [ $folder_name == "mls_device_id" ] || \
       [ $folder_name == "mls_loader" ] || \
       [ $folder_name == "patch_colin" ] || \
       [ $folder_name == "patch_rom" ] || \
       [ $folder_name == "std_lin_api" ] || \
       [ $folder_name == "user_startup" ] || \
       ([ $folder_name == "lin_aa" ] && ([ ${mode} == release_linaa ] || [ ${mode} == debug_linaa ]))
    then
      msg "${GREEN}Leaving $folder ${NOFORMAT}"
    else
      msg "${RED}Removing $folder ${NOFORMAT}"
      rm -r $folder
    fi
  fi
done;
cd ..
msg "${YELLOW}Src/user_startup directory:${NOFORMAT}"
cd ./src/user_startup
for folder in *;
do
  folder_name=${folder##*/}
  if [ -d $folder ]
  then
    if ([ $product == "81160" ] && [[ $folder_name == *"81160"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81330"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81332"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $folder_name == *"81334"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $folder_name == *"81340"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $folder_name == *"81344"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $folder_name == *"81346"* ]])
    then
      msg "${GREEN}Leaving $folder ${NOFORMAT}"
    else
      msg "${RED}Removing $folder ${NOFORMAT}"
      rm -r $folder
    fi
  fi
done;
cd ../..
msg "${YELLOW}Config directory:${NOFORMAT}"
cd ./config
for file in *;
do
  file_name=${file##*/}
  if [ -e $file ]
  then
    if ([ $product == "81160" ] && [[ $file_name == *"81160"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $file_name == *"81330"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $file_name == *"81332"* ]]) || \
       ([[ $product == *"8133"* ]] && [[ $file_name == *"81334"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $file_name == *"81340"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $file_name == *"81344"* ]]) || \
       ([[ $product == *"8134"* ]] && [[ $file_name == *"81346"* ]]) || \
       [ $file_name == "Config.mk" ] || \
       [ $file_name == "Rules.mk" ]
    then
      msg "${GREEN}Leaving $file ${NOFORMAT}"
    else
      msg "${RED}Removing $file ${NOFORMAT}" 
      rm -r $file
    fi
  fi
done;
cd ../../..

# Clean up code/doc folder
if [ $cleanDoc == 1 ]
then
    # Clean up code/doc folder
    msg "${YELLOW}Clean up code/doc folder:${NOFORMAT}"
    rm -r ./code/doc/doxygen
    rm ./code/doc/Makefile
fi

# Clean up code/libraries folder
msg " "
msg "${YELLOW}Keep only used libraries folders:${NOFORMAT}"
msg " "

cd ./code/libraries

for folder in *;
do
  folder_name=${folder##*/}
  if [ -d $folder ]
  then
    if ([ $product == "81160" ] && [ $folder_name == "adc_conv_81160" ]) || \
       ([[ $product == *"8133"* ]] && [ $folder_name == "adc_conv_8133x" ]) || \
       ([[ $product == *"8134"* ]] && [ $folder_name == "adc_conv_8134x" ]) || \
       [ $folder_name == "filter_ab" ] || \
       [ $folder_name == "filter_avg" ] || \
       [ $folder_name == "filter_lpf" ] || \
       [ $folder_name == "filter_pid" ] || \
       [ $folder_name == "mcp2515" ] || \
       [ $folder_name == "mlx90381" ] || \
       [ $folder_name == "mlx90395" ] || \
       [ $folder_name == "mlx92251" ] || \
       [ $folder_name == "motor3ph_align" ] || \
       [ $folder_name == "motor3ph_bemf" ] || \
       [ $folder_name == "motor3ph_foc" ] || \
       [ $folder_name == "motor3ph_pwm" ] || \
       [ $folder_name == "motor3ph_srp" ] || \
       [ $folder_name == "motor3ph_startv90p" ] || \
       [ $folder_name == "motor3ph_stepper" ] || \
       [ $folder_name == "motor3ph_windmill" ] || \
       [ $folder_name == "motor4ph_pwm" ] || \
       [ $folder_name == "motor4ph_stepper" ] || \
       [ $folder_name == "pwm_capture" ] || \
       [ $folder_name == "pwm_communication" ] || \
       [ $folder_name == "pwm_diagnostic" ] || \
       [ $folder_name == "svm_table" ] || \
       [ $folder_name == "swtimer" ] || \
       [ $folder_name == "uart_plot" ] || \
       [ $folder_name == "uart_printf" ] || \
       [ $folder_name == "unirom" ] || \
       ([ $cleanDoc == 0 ] && [ $folder_name == "_doc" ])
    then
      msg "${GREEN}Leaving $folder ${NOFORMAT}"
      if [ -d $folder/products ]
      then
        cd ./$folder/products
        for product_folder in *;
        do
          product_folder_name=${product_folder##*/}
          if [ -d $product_folder ]
          then
            if ([ $product == "81160" ] && [ $product_folder_name == "81160" ]) || \
               ([[ $product == *"8133"* ]] && [ $product_folder_name == "81330" ]) || \
               ([[ $product == *"8133"* ]] && [ $product_folder_name == "81332" ]) || \
               ([[ $product == *"8133"* ]] && [ $product_folder_name == "81334" ]) || \
               ([[ $product == *"8134"* ]] && [ $product_folder_name == "81340" ]) || \
               ([[ $product == *"8134"* ]] && [ $product_folder_name == "81344" ]) || \
               ([[ $product == *"8134"* ]] && [ $product_folder_name == "81346" ])
            then
              msg "${GREEN}Leaving $product_folder ${NOFORMAT}"
            else
              msg "${RED}Removing $product_folder ${NOFORMAT}"
              rm -r $product_folder
            fi
          fi
        done;
        cd ../..
      fi
      if ([ $cleanDoc == 1 ] && [ -d $folder/doc ])
      then
        rm -r $folder/doc
      fi
      if [ -d $folder/unit_test ]
      then
        rm -r $folder/unit_test
      fi
    else
      msg "${RED}Removing $folder ${NOFORMAT}"
      rm -r $folder
    fi
  fi
done;
cd ../..

folder="./release/libraries"
if [ -d "$folder" ]; then
  cd $folder
  for file in *;
  do
    file_name=${file##*/}
    if [ -e $file ]
    then
      if ([ $product == "81160" ] && [ $file_name == "adc_conv_81160.pdf" ]) || \
         ([[ $product == *"8133"* ]] && [ $file_name == "adc_conv_8133x.pdf" ]) || \
         ([[ $product == *"8134"* ]] && [ $file_name == "adc_conv_8134x.pdf" ]) || \
         [ $file_name == "filter_ab.pdf" ] || \
         [ $file_name == "filter_avg.pdf" ] || \
         [ $file_name == "filter_lpf.pdf" ] || \
         [ $file_name == "filter_pid.pdf" ] || \
         [ $file_name == "mcp2515.pdf" ] || \
         [ $file_name == "mlx90381.pdf" ] || \
         [ $file_name == "mlx90395.pdf" ] || \
         [ $file_name == "mlx92251.pdf" ] || \
         [ $file_name == "motor3ph_align.pdf" ] || \
         [ $file_name == "motor3ph_bemf.pdf" ] || \
         [ $file_name == "motor3ph_foc.pdf" ] || \
         [ $file_name == "motor3ph_pwm.pdf" ] || \
         [ $file_name == "motor3ph_srp.pdf" ] || \
         [ $file_name == "motor3ph_startv90p.pdf" ] || \
         [ $file_name == "motor3ph_stepper.pdf" ] || \
         [ $file_name == "motor3ph_windmill.pdf" ] || \
         [ $file_name == "motor4ph_pwm.pdf" ] || \
         [ $file_name == "motor4ph_stepper.pdf" ] || \
         [ $file_name == "pwm_capture.pdf" ] || \
         [ $file_name == "pwm_communication.pdf" ] || \
         [ $file_name == "pwm_diagnostic.pdf" ] || \
         [ $file_name == "svm_table.pdf" ] || \
         [ $file_name == "swtimer.pdf" ] || \
         [ $file_name == "uart_plot.pdf" ] || \
         [ $file_name == "uart_printf.pdf" ] || \
         [ $file_name == "unirom.pdf" ]
      then
        msg "${GREEN}Leaving $file ${NOFORMAT}"
      else
        msg "${RED}Removing $file ${NOFORMAT}"
        rm -r $file
      fi
    fi
  done;
  cd ../..
fi

# Clean up code/src folder
if [ ${mode} = release_linaa ]
then
  def_remove="-UAPP_HAS_DEBUG"
  def_remove+=" -UAPP_HAS_PLOT"
  def_remove+=" -UAPP_HAS_PRINTF"
  def_remove+=" -UAPP_HAS_STR"

elif [ ${mode} = debug_linaa ]
then
  def_remove="-UAPP_HAS_STR"

elif [ ${mode} = release ]
then
  def_remove="-UAPP_HAS_DEBUG"
  def_remove+=" -UAPP_HAS_PLOT"
  def_remove+=" -UAPP_HAS_PRINTF"
  def_remove+=" -UAPP_HAS_STR"
  def_remove+=" -UAPP_HAS_LINAA"

else # debug mode
  def_remove="-UAPP_HAS_STR"
  def_remove+=" -UAPP_HAS_LINAA"
fi

cd ./code/src
msg " "
msg "${YELLOW}Cleaning application src folder:${NOFORMAT}"
msg " "

# find all *.c and *.h files recursively, and run unifdef with def_remove options
find . -regex '.*/.*\.\(c\|h\)$' -exec unifdef -x2 -m $def_remove '{}' \;
cd ../..

# cleanup fast_math
folder="./code/src/fast_math"
if [ -d "$folder" ]; then
  cd $folder
  rm *.*
  for folder in *;
  do
    folder_name=${folder##*/}
    if [ -d $folder ]
    then
      if [ $folder_name != "inc" ] && \
         [ $folder_name != "src" ]
      then
        msg "${RED}Removing $folder ${NOFORMAT}"
        rm -r $folder
      else
        msg "${GREEN}Leaving $folder ${NOFORMAT}"
      fi
    fi
  done;
  cd ../../..
fi
rm -f code/src/str_inertia_test.c
rm -f code/src/str_inertia_test.h
rm -f code/src/str_bemf_test.c
rm -f code/src/str_bemf_test.h

# Clean up main folder
msg " "
msg "${YELLOW}Keep only code, verification and release top level directories:${NOFORMAT}"
msg " "

for folder in *;
do
  folder_name=${folder##*/}
  if [ -d $folder ]
  then
    if [ $folder_name != "code" ] && \
       [ $folder_name != "documents" ] && \
       [ $folder_name != "release" ] && \
       [ $folder_name != "verification" ]
    then
      msg "${RED}Removing $folder ${NOFORMAT}" 
      rm -r $folder
    else
      msg "${GREEN}Leaving $folder ${NOFORMAT}" 
    fi
  fi
done;

sync

msg " "
msg "${RED}Remove Cleanup script.${NOFORMAT}"
msg " "
rm cleanup.sh
