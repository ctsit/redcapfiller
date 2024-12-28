metadata_file <- testthat::test_path("get_long_categorical_field_responses", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

long_categorical_field_responses <- get_long_categorical_field_responses(metadata)
long_categorical_field_responses |>
  saveRDS(testthat::test_path("get_long_categorical_field_response_values", "input.rds"))
