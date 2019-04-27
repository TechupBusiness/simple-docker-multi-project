# Instruction
1. Create a new project (`./project.sh`) and start it (`./compose.sh MY-PROJECT up -d`)
1. Run `./compose.sh PROJECT logs` and get the URL, which you need to open in your browser `Please visit https://www.dropbox.com/cli_link_nonce?nonce=234567your19876543hash to link this device`.
1. After logging in to dropbox, the sync should start and running `./compose.sh PROJECT logs` again should show ``

# Controlling dropbox
To administrate the Dropbox daemon via CLI, enter the container `./compose.sh MY-PROJECT exec dropbox /bin/bash`.
Then use the `dropbox` command.

```
Dropbox command-line interface

    commands:

    Note: use dropbox help <command> to view usage for a specific command.

      status       get current status of the dropboxd
      throttle     set bandwidth limits for Dropbox
      help         provide help
      stop         stop dropboxd
      running      return whether dropbox is running
      start        start dropboxd
      filestatus   get current sync status of one or more files
      ls           list directory contents with current sync status
      autostart    automatically start dropbox at login
      exclude      ignores/excludes a directory from syncing
      lansync      enables or disables LAN sync
      sharelink    get a shared link for a file in your dropbox
      proxy        set proxy settings for Dropbox
```
