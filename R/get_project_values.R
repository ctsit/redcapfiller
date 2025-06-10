#' Get Project Values
#'
#' @param redcap_uri REDCap API URI
#' @param token REDCap project API token
#' @param events (Optional) Vector of event names to fill
#' @param number_of_records_to_populate Number of records to generate (default 5)
#' @return List of data frames (one per event, or just one for classic projects)
#' @export
get_project_values <- function(
    redcap_uri,
    token,
    events = NULL,
    number_of_records_to_populate = 5) {
  checkmate::assert_string(redcap_uri, min.chars = 1)
  checkmate::assert_string(token, min.chars = 1)
  if (!is.null(events)) checkmate::assert_character(events, any.missing = FALSE)
  checkmate::assert_count(number_of_records_to_populate, positive = TRUE)

  # Get project settings and enforce restrictions
  project_info <- REDCapR::redcap_project_info_read(
    redcap_uri = redcap_uri,
    token = token
  )$data

  checkmate::assert_logical(project_info$is_longitudinal, len = 1, any.missing = FALSE)
  checkmate::assert_logical(project_info$has_repeating_instruments_or_events, len = 1, any.missing = FALSE)
  checkmate::assert_logical(project_info$randomization_enabled, len = 1, any.missing = FALSE)
  if (isTRUE(project_info$has_repeating_instruments_or_events)) stop("Projects with repeating instruments/events are not supported.")
  if (isTRUE(project_info$randomization_enabled)) stop("Projects with randomization enabled are not supported.")
  is_longitudinal <- project_info$is_longitudinal

  metadata <- REDCapR::redcap_metadata_read(
    token = token,
    redcap_uri = redcap_uri
  )$data

  record_id_name <- metadata |>
    dplyr::filter(dplyr::row_number() == 1) |>
    dplyr::pull(.data$field_name)

  forms_to_fill <- metadata |>
  dplyr::distinct(.data$form_name) |>
  dplyr::pull(.data$form_name)

  # Exclude record_id, descriptive, calc, file, and fields hidden by branching logic,
  # and only keep fields of types we know how to fill.
  field_types_we_know_how_to_fill <- c(
    "checkbox", "dropdown", "notes", "radio", "text",
    "yesno", "truefalse", "slider"
  )
  metadata_to_populate <-
    metadata |>
    dplyr::filter(.data$field_name != record_id_name) |>
    dplyr::filter(.data$form_name %in% forms_to_fill) |>
    dplyr::filter(.data$field_type != "descriptive") |>
    dplyr::filter(.data$field_type != "calc") |>
    dplyr::filter(.data$field_type != "file") |>
    dplyr::filter(is.na(.data$branching_logic)) |>
    dplyr::filter(.data$field_type %in% field_types_we_know_how_to_fill)

  read_result <- REDCapR::redcap_read(
    token = token,
    redcap_uri = redcap_uri
  )
  if (nrow(read_result$data) > 0) {
    max_existing_id <- suppressWarnings(max(read_result$data[[record_id_name]], na.rm = TRUE))
  } else {
    max_existing_id <- 0
  }
  first_id <- max_existing_id + 1
  record_ids <- seq(first_id, first_id + number_of_records_to_populate - 1)

  categorical_field_responses <- get_categorical_field_responses(metadata_to_populate)
  text_fields <- get_text_fields(metadata_to_populate)
  slider_fields <- get_slider_fields(metadata_to_populate)
  notes_fields <- get_notes_fields(metadata_to_populate)
  fields_and_responses <- dplyr::bind_rows(
    categorical_field_responses,
    text_fields,
    slider_fields,
    notes_fields
  )

  # Helper for generating all rows for a single event (or classic project)
  get_all_rows_in_rectangle <- function(record_ids, record_id_name, forms_to_fill, fields_and_responses, event_name = NA_character_) {
    purrr::map_dfr(
      record_ids,
      get_one_rectangle_of_values,
      record_id_name = record_id_name,
      forms_to_fill = forms_to_fill,
      fields_and_responses = fields_and_responses,
      event_name = event_name
    )
  }

  if (is_longitudinal) {
    event_info <- REDCapR::redcap_event_read(
      token = token,
      redcap_uri = redcap_uri
    )$data
    event_mapping <- REDCapR::redcap_event_instruments(
      token = token,
      redcap_uri = redcap_uri
    )$data
    event_forms <- dplyr::inner_join(
      event_info, event_mapping,
      by = "unique_event_name"
    )
    # filter for param-specified events
    if (!is.null(events)) {
      event_forms <- event_forms |>
        dplyr::filter(.data$unique_event_name %in% events)
    }
    # filter forms we know how to fill
    event_forms <- event_forms |>
      dplyr::filter(.data$form %in% forms_to_fill)
    # For each event, get the relevant forms
    event_names <- unique(event_forms$unique_event_name)
    form_vectors <- purrr::map(
      event_names,
      ~ event_forms |>
        dplyr::filter(.data$unique_event_name == .x) |>
        dplyr::pull(.data$form)
    )

    picked_values_list <- purrr::map2(
      event_names,
      form_vectors,
      ~ get_all_rows_in_rectangle(
        record_ids,
        record_id_name,
        forms_to_fill = .y,
        fields_and_responses,
        event_name = .x
      )
    )
    return(picked_values_list)
  } else {
    picked_values <- get_all_rows_in_rectangle(
      record_ids,
      record_id_name,
      forms_to_fill,
      fields_and_responses
    )
    return(list(picked_values))
  }
}
