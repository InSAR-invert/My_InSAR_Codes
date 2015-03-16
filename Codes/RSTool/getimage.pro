;+ 
; Name:
;    GetImage
; Purpose:
;    ����tif��������
; Calling Sequence:
;    result= GetImage(tif)
; Inputs:
;    tif    :   .tif�ļ���ȫ·�� 
; Outputs:
;    result :   ���飬��������ֵ[����������]
; Commendations:
;    infile :   ֻ֧��tif����tiff
; Example:
;    infile= 'D:\myfiles\My_InSAR_Tools\RSTool\lena.tif'
;    result= GetImage(infile)
;    Print, result
; Modification History:
;-   


Function GetImage, infile

  temp= STRSPLIT(infile, '.', /EXTRACT)
  IF (STRCMP(temp[1], 'TIF')+STRCMP(temp[1], 'TIFF')) Then BEGIN ; ֻ֧��.tif��.tiff
    Message, 'Image type not support!'
  ENDIF 
  
  result= QUERY_TIFF(infile,s)
  coled= (s.dimensions)[1]
  rowed= (s.dimensions)[0]
  return_result= [coled, rowed]
  RETURN, return_result
  
END