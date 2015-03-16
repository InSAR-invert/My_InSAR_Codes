PRO ISODAT, infile, outfile
  ;- ����IDL���з���
  ;- ��ʵ��ѡ�õ�ʾ�����ݣ����෽��ΪISODATA
  
  ;- ��ʼ��envi
  COMPILE_OPT idl2
  envi, /restore_base_save_files
  envi_batch_init, log_file='batch.txt'
  ;- envi������
;  input_file=FILEPATH('can_tmr.img', SUBDIRECTORY=['products','envi45','data']);- �����ļ�·��
  input_file=infile
;  output_file=FILEPATH('test.img', SUBDIRECTORY=['products','envi45','data']);- ����ļ�·��
  output_file=outfile
  envi_open_file, input_file, r_fid=fid ;- ����ENVI���ļ������ļ��߼���r_fid�浽����fid��
  ;- ����ļ��Ƿ���Ա���
  if (fid eq -1) then begin
    temp=DIALOG_MESSAGE('openfile error!', /error)
    envi_batch_exit
    RETURN
  endif
  envi_file_query,fid, ns=ns, nl=nl, nb=nb ;-��ȡ�ļ���Ϣ��nsΪnumber of samples����������nlΪnumber of lines���㶮�ġ�
  dims = [-1l, 0, ns-1, 0, nl-1];-dims��������ֱַ����
                                ;-1��ָ��ROI��ָ�룬��û�У�����Ϊ-1L
                                ;-2����ʼ��
                                ;-3����ֹ��
                                ;-4����ʼ��
                                ;-5����ֹ��
  pos =LINDGEN(nb);-Ҫ���д���Ĳ��Ρ�����Ҫ�����1�����Σ���ֵpos=0��Ҫ����3��4���Σ���ֵpos=[2,3]
  envi_doit,'class_doit',dims=dims,fid=fid,method=4,pos=pos,out_name=output_file,change_thresh=1.00,iso_merge_dist=2,$
    iso_merge_pairs=2,iso_min_pixels=1.00,iso_split_smult=1,iterations=5,min_classes=5,num_classes=10,$
    ISO_SPLIT_STD  =2.0       
  ;- �򿪴��ڲ���ʾԭʼͼ��
  img=INTARR(ns, nl, 3)
  img[*,*,0]=ENVI_GET_DATA(fid=fid, dims=dims, pos=3)
  img[*,*,1]=ENVI_GET_DATA(fid=fid, dims=dims, pos=2)
  img[*,*,2]=ENVI_GET_DATA(fid=fid, dims=dims, pos=1)  
  WINDOW, XSIZE=ns, YSIZE=nl*2, title='�ϰ벿��Ϊԭʼͼ���°벿��Ϊ����ͼ��'
  TVSCL, img, true=3, 0
  ;- ��ʾ����ͼ��
  ENVI_OPEN_FILE, output_file, r_fid=fid
  ENVI_FILE_QUERY,fid, ns=ns, nl=nl
  out=ENVI_GET_DATA(fid=fid, dims=dims, POS=0) 
  DEVICE, DECOMPOSED=0
  LOADCT, 5
  TVSCL, out, 1
  DEVICE, DECOMPOSED=1
  WAIT, 10
  envi_batch_exit
END
