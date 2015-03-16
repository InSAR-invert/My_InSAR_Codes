
;------------------------------------------------------------------------
;
PRO ViewImageSystem::RefreshSheet
  COMPILE_OPT idl2
  
  IF self.initFlag THEN BEGIN
    WIDGET_CONTROL, self.viewSheet, /REFRESH_PROPERTY
    WIDGET_CONTROL, self.imageSheet, /REFRESH_PROPERTY
  ENDIF
  
END

;------------------------------------------------------------------------
;
PRO ViewImageSystem::Reset
  COMPILE_OPT idl2
  
  IF self.initFlag THEN BEGIN
    self.oImage->Reset
    self.oView->Reset
    
  ENDIF
  
END
;------------------------------------------------------------------------
;
;����ı��С
;
PRO ViewImageSystem::pan,event

  self.oView->Getproperty,viewPlane_Rect = viewP
  self.oImage->Getproperty, location = imageLoc
 
  CASE event.type OF
    0: BEGIN
      ;���
      IF event.press EQ 1 THEN BEGIN
        ;Ϊƽ��׼��
        self.panStatus = [1,event.x,event.y]
        
      ENDIF
    END
    1: BEGIN
      self.panStatus = 0
      
      ;������ʾ
      self.oView->Refreshdraw
    END
    2: BEGIN
      IF self.panStatus[0] EQ 1 THEN BEGIN
        ;�ƶ���ͼ
        distance = [event.x,event.y]- self.panStatus[1:2]
        IF self.panFlag EQ 0 THEN BEGIN
          viewP[0:1] = viewP[0:1] - distance
          self.oView->Setproperty, viewPlane_Rect = viewP
          
        ENDIF ELSE BEGIN
          imageLoc += distance
          self.oImage->Setproperty, imageXLoc = imageLoc[0], $
            imageYLoc = imageLoc[1]
        ENDELSE
        
        self.panStatus[1:2] = [event.x, event.y]
        ;
        self->Refreshsheet
        
        ;������ʾ
        self.oView->Refreshdraw
      ENDIF
    END
    ELSE:
  ENDCASE
END
;------------------------------------------------------------------------
;
;����ı��С
;
PRO ViewImageSystem::SelectFile
  COMPILE_OPT idl2
  
  filters = [['*.jpg;*.jpeg', '*.tif;*.tiff', '*.png'], $
  ['JPEG', 'TIFF', 'Bitmap']]
  file = DIALOG_PICKFILE(filter = filters, $
    title = 'ѡ��ͼ���ļ�', $
    path = self.rootDir, $
    Get_Path = path)
  ;
  IF file[0] NE '' THEN BEGIN
    self.rootDir = path
    WIDGET_CONTROL, self.wInputFile, $
      Set_Value = file[0]
      
    self.initFlag = self.oImage->Initimage(file[0])
    
    IF self.initFlag THEN BEGIN
      ;
      self.oView->Refreshdraw
      self->Refreshsheet
    ENDIF
  ;    Widget_Control,self.controlBase,/REFRESH_PROPERTY
  END
END

;------------------------------------------------------------------------
;
;�������¼�����
;
PRO ViewImageSystem::HandleEvent, event
  COMPILE_OPT idl2
  
  tagName = TAG_NAMES(event, /Structure_Name)
  CASE tagName OF
    ;ϵͳ�ر��¼�
    'WIDGET_KILL_REQUEST': BEGIN
      status = DIALOG_MESSAGE('Exit?', /Question,dialog_parent=self.wTlb)
      IF status EQ 'Yes'THEN BEGIN
        WIDGET_CONTROL, event.top, /Destroy
      ENDIF
      RETURN
    END
    ;���Ը�����
    'WIDGET_PROPSHEET_CHANGE' :BEGIN
    IF (event.proptype NE 0) THEN BEGIN
      value = WIDGET_INFO(event.id, Property_Value = event.identifier)
      event.component->Setpropertybyidentifier, event.identifier, value
      self.oView->Refreshdraw,/Erase
    ENDIF
  END
  ;Draw����
  'WIDGET_DRAW' :BEGIN
  IF self.initFlag THEN BEGIN
    ;���ڱ�¶�¼�
    IF event.type EQ 4 THEN BEGIN
      self.oView->Refreshdraw
      RETURN
    ENDIF
    
    CASE self.mouseStatus OF
      'zoom': self->Zoom, event
      'pan': self->Pan, event
      ELSE:
    ENDCASE
  ENDIF
  
END

ELSE:
ENDCASE 

UName = WIDGET_INFO(event.id, /UName)

CASE UName OF
  ;�˳�
  'exit': BEGIN
    status = DIALOG_MESSAGE('�ر�?', /Question)
    IF status EQ 'Yes'THEN BEGIN
      WIDGET_CONTROL, event.top, /Destroy
    ENDIF
    RETURN
  END
  ;����
  'about' : BEGIN
    status = DIALOG_MESSAGE(''+STRING(13B)+  $
      'Author: DYQ ' +STRING(13B)+  $
      'E-mail: dongyq@esrichina-bj.cn'+STRING(13B)+  $
      'MSN: dongyq@esrichina-bj.cn',/INFORMATION)
  END
  ;ѡ���ļ�����
  'select': self->Selectfile
  'reset': self->Reset
  'mview': BEGIN
    self.panFlag = 0
  END
  'mimage': BEGIN
    self.panFlag = 1
  END
  ;    end
  ELSE: BEGIN
  
  ENDELSE
ENDCASE
END
;-----------------------------------------------------------------
;����menu
;
PRO ViewImageSystem::CreateMenu, mBar
  COMPILE_OPT idl2
  ;
  fMenu = WIDGET_BUTTON(mBar, value ='�ļ�',/Menu)
  fReset = WIDGET_BUTTON(fMenu, value = '��ʼֵ', $
    uName = 'reset')
  fExit = WIDGET_BUTTON(fMenu, value = '�˳�', $
    uName = 'exit',/Sep)
  ;
  hMenu =  WIDGET_BUTTON(mBar, value ='����',/Menu)
  hHelp = WIDGET_BUTTON(hmenu, value = '����', $
    uName = 'about',/Sep)
    
END

;-----------------------------------------------------------------
;
;����ϵͳ���
;
PRO ViewImageSystem::Create
  COMPILE_OPT idl2
  
  ;create toplevelbase
  self.wTlb = WIDGET_BASE($
    UName = 'wBase', $
    UValue = self, $
    Title = ' Draw&View&Image: Location* Dimension', $
    TLB_FRAME_ATTR = 1, $
    MBar = mBar, $
    Space = 0, $
    XPad = 0, $
    YPad = 0, $
    Xoffset = 0, $
    Yoffset = 0, $
    Map = 0, $
    /Column, $
    /Tlb_Kill_Request_Events)
    
  WIDGET_CONTROL, self.wTlb, /Realize
  
  ;�˵���
  self->Createmenu,mBar
  ;�˵���
  ;  upBase = Widget_Base(self.wTlb, $
  ;    /Row, $
  ;    Space = 0)
  middleBase = WIDGET_BASE(self.wTlb, $
    /Row, $
    Space = 0)
  downBase  = WIDGET_BASE(self.wTlb, $
    /Row, $
    Space = 0)
  label = WIDGET_LABEL(downBase, value = ' Ready')
  
  ;
  ;������ʾ������
  left = WIDGET_BASE(middleBase,/Column)
  right = WIDGET_BASE(middleBase, $
    Space = 0 , $
    XPad = 0, $
    YPad = 0)
  ;���Ŀ������
  wInput = WIDGET_BASE(left, /ROW)
  self.wInputFile = WIDGET_TEXT(wInput, $
    XSize = 25)
  wSel = WIDGET_BUTTON(wInput, $
    uName = 'select',value = '�ļ�')
    
  tabBase = WIDGET_TAB(left)
  viewBase = WIDGET_BASE(tabBase, $
    Space = 2 , $
    XPad = 0, $
    YPad = 0 , $
    title = 'View����' , $
    /COLUMN)
  imageBase = WIDGET_BASE(tabBase, $
    Space = 2 , $
    XPad = 0, $
    YPad = 0 , $
    title= 'Image����' ,$
    /COLUMN)
  ;�Ҳ����ʾ
  drawBase = WIDGET_BASE(right, /Frame)
  ;
  self.viewSheet = WIDGET_PROPERTYSHEET(viewBase, $
    /Sunken_Frame, $
    Scr_XSize = 200, $
    ySize = 21, $
    /Multiple_Properties)
  self.imageSheet = WIDGET_PROPERTYSHEET(imageBase, $
    /Sunken_Frame, $
    ySize = 20, $
    Scr_XSize = 200, $
    /Multiple_Properties)
  ;
  wReset = WIDGET_BUTTON(left, $
    value = '��ʼֵ', $
    /Frame, $
    uName = 'reset')
  ;
  label = WIDGET_LABEL(left, $
    value = 'ƽ��ʱ��')
  checkBase = WIDGET_BASE(left,/ROW, $
    /EXCLUSIVE, $
    /Frame  )
  cButton1 = WIDGET_BUTTON(checkBase, $
    value = '�޸�View', $
    uName = 'mview')
  cButton2 = WIDGET_BUTTON(checkBase, $
    value = '�޸�Image', $
    uName = 'mimage' )
  WIDGET_CONTROL, cButton1, /SET_BUTTON
  
  self.oImage = OBJ_NEW('testDimsImage', $
    controlBase = self.imageSheet , $
    /REGISTER_PROPERTIES)
  ;
  WIDGET_CONTROL,self.imageSheet, set_value = self.oImage
  
  self.oView = OBJ_NEW('testDimsView', $
    parent = drawBase, $
    controlBase = self.viewSheet , $
    rootDir = self.rootDir , $
    oImage = self.oImage, $
    xSize = self.sz[0]-200, $
    /REGISTER_PROPERTIES, $
    ySize = self.sz[1])
    
  WIDGET_CONTROL,self.viewSheet, set_value = self.oView
  ;���������
  Centertlb, self.wtlb
  
  WIDGET_CONTROL, self.wtlb,/Map,Set_UValue = self
  
END

;-----------------------------------------------------------------
;
;����
;
PRO ViewImageSystem::Cleanup
  COMPILE_OPT idl2
  
  OBJ_DESTROY, self.oView
  OBJ_DESTROY, self.oImage
  
END

;-----------------------------------------------------------------
;
;��ʼ��
;
FUNCTION ViewImageSystem::Init, rootDir = rootDir
  COMPILE_OPT idl2
  ;
  self.sz = Getprimaryscreensize()*.8
  self.mouseStatus = 'pan'
  
  ;����
  self->Create
  ;
  self.initFlag = self.oImage->Initimage(rootDir+'\demo.jpg')
  ;
  IF self.initFlag THEN BEGIN
    self.oView->Refreshdraw
    WIDGET_CONTROL, self.wInputFile, Set_Value = rootDir+'\demo.jpg'
  ENDIF
  Xmanager, 'ViewImageDemo',self.wTlb,/No_Block, Event_Handler = '_ViewImageDemo_Event', $
    Cleanup = '_ViewImageDemo_Cleanup'
    
  RETURN, 1
END

;-----------------------------------------------------------------
;
;����
;
PRO Viewimagesystem__define
  COMPILE_OPT idl2
  
  void = {ViewImageSystem          , $
    ;�̳еĸ���
    wTlb        : 0L  , $
    wInputFile  : 0L  , $
    rootDir     : ''  , $
    viewSheet   : 0L  , $
    imageSheet  : 0L  , $
    initFlag    : 0B  , $
    panFlag     : 0B  , $ ;ƽ������
    panStatus   : FLTARR(3) , $
    
    mouseStatus : ''  , $
    sz : INTARR(2)    , $
    
    oView       : OBJ_NEW() , $
    oImage      : OBJ_NEW()  $
    }
    
END