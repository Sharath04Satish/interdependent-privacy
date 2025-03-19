import geoip2.database
import pandas as pd
from tqdm import tqdm

def is_ip_addr_from_usa(ip_address):
    with geoip2.database.Reader(db_path) as reader:
        try:
            response = reader.country(ip_address)
            return response.country.iso_code == "US"
        except:
            return False

db_path = "../datasets/GeoLite2-Country.mmdb"
df = pd.read_csv("../datasets/data_25_03_17.csv")

print("Extracting location of participant from IP addresses.")
ip_addrs = df["IPAddress"].to_list()[2:]
res = ["IP Address Flag", ""]
for addr in tqdm(ip_addrs):
    if is_ip_addr_from_usa(addr):
        res.append(True)
    else:
        res.append(False)

if "IpAddressFlag" in df.columns:
    df = df.drop(columns=["IPAddressFlag"])
df["IpAddressFlag"] = res

df.to_csv("../datasets/dataset_2025_03_17_ip.csv", index=False)
print("Extraction completed.")
