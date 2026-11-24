
import os
import json
import boto3
from waitress import serve

# AWS configuration
AWS_REGION = "us-east-1"
SECRET_NAME = "prem-intern-1st-project/app-db"

# Retrieve application database credentials
client = boto3.client(
    "secretsmanager",
    region_name=AWS_REGION
)

response = client.get_secret_value(
    SecretId=SECRET_NAME
)

secret = json.loads(response["SecretString"])

# Validate required database settings
required = ["host", "port", "dbname", "username", "password"]

missing = [key for key in required if not secret.get(key)]

if missing:
    raise RuntimeError(
        f"Missing database settings: {', '.join(missing)}"
    )

if secret["username"] == "dbadmin":
    raise RuntimeError("Do not use the RDS master user for the application.")

# Provide database settings to Flask
os.environ["LIFESCIENCES_DB_HOST"] = str(secret["host"])
os.environ["LIFESCIENCES_DB_PORT"] = str(secret["port"])
os.environ["LIFESCIENCES_DB_NAME"] = str(secret["dbname"])
os.environ["LIFESCIENCES_DB_USER"] = str(secret["username"])
os.environ["LIFESCIENCES_DB_PASSWORD"] = str(secret["password"])

# Start the Flask application
from app_rds import app

serve(
    app,
    host="127.0.0.1",
    port=8080,
    threads=4
)
