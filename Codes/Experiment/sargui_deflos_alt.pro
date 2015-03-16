PRO PSTLB_CANCEL,EVENT
  widget_control,event.top,get_uvalue=uvalue
  widget_control,uvalue,get_uvalue=pstate
  widget_control,(*pstate).draw,set_uvalue=[0,0,0]
  widget_control,event.top,/destroy
END
PRO SARGUI_DEFLOS_EVENT,EVENT

  widget_control,event.top,get_uvalue=pstate
;  print,tag_names(event,/structure_name)
  case tag_names(event,/structure_name) of
    'WIDGET_KILL_REQUEST': begin
;      result=dialog_message(title='�˳�','ȷ���˳���',/question)      
;      if result eq 'Yes' then begin
;        ;- ����ָ����ʼ������
        widget_control,event.top,get_uvalue=uvalue
        if ptr_valid(uvalue) then begin
          ptr_free,uvalue
        endif else begin
          result=widget_info(uvalue,/valid_id)
          if result eq 1 then begin
            widget_control,uvalue,get_uvalue=pstate
            widget_control,(*pstate).draw,set_uvalue=[0,0,0]
          endif
        endelse
        ;- ���ٽ���
        widget_control,event.top,/destroy
;        return
;      endif
;      if result eq 'No' then return
    end
    'WIDGET_BUTTON': begin
      uname=widget_info(event.id,/uname)
      widget_control,event.top,get_uvalue=pstate
      case uname of
        'button_pwr': begin
          infile=dialog_pickfile(filter='*.bmp',title='ѡ���ͼ',/read)
          if infile eq '' then return
          widget_control,(*pstate).text_pwr,set_value=infile
          pwr=read_bmp(infile)
          sz=size(pwr)
          ;- ȷ����ʾ��Χ
          if sz(0)gt 2 then begin
            result=dialog_message(title='����','��򿪵�ͼ��Ӱ��')
            return
          endif
          draw=widget_info((*pstate).draw,/geometry)          
          if sz(1) gt sz(2) then begin
            xsize=draw.draw_xsize
            coef=draw.draw_xsize/sz(1)
            ysize=sz(2)*coef
          endif else begin
            ysize=draw.draw_ysize
            coef=draw.draw_ysize/sz(2)
            xsize=sz(1)*coef
          endelse
          text_pwr_state={pwr:pwr,coef:coef}
          text_pwr_pstate=ptr_new(text_pwr_state,/no_copy)
          widget_control,(*pstate).text_pwr,set_uvalue=text_pwr_pstate
          ;- ͼ���ֵ��ʾ
          tv,congrid(pwr,xsize,ysize)
        end
        'button_plist': begin
          widget_control,(*pstate).text_pwr,get_value=text_pwr
          if text_pwr eq '' then begin
            result=dialog_message(title='����ѡ���ͼ','����ѡ���ͼ',/information)
            return
          endif
          infile=dialog_pickfile(title='ps���б��ļ�',file='plist.dat',filter='*.dat',/read)
          if infile eq '' then return
          widget_control,(*pstate).text_plist,set_value=infile
          ;- ȷ��ps�����
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
          plist=complexarr(numps)
          openr,lun,infile,/get_lun          
          readf,lun,plist
          free_lun,lun
          ;- ����ps������
          widget_control,(*pstate).text_pwr,get_uvalue=text_pwr_pstate
          coef=(*text_pwr_pstate).coef
          plist=plist*coef
          ;- ��ʾps��
          device,get_decomposed=old_decomposed,decomposed=0
          TvLCT, 0,255,0,1
          r_part=real_part(plist)
          i_part=imaginary(plist)
          plots,r_part,i_part,psym=1,/device,color=1
          device,decomposed=old_decomposed
          widget_control,(*pstate).text_plist,set_uvalue=numps
        end
        'button_sarlist': begin
          widget_control,(*pstate).text_plist,get_uvalue=numps
          if n_elements(numps) eq 0 then begin
            result=dialog_message(title='δ�ҵ�ps���ļ�','����ѡ��ps���ļ�',/information)
            return
          endif
          infile=dialog_pickfile(title='Ӱ���б��ļ�',file='sarlist.dat',filter='*.dat')
          if infile eq '' then return
          widget_control,(*pstate).text_sarlist,set_value=infile
        end
        'button_los': begin
          widget_control,(*pstate).text_sarlist,get_value=sarlist
          if n_elements(sarlist) eq 0 then begin
            result=dialog_message(title='Ӱ���б��ļ�δѡ��','����ѡ��Ӱ���б��ļ�',/information)
            return
          endif
          infile=dialog_pickfile(title='los���α��ļ�',file='deflos.dat',filter='*.dat',/read)
          if infile eq '' then return
          widget_control,(*pstate).text_los,set_value=infile          
        end
        else: return
      endcase
    end
    'WIDGET_DRAW': begin
      widget_control,event.top,get_uvalue=pstate
      widget_control,(*pstate).text_pwr,get_uvalue=text_pwr_pstate
      widget_control,(*pstate).draw,get_uvalue=pstlb
      pstlb_on=pstlb(0)
      if n_elements(text_pwr_pstate) eq 0 then begin
        coef=1
        gray=0
      endif else begin
        coef=(*text_pwr_pstate).coef
        pwr=(*text_pwr_pstate).pwr
      endelse
      ;- ���ٴ��ڣ���Ӧ������˫���¼�
      if (event.clicks eq 2 and pstlb_on) then begin;-˫�����ٴ���
        widget_control,pstlb(1),/destroy
        widget_control,(*pstate).draw,set_uvalue=[0,0,0]
        event.clicks=0
        pstlb_on=0
      endif
      ;- ��ʼ����ps����Ϣչʾ�������Ӧ������˫���¼�
      if (event.clicks eq 2 and ~pstlb_on)then begin
        widget_control,(*pstate).text_plist,get_uvalue=numps
        if n_elements(numps)eq 0 then numps=0
        xsize=295
        ysize=260
        device,get_screen_size=screen_size        
        xoffset=(screen_size(0)-xsize)/2+150
        yoffset=10
        pstlb=widget_base(title='PS����Ϣչʾ',uname='pstlb',mbar=mbar,xsize=xsize,ysize=ysize,$
                          xoffset=xoffset,yoffset=yoffset,tlb_frame_attr=1,uvalue=event.top,/tlb_kill_request_events)
        mbutton=widget_button(mbar,value='�ļ�')
        button=widget_button(mbutton,value='�˳�',event_pro='pstlb_cancel')
        widget_control,(*pstate).draw_label,get_value=label_text
        value=label_text+string(13b)+string(13b)+'PS������:'+strcompress(numps)+string(13b)+string(13b)+'PS�����:0'+string(13B)+string(13B)+'PS������: X:0 Y:0'+string(13B)+string(13B)+'PS̽��ʱ�����У�0'+string(13B)+string(13B)$
              +'LOS���α����У�0'
        ps_label=widget_label(pstlb,value=value,uname='ps_text',ysize=ysize)
        widget_control,pstlb,/realize
        xmanager,'sargui_deflos',pstlb,/no_block
;        widget_control,pstlb,set_uvalue=pstlb
        widget_control,(*pstate).draw,set_uvalue=[1,pstlb,ps_label]
        event.clicks=0
      endif
      ;- ��ʼ��ps����Ϣչʾ����и�ֵ����Ӧ�����������¼�
      if ((pstlb_on) and (event.press eq 1)and(event.type eq 0)) then begin
        ;- �����¼���ȡ�������
        widget_control,(*pstate).draw_label,get_value=value
        str=strsplit(value,' ',/extract)
        x=floor(double(str(1)))
        y=floor(double(str(3)))
        y_location=double(y)
        widget_control,(*pstate).text_pwr,get_uvalue=text_pwr_pstate
        if n_elements(text_pwr_pstate) ne 0 then begin
          pwr=(*text_pwr_pstate).pwr
          sz=size(pwr)
          y=sz(2)-y
        endif
        ;- ������������ps��
        widget_control,(*pstate).text_plist,get_value=infile;-��plist
        if infile eq '' then return
        widget_control,(*pstate).text_plist,get_uvalue=numps
        plist=complexarr(numps)
        openr,lun,infile,/get_lun
        readf,lun,plist
        free_lun,lun
        r_part=real_part(plist)
        i_part=imaginary(plist)
        winsize=7 ;- ps���������ڣ�7*7���Ե�ǰ����Ϊ����
        d=floor(winsize/2)
        ii=where((r_part ge x-d) and (r_part le x+d) and (i_part ge y-d) and (i_part le y+d))
        if ii(0) ne -1 then begin
          ;- �ж����ڽ���
          d=sqrt((r_part(ii)-x)^2+(i_part(ii)-y)^2)
          ii_d=sort(d)
          ps_index=ii(ii_d(0))
          ps_x=r_part(ps_index)
          ps_y=i_part(ps_index)
          ;- ��ȡ���ϵ�ʱ������
          widget_control,(*pstate).text_sarlist,get_value=infile
          if infile eq '' then return
          day=file_lines(infile)
          sarlist=strarr(day)
          openr,lun,infile,/get_lun
          readf,lun,sarlist
          free_lun,lun
          sarlist=sarlist(sort(sarlist))
          sarlist_show=''
          for i=0,day(0)-1 do begin
            temp=strsplit(sarlist(i),'\',/extract)
            sz=size(temp)
            temp=temp(sz(1)-1)
            temp=strsplit(temp,'.',/extract)
            temp=temp(0)
            sarlist_show=sarlist_show+temp+' '
            j=i+1
            if ~(j mod 3) then sarlist_show=sarlist_show+string(13b)
          endfor
          ;- ��ȡ���ϵ��α�����
          widget_control,(*pstate).text_los,get_value=infile
          if infile eq '' then return
          los=fltarr(day,numps)
          openr,lun,infile,/get_lun
          readu,lun,los
          free_lun,lun
          los=los(*,ps_index)
          los_show=''
          for i=0,day(0)-1 do begin
            los_show=los_show+strcompress(los(i))+' '
            j=i+1
            if ~(j mod 3)then los_show=los_show+string(13b)
          endfor
          ;- Ϊ�����ֵ
          widget_control,(*pstate).draw_label,get_value=label_text
          value=label_text+string(13b)+string(13b)$
                +'PS������:'+strcompress(numps)+string(13b)+string(13b)$
                +'PS�����:'+strcompress(ps_index)+string(13B)+string(13B)$
                +'PS������: X:'+strcompress(ps_x)+' Y:'+strcompress(y_location)+string(13B)+string(13B)$
                +'PS̽��ʱ�����У�'+string(13b)+sarlist_show+string(13b) $
                +'LOS���α����У�'+string(13b)+strcompress(los_show)
          widget_control,(*pstate).draw,get_uvalue=pstlb
          widget_control,pstlb(2),set_value=value
        endif
      endif
      
      
      case event.type of
        2: begin
          drawsz=widget_info((*pstate).draw,/geom)
          ;- ����ʾ����ת��Ϊͼ������
          x=event.x/coef          
          if n_elements(pwr)le 1 then begin
            gray=0
            y=(drawsz.draw_xsize-event.y)/(coef)
          endif else begin
            sz=size(pwr)
            y=(sz(2)*coef-event.y)/(coef)
            if (y ge sz(2) or x ge sz(1) or y lt 0) then begin
              gray=0
            endif else begin            
              gray=(*text_pwr_pstate).pwr(x,sz(2)-y)
            endelse
          endelse
            gray=float(gray)
          label_text='X:'+string(x)+'  Y:'+string(y)+'  �Ҷ�:'+string(gray)
          label_text=strcompress(label_text)
          widget_control,(*pstate).draw_label,set_value=label_text
;          widget_control,(*pstate).draw,get_uvalue=pstlb
;          widget_control,(*pstate).text_plist,get_uvalue=numps
;          if n_elements(numps) eq 0 then numps=0          
;          if pstlb(1) gt 0 then begin
;            value=label_text+string(13b)+string(13b)+'PS������:'+strcompress(numps)+string(13b)+string(13b)+'PS�����:0'+string(13B)+string(13B)+'PS������: X:0 Y:0'+string(13B)+string(13B)+'PS̽��ʱ�����У�0'+string(13B)+string(13B)$
;              +'PS���α����У�0'
;            widget_control,pstlb(2),set_value=value
;          endif
        end
        else:return
      endcase        
    end       
    else: return
  endcase
END


PRO SARGUI_DEFLOS_ALT,EVENT
;- ������ʾ����
;- չʾps��ֲ�ͼ��������ʾps���LOS���α���
  device,get_screen_size=screen_size
  xoffset=20
  yoffset=20
  tlb=widget_base(title='LOS���α��ѯ',xoffset=xoffset,yoffset=yoffset,tlb_frame_attr=1,/column,/tlb_size_event,/tlb_kill_request_event)
  base_input=widget_base(tlb,row=1)
  base_pwr=widget_base(base_input,row=2,frame=1)
  label=widget_label(base_pwr,value='��ͼ��',xsize=80)
  button_pwr=widget_button(base_pwr,value='��',uname='button_pwr',xsize=75)
  text_pwr=widget_text(base_pwr,value='',uname='text_pwr',xsize=25)
  base_plist=widget_base(base_input,row=2,frame=1)
  label=widget_label(base_plist,value='ps���ļ���',xsize=80)
  button_plist=widget_button(base_plist,value='��',uname='button_plist',xsize=75)
  text_plist=widget_text(base_plist,value='',uname='text_plist',xsize=25)
  base_sarlist=widget_base(base_input,row=2,frame=1)
  label=widget_label(base_sarlist,value='Ӱ���б��ļ�:',xsize=80)
  button_sarlist=widget_button(base_sarlist,value='��',uname='button_sarlist',xsize=75)
  text_sarlist=widget_text(base_sarlist,value='',uname='text_sarlist',xsize=25)  
  base_label=widget_base(base_input,row=2,frame=1)
  label=widget_label(base_label,value='LOS���α䣺',xsize=80)
  button_los=widget_button(base_label,value='��',uname='button_los',xsize=75)
  text_los=widget_text(base_label,value='',uname='text_los',xsize=25)
  
  
  draw=widget_draw(tlb,retain=0,xsize=682,ysize=682,uvalue=[0,0,0],$
                   /wheel_events,/button_events,/expose_events,/motion_events,/keyboard_events,uname='draw')
                   ;- draw�����value��Ӧ����ֵ��
                   ;- pstlb_on:�ж�ps��Ϣ��ʾ���Ƿ��Ѿ�����
                   ;- pstlb:ps��Ϣ��ʾ���ID
                   ;- ps_label: ps��Ϣ��ʾ����label�����ID
  draw_label=widget_label(tlb,value='X:Y:Gray:',/align_left,uname='draw_label',xsize=465)
  ;- ��ʼ�����
  widget_control,tlb,/realize
  sz=widget_info(tlb,/geom)
  drawsz=widget_info(draw,/geom)
  drawspace=[sz.xsize,sz.ysize]-[drawsz.xsize,drawsz.ysize]
  state={text_pwr:text_pwr,text_plist:text_plist,text_los:text_los,drawspace:drawspace,draw:draw,draw_label:draw_label,text_sarlist:text_sarlist}
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  xmanager,'sargui_deflos',tlb,/no_block  
END