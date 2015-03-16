FUNCTION TLI_OFFSET_TLB,width=width, height=height
  ;Return the offset value of the top level button.
  IF NOT KEYWORD_SET(width) THEN width=0
  IF NOT KEYWORD_SET(height) THEN height=0
  
  screensize=GET_SCREEN_SIZE()
  c_pos=screensize/2
  tlb_size=[width, height]
  offset=c_pos-tlb_size/2
  RETURN, offset
END

PRO TLI_SARGUI_FILE_COPY,sourcedir, targetdir,nochange=nochange, move=move

  files=FILE_SEARCH(sourcedir, '*')
  find=STRMID(files, 0,1)
  
  find_final=SORT(find)
  nfiles=N_ELEMENTS(find_final)
  
  FOR i=0, nfiles-1 DO BEGIN
  
    fname_i=FILE_BASENAME(files[i])
    fname_orig=fname_i
    str_len=STRLEN(fname_i)
    fname_i=STRMID(fname_i, 2, str_len-2)
    fname_tar=targetdir+PATH_SEP()+fname_i
    
    IF KEYWORD_SET(nochange) THEN fname_tar=targetdir+PATH_SEP()+fname_orig
    
    IF KEYWORD_SET(move) THEN BEGIN
      fname_tar=targetdir+PATH_SEP()+fname_orig
      FILE_MOVE, files[i], fname_tar,/overwrite
    ENDIF ELSE BEGIN
      FILE_COPY, files[i], fname_tar,/overwrite
    ENDELSE
  ;    wait, 0.5
  ENDFOR
  
  
END

PRO SARGUI_ZR_MULTI_COMP,EVENT
  ; First, call the dialog to pick up the work path
  infile=dialog_pickfile(title='ѡ����·��',/directory);ѡȡ����·��
  IF infile EQ '' THEN RETURN
  CD, infile
  IF NOT TLI_HAVESEP(infile) THEN infile=infile+PATH_SEP()
  subdir=infile+'zr_multi_comp'
  imgdir=subdir+PATH_SEP()+'img'
  imgfile=imgdir+PATH_SEP()+'*.jpg
  
  IF NOT TLI_HAVESEP(subdir) THEN subdir=subdir+PATH_SEP()
  
  vfile=subdir+'zr_v'
  dvfile=subdir+'zr_dv'
  seasonfile=subdir+'zr_season'
  
  
  tempdir='D:\myfiles\Software\experiment\tempdata\zr_components'
  tempimgdir='D:\myfiles\Software\experiment\tempdata\zr_components_img'
  ; Second, data preparation
  offset=TLI_OFFSET_TLB(width=300,height=100)
  wtlb = WIDGET_BASE(title = '������',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='����Ԥ����')
  
  IF NOT FILE_TEST(subdir) THEN FILE_MKDIR, subdir
  IF NOT FILE_TEST(imgdir) THEN FILE_MKDIR, imgdir
  
  Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0  wait, 1
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 50;-���������ȵ���
  wait, 0.1
  
  
  wait, 5
  Idlitwdprogressbar_setvalue, process, 98;-���������ȵ���
  wait, 0.1
  
  Idlitwdprogressbar_setvalue, process, 99;-���������ȵ���
  wait, 0.1
  
  
  
  Idlitwdprogressbar_setvalue, process, 100;-���������ȵ���
  wait, 0.1
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
  
  temp=DIALOG_MESSAGE('����Ԥ������ϡ����ȷ����ʼ���ж����ʱ�������',/center,/information)
  
  ; Third, Networking
  wtlb = WIDGET_BASE(title = '������',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='�����ʱ�����')
  
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
  
  str='�����ʱ�������ɣ���������'+ STRING(13B)+STRING(13B) $
    +'��������:  '+vfile+STRING(13B) $
    +'���ٶȷ���:   '+dvfile + STRING(13b) $
    +'�����Գ�������:   '+seasonfile+ STRING(13b) $
    +STRING(13B) $
    +'���ӻ����:   '+ imgfile
    
  temp=DIALOG_MESSAGE(str,/center,/information)
  
  
  
END