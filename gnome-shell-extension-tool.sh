#!/bin/bash
# Author: José M. C. Noronha

declare SLEEP_TIME=3
declare UUID=""
declare PACKAGE_FILE=""

function executeCommand() {
    echo ">> $1"
    eval "$1"
}

function debugGnomeShell() {
    sleep $SLEEP_TIME
    executeCommand "journalctl -f -o cat /usr/bin/gnome-shell"
}

function create() {
    executeCommand "gnome-extensions create --interactive"
}


function restartGnomeShell() {
    local xdgSessionType="$(echo $XDG_SESSION_TYPE)"
    echo "Another way to restart: press ALT + F2 key combination. Into the Enter a Command box type r and press Enter"
    sleep $SLEEP_TIME
    if [[ "${xdgSessionType}" == "x11" ]]; then
        executeCommand "killall -3 gnome-shell"
    elif [[ "${xdgSessionType}" == "wayland" ]]; then
        executeCommand "dbus-run-session -- gnome-shell --nested --wayland"
    else
        echo "Not supported session type"
    fi
}

function enableExt() {
    executeCommand "gnome-extensions enable \"$UUID\""
}

function disable() {
    executeCommand "gnome-extensions disable \"$UUID\""
}

function uninstall() {
    executeCommand "gnome-extensions uninstall \"$UUID\""
}

function install() {
    executeCommand "gnome-extensions install \"${1}\" --force"
}

function pack() {
    local destination="$1"
    PACKAGE_FILE="${UUID}.shell-extension.zip"
    if [ -f "$PACKAGE_FILE" ]; then
        executeCommand "rm -rf \"$PACKAGE_FILE\""
    fi
    echo "Zip file: $PACKAGE_FILE"
    (
        cd "$destination" || exit 1
        for file in $(find . -type f -printf "%T@ %p\n" | sort -nr | cut -d\  -f2-); do
            zip "../$PACKAGE_FILE" "$file"
        done
    )
}

function usage() {
    echo "$0 [OPEATION] [OPTION]

OPEATION:

debug-gnome-shell       Debug Gnome Shell
restart-gnome-shell     Restart the gnome shell
enable [UUID]           Enable the extension
disable [UUID]          Enable the extension
install [PACKAGE_FILE]  Install the extension
uninstall [UUID]        Install the extension
pack [UUID] [DEST]      Pack the extension
create                  Create extension

-h|--help               Show Help
"
}

# Main
function main() {
    local operation="$1"; shift
    case "$operation" in
    "debug-gnome-shell") debugGnomeShell ;;
    "restart-gnome-shell") restartGnomeShell ;;
    "enable") UUID="$1"; enableExt ;;
    "disable") UUID="$1"; disable ;;
    "install") install "$@" ;;
    "uninstall") UUID="$1"; uninstall ;;
    "pack") UUID="$1"; shift; pack "$@" ;;
    "create") create ;;
    "-h"|"--help") usage ;;
    *) echo "Please, pass \"-h\" to see help" ;;
    esac
}
main "$@"