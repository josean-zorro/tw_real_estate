import io
import os
import zipfile
from datetime import date, timedelta

import pandas as pd
import requests
from google.cloud import storage


def get_past_quarter_dates_ending_with_1():
    today = date.today()
    year = today.year

    # Determine the current quarter
    quarter_start_month = ((today.month - 1) // 3) * 3 + 1

    # Define the start date of the quarter
    start_date = date(year, quarter_start_month, 1)

    # Collect all past dates ending in "1"
    dates = [
        start_date + timedelta(days=i)
        for i in range((today - start_date).days + 1)
        if (start_date + timedelta(days=i)).day % 10 == 1
    ]

    # Exclude the last one before today
    if dates:
        dates.pop()  # Remove the last date in the list

    return dates


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


def plvr_historical_crawler(year, season, save_to_gcs=False):
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
                        # Remove first line
                        converted_content = "\n".join(converted_content.split("\n")[1:])
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


def plvr_this_quarter_crawler(save_to_gcs=False):
    today = date.today()
    year = today.year
    quarter = (today.month - 1) // 3 + 1
    base_url_zip = (
        "http://plvr.land.moi.gov.tw/Download?type=zip&fileName=lvr_landcsv.zip"
    )
    base_url_history = (
        "http://plvr.land.moi.gov.tw/DownloadHistory?type=history&fileName="
    )

    past_dates = get_past_quarter_dates_ending_with_1()
    file_data_map = {}

    for date_obj in past_dates:
        date_str = f"{date_obj.year}{date_obj.month:02}{date_obj.day:02}"
        history_url = f"{base_url_history}{date_str}"

        for url in [base_url_zip, history_url]:
            response = requests.get(url)

            if response.status_code == 200:
                with zipfile.ZipFile(io.BytesIO(response.content)) as z:
                    for file_info in z.infolist():
                        if file_info.filename.endswith(".csv"):
                            with z.open(file_info) as csv_file:
                                content = csv_file.read().decode("utf-8")
                                converted_content = "\n".join(
                                    content.split("\n")[1:]
                                )  # Remove header

                                df = pd.read_csv(io.StringIO(converted_content))
                                if file_info.filename not in file_data_map:
                                    file_data_map[file_info.filename] = [df]
                                else:
                                    file_data_map[file_info.filename].append(df)
            else:
                print(f"Failed to download from {url}: {response.status_code}")

            response.close()

    unioned_dir = f"data/plvr/{year}Q{quarter}"
    os.makedirs(unioned_dir, exist_ok=True)

    for filename, dfs in file_data_map.items():
        unioned_df = pd.concat(dfs, ignore_index=True)
        unioned_path = os.path.join(unioned_dir, filename)
        print(f"Unioned file saved: {unioned_dir}")

        if save_to_gcs:
            upload_to_gcs(
                "tw-real-estate",
                f"plvr/{year}Q{quarter}/{filename}",
                unioned_df.to_csv(index=False),
            )
        else:
            unioned_df.to_csv(unioned_path, index=False)
        unioned_df.to_csv(unioned_path, index=False)


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
        gcs_prefix = f"{folder_name}/"
        blobs = list(bucket.list_blobs(prefix=gcs_prefix))
        return len(blobs) > 0  # Folder exists if there are any blobs under this prefix
    else:
        # Check locally
        local_path = os.path.join(prefix, folder_name)
        return os.path.exists(local_path) and os.path.isdir(local_path)


plvr_this_quarter_crawler()
