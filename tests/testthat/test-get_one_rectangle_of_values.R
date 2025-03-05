long_fields_and_responses <- readRDS(testthat::test_path("get_one_rectangle_of_values", "input.rds")) |>
  # filter out the record_id row because we are generating it in these tests
  dplyr::filter(.data$field_name != "record_id")

output <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "record_id",
  forms_to_fill = "form_1",
  long_fields_and_responses
)

output_with_special_record_id <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "special_id",
  forms_to_fill = "form_1",
  long_fields_and_responses
)

testthat::test_that("get_one_rectangle_of_values: outputs have the correct record ID field names", {
  testthat::expect_equal(names(output)[1], "record_id")
  testthat::expect_equal(names(output_with_special_record_id)[1], "special_id")
})

testthat::test_that("get_one_rectangle_of_values: basic form fields are present", {
  testthat::expect_true(all(c("f_dropdown", "f_radio", "f_yes_no", "f_text") %in% names(output)))
  testthat::expect_true(all(c("f_dropdown", "f_radio", "f_yes_no", "f_text") %in% names(output_with_special_record_id)))
})

testthat::test_that("get_one_rectangle_of_values: checkbox fields are present with different indices", {
  testthat::expect_true(any(grepl("f_checkbox___", names(output))))
  testthat::expect_true(any(grepl("f_checkbox___", names(output_with_special_record_id))))
})

# Helper function to check field presence by pattern
check_fields_by_pattern <- function(output, output_with_special_record_id, pattern, description) {
  fields_output <- names(output)[grepl(pattern, names(output))]
  fields_special_output <- names(output_with_special_record_id)[grepl(pattern, names(output_with_special_record_id))]

  testthat::test_that(paste("get_one_rectangle_of_values:", description, "fields are present"), {
    testthat::expect_true(length(fields_output) > 0,
                          info = paste("No", description, "fields found in output"))
    testthat::expect_true(length(fields_special_output) > 0,
                          info = paste("No", description, "fields found in output_with_special_record_id"))
  })
}

check_fields_by_pattern(output, output_with_special_record_id,
                        "^v_number|^v_integer", "numeric")

check_fields_by_pattern(output, output_with_special_record_id,
                        "^v_date|^v_datetime", "date/datetime")

check_fields_by_pattern(output, output_with_special_record_id, "^v_email", "email")
check_fields_by_pattern(output, output_with_special_record_id, "^v_zipcode", "zipcode")
check_fields_by_pattern(output, output_with_special_record_id, "^v_phone", "phone")

# Test for text fields
testthat::test_that("get_one_rectangle_of_values: text fields are handled correctly", {
  text_fields <- c("f_text", "f_notes")

  for (field in text_fields) {
    testthat::expect_true(field %in% names(output),
                          info = paste("Field", field, "not found in output"))
    testthat::expect_true(field %in% names(output_with_special_record_id),
                          info = paste("Field", field, "not found in output_with_special_record_id"))
  }
})

testthat::test_that("get_one_rectangle_of_values: slider field exists", {
  testthat::expect_true("f_slider" %in% names(output))
  testthat::expect_true("f_slider" %in% names(output_with_special_record_id))
})

testthat::test_that("get_one_rectangle_of_values: both outputs have same number of columns", {
  testthat::expect_equal(length(names(output)), length(names(output_with_special_record_id)))
})

testthat::test_that("get_one_rectangle_of_values: outputs have similar structure beyond ID and checkbox fields", {
  output_filtered <- names(output)[!grepl("^record_id$|f_checkbox___", names(output))]
  special_id_filtered <- names(output_with_special_record_id)[
    !grepl("^special_id$|f_checkbox___", names(output_with_special_record_id))
  ]

  testthat::expect_equal(output_filtered, special_id_filtered)
})

testthat::test_that("get_one_rectangle_of_values: important fields have values", {
  testthat::expect_false(is.na(output$f_text[1]))
  testthat::expect_false(is.na(output$f_notes[1]))
  testthat::expect_false(is.na(output_with_special_record_id$f_text[1]))
  testthat::expect_false(is.na(output_with_special_record_id$f_notes[1]))
})
