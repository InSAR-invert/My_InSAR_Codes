% ������chla��δ������chla����VGPMģ�͵ó���OPP
% ָ���ļ�·��
clear;
clc;
chlorfile= 'D:\myfiles\Yatou_paper\Data\200309\S20032442003273.L3m_MO_CHL_chlor_a_9km';
kdfile= 'D:\myfiles\Yatou_paper\Data\200309\S20032442003273.L3m_MO_KD490_Kd_490_9km';
parfile= 'D:\myfiles\Yatou_paper\Data\200309\S20032442003273.L3m_MO_PAR_par_9km';
sstfile= 'D:\myfiles\Yatou_paper\Data\200309\A20032442003273.L3m_MO_SST_9';
% chlorfile= 'D:\myfiles\Yatou_paper\Data\chl\S20000322000060.L3m_MO_CHL_chlor_a_9km';
% kdfile= 'D:\myfiles\Yatou_paper\Data\kd490\S20000322000060.L3m_MO_KD490_Kd_490_9km';
% parfile= 'D:\myfiles\Yatou_paper\Data\par\S20000322000060.L3m_MO_PAR_par_9km';
% sstfile= 'D:\myfiles\Yatou_paper\Data\sst\T20000322000060.L3m_MO_SST_9';
result_path= 'D:\myfiles\Yatou_paper\result';
%-----------------------����opp-vgpm---------------------------------
% ��ȡ����
range=[598,812,3566,3696];%[598,812,3566,3696];%�ü�������
chl= load_hdf_chinasea(chlorfile,range(1),range(2),range(3),range(4));
chl= double(chl); chl(chl==-32767)=nan;
kd= load_hdf_chinasea(kdfile, range(1),range(2),range(3),range(4));
kd= double(kd); kd(kd==-32767)=nan;
PAR= load_hdf_chinasea(parfile, range(1),range(2),range(3),range(4));
PAR= double(PAR); PAR(PAR==-32767)=nan;
%����sst����
% sst= load_hdf_chinasea(sstfile, range(1),range(2),range(3),range(4));
file_info= hdfinfo(sstfile);
sst_sds_info=file_info.SDS;
sst_sds_info= sst_sds_info(1,1);
sst= hdfread(sst_sds_info);
sst= sst(range(1):range(2),range(3):range(4));% ��ȡSST�����ݡ�
sst= double(sst); sst(sst==65535)=nan;
% disp(file_info.Attributes(54).Name);
% disp(file_info.Attributes(54).Value);%������ʽ
slope=double(file_info.Attributes(55).Value);%������ʽ�еĲ���
intercept=double(file_info.Attributes(56).Value);%������ʽ�еĲ���
sst= slope*sst+intercept;%����ת����ʽ�μ�file_info.Attributes(54).Value.

% �������ʱ��dl
% ���Ȼ�ȡÿ�����γ�ȡ�
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%γ�ȵ��ܷ�Χ
lons_range= X(range(3):range(4));%���ȵ��ܷ�Χ
% ���ļ�����ȡ��������
[pathstr, chlname, ext, versn]= fileparts(chlorfile);
start_time= double(str2double(chlname(2:8)));%��ʼʱ��
end_time= double(str2double(chlname(9:15)));%��ֹʱ��
result=day2date(start_time);
month_anno= result(2);
year_anno= result(1);
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
scale=600/max(max(size(chl)));%�������
%-------------------------------------------------------------------------
% % ʹ���޸Ľ���VGPMģ�ͼ���OPP
% opp_vgpm_orig= vgpm_no_improve(chl,sst,kd,dl,PAR);
% opp_vgpm_orig(opp_vgpm_orig<0)=nan;
% opp_vgpm_orig(chl == -32767)=nan;
% ʹ��VGPMģ�ͼ���OPP
new_chl= 4.04672*log((chl+10.02913)/9.62471);
% chl= new_chl;
opp_vgpm_noimprove= vgpm(chl,sst,dl,PAR);

opp_vgpm_improve= vgpm(new_chl, sst, dl, PAR);








%--------------------------------------------------------

    
%�ڶ�������
scale=600/max(max(size(opp_vgpm_improve)));%�������
figure( 'Position',[50,50,scale*size(opp_vgpm_improve,2),scale*size(opp_vgpm_improve,1)]);
    h=imagesc(opp_vgpm_improve);
    set(h, 'alphadata', ~isnan(opp_vgpm_improve));
%     caxis(data_range);
    data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('OPP(Improved Chlo.) of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_vgpm_improve,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp_vgpm_improve,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp_vgpm_improve,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp_vgpm_improve,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
%     close all;

% ��һ������
scale=600/max(max(size(opp_vgpm_noimprove)));%�������
figure( 'Position',[50,50,scale*size(opp_vgpm_noimprove,2),scale*size(opp_vgpm_noimprove,1)]);
    h=imagesc(opp_vgpm_noimprove);
    set(h, 'alphadata', ~isnan(opp_vgpm_noimprove));
%     data_range= caxis;
%     data_range(2)= 5000;
    caxis(data_range);
    % set(gcf, 'Color', [1,1,1])
    name= strcat('OPP(Orig. Chlo.) of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_vgpm_noimprove,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp_vgpm_noimprove,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp_vgpm_noimprove,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp_vgpm_noimprove,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
%     close all;