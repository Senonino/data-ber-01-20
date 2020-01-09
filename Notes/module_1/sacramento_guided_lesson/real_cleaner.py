#!/usr/bin/env python3

import csv
import re
import argparse

class RealCleaner():
    def __init__(self, path):
        self._path = path
        self.unprocessed_data = self._load_csv()
        self.processed_data = self._process_data()

    def _load_csv(self):
        data = []
        with open(self._path) as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                data.append(dict(row))
        return data

    @staticmethod
    def _parse_year(date_string):
        year_pattern = r"\d{4}$"
        return re.findall(year_pattern, date_string)[0]

    @staticmethod
    def _parse_day(date_string):
        day_pattern = r"\s(\d{1,2})\s"
        return re.findall(day_pattern, date_string)[0]

    @staticmethod
    def _parse_month(date_string):
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        month_pattern = r"\w{3}\s(\w{3})\s"
        
        month_name = re.findall(month_pattern, date_string)[0]
        return str(months.index(month_name) + 1).rjust(2, "0")

    def _parse_date(self, date_string):
        return self._parse_year(date_string)+"-"+self._parse_month(date_string)+"-"+self._parse_day(date_string)

    def _process_row(self, row):
        conversion = {"city": lambda x: x.capitalize(),
                        "zip": int,
                        "beds": int,
                        "baths": int,
                        "sq__ft": int,
                        "sale_date": self._parse_date,
                        "price": int,
                        "latitude": float,
                        "longitude": float}

        new_sample = {}
        for key, value in row.items():
            if key in conversion.keys():
                new_sample[key.replace("__", "_")] = conversion[key](value)
            else:
                new_sample[key.replace("__", "_")] = value
                
        return new_sample
    
    def _process_data(self):
        return [self._process_row(row) for row in self.unprocessed_data]

    def to_csv(self, out_path):
        with open(out_path, "w") as outfile:
            headers = list(self.processed_data[0].keys())
            writer = csv.DictWriter(outfile, fieldnames=headers)
            
            writer.writeheader()
            for row in self.processed_data:
                writer.writerow(row)

    def to_list(self, stage="processed"):
        if stage == "processed":
            return self.processed_data
        elif stage == "unprocessed":
            return self.unprocessed_data
        
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("from_path", help="path to input file")
    parser.add_argument("to_path", help="path to output file")
    args = parser.parse_args()
    data = RealCleaner(args.from_path)
    data.to_csv(args.to_path)
