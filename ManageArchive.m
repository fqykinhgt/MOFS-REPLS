function Archive = ManageArchive(Archive,Population,opt)
    %由于本文采用双存档，所以使用opt操作选择要管理的存档
    global Global;
    switch opt
        case 'AccArchive'   %管理AccArchive存档
            tempArchive=[Archive;Population];
            Archive=[];
            tempCost=[tempArchive.obj]';
            idx=unique(tempCost(:,1));
            for i=1:size(idx,1)
                Costi=tempCost(tempCost(:,1)==idx(i),:);
                tPop=tempArchive(tempCost(:,1)==idx(i),:);
                [~,idxi]=min(Costi(:,2));
                Archive=[Archive;tPop(idxi(1))];
            end

            
        case 'NdArchive'    %管理NdArchive存档
            newPopulation=NDSort([Population;Archive]);
            NDRank=[newPopulation.rank];%获取每个个体的非支配等级
            Archive=newPopulation(NDRank==1);
    end
    if size(Archive,1)>Global.N %对存档进行管理
        while size(Archive,1)>Global.N
            tempCost=[Archive.obj]';
            idx=sort(tempCost(:,1));
            CrowDist=zeros(1,size(idx,1));
            for i=2:size(idx,1)-1
                CrowDist(i)=idx(i)-idx(i-1)+idx(i+1)-idx(i);
            end
            CrowDist(1)=Inf;
            CrowDist(end)=Inf;
            idx=find(CrowDist==min(CrowDist));
            Archive(idx(1),:)=[];
        end
    end
end

