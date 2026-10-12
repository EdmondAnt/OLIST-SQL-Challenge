import pandas as pd

# Load raw file and re-export with clean, uniform formatting
df = pd.read_csv(
    r"PATH"
)
df.to_csv(
    r"PATH",
    index=False, encoding= "UTF-8"
)