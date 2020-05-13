#!/usr/bin/env python
# -*- coding: utf-8 -*-
from l_converter import *

def zhcn2zhtw(sentence):
    '''
    ��sentence�еļ�����תΪ������
    :param sentence: ��ת���ľ���
    :return: �������м�����ת��Ϊ������֮��ľ���
    '''
    return Converter('zh-hant').convert(sentence)

def zhtw2zhcn(sentence):
    '''
    ��sentence�еķ�����תΪ������
    :param sentence: ��ת���ľ���
    :return: �������з�����ת��Ϊ������֮��ľ���
    '''
    return Converter('zh-hans').convert(sentence)
