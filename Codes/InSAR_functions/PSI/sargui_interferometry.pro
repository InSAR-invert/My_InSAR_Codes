PRO SARGUI_INTERFEROMETRY_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'input_button':begin
    ;-ѡ�������ļ�
    infile=dialog_pickfile(title='��ѡ�������ļ�',filter='*.dat',file='itab.dat',/read)
    if n_elements(infile)eq 0 then return
    widget_control,(*pstate).input_text,set_uvalue=infile
    widget_control,(*pstate).input_text,set_value=infile
  end
  'size_button':begin
    ;-��ȡӰ������к�
    infile=dialog_pickfile(title='��ѡ�������ļ�',/read,filter='*.par')
    if infile eq '' then return
    if infile ne '' then begin
      openr,lun,infile,/get_lun
      temp=''
      for i=0,9 do begin
        readf,lun,temp
      endfor
      readf,lun,temp
      columns=(strsplit(temp,/extract))(1)
      readf,lun,temp
      lines=(strsplit(temp,/extract))(1) 
    widget_control,(*pstate).column_text,set_value=columns
    widget_control,(*pstate).column_text,set_uvalue=columns
    widget_control,(*pstate).line_text,set_value=lines
    widget_control,(*pstate).line_text,set_uvalue=lines
    endif
  end
  'out_button':begin
    ;-�������·��
    ;-����Ƿ�ѡ���������ļ�����û�У�������
    widget_control,(*pstate).input_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message('δѡ�������ļ����Ƿ�����ѡ��',/question)
      if result eq 'Yes' then begin
        infile=dialog_pickfile(title='��ѡ�������ļ�',filter='*.dat',file='itab.dat',/read)
        if n_elements(infile)eq 0 then return
        widget_control,(*pstate).input_text,set_uvalue=infile
        widget_control,(*pstate).input_text,set_value=infile
      endif else begin
        return
      endelse
    endif else begin
    widget_control,(*pstate).input_text,get_uvalue=infile
    ;-��ȡ�洢·��
    temp=strsplit(infile,'\',/extract)
    temp_size=size(temp)
    out_path=''
    for i=0,temp_size(1)-2 do begin
      out_path=out_path+temp(i)+'\'
    endfor
    ;-��·��д��text�ؼ�
    widget_control,(*pstate).out_text,set_uvalue=out_path
    widget_control,(*pstate).out_text,set_value=out_path
    endelse
  end
  'ok':begin
    ;-��ȡ�ؼ�ֵ
    widget_control,(*pstate).input_text,get_uvalue=infile
    widget_control,(*pstate).out_text,get_uvalue=out_path
    widget_control,(*pstate).column_text,get_uvalue=column
    widget_control,(*pstate).line_text,get_uvalue=line
    column=long(column)
    line=long(line)
    ;-����������
    if infile eq '' then begin
      result=dialog_message('δѡ��Ӱ������ļ�',title='�����ļ�')
      return
    endif
    if out_path eq '' then begin
      result=dialog_message('δ�������·��',title='���·��')
      return
    endif
    if column*line eq 0 then begin
      result=dialog_message('�������ļ����к�',title='�ļ����к�')
      return
    endif
    ;-����������
    wtlb = WIDGET_BASE(title = '������')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='������... ���Ե�')
    Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0
    ;-��ȡ���������Ϣ
    compu=file_lines(infile);��ȡ�ļ�����
    itab=lonarr(5,compu)
    openr,lun,infile,/get_lun
    readf,lun,itab
    free_lun,lun
    Idlitwdprogressbar_setvalue, process,1 ;���ý�����

    ;slc�ļ���С
    width=column
    height=line
    temp0=intarr(width*2,height)
    pa=out_path
    list1=indgen(width)
    listr=list1*2
    listc=listr+1

    ;������˲�������
    for i=0,compu-1 do begin
    int_pair=itab(*,i)

    ;�ļ���д����
    master_str=strcompress(string(int_pair(0)),/remove_all)+'.rslc'
    slave_str=strcompress(string(int_pair(1)),/remove_all)+'.rslc'
    int_str=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.int'
    
    ;��ȡ��Ӱ��
    infile=pa+master_str
    
    openr,lun,infile,/get_lun,/swap_endian
    readu,lun,temp0
    free_lun,lun
    
    temp=long(temp0)
    a=temp(listr,*)
    b=temp(listc,*)
    master=complex(a,b)
    

    ;��ȡ��Ӱ��
    infile=pa+slave_str
    
    openr,lun,infile,/get_lun,/swap_endian
    readu,lun,temp0
    free_lun,lun

    temp=long(temp0)
    a=temp(listr,*)
    b=temp(listc,*)
    slave=complex(a,0-b)
    

    ;���沢������λ��Ϣ
    int=master*slave

    phase=atan(imaginary(int)/real_part(int))

    ;������λ�ж�
    for k=0,height-1 do begin
    for j=0,width-1 do begin
      int1=int(j,k)
      if real_part(int1) lt 0 then begin
        if imaginary(int1) ge 0 then begin
          phase(j,k)=phase(j,k)+!pi
        endif else begin
          phase(j,k)=phase(j,k)-!pi
        endelse
      endif
    endfor
    endfor
    ;���������
    pa1=out_path
    intfile=pa1+int_str+'.int.dat'
    openw,lun,intfile,/get_lun
    printf,lun,int
    free_lun,lun

    phasefile=pa1+int_str+'.phase.dat'
    openw,lun,phasefile,/get_lun
    writeu,lun,phase
    free_lun,lun
    Idlitwdprogressbar_setvalue, process, 1+99*i/compu ;���ý�����
    endfor
    WIDGET_CONTROL,process,/Destroy
    WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
    ;- ����������
    result=dialog_message(title='������','ʱ�����ͼ��������λ������',/information)
  end
  'cl':begin
    result=dialog_message('ȷ���˳���',title='�˳�',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
  end
  else:return
endcase    
END

PRO SARGUI_INTERFEROMETRY,EVENT
;-�����ָ�������
;-�������Ϊ��ָ������ݣ��Լ���Ӧ�Ĳ�ָ���ͼ��
;-������ؿؼ���
device,get_screen_size=screen_size
tlb=widget_base(column=1,title='ʱ����洦��',tlb_frame_attr=1,xsize=300,xoffset=screen_size(0)/3,yoffset=screen_size(1)/3)
;-��ȡitab�ļ���Ϣ
itab_tlb=widget_base(tlb,tlb_frame_attr=1,row=1)
input_text=widget_text(itab_tlb,xsize=32,/editable,value='',uvalue='',uname='input_text')
input_button=widget_button(itab_tlb,xsize=80,value='����itab�ļ�',uname='input_button')
;-��ȡӰ��������
size_tlb=widget_base(tlb,tlb_frame_attr=1,row=1)
line_label=widget_label(size_tlb,xsize=40,value='����:')
line_text=widget_text(size_tlb,xsize=8,/editable,value='0',uvalue='',uname='line_text')
column_label=widget_label(size_tlb,xsize=40,value='����:')
column_text=widget_text(size_tlb,xsize=8,/editable,value='0',uvalue='',uname='column_text')
size_button=widget_button(size_tlb,xsize=80,value='��ͷ�ļ�����',uname='size_button')
;-ָ�����·��
out_tlb=widget_base(tlb,tlb_frame_attr=1,row=1)
out_text=widget_text(out_tlb,xsize=32,/editable,value='',uvalue='',uname='out_text')
out_button=widget_button(out_tlb,xsize=80,value='��ȡ���·��',uname='out_button')
;-��ع��ܰ�ť
fun_tlb=widget_base(tlb,tlb_frame_attr=1,row=1,/align_right)
ok=widget_button(fun_tlb,xsize=40,value='����',uname='ok')
cl=widget_button(fun_tlb,xsize=40,value='�˳�',uname='cl')
;-����ָ�룬ָ��������еĿؼ����ƣ�������tlb��ֵΪpstate
state={input_text:input_text,input_button:input_button,out_text:out_text,out_button:out_button, $
       column_text:column_text,line_text:line_text,size_button:size_button,ok:ok,cl:cl}
pstate=ptr_new(state)
widget_control,tlb,set_uvalue=pstate
;-ʶ��ť
widget_control,tlb,/realize
xmanager,'SARGUI_INTERFEROMETRY',tlb,/no_block
END