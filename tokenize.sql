-- Create your database
CREATE DATABASE IF NOT EXISTS ${YOURNAMEHERE} LOCATION 'adl://azuretestdrivedata.azuredatalakestore.net/user-data/${YOURNAMEHERE}/db';

use ${YOURNAMEHERE};

-- Create intermediate_access_logs table, drop if exists first
drop table if exists intermediate_access_logs;
CREATE EXTERNAL TABLE intermediate_access_logs (
    ip STRING,
    date STRING,
    method STRING,
    url STRING,
    http_version STRING,
    code1 STRING,
    code2 STRING,
    dash STRING,
    user_agent STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    'input.regex' = '([^ ]*) - - \\[([^\\]]*)\\] "([^\ ]*) ([^\ ]*) ([^\ ]*)" (\\d*) (\\d*) "([^"]*)" "([^"]*)"',
    'output.format.string' = "%1$$s %2$$s %3$$s %4$$s %5$$s %6$$s %7$$s %8$$s %9$$s")
LOCATION 'adl://azuretestdrivedata.azuredatalakestore.net/altus-retail-demo/data/original_access_logs';

use ${YOURNAMEHERE};

-- Create tokenized_access_logs table, drop if exists first
drop table if exists tokenized_access_logs;
CREATE EXTERNAL TABLE tokenized_access_logs (
    ip STRING,
    date STRING,
    method STRING,
    url STRING,
    http_version STRING,
    code1 STRING,
    code2 STRING,
    dash STRING,
    user_agent STRING)
stored as parquet
LOCATION 'adl://azuretestdrivedata.azuredatalakestore.net/user-data/${YOURNAMEHERE}/tokenized_access_logs';

INSERT OVERWRITE TABLE tokenized_access_logs SELECT * FROM intermediate_access_logs;
