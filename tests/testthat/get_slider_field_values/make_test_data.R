metadata_file <- testthat::test_path("get_slider_field_values", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

slider_fields <- get_slider_fields(metadata)
slider_fields |>
  saveRDS(testthat::test_path("get_slider_field_values", "input.rds"))
