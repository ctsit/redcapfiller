long_slider_fields <- readRDS(
  testthat::test_path("get_long_slider_field_values", "input.rds")
)

output <- get_long_slider_field_values(long_slider_fields)

testthat::test_that("get_long_slider_field_values returns the correct df with values within the slider ranges", {
  slider_bounds <- long_slider_fields |>
    dplyr::select(field_name, text_validation_min, text_validation_max) |>
    dplyr::group_by(field_name) |>
    dplyr::summarise(
      text_validation_min = min(text_validation_min),
      text_validation_max = max(text_validation_max)
    )

  result <- output %>%
    dplyr::left_join(slider_bounds, by = "field_name") |>
    dplyr::summarise(all_within_range = all(dplyr::between(
      as.numeric(value),
      as.numeric(text_validation_min),
      as.numeric(text_validation_max)
    ), na.rm = TRUE))

  testthat::expect_true(result$all_within_range)
})

testthat::test_that("get_long_slider_field_values returns a unique number for each slider", {
  testthat::expect_equal(
    output |> dplyr::distinct(value) |> nrow(),
    output |> nrow()
  )
})
