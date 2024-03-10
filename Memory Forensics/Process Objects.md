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

- DLLs: Dynamically Linked Libraries define the capabilities of a process. For instance, if a process
needs to communicate via HTTP, it will load the WININET.dll file. In some cases, malware will load its
own malicious DLLs to take control of a process.

- Handles: A pointer to a resource, handles exist in many different forms. Some of the most important to
memory analysis are:
  - File handles: Identify which items in the file system or which I/O devices are being accessed by
the process.
  - Directory handles: This is not your standard file system directory. Instead, directory handles are
known lists within the kernel that allow the process to find kernel objects. Common examples are
KnownDlls, BaseNamedObjects, Callbacks, Device, and Drivers.
  - Registry handles: These are the registry keys the process is reading or writing to.
  - Mutex or semaphore handles: Also called "mutants", these objects control or limit accessto a
resource. For instance, a mutex might be used by an object to enforce that only one process at a
time can access it. Worms commonly set mutexes as a way of "marking" a compromised system so
that it does not get reinfected.
  - Event handles: Events are a way for process threads to communicate. Malware will occasionally
use unique event handles.

- Threads: A process is just a container for all of the items that do the real work. Multiple threads run
within every process interacting with various system objects.

- Memory sections: Every process has a collection of virtual memory pages where DLLs and files are
loaded, and code and data are stored. The Virtual Address Descriptor tree (VAD) maintains a list of
these assigned memory sections.

- Sockets: These are network connection endpoints. Every network socket is assigned to a specific
process, allowing us to trace back suspicious network activities.
