# Export PATH environment variable
# Don't re-export for interactive queue process
if [[ -z "$INTERACTIVE_QUEUE" ]]; then
    . "$SEQCLOUD_DIR"/profile/path.sh
fi
