#!/usr/bin/env python3

import subprocess
import argparse

project_name = 'ptrk/downtrodden'

channel_names = {
    'windows': 'win-64',
    'mac': 'osx-universal',
    'linux': 'linux-64'
}

upload_paths = {
    'windows': './export/windows',
    'mac': './export/mac/downtrodden.zip',
    'linux': './export/linux'
}

version_file_path = './version.txt'

def push_build(platform):
    # Clean export folder
    subprocess.check_call(['make', 'clean'])
    # Make the platform
    subprocess.check_call(['make', platform])
    # Call butler on the directory
    subprocess.call(['butler', 'push', '--fix-permissions', '--userversion-file={0}'.format(version_file_path), upload_paths[platform], '{0}:{1}'.format(project_name, channel_names[platform])])

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--platform', help='Specify a platform to push to. If not specified, all platforms are pushed', choices=channel_names.keys())
    args = parser.parse_args()

    if (args.platform is not None):
        print('Pushing {0}'.format(args.platform))
        push_build(args.platform)
    else:
        print('Pushing all platforms')
        for p in channel_names.keys():
            push_build(p)
