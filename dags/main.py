
from datetime import datetime, timedelta

from airflow import DAG

from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonVirtualenvOperator
from airflow.operators.postgres_operator import PostgresOperator


def parse_logs(file: str) -> None:
    """
    Imports for virtual env
    """
    import re
    import pandas as pd
    import httpagentparser
    from sqlalchemy import create_engine
    PG_SOURCE_DB_CONN_STR = "postgresql://asamad:admin@localhost:5432/source_db"

    data_arr = []
    with open(file) as log:
        for line in log.readlines():
            match = re.match(r'(?P<ip>.*?) (?P<remote_log_name>.*?) (?P<userid>.*?) \[(?P<date>.*?)(?= ) (?P<timezone>.*?)\] \"(?P<request_method>.*?) (?P<path>.*?)(?P<request_version> HTTP\.*)?\" (?P<status>.*?) (?P<length>.*?) (?P<referrer>.*?) \"(?P<user_agent>.*?)\"', line)
            if match:
                user_agent = match.group(12)
                agent = httpagentparser.detect(user_agent)
                device = None
                if agent.get('dist', None):
                    device = agent['dist']['name']
                else:
                    device = agent['os']['name']
                data_arr.append([match.group(1), match.group(3), match.group(4), device ,user_agent])
    print(data_arr)
    data = pd.DataFrame(data_arr, columns=['ip', 'username', 'time', 'device', 'user_agent'])
    data['time'] = pd.to_datetime(data.time, format="%d-%m-%Y:%H:%M:%S")

    engine = create_engine(PG_SOURCE_DB_CONN_STR)
    data.to_sql(name='logs', con=engine, if_exists='append', method='multi', index=False)
    

dag = DAG(
    'b2b-sql-etl',
    default_args={
        'depends_on_past': False,
        'email': ['airflow@example.com'],
        'email_on_failure': True,
        'email_on_retry': False,
        'retries': 3,
        'retry_delay': timedelta(seconds=30),
        'sla': timedelta(hours=1),
    },
    schedule_interval='@daily',
    start_date=datetime(2022, 1, 1),
    catchup=False
)

create_source_db = PostgresOperator(
    dag=dag,
    task_id="create_source_db",
    postgres_conn_id='pg_source_db_conn_id', #this conn string is set in the UI in Admin -> Connections section
    sql="sql/create_source_db.sql",
)

populate_source_db = PostgresOperator(
    dag=dag,
    task_id="populate_source_db",
    postgres_conn_id='pg_source_db_conn_id', #this conn string is set in the UI in Admin -> Connections section
    sql="sql/populate_source_db.sql",
)

make_log_generator_script_executable = BashOperator(
    task_id='make_executable',
    bash_command='chmod u+x /home/abdulsamad/Documents/repos/sql-etl/logs/generator.sh ',
)

generate_weblogs = BashOperator(
    dag=dag,
    task_id='generate_weblogs',
    bash_command='/home/abdulsamad/Documents/repos/sql-etl/logs/generator.sh ',
)

_parse_weblogs = PythonVirtualenvOperator(
    dag=dag,
    task_id='parse_weblogs',
    system_site_packages=False,
    python_callable=parse_logs,
    requirements=['virtualenv==20.16.3', 'pandas==1.4.3', 'httpagentparser==1.9.3', 'sqlalchemy==1.4.40', 'psycopg2-binary==2.9.3'],
    op_args=['/home/abdulsamad/Documents/repos/sql-etl/logs/weblogs.log']
)

create_data_mart = PostgresOperator(
    dag=dag,
    task_id="create_data_mart",
    postgres_conn_id='pg_data_mart_conn_id', #this conn string is set in the UI in Admin -> Connections section
    sql="sql/create_data_mart.sql",
)

populate_data_mart = PostgresOperator(
    dag=dag,
    task_id="populate_data_mart",
    postgres_conn_id='pg_data_mart_conn_id', #this conn string is set in the UI in Admin -> Connections section
    sql="sql/populate_data_mart.sql",
)

[create_source_db, populate_source_db] >> make_log_generator_script_executable >> generate_weblogs >> _parse_weblogs >> [create_data_mart, populate_data_mart]