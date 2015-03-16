;- 
;- Purpose:
;-    Delete all the annotations.
;-
PRO DELANN, inputfile, outputfile

  nlines= FILE_LINES(inputfile)
  str= STRARR(nlines)
  OPENR, lun, inputfile,/GET_LUN
  READF, lun, str
  FREE_LUN, lun
  
  OPENW, lun, outputfile,/GET_LUN
  For i=0, nlines-1 DO BEGIN
    temp= str[i]
    temp_split= STRPOS(temp, ';')
    ;û�зֺ�
    IF TOTAL(temp_split) EQ -1 THEN BEGIN
      PrintF, lun, temp
      CONTINUE
    ENDIF
    
    ; �зֺ�
    IF TOTAL(temp_split) NE -1 THEN BEGIN ; A comment line.
      ; �ж��ֺ�֮ǰ����Ϣ
      IF temp_split[0] EQ 0 THEN BEGIN
        ;�ֺ��ھ���
        CONTINUE
      ENDIF ELSE BEGIN
        ; �ֺŲ��ھ���
        ; �鿴��һ����̖֮ǰ�Ƿ���
         pretemp= STRMID(temp, 0, temp_split[0])
         pretemp_split= STRSPLIT(pretemp, ' ',/EXTRACT)
        ; ���
        IF pretemp_split[0] EQ '' THEN BEGIN
          CONTINUE
        ENDIF ELSE BEGIN
        ; �����
          pretemp= STRMID(temp, 0, temp_split[0])
          PRINTF, lun, pretemp
        ENDELSE
      
      ENDELSE
      
    ENDIF
  ENDFOR
  FREE_LUN, lun
END


PRO TLI_DELANN

  origpath='D:\ISEIS\Codes\CUHK'
  tarpath='F:\CUInSAR-GroupWorkspace\CUHK'
  
  ; Find *.pro in the original path
  fnames= FILE_SEARCH(origpath, '*.pro', count=fcount)
  FOR i=0, fcount-1 DO BEGIN
    fname= fnames[i]
    strlength1= STRLEN(fname)
    strlength2= STRLEN(origpath)
    remainlen= strlength1-strlength2
    remain= STRMID(fname, strlength2, remainlen)
    
    tarfname= tarpath+remain
    
    tarfullpath= FILE_DIRNAME(tarfname)
    
    IF ~FILE_TEST(tarfullpath,/DIRECTORY) THEN FILE_MKDIR, tarfullpath
    
    DELANN, fname, tarfname
    
  
  ENDFOR
  
Print, 'Main pro finished.'
END