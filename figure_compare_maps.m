function figure_compare_maps(src)

	slice_no=5;
	num_subj=10;

	for k=1:num_subj
	
		subj_id=['sub-' sprintf('%02d',k)];
		disp(subj_id);
	
		% Load hqBOLD results
		[dbv,dims,scales,bpp,endian]  = read_avw([src '/derivatives/' subj_id '/' subj_id '_hqbold_dbv']);
		oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_hqbold_oef']);
		
		hqbold_dbv_map((k-1)*dims(1)+1:k*dims(1),:) = rot90(dbv(:,:,slice_no));
		hqbold_oef_map((k-1)*dims(1)+1:k*dims(1),:) = rot90(oef(:,:,slice_no));
		
		% Load sqBOLD results
		[dbv,dims,scales,bpp,endian]  = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_dbv']);
		oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_oef']);
		
		sqbold_dbv_map((k-1)*dims(1)+1:k*dims(1),:) = rot90(dbv(:,:,slice_no));
		sqbold_oef_map((k-1)*dims(1)+1:k*dims(1),:) = rot90(oef(:,:,slice_no));

	end

	scrnsz = get(0,'screensize');
	figdims = [100 1000];
	cmapry=[ones(64,1) linspace(0,1,64)' zeros(64,1)];
	cmapry(1,:)=[0 0 0];
	cmapblb=[zeros(64,1) linspace(0,1,64)' ones(64,1)];
	cmapblb(1,:)=[0 0 0];

	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(hqbold_dbv_map.*100,[0 6]);
	colorbar('NorthOutside')
	%cmap=colormap('jet');
	%cmap(1,:)=[0 0 0];
	colormap(cmapblb);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('hqBOLD DBV')
	
	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(hqbold_oef_map.*100,[0 100]);
	colorbar('NorthOutside')
	colormap(cmapry)
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('hqBOLD OEF')

	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(sqbold_dbv_map.*100,[0 6]);
	colorbar('NorthOutside')
	%colormap('jet')
	colormap(cmapblb);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('sqBOLD DBV')
	
	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(sqbold_oef_map.*100,[0 100]);
	colorbar('NorthOutside')
	colormap(cmapry)
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('sqBOLD OEF')
	
	%single example subject - sub-02
	
	subj=2;
	subj_id=['sub-' sprintf('%02d',subj)];

	% Load hqBOLD results
	[hqDBV,dims,scales,bpp,endian]  = read_avw([src '/derivatives/' subj_id '/' subj_id '_hqbold_dbv']);
	hqDBV=permute(hqDBV,[2 1 3]);
	[hqOEF] = read_avw([src '/derivatives/' subj_id '/' subj_id '_hqbold_oef']);
	hqOEF=permute(hqOEF,[2 1 3]);
		
	% Load sqBOLD results
	[sqDBV,dims,scales,bpp,endian]  = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_dbv']);
	sqDBV=permute(sqDBV,[2 1 3]);
	sqOEF = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_oef']);
	sqOEF=permute(sqOEF,[2 1 3]);

	figure;
	
	subplot(211)
	imagesc(flipud(reshape(sqDBV(:,:,2:3:9),96,96*3)).*100,[0 6]);
	colormap(cmapblb);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	colorbar;
	title('sqBOLD DBV')	
	
	subplot(212)
	imagesc(flipud(reshape(hqDBV(:,:,2:3:9),96,96*3)).*100,[0 6]);
	colormap(cmapblb);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	colorbar;
	title('hqBOLD DBV')
	
	figure
	
	subplot(211)
	imagesc(flipud(reshape(sqOEF(:,:,2:3:9),96,96*3)).*100,[0 100]);
	colormap(cmapry);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	colorbar;
	title('sqBOLD OEF')	
	
	subplot(212)
	imagesc(flipud(reshape(hqOEF(:,:,2:3:9),96,96*3)).*100,[0 100]);
	colormap(cmapry);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	colorbar;
	title('hqBOLD OEF')	

	