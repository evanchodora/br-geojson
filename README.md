## Brazil GeoJSON Data

Creates GeoJSON map data for Brazilian states and the entire country using the data published by the [IBGE (Instituto Brasileiro de Geografia e Estatistica)](http://www.ibge.gov.br/).
This code currently uses the most recent data published March 25, 2019 and represents the 2018 dataset. You can read more about the dataset [here](ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2018/Leia_me_Malha_Digital_2018.pdf).

### Dependencies

The script uses `ogr2ogr` to convert the files from Shapefiles to GeoJSON. It is a part of the [Geospatial Data Abstraction Library (GDAL)](http://www.gdal.org/). Check their site for downloads compatible with your system. It is also included in the Homebrew (Mac) and apt (Debian/Ubuntu) package managers as well.

### Outputs

Running `get_geojson.sh` will create a `data` directory with 3 files for each state + the entire country:
- `UF_municipalities.json`: GeoJSON file for the IBGE municipalities (municipios) within a particular Unidade Federativa (UF)
- `UF_microregions.json`: GeoJSON file for the IBGE microregions (microrregiões) within a UF
- `UF_mesoregions.json`: GeoJSON file for the IBGE mesoregions (mesorregiões) within a UF
