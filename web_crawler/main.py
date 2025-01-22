import argparse
from datetime import datetime

from utils import check_existing_folder, plvr_crawler


def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Crawl and process real estate data.")
    parser.add_argument(
        "--save_to_gcs",
        action="store_true",
        help="Save data to Google Cloud Storage. If not specified, saves locally.",
    )
    args = parser.parse_args()

    # `save_to_gcs` will be True if the flag is provided, otherwise False
    save_to_gcs = args.save_to_gcs
    # if have folder: then incremental mental run, otherwise: first run.
    incremental_run = check_existing_folder(
        folder_name="plvr",
        prefix="data",
        save_to_gcs=save_to_gcs,
        bucket_name="tw-real-estate",
    )

    now = datetime.now()
    current_year = now.year
    current_season = (now.month - 1) // 3 + 1
    last_year = current_year - 1 if current_season == 1 else current_year
    last_season = 4 if current_season == 1 else current_season

    if incremental_run:
        # Incremental run: Use current year and season as the last crawled
        print("Existing data found. Performing incremental crawl.")

        # Crawl new data if applicable
        print(f"Starting from {last_year}-Q{last_season}...")
        plvr_crawler(last_year, last_season, save_to_gcs=save_to_gcs)
    else:
        # First run: Start from 2013-Q1
        print("No existing data found. Performing historical crawl.")
        start_year = 2013
        start_season = 1

        print(
            f"Crawling data from {start_year}-Q{start_season} to {last_year}-Q{last_season}..."
        )
        year, season = start_year, start_season
        while (year, season) <= (last_year, last_season):
            plvr_crawler(year, season, save_to_gcs)
            season += 1
            if season > 4:
                season = 1
                year += 1


if __name__ == "__main__":
    main()
