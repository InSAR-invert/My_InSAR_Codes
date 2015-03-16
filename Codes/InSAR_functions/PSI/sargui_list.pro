PRO SARGUI_LIST_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'add':begin
    widget_control,(*pstate).list,get_uvalue=names
    infiles=dialog_pickfile(title='��ѡ�������ļ�',filter='*.rslc',/read,/multiple_files)
    if n_elements(infiles) eq 0 then return
    if n_elements(names)eq 0 then begin
      names=infiles
    endif else begin    
      names=[names,infiles];�������ļ���������names
    endelse
    widget_control,(*pstate).list,set_uvalue=names
    widget_control,(*pstate).list,set_value=names
    end
;  'close':begin
;    widget_control,(*pstate).list,get_uvalue=list_name
;    print,'All the list names are:',list_name
;    end
  'del':begin
    widget_control,(*pstate).list,get_uvalue=names
    list_num=widget_info((*pstate).list,/list_number)
;    if list_num lt 2 then result=dialog_message('��ѡ����������Ӱ��',title='Ӱ����Ŀ����',/information)
    list_select=widget_info((*pstate).list,/list_select)
    if n_elements(list_select)eq 0 then begin
      result=dialog_message('��ѡ����Ҫɾ����Ӱ������',title='ɾ��Ӱ��',/information)
    endif
    if (n_elements(list_select)eq list_num)then begin
      names=''
    endif else begin
    if min(list_select)eq 0 then names=names(max(list_select)+1:list_num-1)
    if max(list_select)eq list_num-1 then names=names(0:min(list_select)-1)
    if (min(list_select)gt 0 and max(list_select)lt (list_num-1)) then names=[names(0:min(list_select)-1),names(max(list_select)+1:list_num-1)]
    endelse
    widget_control,(*pstate).list,set_value=names
    widget_control,(*pstate).list,set_uvalue=names
    end
  'cl':begin
    result=dialog_message('ȷ���˳���',title='�˳�����',/question,/default_no)
    widget_control,event.top,/destroy
    end
  'input':begin
    widget_control,(*pstate).list,get_uvalue=names
    infiles=dialog_pickfile(title='��ѡ��Ӱ���б��ļ�',filter='*.dat',file='sarlist.dat',/read)
    if infiles eq '' then return
    nlines=file_lines(infiles)
    names=strarr(nlines)
    openr,lun,infiles,/get_lun
    readf,lun,names
    free_lun,lun
    widget_control,(*pstate).list,set_value=names
    widget_control,(*pstate).list,set_uvalue=names
    end
  'output':begin
    widget_control,(*pstate).list,get_uvalue=names
    outfile=dialog_pickfile(title='��ѡ�����·��',filter='*.dat',file='sarlist.dat',/write,/overwrite_prompt)
    if outfile eq '' then return
    openw,lun,outfile,/get_lun
    printf,lun,names,format='(A)'
;    printf,lun,names
    free_lun,lun
    result=dialog_message('�ļ�������',title='����ļ�',/information)
    end
  else: return
endcase
END

PRO SARGUI_LIST,EVENT
;-�������
device,get_screen_size=screen_size
tlb=widget_base(row=1,title='����Ӱ���б��ļ�',tlb_frame_attr=1,xsize=330,xoffset=screen_size(0)/3,yoffset=screen_size(1)/3)
;-�б����
list=widget_list(tlb,uname='lst',xsize=32,ysize=20,/multiple)
;-OK�Լ�Cancel��ť
fun=widget_base(tlb,tlb_frame_attr=1,column=1,xsize=100,/align_bottom)
;adddel=widget_base(fun,column=1,tlb_frame_attr=1,xsize=100,/align_center)
addID=widget_button(fun,value='���',uname='add')
delID=widget_button(fun,value='ɾ��',uname='del')
;okcl=widget_base(fun,column=1,tlb_frame_attr=1,xsize=100,/align_bottom)
inID=widget_button(fun,value='�����ļ��б�',uname='input')
outID=widget_button(fun,value='�����ļ��б�',uname='output')
clID=widget_button(fun,value='�˳�',uname='cl')
;okID=widget_button(fun,value='�ر�',uname='close')

;-�����ṹ��
state={list:list}
pstate=ptr_new(state)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'SARGUI_LIST',tlb,/no_block
END