function tempPop=CoreCode(Pop_i,Archive,opt,adapter)
    global Global;
    tempPop=Pop_i;
    %随机在存档中选择一个领导者个体
    popDec=Pop_i.dec;
    popCost=Pop_i.obj';
    ArchCost=[Archive.obj]';
    Comb=[popCost;ArchCost];
    Comb(:,1)=(Comb(:,1)-min(Comb(:,1)))./(max(Comb(:,1))-min(Comb(:,1)));
    distances = pdist2(Comb(1,:), Comb(2:end,:));
    [~,Dist_idx]=sort(distances);
    Leader=Archive(Dist_idx(randi([1,min([Global.P1,size(Archive,1)])],1)));
    numF=ceil((1-adapter)*(rand()*Global.D/(3*Global.N)));
    
    switch opt
        case 'stage1'
            Pool=[Leader.dec popDec];
            newP=setdiff(1:Global.D,Pool);
            Pool=[Pool newP(TournamentSelection(Global.Wd(newP),ceil(rand()*Global.D/(Global.N*3))))];
            tempPop.dec=Pool(randperm(size(Pool,2),size(popDec,2)));
        case 'stage2'   %高强度开发阶段
            Pool=setdiff(Leader.dec,popDec);
            if size(Pool,2)==0
                newP=setdiff(1:Global.D,Pool);
                W=Global.Wd(newP);
                [~,idx]=sort(W,'descend');
                newP=newP(idx(1:ceil(Global.D/3)));
                Pool=[Pool newP(TournamentSelection(Global.Wd(newP),2))];
            end

            [~,opt_2]=max(tempPop.opt);%1是增加，2是替换，3是减少
            if size(popDec,2)<=numF
                numF=size(unique(popDec),2);
            end
            if opt_2==3 && numF>=size(unique(popDec),2)
                opt_2=randi([0 1],1)+1;
            end

            if opt_2==1   % 增加特征
                %addF=Pool(TournamentSelection(Global.Wd(Pool),1));
                addF=Pool(randperm(size(Pool,2),numF));
                tempPop.dec=[tempPop.dec addF];
            end
            if opt_2==2   %替换特征
                delF=popDec(TournamentSelection(1-Global.Wd(popDec),numF));
                tempPop.dec=setdiff(tempPop.dec,delF);
                %addF=Pool(TournamentSelection(Global.Wd(Pool),1));
                addF=Pool(randperm(size(Pool,2),numF));
                tempPop.dec=[tempPop.dec addF];
            end
            if opt_2==3 %去除特征
                delF=popDec(TournamentSelection(1-Global.Wd(popDec),numF));
                tempPop.dec=setdiff(tempPop.dec,delF);
            end
            
    end
end

