echo "Executing rclone on" `date`
/usr/bin/rclone copy --retries 5 --transfers 2 --checksum data/ megaBiBot:rclone/bioinfo-tweets
