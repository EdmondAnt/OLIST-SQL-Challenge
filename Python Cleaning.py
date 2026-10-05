import pandas as pd

# Load raw file and re-export with clean, uniform formatting
df = pd.read_csv(
    r"C:\Dev\Python Projects\OLIST Project\data\olist_order_reviews_dataset.csv"
)
df.to_csv(
    r"C:\Dev\Python Projects\OLIST Project\data\olist_order_reviews_clean.csv",
    index=False, encoding= "UTF-8"
)