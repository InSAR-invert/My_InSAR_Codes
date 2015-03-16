

clear;
clc;
% ָ���ļ�·��
chlorfile= 'D:\myfiles\Yatou_paper\Data\chl\S20032442003273.L3m_MO_CHL_chlor_a_9km';
kdfile= 'D:\myfiles\Yatou_paper\Data\kd490\S20032442003273.L3m_MO_KD490_Kd_490_9km';
parfile= 'D:\myfiles\Yatou_paper\Data\par\S20032442003273.L3m_MO_PAR_par_9km';
sstfile= 'D:\myfiles\Yatou_paper\Data\sst\T20032442003273.L3m_MO_SST_9';
output_data_path= 'D:\myfiles\Yatou_paper\result';
result_path= output_data_path;
% ��ȡ����
range=[598,812,3566,3696];%[598,812,3566,3696];%�ü�������
chl= load_hdf_chinasea(chlorfile,range(1),range(2),range(3),range(4));
kd= load_hdf_chinasea(kdfile, range(1),range(2),range(3),range(4));
PAR= load_hdf_chinasea(parfile, range(1),range(2),range(3),range(4));
%����sst����
% sst= load_hdf_chinasea(sstfile, range(1),range(2),range(3),range(4));
file_info= hdfinfo(sstfile);
sst_sds_info=file_info.SDS;
sst_sds_info= sst_sds_info(1,1);
sst= hdfread(sst_sds_info);
sst= sst(range(1):range(2),range(3):range(4));% ��ȡSST�����ݡ�
sst= single(sst);
disp(file_info.Attributes(54).Name);
disp(file_info.Attributes(54).Value);%������ʽ
slope=double(file_info.Attributes(55).Value);%������ʽ�еĲ���
intercept=double(file_info.Attributes(56).Value);%������ʽ�еĲ���
sst= slope*sst+intercept;%����ת����ʽ�μ�file_info.Attributes(54).Value.
sst= single(sst);

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
        result= day2date(start_time+j-1);
        year_=result(1);
        month= result(2);
        date= result(3);
        dl_tmp= dl_tmp+mydl(year_,month,date,lats_range(i))/(end_time-start_time+1);%/size(lats_range,2);% ������ƽ��dl
    end
	dl=[dl, dl_tmp];
end
dl= dl(2:end);
dl= dl' * ones(1,range(4)-range(3)+1);%��չ����range������һ�¡�
scale=600/max(max(size(chl)));%�������
%-------------------------------------------------------------------------
% % ʹ��VGPMģ�ͼ���OPP
% if chl< 1.0
% Ctot=38.0*chl.^0.425;
% else
% Ctot=40.2*chl.^0.507;
% end
% 
% if Ctot< 9.9
% Zeu=200*(Ctot.^(-0.293));
% else 
% Zeu=568.2*(Ctot.^(-0.746));
% end
% 
% 
% if sst < -1.0
% Popt=1.13;
% elseif sst> 28.5
% Popt=4;
% else
% Popt=1.2956+2.749*0.1*sst+6.17*0.01*(sst).^2-2.05*0.01*(sst).^3+2.462*0.001*(sst).^4-...
%     1.348*0.0001*(sst).^5+3.4132*0.000001*(sst).^6-3.27*0.00000001*(sst).^7;
% end
% Ctot=40.2*chl.^0.507;
% Ctot(chl<1.0)=38.0*chl(chl<1.0).^0.425;
% Zeu=568.2*(Ctot.^(-0.746));
% Zeu(Ctot< 9.9)=200*(Ctot(Ctot< 9.9).^(-0.293));
% Popt=1.2956+2.749*0.1*sst+6.17*0.01*(sst).^2-2.05*0.01*(sst).^3+2.462*0.001*(sst).^4-...
%     1.348*0.0001*(sst).^5+3.4132*0.000001*(sst).^6-3.27*0.00000001*(sst).^7;
% Popt(sst<-1.0)=1.13;
% Popt(sst>28.5)=4;
% opp=0.66125.*Popt.*PAR./(PAR+4.1).*chl.*Zeu.*dl;
% 
% opp(chl==-32767)=nan;

% LS model
  coe=11.8722;
  Popt=1.2956+2.749*0.1*sst+6.17*0.01*(sst).^2-2.05*0.01*(sst).^3+2.462*0.001*(sst).^4-...
    1.348*0.0001*(sst).^5+3.4132*0.000001*(sst).^6-3.27*0.00000001*(sst).^7;
  Popt(sst < -1.0)=1.13;
  Popt(sst> 28.5)=4;
  Popt= single(Popt);
%   chl(chl == -32767)=1000; % change the NaN data to the value of 1000; nan.^0.1 makes a complex
chl_c=chl;
chl_c(chl==-32767)=nan;  

%������Zeu��
Ctot=40.2*chl.^0.507;
Ctot(chl<1.0)=38.0*chl(chl<1.0).^0.425;
Zeu_fine=568.2*(Ctot.^(-0.746));
Zeu_fine(Ctot< 9.9)=200*(Ctot(Ctot< 9.9).^(-0.293));
sd_fine= Zeu_fine/2.53;

%δ������Zeu
Zeu= kd;
  sd= Zeu/2.53;
  %����X
  X= 0.3+(chl_c-1.5)*2.2./8.5;
  X(chl_c <=1.5)=0.3;
  X(chl_c >=2.5)=2.5;
  
  chleu=0.9899*(chl_c.^0.734);
  
  opp_ls= coe*(0.11-0.037*log10(PAR)).*Popt.*chleu.*sd.*PAR.*dl.*(chl_c./(chl_c+X));
%   opp_ls= coe*(0.11-0.037*log10(PAR(ind))).*Popt(ind).*chleu(ind).*sd(ind).*PAR(ind).*dl(ind).*(chl_c(ind)./(chl_c(ind)+X(ind)));
% opp_ls= coe*(0.11-0.037*(PAR)).*Popt.*chleu.*sd.*PAR.*dl.*(chl_c./(chl_c+X));  
opp_ls(chl==-32767)=nan;
  opp_ls(PAR==-32767)=nan;
    
    
    
    
    
    opp=opp_ls;
    for i=1:100
        opp(opp==max(max(opp)))=nan;
    end
% % %-------------------------------------------------------------------------
figure( 'Position',[50,50,scale*size(opp,2),scale*size(opp,1)]);
    h=imagesc(opp);
    set(h, 'alphadata', ~isnan(opp));
%     caxis(data_range);
    data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('OPP(LS) of month:', num2str(month_anno),'/',num2str(year_anno), '(mg C m^-^2 day^-^1)');
%     name= strcat('OPP(LS Model) of month:', num2str(month_anno),'/',num2str(year_anno), '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))});
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    % ����ͼƬ
    outname= strcat(result_path, '\bmps\',chlname,'-opp(ls_no_mod).bmp');
    saveas(gcf, outname);    
% 
%     %-------------------------------------------------------------------------
% 
%     %��ͼ
%     figure( 'Position',[50,50,scale*size(opp_vgpm,2),scale*size(opp_vgpm,1)]);
%     h=imagesc(opp_vgpm);
%     set(h, 'alphadata', ~isnan(opp_vgpm));
%     caxis(data_range);
%     % set(gcf, 'Color', [1,1,1])
%     name= strcat('OPP(VGPM) of month:', num2str(month_anno),'/',num2str(year_anno), '(mg C m^-^2 day^-^1)');
%     title(name,'fontsize',8);
%     colorbar;
%     x_ticks=5;
%     y_ticks=5;
%     x_step=size(opp_vgpm,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
%     y_step=size(opp_vgpm,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
%     xtick_loc= round(1:x_step:size(opp_vgpm,2));%����x��������ʾ�̶ȵ�λ�á�
%     ytick_loc= round(1:y_step:size(opp_vgpm,1));%����y��������ʾ�̶ȵ�λ�á�
%     set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
%     set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
%     set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
%     set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
%     xlabel ('Longitude(E)','fontsize',10);
%     ylabel ('Latitude(N)','fontsize',10);
%     % ����ͼƬ
%     outname= strcat(result_path, '\bmps\',chlname,'-opp(vgpm).bmp');
%     saveas(gcf, outname);
%     %----------------------------------------------------------------------
%  
%    %-------------------------------------------------------------------------
% 
%     %��ͼ
%     delta= opp_ls-opp_vgpm;
%     figure( 'Position',[50,50,scale*size(delta,2),scale*size(delta,1)]);
%     h=imagesc(delta);
%     set(h, 'alphadata', ~isnan(delta));
%     caxis(data_range);
%     % set(gcf, 'Color', [1,1,1])
%     name= strcat('OPP difference of month:', num2str(month_anno),'/',num2str(year_anno), '(mg C m^-^2 day^-^1)');
%     title(name,'fontsize',8);
%     colorbar;
%     x_ticks=5;
%     y_ticks=5;
%     x_step=size(opp_vgpm,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
%     y_step=size(opp_vgpm,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
%     xtick_loc= round(1:x_step:size(opp_vgpm,2));%����x��������ʾ�̶ȵ�λ�á�
%     ytick_loc= round(1:y_step:size(opp_vgpm,1));%����y��������ʾ�̶ȵ�λ�á�
%     set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
%     set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
%     set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
%     set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
%     xlabel ('Longitude(E)','fontsize',10);
%     ylabel ('Latitude(N)','fontsize',10);
%     % ����ͼƬ
%     outname= strcat(result_path, '\bmps\',chlname,'-opp(vgpm).bmp');
%     saveas(gcf, outname);

% close all;