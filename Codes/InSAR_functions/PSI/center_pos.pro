FUNCTION CENTER_POS,INFILE
openr,lun,infile,/get_lun
temp=''
x=dblarr(12)
y=x
z=x
t=dblarr(12)
;-������ʼ����������
for i=0,5 do begin
readf, lun, temp
endfor
;-��ȡ���������ʱ��
readf, lun, temp
line=strsplit(temp,' ',/extract)
center_time=line(1)
;-������������39��
for i=7,46 do begin
readf, lun, temp
endfor
;-��ȡ����״̬ʸ��������ʼʱ�̼���ʱ����
readf, lun, temp
line=strsplit(temp,' ',/extract)
time_of_first_state_vector=double(line(1))
readf, lun, temp
line=strsplit(temp,' ',/extract)
state_vector_interval=double(line(1))
;-��ȡ����״̬ʸ������
;for i=49,71 do begin
for i=0,8 do begin
readf, lun, temp
line=strsplit(temp,' ',/extract)
    x(i)=double(line(1))            ;get x coordinate at the i-th orbit position
    y(i)=double(line(2))            ;get y .....
    z(i)=double(line(3))            ;get z .....
    t(i)=time_of_first_state_vector+state_vector_interval*i
readf, lun, temp
endfor
;-��ֵ��ȡ��������λ��
coefx=svdfit(t,x,3,/double)
coefy=svdfit(t,y,3,/double)
coefz=svdfit(t,z,3,/double)
x_center=poly(center_time,coefx)
y_center=poly(center_time,coefy)
z_center=poly(center_time,coefz)
free_lun,lun
center_pos=[x_center,y_center,z_center]
return,center_pos
END