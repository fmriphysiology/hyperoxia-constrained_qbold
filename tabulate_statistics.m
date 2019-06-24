function tabulate_statistics(src)

PVthresh=0.4;

for k=1:10

	subj_id=['sub-' sprintf('%02d',k)];
	disp(subj_id);

	% Load hc-qBOLD results 
	[r2p,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_r2p']);
	[x y z v] = size(r2p);
	r2p = r2p(:);
	dbv = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_dbv']);
	dbv = dbv(:);
	oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_oef']);
	oef = oef(:);
	gm = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_gm']);
	gm = gm(:);
	wm = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_wm']);
	wm = wm(:);
	csf = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_csf']);
	csf = csf(:);
	mni = read_avw([src '/derivatives/' subj_id '/' subj_id '_MNI-maxprob-thr0']);
	mni = mni(:);

	slices = ones(x,y,z);
	%slices(:,:,[1:3 end]) = 0;
	slices = slices(:);

	cortex = (mni==3)+(mni==4)+(mni==5)+(mni==6)+(mni==8);
	
	oef(isnan(oef))=0;
	nonzero = ((oef~=0)+(r2p~=0)+(dbv~=0))>0;

	gm_roi = (gm>PVthresh).*(cortex>0).*(slices>0).*nonzero;
		
	hqbold_r2p_median(k,:) = round(median(r2p(gm_roi>0)),1);
	hqbold_r2p_iqr(k,:) = round(iqr(r2p(gm_roi>0)),1);

	temp = 100.*dbv(gm_roi>0);
	temp(temp==0) = [];
	temp(isinf(temp)) = [];
	temp(isnan(temp)) = [];
	hqbold_dbv_median(k,:) = round(median(temp),1);%round(median(100.*dbv(gm_roi>0)),1);
	hqbold_dbv_iqr(k,:) = round(iqr(temp),1);%round(iqr(100.*dbv(gm_roi>0)),1);

	figure(98);
	hold off;
	subplot(1,10,k)
	hist(temp,linspace(-10,20,100));
	xlim([-5 15]);
	ylim([0 350]);
	title([subj_id ': hqBOLD DBV'])
	hold on;
	plot(hqbold_dbv_median(k,:).*ones(2,1),[0 400],'r')
	%plot([0 0],[0 400],'k--')
	%plot([100 100],[0 400],'k--')
	axis square
	
	hqbold_dbv_map(:,:,k)=reshape(dbv(4*96^2+1:5*96^2),96,96,1);
	
	%oef(isnan(oef)) = 0;
	temp = 100.*oef(gm_roi>0);
	temp(temp==0) = [];
	temp(isinf(temp)) = [];
	temp(isnan(temp)) = [];
	
	hqbold_oef_median(k,:) = round(median(temp),1);%round(median(100.*oef(gm_roi>0)),1);
	hqbold_oef_iqr(k,:) = round(iqr(temp),1);%round(iqr(100.*oef(gm_roi>0)),1);
	
	figure(99);
	hold off;
	subplot(1,10,k)
	hist(temp,linspace(-100,200,100));
	xlim([-50 150]);
	ylim([0 350]);
	title([subj_id ': hqBOLD OEF'])
	hold on;
	plot(hqbold_oef_median(k,:).*ones(2,1),[0 400],'r')
	plot([0 0],[0 400],'k--')
	plot([100 100],[0 400],'k--')
	axis square

	hqbold_oef_map(:,:,k)=reshape(oef(4*96^2+1:5*96^2),96,96,1);

	% Load sqBOLD results 
	[r2p,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_r2p']);
	r2p = r2p(:);
	[x y z v] = size(r2p);
	dbv = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_dbv']);
	dbv = dbv(:);
	oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_oef']);
	oef = oef(:);

	oef(isnan(oef))=0;
	nonzero = ((oef~=0)+(r2p~=0)+(dbv~=0))>0;

	gm_roi = (gm>PVthresh).*(cortex>0).*(slices>0).*nonzero;
		
	sqbold_r2p_median(k,:) = round(median(r2p(gm_roi>0)),1);
	sqbold_r2p_iqr(k,:) = round(iqr(r2p(gm_roi>0)),1);
	
	temp = 100.*dbv(gm_roi>0);
	temp(temp==0) = [];
	temp(isinf(temp)) = [];
	temp(isnan(temp)) = [];
	sqbold_dbv_median(k,:) = round(median(temp),1);%round(median(100.*dbv(gm_roi>0)),1);
	sqbold_dbv_iqr(k,:) = round(iqr(temp),1);%round(iqr(100.*dbv(gm_roi>0)),1);

	figure(100);
	hold off;
	subplot(1,10,k)
	hist(temp,linspace(-10,20,100));
	xlim([-5 15]);
	ylim([0 350]);
	title([subj_id ': sqBOLD DBV'])
	hold on;
	plot(sqbold_dbv_median(k,:).*ones(2,1),[0 400],'r')
	%plot([0 0],[0 400],'k--')
	%plot([100 100],[0 400],'k--')
	axis square

	sqbold_dbv_map(:,:,k)=reshape(dbv(4*96^2+1:5*96^2),96,96,1);

	%oef(isnan(oef)) = 0;
	temp = 100.*oef(gm_roi>0);
	temp(temp==0) = [];
	temp(isinf(temp)) = [];
	temp(isnan(temp)) = [];
	
	sqbold_oef_median(k,:) = round(median(temp),1);%round(median(100.*oef(gm_roi>0)),1);
	sqbold_oef_iqr(k,:) = round(iqr(temp),1);%round(iqr(100.*oef(gm_roi>0)),1);

	figure(101);
	hold off;
	subplot(1,10,k)
	hist(temp,linspace(-100,200,100));
	xlim([-50 150]);
	ylim([0 350]);
	title([subj_id ': sqBOLD OEF'])
	hold on;
	plot(sqbold_oef_median(k,:).*ones(2,1),[0 400],'r')
	plot([0 0],[0 400],'k--')
	plot([100 100],[0 400],'k--')
	axis square

	sqbold_oef_map(:,:,k)=reshape(oef(4*96^2+1:5*96^2),96,96,1);

	% Load TRUST results
	Yv=load([src '/derivatives/' subj_id '/' subj_id '_trust_Yv.txt']);
	trust_oef(k,:)=round(100.*(1-Yv),1);
	
	% Load PCASL results
	[cbf,dims,scales,bpp,endian] = read_avw([src '/derivatives/' subj_id '/' subj_id '_perfusion_reg']);
	[x y z v] = size(cbf);
	cbf = cbf(:);
	
	temp = cbf(gm_roi>0);
	temp(temp==0) = [];
	temp(isinf(temp)) = [];
	temp(isnan(temp)) = [];
	pcasl_cbf_median(k,:) = round(median(temp),1);
	pcasl_cbf_iqr(k,:) = round(iqr(temp),1);
	
	pcasl_cbf_map(:,:,k)=reshape(cbf(4*96^2+1:5*96^2),96,96,1);
	
end

	%Bland-Altman analysis
	xBA1=15;
	xBA2=55;
	yBA1=-45;
	yBA2=45;
	
	hqbold_trust_mean=(hqbold_oef_median+trust_oef)./2;
	hqbold_trust_diff=hqbold_oef_median-trust_oef;
	hqbold_trust_diff_std=std(hqbold_trust_diff);
	hqbold_trust_diff_mean=mean(hqbold_trust_diff);
	
	[h_hqbold p_hqbold]=ttest(hqbold_trust_diff);
	
	if h_hqbold
		disp(['hqBOLD OEF values are significantly different to TRUST OEF values: p=' num2str(p_hqbold)])
	else
		disp(['hqBOLD OEF values are not significantly different to TRUST OEF values: p=' num2str(p_hqbold)])	
	end
	
	figure(102)
	hold off;
	scatter(hqbold_trust_mean,hqbold_trust_diff,[],[0 0 0],'filled');
	axis square;
	box on;
	grid on;
	hold on;
	plot([xBA1 xBA2],hqbold_trust_diff_mean.*ones(2,1),'k--');
	plot([xBA1 xBA2],(hqbold_trust_diff_mean+2.*hqbold_trust_diff_std).*ones(2,1),'k--');
	plot([xBA1 xBA2],(hqbold_trust_diff_mean-2.*hqbold_trust_diff_std).*ones(2,1),'k--');
	xlim([xBA1 xBA2]);
	ylim([yBA1 yBA2]);
	set(gca,'ytick',[-40:20:40])
	title('Bland-Altman: hqBOLD vs TRUST')
	
	sqbold_trust_mean=(sqbold_oef_median+trust_oef)./2;
	sqbold_trust_diff=sqbold_oef_median-trust_oef;
	sqbold_trust_diff_std=std(sqbold_trust_diff);
	sqbold_trust_diff_mean=mean(sqbold_trust_diff);
	
	[h_sqbold p_sqbold]=ttest(sqbold_trust_diff);
	
	if h_sqbold
		disp(['sqBOLD OEF values are significantly different to TRUST OEF values: p=' num2str(p_sqbold)])
	else
		disp(['sqBOLD OEF values are not significantly different to TRUST OEF values: p=' num2str(p_sqbold)])	
	end
	
	figure(103)
	hold off;
	scatter(sqbold_trust_mean,sqbold_trust_diff,[],[0 0 0],'filled');
	axis square;
	box on;
	grid on;
	hold on;
	plot([xBA1 xBA2],sqbold_trust_diff_mean.*ones(2,1),'k--');
	plot([xBA1 xBA2],(sqbold_trust_diff_mean+2.*sqbold_trust_diff_std).*ones(2,1),'k--');
	plot([xBA1 xBA2],(sqbold_trust_diff_mean-2.*sqbold_trust_diff_std).*ones(2,1),'k--');
	xlim([xBA1 xBA2]);
	ylim([yBA1 yBA2]);
	set(gca,'ytick',[-40:20:40])
	title('Bland-Altman: sqBOLD vs TRUST')
	

	subj={'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'mean';'stdev'};
	sqbold_dbv_median(11)=mean(sqbold_dbv_median(1:10));
	sqbold_dbv_median(12)=std(sqbold_dbv_median(1:10));
	sqbold_oef_median(11)=mean(sqbold_oef_median(1:10));
	sqbold_oef_median(12)=std(sqbold_oef_median(1:10));
	hqbold_dbv_median(11)=mean(hqbold_dbv_median(1:10));
	hqbold_dbv_median(12)=std(hqbold_dbv_median(1:10));
	hqbold_oef_median(11)=mean(hqbold_oef_median(1:10));
	hqbold_oef_median(12)=std(hqbold_oef_median(1:10));
	trust_oef(11)=mean(trust_oef(1:10));
	trust_oef(12)=std(trust_oef(1:10));

	T=table(subj,sqbold_dbv_median,sqbold_oef_median,hqbold_dbv_median,hqbold_oef_median,trust_oef)

	keyboard;