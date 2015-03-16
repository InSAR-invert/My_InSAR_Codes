PRO SARGUI_DEFLOS_EVENT,EVENT
;   SARGUI_DEFLOS_EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
    'button_nl': begin
      infile=dialog_pickfile(title='�������α�',filter='*.dat',file='nldef.dat',/read)
      if infile eq '' then return
      widget_control,(*pstate).text_nl,set_value=infile
    end
    'button_l': begin
      infile=dialog_pickfile(title='�����α�����',filter='*.txt',file='V.txt')
      if infile eq '' then return
      widget_control,(*pstate).text_l,set_value=infile
    end
    'button_sarlist': begin
      infile=dialog_pickfile(title='��������ļ�',filter='*.dat',file='sarlist.dat')
      if infile eq '' then return
      widget_control,(*pstate).text_sarlist,set_value=infile
    end
    'button_plist': begin
      infile=dialog_pickfile(title='PS���б��ļ�',filter='*.dat',file='plist.dat')
      if infile eq '' then return
      widget_control,(*pstate).text_plist,set_value=infile
    end
    'button_los': begin
      infile=dialog_pickfile(title='LOS���α�',filter='*.dat',file='deflos.dat')
      if infile eq '' then return
      widget_control,(*pstate).text_los,set_value=infile
    end
    'button_ok': begin
      widget_control,(*pstate).text_nl,get_value=infile
      if infile eq '' then begin
        result=dialog_message(title='�������α�','��ѡ��������α��ļ�',/information)
        return
      endif
      widget_control,(*pstate).text_l,get_value=infile
      if infile eq '' then begin
        result=dialog_message(title='�����α�','��ѡ�������α��ļ�',/information)
        return
      endif
      widget_control,(*pstate).text_sarlist,get_value=infile
      if infile eq '' then begin
        result=dialog_message(title='Ӱ���б�','��ѡ��Ӱ���б��ļ�',/information)
        return
      endif
      widget_control,(*pstate).text_nl,get_value=infile
      if infile eq '' then begin
        result=dialog_message(title='LOS���α�','��ѡ��LOS�������α��ļ�',/information)
        return
      endif
      widget_control,(*pstate).text_plist,get_value=infile
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
      free_lun,lun
      widget_control,(*pstate).text_sarlist,get_value=infile
      ;- �ж�Ӱ����Ŀ
      day=file_lines(infile)
      day=day(0)
      num_PS=numps
      nld=fltarr(day,num_PS)
      dlos=fltarr(day,num_PS)
      ;��ȡÿ��PS���ϵķ������α����
      ;-----------------------------
      widget_control,(*pstate).text_nl,get_value=infile
      openr,lun,infile,/get_lun
      readu,lun,nld
      free_lun,lun
      ;��ȡÿ��PS���ϵ������α����ʺͳ���ʱ��
      ;-----------------------------
      widget_control,(*pstate).text_l,get_value=infile
      V=fltarr(num_PS);
      openr,lun,infile,/get_lun
      readf,lun,V
      free_lun,lun
      date=strarr(day)
      widget_control,(*pstate).text_sarlist,get_value=infile
      openr,lun,infile,/get_lun
      readf,lun,date
      free_lun,lun
      for i=0,day-1 do begin
        date(i)=date(i)+'.par'
        c_time=center_time(date(i))
        date(i)=c_time
      endfor
      date=long(date)

;      for i=0,day-1 do begin
;        names(i)=names(i)+'.par'
;;        print,'i is:',i
;;        print,'Name is:',names(i)
;        date=center_time(names(i))
;        ;if date lt 19800101 || date gt 21000000 then begin
;        ;  print,'����������������20001010�ĸ�ʽ���룡'
;        ;endif
;        infiles(i)=date
;      endfor


      for i=0,day-1 do begin
        dd=deltday(date(i),date(0))
        dd=abs(dd)
        dlos[i,*]=V*dd/365+nld(i,*)
      endfor
      widget_control,(*pstate).text_los,get_value=outfile
      dlos=dlos*0.031/4/(!pi)
      ;����ÿ��PS���ϵķ������α����
      ;-----------------------------
      openw,lun,outfile,/get_lun
      writeu,lun,dlos
      free_lun,lun
      result=dialog_message(title='LOS���α���','����������α�����ļ���'+string(13b)+outfile,/information)
    end
    'button_cl': begin
      result=dialog_message('ȷ���˳���',/question,/default_no)
      if result eq 'Yes' then begin
        widget_control,event.top,/destroy
      endif else begin
        return
      endelse
    end
    else: return
  endcase
END


PRO SARGUI_DEFLOS,EVENT
  ;- �����������
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/7
  tlb=widget_base(title='LOS���α����',tlb_frame_attr=1,column=1,xsize=316,xoffset=xoffset,yoffset=yoffset)
  ;- ��������label
  label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
  label=widget_label(tlb,value='�����ļ�:',/align_left)
  ;- �������������
  nltlb=widget_base(tlb,row=2)
  label=widget_label(nltlb,value='�������α�:',xsize=220)
  button_nl=widget_button(nltlb,value='��',uname='button_nl',xsize=85)
  text_nl=widget_text(nltlb,value='',uname='text_nl',xsize=50)
  ;- �����������
  ltlb=widget_base(tlb,row=2)
  label=widget_label(ltlb,value='�����α�����:',xsize=220)
  button_l=widget_button(ltlb,value='��',uname='button_l',xsize=85)
  text_l=widget_text(ltlb,value='',uname='text_l',xsize=50)
  ;- ����Ӱ���б����
  sarlisttlb=widget_base(tlb,row=2)
  label=widget_label(sarlisttlb,value='Ӱ���б��ļ�:',xsize=220)
  button_sarlist=widget_button(sarlisttlb,value='��',uname='button_sarlist',xsize=85)
  text_sarlist=widget_text(sarlisttlb,value='',uname='text_sarlist',xsize=50)
  ;- ����PS���б����
  plisttlb=widget_base(tlb,row=2)
  label=widget_label(plisttlb,value='PS���б��ļ�:',xsize=220)
  button_plist=widget_button(plisttlb,value='��',uname='button_plist',xsize=85)
  text_plist=widget_text(plisttlb,value='',uname='text_plist',xsize=50)
  ;- �������label
  label=widget_label(tlb,value='������������������������������������������������������������',/align_center)
  label=widget_label(tlb,value='����ļ�:',/align_left)
  ;- ����LOS���α����
  lostlb=widget_base(tlb,row=2)
  label=widget_label(lostlb,value='LOS���α�:',xsize=220)
  button_los=widget_button(lostlb,value='ѡ��',uname='button_los',xsize=85)
  text_los=widget_text(lostlb,value='',uname='text_los',xsize=50)
  ;- �������ܰ�ť
  funtlb=widget_base(tlb,/align_right,row=1)
  button_ok=widget_button(funtlb,value='ȷ��',uname='button_ok')
  button_cl=widget_button(funtlb,value='ȡ��',uname='button_cl')
  ;- ����ָ��
  state={button_nl:button_nl,text_nl:text_nl,button_l:button_l,text_l:text_l,$
         button_sarlist:button_sarlist,text_sarlist:text_sarlist,button_los:button_los,$
         text_los:text_los,button_plist:button_plist,text_plist:text_plist,$
         button_ok:button_ok,button_cl:button_cl}
  pstate=ptr_new(state,/no_copy)
  ;- ʶ�����
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'sargui_deflos',tlb,/no_block
END

