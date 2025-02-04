#' @title Generate notes field content
#' @description
#' Generate lorem ipsum text content for each notes field in the provided metadata
#'
#' @param long_notes_fields A dataframe of notes fields from a REDCap data dictionary
#'   (typically output from `get_long_notes_fields()`)
#'
#' @return A tall dataframe of notes field content with one row per field
#' @export
#'
#' @examples
#' \dontrun{
#' notes_responses <- get_long_notes_field_values(notes_fields)
#' }
get_long_notes_field_values <- function(long_notes_fields) {
  notes_responses <- long_notes_fields |>
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
