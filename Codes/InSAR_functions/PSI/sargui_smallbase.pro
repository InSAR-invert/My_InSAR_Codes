PRO SARGUI_SMALLBASE_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of

  'outbutton':begin
    infile=dialog_pickfile(title='��ѡ������ļ�',filter='*.dat',file='itab.dat',/write,/overwrite_prompt)
    widget_control,(*pstate).outpath,set_value=infile
    widget_control,(*pstate).outpath,set_uvalue=infile
    end
  'ok':begin
    widget_control,(*pstate).list,get_uvalue=names
    widget_control,(*pstate).outpath,get_uvalue=outfile
    widget_control,(*pstate).time,get_uvalue=tlimen
    widget_control,(*pstate).space,get_uvalue=slimen
    if n_elements(names)eq 0 then begin
      result=dialog_message('δ���������ļ�',title='�ļ�����')
    endif else begin
      name_size=size(names)
      day=name_size(1)
      date=0
      infiles=lonarr(day)
      da=intarr(day)
      for i=0,day-1 do begin
        names(i)=names(i)+'.par'
;        print,'i is:',i
;        print,'Name is:',names(i)
        date=center_time(names(i))
        ;if date lt 19800101 || date gt 21000000 then begin
        ;  print,'����������������20001010�ĸ�ʽ���룡'
        ;endif
        infiles(i)=date
      endfor
      for i=1,day-1 do begin
        da(i)=deltday(infiles(i-1),infiles(i))
      endfor
      compu=day*(day-1)/2
      itab1=lonarr(5,compu)
      itab1(3,*)=baseline(names) ;�ռ���� space baseline
      num=0
      for i=0,day-2 do begin
        summ=0
        for j=i+1,day-1 do begin
          summ=summ+da(j)
          itab1(0,num)=infiles(i)
          itab1(1,num)=infiles(j)
          itab1(2,num)=summ  ;ʱ����� temple baseline
      ;�趨С���߼����ռ����<600�ף�ʱ�����<500�ס�
      ;   if itab1(2,num) lt 300 && itab1(3,num) lt 500 then begin
          if itab1(2,num) lt tlimen && itab1(3,num) lt slimen then begin
            itab1(4,num)=1   ;ʱ�����
          endif else begin
            itab1(4,num)=0
          endelse
          num=num+1
        endfor
      endfor
      openw,lun,outfile,/get_lun
      printf,lun,itab1
      free_lun,lun
      result=dialog_message('�ļ�������',title='�ļ����',/information)
    endelse
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
    printf,lun,names
    free_lun,lun
    result=dialog_message('�ļ�������',title='����ļ�',/information)
    end
  else: return
endcase

END

PRO SARGUI_SMALLBASE,EVENT
;-�������
device,get_screen_size=screen_size
tlb=widget_base(column=1,title='С���߸�������',tlb_frame_attr=1,xsize=330,ysize=360,xoffset=screen_size(0)/3,yoffset=screen_size(1)/3)
filelist=widget_base(tlb,row=1,tlb_frame_attr=1)
;-�б����
names=''
list=widget_list(filelist,value=names,uvalue=names,uname='lst',xsize=32,ysize=20,/multiple)
;-OK�Լ�Cancel��ť
fun=widget_base(filelist,tlb_frame_attr=1,column=1,xsize=100,/align_bottom)
;adddel=widget_base(fun,column=1,tlb_frame_attr=1,xsize=100,/align_center)
;addID=widget_button(fun,value='���',uname='add')
;delID=widget_button(fun,value='ɾ��',uname='del')
;okcl=widget_base(fun,column=1,tlb_frame_attr=1,xsize=100,/align_bottom)
inID=widget_button(fun,value='�����ļ��б�',uname='input')
;outID=widget_button(fun,value='�����ļ��б�',uname='output')

baselabel=widget_base(tlb,row=2)
timeID=widget_label(baselabel,value='ʱ�����(��)',xsize=110)
spaceID=widget_label(baselabel,value='�ռ����(��)',xsize=110)
time=widget_text(baselabel,value='500',uvalue='500',uname='time',/editable,xsize=16)
space=widget_text(baselabel,value='800',uvalue='800',uname='space',/editable,xsize=16)

out=widget_base(tlb,row=1)
outpath=widget_text(out,value='',uvalue='',/editable,xsize=34,uname='outpath')
outbutton=widget_button(out,value='�������ļ�',uname='outbutton')

okcl=widget_base(tlb,row=1,/align_center)
okID=widget_button(okcl,value='ȷ��',uname='ok',xsize=100)
clID=widget_button(okcl,value='ȡ��',uname='cl',xsize=100)

;-�����ṹ��
state={list:list,time:time,space:space,outpath:outpath}
pstate=ptr_new(state)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'SARGUI_SMALLBASE',tlb,/no_block
END