;elevation.pro
pro elevation

width=500
height=500

high=fltarr(width,height);Ҳ���Դ����������飬���Ǵ�С�����д���


pa='D:\IDL\xiqing\'
re='D:\IDL\result\'

;------------------read image-------------------------
infile=pa+'sim_sar_rdc'
openr,lun,infile,/get_lun,/swap_endian
readu,lun,high
free_lun,lun

;loadct,12    ;��ȡɫ����

elefile=re+'elevation.txt'
openw,lun,elefile,/get_lun
printf,lun,high
free_lun,lun

print,'ok'

;device,decomposed=0
;window,/free,xsize=720,ysize=700
;!p.background=1
;;temp=congrid(temp,200,140)   ;���������ԭʼ��Χ���쵽200*400
;xsft=50
;ysft=150;����xy�����ƫ����
;tv,image,xsft,ysft;��ͼ����ʾ�������Զ��������ݷ�Χ����Ӧ��ʾ����
;
;
;
;cb = bindgen(255);�������飬��С1*251��������������
;;cb = extrac(cb, 0,255);��ȡcb�еĵ�0~200����
;cb = cb#replicate(1b, 15)
;x0=630/2-122
;y0=ysft/2
;tv, cb, x0,y0
;
;   contour,temp,ystyle=1,xrange=[1,500],xstyle=1,levels=300,$
;         position=[xsft,ysft,500+xsft,500+ysft],/NOERASE,/DEVICE,font=0,$
;           xticklen=0.02,yticklen=0.02,$
;         xtickname=[100,200,300,400,500],$
;         ytickname=[0,100,200,300,400,499],$
;         title=x
;        CONTOUR, cb,yrange=[ 0,1], ystyle=1, xrange=[0,255], xstyle=1,level=300,$
;        position = [x0,y0,x0+255,y0+15], /NOERASE, /DEVICE, font=0,$
;        xticklen=0.2,yticklen=0.02,xticks = 5,xminor=4,yticks=1,$
;        xtickname = ['0','51','102','153','204','255'], $
;        ytickname = [' ',' ']
;       xyouts,1,2,'     Swjtu.     RS_Lab.    Zhang Rui',font=0
;device,decomposed=0
;n=1
;temp=tvrd(true=n)
end