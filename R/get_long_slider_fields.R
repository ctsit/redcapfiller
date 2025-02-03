#' @title Get slider field ranges from a REDCap data dictionary
#'
#' @description
#' Given a REDCap data dictionary, enumerate range of values for every slider field in that data dictionary
#'
#' @param metadata A REDCap data dictionary
#'
#' @returns a dataframe with these columns
#' \describe{
#'   \item{field_name}{REDCap field name}
#'   \item{form_name}{REDCap form name}
#'   \item{field_type}{REDCap field type}
#'   \item{select_choices_or_calculations}{RedCap select_choices_or_calculations field}
#'   \item{text_validation_min}{REDCap text validation min}
#'   \item{text_validation_max}{REDCap text validation max}
#'   \item{mean}{mean of data to be generated}
#'   \item{sd}{standard deviation of data to be generated}
#'
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' long_slider_fields <-
#'   get_long_slider_fields(metadata_to_populate)
#' }
get_long_slider_fields <- function(metadata) {
  long_slider_values <- metadata |>
    # include only slider field types
    dplyr::filter(.data$field_type == "slider") |>
    dplyr::group_by(.data$field_name) |>
    tidyr::separate_longer_delim("select_choices_or_calculations",
                                 delim = stringr::regex("\\s?\\|\\s?")) |>
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
      mean = mean(
        c(as.numeric(.data$text_validation_min), as.numeric(.data$text_validation_max)),
        na.rm = TRUE
      ),
      sd = (as.numeric(.data$text_validation_max) - as.numeric(.data$text_validation_min)) / 6
    ) |>
    dplyr::ungroup()

  return(long_slider_values)
}


