PRO SARGUI_FLATTENNING_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'sarlist_button': begin
    infile=dialog_pickfile(title='Ӱ���б��ļ�',filter='*.dat',file='sarlist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).sarlist_text,set_value=infile
    widget_control,(*pstate).sarlist_text,set_uvalue=infile
  end
  'itab_button': begin
    infile=dialog_pickfile(title='Ӱ������ļ�',filter='*.dat',file='itab.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).itab_text,set_value=infile
    widget_control,(*pstate).itab_text,set_uvalue=infile
  end
  'path_button': begin
    widget_control,(*pstate).itab_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='Ӱ���б��ļ�','��ѡ��Ӱ���б��ļ�',/information)
      return
    endif
    infile=file_dirname(infile)+'\'
    widget_control,(*pstate).pathin_text,set_value=infile
    widget_control,(*pstate).pathin_text,set_uvalue=infile
    widget_control,(*pstate).pathout_text,set_value=infile
    widget_control,(*pstate).pathout_text,set_uvalue=infile
  end
  'ok': begin
    ;- ����Ϊ������ʼ��
    widget_control,(*pstate).sarlist_text,get_value=sarlist
    if sarlist eq '' then begin
      result=dialog_message(title='Ӱ���б��ļ�','��ѡ��Ӱ���б��ļ�',/information)
      return
    endif
    widget_control,(*pstate).itab_text,get_value=itabfile
    if itabfile eq '' then begin
      result=dialog_message(title='Ӱ������ļ�','��ѡ��Ӱ������ļ�',/information)
      return
    endif
    widget_control,(*pstate).pathin_text,get_value=pathin
    if pathin eq '' then begin
      result=dialog_message(title='����·��','��ѡ������ļ�·��',/information)
      return
    endif
    widget_control,(*pstate).pathout_text,get_value=pathout
    if pathout eq '' then begin
      result=dialog_message(title='���·��','��ѡ��������·��',/information)
      return
    endif
    openr,lun,sarlist,/get_lun
    slcfile=''
    readf,lun,slcfile
    slcfile=slcfile+'.par'
    files=file_search(slcfile,count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='ͷ�ļ�','δ�ҵ�ͷ�ļ�',/information)
      return
    endif
    openr,lun,slcfile,/get_lun
    temp=''
    for i=0,9 do begin
      readf,lun,temp
    endfor
    readf,lun,temp
    columns=(strsplit(temp,/extract))(1)
    readf,lun,temp
    lines=(strsplit(temp,/extract))(1)     
    ;��ȡ���������Ϣ
    day=file_lines(sarlist)
;    day=15
    compu=day(0)*(day(0)-1)/2
    itab=lonarr(5,compu)
    openr,lun,itabfile,/get_lun
    readf,lun,itab
    free_lun,lun
    ;int�ļ���С
    width=long(columns(0))
    height=long(lines(0))
    temp0=complexarr(width,height)
    fphase=fltarr(width,height)
    phase=fltarr(width,height)
;    pathin='D:\IDL\xiqing\'
;    pathout='D:\IDL\result\'
    ;- ����Ϊ������ʼ��


    ;- ����������
    wtlb = WIDGET_BASE(title = '������')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='������... ���Ե�')
    Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0
    
    
    for m=0,compu-1 do begin
    int_pair=itab(*,m)

    ;�ļ���д����
    ;- ���ļ� master_slc.par&slave_slc.par
    master_par=strcompress(string(int_pair(0)),/remove_all)+'.rslc.par'
    slave_par=strcompress(string(int_pair(1)),/remove_all)+'.rslc.par'
    int_str=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.int'
    ;- д�ļ�
    flt_str=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.flt'
    incid_angle_int=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.incident'
    range_master_int=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.range'
    alfa_angle_int=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.alfangle'
    baseline_int=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.base'


;��ȡ��Ӱ�����ʱ����λ�ò���
infile=pathin+master_par

openr,lun,infile,error=err,/get_lun
temp=''
if(err ne 0)then printf,-2,!error_state.msg               ;print error messages if ever have

;����λ����ʱ������ռ�
x=dblarr(12)
y=x
z=x
t=dblarr(12)
vx=dblarr(12)
vy=vx
vz=vx
;------------------skip the first 4 lines of the file-------------------
for i=0,3 do begin
readf, lun, temp
endfor
;------------------get the time of the image----------------------------
readf, lun, temp
;line=strsplit(temp,' ',/extract)
;year=line(1)
;month=line(2)
;day=line(3)
;------------------get the time paraments--------------------------
readf, lun, temp
line=strsplit(temp,' ',/extract)
start_time=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
center_time=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
end_time=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
azimuth_line_time=line(1)
readf, lun, temp
readf, lun, temp
line=strsplit(temp,' ',/extract)
range_samples=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
azimuth_lines=line(1)

;����SLCʱ���������
time=dindgen(long(azimuth_lines))*double(azimuth_line_time)+double(start_time)

;------------------skip the following 11 lines--------------------------
for i=12,22 do begin
readf, lun, temp
endfor
;------------------all the times----------------------------------------

;��ȡб��R��Ϣ
readf, lun, temp
line=strsplit(temp,' ',/extract)
near_range_slc=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
center_range_slc=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
far_range_slc=line(1)
;------------------all the times----------------------------------------

readf, lun, temp
readf, lun, temp
readf, lun, temp

;��ȡincidence_angle
readf, lun, temp
line=strsplit(temp,' ',/extract)
incidence_angle=double(line(1))
;------------------all the times----------------------------------------


;------------------skip the following 17 lines--------------------------
for i=30,46 do begin
readf, lun, temp
endfor
;------------------all the times----------------------------------------


;��ȡ���ǹ��������Ϣ
readf, lun, temp
line=strsplit(temp,' ',/extract)
time_of_first_state_vector=double(line(1))

readf, lun, temp
line=strsplit(temp,' ',/extract)
state_vector_interval=double(line(1))

;------------------all the times----------------------------------------

;��ȡ12��ʱ�̵�����״̬ʸ��
for i=0,11 do begin
readf, lun, temp
line=strsplit(temp,' ',/extract)
    x(i)=double(line(1))            ;get x coordinate at the i-th orbit position
    y(i)=double(line(2))            ;get y .....
    z(i)=double(line(3))            ;get z .....
    t(i)=time_of_first_state_vector+state_vector_interval*i
readf, lun, temp
line=strsplit(temp,' ',/extract)
    vx(i)=double(line(1))            ;get x coordinate at the i-th orbit position
    vy(i)=double(line(2))            ;get y .....
    vz(i)=double(line(3))            ;get z .....
endfor
free_lun,lun
;----------------------------------------------------------------------

;�ռ�λ���ڲ彨ģ
coefx=svdfit(t,x,3,/double)
coefy=svdfit(t,y,3,/double)
coefz=svdfit(t,z,3,/double)

;���ÿ��azimuth_pixel������λ��
x_postion=poly(time,coefx)
y_postion=poly(time,coefy)
z_postion=poly(time,coefz)
;----------------------------------------------------------------------

;�ٶ�ʸ���ڲ彨ģ
coefvx=svdfit(t,vx,3,/double)
coefvy=svdfit(t,vy,3,/double)
coefvz=svdfit(t,vz,3,/double)

;���ÿ��azimuth_pixel�������ٶ�ʸ��
x_velocity=poly(time,coefvx)
y_velocity=poly(time,coefvy)
z_velocity=poly(time,coefvz)
;----------------------------------------------------------------------

;б��R�ڲ彨ģ
range_data=[double(near_range_slc),double(center_range_slc),double(far_range_slc)]
r1=[0,(width-1.0)/2,width-1]
rn=indgen(width)

;���ÿ��range_pixel�ϵ�б��R
coefr=svdfit(r1,range_data,2,/double)
range=float(poly(rn,coefr))

;��ȡÿ��range_pixel�ϵ������(/����)
dd=double(center_range_slc)*cos(incidence_angle)
incident=float(acos(dd/range))

;���������������б��
outfile=pathout+incid_angle_int
openw,lun,outfile,/get_lun
printf,lun,incident
free_lun,lun

outfile=pathout+range_master_int
openw,lun,outfile,/get_lun
printf,lun,range
free_lun,lun
;----------------------------------------------------------------------


;��ȡ��Ӱ�����ʱ����λ�ò���
infile=pathin+slave_par

openr,lun,infile,error=err,/get_lun
temp=''
if(err ne 0)then printf,-2,!error_state.msg               ;print error messages if ever have

;����λ����ʱ������ռ�
xs=dblarr(12)
ys=xs
zs=xs
ts=dblarr(12)
;------------------skip the first 4 lines of the file-------------------
for i=0,3 do begin
readf, lun, temp
endfor
;------------------get the time of the image----------------------------
readf, lun, temp

;------------------get the time paraments--------------------------
readf, lun, temp
line=strsplit(temp,' ',/extract)
start_time=line(1)

readf, lun, temp
readf, lun, temp

readf, lun, temp
line=strsplit(temp,' ',/extract)
azimuth_line_time=line(1)

readf, lun, temp
readf, lun, temp
line=strsplit(temp,' ',/extract)
range_samples=line(1)

readf, lun, temp
line=strsplit(temp,' ',/extract)
azimuth_lines=line(1)

;����SLCʱ���������
times=dindgen(long(azimuth_lines))*double(azimuth_line_time)+double(start_time)

;------------------skip the following 11 lines--------------------------
for i=12,46 do begin
readf, lun, temp
endfor
;------------------all the times----------------------------------------


;��ȡ���ǹ��������Ϣ
readf, lun, temp
line=strsplit(temp,' ',/extract)
time_of_first_state_vector=double(line(1))
;a=time_of_first_state_vector

readf, lun, temp
line=strsplit(temp,' ',/extract)
state_vector_interval=double(line(1))

;------------------all the times----------------------------------------

;��ȡ12��ʱ�̵�����״̬ʸ��
for i=0,11 do begin
readf, lun, temp
line=strsplit(temp,' ',/extract)
    xs(i)=double(line(1))            ;get x coordinate at the i-th orbit position
    ys(i)=double(line(2))            ;get y .....
    zs(i)=double(line(3))            ;get z .....
    ts(i)=time_of_first_state_vector+state_vector_interval*i
readf, lun, temp
endfor
free_lun,lun
;----------------------------------------------------------------------

;�ռ�λ���ڲ彨ģ
coefxs=svdfit(ts,xs,3,/double)
coefys=svdfit(ts,ys,3,/double)
coefzs=svdfit(ts,zs,3,/double)

;���ÿ��azimuth_pixel������λ��
xs_postion=poly(times,coefxs)
ys_postion=poly(times,coefys)
zs_postion=poly(times,coefzs)
;----------------------------------------------------------------------

;���ÿ��azimuth_pixel�ϵĻ������

alfa=float(atan((zs_postion-z_postion)/sqrt((xs_postion-x_postion)^2+(ys_postion-y_postion)^2)))

;����2pi�����ж�
for s=0,azimuth_lines-1 do begin

  if ys_postion(s)-y_postion(s)+(xs_postion(s)-x_postion(s))*y_velocity(s)/x_velocity(s) lt 0 then begin
  
    alfa(s)=!pi-alfa(s)
    
  endif
  
endfor

;�����ȡ�ռ������Ϣ
base=float(sqrt((xs_postion-x_postion)^2+(ys_postion-y_postion)^2+(zs_postion-z_postion)^2))

;ȥ�ο�������λ���ƹ���: flatenning
;���(pixel)����
for j=0,width-1 do begin
  for k=0,height-1 do begin
    fphase(j,k)=base(k)*sin(incident(j)-alfa(k))*4*!pi/3.1e-2
  endfor
endfor

;�������Ի��������ռ������Ϣ
outfile=pathout+alfa_angle_int
openw,lun,outfile,/get_lun
printf,lun,alfa
free_lun,lun

outfile=pathout+baseline_int
openw,lun,outfile,/get_lun
printf,lun,base
free_lun,lun

;��������ȥƽ��λ��Ϣ������
infile=pathout+int_str+'.phase.dat'
openr,lun,infile,/get_lun
readu,lun,phase
free_lun,lun

flt=(phase-fphase+!pi)mod(!pi*2)-!pi
;if MEAN( flt, /DOUBLE , /NAN) lt -6.2 then begin
;   flt=flt+2*!pi
;endif
;if MEAN( flt, /DOUBLE , /NAN) gt 6.2 then begin
;   flt=flt-2*!pi
;endif
II=where(flt lt (-1)*!pi)
s1=size(II)
III=where(flt gt !pi)
s2=size(III)

if s1(0) ne 0 then begin
flt(II)=flt(II)+2*!pi
endif
if s2(0) ne 0 then begin
flt(III)=flt(III)-2*!pi
endif
 
outfile=pathout+flt_str+'.phase.dat'
openw,lun,outfile,/get_lun
writeu,lun,flt
free_lun,lun

;----------------------------------------------------------------------
;print,m, MEAN( flt, /DOUBLE , /NAN) 
value=100*m/compu
Idlitwdprogressbar_setvalue, process, value
endfor
    WIDGET_CONTROL,process,/Destroy
    WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
    result=dialog_message(title='�������','���ȥƽ��λ��������ļ���б�࣬б����ǣ������ļ���ps�����ļ�',/information)
  end
  'cl': begin
    result=dialog_message(title='�˳�','ȷ���˳���',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
  end
  else: return
endcase

END


PRO SARGUI_FLATTENNING,EVENT
;- ��������ȥƽ
;- ���ȥƽ��λ��������ļ���б�࣬б����ǣ������ļ���ps�����ļ�
;- �����������
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='ȥƽ��ЧӦ',tlb_frame_attr=1,column=1,xsize=320,ysize=150,xoffset=xoffset,yoffset=yoffset)
;- ����sarlist���
sarlistID=widget_base(tlb,tlb_frame_attr=1,row=1)
sarlist_text=widget_text(sarlistID,value='',uvalue='',uname='sarlist_text',/editable,xsize=33)
sarlist_button=widget_button(sarlistID,value='Ӱ���б��ļ�',uname='sarlist_button',xsize=100)
;- ����itab���
itabID=widget_base(tlb,tlb_frame_attr=1,row=1)
itab_text=widget_text(itabID,value='',uvalue='',uname='itab_text',/editable,xsize=33)
itab_button=widget_button(itabID,value='Ӱ������ļ�',uname='itab_button',xsize=100)
;- �����������·�����
pathID=widget_base(tlb,tlb_frame_attr=1,column=2)
pathtext=widget_base(pathID,column=1)
pathin_text=widget_text(pathtext,value='',uvalue='',uname='pathin_text',/editable,xsize=32)
pathout_text=widget_text(pathtext,value='',uvalue='',uname='pathout_text',/editable,xsize=32)
path_button=widget_button(pathID,value='��ȡ�������·��',uname='path_button',ysize=50,xsize=100)
;- �����������
funID=widget_base(tlb,tlb_frame_attr=1,row=1,/align_right)
ok=widget_button(funID,value='����',xsize=50,uname='ok')
cl=widget_button(funID,value='�˳�',xsize=50,uname='cl')
state={sarlist_text:sarlist_text,sarlist_button:sarlist_button, $
       itab_text:itab_text,itab_button:itab_button,pathin_text:pathin_text,$
       pathout_text:pathout_text,path_button:path_button}
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'SARGUI_FLATTENNING',tlb,/no_block
END