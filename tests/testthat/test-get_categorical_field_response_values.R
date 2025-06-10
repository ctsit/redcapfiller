categorical_field_responses <- readRDS(
  testthat::test_path("get_categorical_field_response_values", "input.rds")
)

output <- get_categorical_field_response_values(categorical_field_responses)

testthat::test_that("get_categorical_field_response_values: ethnicity, occupation, race, and state are represented", {
  testthat::expect_true(all.equal(
    output |>
      dplyr::filter(field_name %in% c("ethnicity", "occupation", "race", "state")) |>
      dplyr::arrange(field_name) |>
      dplyr::pull(field_name),
    c("ethnicity", "occupation", "race", "state")
  ))
})

testthat::test_that("get_categorical_field_response_values: bl_caffeine, bl_exercise, and bl_treatments are represented", {
  testthat::expect_true(all.equal(
    output |>
      dplyr::filter(stringr::str_detect(field_name, "bl_caffeine|bl_exercise|bl_treatments")) |>
      dplyr::mutate(field_group = stringr::str_replace(field_name, "___.*", "")) |>
      dplyr::distinct(field_group) |>
      dplyr::arrange(field_group) |>
      dplyr::pull(field_group),
    c("bl_caffeine", "bl_exercise", "bl_treatments")
  ))
})
