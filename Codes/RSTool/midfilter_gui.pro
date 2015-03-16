PRO MIDFILTER_GUI
;- ��ֵ�˲�
;- ����ֵ�����˲�����
;- ���ֵ���˲�֮�������
;- �����������
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/7
tlb=widget_base(title='��ֵ�˲�---LiTao @ SWJTU',tlb_frame_attr=1,column=1,$
                xsize=270,xoffset=xoffset,yoffset=yoffset)
;- �����ļ��������
input_tlb=widget_base(tlb,row=2)
label=widget_label(input_tlb,value='�����ļ�·��:',/align_center,xsize=150)
button=widget_button(input_tlb,value='ѡ��',uname='input_button',uvalue='',xsize=97)
input_text=widget_text(input_tlb,value='',uname='input_text',xsize=40)
label=widget_label(tlb,value='------------------------------------------------------')
;- �����ļ���Ϣ����
info_tlb=widget_base(tlb,row=1)
label=widget_label(info_tlb,value='������')
imlines_text=widget_text(info_tlb,value='0',xsize=5,uname='imlines_text')
label=widget_label(info_tlb,value='������')
imcolumns_text=widget_text(info_tlb,value='0',xsize=5,uname='imcolumns_text')
label=widget_label(info_tlb,value='ͼ������')
imbands_text=widget_text(info_tlb,value='0',xsize=5,uname='imbands_text')
;- ���������������
par_tlb=widget_base(tlb,row=1)
bandlist=widget_droplist(par_tlb,value=['All'],title='������:',uname='bandlist',xsize=130)
winsizelist=widget_droplist(par_tlb,value=['3','5','7','9'],title='�˲����ڣ�',uname='winsizelist',xsize=120)
label=widget_label(tlb,value='------------------------------------------------------')
;- �����ļ��������
output_tlb=widget_base(tlb,row=2)
label=widget_label(output_tlb,value='����ļ�·��:',/align_center,xsize=150)
button=widget_button(output_tlb,value='ѡ��',uname='output_button',xsize=97)
output_text=widget_text(output_tlb,value='',uname='output_text',/editable,xsize=40)
;- �������ܰ�ť
fun_tlb=widget_base(tlb,row=1,/align_right)
button=widget_button(fun_tlb,value='ȷ��',uname='ok')
button=widget_button(fun_tlb,value='ȡ��',uname='cl')
;- ����ָ��
state={input_text:input_text,imlines_text:imlines_text,imcolumns_text:imcolumns_text,imbands_text:imbands_text,$
       winsizelist:winsizelist,output_text:output_text,bandlist:bandlist}
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
;- ʶ��ť
widget_control,tlb,/realize
xmanager,'midfilter_gui',tlb,/no_block
END

PRO MIDFILTER_GUI_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'input_button': begin
    infile=dialog_pickfile(title='��ѡ�������ļ�',filter=['*.jpg','*.bmp','*.tif','*.png','*.gif'],/read)
    if infile eq '' then return
    widget_control,(*pstate).input_text,set_value=infile       
    infile_split=strsplit(infile,'.',/extract)
    filesuffix=infile_split(1)
    case filesuffix of
      'jpg': begin
        read_jpeg,infile,im
      end
      'bmp': begin
        im=read_bmp(infile)
      end
      'tif': begin        
        im=read_tiff(infile)
      end
      'gif': begin
        read_gif,infile,im
      end
      'png': begin
        im=read_png(infile)
      end
      else: return
    endcase
    widget_control,(*pstate).input_text,set_uvalue=im
    result=size(im,/dimensions)
    result=string(result)
    result=strcompress(result)
    if n_elements(result) eq 1 then begin
      result=dialog_message('��֧��0ά��1ά����',title='����')
      return
    endif
    if n_elements(result) eq 2 then begin
      widget_control,(*pstate).imlines_text,set_value=result(1)
      widget_control,(*pstate).imcolumns_text,set_value=result(0)
      widget_control,(*pstate).imbands_text,set_value='1'
    endif
    if n_elements(result) eq 3 then begin
      widget_control,(*pstate).imlines_text,set_value=result(2)
      widget_control,(*pstate).imcolumns_text,set_value=result(1)
      widget_control,(*pstate).imbands_text,set_value=result(0)
      bandlist_value=indgen(result(0))+1
      bandlist_value=string(bandlist_value)
      bandlist_value=strcompress(bandlist_value)
      bandlist_value=[bandlist_value,'All']
      widget_control,(*pstate).bandlist,set_value=bandlist_value
    endif
  end
  'output_button': begin
    outfile=dialog_pickfile(filter='*.bmp',title='��ѡ������ļ�',/write,/overwrite_prompt)
    if outfile eq '' then return
    out_split=strsplit(outfile,'.',/extract)
    if n_elements(out_split) eq 1 then begin
      outfile=outfile+'.bmp'
      result=file_test(outfile)
      if result eq 1 then begin
        result=dialog_message('�ļ��Ѵ��ڣ��Ƿ񸲸�',/question)
        if result eq 'Yes' then begin
          widget_control,(*pstate).output_text,set_value=outfile
        endif      
        if result eq 'No' then begin          
          return
        endif
      endif
    endif
    widget_control,(*pstate).output_text,set_value=outfile
    
    
  end
  'ok': begin
    widget_control,(*pstate).input_text,get_uvalue=im
    widget_control,(*pstate).input_text,get_value=infile
    widget_control,(*pstate).imlines_text,get_value=temp
    imlines=temp(0)
    widget_control,(*pstate).imcolumns_text,get_value=temp
    imcolumns=temp(0)
    widget_control,(*pstate).imbands_text,get_value=temp
    imbands=temp(0)
    widget_control,(*pstate).bandlist,get_value=bandlist
    widget_control,(*pstate).winsizelist,get_value=winsizelist    
    widget_control,(*pstate).output_text,get_value=outfile
    num_select=widget_info((*pstate).bandlist,/droplist_select)
    bands=bandlist(num_select)
    num_select=widget_info((*pstate).winsizelist,/droplist_select)
    winsize=winsizelist(num_select)
    if infile eq '' then begin
      result=dialog_message('��ѡ�������ļ�',title='�����ļ�')
      return
    endif 
    if outfile eq '' then begin
      result=dialog_message('��ѡ������ļ�',title='����ļ�')
      return
    endif
    imcolumns=double(imcolumns)
    imlines=double(imlines)
    winsize=double(winsize)
    imbands=double(imbands)    
    if bands eq 'All' and imbands gt 1 then begin
      for i=0,imbands-1 do begin
        temp=im(i,0:imcolumns-1,0:imlines-1)
        temp=reform(temp)
        im(i,0:imcolumns-1,0:imlines-1)=midfilter(temp,imcolumns,imlines,winsize)
      endfor
    endif
    if imbands eq 1 then begin
      im=midfilter(im,imcolumns,imlines,winsize)
    endif
    if bands ne 'All' then begin
      bands=double(bands)
      temp=im(bands-1,0:imcolumns-1,0:imlines-1)
      temp=reform(temp)
      im(bands-1,0:imcolumns-1,0:imlines-1)=midfilter(temp,imcolumns,imlines,winsize)
    endif
    write_bmp,outfile,im    
    result=dialog_message('�ļ�������',/information)
  end
  'cl':begin
    result=dialog_message('ȷ���˳���',title='�˳�����',/question,/default_no)
    widget_control,event.top,/destroy
  end
  else: return
endcase
END



FUNCTION MIDFILTER,input,imcolumns,imlines,winsize
imcolumns=imcolumns
imlines=imlines
output=dblarr(imcolumns,imlines)
winsize=winsize;���崰�ڴ�С
centerpos=round(winsize/2)*(winsize+1)+1;��ȡ��������λ��
for i=round(winsize),imcolumns-round(winsize)-1 do begin
  for j=round(winsize),imlines-round(winsize)-1 do begin
    temp=input(i-round(winsize):i+round(winsize),j-round(winsize):j+round(winsize))
    temp_order=sort(temp)
    output(i,j)=temp(temp_order(centerpos))
  endfor
endfor
output(0:round(winsize)-1,0:imlines-1)=input(0:round(winsize)-1,0:imlines-1)
output(imcolumns-round(winsize)-1:imcolumns-1,0:imlines-1)=input(imcolumns-round(winsize)-1:imcolumns-1,0:imlines-1);Ӱ����ߺ��ұ���ԭ���ش���
output(0:imcolumns-1,0:round(winsize)-1)=input(0:imcolumns-1,0:round(winsize)-1)
output(0:imcolumns-1,imlines-round(winsize)-1:imlines-1)=input(0:imcolumns-1,imlines-round(winsize)-1:imlines-1);Ӱ���ϱߺ�������ԭ���ش���
return,output
END


;PRO gui_test_cleanup,topid
;  WIDGET_CONTROL, topid,get_uvalue = pState
;  IF PTR_VALID(pState) THEN PTR_FREE, pState
;END
;
;PRO gui_test_event,ev
;  uname = WIDGET_INFO(ev.id,/uname)
;  IF uName EQ 'ok' THEN WIDGET_CONTROL,ev.top,/destroy
;END
;
;PRO gui_test
;  tlb = WIDGET_BASE(/column)
;  tlb1= WIDGET_BASE(tlb,/frame)
;  button = WIDGET_BUTTON(tlb1,value ='OK',uname = 'ok')
;  WIDGET_CONTROL,tlb,/Realize,set_UValue = PTR_NEW({button:button})
;  XMANAGER,'gui_test',tlb,/no_Block,Cleanup = 'gui_test_cleanup'
;END