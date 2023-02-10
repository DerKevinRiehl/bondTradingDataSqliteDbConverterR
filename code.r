# Imports
library(DBI)


# ==========================================
# ========== METHODS =======================
# ==========================================
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
  else { #type=="final"
    if(what=="columns_string") {
      return("SOURCE|REFERENCE_NUMBER|BLOOMBERG_IDENTIFIER|REC_CT_NB|TRD_ST_CD|ISSUE_SYM_ID|CUSIP_ID|RPTG_PARTY_ID|RPTG_PARTY_GVP_ID|PRDCT_SBTP_CD|WIS_DSTRD_CD|NO_RMNRN_CD|ENTRD_VOL_QT|RPTD_PR|YLD_DRCTN_CD|CALCD_YLD_PT|ASOF_CD|TRD_EXCTN_DT|TRD_EXCTN_TM|TRD_RPT_DT|TRD_RPT_TM|TRD_STLMT_DT|TRD_MDFR_LATE_CD|TRD_MDFR_SRO_CD|RPT_SIDE_CD|BUYER_CMSN_AMT|BUYER_CPCTY_CD|SLLR_CMSN_AMT|SLLR_CPCTY_CD|CNTRA_PARTY_ID|CNTRA_PARTY_GVP_ID|LCKD_IN_FL|ATS_FL|SPCL_PR_FL|TRDG_MKT_CD|PBLSH_FL|SYSTM_CNTRL_DT|SYSTM_CNTRL_NB|PREV_TRD_CNTRL_DT|PREV_TRD_CNTRL_NB|FIRST_TRD_CNTRL_DT|FIRST_TRD_CNTRL_NB");
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
      return("bond_table_final_data")
    }
  }
}

execute_sql_command <- function(conn, sql_command) {
  dbExecute(conn, sql_command)
}

query_sql_command <- function(conn, sql_command) {
  result_pointer <- dbSendQuery(conn, sql_command)
  result <- dbFetch(result_pointer)
  dbClearResult(result_pointer)
  return(result)
}

remove_last_chars <- function(text, n) {
  return(substring(text, 1, nchar(text)-n))
}

convert_null_number <- function(val) {
  if(toString(val)=="" || startsWith(toString(val), "NA")) {
    return("NULL")
  }
  else {
    return(toString(val))
  }
}

add_value_to_val_string <- function(val_string, field_name, value, db_fields_int, db_fields_real) {
  if((! field_name %in% db_fields_int) && (! field_name %in% db_fields_real)) {
    val_string <- paste0(val_string, "'", toString(value), "'", ", ", sep="")
  }
  else {
    val_string <- paste0(val_string, convert_null_number(value), ", ", sep="")
  }
  return(val_string)
}

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
  val_string <- "'ACADEMIC', '', '', "
  for (i in 1:(length(record))) {
    val_string <- add_value_to_val_string(val_string, db_fields_C[i+3], record[i], db_fields_int_C, db_fields_real_C)
  }
  val_string <- remove_last_chars(val_string, 2)
  # assemble final command
  sql_command <- paste0("INSERT INTO ", table_name, " (", col_string, ") VALUES (", val_string, ");", sep="")
  return(sql_command)
}

generate_sql_cmd_write_record_B_to_C <- function(record, table_name) {
  # determine db names
  db_fields_B <- get_data_definition("db_fields", "enhanced") 
  db_fields_int_B <- get_data_definition("db_fields_int", "enhanced") 
  db_fields_real_B <- get_data_definition("db_fields_real", "enhanced") 
  db_fields_C <- get_data_definition("db_fields", "final") 
  # render the string of all column names
  col_string <- ""
  for (field in db_fields_C) {
    col_string <- paste0(col_string, "'", field, "'", ", ", sep = "")
  }
  col_string <- remove_last_chars(col_string, 2)
  # render the string of all values
  val_string = paste0("'ENHANCED', '", toString(record[1+1]), "', '", toString(record[5+1]), "', ", sep="")
  val_string = paste0(val_string, convert_null_number(record[0+1]), ", '", toString(record[2+1]), "', '", toString(record[3+1]), "', '", toString(record[4+1]), "', '', '', ", sep="")
  for (i in 7:(34-1)) {
    val_string <- add_value_to_val_string(val_string, db_fields_B[i], record[i], db_fields_int_B, db_fields_real_B)
  }
  val_string <- paste0(val_string, "'', '', ", sep="")
  for (i in 34:(38-1)) {
    val_string <- add_value_to_val_string(val_string, db_fields_B[i], record[i], db_fields_int_B, db_fields_real_B)
  }
  val_string <- remove_last_chars(val_string, 2)
  # assemble final command
  sql_command <- paste0("INSERT INTO ", table_name, " (", col_string, ") VALUES (", val_string, ");", sep="")
  return(sql_command)
}

process_txt_file <- function(file_name, folder, columns_string, separator, conn, table_name, db_fields, db_fields_int, db_fields_real) {
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
        sql_cmd <- generate_sql_cmd_table_insertion(table_name, db_fields, db_fields_int, db_fields_real, record_values)
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

convert_downloaded_academic_data_to_sqlite_db <- function(database_file, folder) {
  # get parameters
  table_name <- get_data_definition("table_name", "academic")
  columns_string <- get_data_definition("columns_string", "academic")
  separator <- get_data_definition("separator", "academic")
  db_fields <- get_data_definition("db_fields", "academic")
  db_fields_int <- get_data_definition("db_fields_int", "academic")
  db_fields_real <- get_data_definition("db_fields_real", "academic")
  # start connection to db
  conn <- dbConnect(RSQLite::SQLite(), database_file)
  print("SQL connection established...")
  # create table schema in db
  sql_command_create_db <- generate_sql_cmd_table_creation(table_name, db_fields, db_fields_int, db_fields_real)
  execute_sql_command(conn, sql_command_create_db)
  # list all files in folder
  files <- list.files(folder)
  # loop through all files
  for (file_name in files) {
    # only consider files starting with this name
    if(! startsWith(file_name, "0047-corp-academic-trace-data")) {
      next # if not, skip this iteration and go to the next file
    }
    process_txt_file(file_name, folder, columns_string, separator, conn, table_name, db_fields, db_fields_int, db_fields_real)
  }
  # Close connection to db
  dbDisconnect(conn)
  print("Connection closed, programme ended successfully...")
}

convert_downloaded_enhanced_data_to_sqlite_db <- function(database_file, zip_file) {
  # get parameters
  table_name <- get_data_definition("table_name", "enhanced")
  columns_string <- get_data_definition("columns_string", "enhanced")
  separator <- get_data_definition("separator", "enhanced")
  db_fields <- get_data_definition("db_fields", "enhanced")
  db_fields_int <- get_data_definition("db_fields_int", "enhanced")
  db_fields_real <- get_data_definition("db_fields_real", "enhanced")
  # start connection to db
  conn <- dbConnect(RSQLite::SQLite(), database_file)
  print("SQL connection established...")
  # create tables schema in db
  sql_command_create_db <- generate_sql_cmd_table_creation(table_name, db_fields, db_fields_int, db_fields_real)
  execute_sql_command(conn, sql_command_create_db)
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
    process_txt_file(txt_file_name, "temp2", columns_string, separator, conn, table_name, db_fields, db_fields_int, db_fields_real)
  }
  # close connection to db
  dbDisconnect(conn)
  unlink("temp", recursive = TRUE)
  unlink("temp2", recursive = TRUE)
  print("Connection closed, programme ended successfully...")
}

merge_data_bases <- function(database_file_A, database_file_B, database_file_C) {
  # final column names
  table_name_A <- get_data_definition("table_name", "academic")
  table_name_B <- get_data_definition("table_name", "enhanced")
  table_name_C <- get_data_definition("table_name", "final")
  db_fields_C <- get_data_definition("db_fields", "final")
  db_fields_int_C <- get_data_definition("db_fields_int", "final")
  db_fields_real_C <- get_data_definition("db_fields_real", "final")
  # start connection to db
  connA <- dbConnect(RSQLite::SQLite(), database_file_A)
  connB <- dbConnect(RSQLite::SQLite(), database_file_B)
  connC <- dbConnect(RSQLite::SQLite(), database_file_C)
  print("SQL connection established...")
  # create tables schema in final db
  sql_command_create_db <- generate_sql_cmd_table_creation(table_name_C, db_fields_C, db_fields_int_C, db_fields_real_C)
  execute_sql_command(connC, sql_command_create_db)
  # count number of records in db A and B
  n_rows_a <- query_sql_command(connA, paste0("SELECT COUNT(*) FROM ",table_name_A,";",sep=""))
  n_rows_a <- as.numeric(unlist(n_rows_a))
  n_rows_b <- query_sql_command(connB, paste0("SELECT COUNT(*) FROM ",table_name_B,";",sep=""))
  n_rows_b <- as.numeric(unlist(n_rows_b))
  # populate table C with data from table A
  populate_final_table(connA, connC, n_rows_a, table_name_A, generate_sql_cmd_write_record_A_to_C)
  # populate table C with data from table B
  populate_final_table(connB, connC, n_rows_b, table_name_B, generate_sql_cmd_write_record_B_to_C)
  # close connection to db
  dbDisconnect(connA)
  dbDisconnect(connB)
  dbDisconnect(connC)
  print("Connection closed, programme ended successfully...")
}

populate_final_table <- function(conn_X, conn_C, n_rows_X, table_name_X, generate_sql_cmd_function_name) {
  table_name_C <- get_data_definition("table_name", "final")
  dbBegin(conn_C)
  for (i in 0:(n_rows_X-1)) {
    query_res <- query_sql_command(conn_X, paste0("SELECT * FROM ",table_name_X," LIMIT 1 OFFSET ", toString(i), ";",sep=""))
    query_res <- unlist(query_res)
    sql_cmd <- generate_sql_cmd_function_name(query_res, table_name_C)
    execute_sql_command(conn_C, sql_cmd)
    if(i%%5000==0) {
      cat("Adding records to final db, ",toString(i), " ", toString(n_rows_X), " lines...\n")
      dbCommit(conn_C) # save changes to db in sqlite file
      dbBegin(conn_C)
    }
  }
  dbCommit(conn_C) # save changes to db in sqlite file
}


# ==========================================
# ========== MAIN WORK FLOW ================
# ==========================================

# Step 1: Convert downloaded academic data to SQLiteDB A.
database_file_A <- ("academic_data_academic2.sqlite")
folder_A <- ("0047-CORP-2013-01-01-2013-12-31_academic")
# convert_downloaded_academic_data_to_sqlite_db(database_file_A, folder_A)

# Step 2: Convert downloaded enhanced data to SQLiteDB B.
database_file_B <- ("academic_data_enhanced2.sqlite")
zip_file_B <- ("EHDwC 2020.zip")
# convert_downloaded_enhanced_data_to_sqlite_db(database_file_B, zip_file_B)

# Step 3: Merge two databases A and B to one final SQLiteDB with an unified schema.
table_name_C <- ("bond_table_final_data")
database_file_C <- ("final_bond_trading_data3.sqlite")
merge_data_bases(database_file_A, database_file_B, database_file_C)
