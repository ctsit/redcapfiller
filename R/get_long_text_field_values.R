#' @title generate text field values
#' @description
#' Provide a set of values for each field in the output of
#' `get_long_text_fields`
#'
#' @param long_text_fields a long data set of text
#'   fields, their parameters, and weights.
#'
#' @return a long dataframe of text field values with one row for each value set.
#' @export
#'
#' @examples
#' \dontrun{
#' get_long_text_field_values(long_text_fields)
#' }
get_long_text_field_values <- function(long_text_fields) {
  tvt_na <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_na") |>
      dplyr::mutate(value = replicate(length(.data$field_name), lorem::ipsum_words(round(stats::rnorm(mean = .data$mean, sd = .data$sd, n = 1)))))
    # |>
    #   dplyr::slice_sample(prop = 0.5, weight_by = .data$weight)
  }

  tvt_types <- c(
    "tvt_na"
  )

  process_one_text_validation_type <- function(my_tvt, df) {
    # exec (run) the function named in `alert` on the rows of data that
    #  have an alert_type of `alert`
    result <- rlang::exec(my_tvt, df |>
      dplyr::filter(.data$tvt == my_tvt))
    return(result)
  }

  text_field_values <-
    purrr::map(tvt_types,
               process_one_text_validation_type,
               long_text_fields |> dplyr::filter(.data$field_type == "text")
               ) |>
    dplyr::bind_rows()

  result <- text_field_values |>
    dplyr::select("field_name", "value")

  return(result)
}
