PRO TEST_TEST
device,get_decomposed=old_decomposed
device,decomposed=0
loadct,25
infile='D:\InSARIDL\SARGUI\IMAGES\20090715-20100129.flt.phase.dat'
phase=fltarr(500,500)
openr,lun,infile,/get_lun
readu,lun,phase
free_lun,lun
window,xsize=500,ysize=600
tvscl,phase,0,100

    ;- ����ɫ����
    cb = bindgen(255)
    cb = extrac(cb, 0,200)
    cb = cb#replicate(1b, 15)
    device,get_decomposed=old_decomposed
    ;- ����ɫ������߿�
    x0=120
    y0=50
    CONTOUR, cb,yrange=[ 0,1], ystyle=1, xrange=[-!pi,!pi], xstyle=1,level=300,$
        position = [x0,y0,x0+200,y0+15], /NOERASE, /DEVICE, font=0,$
        xticklen=0.2,yticklen=0.02,xticks = 2,yticks=1,$
        xtickname = ['-��','0','��'],ytickname = [' ',' ']
    ;- ��ʾɫ����
    tv,cb,x0,y0
device,decomposed=old_decomposed
END