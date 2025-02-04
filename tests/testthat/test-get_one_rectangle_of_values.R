long_fields_and_responses <- readRDS(
  testthat::test_path("get_one_rectangle_of_values", "input.rds")
) |>
  # filter out the record_id row because we are generating it in these tests
  dplyr::filter(.data$field_name != "record_id")

output <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "record_id",
  forms_to_fill = "tests",
  long_fields_and_responses
)

output_with_special_record_id <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "special_id",
  forms_to_fill = "tests",
  long_fields_and_responses
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

testthat::test_that("get_one_rectangle_of_values: fname and lname are represented in the columns", {
  testthat::expect_true(all(c("fname", "lname") %in% gsub("___.*", "", names(output))))
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

