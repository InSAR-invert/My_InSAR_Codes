;+
; ����inPer%�ü�����ʵ�ִ��룬���������ԱȲ��ԣ���ENVI��Ĭ������Ч����ȫһ�¡�
; ����������
;   Ĭ�ϲ�дinPer����Ϊ2%���Բü����죬��ENVI��ͼ��Ĭ��һ��
; ����Ҫ��
;   ����Ϊ������[width,height]�� [band,width,height]��ʽ
;   �ٷֱȿ��������룬Ĭ��Ϊ2%
; 
; http://bbs.esrichina-bj.cn/ESRI/?fromuid=9806
; http://hi.baidu.com/dyqwrp/
; ����: ������
;
; IDLȺ��
;  IDLWay I-VIP:
;  IDLWAY_II: 42102772
;  IDLWay III��
;
; ��ϵ��ʽ: sdlcdyq@sina.com
;-
FUNCTION LINEAR2, inImage,inPer
  COMPILE_OPT idl2
  ;
  IF N_ELEMENTS(inPer) EQ 0 THEN inPer = 0.02

  sz = SIZE(inImage)
  ;ͼ��̫��Ļ�ͳ��̫����ģ��ENVI������Scroll���ڽ���ͳ�ƣ�Ĭ�ϴ�С��256*256
  IF sz[0] EQ 2 THEN BEGIN
    image = CONGRID(inImage, 256, 256)
  ENDIF ELSE BEGIN
    image = CONGRID(inImage, sz[1], 256, 256)
  ENDELSE
  ;ͼ�������Ϣ
  sz = SIZE(image)
  IF sz[0] EQ 2 THEN BEGIN
    nPlanes = 1
    x = sz[1]
    y = sz[2]
  ENDIF ELSE BEGIN
    nPlanes = 3
    x = sz[2]
    y = sz[3]
  ENDELSE

  outImage = inImage

  FOR i=0, nPlanes-1 DO BEGIN
    IF nPlanes EQ 3 THEN img = REFORM(image[i,*,*]) ELSE img=image
    ;ֱ��ͼͳ��
    array = HISTOGRAM(img,oMax = maxV,oMin = minV)
    arrnumb= N_ELEMENTS(array)
    ;
    percent = TOTAL(array,/CUMULATIVE)/TOTAL(array)
    idx1 = WHERE(percent LE inPer)
    idx2 = WHERE(percent GE inPer)
    number = N_ELEMENTS(idx1)
    ;���㵱ǰinpert��Ӧ����ֵ ��2%��
    ;����������ȡ�ٽ�����
    curIdx = (ABS(percent[idx1[number-1]]-inPer) LE ABS(percent[idx2[0]]-inPer))? idx1[number-1]:idx2[0]
    minvalue = minV +(maxV-minV)*curIdx/(arrnumb-1)
    ;1-inper��Ӧ��ֵ ��98%��
    idx1 = WHERE(percent LE (1-inPer))
    idx2 = WHERE(percent GE (1-inPer))
    number = N_ELEMENTS(idx1)
    ;����������ȡ�ٽ�����
    curIdx = (ABS(percent[idx1[number-1]]-1+inPer) LE ABS(percent[idx2[0]]-1+inPer))? idx1[number-1]:idx2[0]
    maxvalue = minV +(maxV-minV)*curIdx/(arrnumb-1)
    ;�����λ��Ƕನ��
    IF nPlanes EQ 3 THEN $
      outImage[i,*,*] = BYTSCL(outImage[i,*,*], max=maxvalue, min=minvalue) $
    ELSE outImage = BYTSCL(outImage, max=maxvalue, min=minvalue)
  ENDFOR

  IF nPlanes EQ 1 THEN outImage = REFORM(outImage)

  RETURN, outImage
END