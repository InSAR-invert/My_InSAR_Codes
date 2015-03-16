
@tli_psselect
PRO TLI_HPA_INFOEXPAND
;Resolve_All

c= 299792458D ; Speed light
  
  ; Use GAMMA input files.
  ; Only support single master image.
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  resultpath=workpath+'/HPA'
  ; Input files
  sarlistfilegamma= workpath+'/SLC_tab'
  pdifffile= workpath+'/pdiff0'
  plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
  plistfile= workpath+'/HPA/plist'
  itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=workpath+'/HPA/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  pbasefile=workpath+'/HPA/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
  plafile=workpath+'/HPA/pla'
  dvddhfile=workpath+'/HPA/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
  vdhfile= workpath+'/HPA/vdh'
  ptattrfile= workpath+'/HPA/ptattr'
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
  logfile= resultpath+PATH_SEP()+'log'+STRCOMPRESS(SYSTIME(/SECONDS),/REMOVE_ALL)+'.txt'     ; Log file.
  ; If logfile already exist, then append. If not, create a new one.
  IF FILE_TEST(logfile) THEN BEGIN
    OPENW, loglun, logfile,/GET_LUN,/APPEND
  ENDIF ELSE BEGIN
    OPENW, loglun, logfile,/GET_LUN
  ENDELSE
  

END