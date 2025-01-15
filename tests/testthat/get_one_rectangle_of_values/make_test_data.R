metadata_file <- testthat::test_path("get_one_rectangle_of_values", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

long_fields_and_responses <- dplyr::bind_rows(
  get_long_categorical_field_responses(metadata),
  get_long_text_fields(metadata)
)

long_fields_and_responses |>
  saveRDS(testthat::test_path("get_one_rectangle_of_values", "input.rds"))
