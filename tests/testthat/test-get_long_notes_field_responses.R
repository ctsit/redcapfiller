long_notes_field_responses <- readRDS(
  testthat::test_path("get_long_notes_field_responses", "input.rds")
)

output <- get_long_notes_field_responses(long_notes_field_responses)

testthat::test_that("get_long_notes_field_responses returns a value field", {
  testthat::expect_true("value" %in% colnames(output))
})

testthat::test_that("get_long_notes_field_responses field_names have notes in their names", {
  testthat::expect_true(all(stringr::str_detect(output$field_name, "notes")))
})
