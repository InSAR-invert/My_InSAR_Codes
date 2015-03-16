function result= cal_opp_chinasea_vgpm(chl_file, kd_file, par_file, sst_file, result_path)

% ָ���ļ�·��
chlorfile= chl_file;%'D:\myfiles\Yatou_paper\Data\S20000922000121.L3m_MO_CHL_chlor_a_9km';
kdfile= kd_file;%'D:\myfiles\Yatou_paper\Data\S20000922000121.L3m_MO_KD490_Kd_490_9km';
parfile= par_file;%'D:\myfiles\Yatou_paper\Data\S20000922000121.L3m_MO_PAR_par_9km';
sstfile= sst_file;%'D:\myfiles\Yatou_paper\Data\T20000922000121.L3m_MO_SST_9';
result_path=result_path;%'D:\myfiles\Yatou_paper\result'

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
chl= new_chl;
opp_vgpm= vgpm(chl,sst,dl,PAR);
% opp_vgpm(chl == -32767)=nan;
%---------------------------------------------------
% VGPMģ�͵Ĺ��̲���
if chl< 1.0
Ctot=38.0*chl.^0.425;
else
Ctot=40.2*chl.^0.507;
end

if Ctot< 9.9
Zeu=200*(Ctot.^(-0.293));
else
Zeu=568.2*(Ctot.^(-0.746));
end

    data_outpath= strcat(result_path,'\data\');
    if ~exist(data_outpath)
        mkdir(data_outpath);
    end
    var_outname=strcat(data_outpath, chlname,'-opp(VGPM).mat');
    save(var_outname,'opp_vgpm','sst','chl','Zeu','dl','PAR');
    %load(var_outname,'opp_vgpm','sst','chl','Zeu','dl');
%-------------------------------------------------------------------------     
%-------------------------------------------------------------------------

    %VGPM ��ͼ
    figure( 'Position',[50,50,scale*size(opp_vgpm,2),scale*size(opp_vgpm,1)]);
    h=imagesc(opp_vgpm);
    set(h, 'alphadata', ~isnan(opp_vgpm));
    data_range= [0, 5000]; %ɫ������Χ
    caxis(data_range);% ����ɫ������Χ
    % set(gcf, 'Color', [1,1,1])
    name= strcat('OPP(VGPM) of month:', num2str(month_anno),'/',num2str(year_anno), '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_vgpm,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp_vgpm,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp_vgpm,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp_vgpm,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    % ����ͼƬ
    bmps_outpath= strcat(result_path, '\bmps\');
    if ~exist(bmps_outpath)
        mkdir(bmps_outpath);
    end
    outname= strcat(bmps_outpath,chlname,'-opp(vgpm).bmp');
    saveas(gcf, outname);
close all;