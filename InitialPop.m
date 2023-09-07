function Population = InitialPop(N,D,Wd)
    %种群的格式与以往的不同，采用可变长度
    %种群的最大长度为D/3
    %该版本还是使用随机初始化，不选择使用过滤方法引导
    interval=D/(3*N);

    Pop.dec=[];%个体
    Pop.obj=[];%记录适应度
    Pop.rank=0;%非支配等级
    Pop.opt=zeros(1,3);
    Population=repmat(Pop,N,1);%定义结构体

    for i=1:N
        SelNum=1+ceil(interval*i);
        Population(i).dec=TournamentSelection(Wd,SelNum);%初始化个体
        Population(i).obj=CalObj(Population(i).dec);%计算个体适应度
        Population(i).opt=rand(1,3);
        Population(i).opt=Population(i).opt./sum(Population(i).opt);
    end
end