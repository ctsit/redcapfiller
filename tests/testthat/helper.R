# write a dataframe, referenced by 'table_name' to tests/testthat/directory_under_test_path
write_rds_to_test_dir <- function(table_name, directory_under_test_path) {
  get(table_name) |> saveRDS(testthat::test_path(directory_under_test_path, paste0(table_name, ".rds")))
}
