function figure_gm_histograms(hqbold_oef_hist,hqbold_dbv_hist,sqbold_oef_hist,sqbold_dbv_hist)

	num_subj=10;
	
	scrnsz = get(0,'screensize');
	figdims = [1500 150];
	h1=figure;
	h2=figure;
	h3=figure;
	h4=figure;
	
	ylimsDBVhq=[0 800];
	ylimsDBVsq=[0 400];
	xlimsDBV=[-5 15];
	ylimsOEFhq=[0 600];
	ylimsOEFsq=[0 1200];
	xlimsOEF=[-50 150];
			
	for k=1:num_subj
	
		subj_id=['sub-' sprintf('%02d',k)];
		disp(subj_id);	
	
		figure(h1)
		hold off;
		subplot(1,10,k)
		hist(hqbold_dbv_hist{k},linspace(-20,20,100));
		xlim(xlimsDBV);
		ylim(ylimsDBVhq);
		title([subj_id ': hqBOLD DBV'])
		hold on;
		plot(median(hqbold_dbv_hist{k}).*ones(2,1),ylimsDBVhq,'r')
		%plot([0 0],ylimsDBV,'k--')
		%plot([100 100],ylimsDBV,'k--')
		axis square
		
		figure(h2)
		hold off;
		subplot(1,10,k)
		hist(hqbold_oef_hist{k},linspace(-200,200,100));
		xlim(xlimsOEF);
		ylim(ylimsOEFhq);
		title([subj_id ': hqBOLD OEF'])
		hold on;
		plot(median(hqbold_oef_hist{k}).*ones(2,1),ylimsOEFhq,'r')
		%plot([0 0],ylimsOEF,'k--')
		%plot([100 100],ylimsOEF,'k--')
		axis square
		
		figure(h3)
		hold off;
		subplot(1,10,k)
		hist(sqbold_dbv_hist{k},linspace(-20,20,100));
		xlim(xlimsDBV);
		ylim(ylimsDBVsq);
		title([subj_id ': hqBOLD DBV'])
		hold on;
		plot(median(sqbold_dbv_hist{k}).*ones(2,1),ylimsDBVsq,'r')
		%plot([0 0],ylimsDBV,'k--')
		%plot([100 100],ylimsDBV,'k--')
		axis square
		
		figure(h4)
		hold off;
		subplot(1,10,k)
		hist(sqbold_oef_hist{k},linspace(-200,200,100));
		xlim(xlimsOEF);
		ylim(ylimsOEFsq);
		title([subj_id ': hqBOLD OEF'])
		hold on;
		plot(median(sqbold_oef_hist{k}).*ones(2,1),ylimsOEFsq,'r')
		%plot([0 0],ylimsOEF,'k--')
		%plot([100 100],ylimsOEF,'k--')
		axis square
				
	end
	

	set(h1,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	set(h2,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	set(h3,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	set(h4,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
