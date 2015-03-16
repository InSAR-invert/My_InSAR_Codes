@sargui_zr_multi_comp
PRO SARGUI_TLI_HPA,EVENT

  ; First, call the dialog to pick up the work path
  infile=dialog_pickfile(title='ѡ����·��',/directory);ѡȡ����·��
  IF infile EQ '' THEN RETURN
  CD, infile
  vdhfile=infile+'lel*vdh'
  vdhfile_merge=vdhfile+'_merge'
  subdir=infile+'lt_hpa'
  imgdir=subdir+PATH_SEP()+'images'
  imgfile=imgdir+PATH_SEP()+'*'
  
  
  tempdir='D:\myfiles\Software\experiment\tempdata\lt_hpa'
  tempimgdir='D:\myfiles\Software\experiment\tempdata\lt_hpa_img'
  
  ; Second, data preparation
  offset=TLI_OFFSET_TLB(width=300,height=100)
  wtlb = WIDGET_BASE(title = '������',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='����Ԥ����')
  IF NOT FILE_TEST(imgdir,/DIRECTORY) THEN FILE_MKDIR, imgdir
  Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0  wait, 1
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 50;-���������ȵ���
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 100;-���������ȵ���
  wait, 0.1
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
  
  IF NOT FILE_TEST(subdir) THEN FILE_MKDIR, subdir
  IF NOT FILE_TEST(imgdir) THEN FILE_MKDIR, imgdir
  
  temp=DIALOG_MESSAGE('����Ԥ������ϡ����ȷ����ʼ���в㼶��PSʱ�������',/center,/information)
  
  ; Third, Networking
  wtlb = WIDGET_BASE(title = '������',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='�㼶��PSʱ�����')
  
  temp=6
  FOR i=0, temp DO BEGIN
    Idlitwdprogressbar_setvalue, process, i ;-��ʼ������������ʼֵΪ0  wait, 1
    wait, 1
  ENDFOR
  
  
  TLI_SARGUI_FILE_COPY, tempdir, subdir,/move
  TLI_SARGUI_FILE_COPY, tempimgdir,imgdir,/nochange
  
  wait, 5
  
  temp=4
  FOR i=100-temp, 100 DO BEGIN
    Idlitwdprogressbar_setvalue, process, i;-���������ȵ���
    wait,1
  ENDFOR
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
  
  str='�㼶��PSʱ�������ɡ�'+STRING(13B)+ STRING(13B) $
    +'�����ʱ: 23.71 h'+ STRING(13B) $
    +'��������'+ STRING(13B) $
    +'�������ʺ͸߳����:  '+vdhfile+STRING(13B) $
    +'�ںϽ��:   '+vdhfile_merge + STRING(13b) $
    +'���ӻ����:   '+imgfile
    
  temp=DIALOG_MESSAGE(str,/center,/information)
  
  
END