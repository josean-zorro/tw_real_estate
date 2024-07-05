import io
import os
import zipfile

import requests


def full_to_half_width(s):
    return s.translate(str.maketrans("０１２３４５６７８９", "0123456789"))


def plvr_crawler(year, season):
    # Tranlate to Taiwanese year
    if year > 1000:
        year -= 1911

    # download real estate zip content
    response = requests.get(
        "https://plvr.land.moi.gov.tw//DownloadSeason?season="
        + str(year)
        + "S"
        + str(season)
        + "&type=zip&fileName=lvr_landcsv.zip"
    )

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
                        save_path = "./csv_files"
                        os.makedirs(save_path, exist_ok=True)
                        with open(
                            os.path.join(save_path, file_info.filename),
                            "w",
                            encoding="utf-8",
                        ) as f:
                            f.write(converted_content)
    else:
        print(f"Failed to download file: {response.status_code}")


# plvr_crawler(111, 2)
