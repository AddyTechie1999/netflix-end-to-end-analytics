import pandas as pd
df = pd.read_csv('Data/netflix-movies-tv-shows.csv')

from sqlalchemy import create_engine

# MySQL connection
engine = create_engine(
    "mysql+pymysql://root:Aditya%401999@localhost:3306/netflix"
)

# Write DataFrame to MySQL table 'netflix_raw'
df.to_sql('netflix_raw', engine, if_exists="append", index=False)
print("Data successfully loaded into table 'netflix_raw' in database 'netflix'.")