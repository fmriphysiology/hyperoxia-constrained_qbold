function run_hqBOLD_analysis_mod(src,subj_id)

% PROCESS GASE DATA

%% Load dataset
%[r2p_data,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_long_tau_mcf_sm']);
[r2p_data,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_merge_mcf_sm']);
r2p_data = r2p_data(:,:,:,29:46);
[x y z v] = size(r2p_data);
tau_ms=(15:3:66);

mask=read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_long_tau_ref_bet']);
mask=mask>0;

% Check that tau matches the number of volumes 
if (length(tau_ms) ~= v)
    disp('List of Tau values doesn''t match the number of volumes') 
    %disp(tau)
    sprintf('Number of volumes = %1.0f', v)
    return;
end

% X
% Convert tau to seconds
%tau = [start_tau:delta_tau:end_tau];
tau_ms = tau_ms(:);
tau = tau_ms.*10^-3;
Tc = 15e-3; % cutoff time for monoexponential regime [s]
tau_index = find(tau >= Tc); % tau's to be used for R2' fitting  

X = [ones(size(tau(tau_index))) -tau(tau_index)];

% Y
r2p_data=reshape(r2p_data,x*y*z,v);
ln_Sase = log(r2p_data); 
ln_Sase(isnan(ln_Sase)) = 0; 
ln_Sase(isinf(ln_Sase)) = 0;

Y = ln_Sase';

% vvvv currently no weighting
w = ones(size(1./tau(tau_index))); % weightings for lscov

p = lscov(X,Y,w);

%for k=1:size(Y,2)
%p(:,k) = lsqnonneg(X,Y(:,k));
%fprintf('.');
%end

s0=reshape(p(1,:),x,y,z).*mask;
r2p=reshape(p(2,:),x,y,z).*mask;

% PROCESS BOLD DATA

%% Load dataset
[bold_data,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_bold_mcf_reg_sm']);
[x y z v] = size(bold_data);

% load ET's
et_o2_co2 = load([src '/' subj_id '/func-bold/' subj_id '_bold_et_o2_co2.trace']);
et_t = et_o2_co2(:,1);
et_co2 = et_o2_co2(:,2);
et_o2 = et_o2_co2(:,3);

% repetition time
tr = 1; % [sec] 
t = (1:300)' .* tr; 

% interpolate end-tidal values 
et_o2 = interp1((et_t-et_t(1)).*60, et_o2, t);
et_co2 = interp1((et_t-et_t(1)).*60, et_co2, t);

et_o2_sm = conv((et_o2-mean(et_o2(1:100)))./max(et_o2-mean(et_o2(1:100))),gampdf(0:0.1:60,1,3));
% X
%X = [ones(size(t)) (et_o2-mean(et_o2(1:100)))./max(et_o2-mean(et_o2(1:100)))];
X = [ones(size(t)) et_o2_sm(1:300)'./max(et_o2_sm(1:300))];
stim=(t>=160).*(t<=260)+(t>130).*(t<160).*(t-130)./30-(t>260).*(t<290).*(t-260)/30+(t>260).*(t<290);
X2 = [ones(size(t)) stim];

% Y
Y1 = reshape(bold_data,x*y*z,v)';
Y1 = Y1(1:300,:);
Y2 = et_o2;

p = lscov(X,Y1);

%for k=1:size(Y,2)
%p(:,k) = lsqnonneg(X,Y1(:,k));
%fprintf('.');
%end

dbold=reshape(p(2,:)./p(1,:),x,y,z);

p = lscov(X2,Y2);

pao2=p(1);
dpao2=p(2);
pao2=mean(Y2(1:100));
dpao2=mean(Y2(175:225))-pao2;

A = 27;
B = 0.2;
C = 245.1;
D = 0.1;
TE = 35;

v = ((A/TE + B) * (C/dpao2 +D)) .* dbold;
v = v.*mask;

% CALCULATE OEF/[dHb] USING V %

dChi0 = 0.264e-6;
Hct = 0.34;
B0 = 3;
k=0.03;
gamma=2.*pi.*42.58e6;

oef = r2p./(v.*gamma.*(4./3).*pi.*dChi0.*Hct.*B0).*mask;
%dhb = r2p./(v.*gamma.*(4./3).*pi.*dChi0.*B0.*k).*masks;

%keyboard;
% SAVE OUT MAPS

%s=regexp(r2p_fname,'_');

save_avw(r2p, [src '/derivatives/' subj_id '/' subj_id '_hcqbold_r2p_mod'], 'f', scales)
save_avw(v, [src '/derivatives/' subj_id '/' subj_id '_hcqbold_dbv_mod'], 'f', scales)
save_avw(oef, [src '/derivatives/' subj_id '/' subj_id '_hcqbold_oef_mod'], 'f', scales)
%save_avw(dhb, [src '/derivatives/' subj_id '/' subj_id '_hcqbold_dhb'], 'f', scales)

%keyboard;