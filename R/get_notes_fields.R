#' @title Get notes fields from a REDCap data dictionary and annotate them with weights
#'
#' @description
#' Given a REDCap data dictionary, this function returns the rows that have a field type of _notes_.
#'
#' @param metadata A REDCap data dictionary
#'
#' @returns A long dataframe with the following columns:
#' \describe{
#'   \item{field_name}{The name of the field.}
#'   \item{form_name}{The form name in which the field is located.}
#'   \item{field_type}{The type of the field (this will always be _notes_).}
#'   \item{weight}{A uniform weight, set to 100.}
#' }
#'
#' @keywords Internal
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
