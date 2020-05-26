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

	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(hqbold_dbv_map.*100,[0 8]);
	colorbar('NorthOutside')
	cmap=colormap('jet');
	cmap(1,:)=[0 0 0];
	colormap(cmap);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('hqBOLD DBV')
	
	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(hqbold_oef_map.*(hqbold_oef_map<1).*(hqbold_oef_map>0).*100,[0 100]);
	colorbar('NorthOutside')
	colormap('hot')
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('hqBOLD OEF')

	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(sqbold_dbv_map.*100,[0 8]);
	colorbar('NorthOutside')
	%colormap('jet')
	colormap(cmap);
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('sqBOLD DBV')
	
	h=figure;
	set(h,'Position',[scrnsz(3)/2-figdims(1)/2 scrnsz(4)/2-figdims(2)/2 figdims(1) figdims(2)])
	imagesc(sqbold_oef_map.*(sqbold_oef_map<1).*(sqbold_oef_map>0).*100,[0 100]);
	colorbar('NorthOutside')
	colormap('hot')
	set(gca,'xticklabel',[])
	set(gca,'yticklabel',[])
	axis image
	title('sqBOLD OEF')
	