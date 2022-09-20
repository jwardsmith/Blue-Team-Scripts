#!/usr/bin/python3 -tt

# create_for508_mounts.py will generate custom mount point directories for exercises in the SANS FOR508 class.  Run "python create_for508_mounts.py -h" for usage details.
# by Mike Pilkington
# version 3.0

# History:
# Version 1.0 - create standard custom mount points
# Version 1.1 - updated to additionally create mount points for carved volume shadow copies
# Version 3.0 - converted from Python 2 to 3 (using '2to3' utility)

import os
import argparse

parser=argparse.ArgumentParser()

parser.add_argument('dir_suffix', help='Provide a descriptive suffix to append to new mount point directories.  For example, "nfury" will create /mnt/ewf_nfury, /mnt/windows_nfury, /mnt/vss_nfury, /mnt/vsscarve_nfury, /mnt/shadow_nfury, /mnt/shadow_nfury/vss*, /mnt/shadowcarve_nfury, and /mnt/shadowcarve_nfury/vss* directories. This argument is required.')
parser.add_argument('-n','--vss-number', type=int, nargs="?", dest="number", default=50, help='Optionally provide the number of vss subdirectories to create. The default is 50.')
parser.add_argument('-b','--base-path', nargs="?", dest="base", default='/mnt', help='Optionally provide the base path to create the mount directories. The default is "/mnt" (and must be run as root).')


args=parser.parse_args()

# Remove trailing slash if provided in base-path argument:
#if args.base[-1] is "/":
if args.base[-1] == "/":
    base_path = args.base[0:-1]
else:
    base_path = args.base


def createdir(directory):
    try:
        if os.path.exists(directory):
            print(('Error: Directory already exists: ' +  directory))
        else:
            os.makedirs(directory)
    except OSError:
        print(('Error: Creating directory. ' +  directory + ' (Must run as root for default base-path of /mnt)'))
        
# Generate base mount point directories:
createdir(base_path + '/ewf_' + args.dir_suffix)
createdir(base_path + '/windows_' + args.dir_suffix)
createdir(base_path + '/vss_' + args.dir_suffix)
createdir(base_path + '/vsscarve_' + args.dir_suffix)
createdir(base_path + '/shadow_' + args.dir_suffix)
createdir(base_path + '/shadowcarve_' + args.dir_suffix)
# Generate vss* subdirectories:
for num in range(args.number):
    createdir(base_path + '/shadow_' + args.dir_suffix +'/vss' + str(num + 1))
for num in range(args.number):
    createdir(base_path + '/shadowcarve_' + args.dir_suffix +'/vss' + str(num + 1))

