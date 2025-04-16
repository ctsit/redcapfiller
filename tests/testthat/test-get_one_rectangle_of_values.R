long_fields_and_responses <- readRDS(testthat::test_path("get_one_rectangle_of_values", "input.rds")) |>
  # filter out the record_id row because we are generating it in these tests
  dplyr::filter(.data$field_name != "record_id")

# Classic output (no event_name column)
output <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "record_id",
  forms_to_fill = "form_1",
  long_fields_and_responses=long_fields_and_responses
)

output_with_special_record_id <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "special_id",
  forms_to_fill = "form_1",
  long_fields_and_responses=long_fields_and_responses
)

# Output with event_name column
output_with_event <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "record_id",
  forms_to_fill = "form_1",
  long_fields_and_responses,
  event_name = "visit_1_arm_1"
)

output_with_special_id_and_event <- get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name = "special_id",
  forms_to_fill = "form_1",
  long_fields_and_responses,
  event_name = "visit_1_arm_1"
)

testthat::test_that("outputs have the correct record ID field names", {
  testthat::expect_equal(names(output)[1], "record_id")
  testthat::expect_equal(names(output_with_special_record_id)[1], "special_id")
  testthat::expect_equal(names(output_with_event)[1], "record_id")
  testthat::expect_equal(names(output_with_special_id_and_event)[1], "special_id")
})

testthat::test_that("outputs have event_name column only if provided", {
  testthat::expect_false("redcap_event_name" %in% names(output))
  testthat::expect_false("redcap_event_name" %in% names(output_with_special_record_id))
  testthat::expect_equal(names(output_with_event)[2], "redcap_event_name")
  testthat::expect_equal(names(output_with_special_id_and_event)[2], "redcap_event_name")
})

testthat::test_that("event_name column has correct value when present", {
  if ("redcap_event_name" %in% names(output_with_event)) {
    testthat::expect_equal(output_with_event$redcap_event_name[1], "visit_1_arm_1")
  }
  if ("redcap_event_name" %in% names(output_with_special_id_and_event)) {
    testthat::expect_equal(output_with_special_id_and_event$redcap_event_name[1], "visit_1_arm_1")
  }
})

testthat::test_that("basic form fields are present", {
  testthat::expect_true(all(c("f_dropdown", "f_radio", "f_yes_no", "f_text") %in% names(output)))
  testthat::expect_true(all(c("f_dropdown", "f_radio", "f_yes_no", "f_text") %in% names(output_with_special_record_id)))
  testthat::expect_true(all(c("f_dropdown", "f_radio", "f_yes_no", "f_text") %in% names(output_with_event)))
  testthat::expect_true(all(c("f_dropdown", "f_radio", "f_yes_no", "f_text") %in% names(output_with_special_id_and_event)))
})

testthat::test_that("checkbox fields are present with different indices", {
  testthat::expect_true(any(grepl("f_checkbox___", names(output))))
  testthat::expect_true(any(grepl("f_checkbox___", names(output_with_special_record_id))))
  testthat::expect_true(any(grepl("f_checkbox___", names(output_with_event))))
  testthat::expect_true(any(grepl("f_checkbox___", names(output_with_special_id_and_event))))
})

# Helper function to check field presence by pattern
check_fields_by_pattern <- function(outputs, pattern, description) {
  for (output in outputs) {
    fields <- names(output)[grepl(pattern, names(output))]
    testthat::test_that(paste("fields by pattern:", description, "fields are present"), {
      testthat::expect_true(length(fields) > 0, info = paste("No", description, "fields found in output"))
    })
  }
}

outputs_list <- list(output, output_with_special_record_id, output_with_event, output_with_special_id_and_event)

check_fields_by_pattern(outputs_list, "^v_number|^v_integer", "numeric")
check_fields_by_pattern(outputs_list, "^v_date|^v_datetime", "date/datetime")
check_fields_by_pattern(outputs_list, "^v_email", "email")
check_fields_by_pattern(outputs_list, "^v_zipcode", "zipcode")
check_fields_by_pattern(outputs_list, "^v_phone", "phone")

testthat::test_that("text and notes fields are handled correctly", {
  text_fields <- c("f_text", "f_notes")
  for (output in outputs_list) {
    for (field in text_fields) {
      testthat::expect_true(field %in% names(output),
        info = paste("Field", field, "not found in output")
      )
    }
  }
})

testthat::test_that("slider field exists", {
  for (output in outputs_list) {
    testthat::expect_true("f_slider" %in% names(output))
  }
})

testthat::test_that("outputs have same number of columns for classic and event outputs", {
  testthat::expect_equal(length(names(output)), length(names(output_with_special_record_id)))
  testthat::expect_equal(length(names(output_with_event)), length(names(output_with_special_id_and_event)))
})

testthat::test_that("important fields have values", {
  for (output in outputs_list) {
    testthat::expect_false(is.na(output$f_text[1]))
    testthat::expect_false(is.na(output$f_notes[1]))
  }
})
