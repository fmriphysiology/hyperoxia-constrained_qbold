function figure_bland_altman(T1)

	hqbold_oef=T1.hqbold_mod_oef_median_gm(1:10).*1.19;
	sqbold_oef=T1.sqbold_mod_oef_median_gm(1:10);
	trust_oef=T1.trust_oef(1:10);
	
	xlims=[15 55];
	ylims=[-45 45];

	scrnsz = get(0,'screensize');
	figdims = [800 400];
	h1=figure;

	% hqBOLD vs TRUST
	
	hT_diff=hqbold_oef-trust_oef;
	hT_mean=(hqbold_oef+trust_oef)./2;
	
	hT_diffMean=mean(hT_diff);
	hT_diffStd=std(hT_diff);
	
	hT_diffMean_pos=hT_diffMean+1.96*hT_diffStd;
	hT_diffMean_neg=hT_diffMean-1.96*hT_diffStd;
	
	subplot(121);
	scatter(hT_mean,hT_diff,[],'k','filled')
	box on;
	axis square;
	hold on;
	plot(xlims,ones(2,1).*hT_diffMean_pos,'-k');
	plot(xlims,ones(2,1).*hT_diffMean_neg,'-k');
	plot(xlims,ones(2,1).*hT_diffMean,'--k');
	xlim(xlims);
	ylim(ylims);
	xlabel('OEF: Mean of hqBOLD & TRUST (%)');
	ylabel('OEF: Difference of hqBOLD & TRUST (%)');
	title('hqBOLD vs TRUST')

	% sqBOLD vs TRUST
	
	sT_diff=sqbold_oef-trust_oef;
	sT_mean=(sqbold_oef+trust_oef)./2;
	
	sT_diffMean=mean(sT_diff);
	sT_diffStd=std(sT_diff);
	
	sT_diffMean_pos=sT_diffMean+1.96*sT_diffStd;
	sT_diffMean_neg=sT_diffMean-1.96*sT_diffStd;
	
	subplot(122);
	scatter(sT_mean,sT_diff,[],'k','filled')
	box on;
	axis square;
	hold on;
	plot(xlims,ones(2,1).*sT_diffMean_pos,'-k');
	plot(xlims,ones(2,1).*sT_diffMean_neg,'-k');
	plot(xlims,ones(2,1).*sT_diffMean,'--k');
	xlim(xlims);
	ylim(ylims);
	xlabel('OEF: Mean of sqBOLD & TRUST (%)');
	ylabel('OEF: Difference of sqBOLD & TRUST (%)');
	title('sqBOLD vs TRUST')
	
	set(h1,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])

	keyboard;