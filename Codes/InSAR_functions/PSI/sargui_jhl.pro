FUNCTION Objfun,x,y,num_intf,dintf,ran,thit,bper,dt
  dph=DBLARR(num_intf)
  lamda=56.0
  l1=4*!pi/lamda
  fun=COMPLEX(0,0)
  dph=dintf[1,*]-dintf[0,*]
  coef_dv=l1*dt
  coef_ddh=l1*1000*bper/(ran*SIN(thit))
  FOR i=0,num_intf-1 DO BEGIN
    fun=fun+COMPLEX(COS(dph(i)-(coef_dv(i)*x+coef_ddh(i)*y)),SIN(dph(i)-(coef_dv(i)*x+coef_ddh(i)*y)))
  ENDFOR
  fun=ABS(fun)/num_intf
  RETURN,fun
END

PRO SARGUI_JHL_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'sarlist_button': begin
    ;- ͬʱ����slcӰ���б��ļ�·����slcӰ����Ŀ���������Ŀ��Ӱ�����к�
    infile=dialog_pickfile(title='Ӱ���б��ļ�',filter='*.dat',file='sarlist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).sarlist_text,set_uvalue=infile
    widget_control,(*pstate).sarlist_text,set_value=infile
    nlines=file_lines(infile)
    sarlist=strarr(nlines)
    numintf=nlines*(nlines-1)/2
    widget_control,(*pstate).numslc_text,set_uvalue=nlines
    nlines=strcompress(nlines,/remove_all)
    a=nlines
    widget_control,(*pstate).numslc_text,set_value=a
    widget_control,(*pstate).numintf_text,set_uvalue=numintf
    numintf=strcompress(numintf,/remove_all)
    widget_control,(*pstate).numintf_text,set_value=numintf
    ;- ��ȡ�ļ����к�
    openr,lun,infile,/get_lun
    readf,lun,sarlist
    free_lun,lun
    slchead=sarlist(0)+'.par'
    files=findfile(slchead,count=numfiles)
    if numfiles eq 0 then begin
      result=dialog_message(title='ͷ�ļ�','δ�ҵ�ͷ�ļ�',/information)
      return
    endif
    
    openr,lun,slchead,/get_lun
    temp=''
    for i=0,9 do begin
      readf,lun,temp
    endfor
    readf,lun,temp
    columns=(strsplit(temp,/extract))(1)
    readf,lun,temp
    lines=(strsplit(temp,/extract))(1)
    widget_control,(*pstate).numline_text,set_value=lines
    widget_control,(*pstate).numline_text,set_uvalue=lines
    widget_control,(*pstate).numpixel_text,set_value=columns
    widget_control,(*pstate).numpixel_text,set_uvalue=columns
    path=file_dirname(infile)
    files=file_search(path+'\*.incident',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='δ�ҵ�������ļ�','�뽫������ļ�����ͬһĿ¼',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).incident_text,set_value=path+'\*.incident'
    files=file_search(path+'\*.range',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='δ�ҵ�б���ļ�','�뽫б���ļ�����ͬһĿ¼',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).range_text,set_value=path+'\*.range'
    files=file_search(path+'\*.bperp.dat',count=filenum)
;    if filenum eq 0 then begin
;      result=dialog_message(title='δ�ҵ���ֱ�����ļ�','�뽫��ֱ�����ļ�����ͬһĿ¼',/information)
;      widget_control,(*pstate).sarlist_text,set_value=''
;      widget_control,(*pstate).sarlist_text,set_uvalue=''
;      return
;    endif
    widget_control,(*pstate).perp_text,set_value=path+'\*.bperp'
  end
  'itab_button': begin
    infile=dialog_pickfile(title='Ӱ������ļ�',filter='*.dat',file='itab.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).itab_text,set_uvalue=infile
    widget_control,(*pstate).itab_text,set_value=infile    
  end
  'plist_button': begin
    infile=dialog_pickfile(title='ps���б��ļ�',filter='*.dat',file='plist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).plist_text,set_value=infile
    widget_control,(*pstate).plist_text,set_uvalue=infile
    ;- �ж�ps�����Ŀ
    openr,lun,infile,/get_lun
    temp=''
    numps=0
    while ~eof(lun) do begin
      readf,lun,temp
      temp_str=strsplit(temp,')',/extract)
      temp_size=size(temp_str)
      if temp_size(1) eq 1 then begin
        numps=numps+1
      endif else begin
        numps=numps+2
      endelse
    endwhile
    widget_control,(*pstate).numps_text,set_uvalue=numps
    numps=strcompress(numps,/remove_all)
    widget_control,(*pstate).numps_text,set_value=numps
  end
  'arcs_button': begin
    infile=dialog_pickfile(title='�����ļ�',filter='*.dat',file='arcs.dat',/read)
    if infile eq '' then return
    ;- ���㻡����Ŀ
    openr,lun,infile,/get_lun
    temp=''
    numarcs=0D
    while ~eof(lun) do begin
      readf,lun,temp
      temp_str=strsplit(temp,')',/extract)
      temp_size=size(temp_str)
      if temp_size(1) eq 1 then begin
        numarcs=numarcs+1
      endif else begin
        numarcs=numarcs+2
      endelse
    endwhile
    widget_control,(*pstate).numarc_text,set_uvalue=numarcs
    numarcs=strcompress(numarcs,/remove_all)    
    widget_control,(*pstate).numarc_text,set_value=numarcs  
    widget_control,(*pstate).arcs_text,set_value=infile
    widget_control,(*pstate).arcs_text,set_uvalue=infile
  end
  'pscoor_button': begin
    infile=dialog_pickfile(title='���ps�����ļ�',filter='*.txt',file='pscoor.txt',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).pscoor_text,set_uvalue=infile
    widget_control,(*pstate).pscoor_text,set_value=infile    
  end


  'diff_button': begin
    widget_control,(*pstate).range_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='��ȡ·��ʧ��','����ָ��б���ļ�·��',/information)
    endif
    infile_path=file_dirname(infile)+'\'
    widget_control,(*pstate).diff_text,set_uvalue=infile_path
    widget_control,(*pstate).diff_text,set_value=infile_path
  end

  'dv_button': begin
    infile=dialog_pickfile(title='������ν�������',filter='*.txt',file='dv_ddh_coh.txt',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).dv_text,set_uvalue=infile
    widget_control,(*pstate).dv_text,set_value=infile
  end
  'ok': begin
    ;- �����������ļ�
    widget_control,(*pstate).sarlist_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','������Ӱ���б��ļ�',/information)
      return
    endif
    widget_control,(*pstate).itab_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','������Ӱ������ļ�',/information)
      return
    endif
    widget_control,(*pstate).plist_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','������ps���б��ļ�',/information)
      return
    endif
    widget_control,(*pstate).arcs_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','�����뻡���ļ�',/information)
      return
    endif
    widget_control,(*pstate).pscoor_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='���','��ָ��ps�������·��',/information)
      return
    endif
    widget_control,(*pstate).dv_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='���','��ָ��������������·��',/information)
      return
    endif    
  ;�ó�������ferretti���ϵ��ģ������������α������͸߳����������
  ;
  ;- ��ʼ��ȡ��������
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num_ps
  widget_control,(*pstate).numarc_text,get_uvalue=num_arc
  widget_control,(*pstate).numline_text,get_uvalue=nlines
  widget_control,(*pstate).numpixel_text,get_uvalue=npixels
;  num_slc=15
;  num_intf=num_slc*(num_slc-1)/2
;  num_ps=3211
;  num_arc=9597
;  nlines=500
;  npixels=500
  widget_control,(*pstate).incident_text,get_value=pathin
  if pathin eq '' then begin
    result=dialog_message(title='����','δ�ҵ�����·��',/information)
    return
  endif
  pathin=file_dirname(pathin)+'\'
  widget_control,(*pstate).pscoor_text,get_value=pathout
  if pathout eq '' then begin
    result=dialog_message(title='���','δ�ҵ����·��',/information)
  endif
  pathout=file_dirname(pathout)+'\'
  ;���鶨��
  pscoor=ULONARR(2,num_ps)
  wphi=FLTARR(npixels,nlines)
  wphi_ps=FLTARR(num_ps,num_intf)
  thi=FLTARR(npixels,1)
  thi_ps=FLTARR(num_ps,num_intf)
  range=DBLARR(npixels,1)
  range_ps=DBLARR(num_ps,num_intf)
  bperp=FLTARR(npixels,nlines)
  bperp_ps=FLTARR(num_ps,num_intf)
  thita=FLTARR(num_arc,num_intf)
  rg=DBLARR(num_arc,num_intf)
  bp=FLTARR(num_arc,num_intf)
  itab=LONARR(5,num_intf)
  dv_ddh_coh=FLTARR(3,num_arc)  
  ;��ȡitab�ļ�
  widget_control,(*pstate).itab_text,get_uvalue=infile
  OPENR,lun,infile,/get_lun
  READF,lun,itab
  FREE_LUN,lun  
  ;��ȡitab�е�ʱ��������ݣ��������Ϊdt������
  dt=itab[2,*]  
  ;��ȡPS���������ļ������䱣��Ϊһ��num_ps*2������pscoor[2,num_ps]
  plist=COMPLEXARR(num_ps)
  pscoor=INTARR(2,num_ps)
  widget_control,(*pstate).plist_text,get_uvalue=infile
  OPENR,lun,infile,/get_lun
  READF,lun,plist
  FREE_LUN,lun
  pscoor[0,*]=REAL_PART(plist)
  pscoor[1,*]=IMAGINARY(plist)
  widget_control,(*pstate).pscoor_text,get_uvalue=infile
;  OPENW,lun,pathout+'pscoor.txt',/get_lun
  OPENW,lun,infile,/get_lun
  PRINTF,lun,pscoor
  FREE_LUN,lun  
  ;��ȡ���������ļ����������Ϊnum_arcs*2�����飬���й���num_arcs��
  ;���У���Ԫ�ض�Ӧ�ڻ������˵���plist�ļ��е�PS�����кš�
  arctemp=COMPLEXARR(num_arc)
  noarc=INTARR(2,num_arc)
  widget_control,(*pstate).arcs_text,get_uvalue=infile
    OPENR,lun,infile,error=err,/get_lun
;  OPENR,lun,'D:\IDL\result\arcs.txt',error=err,/get_lun
  READF,lun,arctemp
  FREE_LUN,lun
  noarc[0,*]=REAL_PART(arctemp)
  noarc[1,*]=IMAGINARY(arctemp)
  
  
  
  ;- ����������
  wtlb = WIDGET_BASE(title = '������')
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='������... ���Ե�')
  Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0  
  ;ѭ����ȡ���и�����ϵ��������,�ֱ��������ǡ�б�ࡢ��ֱ���ߺͲ�ָ�����λ����
  FOR m=0,num_intf-1 DO BEGIN
    int_pair=itab(*,m)
    master=STRCOMPRESS(STRING(int_pair(0)),/remove_all)
    slave=STRCOMPRESS(STRING(int_pair(1)),/remove_all)
    incid_angle_int=master+'-'+slave+'.incident'
    range_master_int=master+'-'+slave+'.range'
    diff_str=master+'-'+slave+'.diff.phase.dat'
    bperp_str=master+'-'+slave+'.bperp.dat'
    
    ;��ȡ���и�����ϵĲ�ָ�����λ������ȡ��ӦPS���ϵ���λ����
    diffpath=pathin+diff_str
    OPENR,lun,diffpath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READU,lun,wphi
    FREE_LUN,lun
    wphi_ps[*,m]=wphi[pscoor[1,*],pscoor[0,*]]
    
    ;��ȡ���и�����ϵ�����������ļ�������ȡ��ӦPS���ϵ����������
    incidentpath=pathin+incid_angle_int
    OPENR,lun,incidentpath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READF,lun,thi
    FREE_LUN,lun
    thi_temp=REBIN(thi,npixels,nlines)
    thi_ps[*,m]=thi_temp[pscoor[1,*],pscoor[0,*]]
    
    ;��ȡ���и�����ϵ�б�������ļ�
    rangepath=pathin+range_master_int
    OPENR,lun,rangepath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READF,lun,range
    FREE_LUN,lun
    range_temp=REBIN(range,npixels,nlines)
    range_ps[*,m]=range_temp[pscoor[1,*],pscoor[0,*]]
    
    ;��ȡ���и�����ϵĴ�ֱ���������ļ�
    bperppath=pathin+bperp_str
    OPENR,lun,bperppath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READU,lun,bperp
    FREE_LUN,lun
    bperp_ps[*,m]=bperp[pscoor[1,*],pscoor[0,*]]
    Idlitwdprogressbar_setvalue, process, 10*m/num_intf;- ���ý���������
  ENDFOR
  ;-------------------------------------------
  ;����Ϊ��ռ���������
  ;���轫�ϲ���PS��λ��ȡ���²��ֽ�ռ�������Ϊ���������Ĳ˵�����
  ;���ɴ˷ֿ������²�������д�ϰ벿��һЩ���ݡ��϶�Ϊһ��ֻΪһ�ζ�ȡ
  ;���ݣ��󲿷�ֱ��ʹ���ڴ����ݡ�
  ;-------------------------------------------
  ;�����ٶ������͸߳������������������
  tt1=0.0
  tt2=0.0
  dv_low=-0.03
  dv_up=0.03
  ddh_low=-15.0
  ddh_up=15.0
  dv_size=21
  ddh_size=21
  dv_inc=(dv_up-dv_low)/(dv_size-1)
  ddh_inc=(ddh_up-ddh_low)/(ddh_size-1)
  dv_try=LINDGEN(21)*dv_inc+dv_low
  ddh_try=LINDGEN(21)*ddh_inc+ddh_low
  ;�𻡶����
  FOR i=0D,num_arc-1D DO BEGIN    
    mm=noarc[0,i]     ;��ȡ��ǰ���εĵ�һ��PS������
    nn=noarc[1,i]    ;��ȡ��ǰ���εĵڶ���PS������
    thita[i,*]=(thi_ps[mm,*]+thi_ps[nn,*])/2   ; ȡ��ǰ������PS������ǵ�ƽ��ֵ
    rg[i,*]=(range_ps[mm,*]+range_ps[nn,*])/2       ;ȡ��ǰ������PS��б���ƽ��ֵ
    bp[i,*]=(bperp_ps[mm,*]+bperp_ps[nn,*])/2     ;ȡ��ǰ������PS�㴹ֱ���ߵ�ƽ��ֵ
    ;��ǰ��ȷ���Ľ�ռ������������ɶ�άƬ��
    Meshgrid,dv_try,ddh_try,dv=dv,ddh=ddh
    xdv=REFORM(dv,1,N_ELEMENTS(dv))
    xddh=REFORM(ddh,1,N_ELEMENTS(ddh))
    ;���������ģ�͵Ķ�����
    y=Objfun(xdv,xddh,num_intf,[wphi_ps[mm,*],wphi_ps[nn,*]],rg[i,*],thita[i,*],bp[i,*],dt)
    coh=MAX(y,max_subscript)  ;��ȡ��ռ���ģ�����ϵ�����ֵ
    dv=xdv[max_subscript]      ;��ȡģ�����ϵ�����ֵ����Ӧ�������α���������
    ddh=xddh[max_subscript]    ;��ȡģ�����ϵ�����ֵ����Ӧ�ĸ߳��������
    dv_ddh_coh[*,i]=[dv,ddh,coh]
    value=long(10+90L*i/num_arc)
    Idlitwdprogressbar_setvalue, process, value ;- ���ý���������    
    
  ENDFOR
  ;��������α����ʺ͸߳���������������������ģ��ϵ��ֵ���ļ�dv_ddh_coh.txt
  OPENW,lun,pathout+'dv_ddh_coh.txt',/get_lun
  PRINTF,lun,dv_ddh_coh
  FREE_LUN,lun
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
  result=dialog_message(title='������','������������ļ�',/information)
  end
  'cl': begin
    result=dialog_message(title='�˳�','ȷ���˳���',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif else begin
      return
    endelse
  end
  else: return
endcase

END



PRO Meshgrid,x,y,dv=dv,ddh=ddh
  x_dim = N_ELEMENTS(x)
  dv=FLTARR(x_dim,x_dim)
  FOR i=0,x_dim-1 DO BEGIN
    FOR j=0,x_dim-1 DO BEGIN
      dv[j,i]=x[j]
    ENDFOR
  ENDFOR
  y_dim=N_ELEMENTS(y)
  y=TRANSPOSE(y)
  ddh=FLTARR(y_dim,y_dim)
  FOR i=0,y_dim-1 DO BEGIN
    FOR j=0,y_dim-1 DO BEGIN
      ddh[j,i]=y[j]
    ENDFOR
  ENDFOR
END



PRO SARGUI_JHL,EVENT
;- �����������
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='�����������',tlb_frame_attr=1,column=1,xsize=356,ysize=480,xoffset=xoffset,yoffset=yoffset)
;- ��������label
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
label=widget_label(tlb,value='�����ļ�:',/align_left)
;- ����Ӱ���б��ļ��������
sarlistID=widget_base(tlb,row=1)
sarlist_text=widget_text(sarlistID,value='',uvalue='',uname='sarlist_text',/editable,xsize=40)
sarlist_button=widget_button(sarlistID,value='Ӱ���б��ļ�',uname='sarlist_button',xsize=90)
;- ����Ӱ������ļ��������
itabID=widget_base(tlb,row=1)
itab_text=widget_text(itabID,value='',uvalue='',uname='itab_text',/editable,xsize=40)
itab_button=widget_button(itabID,value='Ӱ������ļ�',uname='itab_button',xsize=90)
;- ����ps���б��ļ��������
plistID=widget_base(tlb,row=1)
plist_text=widget_text(plistID,value='',uvalue='',uname='plist_text',/editable,xsize=40)
plist_button=widget_button(plistID,value='ps�б��ļ�',uname='plist_button',xsize=90)
;- ���������ļ��������
arcsID=widget_base(tlb,row=1)
arcs_text=widget_text(arcsID,value='',uvalue='',uname='arcs_text',/editable,xsize=40)
arcs_button=widget_button(arcsID,value='�����ļ�',uname='arcs_button',xsize=90)

;- ����label���
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
label=widget_label(tlb,value='�����ļ�·��:',/align_left)
;;- ���������ļ�
;diffID=widget_base(tlb,row=1)
;label=widget_label(diffID,value='�������·��:',xsize=90)
;diff_text=widget_text(diffID,value='',uvalue='',uname='diff_text',/editable,xsize=40)
;- ����������ļ�
incidentID=widget_base(tlb,row=1)
label=widget_label(incidentID,value='������ļ�:',xsize=90)
incident_text=widget_text(incidentID,value='',uvalue='',uname='incident_text',/editable,xsize=40)
;- ����б���ļ�
rangeID=widget_base(tlb,row=1)
label=widget_label(rangeID,value='б���ļ�:',xsize=90)
range_text=widget_text(rangeID,value='',uvalue='',uname='range_text',/editable,xsize=40)
;- ������ֱ�����ļ�
perpID=widget_base(tlb,row=1)
label=widget_label(perpID,value='��ֱ�����ļ�:',xsize=90)
perp_text=widget_text(perpID,value='',uvalue='',uname='perp_text',/editable,xsize=40)

;- ����������ȡ����
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='slcӰ����Ŀ:',xsize=80)
numslc_text=widget_text(texttlb,value='',uvalue='',uname='numslc_text',xsize=12)
label=widget_label(texttlb,value='�������Ŀ:',xsize=80)
numintf_text=widget_text(texttlb,value='',uvalue='',uname='numintf_text',xsize=12)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='ps����Ŀ:',xsize=80)
numps_text=widget_text(texttlb,value='',uvalue='',uname='numps_text',xsize=12)
label=widget_label(texttlb,value='������Ŀ:',xsize=80)
numarc_text=widget_text(texttlb,value='',uvalue='',uname='numarc_text',xsize=12)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='Ӱ������:',xsize=80)
numline_text=widget_text(texttlb,value='',uvalue='',uname='numline_text',xsize=12)
label=widget_label(texttlb,value='Ӱ������:',xsize=80)
numpixel_text=widget_text(texttlb,value='',uvalue='',uname='numpixel_text',xsize=12)
;- ��������label
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
label=widget_label(tlb,value='����ļ�:',/align_left)

;- ����ps���������ļ�
pscoorID=widget_base(tlb,row=1)
pscoor_text=widget_text(pscoorID,value='',uvalue='',uname='pscoor_text',/editable,xsize=40)
pscoor_button=widget_button(pscoorID,value='ps�����ļ�',uname='pscoor_button',xsize=90)
;- �����α������ļ�
dvID=widget_base(tlb,row=1)
dv_text=widget_text(dvID,value='',uvalue='',uname='dv_text',/editable,xsize=40)
dv_button=widget_button(dvID,value='��������',uname='dv_button',xsize=90)
;- �������ܰ�ť
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='��ʼ����',uname='ok')
cl=widget_button(funID,value='�˳�',uname='cl')
;- �����ļ�ָ��
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,arcs_text:arcs_text,arcs_button:arcs_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numarc_text:numarc_text,numline_text:numline_text,numpixel_text:numpixel_text, $
       pscoor_text:pscoor_text,incident_text:incident_text,range_text:range_text, $
       perp_text:perp_text,dv_text:dv_text,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_jhl',tlb,/no_block
END