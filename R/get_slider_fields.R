#' @title Get slider field from a REDCap data dictionary
#'
#' @description
#' Given a REDCap data dictionary, enumerate every slider field in that data
#' dictionary including select choices, min and max values, and add a mean and
#' standard deviation derived from the min and max values.
#'
#' @param metadata A REDCap data dictionary
#'
#' @returns A long dataframe with these columns
#' \describe{
#'   \item{field_name}{REDCap field name}
#'   \item{form_name}{REDCap form name}
#'   \item{field_type}{REDCap field type}
#'   \item{select_choices_or_calculations}{RedCap select_choices_or_calculations field}
#'   \item{text_validation_min}{REDCap text validation min}
#'   \item{text_validation_max}{REDCap text validation max}
#'   \item{mean}{mean of data to be generated. This is derived from the allowed range of values}
#'   \item{sd}{standard deviation of data to be generated. This is derived from the allowed range of values}
#'
#' }
#' @keywords Internal
#'
#' @examples
#' \dontrun{
#' slider_fields <-
#'   get_slider_fields(metadata_to_populate)
#' }
get_slider_fields <- function(metadata) {
  slider_values <- metadata |>
    # include only slider field types
    dplyr::filter(.data$field_type == "slider") |>
    dplyr::group_by(.data$field_name) |>
    dplyr::mutate(
      text_validation_max = dplyr::if_else(
        is.na(.data$text_validation_max),
        "100",
        as.character(.data$text_validation_max)
      ),
      text_validation_min = dplyr::if_else(
        is.na(.data$text_validation_min),
        "0",
        as.character(.data$text_validation_min)
      )
    ) |>
    # narrow our focus to the required columns
    dplyr::select(
      c(
        "field_name",
        "form_name",
        "field_type",
        "select_choices_or_calculations",
        "text_validation_min",
        "text_validation_max"
      )
    ) |>
    dplyr::group_by(.data$field_type) |>
    dplyr::mutate(
      weight = 100,
      mean = (as.numeric(.data$text_validation_min) + as.numeric(.data$text_validation_max)) / 2,
      sd = (as.numeric(.data$text_validation_max) - as.numeric(.data$text_validation_min)) / 6
    ) |>
    dplyr::ungroup()

  return(slider_values)
}
