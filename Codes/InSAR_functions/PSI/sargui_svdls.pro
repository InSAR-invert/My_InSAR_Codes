function svd, A

zi=size(A)
SVDC, A, W, U, V 

k=zi(1)
sv=fltarr(k,k)

FOR i = 0, k-1 DO sv[i,i] = W[i] 

result = U ## sv ## TRANSPOSE(V) 

return,result

end

PRO SARGUI_SVDLS_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of 
  'sarlist_button': begin
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
  'unw_button': begin
    infile=dialog_pickfile(title='������λ����ļ�',filter='*.dat',file='res.unwrap.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).unw_text,set_value=infile
    widget_control,(*pstate).unw_text,set_uvalue=infile
  end  
  'out_button': begin
    infile=dialog_pickfile(title='����ļ�',filter='*.dat',file='res.temporal.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).out_text,set_value=infile
    widget_control,(*pstate).out_text,set_uvalue=infile
  end
  'ok': begin
    widget_control,(*pstate).sarlist_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='Ӱ���б��ļ�','��ѡ��Ӱ���б��ļ�',/information)
      return
    endif
    widget_control,(*pstate).plist_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='ps�б��ļ�','��ѡ��ps�б��ļ�',/information)
      return
    endif
    widget_control,(*pstate).unw_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='ps�����ļ�','��ѡ��ps�����ļ�',/information)
      return
    endif
  
    widget_control,(*pstate).numslc_text,get_uvalue=day
    widget_control,(*pstate).numintf_text,get_uvalue=compu
    widget_control,(*pstate).numps_text,get_uvalue=num_ps
;- SVD����С���˽�����ָ�ʱ������
;day=15
;compu=day*(day-1)/2
;num_PS=3211


res=fltarr(num_PS,compu)
rdate=fltarr(day,num_PS)
;pathin='D:\IDL\xiqing\'
;pathout='D:\IDL\result\'

;����ϵ������A
B=intarr(day,compu)

m=0
for i=0,day-2 do begin
for j=i+1,day-1 do begin
B(i,m)=1
B(j,m)=-1
m=m+1
endfor
endfor

A=svd(B)

C=fltarr(compu-day,compu);
PA=[A,C]
SA=SPRSIN(PA); 

x=fltarr(1,compu);


;��ȡ��������λ�в�res
widget_control,(*pstate).unw_text,get_value=infile
;outfile=pathout+'res.unwrap.dat'
openr,lun,infile,/get_lun
readu,lun,res
free_lun,lun

;�����PS���ϵ���λʱ������rdate
for i=0,num_PS-1 do begin
; print,i
  ;�۲ⳣ��������
  L=res(i,*)
  LL=reform(L,compu)
  ;��С����ƽ�����
  x=SPRSAX(SA,LL)
;  rdate(*,i)=abs(x(0:day-1))
  rdate(*,i)=(x(0:day-1))
endfor

;����rdate
widget_control,(*pstate).out_text,get_value=infile
;outfile=pathout+'res.temporal.dat'
openw,lun,infile,/get_lun
writeu,lun,rdate
free_lun,lun

    result=dialog_message(title='ps��ʱ�����з���','�ļ�������',/information)

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


;svd.pro



PRO SARGUI_SVDLS,EVENT
;- �����������
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/7
tlb=widget_base(title='PSʱ�����з���',tlb_frame_attr=1,column=1,xsize=356,ysize=340,xoffset=xoffset,yoffset=yoffset)
;- ��������label
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
label=widget_label(tlb,value='�����ļ�:',/align_left)
;- ����Ӱ���б��ļ��������
sarlistID=widget_base(tlb,row=1)
sarlist_text=widget_text(sarlistID,value='',uvalue='',uname='sarlist_text',/editable,xsize=40)
sarlist_button=widget_button(sarlistID,value='Ӱ���б��ļ�',uname='sarlist_button',xsize=90)
;- ����ps���б��ļ��������
plistID=widget_base(tlb,row=1)
plist_text=widget_text(plistID,value='',uvalue='',uname='plist_text',/editable,xsize=40)
plist_button=widget_button(plistID,value='ps�б��ļ�',uname='plist_button',xsize=90)
;- ������λ����ļ��������
unwID=widget_base(tlb,row=1)
unw_text=widget_text(unwID,value='',uvalue='',uname='unw_text',/editable,xsize=40)
unw_button=widget_button(unwID,value='ps�����ļ�',uname='unw_button',xsize=90)
;- ����label���
label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
label=widget_label(tlb,value='�����ļ�·��:',/align_left)
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
;- �������·��
outID=widget_base(tlb,row=1)
out_text=widget_text(outID,value='',uvalue='',uname='out_text',/editable,xsize=40)
out_button=widget_button(outID,value='����ļ�',uname='out_button',xsize=90)
;- �������ܰ�ť
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='��ʼ����',uname='ok')
cl=widget_button(funID,value='�˳�',uname='cl')
;- �����ļ�ָ��
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text, $
       plist_text:plist_text,plist_button:plist_button,$
       unw_text:unw_text,unw_button:unw_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numline_text:numline_text,numpixel_text:numpixel_text, $
       out_button:out_button,out_text:out_text,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_svdls',tlb,/no_block
END
