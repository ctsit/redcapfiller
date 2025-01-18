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
)

metadata <- REDCapR::redcap_metadata_read(
  token = credentials$token,
  redcap_uri = credentials$redcap_uri
)$data

# identify the record_id column
record_id_name <- metadata |>
  filter(row_number() == 1) |>
  pull(field_name)

# identify the forms to fill
forms_to_fill <- metadata |>
  distinct(form_name) |>
  filter(!form_name %in% c("randomization")) |>
  pull(form_name)

field_types_we_know_how_to_fill <- c(
  "checkbox",
  "dropdown",
  # "notes",
  "radio",
  # "text",
  "yesno",
  "truefalse"
)

metadata_to_populate <-
  metadata |>
  # Filter for record ID and forms we want to fill
  filter(field_name == record_id_name |
    form_name %in% forms_to_fill) |>
  # Exclude descriptive fields because they are not fillable
  filter(field_type != "descriptive") |>
  # Exclude calc fields because we don't control them
  #   (though we might strobe them to trigger writes in a future version)
  filter(field_type != "calc") |>
  # Exclude file fields
  #   (Eventually we'll add an option to populate them with a dummy file)
  filter(field_type != "file") |>
  # Filter for fields not hidden via branching logic.
  filter(is.na(branching_logic)) |>
  # filter for fields we no how to fill
  filter(field_type %in% field_types_we_know_how_to_fill)

# Make a vector of record IDs to populate
# Get highest existing id
read_result <- REDCapR::redcap_read(
  token = credentials$token,
  redcap_uri = credentials$redcap_uri
)

if (read_result$success) {
  max_existing_id <- max(read_result$data$record_id)
} else {
  max_existing_id = 0
}

# choose which IDs to use
first_id <- max_existing_id + 1
number_of_records_to_populate <- 5
record_ids <- seq(first_id, first_id + number_of_records_to_populate)

# get the categorical field responses in a long table and populate them
long_categorical_field_responses <- get_long_categorical_field_responses(metadata_to_populate)

picked_values <-
  purrr::map(record_ids,
             get_one_rectangle_of_values,
             record_id_name,
             forms_to_fill,
             long_categorical_field_responses
             ) |>
  bind_rows()

picked_values |> REDCapR::redcap_write(
  token = credentials$token,
  redcap_uri = credentials$redcap_uri
)
