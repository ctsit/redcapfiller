#' @title Get long notes fields from a REDCap data dictionary
#'
#' @description
#' Given a REDCap data dictionary, this function returns the fields (rows) that have a field type of notes.
#'
#' @param metadata A REDCap data dictionary
#'
#' @returns A dataframe with the following columns:
#' \describe{
#'   \item{field_name}{The name of the field.}
#'   \item{form_name}{The form name in which the field is located.}
#'   \item{field_type}{The type of the field (will always be "notes").}
#'   \item{weight}{A uniform weight, set to 100.}
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' notes_fields <- get_notes_fields(metadata_to_populate)
#' }
get_notes_fields <- function(metadata) {
  notes_fields <-
    metadata |>
    # filter to include only notes fields
    dplyr::filter(.data$field_type == "notes") |>
    # select the required columns
    dplyr::select("field_name", "form_name", "field_type") |>
    # add the weight column set to 100
    dplyr::mutate(weight = 100)

  return(notes_fields)
}
