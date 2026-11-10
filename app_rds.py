
import os
import psycopg
from psycopg.rows import dict_row
from pathlib import Path
from flask import Flask, request, redirect, url_for, render_template_string

app = Flask(__name__)

# ==========================================
# DATABASE CONFIGURATION
# ==========================================

def connect_db():
    password = os.environ.get("LIFESCIENCES_DB_PASSWORD")

    if not password:
        raise RuntimeError("Database password is not configured.")

    return psycopg.connect(
        host=os.environ.get("LIFESCIENCES_DB_HOST", "127.0.0.1"),
        port=int(os.environ.get("LIFESCIENCES_DB_PORT", "15432")),
        dbname="lifesciences",
        user="lifesciences_app",
        password=password,
        sslmode="require",
        connect_timeout=10,
        row_factory=dict_row
    )


# ==========================================
# HOME PAGE AND SAMPLE REGISTRATION
# ==========================================

@app.route("/", methods=["GET", "POST"])
def home():

    error = None

    if request.method == "POST":

        sample_id = request.form.get("sample_id", "").strip()
        experiment = request.form.get("experiment", "").strip()
        sample_type = request.form.get("sample_type", "").strip()
        researcher = request.form.get("researcher", "").strip()
        status = request.form.get("status", "").strip()

        # Validate form fields
        if not all([
            sample_id,
            experiment,
            sample_type,
            researcher,
            status
        ]):
            error = "Please fill in all fields."

        elif (
            len(sample_id) > 50
            or len(experiment) > 150
            or len(researcher) > 100
            or sample_type not in ("RNA", "DNA", "Protein", "Other")
            or status not in ("Pending", "In Progress", "Completed")
        ):
            error = "Invalid sample information."

        else:

            connection = connect_db()

            try:
                connection.execute("""
                    INSERT INTO samples (
                        sample_id,
                        experiment,
                        sample_type,
                        researcher,
                        status
                    )
                    VALUES (%s, %s, %s, %s, %s)
                """, (
                    sample_id,
                    experiment,
                    sample_type,
                    researcher,
                    status
                ))

                connection.commit()

                return redirect(url_for("home", saved=1))

            except psycopg.errors.UniqueViolation:
                connection.rollback()
                error = "This Sample ID already exists."

            finally:
                connection.close()

    # Retrieve all registered samples
    connection = connect_db()

    try:
        samples = connection.execute("""
            SELECT *
            FROM samples
            ORDER BY sample_id
        """).fetchall()

    finally:
        connection.close()

    return render_template_string("""

    <!DOCTYPE html>
    <html lang="en">

    <head>

        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1">

        <title>Life Sciences Sample Tracker</title>

        <style>

            body {
                font-family: Arial, sans-serif;
                background: #f3f6fa;
                margin: 35px auto;
                max-width: 950px;
                padding: 0 16px;
            }

            h1 {
                color: #17365d;
            }

            h2 {
                color: #243b53;
            }

            .panel {
                background: white;
                padding: 25px;
                border-radius: 10px;
                margin-bottom: 25px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            }

            input, select {
                display: block;
                box-sizing: border-box;
                width: 100%;
                padding: 10px;
                margin: 8px 0 16px;
                border: 1px solid #ccc;
                border-radius: 5px;
            }

            button {
                padding: 12px 22px;
                background: #1765b3;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
            }

            button:hover {
                background: #104c87;
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            th, td {
                border: 1px solid #ddd;
                padding: 12px;
                text-align: left;
            }

            th {
                background: #e8eef7;
            }

            .success {
                color: green;
                font-weight: bold;
            }

            .error {
                color: red;
                font-weight: bold;
            }

            .table-container {
                overflow-x: auto;
            }

        </style>

    </head>

    <body>

        <h1>Life Sciences Research Sample Tracker</h1>

        <p>Laboratory Sample Management System</p>

        <div class="panel">

            <h2>Register New Sample</h2>

            {% if saved %}
                <p class="success">
                    Sample saved successfully!
                </p>
            {% endif %}

            {% if error %}
                <p class="error">
                    {{ error }}
                </p>
            {% endif %}

            <form method="POST">

                <label>Sample ID</label>

                <input
                    type="text"
                    name="sample_id"
                    placeholder="Example: SMP-001"
                    maxlength="50"
                    required
                >

                <label>Experiment Name</label>

                <input
                    type="text"
                    name="experiment"
                    placeholder="Example: RNA Stability Study"
                    maxlength="150"
                    required
                >

                <label>Sample Type</label>

                <select name="sample_type">
                    <option value="RNA">RNA</option>
                    <option value="DNA">DNA</option>
                    <option value="Protein">Protein</option>
                    <option value="Other">Other</option>
                </select>

                <label>Researcher Name</label>

                <input
                    type="text"
                    name="researcher"
                    placeholder="Example: Researcher A"
                    maxlength="100"
                    required
                >

                <label>Experiment Status</label>

                <select name="status">
                    <option value="Pending">Pending</option>
                    <option value="In Progress">In Progress</option>
                    <option value="Completed">Completed</option>
                </select>

                <button type="submit">
                    Save Sample
                </button>

            </form>

        </div>

        <div class="panel">

            <h2>Registered Samples</h2>

            <div class="table-container">

                <table>

                    <tr>
                        <th>Sample ID</th>
                        <th>Experiment</th>
                        <th>Sample Type</th>
                        <th>Researcher</th>
                        <th>Status</th>
                    </tr>

                    {% for s in samples %}

                    <tr>
                        <td>{{ s["sample_id"] }}</td>
                        <td>{{ s["experiment"] }}</td>
                        <td>{{ s["sample_type"] }}</td>
                        <td>{{ s["researcher"] }}</td>
                        <td>{{ s["status"] }}</td>
                    </tr>

                    {% else %}

                    <tr>
                        <td colspan="5">
                            No samples registered yet.
                        </td>
                    </tr>

                    {% endfor %}

                </table>

            </div>

        </div>

    </body>

    </html>

    """,
        samples=samples,
        error=error,
        saved=request.args.get("saved") == "1"
    )


# ==========================================
# APPLICATION HEALTH CHECK
# ==========================================

@app.route("/health")
def health():

    return {
        "status": "healthy",
        "application": "Life Sciences Sample Tracker"
    }, 200


# ==========================================
# DATABASE READINESS CHECK
# ==========================================

@app.route("/ready")
def ready():

    try:
        connection = connect_db()

        try:
            # Verify that the sample database table is available
            connection.execute(
                "SELECT 1 FROM samples LIMIT 1"
            ).fetchone()

        finally:
            connection.close()

        return {
            "database": "connected",
            "status": "ready"
        }, 200

    except psycopg.Error:

        return {
            "database": "unavailable",
            "status": "not_ready"
        }, 503


# ==========================================
# START APPLICATION
# ==========================================

if __name__ == "__main__":

    app.run(
        host="127.0.0.1",
        port=5000,
        debug=False
    )
