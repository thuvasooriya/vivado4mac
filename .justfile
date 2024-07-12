# wip
@_default:
    just --list --list_heading ''

[macos]
setup:
    # prepare environment for installation
    # arrange emails and secrets with scripts
    # interactive config

[macos]
connect:
    # separate the device connect logic
    osascript -e 'tell app "Terminal" to do script " while ! [[ $(ps aux | grep vivado_container | wc -l | tr -d \"\\n\\t \") == \"1\" ]]; do /Users/tony/arc/pro/dev/vivado4mac/xvcd/bin/xvcd; sleep 1; done; exit"'
