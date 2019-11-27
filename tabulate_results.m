function [hqbold_oef_hist hqbold_dbv_hist sqbold_oef_hist sqbold_dbv_hist]=tabulate_results(src)

	num_subj=10;

	% Constants
	dChi0 = 0.264e-6;
	Hct = 0.34;
	B0 = 3;
	gamma=2.*pi.*42.58e6;
	kappa=gamma.*(4./3).*pi.*dChi0.*Hct.*B0;

	for k=1:num_subj;

		subj_id=['sub-' sprintf('%02d',k)];
		disp(subj_id);
	
		% Load TRUST results
		Yv=load([src '/derivatives/' subj_id '/' subj_id '_trust_Yv.txt']);
		trust_oef(k,:)=round(100.*(1-Yv),1);
	
		% Load GM and WM ROIs
		gm_roi = read_avw([src '/derivatives/' subj_id '/' subj_id '_gm_cortex']);
		gm_roi = gm_roi(:);
		wm_roi = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_wm_thr']);
		wm_roi = wm_roi(:);
	
		% Load hqBOLD results
		[r2p,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_r2p']);
		r2p = r2p(:);
		dbv = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_dbv']);
		dbv = dbv(:).*100;
		oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_oef']);
		oef = oef(:).*100;
	
		% GM hqBOLD results
		hqbold_r2p_median_gm(k,:) = median(r2p(gm_roi>0),'omitnan');
		hqbold_r2p_iqr_gm(k,:) = iqr(r2p(gm_roi>0));
		hqbold_dbv_median_gm(k,:) = median(dbv(gm_roi>0),'omitnan');
		hqbold_dbv_iqr_gm(k,:) = iqr(dbv(gm_roi>0));
		hqbold_dbv_hist{k} = dbv(find((gm_roi>0).*~isnan(dbv)));
		hqbold_oef_median_gm(k,:) = median(oef(gm_roi>0),'omitnan');
		hqbold_oef_iqr_gm(k,:) = iqr(oef(gm_roi>0));
		hqbold_oef_hist{k} = oef(find((gm_roi>0).*~isnan(oef)));

		% WM hqBOLD results
		hqbold_r2p_median_wm(k,:) = median(r2p(wm_roi>0),'omitnan');
		hqbold_r2p_iqr_wm(k,:) = iqr(r2p(wm_roi>0));
		hqbold_dbv_median_wm(k,:) = median(dbv(wm_roi>0),'omitnan');
		hqbold_dbv_iqr_wm(k,:) = iqr(dbv(wm_roi>0));
		hqbold_oef_median_wm(k,:) = median(oef(wm_roi>0),'omitnan');
		hqbold_oef_iqr_wm(k,:) = iqr(oef(wm_roi>0));

		% Estimate synthetic R2' from hqBLOLD results
		r2p_synth=kappa.*dbv./100.*(1-Yv);
	
		% GM r2psynth results
		synth_r2p_median_gm(k,:) = median(r2p_synth(gm_roi>0),'omitnan');
		synth_r2p_iqr_gm(k,:) = iqr(r2p_synth(gm_roi>0));
		
		% WM r2psynth results
		synth_r2p_median_wm(k,:) = median(r2p_synth(wm_roi>0),'omitnan');
		synth_r2p_iqr_wm(k,:) = iqr(r2p_synth(wm_roi>0));		

		% Load sqBOLD results 
		[r2p,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_r2p']);
		r2p = r2p(:);
		dbv = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_dbv']);
		dbv = dbv(:).*100;
		oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_oef']);
		oef = oef(:).*100;
		
		% GM sqBOLD results
		sqbold_r2p_median_gm(k,:) = median(r2p(gm_roi>0),'omitnan');
		sqbold_r2p_iqr_gm(k,:) = iqr(r2p(gm_roi>0));
		sqbold_dbv_median_gm(k,:) = median(dbv(gm_roi>0),'omitnan');
		sqbold_dbv_iqr_gm(k,:) = iqr(dbv(gm_roi>0));
		sqbold_dbv_hist{k} = dbv(find((gm_roi>0).*~isnan(dbv)));
		sqbold_oef_median_gm(k,:) = median(oef(gm_roi>0),'omitnan');
		sqbold_oef_iqr_gm(k,:) = iqr(oef(gm_roi>0));
		sqbold_oef_hist{k} = oef(find((gm_roi>0).*~isnan(oef)));

		% WM sqBOLD results
		sqbold_r2p_median_wm(k,:) = median(r2p(wm_roi>0),'omitnan');
		sqbold_r2p_iqr_wm(k,:) = iqr(r2p(wm_roi>0));
		sqbold_dbv_median_wm(k,:) = median(dbv(wm_roi>0),'omitnan');
		sqbold_dbv_iqr_wm(k,:) = iqr(dbv(wm_roi>0));
		sqbold_oef_median_wm(k,:) = median(oef(wm_roi>0),'omitnan');
		sqbold_oef_iqr_wm(k,:) = iqr(oef(wm_roi>0));
		
	end
	
		
	subj={'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'mean';'stdev'};
			
	% Group averages - comparison of GM sqBOLD vs hqBOLD vs TRUST
	hqbold_dbv_median_gm(11) = mean(hqbold_dbv_median_gm(1:10));
	hqbold_dbv_median_gm(12) = std(hqbold_dbv_median_gm(1:10));
	hqbold_oef_median_gm(11) = mean(hqbold_oef_median_gm(1:10));
	hqbold_oef_median_gm(12) = std(hqbold_oef_median_gm(1:10));	
	sqbold_dbv_median_gm(11) = mean(sqbold_dbv_median_gm(1:10));
	sqbold_dbv_median_gm(12) = std(sqbold_dbv_median_gm(1:10));
	sqbold_oef_median_gm(11) = mean(sqbold_oef_median_gm(1:10));
	sqbold_oef_median_gm(12) = std(sqbold_oef_median_gm(1:10));	
	trust_oef(11) = mean(trust_oef(1:10));
	trust_oef(12) = std(trust_oef(1:10));
	
	T=table(subj,sqbold_dbv_median_gm,sqbold_oef_median_gm,hqbold_dbv_median_gm,hqbold_oef_median_gm,trust_oef)

	%Group averages - comparison of measured R2' vs synthetic R2'
	hqbold_r2p_median_gm(11)=mean(hqbold_r2p_median_gm(1:10));
	hqbold_r2p_median_gm(12)=std(hqbold_r2p_median_gm(1:10));
	synth_r2p_median_gm(11)=mean(synth_r2p_median_gm(1:10));
	synth_r2p_median_gm(12)=std(synth_r2p_median_gm(1:10));	
	hqbold_r2p_median_wm(11)=mean(hqbold_r2p_median_wm(1:10));
	hqbold_r2p_median_wm(12)=std(hqbold_r2p_median_wm(1:10));
	synth_r2p_median_wm(11)=mean(synth_r2p_median_wm(1:10));
	synth_r2p_median_wm(12)=std(synth_r2p_median_wm(1:10));
	
	T2=table(subj,hqbold_r2p_median_gm,synth_r2p_median_gm,hqbold_r2p_median_wm,synth_r2p_median_wm)

	[hgm pgm]=ttest(hqbold_r2p_median_gm,synth_r2p_median_gm);
	if hgm
		sig='significantly';
	else
		sig='not significantly';
	end
	disp(['Measured GM values are ' sig ' different to synthetic values'])
	
	[hwm pwm]=ttest(hqbold_r2p_median_wm,synth_r2p_median_wm);
	if hwm
		sig='significantly';
	else
		sig='not significantly';
	end
	disp(['Measured WM values are ' sig ' different to synthetic values'])
	