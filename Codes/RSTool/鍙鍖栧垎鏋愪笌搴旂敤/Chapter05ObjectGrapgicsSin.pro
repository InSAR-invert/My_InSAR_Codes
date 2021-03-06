; Chapter05ObjectGrapgicsSin.pro
PRO Chapter05ObjectGrapgicsSin
    MyWindow = OBJ_NEW('IDLgrWindow')     ;创建窗口对象
    MyView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0,-1,100,2])     ;创建视图对象
    MyModel = OBJ_NEW('IDLgrModel')      ;创建模式对象
    MyPlot = OBJ_NEW('IDLgrPlot', SIN(FINDGEN(100)/10))     ;创建正弦曲线图元对象
    MyModel -> ADD, MyPlot                  ;添加MyPlot对象到MyModel
    MyView -> ADD, MyModel                ;添加MyPlot对象到MyModel
    MyWindow -> DRAW, MyView          ;添加MyPlot对象到MyModel
    WAIT, 20                                         ;暂停10秒
    OBJ_DESTROY, MyWindow              ;删除MyWindow对象
    OBJ_DESTROY, MyView                   ;删除MyView对象
END