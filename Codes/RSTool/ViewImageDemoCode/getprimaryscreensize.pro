;+
; :Description:
;    ��ȡ����Ļ�Ŀ��ÿռ�.
;
; :Keywords:
;    exclude_taskbar:�Ƿ��ų�������
;-
function GETPRIMARYSCREENSIZE, Exclude_Taskbar=exclude_taskbar
  compile_opt idl2

  oMonInfo = OBJ_NEW('IDLsysMonitorInfo')
  rects = oMonInfo -> GetRectangles(Exclude_Taskbar=exclude_Taskbar)
  pmi = oMonInfo -> GetPrimaryMonitorIndex()
  OBJ_DESTROY, oMonInfo

  RETURN, rects[[2, 3], pmi] ; ����Ļ�Ŀ��ÿռ䣺����
end