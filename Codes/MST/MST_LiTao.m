% MST��С������
% �������õ�ļ������жϱպ�����
% ���ߣ�����
% ���Ͻ�ͨ��ѧPS-InSAR����С��
clc;
clear;
% ������������������ʼ��������������
num=100; % �������Ŀ
plist=[]; % ����������
arcs=[]; % �����б������ʽΪ[[�ο���X��Y]��[������X��Y]]
w=[]; % Ȩ���������Ծ���ΪȨ��
w_coor=[];% ÿ��Ȩ�ض�Ӧ�ĵ������
% ������������������ʼ��������������
% ���������������ɲ���ʾ��������ݡ���������������
b=unidrnd(40000,1,num);% ��������������ֵ40000��ά��1*10
% b=[24839,22949,2084,37249,29147,29514,2537,34418,37377,39376];
if num<2
    disp('�������Ŀ����>=2');
    return;
end
for i=1:num
    plist_line=floor(b(i)/200);
    plist_column=mod(b(i),200);
    plist=[plist;plist_line,plist_column];
end
% plot(plist(:,1),plist(:,2),'or'); % ��ʾ
% ���������������ɲ���ʾ��������ݡ���������������
% ��������������ȡ��������Լ�������Ϣ������������
for i=1:num-1
    for j=i+1:num
        temp=((plist(i,1)-plist(j,1))^2+(plist(i,2)-plist(j,2))^2)^0.5;             
        w=[w;temp];
        w_coor=[w_coor;i,j];
    end
end
% ��������������ȡ��������Լ�������Ϣ������������        
% ��������������ʼ������С����������������������
p_used=struct('p_coor',[]);% �ṹ����������ڴ洢�ù��ĵ㼯
[w,coor]=sort(w);
all_num=num*(num-1)/2;


for j=1:all_num
    p_used_size=size(p_used);
    p_coor=w_coor(coor(j),:); % ��ȡ��j�����ζ�Ӧ�ĵ��    
    for i=1:p_used_size
        all_not_in_set=true;
        ii=find(p_used(i).p_coor==p_coor(1));
        ii=size(ii);
        jj=find(p_used(i).p_coor==p_coor(2));
        jj=size(jj);
        if ii(2)==1  % �ڵ�i���㼯���ҵ��˻������
            all_not_in_set=false;
            if jj(2)==0 % �ڵ�i���㼯��δ�ҵ������յ�
                if i==p_used_size % i�����ĵ㼯
                    p_used(i).p_coor=[p_used(i).p_coor,p_coor(2)];
                else % i�������ĵ㼯
                    for k=1:p_used_size % ���̫���˾����ˣ����񰡣�
                        not_in_set=true;
                        jj=find(p_used(k).p_coor==p_coor(2));
                        jj=size(jj);
                        if jj(2)==1 % �ڵ�k���㼯���ҵ��˻����յ�
                            not_in_set=false;
                            if k~=i                                
                                % �������㼯�ϲ�����i���㼯�в�ɾ����k���㼯��
                                p_used(i).p_coor=[p_used(i).p_coor,p_used(k).p_coor];
                                p_used(i).p_coor=unique(p_used(i).p_coor);
                                p_used(k).p_coor=[];
                                arcs=[arcs;p_coor];
%                                 if k<p_used_size % ���k�������ĵ㼯
%                                     k=k-1;
%                                     p_used_size=p_used_size-1;
%                                 end
                                break; % kѭ�����
                            end 
                        end                        
                    end
                    if not_in_set % ֮��ĵ㼯��δ�ҵ������յ�
                        p_used(i).p_coor=[p_used(i).p_coor,p_coor(2)];
                        arcs=[arcs;p_coor];
                    end
                end
            end
            all_not_in_set=false;
            break; % iѭ�����
        end        
    end
    if all_not_in_set % ���еĵ㼯��δ�ҵ��������
        not_in_set=true;
        for m=1:p_used_size % �Ի����յ�Ϊ������������ 
            jj=find(p_used(m).p_coor==p_coor(2));
            jj=size(jj);
            if jj(2)==1 % �յ��ڵ�m���㼯�б�����
                p_used(m).p_coor=[p_used(m).p_coor,p_coor(1)];
                arcs=[arcs;p_coor];
                not_in_set=false;
                break; % mѭ�����
            end
        end
        if not_in_set % �յ�Ҳû�г������κε㼯��
            % δ�ҵ���ʼ����ֹ�㣬�����µĵ㼯
            temp=struct('p_coor',p_coor);
            p_used=[p_used;temp];
            arcs=[arcs;p_coor];
        end
    end
    arcs_size=size(arcs);
    if arcs_size(2)==num-1
        break;
    end
% arcs'
% disp('����������������ѭ����������������������');
end
% ��������������ͼ������������
% start_p=plist(arcs(:,1),:);
% end_p=plist(arcs(:,2),:);
% plot([start_p(:,1),end_p(:,1)],[start_p(:,2),end_p(:,2)]);
arcs_size=size(arcs);
figure;
axis([0,200,0,200]);
for i=1:arcs_size(1);
    start_p=plist(arcs(i,1),:);
    end_p=plist(arcs(i,2),:);
    plot([start_p(1),end_p(1)],[start_p(2),end_p(2)],'g');
    hold on;

end