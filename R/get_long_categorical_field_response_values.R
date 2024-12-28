#' @title generate categorical field response values
#' @description
#' Provide a set of response values for each categorical field in
#' `long_categorical_field_responses`
#'
#' @param long_categorical_field_responses a long data set of categorical
#'   field response values and weights.
#'
#' @return a tall dataframe of categorical field response values with one
#' row for each value set.
#' @export
#'
#' @examples
#' \dontrun{
#' get_long_categorical_field_response_values(long_categorical_field_responses)
#' }
get_long_categorical_field_response_values <- function(long_categorical_field_responses) {
  single_value_responses <- long_categorical_field_responses |>
    dplyr::filter(.data$field_type != "checkbox") |>
    dplyr::group_by(.data$field_name) |>
    dplyr::slice_sample(n = 1, weight_by = .data$weight) |>
    dplyr::ungroup()

  multi_value_responses <-
    long_categorical_field_responses |>
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
