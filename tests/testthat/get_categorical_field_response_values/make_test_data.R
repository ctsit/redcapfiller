metadata_file <- testthat::test_path("get_categorical_field_responses", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

categorical_field_responses <- get_categorical_field_responses(metadata)
categorical_field_responses |>
  saveRDS(testthat::test_path("get_categorical_field_response_values", "input.rds"))
