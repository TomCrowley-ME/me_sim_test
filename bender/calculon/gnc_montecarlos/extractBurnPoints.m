function [istart1burn, istop1burn, istart2burn] = extractBurnPoints( act_f_n )

istart1burn=find(act_f_n>5,1,'first');
if isempty(istart1burn)
    % no burn, put them all together so they're 0 length
    istart1burn=length(act_f_n);
end
istop1burn=find(act_f_n(istart1burn:end)<5,1,'first');
if isempty(istop1burn)
    istop1burn=length(act_f_n);
else
    istop1burn=istop1burn+istart1burn-1;
end
istart2burn=find(act_f_n(istop1burn:end)>5,1,'first');
if isempty(istart2burn)
    istart2burn=length(act_f_n);
else
    istart2burn=istart2burn+istop1burn-1;
end