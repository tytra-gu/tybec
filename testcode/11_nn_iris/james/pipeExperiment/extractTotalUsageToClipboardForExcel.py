from __future__ import print_function
import os
import json
import pandas as pd

file_of_interest = "lib/json/summary.json"
info_file = "lib/json/info.json"


def getAvailableResources(json):
    for child in json["estimatedResources"]["children"]:
        if child["name"] == "Available":
            return child["data"]


def number_of_pipes_selector(json):
    for row in json["rows"]:
        if row["name"] == "Project Name":
            return int(row["data"][0].split("_")[2])


def summary_percentage_selector(json):
    for child in json["estimatedResources"]["children"]:
        if child["name"] == "Total":
            return child["data_percent"]


def summary_value_selector(json):
    for child in json["estimatedResources"]["children"]:
        if child["name"] == "Total":
            return child["data"]


def getAllResultFolders(baseFolder):

    results = []

    for root, subdirs, _ in os.walk(baseFolder):
        for subdir in subdirs:
            if subdir.endswith("reports"):
                results.append(os.path.join(root, subdir))

    return results


def getJson(path):
    with open(path) as file:
        data = json.load(file)

    return data


table = []

for result in getAllResultFolders(os.getcwd()):

    full_summary_path = os.path.join(result, file_of_interest)
    full_info_path = os.path.join(result, info_file)

    row_as_list = [number_of_pipes_selector(getJson(full_info_path))]

    abs_values = summary_value_selector(getJson(full_summary_path))

    total_available = getAvailableResources(getJson(full_summary_path))

    # summary_percentage_selector(getJson(full_summary_path))
    percentage_values = [
        channelResources/float(total) for channelResources, total in zip(abs_values, total_available)]

    for i in range(4):
        row_as_list.append(abs_values[i])
        row_as_list.append(percentage_values[i])

    print(row_as_list)

    table.append(row_as_list)


df = pd.DataFrame(data=table, columns=[
    "No. of Pipes", "ALUTs", "ALUTs %", "FFs", "FFs %", "RAMs", "RAMs %", "DSPs", "DSPs %"])

df.sort_values(by=["No. of Pipes"], inplace=True)

print(df)

df.to_clipboard(index=False)
raw_input(
    "The data has been copied to your clipboard ready for you to paste into excel...")
