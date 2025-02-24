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

testthat::test_that("get_long_text_field_values returns a value field for date and datetime fields", {
  date_fields <- output$field_name[grepl("^date.", output$field_name)]
  datetime_fields <- output$field_name[grepl("^datetime.", output$field_name)]

  date_values <- output$value[output$field_name %in% date_fields]
  datetime_values <- output$value[output$field_name %in% datetime_fields]

  testthat::expect_true(length(date_fields) > 0 | length(datetime_fields) > 0)
  testthat::expect_true(all(date_values != "") & all(datetime_values != ""))
})


