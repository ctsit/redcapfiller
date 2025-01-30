#' @title Get every text field response from a REDCap data dictionary
#'
#' @description
#' Given a REDCap data dictionary, enumerate every text field in that data dictionary and return a dataset with default weights
#'
#' @param metadata A REDCap data dictionary
#'
#' @returns a dataframe with these columns
#' \describe{
#'   \item{field_name}{REDCap field name}
#'   \item{form_name}{REDCap form name}
#'   \item{field_type}{REDCap field type}
#'   \item{text_validation_type}{REDCap text validation type}
#'   \item{text_validation_min}{REDCap text validation min}
#'   \item{text_validation_max}{REDCap text validation max}
#'   \item{tvt}{text validation type function name}
#'   \item{weight}{a default weight for the field}
#'   \item{mean}{mean of data to be generated}
#'   \item{sd}{standard deviation of data to be generated}
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' long_text_fields <-
#'   get_long_text_fields(metadata_to_populate)
#' }
get_long_text_fields <- function(metadata) {
  text_fields <-
    metadata |>
    # include only categorical field types
    dplyr::filter(.data$field_type %in% c("text")) |>
    # excluding anything displayed by branching logic
    dplyr::filter(is.na(.data$branching_logic)) |>
    # narrow our focus to the required columns
    dplyr::select(c(
      "field_name",
      "form_name",
      "field_type",
      "text_validation_type_or_show_slider_number",
      "text_validation_min",
      "text_validation_max"
    )) |>
    dplyr::rename(text_validation_type = "text_validation_type_or_show_slider_number") |>
    dplyr::mutate(tvt = dplyr::case_when(
      is.na(.data$text_validation_type) ~ "tvt_na",
      TRUE ~ "tvt_unsupported"
    )) |>
    # set weights for each response
    dplyr::mutate(weight = 100)

  tvt_na <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(is.na(.data$text_validation_type)) |>
      dplyr::mutate(mean = 1.5, sd = 0.8)
    return(result)
  }

  tvt_unsupported <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(F)
    return(result)
  }

  tvt_types <- c(
    "tvt_na",
    "tvt_unsupported"
  )

  process_one_text_validation_type <- function(my_tvt, df) {
    # exec (run) the function named in `alert` on the rows of data that
    #  have an alert_type of `alert`
    result <- rlang::exec(my_tvt, df |>
      dplyr::filter(.data$tvt == my_tvt))
    return(result)
  }

  text_fields_and_weights <-
    purrr::map(tvt_types, process_one_text_validation_type, text_fields) |>
    dplyr::bind_rows()

  return(text_fields_and_weights)
}
