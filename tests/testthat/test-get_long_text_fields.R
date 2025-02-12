metadata_file <- testthat::test_path("get_long_text_fields", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

output <- get_long_text_fields(metadata)

testthat::test_that("get_long_text_fields: processes only text fields", {
  testthat::expect_equal(
    output |>
      dplyr::distinct(field_type) |>
      dplyr::pull(field_type),
    c("text")
  )
})

testthat::test_that("get_long_text_fields: returns the validation type columns", {
  text_validation_columns <- c(
    "text_validation_type",
    "text_validation_min",
    "text_validation_max"
  )
  testthat::expect_equal(
    output |> dplyr::select(dplyr::all_of(text_validation_columns)) |> names(),
    text_validation_columns
  )
})

testthat::test_that("get_long_text_fields: weights are balanced", {
  testthat::expect_true(output |>
    dplyr::summarise(balanced = (min(weight) == max(weight))) |>
    dplyr::distinct(balanced) |>
    dplyr::pull(balanced))
})
