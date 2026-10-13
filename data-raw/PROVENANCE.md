# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-sea-level/index.html>  \
  sha256 `6ce5aadd6e8e1a5a0a5af11107b0c7cc867e34f1168556ac6f532cb8bc090411`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2024-06/sea-level_documentation.pdf>

## Figure data

- `sea-level_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-10/sea-level_fig-1.csv>  \
  sha256 `3a075b69dc33734707c0e7bc2ee32e4ad49a8a906678912a8d23f0bb32d2a3be`  \
  encoding UTF-8, 144 data rows, columns: `Year`, `CSIRO - Adjusted sea level (inches)`, `CSIRO - Lower error bound (inches)`, `CSIRO - Upper error bound (inches)`, `NOAA - Adjusted sea level (inches)`  \
  title: Figure 1. Global Average Absolute Sea Level Change, 1880-2023  \
  data source: CSIRO, 2017; NOAA, 2024; web update: June 2024; units: inches  \
  EPA's page draws this figure as a JavaScript chart with no download link; the
  path above is the download argument its `createChart("container1", ...)` call
  passes, added by hand after the build script missed it.

- `sea-level_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/sea-level_fig-2.csv>  \
  sha256 `2615508858240a411ccbde5d5b4dda6785b28615766463d8c80ca658a4a281e8`  \
  encoding UTF-8, 72 data rows, columns: `Lat`, `Long`, `Station Name`, `State`, `Relative sea level change`  \
  title: Figure 2. Relative Sea Level Change Along U.S. Coasts, 1960-2023  \
  data source: NOAA, 2024; web update: June 2024; units: inches
