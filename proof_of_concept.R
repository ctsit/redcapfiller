library(tidyverse)
library(REDCapR)
# Read environment from ".env" in the project directory
library(dotenv)
load_dot_env(".env")

# Load redcapfiller. Make sure you build it first or it won't load.
library(redcapfiller)

# Create a credentials file if you don't already have one
# path_credential = Sys.getenv("path_credential")
# REDCapR::create_credential_local(
#   path_credential
# )
# Manually populate that

# Get our credentials using environment variables to locate
# the credentials file and describe the project in it
path_credential <- Sys.getenv("path_credential")
credentials <- REDCapR::retrieve_credential_local(
  path_credential,
  project_id = Sys.getenv("filler_demo_pid")
  #  project_id = 16255
)

generated_values <- REDCapR::get_project_values(
  redcap_uri = credentials$redcap_uri,
  token = credentials$token
)

if (is.data.frame(generated_values)) {
  REDCapR::redcap_write(
    redcap_uri = credentials$redcap_uri,
    token = credentials$token,
    ds_to_write = generated_values
  )
} else {
  purrr::walk(
    generated_values,
    ~ REDCapR::redcap_write(
      redcap_uri = credentials$redcap_uri,
      token = credentials$token,
      ds_to_write = .x
    )
  )
}
