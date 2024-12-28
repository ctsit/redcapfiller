#' Generate a rectangle of data for one record
#'
#' @param one_record_id a single record_id
#' @param record_id_name the column name the record_id should be returned in
#' @param forms_to_fill the forms to fill for this rectangle
#' @param long_categorical_field_responses the output of `get_long_categorical_field_responses()`
#'
#' @returns a rectangle of data with appropriate REDCap identifiers ready to write to REDCap
#' @export
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
    long_categorical_field_responses) {
  # Build tibble of static REDCap identifiers
  redcap_identifiers <- dplyr::tibble(
    record_id = one_record_id
  )

  # fix the first column name
  names(redcap_identifiers) <- record_id_name

  # pick values for one record on one event
  #    ...by binding the output of each field_type / field_validation function
  all_responses <- dplyr::bind_rows(
    get_long_categorical_field_response_values(
      long_categorical_field_responses |>
        dplyr::filter(.data$form_name %in% forms_to_fill)
    )
  )

  # prefix responses with redcap fields
  long_result <- dplyr::bind_cols(
    redcap_identifiers,
    # later we will add redcap_event_name, redcap_repeat_instrument, dag_name, etc. where appropriate
    all_responses
  )

  wide_result <- long_result |>
    tidyr::pivot_wider(
      id_cols = dplyr::any_of(names(redcap_identifiers)),
      names_from = "field_name",
      values_from = "value"
    )

  return(wide_result)
}
