metadata_file <- testthat::test_path("get_long_categorical_field_responses", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

output <- get_long_slider_fields(metadata)

testthat::test_that("get_long_slider_fields: processes sliders", {
  testthat::expect_equal(
    output |>
      dplyr::distinct(field_type) |>
      dplyr::arrange(field_type) |>
      dplyr::pull(field_type),
    "slider"
  )
})

testthat::test_that("get_long_slider_fields values are distinct within each field", {
  duplicate_values <- output %>%
    dplyr::group_by(field_name) %>%
    dplyr::summarise(duplicates = sum(duplicated(select_choices_or_calculations))) %>%
    dplyr::pull(duplicates)

  testthat::expect_true(all(duplicate_values == 0), "There are duplicate values within groups")
})

testthat::test_that("get_long_slider_fields weights are balanced", {
  testthat::expect_true(output |>
                          dplyr::group_by(field_name) |>
                          dplyr::summarise(balanced = (min(weight) == max(weight))) |>
                          dplyr::ungroup() |>
                          dplyr::distinct(balanced) |>
                          dplyr::pull(balanced))
})

