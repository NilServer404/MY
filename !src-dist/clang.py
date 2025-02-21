# -*- coding: utf-8 -*-
# pip install pyinstaller
# pyinstaller --onefile convert-lang.py

'''
    File name: convert-lang.py
    Author: Emil Zhai
    Python Version: 3.7
'''

import codecs, json, os, re, sys, time
import plib.utils as utils
import plib.environment as env
from plib.language.converter import Converter

FILE_MAPPING = {
    'zhcn.lang': { 'out': 'zhtw.lang', 'type': 'lang' },
    'zhcn.jx3dat': { 'out': 'zhtw.jx3dat', 'type': 'lang' },
    'info.ini': { 'out': 'info.ini.zh_TW', 'type': 'info' },
    'package.ini': { 'out': 'package.ini.zh_TW', 'type': 'package' },
}
FILE_MAPPING_RE = [
    { 'pattern': r'(.*)\.zhcn\.jx3dat', 'out': r'\1.zhtw.jx3dat', 'type': 'lang' },
]
FOLDER_MAPPING = {
    # 'zhcn': { 'out': 'zhtw', 'type': 'lang' },
}
IGNORE_FOLDER = ['.git', '@DATA']

def __load_crc_cache(root_path):
    crcs = {}
    crc_file = os.path.join(root_path, '__pycache__' + os.path.sep + 'file.crc.json')
    if os.path.isfile(crc_file):
        with open(crc_file, 'r') as f:
            print('Crc cache loaded: ' + crc_file)
            crcs = json.load(f)
    return crcs

def __save_crc_cache(root_path, crcs):
    if not os.path.exists(os.path.join(root_path, '__pycache__')):
        os.mkdir(os.path.join(root_path, '__pycache__'))
    crc_file = os.path.join(root_path, '__pycache__' + os.path.sep + 'file.crc.json')
    with open(crc_file, 'w') as file:
        print('--------------------------------')
        file.write(json.dumps(crcs))
        print('Crc cache saved: ' + crc_file)

def __is_path_include(pkg_name, cwd, d):
    if env.is_interface_path(cwd) and os.path.isfile(os.path.join(cwd, d)):
        return False
    if d in IGNORE_FOLDER:
        return False
    if not env.is_interface_path(cwd) and env.is_interface_path(os.path.dirname(cwd)) and pkg_name != '':
        if os.path.basename(cwd) == pkg_name:
            return True
        elif os.path.exists(os.path.join(cwd, 'package.ini')):
            return 'dependence=' + pkg_name in open(os.path.join(cwd, 'package.ini')).read()
        elif os.path.exists(os.path.join(cwd, 'info.ini')):
            return 'dependence=' + pkg_name in open(os.path.join(cwd, 'info.ini')).read()
        return False
    return True

def convert_progress(argv):
    params = {}
    cwd = os.getcwd()
    start_time = time.time() * 1000
    converter = Converter('zh-TW')

    param_accept_arg = {
        "--path": True,
    }

    for idx, param in enumerate(argv):
        if (param in param_accept_arg) and idx < len(argv):
            params[param] = argv[idx + 1]
        else:
            params[param] = ""

    if not '--path' in params:
        params['--path'] = os.path.abspath(os.getcwd())

    # get interface root path
    pkg_name = ''
    root_path = params['--path']
    header_file = os.path.join(root_path, 'header.tpl.lua')
    if (not env.is_interface_path(root_path)) and env.is_interface_path(os.path.dirname(root_path)):
        pkg_name = os.path.basename(root_path)
        root_path = os.path.dirname(root_path)

    print('--------------------------------')
    print('Working DIR: ' + root_path)
    print('Working PKG: ' + (pkg_name or 'ALL'))
    crcs = __load_crc_cache(root_path) if not '--no-cache' in params else {}

    header = ''
    header_changed = False
    if os.path.exists(header_file):
        for _, line in enumerate(codecs.open(header_file,'r',encoding='gbk')):
            header = header + line
        print('Header loaded: ' + header_file)
        crc_header = utils.get_file_crc(header_file)
        relpath = header_file.replace(root_path, '')
        if crc_header != crcs.get(relpath):
            header_changed = True
            crcs[relpath] = crc_header
    header_sys = re.sub(r'(?s)-- lib apis caching.*?([-]+)', r'\1', header)

    cpkg = ''
    cpkg_path = '?'

    for cwd, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if __is_path_include(pkg_name, cwd, d)]
        files[:] = [d for d in files if __is_path_include(pkg_name, cwd, d)]

        #for dirname in dirs:
        #    print("cwd is:" + cwd)
        #    print("dirname is" + dirname)

        # for filename in files:
        #     print(cwd, filename)

        for filename in files:
            foldername = os.path.basename(cwd)
            basename, extname = os.path.splitext(filename)
            filepath = os.path.join(cwd, filename)
            relpath = filepath.replace(root_path, '')
            crc_changed = False

            if extname == '.lua' and header != '' and basename != pkg_name and not (filename.startswith('src.') and filename.endswith('.lua')): # src.lua
                print('--------------------------------')
                print('Update header: ' + filepath)
                crc_text = utils.get_file_crc(filepath)
                if not crc_changed:
                    crc_changed = crc_text != crcs.get(relpath)
                if header_changed or crc_changed:
                    all_the_text = ''
                    for count, line in enumerate(codecs.open(filepath,'r',encoding='gbk')):
                        all_the_text = all_the_text + line
                    if all_the_text.find('-- lib apis caching') != -1:
                        ret_text = re.sub(r'(?s)([-]+)\n-- these global functions are accessed all the time by the event handler\n-- so caching them is worth the effort\n\1.*?\n\1\n', header, all_the_text)
                    else:
                        ret_text = re.sub(r'(?s)([-]+)\n-- these global functions are accessed all the time by the event handler\n-- so caching them is worth the effort\n\1.*?\n\1\n', header_sys, all_the_text)

                    if all_the_text != ret_text:
                        print('File saving...')
                        with codecs.open(filepath,'w',encoding='gbk') as f:
                            f.write(ret_text)
                            print('File saved...')
                        crc_text = utils.get_file_crc(filepath)
                    else:
                        print('Already up to date.')
                    crcs[relpath] = crc_text
                else:
                    print('Already up to date.')

            fileType = None
            fileOut = None
            if foldername in FOLDER_MAPPING:
                info = FOLDER_MAPPING[foldername]
                fileType = info['type']
                folderOut = os.path.abspath(os.path.join(cwd, '..', info['out']))
                fileOut = converter.convert(filename)
            elif filename in FILE_MAPPING:
                info = FILE_MAPPING[filename]
                fileType = info['type']
                folderOut = cwd
                fileOut = info['out']
            else:
                for p in FILE_MAPPING_RE:
                    out = re.sub(p['pattern'], p['out'], filename)
                    if out != filename:
                        info = p
                        fileType = info['type']
                        folderOut = cwd
                        fileOut = out
            if fileType and folderOut and fileOut:
                print('--------------------------------')
                print('Convert language: ' + filepath)
                crc_text = utils.get_file_crc(filepath)
                if not crc_changed:
                    crc_changed = crc_text != crcs.get(relpath)
                if fileType == 'package':
                    cpkg = cwd[cwd.rfind('\\') + 1:]
                    cpkg_path = cwd
                if crc_changed:
                    try:
                        all_the_text = ""
                        for count, line in enumerate(codecs.open(filepath,'r',encoding='gbk')):
                            if fileType == 'lang' and count == 0 and line.find('-- language data') == 0:
                                all_the_text = line.replace('zhcn', 'zhtw')
                            else:
                                all_the_text = all_the_text + line
                        print('File converting...')

                        # fill missing package
                        if fileType == 'info' and cwd.find(cpkg_path) == 0 and all_the_text.find('package=') == -1:
                            all_the_text = all_the_text.rstrip() + '\npackage=' + cpkg + '\n'
                            with codecs.open(filepath,'w',encoding='gbk') as f:
                                f.write(all_the_text)
                                print('File saved: ' + filepath)
                            crc_text = utils.get_file_crc(filepath)

                        # all_the_text = all_the_text.decode('gbk')
                        all_the_text = converter.convert(all_the_text)

                        print('File saving...')
                        if not os.path.exists(folderOut):
                            os.mkdir(folderOut)
                        with codecs.open(os.path.join(folderOut, fileOut),'w',encoding='utf8') as f:
                            f.write(all_the_text)
                            print('File saved: ' + fileOut)
                        crcs[relpath] = crc_text
                    except Exception as e:
                        crcs[relpath] = str(e)
                else:
                    print('Already up to date.')

    if not '--no-cache' in params:
        __save_crc_cache(root_path, crcs)

    print('--------------------------------')
    print('Process finished in %dms...' % (time.time() * 1000 - start_time))
    print('--------------------------------')

    if not '--no-pause' in params:
        time.sleep(10)

if __name__ == "__main__":
    env.set_packet_as_cwd()
    try:
        argv
    except NameError:
        argv = sys.argv[1:]
    else:
        pass
    convert_progress(argv)
