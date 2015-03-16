;+----------------------------------------------------------------------------------
;| Ŀ��: �����ݽ��аٷ�֮������������
;| ����: Huxz
;| ����: 2007-01
;+----------------------------------------------------------------------------------
Function LineStrech2, data, minv=minv, maxv=maxv, onlyMinMax=onlyMinMax

	Compile_Opt StrictArr

	CATCH, Error_status
    IF Error_status NE 0 THEN BEGIN
       CATCH, /CANCEL
       minv = Min(data, max=maxv, /nan)
       Return,  Bytscl(data, /nan)
    ENDIF

	dimens=Size(data,/dimensions)
    n_e = Long(dimens[0]*dimens[1])
    MinMaxCount=n_e*0.02 ; 98%�ĸ���ֵ

	if N_Elements(minv) eq 0 then begin
	    minvs = mg_n_smallest(data, MinMaxCount) ; �ҵ���С��98%�ĸ���ֵ
	    minv=max(data[minvs], /nan) ; ȡ��������
	endif

	if N_Elements(maxv) eq 0 then begin
	    maxvs = mg_n_smallest(data, MinMaxCount, /largest) ; �ҵ�����98%�ĸ���ֵ
	    maxv=min(data[maxvs], /nan) ; ȡ������С��
	endif
	; ������ٷ�2���Ե����췶Χ
	if Keyword_Set(onlyMinMax) then begin
		Return, -1
	endif

    data = Bytscl(data, min=minv, max=maxv, top=255, /nan)

    Return, data

End