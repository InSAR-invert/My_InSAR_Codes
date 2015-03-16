PRO SARGUI_DELAUNEY_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'psbutton':begin
    infile=dialog_pickfile(title='���ļ�',filter='*.dat',file='plist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).pstext,set_value=infile
    widget_control,(*pstate).pstext,set_uvalue=infile
  end
  'sarbutton':begin
    infile=dialog_pickfile(title='���ļ�',filter='*.dat',file='sarlist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).sartext,set_value=infile
    widget_control,(*pstate).sartext,set_uvalue=infile
  end
  'outbutton':begin
    outfile=dialog_pickfile(title='����ļ�',filter='*.dat',file='arcs.dat',/write,/overwrite_prompt)
    if outfile eq '' then return
    widget_control,(*pstate).outtext,set_value=outfile
    widget_control,(*pstate).outtext,set_uvalue=outfile
  end
  'debutton':begin
  ;-���PS�ļ��Ƿ��Ѿ�����
    widget_control,(*pstate).pstext,get_uvalue=psinfile
    widget_control,(*pstate).sartext,get_uvalue=slcinfile
    if ((psinfile eq '' )and (slcinfile eq '')) then begin
      result=dialog_message('��ѡ��PS�ļ��Լ�SLC�б��ļ�',title='���ļ�',/information)
      return
    endif else begin
    ;-��ȡSLC�ļ����Ծ�ֵͼ��Ϊ��ʾ�������ĵ�ͼ
      nlines=file_lines(slcinfile)
      names=strarr(nlines)
      openr,lun,slcinfile,/get_lun
      readf,lun,names
      free_lun,lun
      
      infile=names(0)
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
      if (numfiles eq 0) then begin
        result=dialog_message('δ�ҵ�ͷ�ļ����뽫ͷ�ļ�������ͬ�ļ�����',title='ͷ�ļ�δ�ҵ�')
      endif else begin
        openr,lun,hpath,/get_lun
        temp=''
        for i=0,9 do begin
          readf,lun,temp
        endfor
        readf,lun,temp
        columns=(strsplit(temp,/extract))(1)
        readf,lun,temp
        lines=(strsplit(temp,/extract))(1)
        pwr=dblarr(columns,lines)
        for i=0,nlines-1 do begin
          slc=openslc(names(i))
          r_part=long(real_part(slc))
          i_part=long(imaginary(slc))
          amplitude=sqrt(r_part^2+i_part^2)
          pwr=pwr+amplitude/nlines
        endfor
        pwr=adapt_hist_equal(pwr)

      endelse
    ;-��ȡPS�ļ�
      ;- �ж�ps�����Ŀ
      widget_control,(*pstate).pstext,get_uvalue=psinfile
      openr,lun,psinfile,/get_lun
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

      ps=complexarr(numps)
      openr,lun,psinfile,/get_lun
      readf,lun,ps
      free_lun,lun
      file_columns=columns
      file_lines=lines;���ļ����к������file_columns & file_lines
      columns=real_part(ps)
      rows=imaginary(ps)
    ;-����������
      Triangulate,columns,rows,triangles,boundarypts
      s=size(triangles,/dimensions)
      num_triangles=s[1]
      window,/free,xsize=file_columns,ysize=file_lines,title='Delauney������'
      tv,pwr;��ʾ��ͼ
      device,get_decomposed=old_decomposed,decomposed=0;�޸�ϵͳ��ɫ����
      TvLCT, 0,255,0,1;��ȡ��ɫ��
      i=0D
      num_trangles=double(num_triangles)
      for i=0D,num_triangles-1D do begin
          thisTriangle=[triangles[*,i],triangles[0,i]]
          plots,columns[thistriangle],rows[thistriangle],color=1,/device
      ;    plots,columns[thistriangle],rows[thistriangle],/device
      endfor
      decomposed=old_decomposed
      num=numps
      zg=intarr(num,num)
      num=double(num)
      arcs=complexarr(num*5)

      arcs(0)=complex(triangles(0,0),triangles(1,0))
      zg(triangles(0,0),triangles(1,0))=1 & zg(triangles(1,0),triangles(0,0))=1
      arcs(1)=complex(triangles(1,0),triangles(2,0))
      zg(triangles(1,0),triangles(2,0))=1 & zg(triangles(2,0),triangles(1,0))=1
      arcs(2)=complex(triangles(2,0),triangles(0,0))
      zg(triangles(2,0),triangles(0,0))=1 & zg(triangles(0,0),triangles(2,0))=1

      j=1D & num_arcs=3D

      while j lt num_triangles do begin
       
        if ~zg(triangles(0,j),triangles(1,j)) && ~zg(triangles(1,j),triangles(0,j)) then begin
          arcs(num_arcs)=complex(triangles(0,j),triangles(1,j))
          num_arcs=num_arcs+1
          zg(triangles(0,j),triangles(1,j))=1 & zg(triangles(1,j),triangles(0,j))=1
        endif
      
        if ~zg(triangles(1,j),triangles(2,j)) && ~zg(triangles(2,j),triangles(1,j)) then begin
          arcs(num_arcs)=complex(triangles(1,j),triangles(2,j))
          num_arcs=num_arcs+1
          zg(triangles(1,j),triangles(2,j))=1 & zg(triangles(2,j),triangles(1,j))=1
        endif
      
        if ~zg(triangles(2,j),triangles(0,j)) && ~zg(triangles(0,j),triangles(2,j)) then begin
          arcs(num_arcs)=complex(triangles(0,j),triangles(2,j))
          num_arcs=num_arcs+1
          zg(triangles(2,j),triangles(0,j))=1 & zg(triangles(0,j),triangles(2,j))=1
        end
         
        j=j+1   
      endwhile
      bl=arcs(0:num_arcs-1)
      num_triangles=strcompress(num_triangles)
      num_arcs=strcompress(num_arcs)
      widget_control,(*pstate).tritext,set_value=num_triangles
;widget_control,(*pstate).delabel,set_value=num_triangles
      widget_control,(*pstate).linetext,set_value=num_arcs
      widget_control,(*pstate).psbutton,set_uvalue=bl
    endelse
  end
  'ok':begin
    widget_control,(*pstate).psbutton,get_uvalue=bl
    widget_control,(*pstate).outtext,get_uvalue=outfile
    if ((n_elements(bl) eq 0) or (outfile eq ''))then begin
      result=dialog_message('���ȹ���Delauney������',title='����˳�����',/information)
    endif else begin
      openw,lun,outfile,/get_lun
      printf,lun,bl
      free_lun,lun
      result=dialog_message('�ļ�������,�Ƿ�رնԻ���',title='�ļ����',/question)
      if result eq 'Yes' then widget_control,event.top,/destroy
      if result eq 'No' then return
    endelse
  end
  'cl':begin
    result=dialog_message('ȷ���˳���',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif else begin
      return
    endelse
  end    
  else:return
endcase
END

PRO SARGUI_DELAUNEY,EVENT
device,get_screen_size=screen_size
;-�������
tlb=widget_base(xsize=380,ysize=275,column=1,tlb_frame_attr=1,xoffset=screen_size(0)/3)
;-��ȡPS��
pstlb=widget_base(tlb,row=1,tlb_frame_attr=1)
pstext=widget_text(pstlb,value='',uvalue='',/editable,xsize=45,uname='pstext')
psbutton=widget_button(pstlb,value='��PS���ļ�',xsize=80,uname='psbutton')
;-��ȡSLCӰ���б�
sartlb=widget_base(tlb,row=1,tlb_frame_attr=1)
sartext=widget_text(sartlb,/editable,xsize=45,value='',uvalue='',uname='sartext')
sarbutton=widget_button(sartlb,value='��SLC�б�',xsize=80,uname='sarbutton')
;-����Delayney������
;detlb=widget_base(tlb,row=1,tlb_frame_attr=1)
buttonbase=widget_base(tlb,tlb_frame_attr=1,xsize=380)
debutton=widget_button(buttonbase,value='����Delauney������',uname='debutton',ysize=100,xsize=380)
detlb=widget_base(tlb,row=1,tlb_frame_attr=1)
delabel=widget_label(detlb,value='������������Ŀ(��):')
tritext=widget_text(detlb,value='',uvalue='',uname='tritext',xsize=8)
delabel=widget_label(detlb,value='���ɻ�����Ŀ(��):')
linetext=widget_text(detlb,value='',uvalue='',uname='linetext',xsize=10)
;-����������ܰ�ť
outtlb=widget_base(tlb,row=1,tlb_frame_attr=1)
outtext=widget_text(outtlb,value='',uvalue='',uname='outtext',/editable,xsize=45)
outbutton=widget_button(outtlb,value='���������Ϣ',uname='outbutton')
funtlb=widget_base(tlb,column=1,tlb_frame_attr=1,/align_right)
ok=widget_button(funtlb,value='ȷ��',uvalue='',uname='ok',xsize=80)
cl=widget_button(funtlb,value='ȡ��',uvalue='',uname='cl',xsize=80)
;-ʶ�����
state={pstext:pstext,psbutton:psbutton,sartext:sartext,sarbutton:sarbutton,$
       debutton:debutton,tritext:tritext,linetext:linetext,outtext:outtext,$
       ok:ok,cl:cl,outbutton:outbutton,delabel:delabel}
pstate=ptr_new(state)       
widget_control,tlb,set_uvalue=pstate       
widget_control,tlb,/realize
xmanager,'SARGUI_DELAUNEY',tlb,/no_block
END