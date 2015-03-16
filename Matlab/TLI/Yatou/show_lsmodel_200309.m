% չʾ2003��9�µ���С����ģ�ͽ��
infile='D:\myfiles\Yatou_paper\result\data\S20032442003273-opp(LS).mat';
load(infile, 'opp_ls');

% ������ͼ��Ϣ
range=[598,812,3566,3696];%[598,812,3566,3696];%�ü�������

[pathstr, chlname, ext, versn]= fileparts(infile);
start_time= double(str2double(chlname(2:8)));%��ʼʱ��
end_time= double(str2double(chlname(9:15)));%��ֹʱ��
result=day2date(start_time);
month_anno= result(2);
year_anno= result(1);
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%γ�ȵ��ܷ�Χ
lons_range= X(range(3):range(4));%���ȵ��ܷ�Χ

% ��ͼ
scale=600/max(max(size(opp_ls)));%�������
figure( 'Position',[50,50,scale*size(opp_ls,2),scale*size(opp_ls,1)]);
    h=imagesc(opp_ls);
    set(h, 'alphadata', ~isnan(opp_ls));
%     caxis(data_range);
    data_range= caxis;
    data_range(2)= 1000;
    caxis(data_range);
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp(LS model) of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_ls,2)/x_ticks;  %����x�����������������ʾһ���̶ȡ�
    y_step=size(opp_ls,1)/y_ticks;  %����y�����������������ʾһ���̶ȡ�
    xtick_loc= round(1:x_step:size(opp_ls,2));%����x��������ʾ�̶ȵ�λ�á�
    ytick_loc= round(1:y_step:size(opp_ls,1));%����y��������ʾ�̶ȵ�λ�á�
    set(gca, 'XTick', xtick_loc);% ����x������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'YTick', ytick_loc);% ����y������Ҫ��ʾ�Ŀ̶�ֵ��
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
