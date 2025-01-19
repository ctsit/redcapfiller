#' @title Get every categorical field response from a REDCap data dictionary
#'
#' @description
#' Given a REDCap data dictionary, enumerate every response value for every categorical field in that data dictionary
#'
#' @param metadata A REDCap data dictionary
#'
#' @returns a dataframe with these columns
#' \describe{
#'   \item{field_name}{First item}
#'   \item{field_type}{Second item}
#'   \item{response_code}{Second item}
#'   \item{response_label}{Second item}
#'   \item{field_group}{Second item}
#'   \item{weight}{a set of uniform weights across the responses of each field}
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' long_categorical_field_responses <-
#'   get_long_categorical_field_responses(metadata_to_populate)
#' }
get_long_categorical_field_responses <- function(metadata) {
  balanced_responses <-
    metadata |>
    # include only categorical field types
    dplyr::filter(.data$field_type %in% c("checkbox", "radio", "dropdown", "truefalse", "yesno")) |>
    # excluding anything displayed by branching logic
    dplyr::filter(is.na(.data$branching_logic)) |>
    # narrow our focus to the required columns
    dplyr::select(c("field_name", "form_name", "field_type", "select_choices_or_calculations")) |>
    dplyr::mutate(select_choices_or_calculations = dplyr::case_when(
      .data$field_type == "truefalse" ~ "1, True|0, False",
      .data$field_type == "yesno" ~ "1, Yes|0, No",
      TRUE ~ .data$select_choices_or_calculations)
      ) |>
    # separate responses
    tidyr::separate_longer_delim("select_choices_or_calculations", delim = stringr::regex("\\s?\\|\\s?")) |>
    # separate response_codes from response_labels
    tidyr::separate_wider_delim("select_choices_or_calculations",
      delim = ", ",
      names = c("response_code", "response_label"),
      too_many = "merge",
      too_few = "align_start"
    ) |>
    # apply one-hot encoding to checkbox fields, but leave others unmodified
    dplyr::mutate(
      field_group = .data$field_name,
      field_name = dplyr::if_else(
        .data$field_type == "checkbox",
        paste0(.data$field_name, "___", .data$response_code),
        .data$field_name
      ),
      response_code = dplyr::if_else(
        .data$field_type == "checkbox",
        "1",
        .data$response_code
      )
    ) |>
    # set weights for each response
    dplyr::group_by(.data$field_group) |>
    dplyr::mutate(weight = round(100 / dplyr::n(), digits = 0)) |>
    dplyr::ungroup()

  return(balanced_responses)
}
