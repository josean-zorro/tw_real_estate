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
                            local_path = f"data/plvr/{year}Q{season}"
                            save_locally(
                                local_path, file_info.filename, converted_content
                            )
    else:
        print(f"Failed to download file: {response.status_code}")
    response.close()


def check_existing_folder(
    folder_name="plvr", save_to_gcs=False, bucket_name="tw-real-estate", prefix="data"
):
    """
    Check if a specific folder (year-season) exists either locally or in GCS.

    Args:
        folder_name (str): The folder name to check (e.g., "2024-Q1").
        save_to_gcs (bool): Whether to check in Google Cloud Storage (GCS).
        bucket_name (str): The GCS bucket name (only used if save_to_gcs=True).
        prefix (str): The prefix path in GCS (only used if save_to_gcs=True).

    Returns:
        bool: True if the folder exists, False otherwise.
    """
    if save_to_gcs:
        # Check in GCS
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        gcs_prefix = f"{prefix}/{folder_name}/"
        blobs = list(bucket.list_blobs(prefix=gcs_prefix))
        return len(blobs) > 0  # Folder exists if there are any blobs under this prefix
    else:
        # Check locally
        local_path = os.path.join(prefix, folder_name)
        return os.path.exists(local_path) and os.path.isdir(local_path)
