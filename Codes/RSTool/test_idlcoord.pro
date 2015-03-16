PRO test_idlcoord
  ;
  oWindow = OBJ_NEW('IDLgrWindow', $
    retain =2, $
    DIMENSIONS = [800,400])    
    
  ;��ʾ��ϵ�ṹ
  oView = OBJ_NEW('IDLgrView')
  shapeModel = OBJ_NEW('IDLgrModel')
  imageModel= OBJ_NEW('IDLgrModel')
  oTopModel= OBJ_NEW('IDLgrModel')
  oTopModel->add,[imageModel,shapeModel]
  oView->add,oTopModel
  
  ;��ȡ����
  file = filepath( 'day.jpg', SUBDIRECTORY=['examples','data'] )
  
  READ_JPEG, file,imageData
  ; Resize the image data
  imageData = congrid(imageData,3,360,180)
  
  oImage = OBJ_NEW('IDLgrImage', $
    imageData)
  imageModel->add,oImage
  ;��ȡʸ���ļ�
  shpFilename = filepath( 'shape\continents.shp', SUBDIRECTORY=['resource','maps'] )
  shapeFile = OBJ_NEW('IDLffShape', shpFileName)
  shapeFile->getproperty, N_Entities = nEntities
  
  FOR i=0, nEntities-1 DO BEGIN
    entitie = shapeFile->getentity(i)
    
    IF PTR_VALID(entitie.parts) NE 0 THEN BEGIN
      cuts = [*entitie.parts, entitie.n_vertices]
      FOR j=0, entitie.n_parts-1 DO BEGIN
        tempLon = (*entitie.vertices)[0,cuts[j]:cuts[j+1] - 1]
        tempLat = (*entitie.vertices)[1,cuts[j]:cuts[j+1] - 1]
        ;ת������ǰͼ��������
        tempLon = (REFORM(tempLon) -(-180))
        tempLat = (REFORM(tempLat) -(-90))
        ;
        num = N_ELEMENTS(tempLon)
        polylines = LINDGEN(num+1)-1
        polylines[0] = num
        
        tempPlot = OBJ_NEW('IDLgrPolyline', $
          tempLon, $
          tempLat, $
          Polylines = polyLines    , $
          Alpha_Channel = 1, $
          color = [255,0,0])
        shapeModel->add,tempPlot
        
      ENDFOR
    ENDIF
    shapeFile->destroyentity, entitie
  ENDFOR
  ;
  ;  ͼ��������ʾ
  oView->setproperty, viewPlane_Rect = [0,0,800,400]
  oWindow->SetProperty, title ='ͼ��������ʾ'
  oWindow->draw,oView
  ;ͣ������
  wait,2
  
  ;��һ��������ʾ
  ;����ԭ����
  OBJ_DESTROY,oTopModel
  ;�����µ�
  shapeModel = OBJ_NEW('IDLgrModel')
  imageModel= OBJ_NEW('IDLgrModel')
  oTopModel= OBJ_NEW('IDLgrModel')
  oTopModel->add,[imageModel,shapeModel]
  oView->add,oTopModel
  ;
  oImage = OBJ_NEW('IDLgrImage', $
    imageData)
  imageModel->add,oImage
  ;��ȡ��ǰͼ������X��Y����ķ�Χ
  oImage->getproperty, xRange = xRange,yRange = yRange
  ;�����һ��ϵ��
  xr = norm_coord(xRange)
  ;������xrange =[0,360],xr����������,[-0.00000000 ,0.0027777778],ͨ�����øò�����
  ;��ôת����x�����ԭ��������Ϊxr[0]+xr[1]*xrange[0]= -0+0.002777*0 = 0
  ;                           xr[0]+xr[1]*xRange[1]= -0+0.002777*360 =1
  ; �ɲ��� Norm_Coord([-100,100]) =      [0.500000 ,  0.00500000]
  ;
  yr = norm_coord(yRange)
  oImage->setproperty, xCoord_conv = xr, $
    yCoord_conv = yr
  ;
  shapeFile = OBJ_NEW('IDLffShape', shpFileName)
  shapeFile->getproperty, N_Entities = nEntities
  
  FOR i=0, nEntities-1 DO BEGIN
    entitie = shapeFile->getentity(i)
    
    IF PTR_VALID(entitie.parts) NE 0 THEN BEGIN
      cuts = [*entitie.parts, entitie.n_vertices]
;      cuts = reform(cuts);- α��ά��һά
      FOR j=0, entitie.n_parts-1 DO BEGIN
        tempLon = (*entitie.vertices)[0,cuts:cuts[i+1] - 1]
        tempLat = (*entitie.vertices)[1,cuts[j]:cuts[j+1] - 1]
        ;
        ;ת������һ��������ϵ����ʾ
        tempLon = FLOAT((REFORM(tempLon) -(-180))) /360.
        tempLat = FLOAT((REFORM(tempLat) -(-90)))/180.
        ;
        num = N_ELEMENTS(tempLon)
        polylines = LINDGEN(num+1)-1
        polylines[0] = num
        
        tempPlot = OBJ_NEW('IDLgrPolyline', $
          tempLon, $
          tempLat, $
          Polylines = polyLines    , $
          Alpha_Channel = 1, $
          color = [255,0,0])
        shapeModel->add,tempPlot
        
      ENDFOR
    ENDIF
    shapeFile->destroyentity, entitie
  ENDFOR
  ;
  ; ������ʾ��������
  oView->setproperty, viewPlane_Rect = [0,0,1,1]
  oWindow->SetProperty, title ='��һ��������ʾ'
  oWindow->draw,oView
  ;ͣ������
  wait,2
  
  ;����������ʾ
  ;����ԭ����
  OBJ_DESTROY,oTopModel
  
  ;�����µ�
  sMap = map_proj_init('Interrupted Goode') 
;  ���������ͶӰ
;  ;ȫ��ġ��Ⱦ�Բ��ͶӰ��
;  sMap = Map_Proj_Init('Equirectangular'        , $
;                 Limit = [-90,-180,90,180]     , $
;                 Center_Longitude = 0        )
  
  shapeModel = OBJ_NEW('IDLgrModel')
  imageModel= OBJ_NEW('IDLgrModel')
  oTopModel= OBJ_NEW('IDLgrModel')
  oTopModel->add,[imageModel,shapeModel]
  oView->add,oTopModel
  ;
  
  ;��ͼ����о���
  ;
  red= REFORM(imageData[0,*,*])
  green= REFORM(imageData[1,*,*])
  blue= REFORM(imageData[2,*,*])
  
  red1 = map_proj_image( red, MAP_STRUCTURE=sMap, MASK=mask, $
    UVRANGE=uvrange, XINDEX=xindex, YINDEX=yindex )
  green1 = map_proj_image( green, XINDEX=xindex, YINDEX=yindex )
  blue1 = map_proj_image( blue, XINDEX=xindex, YINDEX=yindex )
  imageData = BYTARR(4,360,180)
  imageData[0,*,*] = red1
  imageData[1,*,*] = green
  imageData[2,*,*] = blue
  ;������Ĥ
  imageData[3,*,*] = mask*255b
  ;
  uRange = uvRange[2]-uvRange[0]
  vRange = uvRange[3]-uvRange[1]
  
  oImage = OBJ_NEW('IDLgrImage', $
    imageData, $
    BLEND_FUNCTION = [3, 4], $
    dimensions=[uRange,vRange], $  ;ά��--�������
    location=uvRange[0:1] )        ;λ��--�������
  imageModel->add,oImage
  ;  ;
  shapeFile = OBJ_NEW('IDLffShape', shpFileName)
  shapeFile->getproperty, N_Entities = nEntities
  
  FOR i=0, nEntities-1 DO BEGIN
    entitie = shapeFile->getentity(i)
    
    IF PTR_VALID(entitie.parts) NE 0 THEN BEGIN
      cuts = [*entitie.parts, entitie.n_vertices]
      FOR j=0, entitie.n_parts-1 DO BEGIN
        tempLon = (*entitie.vertices)[0,cuts[j]:cuts[j+1] - 1]
        tempLat = (*entitie.vertices)[1,cuts[j]:cuts[j+1] - 1]
        ;
        ;ת����m������ϵ����ʾ
        vert = MAP_PROJ_FORWARD([tempLon,tempLat], $
          Map_Structure = sMap, $
          Polylines = polyLines)
        ;          
        tempPlot = OBJ_NEW('IDLgrPolyline', $
          vert[0,*], $
          vert[1,*], $
          Polylines = polyLines    , $
          Alpha_Channel = 1, $
          color = [255,0,0])
        shapeModel->add,tempPlot
        
      ENDFOR
    ENDIF
    shapeFile->destroyentity, entitie
  ENDFOR
  ;
  ; ������ʾ�������� 
  
  oView->setproperty, viewPlane_Rect = [uvrange[0],uvrange[1],uRange,vRange]
  oWindow->SetProperty, title ='Interrupted Goode ͶӰ��m��������ʾ'
  oWindow->draw,oView  
END