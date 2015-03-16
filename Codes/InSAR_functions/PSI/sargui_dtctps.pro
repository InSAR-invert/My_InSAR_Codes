

PRO SARGUI_DTCTPS_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname(0) of
  'listbutton':begin
    infile=dialog_pickfile(title='��ѡ�������ļ�',file='sarlist.dat',filter='*.dat',/read)
    if infile eq '' then return
    if infile ne '' then begin
      nlines=file_lines(infile)
      names=strarr(nlines)
      openr,lun,infile,/get_lun
      readf,lun,names
      free_lun,lun
      widget_control,(*pstate).list,set_uvalue=names
      widget_control,(*pstate).list,set_value=names
    endif
  end
  'outbutton':begin
    outfile=dialog_pickfile(title='��ѡ������ļ�',filter='*.dat',file='plist.dat',/overwrite_prompt,/write)
    if outfile ne '' then begin
      widget_control,(*pstate).outpath,set_value=outfile
      widget_control,(*pstate).outpath,set_uvalue=outfile
    endif
  end
  'cl':begin
    result=dialog_message('ȷ���˳���',title='�˳�',/question,/default_no)
    if result eq 'Yes'then begin
      widget_control,event.top,/destroy
    endif else begin
    return
    endelse
  end
  'ok':begin
    ;-����������
    wtlb = WIDGET_BASE(title = '������')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='������... ���Ե�')
    Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0
    ;-��ȡ�ļ������к�
    list_num=widget_info((*pstate).list,/list_number);�ж�list���Ƿ����ļ�
    if list_num eq 0 then begin
      result=dialog_message('δ�ҵ������ļ�',title='�������ļ�',/information)
    endif else begin
      widget_control,(*pstate).list,get_uvalue=names
      widget_control,(*pstate).outpath,get_value=outfile
      if outfile eq '' then begin
      result=dialog_message('��ѡ������ļ�',title='�ļ����',/information)
      endif else begin
      infile=names(0)
      infiles=names
      fpath=strsplit(infile,'\',/extract);���ļ�·���ԡ�\��Ϊ��λ����
      pathsize=size(fpath)
      fname=fpath(pathsize(1)-1)
      file=strsplit(fname,'.',/extract)
      hdrfile=file(0)+'.rslc.par';ͷ�ļ�����
      hdrpath=''
      for i=0,pathsize(1)-2 do begin
        hdrpath=hdrpath+fpath(i)+'\'
      endfor
      hpath=hdrpath+hdrfile;-ͷ�ļ�ȫ·��
      files=findfile(hpath,count=numfiles)
      ;-�Ҳ���ͷ�ļ�������ʾ
      if (numfiles eq 0) then begin
        result=dialog_message('δ�ҵ�ͷ�ļ����뽫ͷ�ļ�������ͬ�ļ�����',title='ͷ�ļ�δ�ҵ�')
      endif else begin
      ;-�ҵ�ͷ�ļ�����ȡ�ļ����к�
        openr,lun,hpath,/get_lun
        temp=''
        for i=0,9 do begin
          readf,lun,temp
        endfor
        readf,lun,temp
        columns=(strsplit(temp,/extract))(1)
        columns=double(columns)
        readf,lun,temp
        lines=(strsplit(temp,/extract))(1)
        lines=double(lines)     
        num=0
        temp0=intarr(columns*2,lines);Ҳ���Դ����������飬���Ǵ�С�����д���
        ;infiles=dialog_pickfile(filter='*.rslc',/read)
        plist=complexarr(2000000)
        ave_pwr=lonarr(columns,lines)
        infiles=names
        dim=list_num
        image=lonarr(columns,lines,dim)
        pwr=lonarr(dim)
        Idlitwdprogressbar_setvalue, process, 5;-���������ȵ���
;        infiles=strarr(dim)
        ;-��ʼ����PS��
        for k=0,dim-1 do begin
          infile=infiles(k)
          slc=openslc(infile)
          r_part=real_part(slc)
          i_part=imaginary(slc)
          image(*,*,k)=sqrt(r_part^2+i_part^2)
          ave_pwr=ave_pwr+image(*,*,k)/dim;��ȡƽ�����Ӱ��
          progressbar_value=5+80*(k+1)/dim
          Idlitwdprogressbar_setvalue, process, progressbar_value;-���ý���������
        endfor
        ave_pwr=adapt_hist_equal(ave_pwr)
        Idlitwdprogressbar_setvalue, process, 88;-���ý���������
        ;-��ֵ����1��sta_flag
        ave_im=mean(image)
        Idlitwdprogressbar_setvalue, process, 91;-���ý���������
        da_im=stddev(image)
        Idlitwdprogressbar_setvalue, process, 94;-���ý���������
        sta_flag=ave_im+da_im*2
        ;-��ֵ����2��det
        columns_lines=columns*lines
        for i=0,columns-1 do begin
        for j=0,lines-1 do begin
          pwr=image(i,j,*)
          ;a=0.0 & da=0.0
          a= mean(pwr)
          da= stddev(pwr)
          det=a/da
          if det GE 2.5 && a GE sta_flag then begin
            plist(num)=complex(i,j)
            num=num+1;num������������PS�����Ŀ
          endif
        endfor
        Idlitwdprogressbar_setvalue, process, 94+4*i/500;-���ý���������
        endfor
        Idlitwdprogressbar_setvalue, process, 98;-���ý���������
        
        if num GE 1 then begin
          ps=plist(0:num-1)
          openw,lun,outfile,/get_lun
          printf,lun,ps
          free_lun,lun
          Idlitwdprogressbar_setvalue, process, 100;-���ý���������
          WIDGET_CONTROL,process,/Destroy
          WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
          result=dialog_message('�ļ�������',title='�ļ����',/information)
          widget_control,(*pstate).resulttext,set_value=string(num)
          widget_control,(*pstate).resulttext,set_uvalue=string(num)
;          widget_control,(*pstate).resultlabel,set_value=string(num)
          widget_control,(*pstate).outbutton,set_uvalue=ave_pwr
        endif else begin
          result=dialog_message('δ�ҵ�PS�㣬�ļ�δ���',title='�ļ����',/information)  
        endelse
        endelse
      endelse
    endelse   
  end 
  'disyes':begin
    widget_control,(*pstate).outbutton,get_uvalue=pwr
    widget_control,(*pstate).outpath,get_uvalue=outpath
    if n_elements(pwr) eq 1 then result=dialog_message('������PS̽������ʾ',title='��ʾ����',/information)
;    if outpath eq '' then result=dialog_message('������PS̽������ʾ',title='��ʾ����',/information)
    if (n_elements(pwr) gt 1) then begin
        window_size=size(pwr)
        window,xsize=window_size(1),ysize=window_size(2),title='PS��ֲ�ͼ'
        tv,pwr
        widget_control,(*pstate).resulttext,get_uvalue=psnum
        ps=complexarr(psnum)
        openr,lun,outpath,/get_lun
        readf,lun,ps
        free_lun,lun
        
        device,get_decomposed=old_decomposed,decomposed=0
        TvLCT, 0,255,0,1
        r_part=real_part(ps)
        i_part=imaginary(ps)
        plots,r_part,i_part,psym=1,/device,color=1
        device,decomposed=old_decomposed
        result=dialog_message('�Ƿ񱣴��ļ�',title='�����ļ�',/question)
        if (result eq 'Yes') then begin
          ps_layover=tvrd(0,0,500,500,true=1)
          outpath=dialog_pickfile(title='����ļ�',filter='*.bmp',file='pslayover.bmp',/write,/overwrite_prompt)
          write_bmp,outpath,ps_layover
          result=dialog_message('�ļ�������')
        endif else begin
        return
        endelse
    endif
  end
  else:return
endcase
END


PRO SARGUI_DTCTPS,EVENT
;-�����������
device,get_screen_size=screen_size
;xsize=screen_size(0)/3
xsize=300
tlb=widget_base(title='PS̽��',column=1,tlb_frame_attr=1,xsize=xsize,ysize=470,xoffset=screen_size(0)/3,yoffset=screen_size(1)/5)
;-����PS̽��������
dettlb=widget_base(tlb,column=1,tlb_frame_attr=1,ysize=380)

labeltlb=widget_base(dettlb,row=1)
dtct=widget_label(labeltlb,value='PS̽��')

inputtlb=widget_base(dettlb,column=1,tlb_frame_attr=1)
listbutton=widget_button(inputtlb,value='��Ӱ���б��ļ�',uname='listbutton')
list=widget_list(inputtlb,value='',uname='list',ysize=20,xsize=42)

resulttlb=widget_base(dettlb,row=1,tlb_frame_attr=1)
resultlabel=widget_label(resulttlb,value='̽�⵽��PS����Ŀ��',xsize=203)
resulttext=widget_text(resulttlb,value='0',uname='resulttext',xsize=11)

outtlb=widget_base(dettlb,row=1,tlb_frame_attr=1)
outpath=widget_text(outtlb,value='',uvalue='',uname='outpath',/editable,xsize=32)
outbutton=widget_button(outtlb,value='����ļ�',uvalue='',uname='outbutton',xsize=80)

funtlb=widget_base(dettlb,row=1,tlb_frame_attr=1,/align_right)
ok=widget_button(funtlb,value='����',uname='ok',xsize=80)
;dis=widget_button(funtlb,value='��ʾ���',uname='disp',xsize=80)
cl=widget_button(funtlb,value='�˳�',uname='cl',xsize=80)

;-����PS��ʾ������
labeltlb_second=widget_base(tlb)
fengexian=widget_label(labeltlb_second,value='������������������������������������������������')

disptlb=widget_base(tlb,column=1,tlb_frame_attr=1)
labeltlb_third=widget_base(disptlb)
dispID=widget_label(labeltlb_third,value='PS��ʾ')

choosetlb=widget_base(disptlb,row=1,tlb_frame_attr=1)
buttonbase=widget_label(choosetlb,value='�Ƿ���ʾPS����ͼ��',xsize=200)
disyes=widget_button(choosetlb,value='��ʾ�����',uname='disyes',xsize=80)
;buttonbase=widget_base(choosetlb,row=1,/exclusive)
;dispyes=widget_button(buttonbase,value='��',uname='dispyes')
;dispno=widget_button(buttonbase,value='��',uname='dispno')
;
;choosetlb=widget_base(disptlb,row=1,tlb_frame_attr=1)
;buttonbase=widget_label(choosetlb,value='�Ƿ����PS����ͼ��',xsize=200)
;outyes=widget_button(choosetlb,value='���',uname='outyes',xsize=80)
;buttonbase=widget_base(choosetlb,row=1,/exclusive)
;outyes=widget_button(buttonbase,value='��')
;outno=widget_button(buttonbase,value='��')


;buttonbase=widget_base(disptlb,row=1,tlb_frame_attr=1)
;dispout=widget_text(buttonbase,value='',uname='dispout',/editable,xsize=32)
;dispbutton=widget_button(buttonbase,value='����ļ�',uname='dispbutton',xsize=80)

;-����ָ��
state={listbutton:listbutton,list:list,outpath:outpath,outbutton:outbutton,$
       resulttext:resulttext,ok:ok,cl:cl,resultlabel:resultlabel}
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate       
widget_control,tlb,/realize
xmanager,'sargui_dtctps',tlb,/no_block
END