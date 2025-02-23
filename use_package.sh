#!/bin/bash

# Define functions

help() {
	echo "$(basename "$0") [-h|--help] [-l|--list] [-p|--path] [regex] Program to control through a list of different packages bin folder with different versions, so that it can be added to the \$PATH variable, based on a config file choosing the default package to be used, and then added through .profile to add it to the \$PATH variable"
	echo ""
	echo "Where:"	
	echo "    -h|--help : Help manual"
	echo "    -l|--list : Outputs all the bin folders for the packages to be used as default"
	echo "    -p|--path : Outputs all the bin folders for the packages to be used as default in \$PATH format"
	echo "    regex     : Optimize the selection for less results, regex matching, can be null, the result will be added to the config file, if for the same package with different version was found, will be replaced"
}

# Define variables

CHECK_PATH="$HOME/packages/"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_FILE="$SCRIPT_DIR/.default.cfg"
POSITIONAL_ARGS=()

# Parse arguments

while [[ $# -gt 0 ]]
do
	case $1 in
	-h|--help)
		help
		exit 0
		;;
	-l|--list)
		cat $CONFIG_FILE
		shift
		exit 0
		;;
	-p|--path)
		cat $CONFIG_FILE | paste -sd ":" -
		shift
		exit 0
		;;
	-*|--*)
		echo "Unknown option $1"
		help
		exit 1
		;;
	*)
		POSITIONAL_ARGS+=("$1")
		shift
		;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Checkings

# Execution

cd $CHECK_PATH

select package in `find . -mindepth 2 -maxdepth 2 -type d -iname "*$1*"`
do
	if [[ $REPLY == 0 ]];
	then
		break	
	else
		if [ -d "$package" ];
		then
			type_package=`echo $package | cut -d "/" -f2`
			bin_path=`find $package -iname "bin" -type d | awk '(NR == 1 || length < length(shortest)) { shortest = $0 } END { print shortest }'`
			if [ -d $bin_path ];
			then
				cd $bin_path

				sed -i "\|${CHECK_PATH}${type_package}|d" $CONFIG_FILE
				echo "$PWD" >> $CONFIG_FILE

				echo ""
				echo "New Config file:"
				echo ""
				cat $CONFIG_FILE
			fi	
			
			break
		else 
			echo "The option selected does not exist (0 to exit)"
		fi
	fi
done

exit 0

