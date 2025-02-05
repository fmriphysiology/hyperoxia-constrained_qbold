function figure_gm_histograms(hqbold_r2p_hist,hqbold_oef_hist,hqbold_dbv_hist,sqbold_oef_hist,sqbold_dbv_hist)

	num_subj=10;
	
	scrnsz = get(0,'screensize');
	figdims = [1500 150];
	h0=figure;
	h1=figure;
	h2=figure;
	h3=figure;
	h4=figure;
	
	ylimsDBVhq=[0 0.13];
	ylimsDBVsq=[0 0.05];
	xlimsDBV=[-4 12];
	ylimsOEFhq=[0 0.07];
	ylimsOEFsq=[0 0.14];
	xlimsOEF=[-40 120];
			
	for k=1:num_subj
	
		subj_id=['sub-' sprintf('%02d',k)];
		disp(subj_id);	
	
		figure(h0)
		hold off;
		subplot(1,10,k)
		histogram(hqbold_r2p_hist{k},linspace(-2,6,64),'normalization','probability');
		xlim([-2 6])
		ylim([0 0.06])
		title([subj_id ': R2p'])
		hold on;
		axis square
		shading flat
		grid on	
	
		figure(h1)
		hold off;
		subplot(1,10,k)
		histogram(hqbold_dbv_hist{k},linspace(-4,12,64),'normalization','probability');
		xlim(xlimsDBV);
		ylim(ylimsDBVhq);
		set(gca,'xtick',[-4:4:12])
		%set(gca,'ytick',[0 ylimsDBVhq(2)/2 ylimsDBVhq(2)])
		title([subj_id ': hqBOLD DBV'])
		hold on;
		%plot(median(hqbold_dbv_hist{k}).*ones(2,1),ylimsDBVhq,'r')
		%plot(mean(hqbold_dbv_hist{k}).*ones(2,1),ylimsDBVhq,'g')
		%plot([0 0],ylimsDBV,'k--')
		%plot([100 100],ylimsDBV,'k--')
		axis square
		shading flat
		grid on
		
		figure(h2)
		hold off;
		subplot(1,10,k)
		histogram(hqbold_oef_hist{k},linspace(-40,120,64),'normalization','probability');
		xlim(xlimsOEF);
		ylim(ylimsOEFhq);
		set(gca,'xtick',[-40:40:120])
		%set(gca,'ytick',[0 ylimsOEFhq(2)/2 ylimsOEFhq(2)])
		title([subj_id ': hqBOLD OEF'])
		hold on;
		%plot(median(hqbold_oef_hist{k}).*ones(2,1),ylimsOEFhq,'r')
		%plot(mean(hqbold_oef_hist{k}).*ones(2,1),ylimsOEFhq,'g')
		%plot([0 0],ylimsOEF,'k--')
		%plot([100 100],ylimsOEF,'k--')
		axis square
		shading flat
		grid on
		
		figure(h3)
		hold off;
		subplot(1,10,k)
		histogram(sqbold_dbv_hist{k},linspace(-4,12,64),'normalization','probability');
		xlim(xlimsDBV);
		ylim(ylimsDBVsq);
		set(gca,'xtick',[-4:4:12])
		%set(gca,'ytick',[0 ylimsDBVsq(2)/2 ylimsDBVsq(2)])
		title([subj_id ': sqBOLD DBV'])
		hold on;
		%plot(median(sqbold_dbv_hist{k}).*ones(2,1),ylimsDBVsq,'r')
		%plot(mean(sqbold_dbv_hist{k}).*ones(2,1),ylimsDBVsq,'g')
		%plot([0 0],ylimsDBV,'k--')
		%plot([100 100],ylimsDBV,'k--')
		axis square
		shading flat
		grid on
		
		figure(h4)
		hold off;
		subplot(1,10,k)
		histogram(sqbold_oef_hist{k},linspace(-40,120,64),'normalization','probability');
		xlim(xlimsOEF);
		ylim(ylimsOEFsq);
		set(gca,'xtick',[-40:40:120])
		%set(gca,'ytick',[0 ylimsOEFsq(2)/2 ylimsOEFsq(2)])
		title([subj_id ': sqBOLD OEF'])
		hold on;
		%plot(median(sqbold_oef_hist{k}).*ones(2,1),ylimsOEFsq,'r')
		%plot(mean(sqbold_oef_hist{k}).*ones(2,1),ylimsOEFsq,'g')
		%plot([0 0],ylimsOEF,'k--')
		%plot([100 100],ylimsOEF,'k--')
		axis square
		shading flat
		grid on
				
	end
	
	set(h0,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	set(h1,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	set(h2,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	set(h3,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	set(h4,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])


	figure;
	subj=3;
	subj_id=['sub-' sprintf('%02d',subj)];
	
	%xlimsDBV=[0 10];
	%xlimsOEF=[0 100];

	subplot(231)
	histogram(hqbold_r2p_hist{subj},linspace(-2,6,64),'normalization','probability');
	xlim([-2 6]);
	ylim([0 0.04]);
	set(gca,'xtick',[-2:2:6])
	title([subj_id ': hqBOLD R2p'])
	hold on;
	axis square
	shading flat
	grid on
	
	subplot(233)
	%hist(hqbold_dbv_hist{subj},linspace(-20,20,100));
	histogram(hqbold_dbv_hist{subj},linspace(-4,12,64),'normalization','probability');
	xlim([xlimsDBV]);
	ylim([0 0.09])
	%ylim([0 800]);
	set(gca,'xtick',[-4:4:12])
	title([subj_id ': hqBOLD DBV'])
	hold on;
	%plot(median(hqbold_dbv_hist{subj}).*ones(2,1),ylimsDBVhq,'r')
	%plot(mean(hqbold_dbv_hist{subj}).*ones(2,1),ylimsDBVhq,'g')
	axis square
	shading flat
	grid on
	
	subplot(236)
	%hist(hqbold_oef_hist{subj},linspace(-200,200,100));
	histogram(hqbold_oef_hist{subj},linspace(-40,120,64),'normalization','probability')
	xlim(xlimsOEF);
	ylim([0 0.03])
	%ylim([0 800]);
	set(gca,'xtick',[-40:40:120])
	title([subj_id ': hqBOLD OEF'])
	hold on;
	%plot(median(hqbold_oef_hist{subj}).*ones(2,1),ylimsOEFhq,'r')
	%plot(mean(hqbold_oef_hist{subj}).*ones(2,1),ylimsOEFhq,'g')
	axis square
	shading flat
	grid on
	
	subplot(232)
	%hist(sqbold_dbv_hist{subj},linspace(-20,20,100));
	histogram(sqbold_dbv_hist{subj},linspace(-4,12,64),'normalization','probability');
	xlim(xlimsDBV);
	ylim([0 0.02])
	%ylim([0 800])
	set(gca,'xtick',[-4:4:12])
	title([subj_id ': sqBOLD DBV'])
	hold on;
	%plot(median(sqbold_dbv_hist{subj}).*ones(2,1),ylimsDBVsq,'r')
	%plot(mean(sqbold_dbv_hist{subj}).*ones(2,1),ylimsDBVsq,'g')
	axis square
	shading flat
	grid on
	
	subplot(235)
	%hist(sqbold_oef_hist{subj},linspace(-200,200,100));
	histogram(sqbold_oef_hist{subj},linspace(-40,120,64),'normalization','probability');
	xlim(xlimsOEF);
	ylim([0 0.09])
	%ylim([0 800]);
	set(gca,'xtick',[-40:40:120])
	title([subj_id ': sqBOLD OEF'])
	hold on;
	%plot(median(sqbold_oef_hist{subj}).*ones(2,1),ylimsOEFsq,'r')
	%plot(mean(sqbold_oef_hist{subj}).*ones(2,1),ylimsOEFsq,'g')
	axis square
	shading flat
	grid on
	