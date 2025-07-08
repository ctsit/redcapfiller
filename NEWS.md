# redcapfiller 0.1.2 (released 2025-07-08)
- Enable Roxygen2 markdown support (@pbchase, #44)
- Reorganize 'Reference' section in pkgdown website (@pbchase, #44)
- Add URL and BugReports to DESCRIPTION (@pbchase)
- Add contributors to DESCRIPTION and CITATION.cff (@pbchase, #43)
- Make most functions internal (@pbchase, #42)

# redcapfiller 0.1.1 (released 2025-06-11)
- Fix initial release errors (@pbchase, #36)

# redcapfiller 0.1.0 (released 2025-06-10)
* Initial release (@pbchase, @saipavan10-git, @ljwoodley)
* Works on **classic projects** and **longitudinal projects**.
* Uses the REDCap API to read the project design and write the generated data.
* Fills categorical fields (providing a uniform random distribution).
* Fills unvalidated text fields and fields with common text validation types: date, datetime, email, integer, number, phone, and zipcode.
    * Provides random-normal distributions for numeric and date fields.
    * Uses "Lorem ipsum" text for non-validated text fields. 
    * Injects simple default randomness where practicable for other types.
* Leaves the form completed fields set to 'Incomplete' (red).
* Does not violate basic data constraints defined in the data dictionary (e.g., validation types, ranges where applicable).
* Populates specified events in longitudinal projects.
* Fills a specified number of records.
