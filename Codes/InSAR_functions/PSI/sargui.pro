@sargui_tli_hpa
PRO SARGUI,IMAGE=IMAGE,XSIZE=XSIZE,YSIZE=YSIZE,BOTTOM=BOTTOM,NCOLORS=NCOLORS,TITLE=TITLE,TABLE=TABLE,DEGUB=DEBUG
  ;����GUI�����и������ֱ�Ϊ��
  ;XSIZE:ȷ��widget_draw�ؼ�x���򳤶�
  ;YSIZE:ȷ��widget_draw�ؼ�y���򳤶�
  ;TITLE:�Ի������
  ;TABLE:����õ�Ԥ�������ɫ��
  ;DEBUG:����BUG�����������Ϣ

  ;-���ϵͳ�Ƿ�֧���������
  if((!d.FLAGS and 65536)eq 0)then message,'Widgets are not supported on this device'
  ;���!d.flags������65536,��֧�������
  
  device,get_screen_size=screen_size
  ;xsize=screen_size(0)*0.618
  xsize=750
  ;-�������
  tlb=widget_base(title='PSISWJTU',column=1,mbar=mbar,xsize=xsize,tlb_frame_attr=1,/tlb_size_event,xoffset=10, yoffset=10)
  ;����������������и����ؼ��ֵĹ���Ϊ��
  ;column:ʹ���������������
  ;mbar:���������ID
  ;title��������������ƣ��Ѿ��ڳ����ʼ���������
  ;/tlb_size_event����base�����С�ı�ʱ������һ���¼�
  ;-�����˵�
  fmenu=widget_button(mbar,value='�ļ�')
  openID=widget_button(fmenu,value='��',menu=2)
  slcID=widget_button(openID,value='SLCӰ��',event_pro='sargui_openslc')
  bmpID=widget_button(openID,value='BMPӰ��',event_pro='sargui_openbmp')
  ;  saveID=widget_button(fmenu,value='���Ϊ...',menu=2)
  ;    jpegID=widget_button(saveID,value='JPEGͼ��',event_pro='sargui_jpeg')
  ;    bmpID=widget_button(saveID,value='BMPͼ��',event_pro='sargui_bmp')
  exitID=widget_button(fmenu,value='�˳�',event_pro='sargui_cancle')
  ;editmenu=widget_button(mbar,value='�༭')
  ;  copyID=widget_button(editmenu,value='����')
  ;  cutID=widget_button(editmenu,value='����')
  ;  pasteID=widget_button(editmenu,value='ճ��')
  ;  zoominID=widget_button(editmenu,value='�Ŵ�')
  ;  zoomoutID=widget_button(editmenu,value='��С')
  presarmenu=widget_button(mbar,value='Ӱ�����')
  plistID=widget_button(presarmenu,value='����Ӱ���б��ļ�',event_pro='sargui_list')
  changeID=widget_button(presarmenu,value='���Ӹ�Ӱ��ת��',menu=2)
  phaseID=widget_button(changeID,value='��λ',event_pro='sargui_phase')
  amplitudeID=widget_button(changeID,value='���',event_pro='sargui_amplitude')
  baseID=widget_button(presarmenu,value='���߽���',event_pro='sargui_basemap')
  ;    timeID=widget_button(baseID,value='ʱ����߽���',event_pro='sargui_timebase')
  ;    spaceID=widget_button(baseID,value='�ռ���߽���',event_pro='sargui_spacebase')
  comID=widget_button(presarmenu,value='С���߸�������',event_pro='sargui_smallbase')
  
  psmenu=widget_button(mbar,value='PS̽�����')
  psdetectID=widget_button(psmenu,value='PS��̽��',event_pro='sargui_dtctps')
  psnetID=widget_button(psmenu,value='Delauney����������',event_pro='sargui_delauney')
  
  dmenu=widget_button(mbar,value='��ָ��洦��')
  inter=widget_button(dmenu,value='ʱ����洦��',event_pro='sargui_interferometry')
  flattenning=widget_button(dmenu,value='ȥƽ��ЧӦ',event_pro='SARGUI_FLATTENNING')
  diff=widget_button(dmenu,value='ʱ���ָ���',event_pro='SARGUI_DIFF_INT')
  original=widget_button(dmenu,value='������λ����',event_pro='sargui_inter')
  
  anspamenu=widget_button(mbar,value='PS���Է�������')
  ;  interID=widget_button(anspamenu,value='ԭʼ����ͼ����',event_pro='sargui_inter')
  zengID=widget_button(anspamenu,value='�����������',event_pro='sargui_jhl')
  ;    psphase=WIDGET_BUTTON(zengID,value='PS���ϲ�ָ�����λ����ȡ')
  ;    dv_ddh=WIDGET_BUTTON(zengID,value='�������ʺ͸߳������������',event_pro='sargui_jhl')
  pserrID=widget_button(anspamenu,value='PS����ƽ�����',event_pro='sargui_sparsels')
  losmenu=widget_button(mbar,value='PS�����Է�������')
  linID=widget_button(losmenu,value='�����α�͸߳�����ֵ',event_pro='SARGUI_PSKRINGING')
  ;  filID=widget_button(losmenu,value='PS��λ�˲�')
  unwID=widget_button(losmenu,value='PS��λ�в���',event_pro='sargui_unwrapres')
  tsID=widget_button(losmenu,value='PSʱ�����з���',event_pro='sargui_svdls')
  atmID=widget_button(losmenu,value='������λ�����ֽ�',event_pro='SARGUI_NLDEF')
  losmenu=widget_button(mbar,value='LOS��ر��α����')
  ;  psdID=widget_button(losmenu,value='PS�α�������')
  kriID=widget_button(losmenu,value='LOS���α����',event_pro='sargui_deflos')
  diflos=widget_button(losmenu,value='LOS���α��ѯ',event_pro='sargui_deflos_alt',separator=1)
  
  ; The following info are added on 06-09-2013.
  ; Written by T.Li @ ISEIS
  advmenu=WIDGET_BUTTON(mbar, value='�༶ʱ�����')  ; Advanced functions
  temp=WIDGET_BUTTON(advmenu, value='���������绯����', event_pro='sargui_zr_network')
  temp=WIDGET_BUTTON(advmenu, value='�����ʱ�����', event_pro='sargui_zr_multi_comp')
  temp=WIDGET_BUTTON(advmenu, value='�㼶��PSʱ�����', event_pro='sargui_tli_hpa')
  
  helpmenu=widget_button(mbar,value='����')
  funID=widget_button(helpmenu,value='����')
  upgradeID=widget_button(helpmenu,value='����')
  versionID=widget_button(helpmenu,value='�汾',event_pro='sargui_version')
  
  ;-����widget_draw�ؼ�
  ;-/motion_events���ڷ�������ƶ��¼�
  ;draw_id=widget_draw(tlb,xsize=draw_xsize,ysize=draw_ysize,uvalue='Draw')
  ;base=widget_base(tlb,row=1,/align_center)
  ;label_id=widget_label(base,value='',/align_left,/dynamic_resize)
  ;-���û�ͼ�������Ϊ��ǰ����
  ;widget_control,draw_id,get_value=draw_window
  ;wset,draw_window
  ;device=!d.name
  ;widget_control,tlb,tlb_get_size=base_size
  
  slcamplitude=0
  slc=0
  version=!version.release
  ;-������Ϣ�ṹ��
  ;info={slc:slc,slcamplitude:slcamplitude,debug:debug,version:version,$
  ;  draw_xsize:draw_xsize,draw_ysize:draw_ysize,tlb:tlb,draw_id:draw_id,draw_window:draw_window,$
  ;  label_id:label_id,device:device,base_size:base_size,out_pos:fltarr(4)}
  state={slc:slc,slcamplitude:slcamplitude,version:version,$
    tlb:tlb,out_pos:fltarr(4)}
    
  ;-��ָ��װ�ص�����infoptr��
  pstate=ptr_new(info,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'sargui',tlb,/no_block
;xmanager,'sargui',tlb,event_handler='sargui_label',/no_block
;if debug then print,'IMGUI startup is done'
END
