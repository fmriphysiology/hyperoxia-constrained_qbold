function run_snr(src,subj_id)

%% Load ASE dataset
ase1 = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_merge_img1']);
asediff = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_merge_imgdiff']);
asemask = read_avw([src '/derivatives/' subj_id '/' subj_id '_gase_merge_ref_bet_ero']);

asesnr = mean(ase1(asemask>0))./std(asediff(asemask>0)).*sqrt(2)

%% Load BOLD dataset
bold1 = read_avw([src '/derivatives/' subj_id '/' subj_id '_bold_mcf_img1']);
bolddiff = read_avw([src '/derivatives/' subj_id '/' subj_id '_bold_mcf_imgdiff']);
boldmask = read_avw([src '/derivatives/' subj_id '/' subj_id '_bold_ref_bet_ero']);

boldsnr = mean(bold1(boldmask>0))./std(bolddiff(boldmask>0)).*sqrt(2)

srcout=[src '/derivatives/' subj_id '/'];

dlmwrite([srcout subj_id '_ase_snr.txt'],asesnr);
dlmwrite([srcout subj_id '_bold_snr.txt'],boldsnr);