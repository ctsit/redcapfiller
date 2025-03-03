#' @title generate text field values
#' @description
#' Provide a set of values for each field in the output of
#' `get_long_text_fields`
#'
#' @param long_text_fields a long data set of text
#'   fields, their parameters, and weights.
#'
#' @return a long dataframe of text field values with one row for each value set.
#' @export
#'
#' @importFrom lubridate today now
#'
#' @examples
#' \dontrun{
#' get_long_text_field_values(long_text_fields)
#' }
get_long_text_field_values <- function(long_text_fields) {
  tvt_na <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_na") |>
      dplyr::mutate(value = sapply(seq_len(nrow(df)), function(i) {
        # Ensure the generated value is valid
        n_words <- max(1, round(stats::rnorm(
          n = 1,
          mean = df$mean[i],
          sd = df$sd[i]
        )))
        as.character(paste(lorem::ipsum_words(n_words), collapse = " "))
      }))
  }

  tvt_datetime <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_datetime") |>
      dplyr::mutate(value = {
        anchor_time <- eval(parse(text = .data$origin_function))
        # Generate random times around anchor_time
        times <- as.POSIXct(
          stats::rnorm(
            n = nrow(df),
            mean = as.numeric(anchor_time),
            sd = .data$sd # Using summarized value
          ),
          origin = "1970-01-01"
        )
        # Convert to character in ISO format
        format(times, "%Y-%m-%d %H:%M:%S")
      })
  }

  tvt_date <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_date") |>
      dplyr::mutate(value = {
        anchor_date <- eval(parse(text = .data$origin_function))
        # Generate random dates around anchor date
        dates <- as.Date(
          stats::rnorm(
            n = nrow(df),
            mean = as.numeric(anchor_date),
            sd = .data$sd
          ),
          origin = "1970-01-01"
        )
        # Convert to character in ISO format based on the date format
        format(dates, "%Y-%m-%d")
      })
  }

  tvt_email <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_email") |>
      dplyr::mutate(
        value = as.character(replicate(
          length(.data$field_name),
          paste0(lorem::ipsum_words(1), "@example.org")
        ))
      )
  }

  rtnorm <- function(n, mean, sd, a = NA, b = NA) {
    a <- as.numeric(a)
    b <- as.numeric(b)
    a <- ifelse(is.na(a), -Inf, a)
    b <- ifelse(is.na(b), Inf, b)
    stats::qnorm(stats::runif(n, stats::pnorm(a, mean, sd), stats::pnorm(b, mean, sd)), mean, sd)
  }

  tvt_integer <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_integer") |>
      dplyr::mutate(
        value = as.character(round(rtnorm(
          n = length(.data$field_name), mean = .data$mean, sd = .data$sd,
          a = .data$text_validation_min, b = .data$text_validation_max
        )))
      )
  }

  tvt_number <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_number") |>
      dplyr::mutate(
        value = as.character(round(rtnorm(
          n = length(.data$field_name), mean = .data$mean, sd = .data$sd,
          a = .data$text_validation_min, b = .data$text_validation_max
        ), digits = 2))
      )
  }

  tvt_zipcode <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_zipcode") |>
      dplyr::mutate(
        value = "32611"
      )
  }

  tvt_phone <- function(df) {
    df |>
      dplyr::filter(.data$tvt == "tvt_phone") |>
      dplyr::mutate(
        value = "800-867-5309"
      )
  }


  tvt_types <- c(
    "tvt_na", "tvt_datetime", "tvt_date",
    "tvt_email", "tvt_integer", "tvt_number",
    "tvt_zipcode", "tvt_phone"
  )

  process_one_text_validation_type <- function(my_tvt, df) {
    # exec (run) the function named in `alert` on the rows of data that
    #  have an alert_type of `alert`
    result <- rlang::exec(my_tvt, df |>
      dplyr::filter(.data$tvt == my_tvt))
    return(result)
  }

  text_field_values <-
    purrr::map(
      tvt_types,
      process_one_text_validation_type,
      long_text_fields |> dplyr::filter(.data$field_type == "text")
    ) |>
    # get rid of empty data frames in the list output
    purrr::keep(~ nrow(.x) > 0)

  # If the list is empty after filtering, create a minimal empty data frame
  if (length(text_field_values) == 0) {
    text_field_values <- dplyr::tibble(field_name = character(0), value = character(0))
  } else {
    # Otherwise, combine all data frames in the list
    text_field_values <- dplyr::bind_rows(text_field_values)
  }

  result <- text_field_values |>
    dplyr::select("field_name", "value")

  return(result)
}
