library(testthat)
library(mockery)

# Helper for mocked REDCapR API output based on project credentials
redcap_api_mocker <- function(redcap_uri, token, what = "classic") {
  if (what == "classic") {
    project_info <- list(data = list(
      is_longitudinal = FALSE,
      has_repeating_instruments_or_events = FALSE,
      randomization_enabled = FALSE
    ))
    event_info <- NULL
    event_mapping <- NULL
  } else if (what == "longitudinal") {
    project_info <- list(data = list(
      is_longitudinal = TRUE,
      has_repeating_instruments_or_events = FALSE,
      randomization_enabled = FALSE
    ))
    event_info <- data.frame(
      unique_event_name = c("event_1_arm_1", "event_2_arm_1"),
      event_name = c("Event 1", "Event 2"),
      stringsAsFactors = FALSE
    )
    event_mapping <- data.frame(
      unique_event_name = c("event_1_arm_1", "event_2_arm_1"),
      form = c("form_a", "form_a"),
      stringsAsFactors = FALSE
    )
  }

  # Mock metadata
  metadata <- data.frame(
    field_name = c("record_id", "field1"),
    form_name = c("form_a", "form_a"),
    field_type = c("text", "text"),
    branching_logic = c(NA, NA),
    stringsAsFactors = FALSE
  )

  # Mock dataset
  redcap_data <- data.frame(record_id = integer(0), field1 = character(0), stringsAsFactors = FALSE)
  read_result <- list(data = redcap_data)

  list(
    redcap_project_info_read = function(...) project_info,
    redcap_metadata_read = function(...) list(data = metadata),
    redcap_read = function(...) read_result,
    redcap_event_read = function(...) list(data = event_info),
    redcap_event_instruments = function(...) list(data = event_mapping)
  )
}

test_that("get_project_values returns correct structure for classic project", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "classic")

  # Patch REDCapR functions
  stub(get_project_values, "REDCapR::redcap_project_info_read", api$redcap_project_info_read)
  stub(get_project_values, "REDCapR::redcap_metadata_read", api$redcap_metadata_read)
  stub(get_project_values, "REDCapR::redcap_read", api$redcap_read)

  # Patch helpers
  stub(get_project_values, "get_long_categorical_field_responses", function(...) data.frame())
  stub(get_project_values, "get_long_text_fields", function(...) data.frame())
  stub(get_project_values, "get_long_slider_fields", function(...) data.frame())
  stub(get_project_values, "get_long_notes_fields", function(...) data.frame())
  stub(get_project_values, "get_one_rectangle_of_values", function(...) data.frame(record_id = 1, field1 = "foo"))

  result <- get_project_values("dummy_uri", "dummy_token", number_of_records_to_populate = 1)

  expect_type(result, "list")
  expect_true(is.data.frame(result[[1]]))
  expect_equal(nrow(result[[1]]), 1) # one record
})

test_that("get_project_values returns correct structure for longitudinal project", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "longitudinal")
  stub(get_project_values, "REDCapR::redcap_project_info_read", api$redcap_project_info_read)
  stub(get_project_values, "REDCapR::redcap_metadata_read", api$redcap_metadata_read)
  stub(get_project_values, "REDCapR::redcap_read", api$redcap_read)
  stub(get_project_values, "REDCapR::redcap_event_read", api$redcap_event_read)
  stub(get_project_values, "REDCapR::redcap_event_instruments", api$redcap_event_instruments)

  stub(get_project_values, "get_long_categorical_field_responses", function(...) data.frame())
  stub(get_project_values, "get_long_text_fields", function(...) data.frame())
  stub(get_project_values, "get_long_slider_fields", function(...) data.frame())
  stub(get_project_values, "get_long_notes_fields", function(...) data.frame())
  stub(get_project_values, "get_one_rectangle_of_values", function(...) data.frame(record_id = 1, field1 = "bar"))

  result <- get_project_values("dummy_uri", "dummy_token")

  expect_type(result, "list")
  expect_length(result, 2) # two events
  expect_true(all(vapply(result, is.data.frame, logical(1))))
})

test_that("get_project_values errors if repeating instruments/events", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "classic")
  repeating_project_info <- list(data = list(
    is_longitudinal = FALSE,
    has_repeating_instruments_or_events = TRUE,
    randomization_enabled = FALSE
  ))
  stub(get_project_values, "REDCapR::redcap_project_info_read", function(...) repeating_project_info)
  stub(get_project_values, "REDCapR::redcap_metadata_read", api$redcap_metadata_read)
  stub(get_project_values, "REDCapR::redcap_read", api$redcap_read)

  expect_error(
    get_project_values("dummy_uri", "dummy_token"),
    "repeating instruments/events are not supported"
  )
})

test_that("get_project_values errors if randomization enabled", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "classic")
  randomized_project_info <- list(data = list(
    is_longitudinal = FALSE,
    has_repeating_instruments_or_events = FALSE,
    randomization_enabled = TRUE
  ))
  stub(get_project_values, "REDCapR::redcap_project_info_read", function(...) randomized_project_info)
  stub(get_project_values, "REDCapR::redcap_metadata_read", api$redcap_metadata_read)
  stub(get_project_values, "REDCapR::redcap_read", api$redcap_read)

  expect_error(
    get_project_values("dummy_uri", "dummy_token"),
    "randomization enabled are not supported"
  )
})

test_that("get_project_values errors on empty redcap_uri", {
  expect_error(
    get_project_values("", "token"),
    "Assertion on 'redcap_uri' failed"
  )
})

test_that("get_project_values errors on empty token", {
  expect_error(
    get_project_values("uri", ""),
    "Assertion on 'token' failed"
  )
})

test_that("get_project_values errors on events non-character", {
  expect_error(
    get_project_values("uri", "token", events = 123),
    "Assertion on 'events' failed"
  )
})

test_that("get_project_values errors on invalid number_of_records_to_populate", {
  expect_error(
    get_project_values("uri", "token", number_of_records_to_populate = 0),
    "Assertion on 'number_of_records_to_populate' failed"
  )
  expect_error(
    get_project_values("uri", "token", number_of_records_to_populate = -1),
    "Assertion on 'number_of_records_to_populate' failed"
  )
  expect_error(
    get_project_values("uri", "token", number_of_records_to_populate = NA),
    "Assertion on 'number_of_records_to_populate' failed"
  )
})

test_that("get_project_values starts record_id after max existing id", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "classic")
  existing <- data.frame(record_id = 1:10, field1 = rep("foo", 10), stringsAsFactors = FALSE)
  stub(get_project_values, "REDCapR::redcap_project_info_read", api$redcap_project_info_read)
  stub(get_project_values, "REDCapR::redcap_metadata_read", api$redcap_metadata_read)
  stub(get_project_values, "REDCapR::redcap_read", function(...) list(data = existing))

  stub(get_project_values, "get_long_categorical_field_responses", function(...) data.frame())
  stub(get_project_values, "get_long_text_fields", function(...) data.frame())
  stub(get_project_values, "get_long_slider_fields", function(...) data.frame())
  stub(get_project_values, "get_long_notes_fields", function(...) data.frame())

  captured_ids <- c()
  stub(get_project_values, "get_one_rectangle_of_values", function(record_id, ...) {
    captured_ids <<- c(captured_ids, record_id)
    data.frame(record_id = record_id, field1 = "foo")
  })

  get_project_values("dummy_uri", "dummy_token", number_of_records_to_populate = 1)
  expect_true(any(unlist(captured_ids) == 11))
})

test_that("get_project_values filters longitudinal events if 'events' is provided", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "longitudinal")

  stub(get_project_values, "REDCapR::redcap_project_info_read", api$redcap_project_info_read)
  stub(get_project_values, "REDCapR::redcap_metadata_read", api$redcap_metadata_read)
  stub(get_project_values, "REDCapR::redcap_read", api$redcap_read)
  stub(get_project_values, "REDCapR::redcap_event_read", api$redcap_event_read)
  stub(get_project_values, "REDCapR::redcap_event_instruments", api$redcap_event_instruments)

  stub(get_project_values, "get_long_categorical_field_responses", function(...) data.frame())
  stub(get_project_values, "get_long_text_fields", function(...) data.frame())
  stub(get_project_values, "get_long_slider_fields", function(...) data.frame())
  stub(get_project_values, "get_long_notes_fields", function(...) data.frame())

  called_events <- c()
  stub(get_project_values, "get_one_rectangle_of_values", function(..., event_name = NA_character_) {
    called_events <<- c(called_events, event_name)
    data.frame(record_id = 1, field1 = "x")
  })

  get_project_values("dummy_uri", "dummy_token", events = "event_2_arm_1")
  expect_true(all(called_events == "event_2_arm_1"))
})

test_that("get_project_values returns correct number of records per event (longitudinal)", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "longitudinal")
  stub(get_project_values, "REDCapR::redcap_project_info_read", api$redcap_project_info_read)
  stub(get_project_values, "REDCapR::redcap_metadata_read", api$redcap_metadata_read)
  stub(get_project_values, "REDCapR::redcap_read", api$redcap_read)
  stub(get_project_values, "REDCapR::redcap_event_read", api$redcap_event_read)
  stub(get_project_values, "REDCapR::redcap_event_instruments", api$redcap_event_instruments)

  stub(get_project_values, "get_long_categorical_field_responses", function(...) data.frame())
  stub(get_project_values, "get_long_text_fields", function(...) data.frame())
  stub(get_project_values, "get_long_slider_fields", function(...) data.frame())
  stub(get_project_values, "get_long_notes_fields", function(...) data.frame())
  stub(get_project_values, "get_one_rectangle_of_values", function(record_ids, ...) {
    data.frame(record_id = record_ids, field1 = "y")
  })

  res <- get_project_values("dummy_uri", "dummy_token", number_of_records_to_populate = 3)
  expect_true(all(vapply(res, nrow, integer(1)) == 3))
})

test_that("get_project_values returns correct number of records (classic)", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "classic")
  stub(get_project_values, "REDCapR::redcap_project_info_read", api$redcap_project_info_read)
  stub(get_project_values, "REDCapR::redcap_metadata_read", api$redcap_metadata_read)
  stub(get_project_values, "REDCapR::redcap_read", api$redcap_read)

  stub(get_project_values, "get_long_categorical_field_responses", function(...) data.frame())
  stub(get_project_values, "get_long_text_fields", function(...) data.frame())
  stub(get_project_values, "get_long_slider_fields", function(...) data.frame())
  stub(get_project_values, "get_long_notes_fields", function(...) data.frame())
  stub(get_project_values, "get_one_rectangle_of_values", function(record_ids, ...) {
    data.frame(record_id = record_ids, field1 = "z")
  })

  res <- get_project_values("dummy_uri", "dummy_token", number_of_records_to_populate = 2)
  expect_equal(nrow(res[[1]]), 2)
})

test_that("get_project_values returns empty df if forms_to_fill empty", {
  api <- redcap_api_mocker("dummy_uri", "dummy_token", what = "classic")
  stub(get_project_values, "REDCapR::redcap_project_info_read", api$redcap_project_info_read)
  stub(get_project_values, "REDCapR::redcap_metadata_read", function(...) {
    list(data = data.frame(
      field_name = "record_id",
      form_name = "form_a",
      field_type = "text",
      branching_logic = NA_character_,
      stringsAsFactors = FALSE
    ))
  })
  stub(get_project_values, "REDCapR::redcap_read", api$redcap_read)
  stub(get_project_values, "get_long_categorical_field_responses", function(...) data.frame())
  stub(get_project_values, "get_long_text_fields", function(...) data.frame())
  stub(get_project_values, "get_long_slider_fields", function(...) data.frame())
  stub(get_project_values, "get_long_notes_fields", function(...) data.frame())
  stub(get_project_values, "get_one_rectangle_of_values", function(...) data.frame())

  res <- get_project_values("dummy_uri", "dummy_token", number_of_records_to_populate = 1)
  expect_type(res, "list")
  expect_true(is.data.frame(res[[1]]))
  expect_equal(nrow(res[[1]]), 0)
})
