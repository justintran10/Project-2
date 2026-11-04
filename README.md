# Yelp New Orleans Restaurant Analysis

Portfolio project using the Yelp Open Dataset to study restaurants in New
Orleans. (Research question and findings will be added as the project
progresses.)

## Data

The raw Yelp files are several GB and are **not** stored in this repository.
To reproduce the filtered data:

1. Download the Yelp Open Dataset (JSON) from
   <https://business.yelp.com/data/resources/open-dataset/>.
2. Extract it into `data/raw/` so that the files are at
   `data/raw/Yelp JSON/yelp_dataset/yelp_academic_dataset_business.json` and
   `.../yelp_academic_dataset_review.json`.
3. Run `R/import.R`.

## Filtered data in this repo (`data/new_orleans/`)

- `business_new_orleans.rds`: 2,259 businesses in New Orleans, LA whose
  Yelp categories include "Restaurants".
- `reviews_new_orleans_no_text.rds`: all 476,421 reviews for those
  restaurants, with the review text column removed to keep the file small.

The full file with review text (`reviews_new_orleans.rds`, about 112 MB) is
over GitHub's 100 MB limit, so it is excluded with `.gitignore`.
`R/import.R` recreates it.

## Handling the large data

(Notes on the zip-inside-a-tar download, the OneDrive sync problem, the
chunked read of the 5.3 GB review file, and the file-size limit. To be
expanded in the final report.)

## Files

- `R/import.R`: imports the raw JSON files, filters to New Orleans
  restaurants, and saves the RDS files