### Notes
Please read the notes inside the FME Workbench to set it up.
This directory contains:
* A directory (Campus utilities pre-processed) with 9 shapefiles that result from cleaning and extracting the Gas Low Pressure and District Hating Networks from '01) Raw Data'. Main input for the FME workbench.
* A directory with a TIN-based digital terrain model (DTM) of the campus. Input for the FME workbench.
* The FME workbench to read the 9 shapefiles and the DTM and insert them into the database. The O&M database must be set up before running the workbench, as it writes to it.
