metadata_file <- testthat::test_path("get_notes_fields", "metadata.csv")
metadata <- readr::read_csv(metadata_file)

output <- get_notes_fields(metadata)

testthat::test_that("get_notes_fields has all the required columns", {
  testthat::expect_true(all(c("field_name", "form_name", "field_type", "weight") %in% colnames(output)))
})

testthat::test_that("get_notes_fields returns uniform weights", {
  testthat::expect_true(all(output$weight == 100))
})

testthat::test_that("get_notes_fields returns empty data frame when no notes fields are present", {
  metadata <- data.frame(field_name = character(0), form_name = character(0), field_type = character(0))
  output <- get_notes_fields(metadata)
  testthat::expect_true(nrow(output) == 0)
})
