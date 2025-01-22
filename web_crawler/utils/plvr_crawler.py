import io
import os
import zipfile

import requests
from google.cloud import storage


def full_to_half_width(s):
    return s.translate(str.maketrans("０１２３４５６７８９", "0123456789"))


def upload_to_gcs(bucket_name, destination_blob_name, content):
    """Upload a file to a GCS bucket."""
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_string(content, content_type="text/csv")
    print(f"Uploaded to gs://{bucket_name}/{destination_blob_name}")


def save_locally(local_path, filename, content):
    """Save the content to a local file."""
    os.makedirs(local_path, exist_ok=True)
    file_path = os.path.join(local_path, filename)
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Saved locally to {file_path}")


def plvr_crawler(year, season, save_to_gcs=False):
    # Tranlate to Taiwanese year
    taiwan_year = year - 1911 if year > 1000 else year
    url = f"https://plvr.land.moi.gov.tw//DownloadSeason?season={taiwan_year}S{season}&type=zip&fileName=lvr_landcsv.zip"
    # download real estate zip content
    response = requests.get(url)

    # Check if the request was successful
    if response.status_code == 200:
        # Create a ZipFile object from the response content
        with zipfile.ZipFile(io.BytesIO(response.content)) as z:
            # Iterate through each file in the zip
            for file_info in z.infolist():
                # Check if the file is a CSV
                if file_info.filename.endswith(".csv"):
                    # Extract the CSV file content
                    with z.open(file_info) as csv_file:
                        # Save the CSV file to disk
                        content = csv_file.read().decode("utf-8")
                        converted_content = full_to_half_width(content)
                        if save_to_gcs:
                            # Save to GCS
                            destination_blob_name = (
                                f"plvr/{year}Q{season}/{file_info.filename}"
                            )
                            upload_to_gcs(
                                "tw-real-estate",
                                destination_blob_name,
                                converted_content,
                            )
                        else:
                            # Save locally
                            local_path = f"plvr/{year}Q{season}"
                            save_locally(
                                local_path, file_info.filename, converted_content
                            )
    else:
        print(f"Failed to download file: {response.status_code}")


def get_last_crawled_season():
    """Determine the latest crawled year and season based on existing folders."""
    if not os.path.exists("data"):
        return None, None

    existing_folders = [
        folder
        for folder in os.listdir("data")
        if os.path.isdir(os.path.join("data", folder)) and "-" in folder
    ]
    if not existing_folders:
        return None, None

    # Extract year-season pairs and find the latest
    existing_seasons = sorted(
        [
            (int(folder.split("-")[0]), int(folder.split("-")[1][1:]))
            for folder in existing_folders
        ],
        reverse=True,
    )
    return existing_seasons[0]
