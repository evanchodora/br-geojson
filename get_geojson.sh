#!/bin/bash

# Bash script to download and convert geographic data from IBGE to GeoJSON data for the states, mesoregions, microregions, and municipalities of Brazil
# Evan Chodora, 2019

# Check for dependencies
if ! [ -x "$(command -v ogr2ogr)" ]; then
	echo 'Error: gdal is not installed'
	exit 1
fi

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

extract () {
	extract_dir=tmp/$filename
	mkdir -p $extract_dir
	unzip -d $extract_dir tmp/$filename.zip
	rm tmp/$filename.zip
	mv $extract_dir/*.shp $extract_dir/map.shp
	mv $extract_dir/*.shx $extract_dir/map.shx
	mv $extract_dir/*.dbf $extract_dir/map.dbf
	mv $extract_dir/*.prj $extract_dir/map.prj
	mv $extract_dir/*.cpg $extract_dir/map.cpg
}

convert () {
	geo_file=tmp/$filename/$filename.json
	ogr2ogr -f GeoJSON $geo_file $extract_dir/map.shp
	iconv -f ISO-8859-1 -t UTF-8 $geo_file > $geo_file.UTF8
	mv $geo_file.UTF8 $geo_file
	cp $geo_file data
}

# Make a temp working directory and a data directory
mkdir -p tmp
mkdir -p data

# Loop through each of the states in the array
for state in "${states[@]}"
do
	# Loop over each of the data types
	for type in "${!types[@]}"
	do
		filename=${state}_${types[$type]}
		remote_file=${state}_${ext_pt[$type]}
		curl $base_url/UFs/${state^^}/$remote_file.zip -o tmp/$filename.download
		mv tmp/$filename.download tmp/$filename.zip
		extract
		convert
	done
done

# Download the files for all of Brazil
for type in "${!types[@]}"
do
	filename=br_${types[$type]}
	remote_file=br_${ext_pt[$type]}
	curl $base_url/Brasil/BR/$remote_file.zip -o tmp/$filename.download
	mv tmp/$filename.download tmp/$filename.zip
	extract
	convert
done

# Clear up temp directory
rm -r tmp
