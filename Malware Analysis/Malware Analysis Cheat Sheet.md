# Malware Analysis

The art of breaking apart malware/code to understand its functionality.

#1. - Virtual Machines
-----------------------------------------
- Windows 10 FlareVM: https://github.com/mandiant/flare-vm
    - FLARE VM is a freely available and open sourced Windows-based security distribution designed for reverse engineers, malware analysts, incident responders, forensicators, and penetration testers. Inspired by open-source Linux-based security distributions like Kali Linux, REMnux and others, FLARE VM delivers a fully configured platform with a comprehensive collection of Windows security tools such as debuggers, disassemblers, decompilers, static and dynamic analysis utilities, network analysis and manipulation, web assessment, exploitation, vulnerability assessment applications, and many others.

- Remnux VM: https://remnux.org/
    - REMnux® is a Linux toolkit for reverse-engineering and analyzing malicious software. REMnux provides a curated collection of free tools created by the community. Analysts can use it to investigate malware without having to find, install, and configure the tools.

#2. - Static Analysis
-----------------------------------------
The art of analysing malware without execution.

- Basic = looking at any and everything other than the assembly code.

- Advanced = looking at code in a disassembler usually Ghidra/IDA Pro/Binja/Hopper etc..

We look at the file type, file hash, strings (indicator of what we are dealing with), sections, imports (what API calls the process may make/non-presence could mean the application is packed) etc... Quick win/quick triage = chance of not repeating what fellow researchers have done.

### Basic Static Analysis

- Identify a file type on Windows

```
CyberChef https://gchq.github.io/CyberChef/#recipe=Detect_File_Type(true,true,true,true,true,true,true)
```

- Identify a file type on Linux

```
$ file <file>
```

- Compute a SHA256 hash on Windows

```
PS C:\> Get-FileHash <file>
```

- Compute a SHA256 hash on Linux

```
$ sha256sum <file>
```

- Extract the strings on Windows

```
PS C:\> strings <file>
```

- Extract the strings on Linux

```
$ pestr <file>
```

- Perform a strings comparison between two files using WinMerge (https://winmerge.org/?lang=en)

```
Select two files -> Right-click and select WinMerge 
```

- PEStudio

```
https://www.winitor.com/
```

- CFF Explorer

```
https://ntcore.com/?page_id=388
```

### Advanced Static Analysis

- Ghidra

```
https://github.com/NationalSecurityAgency/ghidra
```

- IDA Pro

```
https://hex-rays.com/ida-pro/
```

- Binja

```
https://binary.ninja/
```

- Hopper

```
https://www.hopperapp.com/
```

#3. - Dynamic Analysis
-----------------------------------------
The art of analysing malware by execution.

- Basic = looking at any and everything other than the assembly code. Process Monitor (Procmon) logs, ProcDOT flow, Regshot, Wireshark.

- Advanced = executing code in a debugger usually x64dbg/winDbg/OllyDbg/gdb etc..

Quickly analyse the malware behaviour/quick overview of the malware by monitoring the OS = get access to artifacts more quickly rather than extracting them statically which can be a pain.

### Basic Dynamic Analysis

- Start a Procmon, Regshot, and Wireshark capture

```
Open Procmon on FlareVM -> Stop the capture -> Options -> Select Columns -> Ensure ProcessID and ThreadID are selected -> Filter -> Process Name contains bot -> Add -> Apply -> OK -> Open Regshot on FlareVM -> Change the scan dir to C:\ drive -> 1st shot -> Open Wireshark on Remnux (don't start the capture yet) -> After Regshot is complete, start the Procmon capture -> Start the Wireshark capture on Remnux -> Start fakedns on Remnux -> Execute the malware on FlareVM -> Terminate the malware after 1 minute using Process Hacker, right-click select Terminate tree -> Stop the Procmon capture -> Regshot 2nd shot -> Check the fakedns and Wireshark logs (search dns in filter bar) for possible C2 domains -> Stop the Wireshark capture -> After Regshot is complete, select Compare -> Compare and Output -> Save the Regshot output file -> Open the Regshot output file in VSCode -> Save the Procmon logs to a CSV file -> Open ProcDOT on FlareVM -> Select 3 dots next to Procmon and select your Procmon log file -> Refresh -> Select 3 dots next to Launcher and select your malware process -> Refresh -> Use the arrow buttons down the bottom to step into the process frame-by-frame
```

- Process Hacker

```
https://processhacker.sourceforge.io/
```

- API Monitor

```
http://www.rohitab.com/apimonitor
```

### Advanced Dynamic Analysis

- x64dbg

```
https://x64dbg.com/
```

- winDbg

```
https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/
```

- OllyDbg

```
https://www.ollydbg.de/
```

- gdb

```
https://www.sourceware.org/gdb/
```

#4. - Assembly Language
-----------------------------------------

We need to understand how to disassemble and analyse code to get the full details as basic static and basic dynamic analysis can only go so far. This requires knowledge of assembly language. Prerequisite for understanding is to understand data representation in binary and hex.

- Core of everything executed.
- Lowest layer before machine code.
- Key to reverse engineering and malware analysis.
- Modern malware uses a lot of tricks to evade detection, assembly know how is required to reverse engineer them.
- Can be reviewed statically in IDA Pro, Ghidra, Hopper.
- Can be reviewed dynamically in x64dbg, winDbg, gdb.

![image](https://github.com/jwardsmith/Malware-Analysis/assets/31498830/ffb04fd6-7299-406f-8b31-2bc8e86e0ae0)

### Registers

- High speed storage locations inside the CPU - mostly used to speed up execution.
- Total of 8 general purpose registers.
- They can be 32-bit or 64-bit.
- Registers were created for 16b-it architecture. Then extended to support 32-bit. Hence the added "E" for 32-bit and "R" for 64-bit.
- In x64 programs, arguments are passed in registers RCX, RDX, R8, and R9.

- General Purpose Registers = EAX (accumulator - used for arithmetic operations and function return values), EBX, ECX (loop counter), EDX. 
- Pointer and Index = ESP, EBP (base -  base register used to hold the address of the base storage location from where the data were stored continuously), EDI (used for memory transfer instructions like string copy etc..), ESI (used for memory transfer instructions like string copy etc..)
- Segment = CS, SS, DS, ES, FS, GS. 
- Instruction and EFLAGS = EIP (points to the next instruction to be executed), EFLAGS (are set by arithmetic and logical instructions. They are used for conditional jump instructions).

### EFLAGS Registers

- ZF - Zero Flag is set to 1 or true if an arithmetic instruction result is zero.
- CF - Carry Flag is set to 1 if an arithmetic operation generates a borrow or carry.
- SF - Zero Flag is set when the result of an operation is negative.
- TF - Trap Flag is set during debugging. If TF is set, the processor will only execute 1 instruction at a time.

### Assembly Instructions

- Instructions consist of 2 parts - Operations and Operand/s.
- An instruction can have up to 2 operands, depending upon the instruction.
- Operands can be a register, memory location or an immediate value.
- Operations sometimes also have implied operands. For example RET instruction overrides EIP with the next value on the stack.

### Mov Instruction Explained

- mov eax, ebx
    - eax, ebx = both registers
    - mov is operation, eax and ebx are the operands
- mov eax, [ebp+var_8]
    - [ebp+var_8] = memory location 
- mov eax, 0AH
    - 0Ah = immediate value 

### Common Instructions

- Moving Data (mov and variations)
    - MOV, MOVSZ, MOVZX, LEA
- Mathematics (add, subtract, increment, decrement)
    - ADD, SUB, INC, DEC
- Logic
    - AND, OR, NOT, XOR, SHR, SHL, ROR, ROL
- Branching
    - JMP/JZ/JNZ/JG, CALL/RET, CMP/TEST     
- No Operation
    - NOP
- Stack Operations
    - PUSH/POP     

### Stack

- A stack is an important structure in program execution.
- It is used to store variables used inside a function.
- It is also used to pass arguments to functions being called.
- It works on LIFO basis (last in first out).
- Stack is limited in space and stores data for the lifetime of a function.
- Stack grows from high memory to low memory.

#5. - MITRE ATT&CK
-----------------------------------------

A matrix of attackers tactics and techniques. A tactic is the goal an attacker wants to achieve, and a technique is how the attacker achieves that goal.

### The Pyramid of Pain

This simple diagram shows the relationship between the types of indicators you might use to detect an adversary's activities and how much pain it will cause them when you are able to deny those indicators to them.

![image](https://github.com/jwardsmith/Malware-Analysis/assets/31498830/b855dab6-992f-40ce-a181-1ddecd79ec4e)

### The Pyramid Explained

Hash Values:
- Most hash algorithms compute a message digest of the entire input and output a fixed length hash that is unique to the given input.  In other words, if the contents of two files varies even by a single bit, the resultant hash values of the two files are entirely different.  SHA1 and MD5 are the two most common examples of this type of hash.
On the one hand, hash indicators are the most accurate type of indicator you could hope for.  The odds of two different files having the same hash values are so low, you can almost discount this possibility altogether. On the other hand, any change to a file, even an inconsequential one like flipping a bit in an unused resource or adding a null to the end, results in a completely different and unrelated hash value.  It is so easy for hash values to change, and there are so many of them around, that in many cases it may not even be worth tracking them.  
You may also encounter so-called fuzzy hashes, which attempt to solve this problem by computing hash values that take into account similarities in the input.  In other words, two files with only minor or moderate differences would have fuzzy hash values that are substantially similar, allowing an investigator to note a possible relationship between them.  Ssdeep is an example of a tool commonly used to compute fuzzy hashes.  Even though these are still hash values, they probably fit better at the "Tools" level of the Pyramid than here, because they are more resistant to change and manipulation.  In fact, the most common use for them in DFIR is to identify variants of known tools or malware, in an attempt to try to rectify the shortcomings of more static hashes.

IP Addresses:
- IP addresses are quite literally the most fundamental indicator.  Short of data copied from local hard drive and leaving the front door on a USB key, you pretty much have to have an network connection of some sort in order to carry out an attack, and a connection means IP Addresses.  It's at the widest part of the pyramid because there are just so many of them.  Any reasonably advanced adversary can change IP addresses whenever it suits them, with very little effort.  In some cases, if they are using a anonymous proxy service like Tor or something similar, they may change IPs quite frequently and never even notice or care.  That's why IP Addesses are green in the pyramid.  If you deny the adversary the use of one of their IPs, they can usually recover without even breaking stride.

Domain Names:
- One step higher on the pyramid, we have Domain Names (still green, but lighter).  These are slightly more of a pain to change, because in order to work, they must be registered, paid for (even if with stolen funds) and hosted somewhere.  That said, there are a large number of DNS providers out there with lax registration standards (many of them free), so in practice it's not too hard to change domains.  New domains may take anywhere up to a day or two to be visible throughout the Internet, though, so these are slightly harder to change than just IP addresses.

Network & Host Artifacts:
- Smack in the middle of the pyramid and starting to get into the yellow zone, we have the Network and Host Artifacts.  This is the level, at last, where you start to have some negative impact on the adversary.  When you can detect and respond to indicators at this level, you cause the attacker to go back to their lab and reconfigure and/or recompile their tools.  A great example would be when you find that the attacker's HTTP recon tool uses a distinctive User-Agent string when searching your web content (off by one space or semicolon, for example.  Or maybe they just put their name.  Don't laugh.  This happens!).  If you block any requests which present this User-Agent, you force them to go back and spend some time a) figuring out how you detected their recon tool, and b) fixing it.  Sure, the fix may be trivial, but at least they had to expend some effort to identify and overcome the obstacle you threw in front of them.  

Tools:
- The next level is labelled "Tools" and is definitely yellow.  At this level, we are taking away the adversary's ability to use one or more specific arrows in their quiver.  Most likely this happens because we just got so good at detecting the artifacts of their tool in so many different ways that they gave up and had to either find or create a new tool for the same purpose.  This is a big win for you, because they have to invest time in research (find an existing tool that has the same capabilities), development (create a new tool if they are able) and training (figure out how to use the tool and become proficient with it).  You just cost them some real time, especially if you are able to do this across several of their tools.
Some examples of tool indicators might include AV or Yara signatures, if they are able to find variations of the same files even with moderate changes.  Network aware tools with a distinctive communication protocol may also fit in this level, where changing the protocol would require substantial rewrites to the original tool.  Also, as discussed above, fuzzy hashes would probably fall into this level.

Tactics, Techniques & Procedures:
- Finally, at the apex are the TTPs.  When you detect and respond at this level, you are operating directly on adversary behaviors, not against their tools.  For example, you are detecting Pass-the-Hash attacks themselves (perhaps by inspecting Windows logs) rather than the tools they use to carry out those attacks.  From a pure effectiveness standpoint, this level is your ideal.  If you are able to respond to adversary TTPs quickly enough, you force them to do the most time-consuming thing possible: learn new behaviors.  

Let's think about that some more.  If you carry this to the logical extreme, what happens when you are able to do this across a wide variety of the adversary's different TTPs?  You give them one of two options:  
Give up, or
Reinvent themselves from scratch
If I were the adversary, Option #1 would probably look pretty attractive to me in this situation.

Whenever you receive new intel on an adversary, review it carefully against the Pyramid of Pain.  For every paragraph, ask yourself "Is there anything here I can use to detect the adversary's activity, and where does this fall on the pyramid?"  Sure, take all those domains and IPs and make use of them if you can, but keep in mind that the amount of pain you cause an adversary depends on the types of indicators you are able to make use of, and create your plan accordingly.
