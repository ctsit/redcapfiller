long_categorical_field_responses <- readRDS(
  testthat::test_path("get_long_categorical_field_response_values", "input.rds")
)

output <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "record_id",
  forms_to_fill = "tests",
  long_categorical_field_responses
)

output_with_special_record_id <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "special_id",
  forms_to_fill = "tests",
  long_categorical_field_responses
)

testthat::test_that("get_one_rectangle_of_values: ethnicity, occupation, race, and state are represented in the columns", {
  testthat::expect_true(all(c("record_id", "ethnicity", "occupation", "race", "state") %in% names(output)))
})

testthat::test_that("get_one_rectangle_of_values: bl_caffeine, bl_exercise, and bl_treatments are represented in the columns", {
  testthat::expect_true(all(c("bl_caffeine", "bl_exercise", "bl_treatments") %in% gsub("___.*", "", names(output))))
})

testthat::test_that("get_one_rectangle_of_values: special_id is in the record_id position", {
  testthat::expect_equal(names(output_with_special_record_id)[[1]], "special_id")
})
