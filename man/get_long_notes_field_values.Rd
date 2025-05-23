% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_long_notes_field_values.R
\name{get_long_notes_field_values}
\alias{get_long_notes_field_values}
\title{Generate notes field content}
\usage{
get_long_notes_field_values(long_notes_fields)
}
\arguments{
\item{long_notes_fields}{A dataframe of notes fields from a REDCap data dictionary
(typically output from `get_long_notes_fields()`)}
}
\value{
A tall dataframe of notes field content with one row per field
}
\description{
Generate lorem ipsum text content for each notes field in the provided metadata
}
\examples{
\dontrun{
notes_responses <- get_long_notes_field_values(notes_fields)
}
}
