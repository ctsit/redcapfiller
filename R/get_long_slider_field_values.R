#' @title generate slider field values
#' @description
#' Provide a set of values for each slider field in
#' `long_slider_values`
#'
#' @param long_slider_values a long data set of slider values and weights.
#'
#' @return a tall dataframe of slider values with one row for each field
#' @export
#'
#' @examples
#' \dontrun{
#' get_long_slider_field_values(long_slider_values)
#' }
get_long_slider_field_values <- function(long_slider_values) {

  result <- long_slider_values |>
    dplyr::filter(.data$field_type == "slider") |>
    dplyr::mutate(
      response_code = round(stats::rnorm(n = 1,mean = .data$mean, sd = .data$sd)),
      response_code = as.character(ifelse(
        .data$response_code < as.numeric(.data$text_validation_min) |
          .data$response_code > as.numeric(.data$text_validation_max) ,
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
