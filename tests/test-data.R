# Regression checks on the generated data for the Sea Level indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 1 dataset(s)", length(meta$datasets) == 1L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")
# Pinned to EPA's June 2024 web update. A legitimate data update fails here and
# says exactly what changed; re-pin after checking the new values.
f2 <- rd("sea_level_relative_change_by_station.csv")
row_is <- function(df, i, expected) identical(unname(unlist(df[i, ])), expected)
v <- as.numeric(f2$value)

check("fig 2: 72 stations", nrow(f2) == 72L)
check("fig 2: columns are station, state, lat, long, value",
      identical(names(f2), c("station", "state", "lat", "long", "value")))
check("fig 2: 26 states/territories", length(unique(f2$state)) == 26L)
check("fig 2: first row is Nawiliwili, Hawaii",
      row_is(f2, 1L, c("Nawiliwili", "Hawaii", "21.9544", "-159.356", "4.439763775")))
check("fig 2: last row is Magueyes Island, Puerto Rico",
      row_is(f2, nrow(f2), c("Magueyes Island", "Puerto Rico", "17.9701", "-67.0464", "4.985433066")))
check("fig 2: minimum is Skagway, Alaska, -44.74488184",
      identical(f2$station[which.min(v)], "Skagway") && identical(f2$value[which.min(v)], "-44.74488184"))
check("fig 2: maximum is Grand Isle, Louisiana, 22.71968502",
      identical(f2$station[which.max(v)], "Grand Isle") && identical(f2$value[which.max(v)], "22.71968502"))
check("fig 2: every value parses as a number", !anyNA(v))

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
