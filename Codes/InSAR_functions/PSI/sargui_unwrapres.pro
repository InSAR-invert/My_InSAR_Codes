;lspsunw.pro
Function lspsunw, num_PS, num_Arcs, Arcs, wphi_PS

;  ϵ������A������
  A=lonarr(num_PS,num_Arcs)
  
    for j=0,num_Arcs-1 do begin
      A[Arcs[0,j],j]=1
      A[Arcs[1,j],j]=-1
    endfor
  
;    for i=0,num_Arcs-1 do begin
;      A(noarc(0,i),i)=1;
;      A(noarc(1,i),i)=-1;
;    endfor

  B=fltarr(num_Arcs-num_PS,num_Arcs);
  PA=[A,B]
  SA=SPRSIN(PA); 
  ;�۲ⳣ��������
   L=wphi_PS[Arcs[0,*]]-wphi_PS[Arcs[1,*]];
   LL=reform(L,num_Arcs);
  ;��С����ƽ�����
  ; Forming normal equation ...
;A*x=L
;x=invert(transpose(A)##P##A)##transpose(A)##P##L
x=fltarr(1,num_Arcs);
x= SPRSAX(SA,LL);
unw_x=x(0:num_PS-1);

;unw_xc=congruence(Arcs, unw_x, wphi_PS)

return, unw_x
end
PRO SARGUI_UNWRAPRES_EVENT,EVENT
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
    
    files=file_search(path+'\*.alfangle',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='δ�ҵ���������ļ�','�뽫��������ļ�����ͬһĿ¼',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).alf_text,set_value=path+'\*.alfangle'
    files=file_search(path+'\*.base',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='δ�ҵ������ļ�','�뽫�����ļ�����ͬһĿ¼',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).base_text,set_value=path+'\*.base'
    files=file_search(path+'\*.diff.phase.dat',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='δ�ҵ�����ļ�','�뽫����ļ�����ͬһĿ¼',/information)
      widget_control,(*pstate).diff_text,set_value=''
      widget_control,(*pstate).diff_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).diff_text,set_value=path+'\*.diff.phase.dat'
    
    files=file_search(path+'\*.bperp.dat',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='δ�ҵ���ֱ�����ļ�','�뽫��ֱ�����ļ�����ͬһĿ¼',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
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
    numarcs=0
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
  'interv_button': begin
    infile=dialog_pickfile(title='��ֵ���α�����',filter='*.dat',file='V_map.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).interv_text,set_value=infile
    widget_control,(*pstate).interv_text,set_uvalue=infile
  end
  'interh_button': begin
    infile=dialog_pickfile(title='��ֵ�߳��������',filter='*.dat',file='H_map.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).interh_text,set_value=infile
    widget_control,(*pstate).interh_text,set_uvalue=infile
  end
  'unw_button': begin
    infile=dialog_pickfile(title='����ļ�',filter='*.dat',file='res.unwrap.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).unw_text,set_value=infile
    widget_control,(*pstate).unw_text,set_uvalue=infile
  end
  'ok': begin
    ;- ����������
    wtlb = WIDGET_BASE(title = '������')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='������... ���Ե�')
    Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0
    
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
    widget_control,(*pstate).interv_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','�������ֵ���α������ļ�',/information)
      return
    endif
    widget_control,(*pstate).interh_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='����','�������ֵ�߳�����ļ�',/information)
      return
    endif
    widget_control,(*pstate).unw_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='���','��ָ������ļ����·��',/information)
      return
    endif    
  ;�ó�������ferretti���ϵ��ģ������������α������͸߳����������
  ;
  ;- ��ʼ��ȡ��������
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num
  widget_control,(*pstate).numarc_text,get_uvalue=num_arc
  widget_control,(*pstate).numline_text,get_uvalue=width
  widget_control,(*pstate).numpixel_text,get_uvalue=height
  
  
  ;�ļ���С
;width=500
;height=500
;pathin='D:\IDL\xiqing\'
widget_control,(*pstate).sarlist_text,get_value=infile
pathout=file_dirname(infile)+'\'
;pathout='D:\IDL\result\'
;�����˲���
kernelSize=[3,3]     ;�����Ӧ�ÿ���Ԥ����
kernel=REPLICATE((1./(kernelSize[0]*kernelSize[1])),kernelSize[0],kernelSize[1])  ;3*3�����
  
;PS�������ǰ���֪
;num=3211
;num_arc=9597
  
day=file_lines(infile)
compu=day(0)*(day(0)-1)/2
itab=lonarr(5,compu)
V_map=fltarr(width,height)
H_map=fltarr(width,height)
  widget_control,(*pstate).itab_text,get_value=infile
openr,lun,infile,/get_lun
readf,lun,itab
free_lun,lun


;��ȡ����������α������͸߳����
  widget_control,(*pstate).interv_text,get_value=infile 
;infile=pathout+'V_map.dat'
openr,lun,infile,/get_lun
readu,lun,V_map
free_lun,lun
  widget_control,(*pstate).interh_text,get_value=infile
;infile=pathout+'H_map.dat'
openr,lun,infile,/get_lun
readu,lun,H_map
free_lun,lun


PS=complexarr(num)
;arc_line=complexarr(num_arc)
;plist=intarr(2,num)
arc=lonarr(2,num_arc)
wphi_PS=fltarr(num)
res=fltarr(width,height)
diff=fltarr(width,height)
fres=fltarr(width,height)
unwrap=fltarr(num,compu)

bperp=fltarr(width,height)
incident=fltarr(width)
base=fltarr(height)
range=fltarr(width)

;��ȡPS��λ��Ϣ
  widget_control,(*pstate).plist_text,get_value=infile
;  infile=pathout+'plist.txt'
  openr,lun,infile,/get_lun
  readf,lun,PS
  free_lun,lun
  
xlist=Uint(real_part(PS))
ylist=Uint(imaginary(PS))

;��ȡ������Ϣ
  arctemp=COMPLEXARR(num_arc)
  arc=lonarr(2,num_arc) 
  widget_control,(*pstate).arcs_text,get_value=infile
  OPENR,lun,infile,error=err,/get_lun
  READF,lun,arctemp
  FREE_LUN,lun
  arc[0,*]=REAL_PART(arctemp)
  arc[1,*]=IMAGINARY(arctemp)
;  infile=pathout+'arc.txt'
;  openr,lun,infile,/get_lun
;  readf,lun,arctemp
;  free_lun,lun
;  
;arc(0,*)=Uint(real_part(arc_line))
;arc(1,*)=Uint(imaginary(arc_line))


for i=0,compu-1 do begin
int_pair=itab(*,i)
;print,i
ti=int_pair(2)

;�ļ���д����
;master_slc.par&slave_slc.par
master=strcompress(string(int_pair(0)),/remove_all)
slave=strcompress(string(int_pair(1)),/remove_all)
incid_angle_int=master+'-'+slave+'.incident'
range_master_int=master+'-'+slave+'.range'
alfa_angle_int=master+'-'+slave+'.alfangle'
baseline_int=master+'-'+slave+'.base'
diff_str=master+'-'+slave+'.diff'
baseline_perp=master+'-'+slave+'.bperp'

;��ȡ��ֱ���ߡ�����ǡ�б��Ȳ���
;-----------------------------------
infile=pathout+incid_angle_int
openr,lun,infile,/get_lun
readf,lun,incident
free_lun,lun

infile=pathout+range_master_int
openr,lun,infile,/get_lun
readf,lun,range
free_lun,lun

infile=pathout+baseline_int
openr,lun,infile,/get_lun
readf,lun,base
free_lun,lun

infile=pathout+baseline_perp+'.dat'
openr,lun,infile,/get_lun
readu,lun,bperp
free_lun,lun
;-----------------------------------


;��ȡ��ָ�����λ
infile=pathout+diff_str+'.phase.dat'
openr,lun,infile,/get_lun
readu,lun,diff
free_lun,lun

  for j=0,width-1 do begin
    for k=0,height-1 do begin
    ;��������λ�в�
      res(j,k)=diff(j,k)-bperp(j,k)*H_map(j,k)*4*!pi/(0.031*range(j)*sin(incident(j)))-ti/365*4*!pi*V_map(j,k)*cos(incident(j))/0.031
    endfor
  endfor

  res=(res+!pi)mod(!pi*2)-!pi
;  if MEAN( res, /DOUBLE , /NAN) lt -6.0 then begin
;   res=res+2*!pi
;  endif
;  if MEAN( res, /DOUBLE , /NAN) gt 6.0 then begin
;   res=res-2*!pi
;  endif 
  II=where(res lt (-1)*!pi)
  s1=size(II)
  III=where(res gt !pi)
  s2=size(III)

  if s1(0) ne 0 then begin
  res(II)=res(II)+2*!pi
  endif
  if s2(0) ne 0 then begin
  res(III)=res(III)-2*!pi
  endif
  
;��λ�в��˲����
  
;��������ռ��ͨ�˲�
fres=CONVOL(float(res),kernel,/CENTER,/EDGE_TRUNCATE)


;����PS������ȡPS���ϵ���λ
;for n=0,num-1 do begin
;wphi_PS(n)=fres(xlist(n),ylist(n))
;endfor
wphi_PS=fres[xlist,ylist]

;-----------------------------------------
result=lspsunw(num, num_arc, arc, wphi_PS)

unwrap(*,i)=abs(result)

Idlitwdprogressbar_setvalue, process, 100*i/compu ;- ���ý���������
endfor
;���澭�˲�����������λ�в�
outfile=pathout+'res.unwrap.dat'
openw,lun,outfile,/get_lun
writeu,lun,unwrap
free_lun,lun
WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
result=dialog_message(title='���','����ļ�������',/information)

  end
  'cl': begin
    result=dialog_message(title='�˳�','ȷ���˳���',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
  end
  else:return
endcase
END




PRO SARGUI_UNWRAPRES,EVENT
;- �����������
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/7
tlb=widget_base(title='PS��λ�в���',tlb_frame_attr=1,column=1,xsize=356,ysize=595,xoffset=xoffset,yoffset=yoffset)
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
;- ������ֵ���α�����
intervID=widget_base(tlb,row=1)
interv_text=widget_text(intervID,value='',uvalue='',uname='interv_text',/editable,xsize=40)
interv_button=widget_button(intervID,value='��ֵ���α�����',uname='interv_button',xsize=90)
;- ������ֵ�߳����
interhID=widget_base(tlb,row=1)
interh_text=widget_text(interhID,value='',uvalue='',uname='interh_text',/editable,xsize=40)
interh_button=widget_button(interhID,value='��ֵ�߳����',uname='interh_button',xsize=90)

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
;- ������������ļ�
alfID=widget_base(tlb,row=1)
label=widget_label(alfID,value='��������ļ�:',xsize=90)
alf_text=widget_text(alfID,value='',uvalue='',uname='alf_text',/editable,xsize=40)
;- ���������ļ�
baseID=widget_base(tlb,row=1)
label=widget_label(baseID,value='�����ļ�:',xsize=90)
base_text=widget_text(baseID,value='',uvalue='',uname='base_text',/editable,xsize=40)
;- ��������ļ�
diffID=widget_base(tlb,row=1)
label=widget_label(diffID,value='����ļ�:',xsize=90)
diff_text=widget_text(diffID,value='',uvalue='',uname='diff_text',/editable,xsize=40)
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
;- �������·��
unwID=widget_base(tlb,row=1)
unw_text=widget_text(unwID,value='',uvalue='',uname='unw_text',/editable,xsize=40)
unw_button=widget_button(unwID,value='�������ļ�',uname='unw_button',xsize=90)
;- �������ܰ�ť
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='��ʼ����',uname='ok')
cl=widget_button(funID,value='�˳�',uname='cl')
;- �����ļ�ָ��
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,arcs_text:arcs_text,arcs_button:arcs_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numarc_text:numarc_text,numline_text:numline_text,numpixel_text:numpixel_text, $
       unw_text:unw_text,unw_button:unw_button,incident_text:incident_text,range_text:range_text, $
       alf_text:alf_text,base_text:base_text,diff_text:diff_text,perp_text:perp_text,$
       interv_text:interv_text,interv_button:interv_button,$
       interh_text:interh_text,interh_button:interh_button,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_unwrapres',tlb,/no_block
END