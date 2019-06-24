function run_TRUST_fit(src,subj_id)
% dS is the signal decay acquired at each echo in the Saggital Sinus
% TE is the effective echo time and is currently hard coded

srcout=[src '/derivatives/' subj_id '/'];

TE = [0 40 80 160]'./1000; % effective echo time in ms

%% Fit exponential to signal in Sag Sinus

dS = load ([srcout subj_id '_trust_mean_tc.txt']);

dS = dS([1 2 3 5]); % ignore eTE at 120ms
dS = dS(:);

f = fit(TE,dS,'exp1');

%% Calc R2b
R1b = 1/1.624; %t1 of blood assumed to be 1624ms
%t2b = 1/((1/t1b)-(f.b));
R2b = R1b-f.b;
Y = R2_to_Y_converter(R2b);

disp(['T2 of blood measured as ' num2str(round(1000/R2b,2)) 'ms'])
disp(['Yv of blood measured as ' num2str(round(Y*100,0)) '%'])
disp(['OEF measured as ' num2str(round(100-Y*100,0)) '%'])

dlmwrite([srcout subj_id '_trust_T2b.txt'],1000/R2b);
dlmwrite([srcout subj_id '_trust_Yv.txt'],Y);

function Y = R2_to_Y_converter(R2b)

%% Taken from "Qin et al. MRM 65:471 (2011)"
% assumes Hct between 0.40 - 0.46
% A = 7.18;
% C = 59.6;
% Y = 1-sqrt(((1./T2)-A)./C);


%% Taken from "Lu et al. MRM 67:42 (2012)"
%  these are values specifically for tau_cpmg = 10 ms
%  Hct between 
a1 = -13.5; % [s-1]
a2 = 80.2;  % [s-1]
a3 = -75.9; % [s-1]
b1 = -0.5;  % [s-1]
b2 = 3.4;   % [s-1]
c1 = 247.4; % [s-1]
hct = 0.42;

A = a1 + a2*hct + a3*hct^2;
B = b1*hct + b2*hct^2;
C = c1*hct*(1 - hct);

r = roots([C B A-R2b]);

x = r( r>=0 );

if length(x) == 1
    Y = 1-x;
else
    fprintf('Root of quadratic equation problematic')
end

return;