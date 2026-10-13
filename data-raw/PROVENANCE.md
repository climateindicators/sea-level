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

- **Figure 1** has no data download on EPA's page, because EPA renders it as a JavaScript chart. The narrative carries the caption; there is nothing to build.

- `sea-level_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/sea-level_fig-2.csv>  \
  sha256 `2615508858240a411ccbde5d5b4dda6785b28615766463d8c80ca658a4a281e8`  \
  encoding UTF-8, 72 data rows, columns: `Lat`, `Long`, `Station Name`, `State`, `Relative sea level change`  \
  title: Figure 2. Relative Sea Level Change Along U.S. Coasts, 1960-2023  \
  data source: NOAA, 2024; web update: June 2024; units: inches
