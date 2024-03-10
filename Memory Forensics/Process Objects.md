# Process Objects

Windows processes are composed of much more than just an executable.

- **DLLs**: Dynamic Linked Libraries (shared code)
- **Handles**: Pointer to a resource
  - Files: Open files or I/O devices
  - Directories: Lists of names used for access to kernel objects
  - Registry: Access to a key within the Windows Registry
  - Mutexes/Semaphores: Control/limit access to an object
  - Events: Notifications that help threads communicate and organize
- **Threads**: Smallest unit of execution; the workhorse of a process
- **Memory Sections**: Shared memory areas used by a process
- **Sockets**: Network port and connection information within a process

