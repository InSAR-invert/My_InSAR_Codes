;-
;- Purpose:
;-     Do empirical mode decomposition
;-

FUNCTION EXTREMA, $
  Data, $
  FLAT=flatopt, ENDS=endsopt, $
  MAXIMA=maxima, MINIMA=minima

;***********************************************************************
; ���峣���Ͳ���

; ȡʱ�����еĳ���
nx = n_elements( data )

; �ж��Ƿ���Ҫ����������ʾ������
if VAR_TYPE( nx ) eq 2 then begin
  idtype = 1
endif else begin
  idtype = 1l
endelse

; Ĭ�Ϸ�ʽ��Ӷ˵㣬��ԭ���еĶ˵����ӣ�û��������������
x = [ data[0*idtype], data, data[nx-1] ]

; ���ò�������
flatopt = keyword_set( flatopt )
endsopt = keyword_set( endsopt )

; ��ʼ����ż���ֵ�ͼ�Сֵ��λ�õ���������ֵΪ�㣬���������н�������
; 
maxima = [ 0 ]
minima = [ 0 ]

;***********************************************************************
; ̽�⼫ֵ���λ��

; �����зǶ˵�ĵ�λ���б���
for i = idtype, nx do begin

  ; �ҳ���ߵ��ٽ����ֵ���ߵ����������߽�
  idleft = max( where( x[0*idtype:i-1] ne x[i] ) )
  ; ���û�����ڽ�������
  if idleft eq -1 then idleft = 0
  ; �ҳ��бߵ��ٽ����ֵ���ߵ���������ұ߽�
  idright = i + 1 + min( where( x[i+1:nx+1] ne x[i] ) )
  ; ���û�����ڽ�������
  if idright eq i then idright = nx + 1

  ; �ж��Ƿ��¼һ����ֵ��
  check = 1
  if not( flatopt ) then begin
    if i ne ( idleft + idright ) / 2 then check = 0
  endif
  ; 
  if check then begin
    ; ��鼫Сֵ��
    if ( x[i] le x[idleft] ) and ( x[i] le x[idright] ) then begin
      minima = [ minima, i - 1 ]
    endif else begin
      ; ����޼�Сֵ��ĵ�������
      if flatopt and ( x[i] eq x[i-1] ) and ( x[i] eq x[i+1] ) then begin
        minima = [ minima, i - 1 ]
      endif
    endelse
    ; ��鼫��ֵ��
    if ( x[i] ge x[idleft] ) and ( x[i] ge x[idright] ) then begin
      maxima = [ maxima, i - 1 ]
    endif else begin
      ; ����޼���ֵ��ĵ�������
      if flatopt and ( x[i] eq x[i-1] ) and ( x[i] eq x[i+1] ) then begin
        maxima = [ maxima, i - 1 ]
      endif
    endelse
  endif

endfor

; ��������Сֵ�����������������ʼֵ��
nmaxima = n_elements( maxima ) - 1
nminima = n_elements( minima ) - 1

; �Ӽ���ֵ��Сֵ�������Ƴ���ʼֵ
maxima = maxima[1*idtype:nmaxima]
minima = minima[1*idtype:nminima]

; ����Ƿ��¼�Ǽ�ֵ�˵�
if not( endsopt ) then begin
  ; ����һ���Ƿ�Сֵ
  if ( minima[0*idtype] eq 0 ) and ( nminima gt 1 ) then begin
    ; �ҳ��ٽ��Ĳ�ͬ��Сֵ
    id = min( where( data[minima] ne data[0*idtype] ) )
    ; ���һ���Ա�
    if data[minima[0*idtype]] gt data[minima[id]] then begin
      ; �Ƴ���ʼ��Сֵ
      id = min( where( data[minima] ne data[0*idtype] ) )
      minima = minima[id:nminima-1]
      nminima = n_elements( minima )
    endif
  endif
  ; ����һ���Ƿ񼫴�ֵ��
  if ( maxima[0*idtype] eq 0 ) and ( nmaxima gt 1 ) then begin
    ; �ҳ��ٽ��Ĳ�ͬ����ֵ
    id = min( where( data[maxima] ne data[0*idtype] ) )
    ; ���һ��Ա�
    if data[maxima[0*idtype]] lt data[maxima[id]] then begin
      ; �Ƴ���ʼ����ֵ
      id = min( where( data[maxima] ne data[0*idtype] ) )
      maxima = maxima[id:nmaxima-1]
      nmaxima = n_elements( maxima )
    endif
  endif
  ; ������һ���Ƿ�Сֵ��
  if ( minima[nminima-1] eq nx - 1 ) and ( nminima gt 1 ) then begin
    ; �ҳ��ٽ��Ĳ�ͬ��Сֵ
    id = max( where( data[minima] ne data[nx-1] ) )
    ; �����һ��Ա�
    if data[minima[nminima-1]] gt data[minima[id]] then begin
      ; �Ƴ���ʼ��Сֵ
      id = max( where( data[minima] ne data[nx-1] ) )
      minima = minima[0*idtype:id]
      nminima = n_elements( minima )
    endif
  endif
  ; ������һ���Ƿ񼫴�ֵ��
  if ( maxima[nmaxima-1] eq nx - 1 ) and ( nmaxima gt 1 ) then begin
    ; �ҳ��ٽ��Ĳ�ͬ����ֵ
    id = max( where( data[maxima] ne data[nx-1] ) )
    ; �����һ��Ա�
    if data[maxima[nmaxima-1]] lt data[maxima[id]] then begin
      ; �Ƴ���ʼ����ֵ
      id = max( where( data[maxima] ne data[nx-1] ) )
      maxima = maxima[0*idtype:id]
      nmaxima = n_elements( maxima )
    endif
  endif
endif

; ���弫ֵ���������
extrema = [ minima, maxima ]
; �Ƴ��ظ�ֵ(����������ܳ���)
check = 0
ctr = 0 * idtype
nextrema = n_elements( extrema )
while check eq 0 do begin
  id = where( extrema ne extrema[ctr], nid )
  if nid ne nextrema - 1 then begin
    extrema = extrema[[ctr,id]]
    nextrema = nid + 1
  endif
  ctr = ctr + 1
  if ctr ge nextrema - 1 then check = 1
endwhile
; Ϊ��ֵ��λ������Sort extrema locations
id = sort( extrema )
extrema = extrema[id]

;***********************************************************************
; ���ؽ��

return, extrema
END

FUNCTION TLI_EMD, $
  Data, $
  SHIFTFACTOR=shiftfactor, $
  QUEK=quekopt, SPLINEMEAN=splinemeanopt, ZEROCROSS=zerocrossopt, $
  VERBOSE=verboseopt, $
  FIX_H=fixno

;***********************************************************************
; ���峣���Ͳ��������û�����ò������������Ĭ��ֵ

; �����жϱ�׼��ϵ����������ʣ�����ı�׼��С��epsilon��ԭʼ���ݱ�׼��ĳ˻�����ʣ�����Ϊ������
epsilon = 0.00001

; ����ɸѭ���Ĵ�����ȷ����ȡ���Ϊ�ȶ���IMF
ncheckimf = 3

;�������IFM����
no=0.0
; �������Ƽ���IMFʱ��������ɸ����֮�����̬��׼�ֻ�е�ZEROCROSSû�����õ�ʱ��ʹ��
if not( keyword_set( shiftfactor ) ) then shiftfactor = 0.3

; ��ʼ�������ֹ������������Check = 0����δ�õ��κν��
check = 0
; Check = 1 �����ѵõ�һ��IMF
checkimfval = 1
; Check = 2 ����õ�������
checkresval = 2
; Check = 3 �����˳�����.
checkexitval = 3

; ������ݳ���
ndata = n_elements( data )

; ��ȡ���ݳ��ȵ�λ����ȷ���Ƿ���Ҫ���������ֽ���������������������������е�λ�ã�
if VAR_TYPE( ndata ) eq 2 then begin
  idtype = 1
endif else begin
  idtype = 1l
endelse

; ��ȡ�����Ĳ���
quekopt = keyword_set( quekopt )
splinemeanopt = keyword_set( splinemeanopt )
zerocrossopt = keyword_set( zerocrossopt )

; ��ȡ�ж��Ƿ���ʾ�м����ʹ��󡢾�����Ϣ�Ĳ���
verboseopt = keyword_set( verboseopt )

; ��ʼ�����ֽ���������������ݸ�ֵ�����ֽ�����������ں�����ɸ����
x = data

;***********************************************************************
; ����������ݷֽ�Ϊ�������IMFs

; ��ѭ����ɸ���̣���ֱ�����ź�ȫ���ֽ��Ϊֹ
while check lt checkexitval do begin

  ; ����Ƿ��ѻ�ȡ���е�IMFs�������Ƿ��ѵõ�������
  ; �ҳ��ֲ���ֵ�㼰��λ��
  nextrema = n_elements( EXTREMA( x ) )
  ; �жϼ�ֵ������Ƿ�С�ڵ���2���������õ�����������
  if nextrema le 2 then check = checkresval
  ; ��˲������Ƿ�ﵽ����Ҫ��Ĵ�С
  if stddev( x ) lt epsilon * stddev( data ) then check = checkresval

  ; ��¼ԭʼ�ź�
  x0 = x

  ; ��ʼ���ж��Ƿ�����ȡ�ȶ�IMF�ı���
  checkimf = 0
  checkres = 0

  ; δ����IMF����ʱһֱѭ��
  ; ��Щ������Ӧ����ֵ�������˱�������¼
  while check eq 0 do begin

    ; �ҳ��γ����°����ߵľֲ���ֵ��λ�ã��ֱ����minima��maxima
    ;temp = extrema( x, minima=minima, maxima=maxima, /flat )
    temp = EXTREMA( x, minima=minima, maxima=maxima )
    nminima = n_elements( minima )
    nmaxima = n_elements( maxima )

    ; δ�õ��Ϻõİ������ߣ��ڼ�ֵ�������˵���ӳ�����������˵�ЧӦ�����ж�ԭ���Ķ˵��Ƿ�ֵ�㣬�ڶ˵㴦�õ�������   
    period0 = 2 * abs( maxima[0] - minima[0] )
    
    period1 = 2 * abs( maxima[nmaxima-1] - minima[nminima-1] )

    ; Ϊ��ֵ����������µĶ˵㣨ԭ���Ķ˵㲻һ���Ǽ�ֵ�㣩
    maxpos = [ maxima[0]-2*period0, maxima[0]-period0, maxima, $
        maxima[nmaxima-1]+period1, maxima[nmaxima-1]+2*period1 ]
    maxval = [ x[maxima[0]], x[maxima[0]], x[maxima], x[maxima[nmaxima-1]], $
        x[maxima[nmaxima-1]] ]
    minpos = [ minima[0]-2*period0, minima[0]-period0, minima, $
        minima[nminima-1]+period1, minima[nminima-1]+2*period1 ]
    minval = [ x[minima[0]], x[minima[0]], x[minima], x[minima[nminima-1]], $
        x[minima[nminima-1]] ]

    ; ���ƾֲ���ֵ
    ; �ж��Ƿ����ü�ֵ���ֵ�������
    if splinemeanopt then begin

      ; ��ʼ�������ֲ���ֵ��λ�ú�ֵ
      meanpos = [ 0 ]
      meanval = [ 0 ]
      ; �����һ����ֵ���Ǽ�Сֵ���������´���
      if minpos[0] lt maxpos[0] then begin
        meanpos = [ meanpos, ( minpos[0] + maxpos[0] ) / 2 ]
        meanval = [ meanval, ( minval[0] + maxval[0] ) / 2. ]
      endif
      ; �����м�ֵ����ѭ��������������ڵļ���ֵ�뼫Сֵ���ƽ��ֵ
      for i = 0 * idtype, nmaxima + 4 - 1 do begin
        ; ���Ҵ˼���ֵ��һ����Сֵ��λ��
        id1 = min( where( minpos gt maxpos[i] ), nid )
        ; �ж����������ļ�ֵ���Ƿ����
        if nid ne 0 then begin
          ; ��Ӿ�ֵ��λ�ú�ֵ
          meanpos = [ meanpos, ( maxpos[i] + minpos[id1] ) / 2 ]
          meanval = [ meanval, ( maxval[i] + minval[id1] ) / 2. ]
          ; ���Ҵ˼�Сֵ��һ������ֵ��λ��
          id2 = min( where( maxpos gt minpos[id1] ), nid )
          ; �ж����������ļ�ֵ���Ƿ����
          if nid ne 0 then begin
            ; ��Ӿ�ֵ��λ�ú�ֵ
            meanpos = [ meanpos, ( maxpos[id2] + minpos[id1] ) / 2 ]
            meanval = [ meanval, ( maxval[id2] + minval[id1] ) / 2. ]
          endif
        endif
      endfor
      ; ��ȡ����ֵ������
      nmean = n_elements( meanpos ) - 1
      ; Ϊ��ֵ��λ�������������Ƴ���ʼֵ
      id = sort( meanpos[1:nmean] )
      meanpos = meanpos[1+id]
      meanval = meanval[1+id]
      ; ����������ֵ���ƾֲ���ֵ
      localmean = spline( meanpos, meanval, indgen( ndata ) )

    ; ��������ü�ֵ�õ���ֵ����������뷽��
    endif else begin

      ; �Լ��󡢼�Сֵ��ֱ�ͨ��������ֵ�õ����°�����
      maxenv = spline( maxpos, maxval, indgen( ndata ) )
      minenv = spline( minpos, minval, indgen( ndata ) )
      ; ����ƽ��������
      localmean = ( minenv + maxenv ) / 2.

    endelse

    ; �ӵ�ǰ���ݼ�ȥ�ֲ���ֵ
    xold = x
    x = x - localmean

    ; ���IMF�ж�׼���Ǽ�ֵ������������ı�ֵ
    if zerocrossopt then begin
      ; ������������
      nzeroes = ZERO_CROSS( x )
      ; ���㼫ֵ������
      nextrema = n_elements( EXTREMA( x ) )
      ; �������������Ƿ��뼫ֵ��������Ȼ���������1
      if nextrema - nzeroes le 1 then begin
        ; ���������Ļ��ѵõ�������Ϊ��ѡIMF
        checkimf = checkimf + 1
      endif else begin
        ; ��������������ΪIMF
        checkimf = 0
      endelse
    endif

    ; ���IMF�ж�����Ϊ����������ֵ������ý��֮��Ĵ�С
    if not( zerocrossopt ) then begin
      ; ������һ��׼����Ϊɸ���̵���ֹ���� 

      ; ���ô�ͳ���������׼��
      if not( quekopt ) then begin
        sd = total( ( ( xold - x )^2 ) / ( xold^2 + epsilon ) )
      ; ���øĽ��ķ��������׼��
      endif else begin
        sd = total( ( xold - x ) ^ 2 ) / total( xold^2 )
      endelse

      ; �Ƚϱ�׼�����ֵ���ж��Ƿ�õ�һ��IMF
      if sd lt shiftfactor then begin
        
        checkimf = checkimf + 1
      endif else begin
        
        checkimf = 0
      endelse

    endif

    ; �ж��Ƿ�õ����������Ĳ��������õ�������Ϊһ��IMF�����洢
    if stddev( x ) lt epsilon * stddev( data ) then checkres = checkres + 1

    ; �ж��Ƿ�õ�����������IMF
    if checkimf eq ncheckimf then check = checkimfval
    if checkres eq ncheckimf then check = checkimfval

  endwhile

  ; �洢�õ���IMF��imf������
  if VAR_TYPE( imf ) eq 0 then begin
    ; �ж��Ƿ�Ϊ��һ��IMF
    imf = x
  endif else begin
    ; ������ǵ�һ�������һ��
    imf = [ [imf], [x] ]
  endelse
  ; �ж��Ƿ��Ѿ��õ�������
  if check eq checkresval then begin
    check = checkexitval
  endif else begin
    check = 0
  endelse

  ; ��ԭʼ�ź��м�ȥ��һ��IMF
  x = x0 - x

endwhile

;***********************************************************************
; ���ؽ��

return, imf

END

;FUNCTION TLI_EMD,Bt, residuals, times=times
;  ; Find maxima
;  maxima=0
;  minima=0
;  maxima_ind=0
;  mimima_ind=0
;  residuals_cp = residuals
;  emd
;  WHILE NOT nofinish DO BEGIN
;    FOR i=0, N_ELEMENTS(residuals_cp)-1 DO BEGIN
;    
;      Case i OF
;        0: BEGIN        
;          IF residuals_cp[i] GE residuals_cp[i+1] THEN BEGIN
;            maxima_ind=[maxima, i]
;          ENDIF ELSE BEGIN
;            minima_ind=[minima, i]
;          ENDELSE          
;        END
;        
;        N_ELEMENTS(residuals_cp)-1: BEGIN        
;          IF residuals_cp[N_ELEMENTS(residuals_cp)-1] GT residuals_cp[N_ELEMENTS(residuals_cp)-2] THEN BEGIN
;            maxima_ind=[maxima_ind, (N_ELEMENTS(residuals_cp)-1)]
;          ENDIF ELSE BEGIN
;            minima_ind=[minima_ind, (N_ELEMENTS(residuals_cp)-1)]
;          ENDELSE          
;        END
;        
;        ELSE: BEGIN        
;          IF residuals_cp[i] GT residuals_cp[i-1] AND residuals_cp[i] GE residuals_cp[i+1] THEN BEGIN
;            maxima_ind=[maxima_ind, i]
;          ENDIF ELSE BEGIN
;            minima_ind=[minima_ind, i]
;          ENDELSE
;        END
;      ENDCASE
;      
;    ENDFOR
;    
;    ; Check the result
;    IF maxima_ind LT 2 OR minima_ind LT 2 THEN BEGIN
;    
;      maxima= residuals_cp[maxima_ind]
;      minima= residuals_cp[minima_ind]
;      
;      
;      Print, 'Empirical mode decomposition done successfully.'
;      nofinish=-1
;      RETURN, 1
;    ENDIF ELSE BEGIN
;      ; Interp maxima at each time
;      maxima_interp= INTERPOL(maxima, BT[maxima_ind], BT)
;      ; Interp minima at each time
;      minima_interp= INTERPOL(minima, BT[minima_ind], BT)
;      ; Calculate ml
;      mean_interp= (maxima_interp+minima_interp)/2
;      ; New residuals for next loop
;      residuals_cp = residuals_cp- mean_interp
;    ENDELSE
;    
;  ENDWHILE
;  
;  RETURN,1
;END

PRO TLI_EMP_MODE_DEC

  ; Input params
  refind= 17170
  temp= ALOG(2)
  e= 2^(1/temp)
  c= 299792458D ; Speed light
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK'
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfilegamma= workpath+'/SLC_tab'
    sarlistfile= workpath+'/testforCUHK/sarlist_Linux'
    pdifffile= workpath+'/pdiff0'
    plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
    plistfile= workpath+'/testforCUHK/plist'
    itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
    arcsfile=workpath+'/testforCUHK/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile=workpath+'/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
    dvddhfile=workpath+'/testforCUHK/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/dvddh'
    vdhfile= workpath+'/testforCUHK/vdh'
    atmfile= workpath+'/testforCUHK/atm'
    nonfile= workpath+'/testforCUHK/nonlinear'
    noisefile= workpath+'/testforCUHK/noise'
    time_seriesfile= workpath+'/testforCUHK/time_series'
  ENDIF ELSE BEGIN
    sarlistfile= TLI_DIRW2L(sarlistfile,/reverse)
    pdifffile=TLI_DIRW2L(pdifffile,/reverse)
    plistfile=TLI_DIRW2L(plistfile,/reverse)
    itabfile=TLI_DIRW2L(itabfile,/reverse)
    arcsfile=TLI_DIRW2L(arcsfile,/reverse)
    pbasefile=TLI_DIRW2L(pbasefile,/reverse)
    dvddhfile=TLI_DIRW2L(dvddhfile,/REVERSE)
    vdhfile=TLI_DIRW2L(vdhfile,/REVERSE)
  ENDELSE
  
  ; Read sarlistfile
  nslc= FILE_LINES(sarlistfile)
  sarlist= STRARR(1,nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  ; Read plist
  plist= TLI_READDATA(plistfile, samples=1, format='FCOMPLEX')
  
  ; Load itabfile's info
  nintf= FILE_LINES(itabfile) ; Number of interferograms.
  ; Read itab
  itab= INTARR(4)
  Print, '* There are', STRCOMPRESS(nintf), ' interferograms. *'
  OPENR, lun, itabfile,/GET_LUN
  FOR i=0, nintf-1 DO BEGIN
    tmp=''
    READF, lun, tmp
    tmp= STRSPLIT(tmp, ' ',/EXTRACT)
    itab= [[itab], [tmp]]
  ENDFOR
  FREE_LUN, lun
  itab= itab[*, 1:*]
  master_index= itab[0, *]-1
  slave_index= itab[1, *]-1
  master_index= master_index[UNIQ(master_index)]
  IF N_ELEMENTS(master_index) EQ 1 THEN BEGIN
    Print, '* The master image index is:', STRCOMPRESS(master_index), $
      ' Its name is: ', FILE_BASENAME(sarlist[master_index-1]), ' *'
  ENDIF ELSE BEGIN
    Print, '* The master image indices are:', STRCOMPRESS(master_index), ' *'
  ENDELSE
  
  ; Load plistfile's info
  npt= TLI_PNUMBER(plistfile); Number of points.
  
  ; Check params
  IF refind EQ 0 OR refind EQ npt-1 THEN BEGIN
    MESSAGE, 'Error: We do not believe it is robust to set refind as: ', STRCOMPRESS(refind)
  ENDIF
  
  ; Load pdifffile
  pdiff= TLI_READDATA(pdifffile, samples=npt, format='FCOMPLEX',/SWAP_ENDIAN)
  
  ; Load pbasefile
  pbase= TLI_READDATA(pbasefile, samples=13,format='DOUBLE',/SWAP_ENDIAN)
  
  ; Load vdhfile
  vdh= TLI_READDATA(vdhfile,samples=5, format='DOUBLE')
  npt_arcs= (SIZE(vdh,/DIMENSIONS))[1]
  
  ; Different phase referred to the refind
  refphase= pdiff[refind, *]  ; Phase difference between points and refind.
  pdiff_refind= pdiff*CONGRID(CONJ(refphase), npt, nintf); pdiff - refind*********refrence point included.**********
  pdiff_refind= ATAN(pdiff_refind,/PHASE)                ; phase
  
  ; Calculate dvddh related phase
  radar_frequency= READ_PARAMS(sarlist[master_index[0]]+'.par', 'radar_frequency')
  R1= READ_PARAMS(sarlist[master_index[0]]+'.par', 'near_range_slc')
  rps= READ_PARAMS(sarlist[master_index[0]]+'.par', 'range_pixel_spacing')
  stec= READ_PARAMS(sarlist[master_index[0]]+'.par', 'sar_to_earth_center')
  erbs= READ_PARAMS(sarlist[master_index[0]]+'.par', 'earth_radius_below_sensor')
  wavelength = (c) / radar_frequency ;��Ϊ��λ
  
  ref_coor= plist[refind]
  ref_x= REAL_PART(ref_coor)
  ; Slant range of ref. p
  ref_r= R1+(ref_x)*rps
  ; Look angle of ref. p
  cosla= (stec^2+ref_r^2-erbs^2)/(2*stec*ref_r)
  sinla= SQRT(1-cosla^2)
  K1= -4*(!PI)/(wavelength*ref_r*sinla) ;GX Liu && Lei Zhang��ʹ���@�NӋ�㷽�� Please be reminded that K1 and K2 are both negative.
  K2= -4*(!PI)/(wavelength*1000) ;����Ϊ��λ---��Ӧ�α�
  
  Bt= TBASE_ALL(sarlistfile, itabfile)
  
  IF TOTAL(pbase[6:8, *]) EQ 0 THEN BEGIN
    Print, '* Warning: No precision baseline is available. *'
    Bperp= pbase[1, *]
  ENDIF ELSE BEGIN
    Bperp= pbase[7, *]
  ENDELSE
  
  refind_ind= WHERE(vdh[0, *] EQ refind)
  ref_v= (vdh[3, refind_ind])[0]
  ref_dh= (vdh[4, refind_ind])[0]
  
  ; Atmospheric phase
  atm_phase= DBLARR(npt, nintf+3) ; itab+3 means there is  x line,  y line,and a mask line.
  atm_phase[*, 0:1]= TRANSPOSE([REAL_PART(plist), IMAGINARY(plist)])
  non_phase= atm_phase
  time_series_phase= atm_phase
  noise_phase= atm_phase
  
  FOR i=0, npt_arcs-1 DO BEGIN
    IF ~(i MOD 100) THEN BEGIN
      Print,i, '/', STRCOMPRESS(npt_arcs-1)
    ENDIF
  
    pt_ind= vdh[0, i] ; Point index
    pt_phase= pdiff_refind[pt_ind, *]
    pt_dv= (vdh[3, i]-ref_v)[0]
    pt_ddh= (vdh[4, i]-ref_dh)[0]
    
    res= TRANSPOSE(pt_phase-(K1*Bperp*pt_ddh+K2*Bt*pt_dv))
    emd_res=TLI_EMD(res)
    ; We believe that the first component is APS, second nonlinear vel., others noise.
    IF N_ELEMENTS(SIZE(emd_res,/DIMENSIONS)) EQ 1 THEN BEGIN
      n_component=1
    ENDIF ELSE BEGIN
    n_component= (SIZE(emd_res,/DIMENSIONS))[1]
    ENDELSE
 
    CASE n_component OF
      0: BEGIN
        Print, 'There is no obvious residuals at this point: ', STRCOMPRESS(i)
      END
      1: BEGIN
        atm_phase[i, 2:*]= [1D, emd_res[*, 0]]
      END
      2: BEGIN
        atm_phase[i, 2:*]= [1D, emd_res[*, 0]]
        non_phase[i, 2:*]= [1D, emd_res[*, 1]]
      END
      3: BEGIN
        atm_phase[i, 2:*]= [1D, emd_res[*, 0]]
        non_phase[i, 2:*]= [1D, emd_res[*, 1]]
        noise_phase[i, 2:*]= [1D, emd_res[*, 2]]
      END
      ELSE: BEGIN
        atm_phase[i, 2:*]= [1D, emd_res[*, 0]]
        non_phase[i, 2:*]= [1D, emd_res[*, 1]]
        noise_phase[i, 2:*]= [1D, TOTAL(emd_res[*, 2:*], 2)]
      END
    ENDCASE
  ENDFOR
  
  v_all= DBLARR(npt)
  v_ind= TRANSPOSE(vdh[0, *])
  time_series_phase[*,3:*]= TRANSPOSE(BT) ## v_all + non_phase[*, 3:*]
  
  OPENW, lun, atmfile,/GET_LUN
  WRITEU, lun, atm_phase
  FREE_LUN, lun
  
  OPENW, lun, nonfile,/GET_LUN
  WRITEU, lun, non_phase
  FREE_LUN, lun
  
  OPENW, lun, noisefile,/GET_LUN
  WRITEU, lun, noise_phase
  FREE_LUN, lun
  
  OPENW, lun, time_seriesfile,/GET_LUN
  WRITEU, lun, time_series_phase
  FREE_LUN, lun
  
  Print, 'Files written successfully!'
  
END