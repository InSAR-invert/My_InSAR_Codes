PRO TLI_SIM_TEST

  COMPILE_OPT idl2
  c= 299792458D ; Speed light
  
  workpath='/mnt/software/myfiles/Software/experiment/sim'
  
  resultpath=workpath+'/testforCUHK'
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfilegamma= workpath+'/SLC_tab'
    pdifffile= workpath+'/simph'
    plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
    plistfile= resultpath+PATH_SEP()+'plist'
    itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
    arcsfile=resultpath+PATH_SEP()+'arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile=resultpath+PATH_SEP()+'pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
    plafile=resultpath+PATH_SEP()+'pla'
    dvddhfile=resultpath+PATH_SEP()+'dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/dvddh'
    vdhfile= resultpath+PATH_SEP()+'vdh'
    ptattrfile= resultpath+PATH_SEP()+'ptattr'
    plistfile= resultpath+PATH_SEP()+'plist'                            ; PS���б�
    sarlistfile= resultpath+PATH_SEP()+'sarlist_Linux'                        ; �ļ��б�
    arcsfile= resultpath+PATH_SEP()+'arcs'                              ; ���绡���б�
    pslcfile= resultpath+PATH_SEP()+'pslc'                              ; ��λ�ϵ�SLC
    interflistfile= resultpath+PATH_SEP()+'Interf.list'                 ; �����б�
    pbasefile=resultpath+PATH_SEP()+'pbase'                             ; ��λ�����ļ�
    dvddhfile=resultpath+PATH_SEP()+'dvddh'                             ; ��������α������Լ���Ը߳����
    vdhfile= resultpath+PATH_SEP()+'vdh'                                ; ��λ�α������Լ��߳����
    ptattrfile= resultpath+PATH_SEP()+'ptattr'                          ; ��λ��Ϣ�ļ�(�����������������������Ϣ)
    plafile= resultpath+PATH_SEP()+'pla'                                ; ��λ���ӽ��ļ�
    arcs_resfile= resultpath+PATH_SEP()+'arcs_res'                      ; ���βв�
    res_phasefile= resultpath+PATH_SEP()+'res_phase'                    ; ��λ�в�
    time_series_linearfile= resultpath+PATH_SEP()+'time_series_linear'  ; �����α�
    res_phase_slfile= resultpath+PATH_SEP()+'res_phase_sl'              ; �ռ��˲����
    res_phase_tlfile= resultpath+PATH_SEP()+'res_phase_tl'              ; ʱ���˲����
    final_resultfile= resultpath+PATH_SEP()+'final_result'              ; �α�ʱ������
    nonlinearfile= resultpath+PATH_SEP()+'nonlinear'                    ; �������α�����
    atmfile= resultpath+PATH_SEP()+'atm'                                ; �����в�
    time_seriestxtfile= resultpath+PATH_SEP()+'Deformation_Time_Series_Per_SLC_Acquisition_Date.txt'
    dhtxtfile= resultpath+PATH_SEP()+'HeightError.txt'                  ; ���ղ�Ʒ���߳����
    vtxtfile= resultpath+PATH_SEP()+'Deformation_Average_Annual_Rate.txt' ; ���ղ�Ʒ����λ���α�����
    logfile= resultpath+PATH_SEP()+'log.txt'
    
  ENDIF ELSE BEGIN
    sarlistfile= TLI_DIRW2L(sarlistfile,/reverse)
    pdifffile=TLI_DIRW2L(pdifffile,/reverse)
    plistfile=TLI_DIRW2L(plistfile,/reverse)
    itabfile=TLI_DIRW2L(itabfile,/reverse)
    arcsfile=TLI_DIRW2L(arcsfile,/reverse)
    pbasefile=TLI_DIRW2L(pbasefile,/reverse)
    outfile=TLI_DIRW2L(outfile,/reverse)
  ENDELSE
  
  starttime= SYSTIME(/SECONDS)
  
  ; Load master slc header.
  nintf= FILE_LINES(itabfile)
  nslc= FILE_LINES(sarlistfile)
  finfo= TLI_LOAD_MPAR(sarlistfile, itabfile)
  
  IF 1 THEN BEGIN
    ;��GAMMA��SLC_tabת��Ϊ�ڲ���ʽ
    TLI_GAMMA2MYFORMAT_SARLIST, sarlistfilegamma, sarlistfile
    
    ;;��GAMMA��plistת��Ϊ�ڲ���ʽ
    TLI_GAMMA2MYFORMAT_PLIST, plistfilegamma, plistfile
    
    IF 1 THEN BEGIN
      rps=finfo.range_pixel_spacing
      aps=finfo.azimuth_pixel_spacing
      disthresh=500
      optimize=1
      corrthresh=0.8
      ; Networking.
      ; Free network.
      TLI_HPA_FREENETWORK, plistfilegamma,pdifffile, rps, aps, $
        disthresh=disthresh,corrthresh=corrthresh,arcsfile=arcsfile, optimize=optimize, txt=txt
    ENDIF ELSE BEGIN
    
    
    
      range_pixel_spacing= finfo.range_pixel_spacing
      azimuth_pixel_spacing= finfo.azimuth_pixel_spacing
      dist_thresh=1000
      
      ; Delaunay Triangulation.
      result= TLI_DELAUNAY(plistfile,outname=arcsfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
    ENDELSE
    IF 0 THEN BEGIN
      arcs_no= TLI_ARCNUMBER(arcsfile)
      arcs= COMPLEXARR(3, arcs_no)
      OPENR, lun, arcsfile,/GET_LUN
      READU, lun, arcs
      FREE_LUN, lun
      arcs= arcs[0:1, *]
      
      scale=0.2           ;  Strech scale for all the coordinates
      scale_r=0.3            ;  Strech scale for range coordinates
      scale_azi=0.3          ;  Strech scale for azimuth coordinates
      DEVICE, DECOMPOSED=0
      TVLCT, 0,255,0,1
      FOR i=0, arcs_no-1 DO BEGIN
        coor= arcs[*, i]*scale
        PLOTS, [REAL_PART(coor[0]),REAL_PART(coor[1])], [IMAGINARY(coor[0]), IMAGINARY(coor[1])], $
          color=1,/DEVICE
      ENDFOR
    ENDIF
    
    
    Print, 'Delaunay Triangulation Done!!!'
  ENDIF
  
  
  IF 1 THEN BEGIN
  
  
    wavelength= c/finfo.radar_frequency
    deltar= finfo.range_pixel_spacing
    R1= finfo.near_range_slc
    
    TLI_LINEAR_SOLVE_GAMMA, sarlistfile,pdifffile,plistfile,itabfile,arcsfile,pbasefile,plafile,dvddhfile, $
      wavelength, deltar, R1
      
    ; �Զ�ѡ��Ӱ�����ĵ���Ϊ�ο��㣬����������...
    IF 1 THEN BEGIN
      plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
      samples= DOUBLE(finfo.range_samples)
      lines= DOUBLE(finfo.azimuth_lines)
      plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
      min_dist= MIN(plist_dist, refind)
      Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
    ENDIF
    ref_v=0          ; �ο����α����ʣ��ⲿ���ݣ����û�ָ����Ĭ��Ϊ0
    ref_dh=0         ; �ο���߳����, �ⲿ���ݣ����û�ָ����Ĭ��Ϊ0
    mask_arc= 0.98    ; ��Χ[0,1]  �Ƽ���Χ[0.8,1] ����ʱ�����ϵ����ֵ
    mask_pt_coh= 0.95 ; ��Χ[0,1]  �Ƽ���Χ[0.8,1] ��λʱ�����ϵ����ֵ
    refind= refind   ; �ο������꣬�轻��ѡ��
    v_acc= 10        ; ����α����ʼ������ ���Ƽ���Χ[5,100]
    dh_acc= 10       ; �̼߳������ ���Ƽ���Χ[10,100]
    TLI_RG_DVDDH_CONSTRAINTS, plistfile, dvddhfile, vdhfile, ptattrfile,mask_arc, mask_pt_coh, refind, v_acc, dh_acc
    
    ;  TLI_RG_DVDDH, plistfile, dvddhfile, vdhfile, mask_arc, refind
    ;      TLI_RG_DVDDH_NOWEIGHT, plistfile, dvddhfile, vdhfile, ptattrfile,mask_arc, mask_pt_coh, refind, v_acc, dh_acc
    ;  TLI_RG_DVDDH_CONSTRAINTS, plistfile, dvddhfile, vdhfile, ptattrfile,mask_arc, mask_pt_coh, refind, v_acc, dh_acc
    
    v= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
    x= v[1,*]
    y= v[2,*]
    z= v[3,*]
    show_z= BYTSCL(z)
    Print, '[max min] of z:',MAX(z), MIN(z)
    z_std= STDDEV(z)
    z_m= MEAN(z)
    ind= WHERE((z GE z_m-z_std*3) AND (z LE z_m+3*z_std))
    z_n= z[*, ind]
    Print, '[max min] of z(optimized):',MAX(z_n), MIN(z_n)
    Print, 'STD of z:', STDDEV(z_n)
  ENDIF
END