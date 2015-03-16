;+--------------------------------------------------------------------------
;| ����������----һ�������г��ִ�����������
;| ����: ��ֵ����----û��ά������
;| ���: Return ����
;|           �ؼ������: bigfreq: �������ִ���
;+--------------------------------------------------------------------------
;
; History:
;   Original version: Copy from HH.
;   20140314        : Add NBINS=NBINS, T.LI @ SWJTU
;
Function Mode, array, bigfreq=bigfreq, nbins=nbins
  IF NOT KEYWORD_SET(nbins) THEN nbins=20
  h = Histogram(array, MIN=Min(array), NBINS=NBINS, locations=locations)
  bigfreq = Max(h)
  m=locations[WHERE(h EQ bigfreq)]
;  m = Where(h EQ bigfreq) + Min(array)
  
  Return, m
End