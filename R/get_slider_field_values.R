#' @title generate slider field values
#' @description
#' Provide a set of values for each slider field in
#' `slider_values`
#'
#' @param slider_values a long data set of slider values and weights.
#'
#' @return a tall dataframe of slider values with one row for each field
#' @export
#'
#' @examples
#' \dontrun{
#' get_slider_field_values(slider_values)
#' }
get_slider_field_values <- function(slider_values) {

  result <- slider_values |>
    dplyr::filter(.data$field_type == "slider") |>
    dplyr::mutate(
      response_code = round(stats::rnorm(n = length(.data$mean), mean = .data$mean, sd = .data$sd)),
      response_code = as.character(ifelse(
        .data$response_code < dplyr::coalesce(as.numeric(.data$text_validation_min), 0) |
          .data$response_code > dplyr::coalesce(as.numeric(.data$text_validation_max), 100) ,
        NA,
        .data$response_code)
      )
    ) |>
    dplyr::group_by(.data$field_name) |>
    dplyr::slice_sample(n = 1, weight_by = .data$weight) |>
    dplyr::ungroup() |>
    dplyr::select("field_name", value = "response_code")

  return(result)
}
