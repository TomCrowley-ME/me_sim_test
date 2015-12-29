function c=m3dtimesv(a,b)
c=zeros(size(b,1),size(a,3));

for i3=1:size(a,3)
    c(:,i3)=a(:,:,i3)*b(:,i3);
end
