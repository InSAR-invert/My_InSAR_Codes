@sargui_zr_multi_comp

PRO SARGUI_ZR_NETWORK,EVENT
  ; First, call the dialog to pick up the work path
  infile=dialog_pickfile(title='ѡ����·��',/directory);ѡȡ����·��
  IF infile EQ '' THEN RETURN
  CD, infile
  IF NOT TLI_HAVESEP(infile) THEN infile=infile+PATH_SEP()
  subdir=infile+'zr_networking'
  imgdir=subdir+PATH_SEP()+'img'
  imgfile=imgdir+PATH_SEP()+'*.jpg'
  
  tempdir='D:\myfiles\Software\experiment\tempdata\zr_networking'
  tempimgdir='D:\myfiles\Software\experiment\tempdata\zr_networking_img'
  ; Second, data preparation
  offset=TLI_OFFSET_TLB(width=300,height=100)
  wtlb = WIDGET_BASE(title = '������',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='����Ԥ����')
  Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0  wait, 1
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 50;-���������ȵ���
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 100;-���������ȵ���
  wait, 0.1
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
  
  IF NOT FILE_TEST(subdir, /DIRECTORY) THEN FILE_MKDIR, subdir
  IF NOT FILE_TEST(imgdir,/DIRECTORY) THEN FILE_MKDIR, imgdir
  
  temp=DIALOG_MESSAGE('����Ԥ������ϡ����ȷ����ʼ��������ģ�͡�',/center,/information)
  
  ; Third, Networking
  wtlb = WIDGET_BASE(title = '������',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='��������ģ��')
  
  temp=6
  FOR i=0, temp DO BEGIN
    Idlitwdprogressbar_setvalue, process, i ;-��ʼ������������ʼֵΪ0  wait, 1
    wait, 1
  ENDFOR
  
  
  
;  Idlitwdprogressbar_setvalue, process, 50;-���������ȵ���
  
  TLI_SARGUI_FILE_COPY, tempdir, subdir
  TLI_SARGUI_FILE_COPY, tempimgdir, imgdir
  
  
  wait, 5
  temp=4
  FOR i=100-temp, 100 DO BEGIN
    Idlitwdprogressbar_setvalue, process, i;-���������ȵ���
    wait,1
  ENDFOR
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
  
  str='���������������'+STRING(13B) $
      +'�����ʱ��3.6 h' $
      +STRING(13B) $
      +'���ӻ����:   '+imgfile
  temp=DIALOG_MESSAGE(str,/center,/information)
  
  
  
END