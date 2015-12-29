function dout = stretchMultiData( d, cols )

n=floor(size(d,2)/cols);

if n*cols ~= size(d,2)
    error('matrix column size does not match integer')
end

dout=zeros(size(d,1)*n,cols);

for i=1:cols
    dout(:,i)=reshape(d(:,i:cols:end)',size(d,1)*n,1);
end
