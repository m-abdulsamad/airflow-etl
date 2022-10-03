**Context**

This project aims at creating an analytics data pipeline for an online B2B company which is used by companies to sell products and has many front-facing users across the globe.

**Tools Used**
- Python
- Postgres 
- SQL
- Apache Airflow (for orchestration)
- Apache Superset (for reporting and visualization)

**Data Pipeline Architecture**

![Alt text](/blob/arch.jpg?raw=true)

In the architecture diagram above is a simple ETL design where there is a B2B platform relational database (more on this in the Data Model section) and the weblog data from the webserver that are fed to the transformation layer. The transformation layer is responsible for manipulating the data into meaningful data which is then used for reporting and visualization (more on this in the Reports section). Data Mart has been chosen as the target data store as it is more targetted towards the end goal i.e create reports. 

For both the source and the data mart, Postgres is used as the relational database. The transformation layer involves Python and SQL scripting and all of the moving pieces are glued together using Apache Airflow which is an orchestration tool. Finally once the data is in the data mart, Apache Superset is used for visualization and reporting.

**Data Model**

Below is the ER diagram of how the B2B source database looks like:
![Alt text](/blob/data_model.jpg?raw=true)

Below is the ER diagram of how the data mart database looks like:

![Alt text](/blob/data_mart_data_model.jpg?raw=true)

**Airflow DAG**

![Alt text](/blob/airflow_dag.png?raw=true)
Below is the breakdown of each task in the Airflow DAG:
- create_source_db: It is a SQL script for creating the database tables, if not already created, mentioned in the Data Model section.
- populate_source_db: It is a SQL script for populating the source database with data.
- make_executable: It is a Bash command for making the `logs/generator.sh` script executable.
- generate_weblogs: It is a Bash script for generating Apache logs in the combined log format `"%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\""`. 
This Bash script uses `log-generator` (a pypi package) for generating logs. More on `log-generator` [here](https://pypi.org/project/log-generator/).
- parse_weblogs: It is a Python function which receives the generated logs as input, parses them and inserts them to the source database. 
- create_data_mart: It is a SQL script for creating the data mart tables, if not already created.
- populate_data_mart: It is a SQL script which reads the data from the source database (which now includes the log data as well) and inserts new data into the tables. The tables in the data mart are based on the Reports. 

_Note_: Airflow besides being an orchestration tool provides many features out of the box like restarts on job failure, track metadata of the ETL/ELT pipeline and has the ability to scale. 

**Code Structure**

- blob: It contains the static images used in the README file.
- dags: It contains the `main.py` file which is the starting point of the project and holds the DAG for the ETL. It also contains a `sql` folder which holds all the SQL scripts.    
- logs: It contains an executable `generator.sh` which is responsible for generating logs. The script uses `config.yml` file to generate the logs. More on `config.yml` [here](https://pypi.org/project/log-generator/). A sample log file is included as well.
- requirements.txt: It contains all the Python dependencies required for this project. If for some reason the deps are not installed properly through the `requirements.txt` file, manual installations can be done. Airflow can be installed [locally](https://airflow.apache.org/docs/apache-airflow/stable/start/local.html) and `log-generator` can be installed using `pip install log-generator`.

**Reports**

The data mart is the foundation for these reports :
- What are the most popular used devices for B2B clients (top 5).
- What are the most popular products in the country from which most users log into.
- All sales of B2B platform displayed monthly for the last year.

`devices_used_for_logging`, `sales_per_month` and `popular_products_in_most_logged_in_country` tables are used respectively for these reports.
![Alt text](/blob/dashboard.png?raw=true)

