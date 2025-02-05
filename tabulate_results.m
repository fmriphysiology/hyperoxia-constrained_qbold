function [T1 T2 hqbold_r2p_hist hqbold_oef_hist hqbold_dbv_hist sqbold_oef_hist sqbold_dbv_hist]=tabulate_results(src)

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
		
		% Load respiratory data
		et_o2_co2 = load([src '/' subj_id '/func-bold/' subj_id '_bold_et_o2_co2.trace']);
		et_t = et_o2_co2(:,1);
		et_co2 = et_o2_co2(:,2);
		et_o2 = et_o2_co2(:,3);
		tr = 1; % [sec] 
		t = (1:300)' .* tr; 
		et_o2 = interp1((et_t-et_t(1)).*60, et_o2, t);
		et_co2 = interp1((et_t-et_t(1)).*60, et_co2, t);
		pao2(k,:)=mean(et_o2(1:100));
		dpao2(k,:)=mean(et_o2(175:225))-pao2(k,:);
		paco2(k,:)=mean(et_co2(1:100));
		dpaco2(k,:)=mean(et_co2(175:225))-paco2(k,:);
	
		% Load TRUST results
		Yv=load([src '/derivatives/' subj_id '/' subj_id '_trust_Yv.txt']);
		trust_oef(k,:)=round(100.*(1-Yv),1);
	
		% Load GM and WM ROIs
		gm_roi = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_gm_cortex']);
		gm_roi = gm_roi(:);
		wm_roi = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_wm_thr']);
		wm_roi = wm_roi(:);	

		% Load hqBOLD results
		[r2p,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_hqbold_r2p']);
		r2p = r2p(:);
		dbv = read_avw([src '/derivatives/' subj_id '/' subj_id '_hqbold_dbv']);
		dbv = dbv(:).*100;
		oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_hqbold_oef']);
		oef = oef(:).*100;
	
		% GM hqBOLD results
		hqbold_r2p_median_gm(k,:) = median(r2p(gm_roi>0),'omitnan');
		hqbold_r2p_iqr_gm(k,:) = iqr(r2p(gm_roi>0));
		hqbold_r2p_hist{k} = r2p(find((gm_roi>0).*~isnan(r2p)));
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
	
		% GM r2p_synth results
		synth_r2p_median_gm(k,:) = median(r2p_synth(gm_roi>0),'omitnan');
		synth_r2p_iqr_gm(k,:) = iqr(r2p_synth(gm_roi>0));
		
		% WM r2p_synth results
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
	
		
	subj={'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'mean';'stdev';'cov'};
	
	% Group averages - respiratory parameters
	pao2(11) = mean(pao2(1:10));
	pao2(12) = std(pao2(1:10));	
	pao2(13) = std(pao2(1:10))./mean(pao2(1:10));
	dpao2(11) = mean(dpao2(1:10));
	dpao2(12) = std(dpao2(1:10));	
	dpao2(13) = std(dpao2(1:10))./mean(dpao2(1:10));
	paco2(11) = mean(paco2(1:10));
	paco2(12) = std(paco2(1:10));	
	paco2(13) = std(paco2(1:10))./mean(paco2(1:10));
	dpaco2(11) = mean(dpaco2(1:10));
	dpaco2(12) = std(dpaco2(1:10));	
	dpaco2(13) = std(dpaco2(1:10))./mean(dpaco2(1:10));
	
	T1=table(subj,pao2,dpao2,paco2,dpaco2)

	[hdpao2 pdpao2]=ttest(dpao2(1:10));
	if hdpao2
		sig='significantly';
	else
		sig='not significantly';
	end
	disp(['PaO2 did ' sig ' change during the hyperoxia challenge (p=' num2str(pdpao2) ')'])	

	[hdpaco2 pdpaco2]=ttest(dpaco2(1:10));
	if hdpaco2
		sig='significantly';
	else
		sig='not significantly';
	end
	disp(['PaCO2 did ' sig ' change during the hyperoxia challenge (p=' num2str(pdpaco2) ')'])	
				
	% Group averages - comparison of GM sqBOLD vs hqBOLD vs TRUST
	trust_oef(11) = mean(trust_oef(1:10));
	trust_oef(12) = std(trust_oef(1:10));
	trust_oef(13) = std(trust_oef(1:10))./mean(trust_oef(1:10));
	sqbold_dbv_median_gm(11) = mean(sqbold_dbv_median_gm(1:10));
	sqbold_dbv_median_gm(12) = std(sqbold_dbv_median_gm(1:10));
	sqbold_dbv_median_gm(13) = std(sqbold_dbv_median_gm(1:10))./mean(sqbold_dbv_median_gm(1:10));
	sqbold_oef_median_gm(11) = mean(sqbold_oef_median_gm(1:10));
	sqbold_oef_median_gm(12) = std(sqbold_oef_median_gm(1:10));	
	sqbold_oef_median_gm(13) = std(sqbold_oef_median_gm(1:10))./mean(sqbold_oef_median_gm(1:10));
	hqbold_dbv_median_gm(11) = mean(hqbold_dbv_median_gm(1:10));
	hqbold_dbv_median_gm(12) = std(hqbold_dbv_median_gm(1:10));
	hqbold_dbv_median_gm(13) = std(hqbold_dbv_median_gm(1:10))./mean(hqbold_dbv_median_gm(1:10));
	hqbold_oef_median_gm(11) = mean(hqbold_oef_median_gm(1:10));
	hqbold_oef_median_gm(12) = std(hqbold_oef_median_gm(1:10));	
	hqbold_oef_median_gm(13) = std(hqbold_oef_median_gm(1:10))./mean(hqbold_oef_median_gm(1:10));
	hqbold_r2p_median_gm(11)=mean(hqbold_r2p_median_gm(1:10));
	hqbold_r2p_median_gm(12)=std(hqbold_r2p_median_gm(1:10));
	hqbold_r2p_median_gm(13)=std(hqbold_r2p_median_gm(1:10))./mean(hqbold_r2p_median_gm(1:10));
	sqbold_r2p_median_gm(11)=mean(sqbold_r2p_median_gm(1:10));
	sqbold_r2p_median_gm(12)=std(sqbold_r2p_median_gm(1:10));
	sqbold_r2p_median_gm(13)=std(sqbold_r2p_median_gm(1:10))./mean(sqbold_r2p_median_gm(1:10));
	
	sqbold_dbv_iqr_gm(11) = mean(sqbold_dbv_iqr_gm(1:10));
	sqbold_dbv_iqr_gm(12) = std(sqbold_dbv_iqr_gm(1:10));
	sqbold_dbv_iqr_gm(13) = std(sqbold_dbv_iqr_gm(1:10))./mean(sqbold_dbv_iqr_gm(1:10));
	sqbold_oef_iqr_gm(11) = mean(sqbold_oef_iqr_gm(1:10));
	sqbold_oef_iqr_gm(12) = std(sqbold_oef_iqr_gm(1:10));	
	sqbold_oef_iqr_gm(13) = std(sqbold_oef_iqr_gm(1:10))./mean(sqbold_oef_iqr_gm(1:10));
	hqbold_dbv_iqr_gm(11) = mean(hqbold_dbv_iqr_gm(1:10));
	hqbold_dbv_iqr_gm(12) = std(hqbold_dbv_iqr_gm(1:10));
	hqbold_dbv_iqr_gm(13) = std(hqbold_dbv_iqr_gm(1:10))./mean(hqbold_dbv_iqr_gm(1:10));
	hqbold_oef_iqr_gm(11) = mean(hqbold_oef_iqr_gm(1:10));
	hqbold_oef_iqr_gm(12) = std(hqbold_oef_iqr_gm(1:10));	
	hqbold_oef_iqr_gm(13) = std(hqbold_oef_iqr_gm(1:10))./mean(hqbold_oef_iqr_gm(1:10));
	hqbold_r2p_iqr_gm(11)=mean(hqbold_r2p_iqr_gm(1:10));
	hqbold_r2p_iqr_gm(12)=std(hqbold_r2p_iqr_gm(1:10));
	hqbold_r2p_iqr_gm(13)=std(hqbold_r2p_iqr_gm(1:10))./mean(hqbold_r2p_iqr_gm(1:10));
	sqbold_r2p_iqr_gm(11)=mean(sqbold_r2p_iqr_gm(1:10));
	sqbold_r2p_iqr_gm(12)=std(sqbold_r2p_iqr_gm(1:10));
	sqbold_r2p_iqr_gm(13)=std(sqbold_r2p_iqr_gm(1:10))./mean(sqbold_r2p_iqr_gm(1:10));
		
	T2=table(subj,sqbold_r2p_median_gm,sqbold_r2p_iqr_gm,sqbold_dbv_median_gm,sqbold_dbv_iqr_gm,sqbold_oef_median_gm,sqbold_oef_iqr_gm,hqbold_r2p_median_gm,hqbold_r2p_iqr_gm,hqbold_dbv_median_gm,hqbold_dbv_iqr_gm,hqbold_oef_median_gm,hqbold_oef_iqr_gm,trust_oef)

	[poef tbloef stsoef]=anova1([sqbold_oef_median_gm(1:10) hqbold_oef_median_gm(1:10) trust_oef(1:10)]);
	if poef<0.05
		disp('OEF values: One or more groups has a significantly different mean')
		[coef moef hoef]=multcompare(stsoef);
		disp('Multiple comparisons')
		disp(coef);
	else
		disp('OEF values: None of the group means are significantly different')
	end
	
	[hdbv pdbv]=ttest(hqbold_dbv_median_gm(1:10),sqbold_dbv_median_gm(1:10));
	if hdbv
		sig='significantly';
	else
		sig='not significantly';
	end
	disp(['hqBOLD DBV values are ' sig ' different to sqBOLD DBV values (p=' num2str(pdbv) ')'])	

	[hr2p pr2p]=ttest(hqbold_r2p_median_gm(1:10),sqbold_r2p_median_gm(1:10));
	if hr2p
		sig='significantly';
	else
		sig='not significantly';
	end
	disp(['hqBOLD R2p values are ' sig ' different to sqBOLD R2p values (p=' num2str(pr2p) ')'])	

	%Group averages - comparison of measured R2' vs synthetic (simulated) R2'
	hqbold_r2p_median_gm(11)=mean(hqbold_r2p_median_gm(1:10));
	hqbold_r2p_median_gm(12)=std(hqbold_r2p_median_gm(1:10));
	hqbold_r2p_median_gm(13)=std(hqbold_r2p_median_gm(1:10))./mean(hqbold_r2p_median_gm(1:10));
	
	%%
	sqbold_r2p_median_gm(11)=mean(sqbold_r2p_median_gm(1:10));
	sqbold_r2p_median_gm(12)=std(sqbold_r2p_median_gm(1:10));
	sqbold_r2p_median_gm(13)=std(sqbold_r2p_median_gm(1:10))./mean(sqbold_r2p_median_gm(1:10));
	
	%synth_r2p_median_gm(11)=mean(synth_r2p_median_gm(1:10));
	%synth_r2p_median_gm(12)=std(synth_r2p_median_gm(1:10));	
	%synth_r2p_median_gm(13)=std(synth_r2p_median_gm(1:10))./mean(synth_r2p_median_gm(1:10));	
	%hqbold_r2p_median_wm(11)=mean(hqbold_r2p_median_wm(1:10));
	%hqbold_r2p_median_wm(12)=std(hqbold_r2p_median_wm(1:10));
	%hqbold_r2p_median_wm(13)=std(hqbold_r2p_median_wm(1:10))./mean(hqbold_r2p_median_wm(1:10));

	%%
	%sqbold_r2p_median_wm(11)=mean(sqbold_r2p_median_wm(1:10));
	%sqbold_r2p_median_wm(12)=std(sqbold_r2p_median_wm(1:10));
	%sqbold_r2p_median_wm(13)=std(sqbold_r2p_median_wm(1:10))./mean(sqbold_r2p_median_wm(1:10));

	%synth_r2p_median_wm(11)=mean(synth_r2p_median_wm(1:10));
	%synth_r2p_median_wm(12)=std(synth_r2p_median_wm(1:10));
	%synth_r2p_median_wm(13)=std(synth_r2p_median_wm(1:10))./mean(synth_r2p_median_wm(1:10));
	
	T3=table(subj,sqbold_r2p_median_gm,hqbold_r2p_median_gm)
	%T2=table(subj,hqbold_r2p_median_gm,synth_r2p_median_gm,hqbold_r2p_median_wm,synth_r2p_median_wm)
	
	%[p tbl sts]=anova1([hqbold_r2p_median_gm(1:10) synth_r2p_median_gm(1:10) hqbold_r2p_median_wm(1:10) synth_r2p_median_wm(1:10)]);
	%if p<0.05
	%	disp('R2p values: One or more groups has a significantly different mean')
	%	[c m h]=multcompare(sts);
	%	disp('Multiple comparisons')
	%	disp(c);
	%else
	%	disp('R2p values: None of the group means are significantly different')
	%end

	[hr2p pr2p]=ttest(hqbold_r2p_median_gm(1:10),sqbold_r2p_median_gm(1:10));
	if hr2p
		sig='significantly';
	else
		sig='not significantly';
	end
	disp(['hqBOLD R2p values are ' sig ' different to sqBOLD R2p values (p=' num2str(pr2p) ')'])	
		
	sqbold_dbv_median_wm(11) = mean(sqbold_dbv_median_wm(1:10));
	sqbold_dbv_median_wm(12) = std(sqbold_dbv_median_wm(1:10));
	sqbold_dbv_median_wm(13) = std(sqbold_dbv_median_wm(1:10))./mean(sqbold_dbv_median_wm(1:10));
	sqbold_oef_median_wm(11) = mean(sqbold_oef_median_wm(1:10));
	sqbold_oef_median_wm(12) = std(sqbold_oef_median_wm(1:10));	
	sqbold_oef_median_wm(13) = std(sqbold_oef_median_wm(1:10))./mean(sqbold_oef_median_wm(1:10));
	hqbold_dbv_median_wm(11) = mean(hqbold_dbv_median_wm(1:10));
	hqbold_dbv_median_wm(12) = std(hqbold_dbv_median_wm(1:10));
	hqbold_dbv_median_wm(13) = std(hqbold_dbv_median_wm(1:10))./mean(hqbold_dbv_median_wm(1:10));
	hqbold_oef_median_wm(11) = mean(hqbold_oef_median_wm(1:10));
	hqbold_oef_median_wm(12) = std(hqbold_oef_median_wm(1:10));	
	hqbold_oef_median_wm(13) = std(hqbold_oef_median_wm(1:10))./mean(hqbold_oef_median_wm(1:10));
	hqbold_r2p_median_wm(11)=mean(hqbold_r2p_median_wm(1:10));
	hqbold_r2p_median_wm(12)=std(hqbold_r2p_median_wm(1:10));
	hqbold_r2p_median_wm(13)=std(hqbold_r2p_median_wm(1:10))./mean(hqbold_r2p_median_wm(1:10));
	sqbold_r2p_median_wm(11)=mean(sqbold_r2p_median_wm(1:10));
	sqbold_r2p_median_wm(12)=std(sqbold_r2p_median_wm(1:10));
	sqbold_r2p_median_wm(13)=std(sqbold_r2p_median_wm(1:10))./mean(sqbold_r2p_median_wm(1:10));

	T2wm=table(subj,sqbold_r2p_median_wm,sqbold_dbv_median_wm,sqbold_oef_median_wm,hqbold_r2p_median_wm,hqbold_dbv_median_wm,hqbold_oef_median_wm,trust_oef)

	r2p_ratio=sqbold_r2p_median_gm./sqbold_r2p_median_wm;
	sqDBV_ratio=sqbold_dbv_median_gm./sqbold_dbv_median_wm;
	hqDBV_ratio=hqbold_dbv_median_gm./hqbold_dbv_median_wm;
	
	r2p_ratio(11)=mean(r2p_ratio(1:10));
	r2p_ratio(12)=std(r2p_ratio(1:10));
	r2p_ratio(13)=std(r2p_ratio(1:10))./mean(r2p_ratio(1:10));
	sqDBV_ratio(11)=mean(sqDBV_ratio(1:10));
	sqDBV_ratio(12)=std(sqDBV_ratio(1:10));
	sqDBV_ratio(13)=std(sqDBV_ratio(1:10))./mean(sqDBV_ratio(1:10));
	hqDBV_ratio(11)=mean(hqDBV_ratio(1:10));
	hqDBV_ratio(12)=std(hqDBV_ratio(1:10));
	hqDBV_ratio(13)=std(hqDBV_ratio(1:10))./mean(hqDBV_ratio(1:10));

	T3=table(subj,r2p_ratio,sqDBV_ratio,hqDBV_ratio)
