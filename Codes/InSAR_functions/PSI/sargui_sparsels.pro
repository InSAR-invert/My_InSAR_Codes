

PRO SARGUI_SPARSELS_EVENT,EVENT
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
  'dv_button': begin
    infile=dialog_pickfile(title='��������',filter='*.txt',file='dv_ddh_coh.txt')
    if infile eq '' then begin
      result=dialog_message(title='���������ļ�','��ѡ�񻡶������ļ�',/information)
      return
    endif
    widget_control,(*pstate).dv_text,set_value=infile
    widget_control,(*pstate).dv_text,set_uvalue=infile
  end
  'herr_button': begin
    infile=dialog_pickfile(title='����߳����',filter='*.txt',file='H.txt',/write,/overwrite_prompt)
    if infile eq '' then begin
      result=dialog_message(title='�߳�����ļ�','��ѡ��߳�����ļ�',/information)
      return
    endif
    widget_control,(*pstate).herr_text,set_value=infile
    widget_control,(*pstate).herr_text,set_uvalue=infile
  end
  'v_button': begin
    infile=dialog_pickfile(title='���α�����',filter='*.txt',file='V.txt',/write,/overwrite_prompt)
    if infile eq '' then begin
      result=dialog_message(title='���α�����','��ѡ�����α������ļ�',/information)
      return
    endif
    widget_control,(*pstate).v_text,set_value=infile
    widget_control,(*pstate).v_text,set_uvalue=infile
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
    widget_control,(*pstate).dv_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','�����뻡�������ļ�',/information)
      return
    endif
    widget_control,(*pstate).herr_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='���','��ָ���߳�������·��',/information)
      return
    endif
    widget_control,(*pstate).v_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='���','��ָ�����α���������·��',/information)
      return
    endif    
  ;- ��ʼ��ȡ��������
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num_ps
  widget_control,(*pstate).numarc_text,get_uvalue=num_arcs
  widget_control,(*pstate).numline_text,get_uvalue=nlines
  widget_control,(*pstate).numpixel_text,get_uvalue=npixels
   
;  ;��������
;  num_slc=15
;  num_intf=num_slc*(num_slc-1)/2
;  num_PS=3211
;  num_Arcs=9597
;  nlines=500
;  npixels=500
;  pathin='D:\IDL\result\'
;  pathout='D:\IDL\result\'
  
  dv_ddh_coh=fltarr(3,num_Arcs)

  ;���������α����ʺ͸߳���������������������ģ��ϵ��ֵ���ļ�dv_ddh_coh.txt
  widget_control,(*pstate).dv_text,get_value=infile
  OPENR,lun,infile,/get_lun
  readf,lun,dv_ddh_coh
  FREE_LUN,lun
  dv=dv_ddh_coh(0,*)
  Inc=dv_ddh_coh(1,*)
  Wei=dv_ddh_coh(2,*)
;  starting=0
;  ending=0
;  thrsld=0.1

  arctemp=COMPLEXARR(num_Arcs)
  noarc=INTARR(2,num_Arcs)
  widget_control,(*pstate).arcs_text,get_value=infile
  OPENR,lun,infile,error=err,/get_lun
  READF,lun,arctemp
  FREE_LUN,lun
  noarc[0,*]=REAL_PART(arctemp)
  noarc[1,*]=IMAGINARY(arctemp)
 
;  ;Ȩ��P������
;  P1=fltarr(num_Arcs,1)+1;����num_Arcs��1���������speye�ĶԽ���
;  P=diag_matrix(P1);��num_Arcs��1���ɶԽ���P=speye(num_Arcs,num_Arcs)
;  II=where(Wei lt thrsld);
;  SI=size(II);
;  II=where(Wei lt 0.4)
;    Wei(II)=(Wei(II))^5
;  if SI(3) GT 0 then begin
;    Wei(II)=0
;  endif
;  
;  for i=0,num_Arcs-1 do begin
;    P(i,i)=Wei(i);
;  endfor
;;  SP=SPRSIN(P);
  
  ;ϵ������A������
  num_PS=DOUBLE(num_PS)
  num_Arcs=DOUBLE(num_Arcs)
  A=fltarr(num_PS,num_Arcs)
    for i=0,num_Arcs-1 do begin
      A(noarc(0,i),i)=1;
      A(noarc(1,i),i)=-1;
    endfor
  B=fltarr(num_Arcs-num_PS,num_Arcs);
  PA=[A,B]
  SA=SPRSIN(PA); 
  ;�۲ⳣ��������
   L=Inc;
;  LL=fltarr(num_Arcs);
;  LL=L(0,*);
   LL=reform(L,num_Arcs);
   VV=reform(dv,num_Arcs);
  ;��С����ƽ�����
  ; Forming normal equation ...
;A*x=L
;x=invert(transpose(A)##P##A)##transpose(A)##P##L
x=fltarr(1,num_Arcs);
vd=fltarr(1,num_Arcs);
x= SPRSAX(SA,LL);
H=x(0:num_PS-1);
vd=SPRSAX(SA,VV);
v=vd(0:num_PS-1);
;VV=A##x-L;               ; corrections to observations along all arcs 
;VTPV=transpose(VV)##P##VV;
;delta=sqrt(VTPV/(num_Arcs-num_PS));     ; standard deviation

;;���α�������߳����ƽ��  20110404 �޸�
;;��ȡPS��λ��Ϣ
  plist=COMPLEXARR(num_PS)
  pscoor=INTARR(2,num_PS)
  ppp=file_dirname(infile)+'\plist.dat'
  ppp=ppp(0)
  openr,lun,ppp,/get_lun
  readf,lun,plist
  free_lun,lun
 
  x1=long(real_part(plist))
  y1=long(imaginary(plist))
  pscoor[0,*]=REAL_PART(plist)
  pscoor[1,*]=IMAGINARY(plist)


array=indgen(floor(num_PS/20))*20
vv=v(array)
vv=abs(vv)
hh=H(array)
hh=abs(hh)
x=x1(array)
y=y1(array)
;print,'Insert processing is doing...'

;�ֱ��ڲ������α������͸߳����
e=[60,0]
width=npixels
height=nlines
;V_map=krig2d(V,x1,y1,expon=e,GS=[1,1],Bounds=[0,0,width,height])
V_map=krig2d(vv,x,y,expon=e,GS=[1,1],Bounds=[0,0,width-1,height-1])
v=V_map[pscoor[0,*],pscoor[1,*]]
v=v-max(v)
;print,'First step is over. Please waiting a moment!'
e=[40,10]
H_map=krig2d(hh,x,y,expon=e,GS=[1,1],Bounds=[0,0,width-1,height-1])
H=H_map[pscoor[0,*],pscoor[1,*]]


  widget_control,(*pstate).herr_text,get_value=infile
  OPENW,lun,infile,/get_lun
  PRINTF,lun,H
  FREE_LUN,lun  
  widget_control,(*pstate).v_text,get_value=infile
  OPENW,lun,infile,/get_lun
  PRINTF,lun,v
  FREE_LUN,lun
;print,mean(v),stddev(v)
;print,max(v),min(v)
;print,mean(H),stddev(H)
;print,max(H),min(H) 


 
  result=dialog_message(title='���','���α������Լ��߳����������',/information) 
  
  end
  'cl': begin
    result=dialog_message(title='�˳�','ȷ���˳���',/question)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
  end
  else: return
endcase
END

PRO SARGUI_SPARSELS, EVENT
;- ��С����ƽ��������߳��������Լ����α����ʡ�
;- �����������
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='PS����ƽ�����',tlb_frame_attr=1,column=1,xsize=356,ysize=400,xoffset=xoffset,yoffset=yoffset)
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
;- �������������������
dvID=widget_base(tlb,row=1)
dv_text=widget_text(dvID,value='',uvalue='',uname='dv_text',/editable,xsize=40)
dv_button=widget_button(dvID,value='���������ļ�',uname='dv_button',xsize=90)


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

;- �����߳����ؼ�
herrID=widget_base(tlb,row=1)
herr_text=widget_text(herrID,value='',uvalue='',uname='herr_text',/editable,xsize=40)
herr_button=widget_button(herrID,value='�߳�����ļ�',uname='herr_button',xsize=90)
;- �����α������ļ�
vID=widget_base(tlb,row=1)
v_text=widget_text(vID,value='',uvalue='',uname='v_text',/editable,xsize=40)
v_button=widget_button(vID,value='���α������ļ�',uname='v_button',xsize=90)
;- �������ܰ�ť
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='��ʼ����',uname='ok')
cl=widget_button(funID,value='�˳�',uname='cl')
;- �����ļ�ָ��
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,arcs_text:arcs_text,arcs_button:arcs_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numarc_text:numarc_text,numline_text:numline_text,numpixel_text:numpixel_text, $
       herr_text:herr_text,herr_button:herr_button,v_text:v_text,v_button:v_button,ok:ok,cl:cl , $
       dv_text:dv_text,dv_button:dv_button   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_sparsels',tlb,/no_block

END

