metadata_file <- testthat::test_path("get_long_slider_field_values", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

long_slider_fields <- get_long_slider_fields(metadata)
long_slider_fields |>
  saveRDS(testthat::test_path("get_long_slider_field_values", "input.rds"))
