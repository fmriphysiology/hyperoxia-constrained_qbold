function run_sqBOLD_analysis(src,subj_id)

% PROCESS GASE DATA

%% Load dataset
[r2p_data,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_merge_mcf_sm']);
[x y z v] = size(r2p_data);
tau_ms1=(-15:3:66); % gase tau values
tau_ms2=(15:3:66); %gase_long_tau values
tau_ms3=zeros(1,11); %gase_spin_echo_repeats values
tau_ms=[tau_ms1 tau_ms2 tau_ms3];

mask=read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_merge_ref_bet']);
mask=mask>0;

% Check that tau matches the number of volumes 
if (length(tau_ms) ~= v)
    disp('List of Tau values doesn''t match the number of volumes') 
    sprintf('Number of volumes = %1.0f', v)
    return;
end

% X
% Convert tau to seconds
tau_ms = tau_ms(:);
tau = tau_ms.*10^-3;
Tc = 15e-3; % cutoff time for monoexponential regime [s]
num_long_tau = 18; % only pick up the first 18 taus of gase
tau_index = find(tau >= Tc,num_long_tau,'first'); % tau's to be used for R2' fitting  
num_tau_zero = 12; % pick up all 12 tau=0 images
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

p = lscov(X,Y);

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

% SAVE OUT MAPS

save_avw(r2p, [src '/derivatives/' subj_id '/' subj_id '_sqbold_r2p'], 'f', scales)
save_avw(v, [src '/derivatives/' subj_id '/' subj_id '_sqbold_dbv'], 'f', scales)
save_avw(oef, [src '/derivatives/' subj_id '/' subj_id '_sqbold_oef'], 'f', scales)

%keyboard;