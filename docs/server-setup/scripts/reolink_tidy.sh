#!/bin/bash
# filepath: /home/alan/repositories/linux-notes/docs/server-setup/scripts/reolink_tidy.sh

# Configuration
RECORDINGS_DIR="/srv/sftpgo/data/ajr-reolink"  # Change this to your recordings directory
THRESHOLD=90                          # Disk usage threshold percentage
LOG_FILE="/srv/sftpgo/data/ajr-reolink/reolink_tidy.log" # Change this to your desired log file path (e.g., /var/log/reolink_tidy.log)

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to get disk usage percentage
get_disk_usage() {
    df "$RECORDINGS_DIR" | awk 'NR==2 {print int($5)}'
}

# Function to clean up empty directories
cleanup_empty_dirs() {
    # Remove empty day directories
    find "$RECORDINGS_DIR" -type d -name "[0-9][0-9]" -empty -delete 2>/dev/null
    # Remove empty month directories
    find "$RECORDINGS_DIR" -type d -name "[0-9][0-9]" -empty -delete 2>/dev/null
    # Remove empty year directories
    find "$RECORDINGS_DIR" -type d -name "[0-9][0-9][0-9][0-9]" -empty -delete 2>/dev/null
}

# Function to find and delete oldest day directory
delete_oldest_day() {
    local oldest_day
    oldest_day=$(find "$RECORDINGS_DIR" -type d -name "[0-9][0-9]" -path "*/[0-9][0-9]/[0-9][0-9]" 2>/dev/null | sort | head -n1)
    
    if [ -n "$oldest_day" ]; then
        local size
        size=$(du -sh "$oldest_day" 2>/dev/null | cut -f1)
        log_message "Deleting oldest day directory: $oldest_day (Size: $size)"
        rm -rf "$oldest_day"
        return 0
    else
        log_message "No day directories found to delete"
        return 1
    fi
}

# Main script
main() {
    log_message "Starting reolink_tidy script"
    
    # Check if recordings directory exists
    if [ ! -d "$RECORDINGS_DIR" ]; then
        log_message "ERROR: Recordings directory $RECORDINGS_DIR does not exist"
        exit 1
    fi
    
    # Get initial disk usage
    local current_usage
    current_usage=$(get_disk_usage)
    log_message "Current disk usage: ${current_usage}%"
    
    # Check if cleanup is needed
    if [ "$current_usage" -le "$THRESHOLD" ]; then
        log_message "Disk usage (${current_usage}%) is below threshold (${THRESHOLD}%). No cleanup needed."
        cleanup_empty_dirs
        log_message "Cleaned up empty directories"
        exit 0
    fi
    
    log_message "Disk usage (${current_usage}%) exceeds threshold (${THRESHOLD}%). Starting cleanup..."
    
    # Delete oldest days until disk usage is below threshold
    local deleted_count=0
    while [ "$(get_disk_usage)" -gt "$THRESHOLD" ]; do
        if delete_oldest_day; then
            deleted_count=$((deleted_count + 1))
            current_usage=$(get_disk_usage)
            log_message "Cleanup iteration $deleted_count completed. Current usage: ${current_usage}%"
            
            # Clean up empty directories after each deletion
            cleanup_empty_dirs
            
            # Safety check to prevent infinite loop
            if [ "$deleted_count" -ge 1000 ]; then
                log_message "WARNING: Deleted 1000 directories. Stopping to prevent infinite loop."
                break
            fi
        else
            log_message "No more directories to delete. Stopping cleanup."
            break
        fi
    done
    
    # Final status
    current_usage=$(get_disk_usage)
    if [ "$current_usage" -le "$THRESHOLD" ]; then
        log_message "SUCCESS: Cleanup completed. Final disk usage: ${current_usage}%. Deleted $deleted_count day directories."
    else
        log_message "WARNING: Cleanup completed but disk usage (${current_usage}%) still exceeds threshold (${THRESHOLD}%). Deleted $deleted_count day directories."
    fi
    
    log_message "reolink_tidy script completed"
}

# Run main function
main "$@"