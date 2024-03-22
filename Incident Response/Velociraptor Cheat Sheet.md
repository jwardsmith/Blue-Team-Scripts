# Velociraptor Cheat Sheet

### Connected Clients Audit

- View currently connected clients

```
Click the drop-down next to the search bar -> Select 'Show All'
```

- View the overview (First Seen, Last Seen, OS, Hostname, Release etc...) for a currently connected client

```
Click the drop-down next to the search bar -> Select 'Show All' -> Click the Client ID of a client
```

### Command Execution

- Execute a command on a currently connected client

```
Click the Client ID of a client -> Select 'Shell' -> Select shell type (PowerShell, CMD, Bash, VQL) -> Enter command -> Launch -> Click the eye icon to show output
```

### Virtual File System (VFS)

- View the virtual file system (file, ntfs, registry) on a currently connected client

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it)
```

- Collect a file from a client

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it) -> Select a file -> Click 'Collect from the client' -> Click the download icon button
```

- View a file in Textview (text editor) or HexView (hex editor)

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it) -> Select a file -> Click 'Textview' or 'HexView'
```

### Hunt Manager

- Create a hunt

```
Click the + button -> Enter a description, expiry and any filters -> Choose the artifact to collect e.g. Windows.Search.FileFinder -> Configure parameters e.g. SearchFilesGlob = C:\Users\**\Security_Protocol* -> Specify resources -> Review -> Launch
```

- Run a hunt

```
Select a hunt -> Click the play button
```

- View the results of a hunt

```
Select a hunt -> Select the Notebook tab
```
