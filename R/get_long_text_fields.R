#' @title Get every text field response from a REDCap data dictionary
#'
#' @description
#' Given a REDCap data dictionary, enumerate every text field in that data dictionary
#' and return a dataset with default weights
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
    dplyr::mutate(
      text_validation_min = as.character(.data$text_validation_min),
      text_validation_max = as.character(.data$text_validation_max)
    ) |>
    dplyr::mutate(tvt = dplyr::case_when(
      is.na(.data$text_validation_type) ~ "tvt_na",
      grepl("^datetime.*", .data$text_validation_type) ~ "tvt_datetime",
      grepl("^date_", .data$text_validation_type) ~ "tvt_date",
      grepl("email", .data$text_validation_type) ~ "tvt_email",
      grepl("integer", .data$text_validation_type) ~ "tvt_integer",
      grepl("number", .data$text_validation_type) ~ "tvt_number",
      grepl("zipcode", .data$text_validation_type) ~ "tvt_zipcode",
      grepl("phone", .data$text_validation_type) ~ "tvt_phone",
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

  tvt_email <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(grepl("email", .data$text_validation_type)) |>
      dplyr::mutate(weight = 100)
    return(result)
  }

  tvt_datetime <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(grepl("^datetime.*", .data$text_validation_type)) |>
      dplyr::mutate(
        text_validation_min = dplyr::case_when(
          grepl("^\\[.*\\]$", .data$text_validation_min) ~ NA_character_,
          grepl("^-?[0-9]+(\\.[0-9]+)?$", .data$text_validation_min) ~ .data$text_validation_min,
          grepl("^\\d{4}-\\d{2}-\\d{2}$", .data$text_validation_min) ~ as.character(.data$text_validation_min),
          TRUE ~ NA_character_
        ),
        text_validation_max = dplyr::case_when(
          grepl("^\\[.*\\]$", .data$text_validation_max) ~ NA_character_,
          grepl("^-?[0-9]+(\\.[0-9]+)?$", .data$text_validation_max) ~ .data$text_validation_max,
          grepl("^\\d{4}-\\d{2}-\\d{2}$", .data$text_validation_max) ~ as.character(.data$text_validation_max),
          TRUE ~ NA_character_
        ),
        origin_function = "lubridate::now()",
        bias = 3600 * 24
      )
    return(result)
  }

  tvt_date <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(grepl("^date_", .data$text_validation_type)) |>
      dplyr::mutate(
        text_validation_min = dplyr::case_when(
          grepl("^\\[.*\\]$", .data$text_validation_min) ~ NA_character_,
          grepl("^-?[0-9]+(\\.[0-9]+)?$", .data$text_validation_min) ~ .data$text_validation_min,
          grepl("^\\d{4}-\\d{2}-\\d{2}$", .data$text_validation_min) ~ as.character(.data$text_validation_min),
          TRUE ~ NA_character_
        ),
        text_validation_max = dplyr::case_when(
          grepl("^\\[.*\\]$", .data$text_validation_max) ~ NA_character_,
          grepl("^-?[0-9]+(\\.[0-9]+)?$", .data$text_validation_max) ~ .data$text_validation_max,
          grepl("^\\d{4}-\\d{2}-\\d{2}$", .data$text_validation_max) ~ as.character(.data$text_validation_max),
          TRUE ~ NA_character_
        ),
        origin_function = "lubridate::today()",
        bias = 36 * 24
      )
    return(result)
  }

  tvt_integer <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(grepl("integer", .data$text_validation_type)) |>
      dplyr::mutate(
        min_val = ifelse(!is.na(as.numeric(.data$text_validation_min)), as.numeric(.data$text_validation_min), 0),
        max_val = ifelse(!is.na(as.numeric(.data$text_validation_max)), as.numeric(.data$text_validation_max), 0),
        mean = (.data$min_val + .data$max_val) / 2,
        sd = (.data$max_val - .data$min_val) / 6
      ) |>
      dplyr::mutate(
        mean = dplyr::if_else(.data$mean == 0, 15, .data$mean),
        sd = dplyr::if_else(.data$sd == 0, 3, .data$sd)
      ) |>
      dplyr::select(-min_val, -max_val)
    return(result)
  }

  tvt_number <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(grepl("number", .data$text_validation_type)) |>
      dplyr::mutate(
        min_val = as.numeric(.data$text_validation_min),
        max_val = as.numeric(.data$text_validation_max)
      ) |>
      dplyr::mutate(
        min_val = dplyr::coalesce(.data$min_val, 0),
        max_val = dplyr::coalesce(.data$max_val, 0),
        mean = (.data$min_val + .data$max_val) / 2,
        sd = (.data$max_val - .data$min_val) / 6
      ) |>
      dplyr::mutate(
        mean = dplyr::if_else(.data$mean == 0, 15, .data$mean),
        sd = dplyr::if_else(.data$sd == 0, 3, .data$sd)
      ) |>
      dplyr::select(-min_val, -max_val)
    return(result)
  }

  tvt_zipcode <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(grepl("zipcode", .data$text_validation_type)) |>
      dplyr::mutate(weight = 100)
    return(result)
  }

  tvt_phone <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(grepl("phone", .data$text_validation_type)) |>
      dplyr::mutate(weight = 100)
    return(result)
  }

  tvt_unsupported <- function(text_fields) {
    result <-
      text_fields |>
      dplyr::filter(F)
    return(result)
  }

  tvt_types <- c(
    "tvt_na", "tvt_datetime", "tvt_unsupported", "tvt_date",
    "tvt_email", "tvt_integer", "tvt_number", "tvt_zipcode",
    "tvt_phone"
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
