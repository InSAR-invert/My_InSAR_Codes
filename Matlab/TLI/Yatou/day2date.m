function result= day2date(day)
% �����������ת���ɶ�Ӧ�����ڡ�
% ���
year= floor(day/1000);
if(mod(year,4)==0)
    if(mod(year,100)==0)
    if(mod(year,400)==0)
    jm=[31,29,31,30,31,30,31,31,30,31,30,31];
    else
    end
    jm=[31,28,31,30,31,30,31,31,30,31,30,31];
    else
    end
    jm=[31,29,31,30,31,30,31,31,30,31,30,31];
    else
    jm=[31,28,31,30,31,30,31,31,30,31,30,31];
end
% �·�
days= mod(day, 1000);
all_days=0;
for i=1:12
    all_days=all_days+jm(i);
    if all_days >=days
        break;
    end    
end
month=i;
% ����
if all_days == days 
    date= jm(i);
else
    date= jm(i)-(all_days-days);
end
result= [year,month,date];