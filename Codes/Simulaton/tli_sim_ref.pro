; Calculate the difference between the simulated data and the calculated data.

PRO TLI_SIM_REF

  COMPILE_OPT idl2
  c= 299792458D ; Speed light
  
  
  workpath='/mnt/software/myfiles/Software/experiment/sim'
  
  resultpath=workpath+'/testforCUHK'
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfilegamma= workpath+'/SLC_tab'
    pdifffile= workpath+'/simph'
    simlinfile= workpath+'/simlin'
    simherrfile= workpath+'/simherr'
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
    sarlistfile= resultpath+PATH_SEP()+'sarlist_Linux'                  ; �ļ��б�
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
    OPENW, loglun, logfile,/GET_LUN
    
  ENDIF ELSE BEGIN
    sarlistfile= TLI_DIRW2L(sarlistfile,/reverse)
    pdifffile=TLI_DIRW2L(pdifffile,/reverse)
    plistfile=TLI_DIRW2L(plistfile,/reverse)
    itabfile=TLI_DIRW2L(itabfile,/reverse)
    arcsfile=TLI_DIRW2L(arcsfile,/reverse)
    pbasefile=TLI_DIRW2L(pbasefile,/reverse)
    outfile=TLI_DIRW2L(outfile,/reverse)
  ENDELSE
  
  finfo= TLI_LOAD_MPAR(sarlistfilegamma,itabfile)
  
  IF 1 THEN BEGIN
    plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
    samples= DOUBLE(finfo.range_samples)
    lines= DOUBLE(finfo.azimuth_lines)
    plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
    min_dist= MIN(plist_dist, refind)
    Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
  ENDIF
  PrintF, loglun, 'Reference point index:'+STRCOMPRESS(refind)+'.   Coordinates:'+STRCOMPRESS( plist[refind])
  
  ; Read simlin file   simulated linear def. vel. file.
  simlin= TLI_READDATA(simlinfile,samples=1, format='DOUBLE')
  ; Find ref. point's v in simlin
  ref_v= simlin[refind]
  
  ; Read vdh file
  vdh= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
  v= vdh[3, *]
  ref_v_here= (v[WHERE(vdh[0,*] EQ refind)])[0]
  vdh[3, *]= v+(ref_v-ref_v_here)
  
  simlin= simlin[vdh[0, *]]
  res= vdh
  res[3, *]= simlin-res[3, *]
  
  ; Report the accuracy
  ; The accuracy of deformation velocity.
  minsmv= MIN(simlin, max= maxsmv)
  PrintF, loglun, ''
  PrintF, loglun, '*************************************************************'
  PrintF, loglun, 'Statistics of original v:'
  PrintF, loglun, 'min_sim_v:'+STRING(minsmv)
  PrintF, loglun, 'max_sim_v:'+STRING(maxsmv)
  PrintF, loglun, 'std_sim_v:'+STRING(STDDEV(simlin))
  PrintF, loglun, 'mean_sim_v:'+STRING(MEAN(ABS(simlin)))
  
  minv= MIN(v, max=maxv)
  PrintF, loglun, ''
  PrintF, loglun, '*************************************************************'
  PrintF, loglun, 'Statistics of calculated v:'
  PrintF, loglun, 'min_cal_v:'+STRING(minv)
  PrintF, loglun, 'max_cal_v:'+STRING(maxv)
  PrintF, loglun, 'std_cal_v:'+STRING(STDDEV(v))
  PrintF, loglun, 'mean_cal_v:'+STRING(MEAN(ABS(v)))
  
  
  minres= MIN(res[3, *], max=maxres)
  stdres= STDDEV(res[3, *])
  PrintF, loglun, ''
  PrintF, loglun, '*************************************************************'
  PrintF, loglun, 'Accuracy of deformation velocity:'
  PrintF, loglun, 'min_acc_v:'+STRING(minres)
  PrintF, loglun, 'max_acc_v:'+STRING(maxres)
  PRintF, loglun, 'std_acc_v:'+STRING(stdres)
  PrintF, loglun, 'mean_acc_v:'+STRING(MEAN(ABS(res[3, *])))
  
  ; The accuracy of height error.
  simherr= TLI_READDATA(simherrfile, samples=1, format='DOUBLE')
  ref_herr= simherr[refind]
  minsmh= MIN(simherr, max= maxsmh)
  stdsmh= STDDEV(simherr)
  PrintF, loglun, ''
  PrintF, loglun, '*************************************************************'
  Printf, loglun, 'Statistics of simulated height error:'
  PrintF, loglun, 'min_sim_dh:'+STRING(minsmh)
  PrintF, loglun, 'max_sim_dh:'+STRING(maxsmh)
  PrintF, loglun, 'std_sim_dh:'+STRING(stdsmh)
  PrintF, loglun, 'mean_sim_dh:'+STRING(MEAN(ABS(simherr)))
  
  herr= vdh[4, *]
  ref_herr_here= (v[WHERE(vdh[0, *] EQ refind)])[0]
  vdh[4, *]= herr+(ref_herr-ref_herr_here)
  ; Report the calculated height error
  minherr= MIN(herr, max= maxherr)
  stdherr= STDDEV(herr)
  PrintF, loglun, ''
  PrintF, loglun, '*************************************************************'
  PrintF, loglun, 'Statistics of calculated height error:'
  PrintF, loglun, 'h_ref:'+STRCOMPRESS(ref_herr)
  PrintF, loglun, 'min_cal_dh:'+STRING(minherr)
  PrintF, loglun, 'max_cal_dh:'+STRING(maxherr)
  PrintF, loglun, 'std_cal_dh:'+STRING(STDDEV(herr))
  PrintF, loglun, 'mean_cal_dh:'+STRING(MEAN(ABS(herr)))
  
  ; Report the accuracy
  simherr= simherr[vdh[0, *]]
  res[4, *]= simherr-res[4, *] ; error of height error
  minres= MIN(res[4, *], max=maxres)
  stdres= STDDEV(res[4, *])
  PrintF, loglun, ''
  PrintF, loglun, '*************************************************************'
  PrintF, loglun, 'Accuracy of height error:'
  PrintF, loglun, 'min_acc_dh:'+STRING(minres)
  Printf, loglun, 'max_acc_dh:'+STRING(maxres)
  Printf, loglun, 'std_acc_dh:'+STRING(stdres)
  Printf, loglun, 'mean_acc_dh:'+STRING(MEAN(ABS(res[4, *])))
  
  OPENW, lun, vdhfile+'acc.txt',/GET_LUN
  PRINTF, lun, res
  FREE_LUN, lun
  OPENW, lun, vdhfile+'ref.txt',/GET_LUN
  PRINTF, lun, vdh
  FREE_LUN, lun
  
  new_res= res[4, *]
  meanres= MEAN(new_res)
  stdres= STDDEV(new_res)
  normal_res= WHERE(new_res GT meanres-2*stdres AND new_res LT meanres+2*stdres)
  new_res= new_res[normal_res]
  minres= MIN(new_res, max=maxres)
  stdres= STDDEV(new_res)
  meanres= MEAN(ABS(new_res))
  PrintF, loglun, ''
  PrintF, loglun, '*************************************************************'
  PrintF, loglun, 'Height accuracy of 95% PS:'
  PrintF, loglun, 'min_acc_dh95:'+STRING(minres)
  Printf, loglun, 'max_acc_dh95:'+STRING(maxres)
  Printf, loglun, 'std_acc_dh95:'+STRING(stdres)
  Printf, loglun, 'mean_acc_dh95:'+STRING(MEAN(ABS(new_res)))
  
  FREE_LUN, loglun
  
  Print, 'Main pro finished!'
  
;  STOP
END