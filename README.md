# Structuring of TRACE raw files into a SQLiteDB

Riehl, Kevin and Müller, Lukas 2023
Chair of Corporate Finance, Technical University of Darmstadt, Germany

## Introduction
**Motivation:** The Trade Reporting and Compliance Engine (TRACE) is the FINRA-developed vehicle that facilitates the mandatory reporting of over-the-counter transactions in eligible fixed-income securities. All broker-dealers who are FINRA member firms have an obligation to report transactions in TRACE-eligible securities under an SEC-approved set of rules (https://www.finra.org/filing-reporting/trace). TRACE data can be obtained via traditional vendors (i.e., Wharton Research Data Services, WRDS) or purchased directly from FINRA. TRACE data from FINRA is provided in two variations, namely, "Academic Data" and "Enhanced Historical Data." While the information in the data itself is virtually identical, the data sets exhibit minor differences. 

**Goal:** This code repository allows the recipient to convert the raw data provided by FINRA (Academic Data as well as Enhanced Historical Data) into a SQLiteDB for further analyses using the programming language R. FINRA provides the data in .txt format, where one trading day corresponds to one file. We provide a reproducible solution for processing Academic Data and Enhanced Historical Data, and for merging both data sets to provide a final, cost-efficient database. 

**Benefit:** The resulting SQLiteDB represents the data in a standardized form that can be used for further analysis with simple SQL queries in a variety of applications and programming languages. The resulting database shares template and labeling with WRDS and can therefore seamlessly interface with existing program codes for cleaning the data, e.g., as given in Tidy Finance in R (https://gist.github.com/patrick-weiss/3a05b3ab281563b2e94858451c2eb3a4). 

**The main workflow:** of the data processing takes place in five steps:
```
# Step 1: Start Connection To SQLiteDB File
database_file <- ("bond_trading_data_db.sqlite")
conn <- dbConnect(RSQLite::SQLite(), database_file)
print("SQL connection established...")

# Step 2: Create table schema in SQLiteDB
prepare_database_table(conn)
print("Created table schema...")

# Step 3: Convert downloaded academic data and insert to SQLiteDB
print("Start convert download academic data in final table...")
folder_A <- ("0047-CORP-2013-01-01-2013-12-31_academic")
convert_downloaded_academic_data_to_sqlite_db(conn, folder_A)

# Step 4: Convert downloaded enhanced data and insert to SQLiteDB
print("Start convert download enhanced data in final table...")
zip_file_B <- ("EHDwC 2020.zip")
convert_downloaded_enhanced_data_to_sqlite_db(conn, zip_file_B)

# Step 5: Close Connection to SQLiteDB File
dbDisconnect(conn)
print("Connection closed and database successfully created...")
```

**What you will find here:**
The repository consists of...
- explanations of the data structure of TRACE Academic and Enhanced Historical data offered by FINRA.
- documentation how to use the code implementation in R
- a [ready to run program](https://github.com/DerKevinRiehl/bondTradingDataSqliteDbConverterR/blob/main/code.r) that enables you to convert your data into a database

## Structure of the bond trading data

### Structure of academic data
The academic data is delivered as a set of TXT files in a folder. Each TXT file follows a naming convention and represents trading bond data of a single day, e.g., `0047-corp-academic-trace-data-2013-01-02.txt`.

The TXT files obtain a CSV-like table structure inside with `|` as a separator symbol, and this shows an example of the data:
```
REC_CT_NB|TRD_ST_CD|ISSUE_SYM_ID|CUSIP_ID|RPTG_PARTY_ID|RPTG_PARTY_GVP_ID|PRDCT_SBTP_CD|WIS_DSTRD_CD|NO_RMNRN_CD|ENTRD_VOL_QT|RPTD_PR|YLD_DRCTN_CD|CALCD_YLD_PT|ASOF_CD|TRD_EXCTN_DT|TRD_EXCTN_TM|TRD_RPT_DT|TRD_RPT_TM|TRD_STLMT_DT|TRD_MDFR_LATE_CD|TRD_MDFR_SRO_CD|RPT_SIDE_CD|BUYER_CMSN_AMT|BUYER_CPCTY_CD|SLLR_CMSN_AMT|SLLR_CPCTY_CD|CNTRA_PARTY_ID|CNTRA_PARTY_GVP_ID|LCKD_IN_FL|ATS_FL|SPCL_PR_FL|TRDG_MKT_CD|PBLSH_FL|SYSTM_CNTRL_DT|SYSTM_CNTRL_NB|PREV_TRD_CNTRL_DT|PREV_TRD_CNTRL_NB|FIRST_TRD_CNTRL_DT|FIRST_TRD_CNTRL_NB
1|T|BCS3930817|06740L8C2|d1a9a1444e0922a25d6dc248cc687dd18bc95ea5||CORP|N||3000000.00|100.250000||7.586602||20130102|031500|20130102|080003|20130107|||S|0.00||0.00|A|C|||||S1|Y|20130102|2000000003|||20130102|2000000003
2|T|BCS3930817|06740L8C2|d1a9a1444e0922a25d6dc248cc687dd18bc95ea5||CORP|N||3000000.00|100.250000||7.586602||20130102|031500|20130102|080003|20130107|||B|0.00|A|0.00||C|||||S1|Y|20130102|2000000004|||20130102|2000000004
...
```
### Structure of enhanced data
The enhanced data is delivered as a set of ZIP files in a folder representing a year like `EHDwC 2020.zip`. Each of these ZIP files contains further sub-ZIP files representing single days like `enhanced-time-and-sales-cusip-2020-01-02.zip`. Finally, in these sub-ZIP files you can find TXT files representing the trading bond data of a specific day, like `enhanced-time-and-sales-cusip-2020-01-02.txt`.

```
├── EHDwC 2020.zip
│   └──enhanced-time-and-sales-cusip-2020-01-02.zip
│   |  └── enhanced-time-and-sales-cusip-2020-01-02.txt
│   └──enhanced-time-and-sales-cusip-2020-01-03.zip
│      └── enhanced-time-and-sales-cusip-2020-01-03.txt
...
```

The TXT files obtain a CSV like table structure inside with `|` as a separator symbol, this shows an example of the data:
```
Record Count Num|Reference Number|Trade Status|TRACE Symbol|CUSIP|Bloomberg Identifier|Sub Product|When Issued Indicator|Remuneration|Quantity|Price|Yield Direction|Yield|As Of Indicator|Execution Date|Execution Time|Trade Report Date|Trade Report Time|Settlement Date|Trade Modifier 3|Trade Modifier 4|Buy/Sell Indicator|Buyer Commission|Buyer Capacity|Seller Commission|Seller Capacity|Reporting Party Type|Contra Party Indicator|Locked In Indicator|ATS Indicator|Special Price Indicator|Trading Market Indicator|Dissemination Flag|Prior Trade Report Date|Prior Reference Number|First Trade Control Date|First Trade Control Number
1|0000005|T|SUHJ4887191|G857ABAC4|BBG00GQ7JTK4|CORP|N||350000.00|99.970000|||A|20200101|205505|20200102|080002|20200106|||B|0.00|P|0.00||D|C||||S1|Y|||20200102|0000005
2|0000006|T|SUHJ4887191|G857ABAC4|BBG00GQ7JTK4|CORP|N||350000.00|100.000000|||A|20200101|205505|20200102|080002|20200106|||S|0.00||0.00|P|D|D||||S1|Y|||20200102|0000006
...
```

### Comparison of table structure
As visible from the TXT file structure, the number of columns and column names of academic and enhanced data are not identical but ressemble quite a lot.

| **Academic Data** |                    |         |   | **Enhanced   Data** |                            |        |
|-------------------|--------------------|--------------|---|---------------------|----------------------------|--------------|
| **Nr**            | **Field Name**     | **Example**  |   | **Nr**              | **Field Name**             | **Example**  |
| 1                 | REC_CT_NB          | 1            |   | 1                   | Record.Count.Num           | 1            |
|                   |                    |              |   | 2                   | Reference.Number           | 2            |
| 2                 | TRD_ST_CD          | T            |   | 3                   | Trade.Status               | T            |
| 3                 | ISSUE_SYM_ID       | BCS3930817   |   | 4                   | TRACE.Symbol               | CAT5254597   |
| 4                 | CUSIP_ID           | 06740L8C2    |   | 5                   | CUSIP                      | 14913R2P1    |
|                   |                    |              |   | 6                   | Bloomberg.Identifier       | BBG012F5NQR4 |
| 5                 | RPTG_PARTY_ID      | d1a9a1444e0… |   |                     |                            |              |
| 6                 | RPTG_PARTY_GVP_ID  |              |   |                     |                            |              |
| 7                 | PRDCT_SBTP_CD      | CORP         |   | 7                   | Sub.Product                | CORP         |
| 8                 | WIS_DSTRD_CD       | N            |   | 8                   | When.Issued.Indicator      | N            |
| 9                 | NO_RMNRN_CD        |              |   | 9                   | Remuneration               |              |
| 10                | ENTRD_VOL_QT       | 3000000      |   | 10                  | Quantity                   | 25000,00     |
| 11                | RPTD_PR            | 100.25       |   | 11                  | Price                      | 95,407,000   |
| 12                | YLD_DRCTN_CD       |              |   | 12                  | Yield.Direction            |              |
| 13                | CALCD_YLD_PT       | 7.586602     |   | 13                  | Yield                      | 2,554,416    |
| 14                | ASOF_CD            |              |   | 14                  | As.Of.Indicator            |              |
| 15                | TRD_EXCTN_DT       | 20130102     |   | 15                  | Execution.Date             | 20220401     |
| 16                | TRD_EXCTN_TM       | 31500        |   | 16                  | Execution.Time             | 80002        |
| 17                | TRD_RPT_DT         | 20130102     |   | 17                  | Trade.Report.Date          | 20220401     |
| 18                | TRD_RPT_TM         | 80003        |   | 18                  | Trade.Report.Time          | 80002        |
| 19                | TRD_STLMT_DT       | 20130107     |   | 19                  | Settlement.Date            | 20220405     |
| 20                | TRD_MDFR_LATE_CD   |              |   | 20                  | Trade.Modifier.3           |              |
| 21                | TRD_MDFR_SRO_CD    |              |   | 21                  | Trade.Modifier.4           |              |
| 22                | RPT_SIDE_CD        | S            |   | 22                  | Buy.Sell.Indicator         | B            |
| 23                | BUYER_CMSN_AMT     | 0            |   | 23                  | Buyer.Commission           | 0,00         |
| 24                | BUYER_CPCTY_CD     |              |   | 24                  | Buyer.Capacity             | A            |
| 25                | SLLR_CMSN_AMT      | 0            |   | 25                  | Seller.Commission          | 0,00         |
| 26                | SLLR_CPCTY_CD      | A            |   | 26                  | Seller.Capacity            |              |
| 27                | CNTRA_PARTY_ID     | C            |   | 27                  | Reporting.Party.Type       | D            |
| 28                | CNTRA_PARTY_GVP_ID |              |   | 28                  | Contra.Party.Indicator     | D            |
| 29                | LCKD_IN_FL         |              |   | 29                  | Locked.In.Indicator        |              |
| 30                | ATS_FL             |              |   | 30                  | ATS.Indicator              |              |
| 31                | SPCL_PR_FL         |              |   | 31                  | Special.Price.Indicator    |              |
| 32                | TRDG_MKT_CD        | S1           |   | 32                  | Trading.Market.Indicator   | S1           |
| 33                | PBLSH_FL           | Y            |   | 33                  | Dissemination.Flag         | N            |
| 34                | SYSTM_CNTRL_DT     | 20130102     |   |                     |                            |              |
| 35                | SYSTM_CNTRL_NB     | 2000000003   |   |                     |                            |              |
| 36                | PREV_TRD_CNTRL_DT  |              |   | 34                  | Prior.Trade.Report.Date    | NA           |
| 37                | PREV_TRD_CNTRL_NB  |              |   | 35                  | Prior.Reference.Number     | NA           |
| 38                | FIRST_TRD_CNTRL_DT | 20130102     |   | 36                  | First.Trade.Control.Date   | 20220401     |
| 39                | FIRST_TRD_CNTRL_NB | 2000000003   |   | 37                  | First.Trade.Control.Number | 2            |

### Structure of the final table
In order to work with a merged set of final data, we propose a unified schema for the data is oriented on the academic data. The following table explains the fields of the final table. Capitalized columns are carried over from the original data, and lowercase columns denote variables used in the code available through the functions used to clean and process the data.

| **Final Data** |                      |                       |             |
|----------------|----------------------|-----------------------|-------------|
| **Nr**         | **Field Name**       | **SQLiteDB Datatype** | **Example** |
| 1              | REC_CT_NB            | INTEGER               | 1           | 
| 2              | REF_NB               | INTEGER               | 2           | 
| 3              | trc_st               | TEXT                  | T           | 
| 4              | ISSUE_SYM_ID         | TEXT                  | CAT5254597  | 
| 5              | cusip_id             | TEXT                  | 14913R2P1   | 
| 6              | BLMBRG_ID            | TEXT                  | BBG012F5NQR4| 
| 7              | RPTG_PARTY_ID        | TEXT                  | d1a9a1444e..| 
| 8              | RPTG_PARTY_GVP_ID    | TEXT                  | 12345       | 
| 9              | PRDCT_SBTP_CD        | TEXT                  | CORP        | 
| 10             | wis_fl               | TEXT                  | N           | 
| 11             | NO_RMNRN_CD          | TEXT                  | 12345       | 
| 12             | entrd_vol_qt         | INTEGER               | 3000000     | 
| 13             | rptd_pr              | REAL                  | 100.25      | 
| 14             | YLD_DRCTN_CD         | TEXT                  | 12345       | 
| 15             | yld_pt               | REAL                  | 7.586602    | 
| 16             | asof_cd              | TEXT                  | 12345       | 
| 17             | trd_exctn_dt         | TEXT                  | 20220401    | 
| 18             | trd_exctn_tm         | TEXT                  | 80002       | 
| 19             | trd_rpt_dt           | TEXT                  | 20220401    | 
| 20             | trd_rpt_tm           | TEXT                  | 80002       | 
| 21             | stlmnt_dt            | TEXT                  | 20220405    | 
| 22             | TRD_MDFR_LATE_CD     | TEXT                  |             | 
| 23             | TRD_MDFR_SRO_CD      | TEXT                  |             | 
| 24             | rpt_side_cd          | TEXT                  | B           | 
| 25             | BUYER_CMSN_AMT       | REAL                  | 10.00       | 
| 26             | BUYER_CPCTY_CD       | TEXT                  | A           | 
| 27             | SLLR_CMSN_AMT        | REAL                  | 12.00       | 
| 28             | SLLR_CPCTY_CD        | TEXT                  | 12345       | 
| 29             | RPT_PRTY_ID          | TEXT                  | D           | 
| 30             | cntra_mp_id          | TEXT                  | D           | 
| 31             | CNTRA_PARTY_GVP_ID   | TEXT                  |             | 
| 32             | LCKD_IN_FL           | TEXT                  |             | 
| 33             | ATS_FL               | TEXT                  |             | 
| 34             | spcl_trd_fl          | TEXT                  |             | 
| 35             | TRDG_MKT_CD          | TEXT                  | S1          | 
| 36             | PBLSH_FL             | TEXT                  | N           | 
| 37             | SYSTM_CNTRL_DT       | TEXT                  | 20130102    | 
| 38             | SYSTM_CNTRL_NB       | TEXT                  | 2000000003  | 
| 39             | pr_trd_dt            | TEXT                  | 20130103    | 
| 40             | PREV_TRD_CNTRL_NB    | TEXT                  |             | 
| 41             | FIRST_TRD_CNTRL_DT   | TEXT                  | 20130105    | 
| 42             | FIRST_TRD_CNTRL_NB   | INTEGER               | 2           | 
| 43             | msg_seq_nb           | TEXT                  | AC_2000000003 | 
| 44             | orig_msg_seq_nb      | TEXT                  | AC_2        | 
| 45             | days_to_sttl_ct      | INTEGER               | 4 (days between stlmnt_dt and trd_exectn_dt) | 


## Documentation of code

### get_data_definition()
This function returns certain definitions, based on 'what' you request (e.g. 'columns_string', 'separator', 'db_fields', 'db_fields_int', 'db_fields_real', 'table_name') and for what kind of 'type' (can be 'academic', 'enhanced' 'final'). This is a helping function for other functions. 
- **Example Input:** `get_data_definition("table_name", "final");")`
- **Example Output:** `"bond_table_final_data"`
- **Explanation of output:** this request asks for the table_name used in the SQLiteDb for the final dataset.
```
get_data_definition <- function(what, type) {
  if(type=="academic") {
    if(what=="columns_string") {
      return("REC_CT_NB|TRD_ST_CD|ISSUE_SYM_ID|CUSIP_ID|RPTG_PARTY_ID|RPTG_PARTY_GVP_ID|PRDCT_SBTP_CD|WIS_DSTRD_CD|NO_RMNRN_CD|ENTRD_VOL_QT|RPTD_PR|YLD_DRCTN_CD|CALCD_YLD_PT|ASOF_CD|TRD_EXCTN_DT|TRD_EXCTN_TM|TRD_RPT_DT|TRD_RPT_TM|TRD_STLMT_DT|TRD_MDFR_LATE_CD|TRD_MDFR_SRO_CD|RPT_SIDE_CD|BUYER_CMSN_AMT|BUYER_CPCTY_CD|SLLR_CMSN_AMT|SLLR_CPCTY_CD|CNTRA_PARTY_ID|CNTRA_PARTY_GVP_ID|LCKD_IN_FL|ATS_FL|SPCL_PR_FL|TRDG_MKT_CD|PBLSH_FL|SYSTM_CNTRL_DT|SYSTM_CNTRL_NB|PREV_TRD_CNTRL_DT|PREV_TRD_CNTRL_NB|FIRST_TRD_CNTRL_DT|FIRST_TRD_CNTRL_NB");
    }
    else if(what=="separator") {
      return("|")
    }
    else if(what=="db_fields") {
      return(strsplit(get_data_definition("columns_string", type), split=get_data_definition("separator", type), fixed=TRUE)[[1]]);
    }
    else if(what=="db_fields_int") {
      return(list("REC_CT_NB", "ENTRD_VOL_QT", "BUYER_CMSN_AMT", "SLLR_CMSN_AMT"))
    }
    else if(what=="db_fields_real") {
      return(list("RPTD_PR", "CALCD_YLD_PT"))
    }
    else { # table_name
      return("bond_table_academic_data")
    }
  }
  else if(type=="enhanced") {
    if(what=="columns_string") {
      return("Record Count Num|Reference Number|Trade Status|TRACE Symbol|CUSIP|Bloomberg Identifier|Sub Product|When Issued Indicator|Remuneration|Quantity|Price|Yield Direction|Yield|As Of Indicator|Execution Date|Execution Time|Trade Report Date|Trade Report Time|Settlement Date|Trade Modifier 3|Trade Modifier 4|Buy/Sell Indicator|Buyer Commission|Buyer Capacity|Seller Commission|Seller Capacity|Reporting Party Type|Contra Party Indicator|Locked In Indicator|ATS Indicator|Special Price Indicator|Trading Market Indicator|Dissemination Flag|Prior Trade Report Date|Prior Reference Number|First Trade Control Date|First Trade Control Number");
    }
    else if(what=="separator") {
      return("|")
    }
    else if(what=="db_fields") {
      return(strsplit(get_data_definition("columns_string", type), split=get_data_definition("separator", type), fixed=TRUE)[[1]]);
    }
    else if(what=="db_fields_int") {
      return(list("Record Count Num"))
    }
    else if(what=="db_fields_real") {
      return(list("Quantity", "Price", "Buyer Commission", "Seller Commission", "Yield"))
    }
    else { # table_name
      return("bond_table_enhanced_data")
    }
  }
  else { #if(type=="final")
    if(what=="columns_string") {
	  return("REC_CT_NB|REF_NB|trc_st|ISSUE_SYM_ID|cusip_id|BLMBRG_ID|RPTG_PARTY_ID|RPTG_PARTY_GVP_ID|PRDCT_SBTP_CD|wis_fl|NO_RMNRN_CD|entrd_vol_qt|rptd_pr|YLD_DRCTN_CD|yld_pt|asof_cd|trd_exctn_dt|trd_exctn_tm|trd_rpt_dt|trd_rpt_tm|stlmnt_dt|TRD_MDFR_LATE_CD|TRD_MDFR_SRO_CD|rpt_side_cd|BUYER_CMSN_AMT|BUYER_CPCTY_CD|SLLR_CMSN_AMT|SLLR_CPCTY_CD|RPT_PRTY_ID|cntra_mp_id|CNTRA_PARTY_GVP_ID|LCKD_IN_FL|ATS_FL|spcl_trd_fl|TRDG_MKT_CD|PBLSH_FL|SYSTM_CNTRL_DT|SYSTM_CNTRL_NB|pr_trd_dt|PREV_TRD_CNTRL_NB|FIRST_TRD_CNTRL_DT|FIRST_TRD_CNTRL_NB|msg_seq_nb|orig_msg_seq_nb|days_to_sttl_ct");
    }
    else if(what=="separator") {
      return("|")
    }
    else if(what=="db_fields") {
      return(strsplit(get_data_definition("columns_string", type), split=get_data_definition("separator", type), fixed=TRUE)[[1]]);
    }
    else if(what=="db_fields_int") {
      return(list("REC_CT_NB", "REF_NB", "entrd_vol_qt", "FIRST_TRD_CNTRL_NB", "days_to_sttl_ct"))
    }
    else if(what=="db_fields_real") {
      return(list("rptd_pr", "yld_pt", "BUYER_CMSN_AMT", "SLLR_CMSN_AMT"))
    }
    else { # table_name
      return("bond_table_final_data")
    }
  }
}
```


### execute_sql_command()
This function executes an SQL command 'sql_command' (for SQLite databases) to the database that is connected via the session 'conn'. Note: This is for SQL commands that edit or change data in the db, not for queries to read data.
- **Example Input:** `execute_sql_command(conn, "INSERT INTO table1 ('A', 'B', 'C') VALUES ('text', 12, 15.2);")`

```
execute_sql_command <- function(conn, sql_command) {
  dbExecute(conn, sql_command)
}
```

### query_sql_command()
This function sends an SQL query command 'sql_command' (for SQLite databases) to the database that is connected via the session 'conn' and returns the result from the request. This is for queries to read messages from the database.
The result can be nested list like depending on your query (e.g. select query for multiple records).
- **Example Input:** `execute_sql_command(conn, "SELECT COUNT(*) FROM table_1;")`
- **Example Output:** `((1234))`
- **Explanation of output**: request how many rows there are in 'table_1', as a result we find it is 1234 rows.

```
query_sql_command <- function(conn, sql_command) {
  result_pointer <- dbSendQuery(conn, sql_command)
  result <- dbFetch(result_pointer)
  dbClearResult(result_pointer)
  return(result)
}
```


### remove_last_chars()
This function removes the last 'n' characters from a given input string 'text'.
- **Example Input:** `remove_last_chars("text.", 1)`
- **Example Output:** `"text"`
- **Explanation of output**: removed one character from string "text." which was the dot, remaining is "text"

```
remove_last_chars <- function(text, n) {
  return(substring(text, 1, nchar(text)-n))
}
```

### convert_null_number()
This function converts a given numeric value to a string that can be used in SQL queries.
In case a value is null / not defined (in R it is "NA") it needs to be converted into the string "NULL" for SQLiteDB queries. This is a helping function for SQL query generating functions.
- **Example Input1:** `convert_null_number(12)`
- **Example Output1:** `"12"`
- **Example Input2:** `convert_null_number("")`
- **Example Output2:** `"NULL"`

```
convert_null_number <- function(val) {
  if(toString(val)=="" || startsWith(toString(val), "NA")) {
    return("NULL")
  }
  else {
    return(toString(val))
  }
}
```

### add_value_to_val_string()
This function adds a certain 'value' to the 'val_string', and depending on whether 'field_name' is of TEXT, Integer (in 'db_fields_int') or Real (in 'db_fields_real') nature, the text is added accordingly with hypens or as a number using convert_null_number().
- **Example Input:** `add_value_to_val_string("1, 2, 'ABC', ", "field", 12, list("field"), list("a", "b"))`
- **Example Output:** `"1, 2, 'ABC', 12, "`
- **Explanation of output:** "12 , " was appended to the value string

```
add_value_to_val_string <- function(val_string, field_name, value, db_fields_int, db_fields_real) {
  if((! field_name %in% db_fields_int) && (! field_name %in% db_fields_real)) {
    val_string <- paste0(val_string, "'", toString(value), "'", ", ", sep="")
  }
  else {
    val_string <- paste0(val_string, convert_null_number(value), ", ", sep="")
  }
  return(val_string)
}
```



### generate_sql_cmd_table_creation()
This function creates the SQL command to create a table (with name 'table_name') if not existing yet, with the column names mentioned in 'db_fields'. 'db_fields_int' and 'db_fields_real' specify the data type of certain columns.

- **Example Input:** `generate_sql_cmd_table_creation("table1", list("A", "B", "C"), list("B"), list("C"))`
- **Example Output:** `"CREATE TABLE IF NOT EXISTS table1 ('A' TEXT, 'B' INTEGER, 'C' REAL);"`
- **Explanation of SQL statement**: create table table 1 with a text column 'A', an integer column 'B' and a real number (float, double like) 'C'

```
generate_sql_cmd_table_creation <- function(table_name, db_fields, db_fields_int, db_fields_real) {
  sql_command <- paste0("CREATE TABLE IF NOT EXISTS ", table_name, " (", sep="")
  for (field in db_fields) {
    if(field %in% db_fields_int) {
      sql_command <- paste0(sql_command, "'", field, "'", " INTEGER, ", sep="")
    }
    else if(field %in% db_fields_real) {
      sql_command <- paste0(sql_command, "'", field, "'", " REAL, ", sep="")
    }
    else {
      sql_command <- paste0(sql_command, "'", field, "'", " TEXT, ", sep="")
    }
  }
  sql_command <- remove_last_chars(sql_command, 2)
  sql_command <- paste(sql_command, ");", sep="")
  return (sql_command)
}
```

### generate_sql_cmd_table_insertion()
This function creates the SQL command to insert a data record (single row) stored in 'values' into the table 'table_name'. 'db_fields_int' and 'db_fields_real' specify the data type of certain columns. If value is a string, it is inserted with " symbol, if it is a number (int or real) then you need to catch the case that it is of a null type, in this case SQLite expects the word "NULL".

- **Example Input:** `generate_sql_cmd_table_insertion("table1", list("A", "B", "C"), list("B"), list("C"), list("text", 12, 15.2))`
- **Example Output:** `"INSERT INTO table1 ('A', 'B', 'C') VALUES ('text', 12, 15.2);"`
- **Explanation of SQL statement**: insert row in table 1 with the values "text", 12, 15.2 representing the columns "A", "B", "C".

```
generate_sql_cmd_table_insertion <- function(table_name, db_fields, db_fields_int, db_fields_real, values) {
  # render the string of all column names, e.g. "'A', 'B', 'C'"
  col_string <- ""
  for (field in db_fields) {
    col_string <- paste0(col_string, "'", field, "'", ", ", sep = "")
  }
  col_string <- remove_last_chars(col_string, 2)
  # render the string of all values, e.g. "'text', 12, 15.12"
  val_string <- ""
  for (it in 1:length(db_fields)) {
    val_string <- add_value_to_val_string(val_string, db_fields[it], values[it], db_fields_int, db_fields_real)
  } 
  val_string <- remove_last_chars(val_string, 2)
  # assemble final command
  sql_command <- paste0("INSERT INTO ", table_name, "(", col_string, ") VALUES (", val_string, ");", sep="")
  return(sql_command)
}
```

### prepare_database_table()
This function generates the table schema for the final SQLiteDB.

```
prepare_database_table <- function(conn) {
  table_name <- get_data_definition("table_name", "final")
  db_fields <- get_data_definition("db_fields", "final")
  db_fields_int <- get_data_definition("db_fields_int", "final")
  db_fields_real <- get_data_definition("db_fields_real", "final")
  sql_command_create_db <- generate_sql_cmd_table_creation(table_name, db_fields, db_fields_int, db_fields_real)
  execute_sql_command(conn, sql_command_create_db)
}
```

### generate_sql_cmd_write_record_A_to_C()
This function takes a 'record' from academic data and creates a SQL insertion statement to put it to the final SQLiteDB table.

- **Example Output:** `"INSERT INTO bond_table_final_data ('REC_CT_NB', 'REF_NB', 'trc_st', 'ISSUE_SYM_ID', 'cusip_id', 'BLMBRG_ID', 'RPTG_PARTY_ID', 'RPTG_PARTY_GVP_ID', 'PRDCT_SBTP_CD', 'wis_fl', 'NO_RMNRN_CD', 'entrd_vol_qt', 'rptd_pr', 'YLD_DRCTN_CD', 'yld_pt', 'asof_cd', 'trd_exctn_dt', 'trd_exctn_tm', 'trd_rpt_dt', 'trd_rpt_tm', 'stlmnt_dt', 'TRD_MDFR_LATE_CD', 'TRD_MDFR_SRO_CD', 'rpt_side_cd', 'BUYER_CMSN_AMT', 'BUYER_CPCTY_CD', 'SLLR_CMSN_AMT', 'SLLR_CPCTY_CD', 'RPT_PRTY_ID', 'cntra_mp_id', 'CNTRA_PARTY_GVP_ID', 'LCKD_IN_FL', 'ATS_FL', 'spcl_trd_fl', 'TRDG_MKT_CD', 'PBLSH_FL', 'SYSTM_CNTRL_DT', 'SYSTM_CNTRL_NB', 'pr_trd_dt', 'PREV_TRD_CNTRL_NB', 'FIRST_TRD_CNTRL_DT', 'FIRST_TRD_CNTRL_NB', 'msg_seq_nb', 'orig_msg_seq_nb', 'days_to_sttl_ct') VALUES (1, NULL, 'T', 'RBS3910852', 'N04895ZZ9', '', 'd1a9a1444e0922a25d6dc248cc687dd18bc95ea5', '', 'CORP', 'N', '', '250000.00', 107.250000, '', NULL, '', '20130107', '025108', '20130107', '080001', '20130110', '', '', 'B', 0.00, 'A', 0.00, '', '', 'C', '', '', '', '', 'S1', 'Y', '20130107', '2000000005', '', '', '20130107', 2000000005, 'AC_2000000005', 'AC_2000000005', 3);"`

```
generate_sql_cmd_write_record_A_to_C <- function(record, table_name) {
  # determine db names
  db_fields_C <- get_data_definition("db_fields", "final") 
  db_fields_int_C <- get_data_definition("db_fields_int", "final") 
  db_fields_real_C <- get_data_definition("db_fields_real", "final") 
  # render the string of all column names
  col_string <- ""
  for (field in db_fields_C) {
    col_string <- paste0(col_string, "'", field, "'", ", ", sep = "")
  }
  col_string <- remove_last_chars(col_string, 2)
  # render the string of all values
  val_string <- ""
  val_string <- add_value_to_val_string(val_string, "REC_CT_NB",    record[1], db_fields_int_C, db_fields_real_C)
  val_string <- add_value_to_val_string(val_string, "REF_NB",       "",        db_fields_int_C, db_fields_real_C)
  val_string <- add_value_to_val_string(val_string, "trc_st",       record[2], db_fields_int_C, db_fields_real_C)
  val_string <- add_value_to_val_string(val_string, "ISSUE_SYM_ID", record[3], db_fields_int_C, db_fields_real_C)
  val_string <- add_value_to_val_string(val_string, "cusip_id",     record[4], db_fields_int_C, db_fields_real_C)
  val_string <- add_value_to_val_string(val_string, "BLMBRG_ID",    "",        db_fields_int_C, db_fields_real_C)
  for (i in 5:26) {
	val_string <- add_value_to_val_string(val_string, db_fields_C[i+2], record[i], db_fields_int_C, db_fields_real_C)
  }
  val_string <- add_value_to_val_string(val_string, "RPT_PRTY_ID",      "",        db_fields_int_C, db_fields_real_C)
  for (i in 27:39) {
	val_string <- add_value_to_val_string(val_string, db_fields_C[i+3], record[i], db_fields_int_C, db_fields_real_C)
  }
  msg_seq_nb <- paste0("AC_", record[35], sep = "")
  val_string <- add_value_to_val_string(val_string, "msg_seq_nb",      msg_seq_nb,      db_fields_int_C, db_fields_real_C)
  orig_msg_seq_nb <- paste0("AC_", record[39], sep = "")
  val_string <- add_value_to_val_string(val_string, "orig_msg_seq_nb", orig_msg_seq_nb, db_fields_int_C, db_fields_real_C)
  days_to_sttl_ct <- strtoi(as.Date(record[19], format="%Y%m%d") - as.Date(record[15], format="%Y%m%d"))
  val_string <- add_value_to_val_string(val_string, "days_to_sttl_ct", days_to_sttl_ct, db_fields_int_C, db_fields_real_C)
  val_string <- remove_last_chars(val_string, 2)
  # assemble final command
  sql_command <- paste0("INSERT INTO ", table_name, " (", col_string, ") VALUES (", val_string, ");", sep="")
  return(sql_command)
}
```

### generate_sql_cmd_write_record_B_to_C()
This function takes a 'record' from enhanced data and creates a SQL insertion statement to put it to the final SQLiteDB table.

- **Example Output:** `"INSERT INTO bond_table_final_data ('REC_CT_NB', 'REF_NB', 'trc_st', 'ISSUE_SYM_ID', 'cusip_id', 'BLMBRG_ID', 'RPTG_PARTY_ID', 'RPTG_PARTY_GVP_ID', 'PRDCT_SBTP_CD', 'wis_fl', 'NO_RMNRN_CD', 'entrd_vol_qt', 'rptd_pr', 'YLD_DRCTN_CD', 'yld_pt', 'asof_cd', 'trd_exctn_dt', 'trd_exctn_tm', 'trd_rpt_dt', 'trd_rpt_tm', 'stlmnt_dt', 'TRD_MDFR_LATE_CD', 'TRD_MDFR_SRO_CD', 'rpt_side_cd', 'BUYER_CMSN_AMT', 'BUYER_CPCTY_CD', 'SLLR_CMSN_AMT', 'SLLR_CPCTY_CD', 'RPT_PRTY_ID', 'cntra_mp_id', 'CNTRA_PARTY_GVP_ID', 'LCKD_IN_FL', 'ATS_FL', 'spcl_trd_fl', 'TRDG_MKT_CD', 'PBLSH_FL', 'SYSTM_CNTRL_DT', 'SYSTM_CNTRL_NB', 'pr_trd_dt', 'PREV_TRD_CNTRL_NB', 'FIRST_TRD_CNTRL_DT', 'FIRST_TRD_CNTRL_NB', 'msg_seq_nb', 'orig_msg_seq_nb', 'days_to_sttl_ct') VALUES (1, 0000003, 'T', 'KAISF4532226', 'G52132AU4', 'BBG00H0MKH30', '', '', 'CORP', 'N', '', '5000000.00', 98.000000, '', NULL, 'A', '20200105', '200051', '20200106', '080002', '20200108', '', '', 'B', 0.00, 'A', 0.00, '', 'D', 'C', '', '', '', 'Y', 'S1', 'Y', '', '', '', '', '20200106', 0000003, 'EN_0000003', 'EN_0000003', 3);"`

```
generate_sql_cmd_write_record_B_to_C <- function(record, table_name) {
  # determine db names
  db_fields_C <- get_data_definition("db_fields", "final") 
  db_fields_int_C <- get_data_definition("db_fields_int", "final") 
  db_fields_real_C <- get_data_definition("db_fields_real", "final") 
  # render the string of all column names
  col_string <- ""
  for (field in db_fields_C) {
    col_string <- paste0(col_string, "'", field, "'", ", ", sep = "")
  }
  col_string <- remove_last_chars(col_string, 2)
  # render the string of all values
  val_string <- ""
  for (i in 1:6) {
	val_string <- add_value_to_val_string(val_string, db_fields_C[i], record[i], db_fields_int_C, db_fields_real_C)
  }
  val_string <- add_value_to_val_string(val_string, "RPTG_PARTY_ID",     "", db_fields_int_C, db_fields_real_C)
  val_string <- add_value_to_val_string(val_string, "RPTG_PARTY_GVP_ID", "", db_fields_int_C, db_fields_real_C)
  for (i in 7:28) {
	val_string <- add_value_to_val_string(val_string, db_fields_C[i+2], record[i], db_fields_int_C, db_fields_real_C)
  }
  val_string <- add_value_to_val_string(val_string, "CNTRA_PARTY_GVP_ID", "", db_fields_int_C, db_fields_real_C)
  for (i in 29:33) {
	val_string <- add_value_to_val_string(val_string, db_fields_C[i+3], record[i], db_fields_int_C, db_fields_real_C)
  }
  val_string <- add_value_to_val_string(val_string, "SYSTM_CNTRL_DT", "", db_fields_int_C, db_fields_real_C)
  val_string <- add_value_to_val_string(val_string, "SYSTM_CNTRL_NB", "", db_fields_int_C, db_fields_real_C)
  for (i in 34:37) {
	val_string <- add_value_to_val_string(val_string, db_fields_C[i+5], record[i], db_fields_int_C, db_fields_real_C)
  }
  msg_seq_nb <- paste0("EN_", record[2], sep = "")
  val_string <- add_value_to_val_string(val_string, "msg_seq_nb", msg_seq_nb, db_fields_int_C, db_fields_real_C)
  orig_msg_seq_nb <- paste0("EN_", record[37], sep = "")
  val_string <- add_value_to_val_string(val_string, "orig_msg_seq_nb", orig_msg_seq_nb, db_fields_int_C, db_fields_real_C)
  days_to_sttl_ct <- strtoi(as.Date(record[19], format="%Y%m%d") - as.Date(record[15], format="%Y%m%d"))
  val_string <- add_value_to_val_string(val_string, "days_to_sttl_ct", days_to_sttl_ct, db_fields_int_C, db_fields_real_C)
  val_string <- remove_last_chars(val_string, 2)
  # assemble final command
  sql_command <- paste0("INSERT INTO ", table_name, " (", col_string, ") VALUES (", val_string, ");", sep="")
  return(sql_command)
}
```

### process_txt_file()
This function will process one specific txt file from 'file_name' in 'folder' and then go through it line by line, getting all information and storing it to the database session 'conn' in table 'table_name'. For this purpose, it needs to know the 'columns_string' (to make sure the header of the txt file matches the expected format), as well as the information about fields in the db 'db_fields'.
Furthermore, separator will determine the separation character used in the txt files and the gen_sql_func_name is a function that is used to convert a record from either academic or enhanced data into the final table scheme.

- **Example Input:** `process_txt_file(file_name, folder, columns_string, separator, conn, table_name, db_fields, generate_sql_cmd_write_record_A_to_C)`
- **Example (Console) Output:** 
```
> process_txt_file(file_name, folder, columns_string, separator, conn, table_name, db_fields, gen_sql_func_name)
Start processing file  0047-corp-academic-trace-data-2013-01-02.txt ...
[1] "File header check correct, start processing lines..."
Warning: invalid line will be ignored : line  54156[1] ""
Warning: invalid line will be ignored : line  54157[1] ""
Finished processing the file,  54158 lines...
```

```
process_txt_file <- function(file_name, folder, columns_string, separator, conn, table_name, db_fields, gen_sql_func_name) {
  # loading file
  cat("Start processing file ", file_name, "...\n")
  file_reader <- file(description=paste0(folder,"/",file_name,sep=""), open="r", encoding="UTF-8", blocking = TRUE)
  # read file head
  head <- readLines(file_reader, n=1)
  # Check and validate head
  if(head==columns_string) {
    print("File header check correct, start processing lines...")
    # Go through file line by line
    line <- readLines(file_reader, n=1)
    counter <- 1
    dbBegin(conn)
    while(! length(line)==0) {
      # Check validity of line
      record_values <- strsplit(line, split=separator, fixed=TRUE)[[1]]
      if(length(record_values)==length(db_fields)) {
        sql_cmd <- gen_sql_func_name(record_values, table_name)
        execute_sql_command(conn, sql_cmd)
      }
      else {
        cat("Warning: invalid line will be ignored : line ", counter)
        print("")
      }
      counter <- counter + 1
      line <- readLines(file_reader, n=1)
    }
    cat("Finished processing the file, ", counter, "lines...\n")
    dbCommit(conn) # save changes to db in sqlite file
    print("Processed changes committed to be permanently saved into db...")
  }
  else {
    cat("Error loading file ", file, " its header doesnt match...\n Programme aborted...\n")
  }
  # Close file
  close(file_reader)
  rm(file_reader)
}
```

### convert_downloaded_academic_data_to_sqlite_db()
This function converts downloaded academic data (txt files) in a 'folder' to the SQLiteDB that is connection in conn.

- **Example Input:** `convert_downloaded_academic_data_to_sqlite_db(conn, "folder_txts")`
- **Example (Console) Output:** 
```
> convert_downloaded_academic_data_to_sqlite_db(conn, folder)
[1] "SQL connection established..."
Start processing file  0047-corp-academic-trace-data-2013-01-02.txt ...
[1] "File header check correct, start processing lines..."
Warning: invalid line will be ignored : line  54156[1] ""
Warning: invalid line will be ignored : line  54157[1] ""
Finished processing the file,  54158 lines...
[1] "Processed changes committed to be permanently saved into db..."
Start processing file  0047-corp-academic-trace-data-2013-01-03.txt ...
[1] "File header check correct, start processing lines..."
Warning: invalid line will be ignored : line  62224[1] ""
Warning: invalid line will be ignored : line  62225[1] ""
Finished processing the file,  62226 lines...
[1] "Processed changes committed to be permanently saved into db..."
Start processing file  0047-corp-academic-trace-data-2013-01-04.txt ...
[1] "File header check correct, start processing lines..."
Warning: invalid line will be ignored : line  61256[1] ""
Warning: invalid line will be ignored : line  61257[1] ""
Finished processing the file,  61258 lines...
[1] "Processed changes committed to be permanently saved into db..."
Start processing file  0047-corp-academic-trace-data-2013-01-07.txt ...
[1] "File header check correct, start processing lines..."
Warning: invalid line will be ignored : line  62365[1] ""
Warning: invalid line will be ignored : line  62366[1] ""
Finished processing the file,  62367 lines...
[1] "Processed changes committed to be permanently saved into db..."
[1] "Connection closed, programme ended successfully..."
```

```
convert_downloaded_academic_data_to_sqlite_db <- function(conn, folder) {
  # get parameters
  table_name <- get_data_definition("table_name", "final")
  columns_string <- get_data_definition("columns_string", "academic")
  separator <- get_data_definition("separator", "academic")
  db_fields <- get_data_definition("db_fields", "academic")
  print("inside")
  
  # list all files in folder
  files <- list.files(folder)
  print("files found")
  print("Folder")
  print(folder)
  print(length(files))
  print(files)
  # loop through all files
  for (file_name in files) {
    # only consider files starting with this name
    if(! startsWith(file_name, "0047-corp-academic-trace-data")) {
      next # if not, skip this iteration and go to the next file
    }
    process_txt_file(file_name, folder, columns_string, separator, conn, table_name, db_fields, generate_sql_cmd_write_record_A_to_C)
  }
}
```

### convert_downloaded_enhanced_data_to_sqlite_db()
This function converts downloaded enhanced data (zip file) to a SQLiteDB connected in conn. 
If applied multiple times, additional entries are added to the existing SQLiteDB. 
This way, you can call the function with multiple zip files. 
Note: this function will temporarily create two temporary folders "temp" and "temp2" to extract zip files.

- **Example Input:** `convert_downloaded_enhanced_data_to_sqlite_db(conn, "enhanced.zip")`
- **Example (Console) Output:** 
```
> convert_downloaded_enhanced_data_to_sqlite_db(conn, zip_file)
[1] "SQL connection established..."
Start processing file  enhanced-time-and-sales-cusip-2020-01-02.txt ...
[1] "File header check correct, start processing lines..."
Warning: invalid line will be ignored : line  78528[1] ""
Finished processing the file,  78529 lines...
[1] "Processed changes committed to be permanently saved into db..."
Start processing file  enhanced-time-and-sales-cusip-2020-01-03.txt ...
[1] "File header check correct, start processing lines..."
Warning: invalid line will be ignored : line  71163[1] ""
Finished processing the file,  71164 lines...
[1] "Processed changes committed to be permanently saved into db..."
Start processing file  enhanced-time-and-sales-cusip-2020-01-06.txt ...
[1] "File header check correct, start processing lines..."
Warning: invalid line will be ignored : line  91596[1] ""
Finished processing the file,  91597 lines...
[1] "Processed changes committed to be permanently saved into db..."
[1] "Connection closed, programme ended successfully..."
```

```
convert_downloaded_enhanced_data_to_sqlite_db <- function(conn, zip_file) {
  # get parameters
  table_name <- get_data_definition("table_name", "final")
  columns_string <- get_data_definition("columns_string", "enhanced")
  separator <- get_data_definition("separator", "enhanced")
  db_fields <- get_data_definition("db_fields", "enhanced")
  db_fields_int <- get_data_definition("db_fields_int", "enhanced")
  db_fields_real <- get_data_definition("db_fields_real", "enhanced")
  # list all zip files / days in given zip_file
  unlink("temp", recursive = TRUE) # delete temp folders where zip files got extracted
  unlink("temp2", recursive = TRUE)
  unzip(zip_file,exdir="temp")
  file_list <- list.files("temp")
  # loop through all files
  for (zip_file_name in file_list) {
    # unzip files
    unlink("temp2", recursive = TRUE)
    unzip(paste0("temp","/",zip_file_name),exdir="temp2")
    txt_file_name <- list.files("temp2")[1]
    process_txt_file(txt_file_name, "temp2", columns_string, separator, conn, table_name, db_fields, generate_sql_cmd_write_record_B_to_C)
  }
}
```
