#!/bin/bash

# Bash script to download and convert geographic data from IBGE to GeoJSON data
#for the states, mesoregions, microregions, and municipalities of Brazil
#
# Evan Chodora, 2019
# https://github.com/evanchodora/br-geojson

# Check for dependencies
if ! [ -x "$(command -v ogr2ogr)" ]; then
	echo 'Error: gdal (https://gdal.org) is not installed'
	exit 1
fi

# Script usage help line
usage() { echo "Usage: $0 [-h | --help] [-c | --clean] [-b | --brasil]" 1>&2; }

# Set script options from the command line arguments
# clean [-c | --clean]: clean the tmp directory after script completion
# brasil [-b | --brasil]: download the data for the entire country as a single file
clean=0
brasil=0
while getopts ":hcb" o; do
	case "${o}" in
		h)
			usage
			exit 0
			;;
		c)
			clean=1
			;;
		b)
			brasil=1
			;;
		*)
			usage
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

# Base URL for downloading data
base_url="ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2018"

# Array of state abbreviations
states=(ac al am ap ba ce df es go ma
        mg ms mt pa pb pe pi pr rj rn
        ro rr rs sc se sp to)

# Array of the 4 types of geo data per state
types=(municipalities
       microregions
       mesoregions
       state)
ext_pt=(municipios
        microrregioes
        mesorregioes
        unidades_da_federacao)

# Function to extract the data from the compressed IBGE files
extract () {
	extract_dir=tmp/${state}/$filename
	mkdir -p $extract_dir
	unzip -d $extract_dir tmp/$filename.zip > /dev/null
	rm tmp/$filename.zip
	mv $extract_dir/*.shp $extract_dir/map.shp
	mv $extract_dir/*.shx $extract_dir/map.shx
	mv $extract_dir/*.dbf $extract_dir/map.dbf
	mv $extract_dir/*.prj $extract_dir/map.prj
	mv $extract_dir/*.cpg $extract_dir/map.cpg
}

# Function to convert the Shapefiles to GeoJSON and move to data directory
convert () {
	geo_file=tmp/${state}/$filename/$filename.json
	ogr2ogr -f GeoJSON $geo_file $extract_dir/map.shp
	iconv -f ISO-8859-1 -t UTF-8 $geo_file > $geo_file.UTF8
	mv $geo_file.UTF8 $geo_file
	cp $geo_file data/${state}
}

# Make a temp working directory and a data directory
mkdir -p tmp
mkdir -p data

echo "Beginning download script"

# Loop through each of the states in the array
for state in "${states[@]}"
do
	mkdir -p tmp/${state}
	mkdir -p data/${state}
	# Loop over each of the data types
	for type in "${!types[@]}"
	do
		echo "Processing ${state^^} - ${types[$type]}..."
		filename=${state}_${types[$type]}
		remote_file=${state}_${ext_pt[$type]}
		curl -# $base_url/UFs/${state^^}/$remote_file.zip -o tmp/$filename.dl
		mv tmp/$filename.dl tmp/$filename.zip
		extract
		convert
	done
done

# Download the files for all of Brazil if flag is set
if [ $brasil = 1 ]; then
	state=br
	mkdir -p tmp/${state}
	mkdir -p data/${state}
	for type in "${!types[@]}"
	do
		echo "Processing ${state^^} - ${types[$type]}..."
		filename=${state}_${types[$type]}
		remote_file=${state}_${ext_pt[$type]}
		curl -# $base_url/Brasil/${state^^}/$remote_file.zip -o tmp/$filename.dl
		mv tmp/$filename.dl tmp/$filename.zip
		extract
		convert
	done
fi

# Clear up temp directory if clean flag is set
if [ $clean = 1 ]; then
	rm -r tmp
fi

echo "Complete"
