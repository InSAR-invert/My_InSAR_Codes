PRO LAYOVER
;- �����״�ĵ�����Ϣ��ȡ������߳�
;- ��ʵ���Ŀ����ΪPS�ṩ��ȷ�ĵ���߳���Ϣ
;- ��������������֣���������Ϣ����ȡ�Լ��̵߳ļ��㡣
  infile='D:\myfiles\My_InSAR_Tools\InSAR\Images\testbuilding.bmp'
;  infile='/mnt/software/myfiles/My_InSAR_Tools/InSAR/Images/testbuilding.bmp'
  layover_th=240;- �趨�������ص�������ֵ
  layover_r=5;- �趨�������������뾶
  layover_gray_change=10;- �趨�������صĻҶȱ仯��Χ
  im=read_bmp(infile)
  im_size=size(im)
  im_columns=im_size(1)
  im_columns=im_columns(0)
  im_lines=im_size(2)
  im_lines=im_lines(0)
  layover_im=intarr(im_columns,im_lines);- ����layover_im�����洢�ж���Ϣ
  x=0;- �����洢ÿ����x���������
  y=0;- �����洢ÿ����y���������
  z=0;- �����洢ÿ����z���������
  layover_p=create_struct('startx',-1,'starty',-1,'length',-1);- �����洢ÿ����ĸ��ڵ���Ϣ
  uniq_x=0;-�����洢������ʼ��x
  uniq_y=0;-�����洢������ʼ��y
  uniq_z=0;;-�����洢������ʼ��z
;  window,xsize=im_columns,ysize=im_lines
;  tv,im ;- ��ʾԭʼ��ͼ��
  ;- ��ʼ���е������ط���
  wtlb = WIDGET_BASE(title = '������')
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='������... ���Ե�')
  Idlitwdprogressbar_setvalue, process, 0 ;-��ʼ������������ʼֵΪ0
  for i=0, im_lines-1 do begin
    p_value=double(i)/double(im_lines)*100D
    Idlitwdprogressbar_setvalue, process, p_value ;- ���ý�������ֵ

    j=im_columns-1
    while j ge layover_r do begin
      if (im(j,i) ge layover_th) then begin
        if layover_p.startx eq -1 then layover_p.startx=j
        if layover_p.starty eq -1 then layover_p.starty=i
        if layover_p.startx eq -1 then layover_p.length=0
        temp=im(j-layover_r:j-1,i)
        result=where(temp ge im(j,i)-layover_gray_change)
        if total(result) eq -1 then  begin        ;- �Ҳ�����һ���ڵ�
          layover_im(j,i)=0
          layover_p.startx=-1
          layover_p.starty=-1
          layover_p.length=0
          j=j-1
        endif
        if total(result) ge 0 then begin    ;- �ҵ���һ���ڵ�
;          layover_im(j-layover_r+result(0):j,i)=1
          x=[x,replicate(layover_p.startx,n_elements(result))]
          y=[y,replicate(layover_p.starty,n_elements(result))]
          z=[z,layover_r-result+layover_p.length]
          layover_p.length=layover_p.length+layover_r-result(0);- ���ڳ��ȱ仯
          layover_im([j-layover_r+result],i)=1
          layover_im(j,i)=1
          j=j-layover_r+result(0)
        endif
      endif
      if (im(j,i) lt layover_th) then begin
        layover_im(j,i)=0
        layover_p.startx=-1
        layover_p.starty=-1
        layover_p.length=0
        j=j-1
      endif      
    endwhile 
  endfor 

  uniq_index=uniq(x)
  temp=size(uniq_index)
  for i=1,temp(1)-2 do begin
    a=0
    uniq_z_temp=max(z(uniq_index(i):uniq_index(i+1)))
    uniq_z=[uniq_z,uniq_z_temp]
    a=[a,uniq_index(i)-uniq_index(i-1)]
  endfor
  uniq_z=uniq_z(1:*)
  layover_im=layover_im*255
  write_bmp,'D:\myfiles\My_InSAR_Tools\InSAR\testbuilding_layover.bmp',layover_im
  device,decomposed=1
  !p.background='FFFFFF'XL
  !p.color='000000'XL
  window,/free
  tv,im
  window,/free
  PLOT_3DBOX,x,y,z,psym=1
  result= TVRD()
  WRITE_BMP, 'D:\myfiles\My_InSAR_Tools\InSAR\Images\3DBOX.bmp', result

  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-���ٽ�����
  window,/free
  plot,uniq_z(where(uniq_z ge 50))
;  plot,uniq_z(where(uniq_z ge 50 && uniq_z le 80))
  print,mean(uniq_z(where(uniq_z ge 80)))
  window,/free
  plot,uniq_z
  result= TVRD()
  WRITE_BMP, 'D:\myfiles\My_InSAR_Tools\InSAR\Images\height.bmp', result

END

