% ָ���ļ�·��
clear;
clc;
chlorfile= 'D:\myfiles\Yatou_paper\Data\chl\S20003362000366.L3m_MO_CHL_chlor_a_9km';
kdfile= 'D:\myfiles\Yatou_paper\Data\KD490\S20000322000060.L3m_MO_KD490_Kd_490_9km';
parfile= 'D:\myfiles\Yatou_paper\Data\PAR\S20000322000060.L3m_MO_PAR_par_9km';
sstfile= 'D:\myfiles\Yatou_paper\Data\SST\T20000322000060.L3m_MO_SST_9';
sst_200002='D:\myfiles\Yatou_paper\Data\AquaSST\A20000322000060.L3m_MO_SST_9';
% chlorfile= 'D:\myfiles\Yatou_paper\Data\chl\S20000322000060.L3m_MO_CHL_chlor_a_9km';
% kdfile= 'D:\myfiles\Yatou_paper\Data\kd490\S20000322000060.L3m_MO_KD490_Kd_490_9km';
% parfile= 'D:\myfiles\Yatou_paper\Data\par\S20000322000060.L3m_MO_PAR_par_9km';
% sstfile= 'D:\myfiles\Yatou_paper\Data\sst\T20000322000060.L3m_MO_SST_9';
result_path= 'D:\myfiles\Yatou_paper\result';
%--------------------------------------------------------
% ��ȡ����
range=[598,812,3566,3696];%[598,812,3566,3696];%�ü�������
chl= load_hdf_chinasea(chlorfile,range(1),range(2),range(3),range(4));
kd= load_hdf_chinasea(kdfile,range(1),range(2),range(3),range(4));
PAR= load_hdf_chinasea(parfile,range(1),range(2),range(3),range(4));
%����sst����
% sst= load_hdf_chinasea(sstfile, range(1),range(2),range(3),range(4));
file_info= hdfinfo(sstfile);
sst_sds_info=file_info.SDS;
sst_sds_info= sst_sds_info(1,1);
sst= hdfread(sst_sds_info);
sst= double(sst);
sst(sst==65535)=nan;
sst= sst(range(1):range(2),range(3):range(4));% ��ȡSST�����ݡ�
sst= single(sst);
disp(file_info.Attributes(54).Name);
disp(file_info.Attributes(54).Value);%������ʽ
slope=double(file_info.Attributes(55).Value);%������ʽ�еĲ���
intercept=double(file_info.Attributes(56).Value);%������ʽ�еĲ���
sst= slope*sst+intercept;%����ת����ʽ�μ�file_info.Attributes(54).Value.
sst= single(sst);

%------------------------����--------------------------------
% vgpmresult= cal_opp_chinasea(chlorfile, kdfile, parfile, sstfile, result_path);

% new_chl= 4.04672*log((chl+10.02913)/9.62471);
% 
% difference= chl-new_chl;
% Zeu_first= difference;
%����������ȡ����ַ�����K490��Ctot
Zeu_k490= 3.512./kd;

Ctot=40.2*chl.^0.507;
Ctot(chl<1.0)=38.0*chl(chl<1.0).^0.425;
Zeu_Ctot=568.2*(Ctot.^(-0.746));
Zeu_Ctot(Ctot< 9.9)=200*(Ctot(Ctot< 9.9).^(-0.293));
%------------------------ͼ���ע��--------------------------------
[pathstr, chlname, ext, versn]= fileparts(chlorfile);
start_time= double(str2double(chlname(2:8)));%��ʼʱ��
end_time= double(str2double(chlname(9:15)));%��ֹʱ��
result=day2date(start_time);
month_anno= result(2);
year_anno= result(1);
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%γ�ȵ��ܷ�Χ
lons_range= X(range(3):range(4));%���ȵ��ܷ�Χ
%-------------------------------------dl----------------------------
dl=0;

for i=1:size(lats_range,2)
    dl_tmp=0;
    for j=1:(end_time-start_time+1)
        result= day2date(start_time+j);
        year_=result(1);
        month= result(2);
        date= result(3);
        dl_tmp= dl_tmp+mydl(year_,month,date,lats_range(i))/(end_time-start_time+1);% ������ƽ��dl
    end
	dl=[dl, dl_tmp];
end
dl= dl(2:end);
dl= dl' * ones(1,range(4)-range(3)+1);%��չ����range������һ�¡�
%-------------------------------------dl----------------------------
%---------------------------------��ȡ����-------------------
% chl_copy=chl;
% chl_copy(chl==-32767)=nan;
% new_chl(chl==-32767)=nan;
% x=[122.800,122.633,127.300,125.500,126.133];
% y=[31.633,31.000,28.433,29.250,31.433];
% x_pixel=round((x-lons_range(1))/0.0833333);
% y_pixel=size(lats_range,2)-round((y-lats_range(end))/0.0833333);
% % datas= new_chl(x_pixel,y_pixel);
% datas=0;
% for k=1:size(x,2) 
%     datas= [datas, new_chl(y_pixel(k),x_pixel(k))];
% end
% datas=datas(2:end);
% result= [x',y',datas']
% % subset= new_chl(min(min(x_pixel)):max(max(x_pixel)),...
% %                 min(min(y_pixel))-50:max(max(y_pixel)));            
% subset= new_chl(y_pixel(1)-20:y_pixel(1)+20,x_pixel(1)-20:x_pixel(1)+20);
% figure(2)          ;
% h=imagesc(subset);
% set(h, 'alphadata', ~isnan(subset));
% pause;
%--------------------------------------------------------
sst(sst==-2)=nan;
Zeu_first=dl;
Zeu_first(chl==-32767)=nan;
scale=600/max(max(size(chl)));%�������
figure( 'Position',[50,50,scale*size(Zeu_first,2),scale*size(Zeu_first,1)]);
    h=imagesc(Zeu_first);
    set(h, 'alphadata', ~isnan(Zeu_first));
%     caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('���ճ��� of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(Zeu_first,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(Zeu_first,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(Zeu_first,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(Zeu_first,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))});
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
stop
    
    
    
    
    
    
    
    
    
    
    
    %����sst����
% sst= load_hdf_chinasea(sstfile, range(1),range(2),range(3),range(4));
file_info= hdfinfo(sst_200002);
sst_sds_info=file_info.SDS;
sst_sds_info= sst_sds_info(1,1);
sst= hdfread(sst_sds_info);
sst(sst==65535)=nan;
sst= sst(range(1):range(2),range(3):range(4));% ��ȡSST�����ݡ�
sst= single(sst);
disp(file_info.Attributes(54).Name);
disp(file_info.Attributes(54).Value);%������ʽ
slope=double(file_info.Attributes(55).Value);%������ʽ�еĲ���
intercept=double(file_info.Attributes(56).Value);%������ʽ�еĲ���
sst= slope*sst+intercept;%����ת����ʽ�μ�file_info.Attributes(54).Value.
sst= single(sst);
sst(chl<0)=nan;
Zeu_first=sst;
Zeu_first(chl==-32767)=nan;
scale=600/max(max(size(chl)));%�������
figure( 'Position',[50,50,scale*size(Zeu_first,2),scale*size(Zeu_first,1)]);
    h=imagesc(Zeu_first);
    set(h, 'alphadata', ~isnan(Zeu_first));
%     caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Chl of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(Zeu_first,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(Zeu_first,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(Zeu_first,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(Zeu_first,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
