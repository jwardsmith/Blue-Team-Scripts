# Volatility Cheat Sheet

Volatility is a framework for performing digital investigations on Windows, Linux, and Mac memory images.

- Run Volatility

```
# vol.py -f <memory image> --profile=<profile> <plugin>
# vol.py -f memory.dmp --profile=Win10x64_19041 <plugin>
```

- List help for a module

```
# vol.py malfind -h
```

### Preliminary Tools

- Find and decrypt KDBG structure to help identify system profile (determine the OS and build) (match the Build string with the Profile suggestion)

```
# vol.py -f memory.dmp kdbgscan
```
