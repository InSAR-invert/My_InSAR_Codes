PRO SARGUI_NLDEF_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'sarlist_button': begin
    infile=dialog_pickfile(title='Ӱ���б��ļ�',filter='*.dat',file='sarlist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).sarlist_text,set_value=infile
    widget_control,(*pstate).sarlist_text,set_uvalue=infile
  end
  'plist_button': begin
    infile=dialog_pickfile(title='ps���б��ļ�',filter='*.dat',file='plist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).plist_text,set_value=infile
    widget_control,(*pstate).plist_text,set_uvalue=infile
  end
  'pt_button': begin
    infile=dialog_pickfile(title='ps��ʱ�������ļ�',filter='*.dat',file='res.temporal.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).pt_text,set_value=infile
    widget_control,(*pstate).pt_text,set_uvalue=infile
  end
  'out_button': begin
    infile=dialog_pickfile(title='EMD���������ļ�',filter='*.dat',file='nldef.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).out_text,set_value=infile
    widget_control,(*pstate).out_text,set_uvalue=infile
  end
  
  'ok': begin
    widget_control,(*pstate).sarlist_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(titiel='Ӱ���б��ļ�','δ�ҵ��ļ�',/information)
      return
    endif
    widget_control,(*pstate).plist_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(titiel='ps���б��ļ�','δ�ҵ��ļ�',/information)
      return
    endif
    widget_control,(*pstate).pt_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(titiel='psʱ�������ļ�','δ�ҵ��ļ�',/information)
      return
    endif
    widget_control,(*pstate).out_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(titiel='EMD���������ļ�','��ָ�����·��',/information)
      return
    endif
    widget_control,(*pstate).sarlist_text,get_value=infile
    day=file_lines(infile)
    ;- �ж�ps�����Ŀ
    widget_control,(*pstate).plist_text,get_value=infile
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
    num_PS=numps
;    print,'num_ps',numps
    
;    day=15
;num_PS=3211

rdate=fltarr(day,num_PS)
nl=fltarr(day,num_PS)
;pathin='D:\IDL\xiqing\'
;pathout='D:\IDL\result\'

;��ȡÿ��PS���ϵ���λʱ������
;-----------------------------
    widget_control,(*pstate).pt_text,get_uvalue=infile
;infile=pathout+'res.temporal.dat'
openr,lun,infile,/get_lun
readu,lun,rdate
free_lun,lun
;- ����������
    wtlb = WIDGET_BASE(title = '������')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='������... ���Ե�')
Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0


for i=0,num_PS-1 do begin
Idlitwdprogressbar_setvalue, process, double(i)/double(num_PS-1)*100
;---------------------------
data=rdate(*,i)
imf=emd(data)

;window,/free,xsize=700,400
;plot,data,title='Unlinear Deformation Digital'
;
;window,/free,xsize=800,800
;!P.MULTI=[0,1,3,0,0]
;
;FOR j = 0,2 DO begin
;plot,imf(*,j),title='part'+string(j)
;endfor

;;nos=imf(*,0)
;unline=imf(*,2)+imf(*,1)

nl(*,i)=imf(*,1)

;window,/free,xsize=400,600
;!P.MULTI=[0,1,2,0,0]
;plot,unline,title='Unlinear Deformation Part'
;plot,nos,title='Noise Part'
;stop
endfor


    widget_control,(*pstate).out_text,get_uvalue=infile
;outfile=pathout+'nldef.dat'
;print,infile,size(nl)
openw,lun,infile,/get_lun
writeu,lun,nl
free_lun,lun
WIDGET_CONTROL,process,/Destroy
WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
;print,numps,size(nl)
result=dialog_message(title='EMD�ֽ��������','�������',/information)
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


PRO SARGUI_NLDEF,EVENT
;- �����������
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/7
tlb=widget_base(title='������λ�����ֽ�',tlb_frame_attr=1,column=1,xsize=356,ysize=210,xoffset=xoffset,yoffset=yoffset)
;- ��������label
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
label=widget_label(tlb,value='�����ļ�:',/align_left)
;- ����Ӱ���б����
sarlistID=widget_base(tlb,row=1)
sarlist_text=widget_text(sarlistID,value='',uvalue='',uname='sarlist_text',/editable,xsize=40)
sarlist_button=widget_button(sarlistID,value='Ӱ���б��ļ�',uname='sarlist_button',xsize=90)
;- ����ps�б����
plistID=widget_base(tlb,row=1)
plist_text=widget_text(plistID,value='',uvalue='',uname='plist_text',/editable,xsize=40)
plist_button=widget_button(plistID,value='ps���б��ļ�',uname='plist_button',xsize=90)
;- ����psʱ���������
ptID=widget_base(tlb,row=1)
pt_text=widget_text(ptID,value='',uvalue='',uname='pt_text',/editable,xsize=40)
pt_button=widget_button(ptID,value='psʱ������',uname='pt_button',xsize=90)
;- �������label
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
label=widget_label(tlb,value='����ļ�:',/align_left)
;- ��������ļ����
outID=widget_base(tlb,row=1)
out_text=widget_text(outID,value='',uvalue='',uname='out_text',/editable,xsize=40)
out_button=widget_button(outID,value='EMD��������',uname='out_button',xsize=90)
;- �������ܰ�ť
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='��ʼ����',uname='ok')
cl=widget_button(funID,value='�˳�',uname='cl')
;- ����ָ��
state={sarlist_text:sarlist_text,sarlist_button:sarlist_button,$
       plist_text:plist_text,plist_button:plist_button,pt_text:pt_text,pt_button:pt_button,$
       out_text:out_text,out_button:out_button,ok:ok,cl:cl}
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_nldef',tlb,/no_block
END