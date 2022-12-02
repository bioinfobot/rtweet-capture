#!/usr/bin/R

# Purpose: to initiate and save rtweet authentication for the bot.

library(yaml)
library(rtweet)

yams <- yaml.load_file("/home/swatantra/sandbox/keys/bioinfobot-creds.yaml")

auth <- rtweet_bot(yams$consumer_key, yams$consumer_secret, yams$access_token, yams$access_token_secret)
auth_save(auth, "bioinfobot")
auth_list()

#   auth_as("govbot")
