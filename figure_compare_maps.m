function figure_compare_maps(src)

	slice_no=5;
	num_subj=10;

	for k=1:num_subj
	%k=1
	
		subj_id=['sub-' sprintf('%02d',k)];
		disp(subj_id);
	
		% Load hqBOLD results
		[dbv,dims,scales,bpp,endian]  = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_dbv']);
		oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_hcqbold_oef']);
		
		hqbold_dbv_map(:,:,k) = rot90(dbv(:,:,slice_no));
		hqbold_oef_map(:,:,k) = rot90(oef(:,:,slice_no));
		
		% Load sqBOLD results
		[dbv,dims,scales,bpp,endian]  = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_dbv']);
		oef = read_avw([src '/derivatives/' subj_id '/' subj_id '_sqbold_oef']);
		
		sqbold_dbv_map(:,:,k) = rot90(dbv(:,:,slice_no));
		sqbold_oef_map(:,:,k) = rot90(oef(:,:,slice_no));

	end
	
	% Reshape into n slices	
	hqbold_dbv_map = reshape(hqbold_dbv_map,dims(1),dims(2)*num_subj);
	hqbold_oef_map = reshape(hqbold_oef_map,dims(1),dims(2)*num_subj);
	sqbold_dbv_map = reshape(sqbold_dbv_map,dims(1),dims(2)*num_subj);
	sqbold_oef_map = reshape(sqbold_oef_map,dims(1),dims(2)*num_subj);

	scrnsz = get(0,'screensize');
	figdims = [1500 150];

	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(hqbold_dbv_map,[0 0.1]);
	colorbar
	colormap('jet')
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('GM hqBOLD DBV')
	
	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(hqbold_oef_map.*(hqbold_oef_map<1).*(hqbold_oef_map>0),[0 1]);
	colorbar
	colormap('hot')
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('GM hqBOLD OEF')

	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(sqbold_dbv_map,[0 0.1]);
	colorbar
	colormap('jet')
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('GM sqBOLD DBV')
	
	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(sqbold_oef_map.*(sqbold_oef_map<1).*(sqbold_oef_map>0),[0 1]);
	colorbar
	colormap('hot')
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('GM sqBOLD OEF')
	
	keyboard;