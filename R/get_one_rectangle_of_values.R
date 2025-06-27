#' Generate a rectangle of data for one record
#'
#' @param one_record_id a single record_id
#' @param record_id_name the column name the record_id should be returned in
#' @param forms_to_fill the forms to fill for this rectangle
#' @param fields_and_responses the output of [get_text_fields()],
#'   [get_slider_fields()], [get_notes_fields()],  and
#'   [get_categorical_field_responses()] functions
#' @param event_name event name to include as a column after record_id;
#' default NA_character_. If NA, omit column for compatibility.
#'
#' @returns A rectangle of data with appropriate REDCap identifiers ready
#'   to write to REDCap
#' @keywords Internal
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' get_one_rectangle_of_values(1, record_id_name, forms_to_fill)
#' }
get_one_rectangle_of_values <- function(
    one_record_id = 1,
    record_id_name,
    forms_to_fill,
    fields_and_responses,
    event_name = NA_character_) {
  redcap_identifiers <- dplyr::tibble(
    record_id = one_record_id
  )

  # fix the first column name
  names(redcap_identifiers) <- record_id_name

  # Optionally add event_name as second column if provided
  if (!is.na(event_name)) {
    event_col <- dplyr::tibble(event_name = event_name)
    # Rename the column to "redcap_event_name" for clarity
    names(event_col) <- "redcap_event_name"
    # Bind 'event_col' as second column after record_id
    redcap_identifiers <- dplyr::bind_cols(
      redcap_identifiers,
      event_col
    )
    # Reorder columns so event_name is directly after record_id_name
    redcap_identifiers <- redcap_identifiers[, c(1, 2)]
  }

  value_getter_functions <- c(
    "get_categorical_field_response_values",
    "get_text_field_values",
    "get_slider_field_values",
    "get_notes_field_values"
  )

  process_one_value_getter <- function(value_getter, df) {
    rlang::exec(value_getter, df)
  }

  # pick values for one record on one event
  all_responses <-
    purrr::map(
      value_getter_functions,
      process_one_value_getter,
      fields_and_responses |>
        dplyr::filter(.data$form_name %in% forms_to_fill)
    ) |>
    dplyr::bind_rows()

  # prefix responses with redcap fields
  result <- dplyr::bind_cols(
    redcap_identifiers,
    all_responses
  )

  id_cols <- names(redcap_identifiers)

  wide_result <- result |>
    tidyr::pivot_wider(
      id_cols = dplyr::any_of(id_cols),
      names_from = "field_name",
      values_from = "value"
    )

  return(wide_result)
}
