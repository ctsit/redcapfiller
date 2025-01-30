long_text_field_values <- readRDS(
  testthat::test_path("get_long_text_field_values", "input.rds")
)

output <- get_long_text_field_values(long_text_field_values)
output_b <- get_long_text_field_values(long_text_field_values)
output_c <- get_long_text_field_values(long_text_field_values)

testthat::test_that("get_long_text_field_values returns field_name and value columns", {
  testthat::expect_true(all.equal(
    names(output),
    c("field_name", "value")
  ))
})

testthat::test_that("get_long_text_field_values returns a constant vector of field_names when called repeatedly", {
  testthat::expect_true(identical(
    output$field_name, output_b$field_name
  ))
  testthat::expect_true(identical(
    output$field_name, output_c$field_name
  ))
})

testthat::test_that("get_long_text_field_values returns a varying vector of values when called repeatedly", {
  testthat::expect_false(identical(
    output$value, output_b$value
  ))
  testthat::expect_false(identical(
    output$value, output_c$value
  ))
})

