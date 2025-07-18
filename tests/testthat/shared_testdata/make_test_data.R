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

metadata |> readr::write_csv(testthat::test_path("get_text_fields", "metadata.csv"), na = "")
