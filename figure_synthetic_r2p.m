function figure_synthetic_r2p(src)
	
	subj_id='sub-01';
	
	% Load hqBOLD results
	[r2p,dims,scales,bpp,endian]  = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_r2p']);
	dbv = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_dbv']);

	% Load TRUST results
	Yv=load([src '/derivatives/' subj_id '/' subj_id '_trust_Yv.txt']);
	%trust_oef=round(100.*(1-Yv),1);
	
	% Calculate synthetic R2'
	dChi0 = 0.264e-6;
	Hct = 0.34;
	B0 = 3;
	gamma=2.*pi.*42.58e6;
	
	synth_r2p=(4./3).*pi.*gamma.*dChi0.*Hct.*B0.*dbv.*(1-Yv);
	
	% Produce maps
	scrnsz = get(0,'screensize');
	figdims = [1000 100];
	
	r2p=permute(r2p,[2 1 3]);
	r2p=flipud(reshape(r2p,dims(1),dims(2)*dims(3)));
	synth_r2p=permute(synth_r2p,[2 1 3]);
	synth_r2p=flipud(reshape(synth_r2p,dims(1),dims(2)*dims(3)));
	
	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(r2p,[0 8]);
	colorbar
	cmap=colormap('gray');
	cmap(1,:)=[0 0 0];
	colormap(cmap);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('Apparent R_2^\prime')

	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(synth_r2p,[0 8]);
	colorbar
	cmap=colormap('gray');
	cmap(1,:)=[0 0 0];
	colormap(cmap);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('Synthetic R_2^\prime')	
	