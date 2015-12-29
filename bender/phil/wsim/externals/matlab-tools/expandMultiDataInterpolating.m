function tout = expandMultiDataInterpolating( t, n )

flip=size(t,1)==1;

if flip
    t=t';
end

rowstotal=length(t)*n;
index=(1:rowstotal)';
tout=interp1(1:n:rowstotal,t, index,'linear','extrap' );

if flip
    tout=tout';
end
