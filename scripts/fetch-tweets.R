#!/usr/bin/env Rscript

# Purpose: to fetch tweets from my home timeline using since id.

suppressMessages(library(rtweet))
suppressMessages(library(yaml))
suppressMessages(library(DBI))


# Function(s)
strtime <- function(x){
  crtime <- strptime(x, "%a %b %d %H:%M:%S %z %Y", tz = "UTC")
  return(as.character(crtime))
}

# Rtweet Authentication
auth_as("bioinfobot")

# Read since_ids
since_ids <- readRDS(file.path("data", "since-ids.rds"))

# Read home timeline data and fetch associated user data
timeline_dat <- get_my_timeline(n = Inf,  since_id = since_ids,  parse = TRUE)

if(nrow(timeline_dat) > 0){
        print(paste0(nrow(timeline_dat), " new tweet(s) were fetched on ", date()))

        users_dat <- users_data(timeline_dat) 
        users_dat <- users_dat[c("id_str","screen_name", "location")]
        colnames(users_dat) <- c("UserID", "UserName", "Location") 

        # Rename columns  
        tweet_dat <- timeline_dat[c("created_at", "id_str", "full_text", "lang")] 
        colnames(tweet_dat) <-  c("TimeStamp", "TweetID", "Tweet", "Language")

        # Join tweet data with the user data
        all_dat <- cbind(users_dat, tweet_dat)
        all_dat  <-  all_dat[c("TweetID", "TimeStamp", "Language", "UserID", "UserName", "Tweet", "Location")]

        # Convert twitter time stamp to a string (compatible wtih SQLite and Excel)
        # All the time stamps are in UTC
        all_dat["TimeStamp"] <- apply(all_dat["TimeStamp"], 2, strtime)

        # Pull and save latest since_ids
        since_ids <- all_dat[["TweetID"]]
        saveRDS(since_ids, file.path("data",  "since-ids.rds"))


        # Make a connection with the RSQLite database
        con <- dbConnect(RSQLite::SQLite(), file.path("data", "bioinfo-tweets.db"))

        ## Write data to the database
        dbWriteTable(con, "MainDataTable", all_dat, append = TRUE)                           

        ## Disconnect from the database
        dbDisconnect(con)
}else{
        print(paste0(nrow(timeline_dat), " new tweet(s) were fetched on ", date()))
}
