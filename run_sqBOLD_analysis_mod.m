function run_sqBOLD_analysis_mod(src,subj_id)

% PROCESS GASE DATA

%% Load dataset
%[r2p_data1,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_mcf_reg_sm']);
%[x1 y1 z1 v1] = size(r2p_data1);
tau_ms1=(-15:3:66);

%[r2p_data2,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_long_tau_mcf_sm']);
%[x2 y2 z2 v2] = size(r2p_data2);
tau_ms2=(15:3:66);

%[r2p_data3,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_spin_echo_repeats_mcf']);
%[x3 y3 z3 v3] = size(r2p_data3);
tau_ms3=zeros(1,11);

%r2p_data=cat(4,r2p_data1,r2p_data2,r2p_data3);
[r2p_data,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_merge_mcf_sm']);
[x y z v] = size(r2p_data);
tau_ms=[tau_ms1 tau_ms2 tau_ms3];

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
num_long_tau = 18;
tau_index = find(tau >= Tc,num_long_tau,'first'); % tau's to be used for R2' fitting  
num_tau_zero = 11;
tau_zero = find(tau == 0,num_tau_zero,'first');

X = [ones(size(tau(tau_index))) -tau(tau_index) ones(size(tau(tau_index)))];
X = [repmat([0 0 1],num_tau_zero,1); X];

% Y
r2p_data=reshape(r2p_data,x*y*z,v);
ln_Sase = log(r2p_data(:,tau_index));
ln_Sase = [log(r2p_data(:,tau_zero)) ln_Sase]; 
ln_Sase(isnan(ln_Sase)) = 0; 
ln_Sase(isinf(ln_Sase)) = 0;

Y = ln_Sase';

% vvvv currently no weighting
w = ones(size(1./[15e-3; tau(tau_index)])); % weightings for lscov

%p = lscov(X,Y,w);
p = lscov(X,Y);

%for k=1:size(Y,2)
%p(:,k) = lsqnonneg(X,Y(:,k));
%fprintf('.');
%end

v=reshape(p(1,:),x,y,z).*mask;
r2p=reshape(p(2,:),x,y,z).*mask;
s0=reshape(p(3,:),x,y,z).*mask;

% CALCULATE OEF/[dHb] USING V %

dChi0 = 0.264e-6;
Hct = 0.34;
B0 = 3;
k=0.03;
gamma=2.*pi.*42.58e6;

oef = r2p./(v.*gamma.*(4./3).*pi.*dChi0.*Hct.*B0).*mask;
%dhb = r2p./(v.*gamma.*(4./3).*pi.*dChi0.*B0.*k).*mask;

% SAVE OUT MAPS

%s=regexp(r2p_fname,'_');

save_avw(r2p, [src '/derivatives/' subj_id '/' subj_id '_sqbold_r2p_mod'], 'f', scales)
save_avw(v, [src '/derivatives/' subj_id '/' subj_id '_sqbold_dbv_mod'], 'f', scales)
save_avw(oef, [src '/derivatives/' subj_id '/' subj_id '_sqbold_oef_mod'], 'f', scales)
%save_avw(dhb, [src '/derivatives/' subj_id '/' subj_id '_sqbold_dhb_mod'], 'f', scales)

%keyboard;