long_slider_fields <- readRDS(
  testthat::test_path("get_long_slider_field_values", "input.rds")
)

output <- get_long_slider_field_values(long_slider_fields)

#TODO: vverify test_validation_min/max
testthat::test_that("get_long_slider_field_values returns the correct df with values within the slider ranges", {
  testthat::expect_true(all.equal(
    output |>
      dplyr::filter(field_name %in% c("ethnicity", "occupation", "race", "state")) |>
      dplyr::arrange(field_name) |>
      dplyr::pull(field_name),
    c("ethnicity", "occupation", "race", "state")
  ))
})
