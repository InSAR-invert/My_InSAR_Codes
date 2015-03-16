PRO TestMNFTransform,infile
;- ��С�����任
  ;HighPassFilter�����������ǽ��и�ͨ�˲�
  ;����ֵΪ imageinfo �ṹ��
  ;���������Ч���ε�����ֵ ����Ч��������Ӧ��ͼ��
  imageinfo=HighPassFilter(infile)
  
  samples=imageinfo.SAMPLES
  lines=imageinfo.LINES
  dataType=imageinfo.DATATYPE
  filteredImage = imageinfo.FILTEREDIMAGE
  filteredNoiseImage = imageinfo.FILTEREDNOISEIMAGE
  GoodBandsIndex = imageinfo.GOODBANDSINDEX
  
  ;ʹ��reform�����Чͼ��ı��Ϊ N_ELEMENTS(GoodBandsIndex) x��samples*lines����С�ľ���
  bandfilteredImage = REFORM(filteredImage,[samples*lines,N_ELEMENTS(GoodBandsIndex)])
  bandNoiseImage = REFORM(filteredNoiseImage,[samples*lines,N_ELEMENTS(GoodBandsIndex)])
  
  
  ;��ȡ�˲���ͼ���������Э�������
  covarFilteredImage=IMSL_COVARIANCES(bandfilteredImage,/double)
  covarNoiseImage=IMSL_COVARIANCES(bandNoiseImage,/double)
  
  ;-----------------------------
  ;MNF �㷨
  ;-----------------------------
  ;��һ��
  ;��ȡ�˲���ͼ�������ֵ����������
  FilteredEigval = IMSL_EIG(covarFilteredImage, Vectors = FilteredEigvec)
  HELP,FilteredEigval,/structure
  
  ;���򷵻� FilteredEigval���˲���ͼ��Э�����������ֵ��
  sortFilteredEigval = SORT(FilteredEigval)
  ;���� ������Ӧ������ֵ
  sortIndexFilteredEigval=REVERSE(sortFilteredEigval)
  ;�õ���������ֵ����������
  NewFilteredEigval=FilteredEigval[sortIndexFilteredEigval]
  
  newFilteredEigvec=MAKE_ARRAY(DIMENSION=SIZE(FilteredEigvec,/DIMENSION),/DCOMPLEX)
  ;�õ����������������о���
  FOR i=0,N_ELEMENTS(GoodBandsIndex)-1 DO BEGIN
    newFilteredEigvec[i,*] = FilteredEigvec[sortIndexFilteredEigval,*]
  ENDFOR
  P = (newFilteredEigvec # DIAG_MATRIX(NewFilteredEigval))^(-0.5)
  
  ;�ڶ���
  ;covarNoiseImage�ǰ�������Э�������
  ;��P����Э�������n2
  newcovarNoiseImage=TRANSPOSE(P) # covarNoiseImage # P
  
  ;��ȡ�˲�������Э������������ֵ����������
  NoiseEigval = IMSL_EIG(newcovarNoiseImage, Vectors = NoiseEigvec)
  HELP,NoiseEigvec,/structure
  
  ;���� ���� NoiseEigval������Э�����������ֵ��
  sortNoiseEigval = SORT(NoiseEigval)
  ;���� ������Ӧ������ֵ
  sortIndexNoiseEigval=REVERSE(sortNoiseEigval)
  ;�õ���������ֵ��������
  NewNoiseEigval = NoiseEigval[sortIndexNoiseEigval]
  
  newNoiseEigvec=MAKE_ARRAY(DIMENSION=SIZE(NoiseEigvec,/DIMENSION),/DCOMPLEX)
  ;�õ����������������о���
  FOR i=0,N_ELEMENTS(GoodBandsIndex)-1 DO BEGIN
    newNoiseEigvec[i,*] = NoiseEigvec[sortIndexNoiseEigval,*]
  ENDFOR
  A = newNoiseEigvec
  
  ;�ۺϵõ� MNF �任����
  T = P # A
  ;��ͼ�����MNF�任
  imageMNF=bandfilteredImage # T
  
  
  ; ���Ա任�Ƿ���ȷ
  tmp=REFORM(DOUBLE(imageMNF[*,0]),[samples,lines])
  HELP,tmp,/structure
  WINDOW,0,xsize=samples,ysize=lines
  TVSCL,tmp,/order
  
END