FUNCTION CENTER_TIME,INFILE
;-������Ϊ����ʱ�䣬ʾ�����£�
;-date:      2009 4 29 22 17 37.3944
openr,lun,infile,/get_lun
temp=''
;-����ͷ�ļ�ǰ����
for i=0,3 do begin
  readf, lun, temp
endfor
;-��ȡʱ�����
readf, lun, temp
line=strsplit(temp,' ',/extract)
year=line(1)
year=string(year)
year=strcompress(year,/remove_all)
month=line(2)
if month lt 10 then begin
  month=string(0)+string(month)
endif else begin
  month=string(month)
endelse
month=strcompress(month,/remove_all)
day=line(3)
if day lt 10 then begin
  day=string(0)+string(day)
endif else begin
  day=string(day)
endelse
day=strcompress(day,/remove_all)
c_time=year+month+day
c_time=long(c_time)
free_lun,lun
return,c_time
END