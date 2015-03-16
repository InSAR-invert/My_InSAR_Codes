;+ 
; Name:
;    TLI_refineoffs
; Purpose:
;    Refine data generated from fine_coreg_cc
; Calling Sequence:
;    TLI_REFINEOFFS, master, slave, MNS, MNL, SNS, SNL, foff_file, osfactor,corrwinl,corrwinp,master_ovs_az,master_ovs_rg,$
;                    threshold=threshold, degree=degree, max_iterations= max_iterations,$
;                    weighting=weighting,crit_value= crit_value,$
;                    refine_data= refine_data, coef=coef
; Inputs:
;    master         : Master file(Full Path).
;    slave          : Slave file(full path)
;    MNS            : Master samples.
;    MNL            : Master lines.
;    SNS            : Slave samples.
;    SNL            : Slave lines.
;    foff_file      : Fine coreg off file.
;    osfactor       : Oversample factor in fine coreg.
;    corrwinl       : Correlation window in azimuth direction in fine coreg.
;    corrwinp       : Correlation window in range direction in fine coreg.
;    master_ovs_az  : Master oversample factor in azi direction.
;    master_ovs_rg  : Master oversample factor in range direction.
; Keyword Input Parameters:
;    threshold      : Threshold of coherence.
;    degree         : Degree of polynomial.
;    max_iterations : Iterations.
;    weighting      : Way to weight.[0,1,2,3]
;    crit_value     : Overall err.
;    refine_data    : Return value.
;    coef           : Return value.
; Outputs:
;    refine_data    : Refined data.
;    coef           : Polynomial coefficients.
; Commendations:
;    threshold      : 0.2 for window 64*64, 0.4 for 32*32
;    degree         : 2
;    max_iterations : 1000
;    weighting      : 1
;    crit_value     : 10
; Example: 
;  master= 'D:\ISEIS\Data\Img\ASAR-20070726.slc'
;  slave= 'D:\ISEIS\Data\Img\ASAR-20060601.slc'
;  MNS= 5195D;��Ӱ������
;  MNL= 27313D;��Ӱ������
;  SNS= 5195D;��Ӱ��������
;  SNL= 27301D;��Ӱ��������
;  threshold= 0.1;���ϵ����ֵ
;  degree= 1;degree
;  max_iterations=nlines-TLI_NCOEFFS(2);max_iterations
;  osfactor= 32D; ���������ӡ���������������������Ӧ�ôӾ���׼�л�ȡ��
;  corrwinl= 64D; ����ش���
;  corrwinp= 64D; ����ش���
;    weighting= 3;��Ȩ������
;  master_ovs_az=1;��Ӱ��λ�����������
;  master_ovs_rg=1;��Ӱ��б�������������
;  crit_value=10; ������ֵֹ
;  foff_file=FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'  
;  TLI_REFINEOFFS, master, slave, MNS, MNL, SNS, SNL, foff_file, osfactor,corrwinl,corrwinp,master_ovs_az,master_ovs_rg,$
;                    threshold=threshold, degree=degree, max_iterations= max_iterations,$
;                    weighting=weighting,crit_value= crit_value,$
;                    refine_data= refine_data, coef=coef
; Modification History:
;    05/09/2012        :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;-  

FUNCTION TLI_NCOEFFS, degree
  ; ����Degree�׶���ʽ��Ҫ����ϵ��
  result= (degree+1)*(degree+2)/2
  RETURN, result
END

Function TLI_SCL, arr, minv, maxv
  ; �������������쵽[minv, maxv]֮��
  arr_n= DOUBLE(arr)
  minv= Double(minv)
  maxv= DOUBLE(maxv)
  arr_n=(arr_n-MIN(arr_n))/(MAX(arr_n)-MIN(arr_n))*(maxv-minv)+minv
  Return, arr_n
END

Function TLI_InvertChol, arr
  ; �����
  sz= SIZE(arr,/DIMENSIONS)
  N= sz[1]
  FOR i=0, N-1 DO BEGIN
    arr[i,i]=1/arr(i,i)
    FOR j=i+1, N-1 DO BEGIN
      sum=0
      FOR k=i, j DO BEGIN
        sum = sum- arr[k,j]*arr[i,k]
      ENDFOR
      arr[i,j]= sum/arr[j,j]
    ENDFOR
  ENDFOR
  FOR i=0, N-1 DO BEGIN
    FOR j=i, N-1 DO BEGIN
      sum=0
      FOR k=j,N-1 DO BEGIN
        sum= sum+arr[i,k]*arr[j,k]
      ENDFOR
      arr[i,j]=sum    
    ENDFOR  
  ENDFOR
  Return, arr
END
Function TLI_RMLINE, arr, line
; ȥ��ĳһ��
; line:��0��ʼ
  arr_c= arr
  sz= SIZE(arr_c,/DIMENSIONS)
  IF sz[1] LT line Then Message, 'Can not remove line'+STRCOMPRESS(line)+'from arr of line'+StrCompress(sz[1])
  IF sz[1] EQ 1 THEN Message, 'Arr seems to have only 1 line.'
  IF line EQ 0 THEN BEGIN
    arr_c= arr_c[*, 1:*]
    Return, arr_c
  ENDIF
  IF line EQ sz[1]-1 THEN BEGIN
    arr_c= arr_c[*, 0:(sz[1]-2)]
    Return, arr_c
  ENDIF
  arr_c= [[arr_c[*, 0:(line-1)]],[arr_c[*, (line+1):*]]]
  
  Return, arr_c
END

PRO TLI_REFINEOFFS, master, slave, MNS, MNL, SNS, SNL, foff_file, osfactor,corrwinl,corrwinp,master_ovs_az,master_ovs_rg,$
                    threshold=threshold, degree=degree, max_iterations= max_iterations,$
                    weighting=weighting,crit_value= crit_value,$
                    refine_data= refine_data, coef=coef,no_offfile=no_offfile
  COMPILE_OPT idl2
;-------------------------��ʼ�����������ݵ�------------------------------------
  IF N_Params() NE 12 THEN Message,'Error! TLI_REFINEOFFS: Input params must be 7.'
  
  
  IF ~KEYWORD_SET(threshold) THEN threshold= 0.2
  IF ~KEYWORD_SET(degree) THEN degree=2
  IF ~KEYWORD_SET(weighting) THEN weighting=1
  IF ~KEYWORD_SET(crit_value) THEN crit_value=10
  
  IF ~KEYWORD_SET(no_offfile) THEN BEGIN
    finfo= FILE_INFO(foff_file)
    nlines= finfo.size/40D
    IF ~KEYWORD_SET(max_iterations) THEN max_iterations=nlines-TLI_NCOEFFS(degree)
    foffs= DBLARR(5, nlines);����׼ÿ�����ƫ����
    OPENR, lun, foff_file,/GET_LUN
    READU, lun, foffs
    FREE_LUN, lun
    
  ENDIF ELSE BEGIN
    foffs= foff_file
    IF ~KEYWORD_SET(max_iterations) THEN max_iterations=(((SIZE(foffs,/DIMENSIONS))[1])/2D)
  ENDELSE
  
  nunk=Tli_NCoeffs(degree)

  corrwinl= (corrwinl-8)>10
  corrwinp= (corrwinp-8)>10
  accuracy= 0.5D/osfactor

  winL=0;�޳��ĵ�������
  winp=0;�޳��ĵ�������
  
  IF degree GE 3 THEN Message, 'Degree of more than 3 is not supported!'
;-------------------------��ʼ�����������ݵ�------------------------------------  
  
;-----------------------------���ݾ���------------------------------------  
  ;�Զ��ֲ�̽�⣬��ﵽ0.1�������ϵľ��ȡ���λ���б�������ò�ͬȨ�ء�
  sigmal= 0.15
  sigmap= 0.10;range�򾫶��Ը�
  ind= (SORT(foffs[4,*]))
  foffs= foffs[*,ind]  ; ��foffs�������򡣰����ϵ����������
  ind= WHERE( foffs[4,*] GE threshold)
  IF N_Elements(ind) LT nunk THEN Message, 'Coherence of input points are too low to estimate params!'
  data=[Transpose(DINDGEN(N_elements(ind))),foffs[*,ind]];��Ӹ����
  ;�����Լ��飬alpha=0.001, gamma=0.80
  done=0
  iteration=1
  Print, 'Start Iteration'
  While done NE 1 DO BEGIN
  Print,'iteration/All iterations:       ',StrCompress(iteration),'/',StrCompress(max_iterations)
    IF winL GT 0 THEN data= TLI_RMLINE(data, winL);ȥ���в����ĵ�
;    IF iteration NE 0 THEN BEGIN ;ȥ������ֵ
;      sz= SIZE(data,/DIMENSIONS)
;      data= data[*, 0: sz[1]-2]
;      data[0,*]= DINDGEN(sz[1]);�������
;    ENDIF
    sz= SIZE(data,/DIMENSIONS)
    nobs= sz[1]
    IF sz[1] LE nunk Then Message, 'Tli_Refineoffs: Number of points are too low to estimate params.'
    
    ; �ⷽ�̡�Ϊ������ָ߽����ʱ�������Ƚ��������쵽[-2,2]֮��
    posp= TLI_SCL(data[1,*],-2,2)   ; ��Ӱ��������
    posl= TLI_SCL(data[2,*],-2,2)   ; ��Ӱ��������
    yp= (data[3,*]-data[1,*])         ; ������ƫ��
    yl= (data[4,*]-data[2,*])         ; ������ƫ��
    a0= Transpose(1+DBLARR(sz[1]))  ; 1
    a1= posl                        ; y1
    a2= posp                        ; x1
    a3= a1^2                        ; y2
    a4= a1*a2                       ; yx
    a5= a2^2                        ; x2
    ;���̹���������a0+a1y1+2x1+a3y2+a4yx+a5x2
    Case degree OF
      0 : BEGIN
        A= a0
      END
      1 : BEGIN
        A= [a0, a1, a2]
      END
      2 :  BEGIN
        A= [a0, a1, a2, a3, a4, a5]
      END
      ELSE : Message, 'Tli_RefineOffs: Degree not supported!'
    ENDCASE
    ; ���̼�Ȩ������0����Ȩ��1��sqrt(coherence)��2��coherence��3��Bamler04����
    Case Weighting Of
      0 : BEGIN
        qy1= Transpose(DBLARR(sz[1])+1);
      END
      1 : BEGIN
        qy1= data[5, *]
;        qy1= qy1/MEAN(qy1)
      END
      2 : BEGIN
        qy1= data[5, *]^2
;        qy1= qy1/MEAN(qy1)
      END
      3 : BEGIN
        ; ����Coherent cross-correlation��˵��ƫ�����ľ���
        ; sigma_cc= SQRT(3/(2N))*SQRT(1-coh^2)/(pi*coh)
        ; ���ڴ˴����õ�Incoherent cross-correlation�����������ӽ�sigma��
        ; sigma_ic= SQRT��2/coh��*sigma_cc.
        N_corr= corrwinl*corrwinp/(master_ovs_az*master_ovs_rg)
        coh= data[5,*];��correlation����ƫ����
        sigma_cc= SQRT(3D/(2* N_corr)*SQRT(1-coh^2))/(!PI * coh)
        sigma_ic= SQRT(2D /coh)*sigma_cc
        qy1= 1/(sigma_ic^2)
        sigmal=1D
        sigmap=1D
      END
      ELSE: Message, 'Tli_RefineOffs: Weighting method not supported!'
    ENDCASE
    ; ��������
    N=   TRANSPOSE(A)## (A*REBIN(qy1, SIZE(A,/DIMENSIONS)))
    rhsl= Transpose(A)## (yl*qy1)
    rhsp= Transpose(A)## (yp*qy1)
    QxHat=N
    ;�ⷽ��
    LA_CHOLDC, QxHat
    For i=0, (SIZE(QxHat,/DIMENSIONS))[1]-2 DO QxHat[i+1:*,i]=0;����Ҫ���°벿��
    rhsl= LA_CHOLSOL(QxHat, rhsl)
    rhsp= LA_CHOLSOL(QxHat, rhsp)
    ;�����
    err= N##Invert(Transpose(QxHat))## Invert(QxHat)- Diag_matrix(DBLARR((SIZE(QxHat,/DIMENSIONS))[1])+1)
    maxdev= MAX(err)
    IF maxdev GT .01 THEN BEGIN
      Message, 'TLI_RefineOffs: Maximum Deviation N*Invert(N) is larger than 0.01:'+STRCOMPRESS(maxdev)
    ENDIF ELSE BEGIN
      IF maxdev GT 0.001 THEN BEGIN
        Print, 'TLI_RefineOffs: Maximum Deviation N*Invert(N) is larger than 0.001:', STRCOMPRESS(maxdev)
      ENDIF
    ENDELSE
    QxHat= Invert(QxHat)
    sz= SIZE(QxHat,/DIMENSIONS)
    FOR i=0, sz[1]-1 DO BEGIN
      FOR j=0, i-1 DO BEGIN
        QxHat[i,j]= QxHat[j,i];�޸�����
      ENDFOR
    ENDFOR
    ;������һ������
    QyHat= A##(QxHat##Transpose(A))
    ylHat= A##rhsL
    ypHat= A##rhsp
    elHat= yl- ylHat
    epHat= yp- ypHat
    QeHat= -QyHat
    overallmodeltestl= TOTAL(elHat^2*Qy1)/(sigmal^2)/(Nobs-Nunk)
    overallmodeltestp= TOTAL(epHat^2*Qy1)/(sigmap^2)/(Nobs-Nunk)
    ;�����Լ���
    wtestL= elHat/(Diag_matrix(QeHat)* sigmal)
    wtestp= ephat/(Diag_matrix(QeHat)* sigmap)
    maxwl= MAX(ABS(wtestl),winl);W test��λ�����ֵ
    maxwp= MAX(ABS(wtestp),winp);W testб�������ֵ
    Wtestsum= wtestl^2+wtestp^2
    maxwsum= max(wtestsum,winl)
    
    IF nobs LE nunk THEN BEGIN
      Print, 'No redundancy! Iterations Done!'
      Done=1
    ENDIF
    IF MAX([maxwl, maxwp]) LE crit_value THEN BEGIN
      Print, 'Kicked all outliers! Iterations Done!'
      Done=1
    ENDIF
    IF iteration GE max_iterations THEN BEGIN
      Print, 'Reached Max iterations! Iterations Done!'
      Done=1
    ENDIF
    
    IF Done EQ 1 THEN BEGIN
      IF (overallmodeltestl GT 10) OR (overallmodeltestp GT 10) THEN BEGIN
        Print, 'Warning: TLI_RefineOffs, the model accuracy shoule be less than 10'
      ENDIF
      IF MAX([maxwl, maxwp]) GT 200 THEN BEGIN
        Print, 'Warning: Outlier is not kicked out clearly, please remove the data:'+ StrCompress(data[1,winl])+ StrCompress(data[2,winl])
      ENDIF
    ENDIF
    
;    Print, 'Overall model test(<10): ', overallmodeltestl,overallmodeltestp
;    Print, 'maxw(<200):', maxwl, maxwp
;    IF overallmodeltestl LT 80 THEN BEGIN
;      PRINT, SIZE(data,/DIMENSIONS), data[*, winl]
;    ENDIF    
    iteration= iteration+1    
  ENDWHILE
;-----------------------------���ݾ���------------------------------------
;-----------------------------����ʽ���------------------------------------
  nobs= (SIZE(data,/DIMENSIONS))[1]
  ;����ϵ����
  sminl=0D
  smaxl=Double(SNL)
  sminp=0D
  smaxp=Double(SNS)
;  posl= TLI_SCL(data[4,*], sminl, smaxl)
;  posp= TLI_SCL(data[3,*], sminp, smaxp)
  posl= data[4,*]
  posp= data[3,*]
  yl= (data[4,*]-data[2,*])
  yp= (data[3,*]-data[1,*])
  sz= SIZE(data,/DIMENSIONS)
  a0= Transpose(1+DBLARR(sz[1]))  ; 1
  a1= posl                        ; y1
  a2= posp                        ; x1
  a3= a1^2                        ; y2
  a4= a1*a2                       ; yx
  a5= a2^2                        ; x2
  Case degree OF
      0 : BEGIN
        A= a0
      END
      1 : BEGIN
        A= [a0, a1, a2]
      END
      2 :  BEGIN
        A= [a0, a1, a2, a3, a4, a5]
      END
      ELSE : Message, 'Tli_RefineOffs: Degree not supported!'
  ENDCASE
  Case Weighting Of
      0 : BEGIN
        qy1= Transpose(DBLARR(sz[1])+1);
      END
      1 : BEGIN
        qy1= data[5, *]
;        qy1= qy1/MEAN(qy1)
      END
      2 : BEGIN
        qy1= data[5, *]^2
;        qy1= qy1/MEAN(qy1)
      END
      3 : BEGIN
        ; ����Coherent cross-correlation��˵��ƫ�����ľ���
        ; sigma_cc= SQRT(3/(2N))*SQRT(1-coh^2)/(pi*coh)
        ; ���ڴ˴����õ�Incoherent cross-correlation�����������ӽ�sigma��
        ; sigma_ic= SQRT��2/coh��*sigma_cc.
        N_corr= corrwinl*corrwinp/(master_ovs_az*master_ovs_rg)
        coh= data[5,*];��correlation����ƫ����
        sigma_cc= SQRT(3D/(2* N_corr)*SQRT(1-coh^2))/(!PI * coh)
        sigma_ic= SQRT(2D /coh)*sigma_cc
        qy1= 1/(sigma_ic^2)
        sigmal=1D
        sigmap=1D
      END
      ELSE: Message, 'Tli_RefineOffs: Weighting method not supported!'
  ENDCASE
  N=   TRANSPOSE(A)## (A*REBIN(qy1, SIZE(A,/DIMENSIONS)))
  srhsl= Transpose(A)## (yl*qy1)
  srhsp= Transpose(A)## (yp*qy1)
  QxHat=N
  LA_CHOLDC, QxHat
  For i=0, (SIZE(QxHat,/DIMENSIONS))[1]-2 DO QxHat[i+1:*,i]=0;����Ҫ���°벿��
  srhsl= LA_CHOLSOL(QxHat, srhsl)
  srhsp= LA_CHOLSOL(QxHat, srhsp)
  ;��ƫ����ӳ�����ת��Ϊ��׼��ʽ
  Case degree OF
    0: BEGIN
      coef= [[srhsp,0,0,0,0,0],[srhsl,0,0,0,0,0]]
    END
    1: BEGIN
      coef= [[srhsp[0],srhsp[2],srhsp[1],0,0,0], $
             [srhsl[0],srhsl[2],srhsl[1],0,0,0]]
    END
    2: BEGIN
      coef= [[srhsp[0],srhsp[2],srhsp[1],srhsp[4],srhsp[5],srhsp[3]], $
             [srhsl[0],srhsl[2],srhsl[1],srhsl[4],srhsl[5],srhsl[3]]]
    END
    ELSE:
  ENDCASE
  m_coor=COMPLEX([0,MNS-1,0,MNS-1],[0,0,MNL-1,MNL-1])
  s_coor= COORMTOS(coef,m_coor,/offs )
  refine_data= data
END