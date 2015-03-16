% 2003�꣬1/4/7/10�ĸ��·ݵ�OPP�ֲ���
clear;
clc;
infile_file1= 'D:\myfiles\Yatou_paper\result\data\S20030012003031-opp(VGPM).mat';
infile_file4='D:\myfiles\Yatou_paper\result\data\S20031212003151-opp(VGPM).mat';
infile_file7='D:\myfiles\Yatou_paper\result\data\S20031822003212-opp(VGPM).mat';
infile_file10='D:\myfiles\Yatou_paper\result\data\S20032742003304-opp(VGPM).mat';
result_path='D:\myfiles\Yatou_paper\result';
load(infile_file1, 'opp_vgpm');
opp_spring= opp_vgpm;
load(infile_file4, 'opp_vgpm');
opp_summer= opp_vgpm;
load(infile_file7, 'opp_vgpm');
opp_autumn= opp_vgpm;
load(infile_file10, 'opp_vgpm');
opp_winter= opp_vgpm;
%������ͼ��Ϣ
% [pathstr, chlname, ext, versn]= fileparts(chlorfile);
% start_time= double(str2double(chlname(2:8)));%��ʼʱ��
% end_time= double(str2double(chlname(9:15)));%��ֹʱ��
% result=day2date(start_time);
% month_anno= result(2);
% year_anno= result(1);
range=[598,812,3566,3696];
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%γ�ȵ��ܷ�Χ
lons_range= X(range(3):range(4));%���ȵ��ܷ�Χ

%--------------------------------��ͼ-----------------------
scale=600/max(max(size(opp_vgpm)));%�������
% ��
figure( 'Position',[50,50,scale*size(opp_autumn,2),scale*size(opp_autumn,1)]);
    h=imagesc(opp_autumn);
    set(h, 'alphadata', ~isnan(opp_autumn));
%     caxis(data_range);
    data_range= caxis;
    data_range(2)= 4500;
    caxis(data_range);
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp of month: 07/2003  ', '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_spring,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp_spring,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp_spring,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp_spring,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\2003��7��opp.bmp');
    saveas(gcf, outname);
% ��
figure( 'Position',[50,50,scale*size(opp_spring,2),scale*size(opp_spring,1)]);
    h=imagesc(opp_spring);
    set(h, 'alphadata', ~isnan(opp_spring));
    caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp of month: 01/2003  ', '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_spring,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp_spring,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp_spring,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp_spring,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\2003��1��opp.bmp');
    saveas(gcf, outname);
% ��
figure( 'Position',[50,50,scale*size(opp_summer,2),scale*size(opp_summer,1)]);
    h=imagesc(opp_summer);
    set(h, 'alphadata', ~isnan(opp_summer));
    caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp of month: 04/2003  ', '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_spring,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp_spring,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp_spring,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp_spring,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\2003��5��opp.bmp');
    saveas(gcf, outname);

% ��
figure( 'Position',[50,50,scale*size(opp_winter,2),scale*size(opp_winter,1)]);
    h=imagesc(opp_winter);
    set(h, 'alphadata', ~isnan(opp_winter));
    caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp of month: 10/2003  ', '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_spring,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp_spring,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp_spring,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp_spring,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\2003��10��opp.bmp');
    saveas(gcf, outname);
    pause;
    close all;