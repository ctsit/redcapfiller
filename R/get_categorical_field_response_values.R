#' @title Generate categorical field response values
#' @description
#' Provide a set of response values for each categorical field in
#' `categorical_field_responses`
#'
#' @param categorical_field_responses A long dataframe of categorical
#'   field response values and weights.
#'
#' @return A long dataframe of categorical field response values with one
#' row for each value set.
#' @keywords Internal
#'
#' @examples
#' \dontrun{
#' get_categorical_field_response_values(categorical_field_responses)
#' }
get_categorical_field_response_values <- function(categorical_field_responses) {
  single_value_responses <- categorical_field_responses |>
    # Filter for any categorical field_type
    dplyr::filter(.data$field_type %in% c(
      "checkbox",
      "dropdown",
      "radio",
      "yesno"
    )) |>
    # Filter for anything but checkbox fields
    dplyr::filter(.data$field_type != "checkbox") |>
    dplyr::group_by(.data$field_name) |>
    dplyr::slice_sample(n = 1, weight_by = .data$weight) |>
    dplyr::ungroup()

  multi_value_responses <-
    categorical_field_responses |>
    # Filter for checkbox fields
    dplyr::filter(.data$field_type == "checkbox") |>
    dplyr::group_by(.data$field_group) |>
    dplyr::slice_sample(prop = 0.5, weight_by = .data$weight) |>
    dplyr::ungroup()

  result <- dplyr::bind_rows(
    single_value_responses,
    multi_value_responses
  ) |>
    dplyr::select("field_name", value = "response_code")

  return(result)
}
