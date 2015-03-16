FUNCTION Ground, X
  RETURN, [X(0)^2-X(0)*2*!coe0(0)+ $
           X(1)^2-X(1)*2*!coe0(1)+ $
           X(2)^2-X(2)*2*!coe0(2)+ $
           !coe1(3), $ ;б�෽��
           X(0)*!coe1(0)+X(1)*!coe1(1)+X(2)*!coe1(2)+!coe1(3), $ ;������շ���
           X(0)^2*!coe2(0)+X(1)^2*!coe2(1)+X(2)^2*!coe2(2)-1 $ ;���򷽳�
           ]
END
FUNCTION STime, x
  RETURN, (x^2*!coevx(0)+x*!coevx(1)+!coevx(2))*(x^2*!coepx(0)+x*!coepx(1)+!coepx(2)-!POS(0))+ $
          (x^2*!coevy(0)+x*!coevy(1)+!coevy(2))*(x^2*!coepy(0)+x*!coepy(1)+!coepy(2)-!POS(1))+ $
          (x^2*!coevz(0)+x*!coevz(1)+!coevz(2))*(x^2*!coepz(0)+x*!coepz(1)+!coepz(2)-!POS(2))
;           (x^3,x^2,x,1)##TRANSPOSE(!coevx)*(!P(0)-(x^3,x^2,x,1)##TRANSPOSE(!coepx))+ $
;           !coevy##TRANSPOSE(x^3,x^2,x,1)*(!P(1)-!coepy##TRANSPOSE(x^3,x^2,x,1))+ $
;           !coevz##TRANSPOSE(x^3,x^2,x,1)*(!P(2)-!coepz##TRANSPOSE(x^3,x^2,x,1))
END

FUNCTION CENTER_POS,INFILE,time
  ;-��ȡ����ʱ��
  c_time=read_slcpar(infile,'center_time:')
  c_time=strsplit(c_time,' ',/extract)
  c_time=c_time(1)
;  c_time=time
  ;-��ȡ����״̬ʸ��������ʼʱ�̼���ʱ����
  time_of_first_state_vector=read_slcpar(infile,'time_of_first_state_vector:')
  time_of_first_state_vector=strsplit(time_of_first_state_vector,' ',/extract)
  time_of_first_state_vector=time_of_first_state_vector(1)
  state_vector_interval=read_slcpar(infile,'state_vector_interval:')
  state_vector_interval=strsplit(state_vector_interval,' ',/extract)
  state_vector_interval=state_vector_interval(1)
  ;-��ȡ����״̬ʸ������
  state_vector_position=read_slcpar(infile,'state_vector_position')  
  sz=size(state_vector_position)
  x=dblarr(sz(1))
  y=x
  z=x
  t=x
  for i=0,sz(1)-1 do begin
    p_vector=strsplit(state_vector_position(i),' ',/extract)
    x(i)=p_vector(1)
    y(i)=p_vector(2)
    z(i)=p_vector(3)
    t(i)=time_of_first_state_vector+state_vector_interval*i    
  endfor
  ;-��ֵ��ȡ��������λ��
  coefx=svdfit(t,x,3,/double)
  coefy=svdfit(t,y,3,/double)
  coefz=svdfit(t,z,3,/double)
  x_center=poly(c_time,coefx)
  y_center=poly(c_time,coefy)
  z_center=poly(c_time,coefz)
  center_pos=[x_center,y_center,z_center]
  return,center_pos
END
FUNCTION CENTER_V,INFILE,time
  ;-��ȡ����ʱ��
  c_time=read_slcpar(infile,'center_time:')
  c_time=strsplit(c_time,' ',/extract)
  c_time=c_time(1)
;  c_time=time
  ;-��ȡ����״̬ʸ��������ʼʱ�̼���ʱ����
  time_of_first_state_vector=read_slcpar(infile,'time_of_first_state_vector:')
  time_of_first_state_vector=strsplit(time_of_first_state_vector,' ',/extract)
  time_of_first_state_vector=time_of_first_state_vector(1)
  state_vector_interval=read_slcpar(infile,'state_vector_interval:')
  state_vector_interval=strsplit(state_vector_interval,' ',/extract)
  state_vector_interval=state_vector_interval(1)
  ;-��ȡ�����ٶ�ʸ������
  state_vector_position=read_slcpar(infile,'state_vector_velocity')  
  sz=size(state_vector_position)
  x=dblarr(sz(1))
  y=x
  z=x
  t=x
  for i=0,sz(1)-1 do begin
    p_vector=strsplit(state_vector_position(i),' ',/extract)
    x(i)=p_vector(1)
    y(i)=p_vector(2)
    z(i)=p_vector(3)
    t(i)=time_of_first_state_vector+state_vector_interval*i    
  endfor
  ;-��ֵ��ȡ���������ٶ�
  coefx=svdfit(t,x,3,/double)
  coefy=svdfit(t,y,3,/double)
  coefz=svdfit(t,z,3,/double)
  x_center=poly(c_time,coefx)
  y_center=poly(c_time,coefy)
  z_center=poly(c_time,coefz)
  center_v=[x_center,y_center,z_center]
  return,center_v
END

PRO COARSE_COREGISTRATION
;- �˳������ڼ�����Ӱ������кŵ���Ӱ�����кŵ�ת����
;- ������Ҫ����Ӱ�����к�ӳ�䵽��������꣬����Ҫ�������̣�
;- 1> б�෽��
;-    |MP|=R
;- 2> ������շ���
;-    (MP)��v=0
;- 3> ��Բ����
;-    (X+Y)^2/a^2+Z^2/b^2=1
  ;- ���ݳ�ʼ��
  master='D:\myfiles\My_InSAR_Tools\InSAR\Images\20090327.rslc'
  slave='D:\myfiles\My_InSAR_Tools\InSAR\Images\20090407.rslc'
;  m_c=m_c
;  m_l=m_l
  m_c=250  &  m_l=250
;  master_vector=parameters(master,50,50)
  ;- ���з���
  ;- 1>
  master_par=master+'.par'
  position=center_pos(master_par)
  xm=position(0)
  ym=position(1)
  zm=position(2);λ��
  r=dblarr(3)
  c=r
  temp=read_slcpar(master_par,'near_range_slc:')
  temp=strsplit(temp,' ',/extract)
  r(0)=double(temp(1))
  temp=read_slcpar(master+'.par','center_range_slc:')
  temp=strsplit(temp,' ',/extract)
  r(1)=double(temp(1))
  temp=read_slcpar(master+'.par','far_range_slc:')
  temp=strsplit(temp,' ',/extract)
  r(2)=double(temp(1))
  c(0)=1
  columns=read_slcpar(master+'.par','range_samples:')
  columns=strsplit(columns,' ',/extract)
  columns=double(columns(1))
  c(1)=columns/2
  c(2)=columns
  coef=svdfit(c,r,2,/double)
  r_c=poly(m_c,coef);б��
;  (xm-xp)^2+(ym-yp)^2+(zm-zp)^2-r_c^2=f
  ;- 2>
  velocity=center_v(master_par)
;  [xp,yp,zp]*transpose(velocity)=0
  ;- 3>
  a=read_slcpar(master_par,'earth_semi_major_axis:')
  a=strsplit(a,' ',/extract)
  a=a(1)
  b=read_slcpar(master_par,'earth_semi_minor_axis:')
  b=strsplit(b,' ',/extract)
  b=b(1)
;  (xp^2+yp^2)/a^2+zp^2/b^2=1

  ;-����ϵͳ�������ⷽ��
  DEFSYSV, '!coe0', [position, xm^2+ym^2+zm^2-r_c^2]
  DEFSYSV, '!coe1', [velocity, -velocity*TRANSPOSE(position)]
  DEFSYSV, '!coe2', [1/a^2, 1/a^2, 1/b^2]
  P=IMSL_ZEROSYS('Ground', 3)
;  PRINT, P
  DEFSYSV, '!POS', P


;-������ݵ�������귴���Ӱ��ĳ���ʱ��
  slave_par=slave+'.par'
  infile=slave_par
  
   ;-��ȡ����ʱ��
  c_time=read_slcpar(infile,'center_time:')
  c_time=strsplit(c_time,' ',/extract)
  c_time=c_time(1)
;  c_time=time
  ;-��ȡ����״̬ʸ��������ʼʱ�̼���ʱ����
  time_of_first_state_vector=read_slcpar(infile,'time_of_first_state_vector:')
  time_of_first_state_vector=strsplit(time_of_first_state_vector,' ',/extract)
  time_of_first_state_vector=time_of_first_state_vector(1)
  state_vector_interval=read_slcpar(infile,'state_vector_interval:')
  state_vector_interval=strsplit(state_vector_interval,' ',/extract)
  state_vector_interval=state_vector_interval(1)
  ;-��ȡ����״̬ʸ������
  state_vector_position=read_slcpar(infile,'state_vector_position')  
  sz=size(state_vector_position)
  x=dblarr(sz(1))
  y=x
  z=x
  t=x
  for i=0,sz(1)-1 do begin
    p_vector=strsplit(state_vector_position(i),' ',/extract)
    x(i)=p_vector(1)
    y(i)=p_vector(2)
    z(i)=p_vector(3)
    t(i)=time_of_first_state_vector+state_vector_interval*i    
  endfor
  ;-��ֵ��ȡ����ʱ�̵�λ�����ϵ��
  coefx=svdfit(t,x,3,/double)
  coefy=svdfit(t,y,3,/double)
  coefz=svdfit(t,z,3,/double)
  DEFSYSV, '!coepx', coefx
  DEFSYSV, '!coepy', coefy
  DEFSYSV, '!coepz', coefz


  
  
  
  ;-��ȡ����״̬ʸ��������ʼʱ�̼���ʱ����
  time_of_first_state_vector=read_slcpar(infile,'time_of_first_state_vector:')
  time_of_first_state_vector=strsplit(time_of_first_state_vector,' ',/extract)
  time_of_first_state_vector=time_of_first_state_vector(1)
  state_vector_interval=read_slcpar(infile,'state_vector_interval:')
  state_vector_interval=strsplit(state_vector_interval,' ',/extract)
  state_vector_interval=state_vector_interval(1)
  ;-��ȡ�����ٶ�ʸ������
  state_vector_position=read_slcpar(infile,'state_vector_velocity')  
  sz=size(state_vector_position)
  x=dblarr(sz(1))
  y=x
  z=x
  t=x
  for i=0,sz(1)-1 do begin
    p_vector=strsplit(state_vector_position(i),' ',/extract)
    x(i)=p_vector(1)
    y(i)=p_vector(2)
    z(i)=p_vector(3)
    t(i)=time_of_first_state_vector+state_vector_interval*i    
  endfor
  ;-��ֵ��ȡ����ʱ�̵��ٶ����ϵ��
  coefx=svdfit(t,x,3,/double)
  coefy=svdfit(t,y,3,/double)
  coefz=svdfit(t,z,3,/double)
  DEFSYSV, '!coevx', coefx
  DEFSYSV, '!coevy', coefy
  DEFSYSV, '!coevz', coefz
  time=IMSL_ZEROFCN('STime')
  PRINT, time



END