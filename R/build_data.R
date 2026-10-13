# Build tidy long-format data for the Sea Level indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# Generated as a stub by the build-indicator skill. Each figure below has a
# `todo_reshape()` call standing where its reshape belongs. Replace that line,
# then delete the todo_reshape() helper once no call to it remains.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Sea Level",
  slug                    = "sea-level",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-sea-level/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2024-06/sea-level_documentation.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Global Average Absolute Sea Level Change, 1880-2023 ----

f1_path <- file.path(raw_dir, "sea-level_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

assert_headers(
  f1_raw,
  id_cols          = "Year",
  expected_headers = c(
    "CSIRO - Adjusted sea level (inches)",
    "CSIRO - Lower error bound (inches)",
    "CSIRO - Upper error bound (inches)",
    "NOAA - Adjusted sea level (inches)"
  ),
  what             = "sea-level_fig-1.csv"
)

# Two series on one year axis: CSIRO's tide gauge reconstruction (1880-2013),
# which carries the error band, and NOAA's satellite record (1993-2023), which
# does not. Years a series does not cover are blank in the source and dropped.
f1_csiro <- f1_raw |>
  transmute(
    year   = Year,
    series = "CSIRO",
    value  = `CSIRO - Adjusted sea level (inches)`,
    lower  = `CSIRO - Lower error bound (inches)`,
    upper  = `CSIRO - Upper error bound (inches)`
  ) |>
  filter(value != "")

# The band must exist exactly where the CSIRO value does.
stopifnot(all(f1_csiro$lower != "" & f1_csiro$upper != ""))
stopifnot(sum(f1_raw$`CSIRO - Lower error bound (inches)` != "") == nrow(f1_csiro))

f1_noaa <- f1_raw |>
  transmute(
    year   = Year,
    series = "NOAA",
    value  = `NOAA - Adjusted sea level (inches)`,
    lower  = "",
    upper  = ""
  ) |>
  filter(value != "")

f1 <- bind_rows(f1_csiro, f1_noaa)

assert_conservation(
  f1_raw,
  c("CSIRO - Adjusted sea level (inches)", "NOAA - Adjusted sea level (inches)"),
  nrow(f1), "sea-level_fig-1.csv"
)

write_csv_stable(f1, file.path(out_dir, "sea_level_global_absolute_change.csv"))

# ---- Figure 2: Relative Sea Level Change Along U.S. Coasts, 1960-2023 ----

f2_path <- file.path(raw_dir, "sea-level_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f2_raw,
  id_cols          = c("Lat", "Long", "Station Name", "State"),
  expected_headers = "Relative sea level change",
  what             = "sea-level_fig-2.csv"
)

# One row per tide gauge station already, with a single series: the reshape is a
# rename. Values stay character so the source's 10 significant digits survive.
f2 <- f2_raw |>
  transmute(
    station = `Station Name`,
    state   = State,
    lat     = Lat,
    long    = Long,
    value   = `Relative sea level change`
  )

assert_conservation(f2_raw, "Relative sea level change", nrow(f2), "sea-level_fig-2.csv")

write_csv_stable(f2, file.path(out_dir, "sea_level_relative_change_by_station.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

f1_columns <- list(
  col("year",   "integer", "Calendar year."),
  col("series", "string",  "CSIRO (tide gauge reconstruction adjusted with satellite data, 1880-2013) or NOAA (satellite measurements, 1993-2023)."),
  col("value",  "number",  "Cumulative change in global average absolute sea level since 1880, inches."),
  col("lower",  "number",  "Lower bound of the likely range, inches. CSIRO only; blank for NOAA."),
  col("upper",  "number",  "Upper bound of the likely range, inches. CSIRO only; blank for NOAA.")
)
stopifnot(identical(vapply(f1_columns, `[[`, "", "name"), names(f1)))

f2_columns <- list(
  col("station", "string", "Tide gauge station name, as EPA labels it."),
  col("state",   "string", "U.S. state or territory the station is in."),
  col("lat",     "number", "Station latitude, decimal degrees."),
  col("long",    "number", "Station longitude, decimal degrees (negative = west)."),
  col("value",   "number", "Relative sea level change at the station, 1960-2023, inches. Negative means land rose faster than the sea.")
)
stopifnot(identical(vapply(f2_columns, `[[`, "", "name"), names(f2)))

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "sea_level_global_absolute_change.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "sea-level_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "UTF-8",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = f1_columns
    ),
    list(
      file            = "sea_level_relative_change_by_station.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "sea-level_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "UTF-8",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = f2_columns
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
