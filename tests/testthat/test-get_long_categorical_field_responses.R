metadata_file <- testthat::test_path("shared_testdata", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

output <- get_long_categorical_field_responses(metadata)

testthat::test_that("get_long_categorical_field_responses: processes checkbox, dropdown, radio, truefalse and yesno", {
  testthat::expect_equal(
    output |>
      dplyr::distinct(field_type) |>
      dplyr::arrange(field_type) |>
      dplyr::pull(field_type),
    c("checkbox", "dropdown", "radio", "truefalse", "yesno")
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

testthat::test_that("get_long_categorical_field_responses: truefalse are 1 and 0", {
  testthat::expect_equal(output |>
   dplyr::filter(field_type == "truefalse") |>
   dplyr::distinct(response_code) |>
   dplyr::pull(response_code),
   c("1", "0"))
})

testthat::test_that("get_long_categorical_field_responses: yesno are 1 and 0", {
  testthat::expect_equal(output |>
   dplyr::filter(field_type == "yesno") |>
   dplyr::distinct(response_code) |>
   dplyr::pull(response_code),
 c("1", "0"))
})

