PRO SARGUI_OPENSLC_EVENT,EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
    'cancel':begin
        result=dialog_message('ȷ���˳���',title='��ȡӰ�������Ϣ',/question)
        if result eq 'Yes' then begin
        widget_control,event.top,/destroy
        ptr_free,pstate
        return
        endif
    end
    'ok':begin
        widget_control,(*pstate).columns,get_value=cln
        widget_control,(*pstate).columns,set_uvalue=cln
        widget_control,(*pstate).lines,get_value=ln
        widget_control,(*pstate).lines,set_uvalue=ln
        print,cln,ln
        columns=cln(0)
        lines=ln(0)
        infile=(*pstate).infile
        ;-��ʼ��ȡ�ļ�
        slc=openslc(infile,columns,lines)
        slc=double(slc)
        rl_part=real_part(slc)
        img_part=imaginary(slc)
;    ;-�Ҷȱ任
;    columns=long(columns)
;    lines=long(lines)
;    temp=reform(slcamplitude,columns*lines)
;    slcmean=mean(temp)
;    slcres=sqrt(slcamplitude/slcmean*(slcamplitude^0.35))    
;    slcamplitude=adapt_hist_equal(slcamplitude)
    slcamplitude=sqrt(rl_part^2+img_part^2)
    slcamplitude=adapt_hist_equal(slcamplitude)
    
    
   
        window,xsize=columns,ysize=lines,/free,title='SLC���Ӱ��',xpos=0,ypos=50
        tv,(slcamplitude*0.95+edge*0.5)

        end
  endcase
END

PRO SARGUI_OPENSLC,EVENT
infile=dialog_pickfile(title='��SLCӰ��',filter='*.rslc',/read);ѡȡ�ļ�
if infile eq '' then return
columns=0
lines=0
;-��ȡSLCͷ�ļ�����
fpath=strsplit(infile,'\',/extract);���ļ�·���ԡ�\��Ϊ��λ����
pathsize=size(fpath)
fname=fpath(pathsize(1)-1)
file=strsplit(fname,'.',/extract)
hdrfile=file(0)+'.rslc.par';ͷ�ļ�����
hdrpath=''
for i=0,pathsize(1)-2 do begin
  hdrpath=hdrpath+fpath(i)+'\'
endfor
hpath=hdrpath+hdrfile
;-�Ҳ���ͷ�ļ������������ļ����к�
files=findfile(hpath,count=numfiles)
if (numfiles eq 0) then begin
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  tlb=widget_base(xsize=250,ysize=110,column=1,title='�������ļ����к�',tlb_frame_attr=1,xoffset=xoffset,yoffset=yoffset)
  main=widget_base(tlb,column=1,frame=1)
  ;frame:�������߿�����ֵ
  abase=widget_base(main,row=2,/grid_layout,/base_align_center)
  label=widget_label(abase,value='�ļ�����')
  columns=widget_text(abase,value='0',/editable,xsize=18,uvalue='0',uname='col')
  label=widget_label(abase,value='�ļ�����')
  lines=widget_text(abase,value='0',/editable,xsize=18,uvalue='0',uname='lines')
  ;-�����˳�OK�Ȱ�ť
  buttsize=75
  bbase=widget_base(tlb,row=1,/align_center)
  butt=widget_button(bbase,value='OK',xsize=buttsize,uname='ok')
  butt=widget_button(bbase,value='Cancel',xsize=buttsize,uname='cancel')
  butt=widget_button(bbase,value='Help',xsize=buttsize,uname='Help')
  state={columns:columns,lines:lines,infile:infile}
  pstate=ptr_new(state,/no_copy)
  ;-�������
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'sargui_openslc',tlb,/no_block
  widget_control,(*pstate).columns,get_uvalue=columns
  widget_control,(*pstate).lines,get_uvalue=lines
  print,columns,lines   
endif else begin
  ;-�ҵ�ͷ�ļ�����ȡ�ļ���С
  openr,lun,hpath,error=err,/get_lun
  temp=''
  if(err ne 0)then  begin
    result=dialog_message('Find head file: Error!')
  endif
  for i=0,9 do begin
    readf,lun,temp
  endfor
  readf,lun,temp
  columns=(strsplit(temp,/extract))(1)
  readf,lun,temp
  lines=(strsplit(temp,/extract))(1)  
  ;-��ʼ��ȡ�ļ�
  slc=openslc(infile)
  rl_part=real_part(slc)
  img_part=imaginary(slc)
;    ;-�Ҷȱ任
;    columns=long(columns)
;    lines=long(lines)
;    temp=reform(slcamplitude,columns*lines)
;    slcmean=mean(temp)
;    slcres=sqrt(slcamplitude/slcmean*(slcamplitude^0.35))    
;    slcamplitude=adapt_hist_equal(slcamplitude)
;    ;-�Ҷȱ任2
;    slcamplitude=(rl_part^2+img_part^2)^0.5
;    slcamplitude=double(slcamplitude)
;    slcamplitude=filter(slcamplitude)
;    slcamplitude=adapt_hist_equal(slcamplitude)
;    edge=roberts(slcamplitude)
    slcamplitude=sqrt(rl_part^2+img_part^2)
    slcamplitude=adapt_hist_equal(slcamplitude)
    
    
   
    window,xsize=columns,ysize=lines,/free,title='SLC���Ӱ��',xpos=0,ypos=50
    tv,slcamplitude

endelse
END