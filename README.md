[REDCap Filler](https://github.com/ctsit/redcapfiller)
=======

REDCap Filler provides a testing and development service to users of Vanderbilt University's [REDCap](https://projectredcap.org/). It generates and loads test data into a REDCap project, using the project's design to guide test data generation. This data-driven process allows rapid data creation with minimal effort. This provides a low-cost way to test many of the project features. It provides test data as input for reporting and other downstream processes.

### Installation

The redcapfiller package is only available as source code on GitHub. The easiest way to install it from R or RStudio using the `remotes` package:

```r
install.packages("remotes") # Run this line if the 'remotes' package hasn't been installed already.
remotes::install_github("ctsit/redcapfiller")
```

### Using REDCap Filler

Copy [proof_of_concept.R](https://github.com/ctsit/redcapfiller/blob/main/proof_of_concept.R) to and adapt it to your needs. It will add 5 records to a classic REDCap project identified by `filler_demo_pid` whose credentials are stored in the CSV named in `path_credential` It will fill the variables it knows how to fill.  For more details on how to set up this script, see [Demonstration and Testing procedure](https://ctsit.github.io/redcapfiller/articles/demonstration_and_testing.html)


### Limitations

REDCap Filler does not yet understand all the dimensions of a modern REDCap project. It can fill the categorical fields. It can fill unvalidated text field and the text validation types date, datetime, email, integer, number, phone, and zipcode. It ignores all other field types and validation types and will not attempt to fill them. Filler only knows how to fill classic projects without repeating forms or events. It does not honor form display logic and ignores all fields governed by branching logic.

Focusing more on what Filler _can_ or _will_ do, the first release milestone will support these features:

- Use the REDCap data dictionary as the primary input. Add a few parameters to define record count and forms to fill.
- Work on classic projects with no repeating objects.
- Fill the forms named in a vector of form names.
- Fill out every field on the named forms as long as there is no BL constraint. (Note: Timeline constraints might delay some text validation types)
- Do not violate any data constraints.
- Inject a simple default randomness wherever practicable.
- Set the form completed fields to green.
- Use the REDCap API to read the data dictionary and write the data.
- Provide a uniform distribution on categorical fields.
- Provide normal distribution on numeric and date fields.

### Futures

This project aims to populate complex REDCap projects using the project design. If the REDCap API exposes a design dimension, we plan to use that to guide how the Filler populates projects. Yet, that will take some time to develop fully. This is the proposed timeline of features:

1. Populate all fields in a classic project with no repeating objects, ignoring fields with BL constraints and completely ignoring FDL.
2. Add support for longitudinal projects
3. Complete any text validation types missing in the first release.
3. Add support for repeating events and repeating forms.
4. Allow non-uniform distribution of categorical fields. Allow non-default distributions on ranged fields.
5. Allow inter-record and intra-record date offsets.
6. Add Branching Logic support.
7. Add Form Display Logic support.

### Collaborative development

We encourage input and collaboration.  If you're familiar with GitHub and R packages, submit a [pull request](https://github.com/ctsit/redcapfiller/pulls). If you'd like to report a bug or suggest, please create a GitHub [issue](https://github.com/ctsit/redcapfiller/issues); issues are usually a good place to ask public questions, too. However, email Philip if you prefer an offline dialog (<pbc@ufl.edu>).

We'd like to thank the REDCap Community for their advice and contributions to the design of REDCap Filler.

### Build status

<!-- badges: start -->
[![R-CMD-check](https://github.com/ctsit/redcapfiller/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ctsit/redcapfiller/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->
