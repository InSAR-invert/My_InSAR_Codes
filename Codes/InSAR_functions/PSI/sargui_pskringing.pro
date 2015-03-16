
PRO SARGUI_PSKRINGING_EVENT,EVENT
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
  'herr_button': begin
    infile=dialog_pickfile(title='����߳�����ļ�',filter='*.txt',file='H.txt',/read)
    if infile eq '' then return
    widget_control,(*pstate).herr_text,set_uvalue=infile
    widget_control,(*pstate).herr_text,set_value=infile
  end
  'v_button': begin
    infile=dialog_pickfile(title='�������α������ļ�',filter='*.txt',file='V.txt',/read)
    if infile eq '' then return
    widget_control,(*pstate).v_text,set_uvalue=infile
    widget_control,(*pstate).v_text,set_value=infile
  end
  'interh_button': begin
    infile=dialog_pickfile(title='�߳�����ֵ���',filter='*.dat',file='H_map.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).interh_text,set_uvalue=infile
    widget_control,(*pstate).interh_text,set_value=infile
  end
  'interv_button': begin
    infile=dialog_pickfile(title='���α����ʲ�ֵ���',filter='*.dat',file='V_map.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).interv_text,set_uvalue=infile
    widget_control,(*pstate).interv_text,set_value=infile
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
    widget_control,(*pstate).herr_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','��ָ���߳��������·��',/information)
      return
    endif    
    widget_control,(*pstate).v_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','��ָ�����α���������·��',/information)
      return
    endif 
  ;�ó�������ferretti���ϵ��ģ������������α������͸߳����������
  ;
  ;- ��ʼ��ȡ��������
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num_ps
  widget_control,(*pstate).numline_text,get_uvalue=nlines
  widget_control,(*pstate).numpixel_text,get_uvalue=npixels
;  num_slc=15
;  num_intf=num_slc*(num_slc-1)/2
;  num_ps=3211
;  num_arc=9597
;  nlines=500
;  npixels=500
  
  widget_control,(*pstate).sarlist_text,get_value=infile
  day=file_lines(infile)  
;  day=15
compu=day(0)*(day(0)-1)/2
itab=lonarr(5,compu)
  widget_control,(*pstate).numps_text,get_uvalue=num
;num=3211
PS=complexarr(num)

dh=fltarr(num)
V=fltarr(num)
  widget_control,(*pstate).itab_text,get_value=infile
openr,lun,infile,/get_lun
readf,lun,itab
free_lun,lun
  widget_control,(*pstate).numline_text,get_uvalue=height
  widget_control,(*pstate).numpixel_text,get_uvalue=width
;  - �ļ���С
;  width=500
;  height=500

;pathin='D:\IDL\xiqing\'
;pathout='D:\IDL\result\'

;��ȡPS��λ��Ϣ
  widget_control,(*pstate).plist_text,get_value=infile
  openr,lun,infile,/get_lun
  readf,lun,PS
  free_lun,lun
  
  x1=long(real_part(PS))
  y1=long(imaginary(PS))
  
;��ȡ����������α�����V�͸߳����dh
;-----------------------------------------
  widget_control,(*pstate).herr_text,get_value=infile
  openr,lun,infile,/get_lun
  readf,lun,dh
  FREE_LUN,lun  
  widget_control,(*pstate).v_text,get_value=infile
  openr,lun,infile,/get_lun
  readf,lun,V
  FREE_LUN,lun  

;-----------------------------------------
array=indgen(floor(num/20))*20
vv=V(array)
vv=abs(vv)
hh=dh(array)
hh=abs(hh)
x=x1(array)
y=y1(array)
;print,'Insert processing is doing...'

;�ֱ��ڲ������α������͸߳����
e=[60,0]
;V_map=krig2d(V,x1,y1,expon=e,GS=[1,1],Bounds=[0,0,width,height])
V_map=krig2d(vv,x,y,expon=e,GS=[1,1],Bounds=[0,0,width-1,height-1])
;window,/free
;shade_surf,V_map

;print,'First step is over. Please waiting a moment!'
e=[40,10]
H_map=krig2d(hh,x,y,expon=e,GS=[1,1],Bounds=[0,0,width-1,height-1])
;window,/free
;shade_surf,H_map  
  
;���������α������͸߳����
widget_control,(*pstate).interv_text,get_value=infile
openw,lun,infile,/get_lun
writeu,lun,V_map
free_lun,lun
widget_control,(*pstate).interh_text,get_value=infile
openw,lun,infile,/get_lun
writeu,lun,H_map
free_lun,lun
  result=dialog_message(title='�����α������͸߳����','�ļ�������',/information)
    
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


PRO SARGUI_PSKRINGING,EVENT
;- ������ֵ������PS������α������Լ��߳�����ֵ�õ�
;- ����Ӱ������α������Լ��߳��������ļ�����itab.
;- txt, plist.txt, H.txt, V.txt������ļ�����V_
;- map.dat, H_map.dat
;- �����������
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='�����α�͸߳�����ֵ',tlb_frame_attr=1,column=1,xsize=356,ysize=390,xoffset=xoffset,yoffset=yoffset)
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
;- �����߳�����ļ��������
herrID=widget_base(tlb,row=1)
herr_text=widget_text(herrID,value='',uvalue='',uname='herr_text',/editable,xsize=40)
herr_button=widget_button(herrID,value='�߳�����ļ�',uname='herr_button',xsize=90)
;- �������α������ļ��������
vID=widget_base(tlb,row=1)
v_text=widget_text(vID,value='',uvalue='',uname='v_text',/editable,xsize=40)
v_button=widget_button(vID,value='���α������ļ�',uname='v_button',xsize=90)

;- ����������ȡ����
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='slcӰ����Ŀ:',xsize=80)
numslc_text=widget_text(texttlb,value='',uvalue='',uname='numslc_text',xsize=12)
label=widget_label(texttlb,value='�������Ŀ:',xsize=80)
numintf_text=widget_text(texttlb,value='',uvalue='',uname='numintf_text',xsize=12)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='Ӱ������:',xsize=80)
numline_text=widget_text(texttlb,value='',uvalue='',uname='numline_text',xsize=12)
label=widget_label(texttlb,value='Ӱ������:',xsize=80)
numpixel_text=widget_text(texttlb,value='',uvalue='',uname='numpixel_text',xsize=12)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='ps����Ŀ:',xsize=80)
numps_text=widget_text(texttlb,value='',uvalue='',uname='numps_text',xsize=12)

;- ��������label
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
label=widget_label(tlb,value='����ļ�:',/align_left)

;- ������ֵ�߳����
pscoorID=widget_base(tlb,row=1)
interh_text=widget_text(pscoorID,value='',uvalue='',uname='interh_text',/editable,xsize=40)
interh_button=widget_button(pscoorID,value='��ֵ�߳����',uname='interh_button',xsize=90)
;- ������ֵ���α�����
intervID=widget_base(tlb,row=1)
interv_text=widget_text(intervID,value='',uvalue='',uname='interv_text',/editable,xsize=40)
interv_button=widget_button(intervID,value='��ֵ���α�����',uname='interv_button',xsize=90)
;- �������ܰ�ť
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='��ʼ����',uname='ok')
cl=widget_button(funID,value='�˳�',uname='cl')
;- �����ļ�ָ��
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,herr_text:herr_text,herr_button:herr_button, $
       v_text:v_text,v_button:v_button,numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numline_text:numline_text,numpixel_text:numpixel_text,interh_text:interh_text,interh_button:interh_button, $
       interv_text:interv_text,interv_button:interv_button,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_pskringing',tlb,/no_block

END
