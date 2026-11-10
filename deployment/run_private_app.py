import os
import json
import boto3
from waitress import serve

client = boto3.client(
    "secretsmanager",
    region_name="ap-southeast-2"
)

response = client.get_secret_value(
    SecretId="lifesciences/lab/app-db"
)

secret = json.loads(response["SecretString"])

if secret.get("username") != "lifesciences_app" or not secret.get("password"):
    raise RuntimeError("Invalid database credentials")

os.environ["LIFESCIENCES_DB_PASSWORD"] = secret["password"]
os.environ["LIFESCIENCES_DB_HOST"] = (
    "lifesciences-postgres-lab.czqgk8q0u3ee."
    "ap-southeast-2.rds.amazonaws.com"
)
os.environ["LIFESCIENCES_DB_PORT"] = "5432"

from app_rds import app

serve(app, host="127.0.0.1", port=8080, threads=4)
