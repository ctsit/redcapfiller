metadata_file <- testthat::test_path("shared_testdata", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

fields_and_responses <- dplyr::bind_rows(
  get_categorical_field_responses(metadata),
  get_text_fields(metadata),
  get_notes_fields(metadata),
  get_slider_fields(metadata)
)

fields_and_responses |>
  saveRDS(testthat::test_path("get_one_rectangle_of_values", "input.rds"))
