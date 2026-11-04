# import.R
# Rebuilds the filtered New Orleans files from the raw Yelp Open Dataset.
# Raw JSON files are NOT in this repo (several GB). Download them first (see README)
# and extract them so the paths below exist.

library(tidyverse)
library(jsonlite)

business_file <- "data/raw/Yelp JSON/yelp_dataset/yelp_academic_dataset_business.json"
review_file   <- "data/raw/Yelp JSON/yelp_dataset/yelp_academic_dataset_review.json"

dir.create("data/new_orleans", recursive = TRUE, showWarnings = FALSE)

# ---- 1. Businesses: small enough to load whole ----------------------------
business_raw <- stream_in(file(business_file), verbose = FALSE)

business <- business_raw |>
  select(business_id, name, address, city, state, postal_code,
         latitude, longitude, stars, review_count, categories)

# ---- 2. Filter to New Orleans restaurants ---------------------------------
new_orleans_restaurants <- business |>
  filter(
    state == "LA",
    city == "New Orleans",
    !is.na(categories),
    str_detect(categories, regex("Restaurants", ignore_case = TRUE))
  ) |>
  mutate(
    postal_code   = na_if(postal_code, ""),
    categories    = str_squish(categories),
    business_name = str_squish(name)
  ) |>
  distinct(business_id, .keep_all = TRUE)

saveRDS(new_orleans_restaurants,
        "data/new_orleans/business_new_orleans.rds",
        compress = "xz")

# ---- 3. Reviews: read the 5.3 GB file in chunks ----------------------------
# Only reviews for the restaurants above are kept, so the full file is never
# held in memory. Lower pagesize if R runs out of memory.
ids <- new_orleans_restaurants$business_id
chunks <- list()
chunk_number <- 0

keep_new_orleans <- function(df) {
  chunk_number <<- chunk_number + 1
  chunks[[chunk_number]] <<- df |>
    dplyr::filter(business_id %in% ids) |>
    dplyr::select(business_id, user_id, stars, date, text, useful, funny, cool)
}

stream_in(file(review_file), handler = keep_new_orleans,
          pagesize = 50000, verbose = TRUE)

reviews <- bind_rows(chunks)

# ---- 4. Save ---------------------------------------------------------------
# Full file (with review text) is about 112 MB, over GitHub's 100 MB limit, so
# it is listed in .gitignore and kept local only.
saveRDS(reviews, "data/new_orleans/reviews_new_orleans.rds", compress = "gzip")

# Text-free copy (all reviews, no text column) is small enough to commit.
saveRDS(select(reviews, -text),
        "data/new_orleans/reviews_new_orleans_no_text.rds",
        compress = "xz")