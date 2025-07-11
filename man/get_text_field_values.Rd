% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_text_field_values.R
\name{get_text_field_values}
\alias{get_text_field_values}
\title{Generate text field values}
\usage{
get_text_field_values(text_fields)
}
\arguments{
\item{text_fields}{A long dataframe of text
fields, their parameters, and weights.}
}
\value{
A long dataframe of text field values with one row for each value set.
}
\description{
Generate values for each field in \code{text_fields}. This function addresses
all the text validation types
}
\examples{
\dontrun{
get_text_field_values(text_fields)
}
}
\keyword{Internal}
