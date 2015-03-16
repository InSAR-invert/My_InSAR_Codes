% ����2000-2010�����е�OPP��
% ���������
clear;
clc;
input_data_path= 'D:\myfiles\Yatou_paper\Data';   % ��·��
output_data_path= 'D:\myfiles\Yatou_paper\result';% ���·��
range= [598,812,3566,3696];                       % �й�����Χ
log_file= strcat(output_data_path, '\log.txt');   % ��־�ļ���·��

chl_path= strcat(input_data_path, '\Chl\');   % chl�ļ���·��
kd_path= strcat(input_data_path, '\KD490\');  % kd490�ļ���·��
par_path= strcat(input_data_path, '\PAR\');   % PAR�ļ���·��
sst_path= strcat(input_data_path, '\AquaSST\');   % SST�ļ���·��
% sst_path= strcat(input_data_path, '\SST\');   % SST�ļ���·��
chl_files= dir(strcat(chl_path,'*.L3m_MO_CHL_chlor_a_9km'));
if exist(log_file)
    delete(log_file);
end
fid= fopen(log_file, 'a');                    %����־�ļ���׼�����롣
for i=1:size(chl_files,1)
    disp(strcat(num2str(i), '/',num2str(size(chl_files,1))));
    chl_file= strcat(chl_path, chl_files(i).name);
    [pathstr, chlname, ext, versn]= fileparts(chl_file);
    kd_file= strcat(kd_path, chlname, '.L3m_MO_KD490_Kd_490_9km');
    par_file= strcat(par_path, chlname, '.L3m_MO_PAR_par_9km');
    sst_file= strcat(sst_path,'A', chlname(2:end), '.L3m_MO_SST_9');
    if ~exist(kd_file)
        fprintf(fid, '%s\r\n',strcat('KD490 file not exist:', kd_file));
        continue;
    end
    if ~exist(par_file)
        fprintf(fid,'%s\r\n', strcat('PAR file not exist:', par_file));
        continue;
    end
    if ~exist(sst_file)
        fprintf(fid,'%s\r\n',strcat('SST file not exist:', sst_file));
        continue;
    end
%     result= cal_opp_chinasea_ls(chl_file, kd_file, par_file, sst_file, output_data_path);%��С����
    result= cal_opp_chinasea_vgpm(chl_file, kd_file, par_file, sst_file,...
    output_data_path);%VGPM
end
fclose(fid);