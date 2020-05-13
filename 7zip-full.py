# -*- coding: GBK -*-
import time, os, re

# ��ȡGit��֧
name_list = os.popen('git branch').read().strip().split("\n")
branch_name = ''
for name in name_list:
	if name[0:1] == '*':
		branch_name = name[2:]

# �ж��Ƿ������л���֧
if branch_name != 'publish':
	print 'Error: current branch(%s) is not on git publish!' % (branch_name)
	exit()

# ��ȡMY.lua�ļ��еĲ���汾��
str_version = "0x0000000"
for line in open("MY_!Base/src/MY.lua"):
	if line[6:15] == "_VERSION_":
		str_version = line[22:25]

# ��ȡGit�����İ汾��
version_list = os.popen('git tag').read().strip().split("\n")
max_version, git_tag = 0, ''
for version in version_list:
	if max_version < int(version[1:]):
		git_tag = version
		max_version = int(version[1:])

# �ж��Ƿ����������汾��
if int(str_version) <= max_version:
	print 'Error: current version(%s) is smaller than or equals with last git published version(%d)!' % (str_version, max_version)
	exit()

# ƴ���ַ�����ʼѹ���ļ�
dst_file = "!src-dist/releases/MY_" + time.strftime("%Y%m%d%H%M%S", time.localtime()) + "_v" + str_version + ".7z"
print "zippping..."
os.system("7z a -t7z " + dst_file + " -xr!manifest.dat -xr!manifest.key -xr!publisher.key -x@7zipignore.txt")
print "File(s) compressing acomplete!"
print "Url: " + dst_file

time.sleep(5)
print('Exiting...')
