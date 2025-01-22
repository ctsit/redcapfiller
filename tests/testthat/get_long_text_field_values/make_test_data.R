# Download the data dictionary from a copy of REDCapR's validation-types-1 project.
# See https://ctsit.github.io/redcapfiller/articles/demonstration_and_testing.html for details

library(tidyverse)
library(REDCapR)
# Read environment from ".env" in the project directory
library(dotenv)
load_dot_env(".env")

# Get our credentials using environment variables to locate
# the credentials file and describe the project in it
path_credential <- Sys.getenv("path_credential")
credentials <- REDCapR::retrieve_credential_local(
  path_credential,
  project_id = Sys.getenv("filler_demo_pid")
)

metadata <- REDCapR::redcap_metadata_read(
  token = credentials$token,
  redcap_uri = credentials$redcap_uri
)$data

long_text_fields <- metadata |> get_long_text_fields()

long_text_fields |> saveRDS(testthat::test_path("get_long_text_field_values", "input.rds"))
