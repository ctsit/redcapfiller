% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_one_rectangle_of_values.R
\name{get_one_rectangle_of_values}
\alias{get_one_rectangle_of_values}
\title{Generate a rectangle of data for one record}
\usage{
get_one_rectangle_of_values(
  one_record_id = 1,
  record_id_name,
  forms_to_fill,
  fields_and_responses,
  event_name = NA_character_
)
}
\arguments{
\item{one_record_id}{a single record_id}

\item{record_id_name}{the column name the record_id should be returned in}

\item{forms_to_fill}{the forms to fill for this rectangle}

\item{fields_and_responses}{the output of \code{\link[=get_text_fields]{get_text_fields()}},
\code{\link[=get_slider_fields]{get_slider_fields()}}, \code{\link[=get_notes_fields]{get_notes_fields()}},  and
\code{\link[=get_categorical_field_responses]{get_categorical_field_responses()}} functions}

\item{event_name}{event name to include as a column after record_id;
default NA_character_. If NA, omit column for compatibility.}
}
\value{
A rectangle of data with appropriate REDCap identifiers ready
to write to REDCap
}
\description{
Generate a rectangle of data for one record
}
\examples{
\dontrun{
get_one_rectangle_of_values(1, record_id_name, forms_to_fill)
}
}
\keyword{Internal}
