# redcapfiller 0.1.0.9002 (released TBD)
*   Works on **classic projects** and **longitudinal projects**.
*   Uses the REDCap API to read the project design and write the generated data.
*   Fills categorical fields (providing a uniform random distribution).
*   Fills unvalidated text fields and fields with common text validation types: date, datetime, email, integer, number, phone, and zipcode.
    *   Provides random-normal distributions for numeric and date fields.
    *   Uses "Lorem ipsum" text for non-validated text fields. 
    *   Injects simple default randomness where practicable for other types.
*   Leaves the form completed fields set to 'Incomplete' (red).
*   Does not violate basic data constraints defined in the data dictionary (e.g., validation types, ranges where applicable).
*   Populates specified events in longitudinal projects.
*   Fills a specified number of records.
