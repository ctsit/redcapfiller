metadata_file <- testthat::test_path("get_long_categorical_field_responses", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

output <- get_long_categorical_field_responses(metadata)

testthat::test_that("get_long_categorical_field_responses: processes only checkbox, dropdown, and radio", {
  testthat::expect_equal(
    output |>
      dplyr::distinct(field_type) |>
      dplyr::arrange(field_type) |>
      dplyr::pull(field_type),
    c("checkbox", "dropdown", "radio")
  )
})

testthat::test_that("get_long_categorical_field_responses: checkbox responses are all 1", {
  testthat::expect_equal(output |>
    dplyr::filter(field_type == "checkbox") |>
    dplyr::distinct(response_code) |>
    dplyr::pull(response_code), "1")
})

testthat::test_that("get_long_categorical_field_responses: non-checkbox responses are distinct within each field", {
  testthat::expect_equal(output |>
    dplyr::filter(field_type != "checkbox") |>
    dplyr::group_by(field_name) |>
    dplyr::count(response_code) |>
    dplyr::ungroup() |>
    dplyr::distinct(n) |>
    dplyr::pull(n), 1)
})

testthat::test_that("get_long_categorical_field_responses: weights are balanced", {
  testthat::expect_true(output |>
    dplyr::group_by(field_group) |>
    dplyr::summarise(balanced = (min(weight) == max(weight))) |>
    dplyr::ungroup() |>
    dplyr::distinct(balanced) |>
    dplyr::pull(balanced))
})
