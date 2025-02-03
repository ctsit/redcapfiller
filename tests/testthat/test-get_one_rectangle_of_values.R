long_categorical_field_responses <- readRDS(
  testthat::test_path("get_long_categorical_field_response_values", "input.rds")
)

long_notes_fields_responses <- readRDS(
  testthat::test_path("get_long_notes_field_responses", "input.rds")
)

output <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "record_id",
  forms_to_fill = "tests",
  long_categorical_field_responses,
  long_notes_fields_responses
)

output_with_special_record_id <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "special_id",
  forms_to_fill = "tests",
  long_categorical_field_responses,
  long_notes_fields_responses
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

testthat::test_that("get_one_rectangle_of_values: notes fields are represented in the columns", {
  testthat::expect_true(all(c("addl_notes", "bl_treatments_other_notes", "phy_notes") %in% names(output)))
})

testthat::test_that("get_one_rectangle_of_values: has values for all notes fields", {
  testthat::expect_true(all(!is.na(output$addl_notes)))
  testthat::expect_true(all(!is.na(output$bl_treatments_other_notes)))
  testthat::expect_true(all(!is.na(output$phy_notes)))

  testthat::expect_true(all(!is.na(output_with_special_record_id$addl_notes)))
  testthat::expect_true(all(!is.na(output_with_special_record_id$bl_treatments_other_notes)))
  testthat::expect_true(all(!is.na(output_with_special_record_id$phy_notes)))
})

