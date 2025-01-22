import argparse

from utils.plvr_crawler import plvr_crawler

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Crawl and process real estate data.")
    parser.add_argument(
        "--save_to_gcs",
        action="store_true",
        help="Save data to Google Cloud Storage. If not specified, saves locally.",
    )
    args = parser.parse_args()

    # Determine mode based on the argument
    save_to_gcs = args.save_to_gcs
    year = 2022
    season = 1
    plvr_crawler(year, season, save_to_gcs=save_to_gcs)
