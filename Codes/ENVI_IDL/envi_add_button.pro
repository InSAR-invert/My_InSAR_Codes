PRO Envi_file_info_define_buttons, buttonInfo
; �������˵�-��Basic Tools�˵�ǰ��
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '�Զ���˵�after', $
    /MENU, REF_VALUE = 'Basic Tools', /SIBLING, POSITION = 'after'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '�Զ���˵�before', $
    /MENU, REF_VALUE = 'Basic Tools', /SIBLING, POSITION = 'before'
    
;�����Ӳ˵�
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '���ܶ����ˣ���ӵ��ɶ�أ�', $
    uValue = '', $
    event_pro ='Envi_file_info', $
    REF_VALUE = '�Զ���˵�before'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = 'ȷʵ���üӣ�', $
    uValue = '', $
    event_pro ='Envi_file_info', $
    REF_VALUE = '�Զ���˵�before'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '�ӷָ���զ����', $
    uValue = '', $
    event_pro ='Envi_file_info',$
    REF_VALUE = '�Զ���˵�before' , $
    /SEPARATOR
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '�����ģ��Ӹ���', $
    uValue = '', $
    event_pro ='Envi_file_info', $
    REF_VALUE = '�Զ���˵�before', POSITION = 'first'    
    
;������ʾ�˵�
ENVI_DEFINE_MENU_BUTTON, buttonInfo, $
    VALUE = '�Զ���˵�', $
    /Display, $
    /MENU, REF_VALUE = 'File', $
    /SIBLING, POSITION = 'after'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, $
    VALUE = '����֪����ɶ��', $
    UValue =' ', $
    /Display, $
    event_pro ='Envi_file_info', $
    REF_VALUE = '�Զ���˵�'   
    
END
;+
;escription:
;    ENVI query image
; Author: DYQ 2009-5-15;
;
PRO Envi_file_info,event
; COMPILE_OPT STRICTARR

;ѡ���ļ�
ENVI_OPEN_FILE, fname, r_fid=fid

;����Ч�򷵻�
IF fid[0] EQ -1 THEN BEGIN
    msg = DIALOG_MESSAGE('δ���ļ������ݴ���',/Error)
    RETURN
ENDIF

;������Ϣ��ѯ
ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, fname=fname
;��ʾ
msg = DIALOG_MESSAGE('�����ļ�����'+ fName + STRING(13B)+ $
    ';��������'+STRING(nb)+ STRING(13B)+ $
';��С��'+STRING(ns)+'*'+STRING(nl),$
/Information)

END