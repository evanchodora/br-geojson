## Brazil GeoJSON Data

Creates GeoJSON map data for Brazilian states and the entire country using the data published by the [IBGE (Instituto Brasileiro de Geografia e Estatistica)](http://www.ibge.gov.br/).
This code currently uses the most recent data published March 25, 2019 and represents the 2018 dataset. You can read more about the dataset [here](https://bit.ly/2MpSK22).

### Dependencies

The script uses `ogr2ogr` to convert the files from Shapefiles to GeoJSON. It is a part of the [Geospatial Data Abstraction Library (GDAL)](http://www.gdal.org/). Check their site for downloads compatible with your system. It is also included in the Homebrew (Mac) and apt (Debian/Ubuntu) package managers as well.

### Outputs

Running `get_geojson.sh` will create a `data` directory with 4 files for each state (and optionally the entire country):
- `UF_municipalities.json`: GeoJSON file for the IBGE municipalities (municipios) within a particular Unidade Federativa (UF)
- `UF_microregions.json`: GeoJSON file for the IBGE microregions (microrregiões) within a UF
- `UF_mesoregions.json`: GeoJSON file for the IBGE mesoregions (mesorregiões) within a UF
- `UF_state.json`: GeoJSON file for the geometry of each UF

#### Options

- `-c` or `--clean`: will delete the tmp directory created to store all the original Shapefiles upon completion
- `-b` or `--brasil`: will optionally download every municipality, mesoregion, etc. for the whole country as one file (large files)
