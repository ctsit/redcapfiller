#' @title Generate notes field content
#' @description
#' Generate lorem ipsum text content for each notes field in `notes_fields`
#'
#' @param notes_fields A long dataframe of notes fields from a REDCap data dictionary
#'   (typically output from [get_notes_fields()])
#'
#' @return A tall dataframe of notes field content with one row per field
#' @keywords Internal
#'
#' @examples
#' \dontrun{
#' notes_responses <- get_notes_field_values(notes_fields)
#' }
get_notes_field_values <- function(notes_fields) {
  notes_responses <- notes_fields |>
    # Ensure we're only working with notes fields
    dplyr::filter(.data$field_type == "notes") |>
    # Generate lorem ipsum text for each field
    dplyr::mutate(
      value = purrr::map_chr(
        .data$field_name,
        ~ lorem::ipsum(1, avg_words_per_sentence = 6) |>
          as.character()
      )
    ) |>
    # Select relevant columns
    dplyr::select("field_name", "value")

  return(notes_responses)
}
