metadata_file <- testthat::test_path("shared_testdata", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

output <- get_text_fields(metadata)

testthat::test_that("get_text_fields: processes only text fields", {
  testthat::expect_equal(
    output |>
      dplyr::distinct(field_type) |>
      dplyr::pull(field_type),
    c("text")
  )
})

testthat::test_that("get_text_fields: returns the validation type columns", {
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

testthat::test_that("get_text_fields: weights are balanced", {
  testthat::expect_true(output |>
    dplyr::summarise(balanced = (min(weight) == max(weight))) |>
    dplyr::distinct(balanced) |>
    dplyr::pull(balanced))
})

testthat::test_that("get_text_fields: origin_function and sd columns are present", {
  datetime_support_columns <- c("origin_function", "sd")
  testthat::expect_equal(
    output |>
      dplyr::select(dplyr::all_of(datetime_support_columns)) |> names(),
    datetime_support_columns
  )
})
