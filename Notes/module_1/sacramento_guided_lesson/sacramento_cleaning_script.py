import csv
import re

data = []
with open("Sacramentorealestatetransactions.csv") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        data.append(dict(row))

def parse_year(date_string):
    year_pattern = r"\d{4}$"
    return re.findall(year_pattern, date_string)[0]

def parse_day(date_string):
    day_pattern = r"\s(\d{1,2})\s"
    return re.findall(day_pattern, date_string)[0]

def parse_month(date_string):
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    month_pattern = r"\w{3}\s(\w{3})\s"
    
    month_name = re.findall(month_pattern, date_string)[0]
    return str(months.index(month_name) + 1).rjust(2, "0")

def parse_date(date_string):
    return parse_year(date_string)+"-"+parse_month(date_string)+"-"+parse_day(date_string)

def process_row(row):
    conversion = {"city": lambda x: x.capitalize(),
              "zip": int,
              "beds": int,
              "baths": int,
              "sq__ft": int,
              "sale_date": parse_date,
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

data_clean = [process_row(row) for row in data]

with open("sacramento_clean.csv", "w") as outfile:
    headers = list(data_clean[0].keys())
    writer = csv.DictWriter(outfile, fieldnames=headers)
    
    writer.writeheader()
    for row in data_clean:
        writer.writerow(row)
