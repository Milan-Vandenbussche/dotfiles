# Quickshell Configuration

Custom hand-written Quickshell configuration for desktop and laptop environments.

## Running

Run the shell config manually:
```bash
qs -c shell
```
or with verbose logging:
```bash
qs -c shell -v
```

## Hot-Reloading

Quickshell watches its configuration files for changes. Saving any QML file in `~/.config/quickshell/shell/` will automatically hot-reload the UI.

To manually reload via IPC:
```bash
qs ipc reload
```

## Killing

To terminate the running Quickshell instance:
```bash
qs kill
```
or:
```bash
pkill quickshell
```

## Logs

To view recent Quickshell log output:
```bash
qs log
```
or follow system journal:
```bash
journalctl --user -b -t quickshell -f
```
