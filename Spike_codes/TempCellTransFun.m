function y = TempCellTransFun(x)
y1 = cellfun(@(z) cellfun(@single,z,'un',0),x(:,1:4),'un',0);
y = [y1,x(:,5)];