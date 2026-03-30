#!/bin/bash
LOCK_CMD="qs -p $HOME/.config/dots/qs/lockscreen/lock.qml"

case "$1" in
    lock)
        # Find the process, but ignore this script ($$) and the grep process
        if ! pgrep -f "$LOCK_CMD" | grep -v -e "$$" -e "grep" > /dev/null; then
            exec $LOCK_CMD
        else
            echo "Lockscreen is already running"
        fi
        ;;
    unlock)
        pkill -f "$LOCK_CMD"
        ;;
    *)
        echo "Usage: $0 {lock|unlock}"
        exit 1
        ;;
esac