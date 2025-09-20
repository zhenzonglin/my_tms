clear;clc;close all;
%%
workdir = 'C:\1_UP\MRI\sy\Pre\36BNTG_day3\part2_timeseries\dataPost';
mkdir([workdir, filesep, 'group_glm2'])
TR = 2;
mask1 = 'C:\1_UP\MRI\sy\36BNTG_day3\part1_spDCM_sub\glm\ispi_PuM3_mask.nii,1';
mask2 = 'C:\1_UP\MRI\sy\36BNTG_day3\part1_spDCM_sub\glm\ispi_PuM4_mask.nii,1';
mask3 = 'C:\1_UP\MRI\sy\36BNTG_day3\part1_spDCM_sub\glm\ispi_PuM5_mask.nii,1';
mask4 = 'C:\1_UP\MRI\sy\36BNTG_day3\part1_spDCM_sub\glm\r377.L.PuM.nii,1';
%%
name_subj = dir([workdir, filesep, 'sub*']);

for s0 = 1 : length(name_subj)

    subj_dir = [workdir, filesep, name_subj(s0).name];

    f = spm_select('FPList', subj_dir , '^SWRA.*\.nii$');
    rp_file = dir([subj_dir, filesep, 'rp*']);

    clear matlabbatch
	close all

    glmdir = fullfile(subj_dir,'glm1');
    if ~exist(glmdir,'file'), mkdir(glmdir); end
    
    % First GLM specification
    %-----------------------------------------------------------------
    matlabbatch{1}.spm.stats.fmri_spec.dir = {glmdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(f);

    % First GLM estimation
    %-----------------------------------------------------------------
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(glmdir,'SPM.mat')};

    % Extraction of time series from WM and CSF
    %-----------------------------------------------------------------
    matlabbatch{3}.spm.util.voi.spmmat = {fullfile(glmdir,'SPM.mat')};
    matlabbatch{3}.spm.util.voi.adjust = NaN;
    matlabbatch{3}.spm.util.voi.session = 1;
    matlabbatch{3}.spm.util.voi.name = 'CSF';
    matlabbatch{3}.spm.util.voi.roi{1}.sphere.centre = [0 -40 -5]; 
    matlabbatch{3}.spm.util.voi.roi{1}.sphere.radius = 6;
    matlabbatch{3}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
    matlabbatch{3}.spm.util.voi.roi{2}.mask.image = {fullfile(glmdir,'mask.nii')};
    matlabbatch{3}.spm.util.voi.expression = 'i1 & i2';

    matlabbatch{4} = matlabbatch{3};
    matlabbatch{4}.spm.util.voi.name = 'WM';
    matlabbatch{4}.spm.util.voi.roi{1}.sphere.centre = [0 -24 -33];
    

    % Second GLM specification
    %-----------------------------------------------------------------
    glmdir = fullfile(subj_dir,'glm2');
    if ~exist(glmdir,'file'), mkdir(glmdir); end

    matlabbatch{5}.spm.stats.fmri_spec.dir = {glmdir};
    matlabbatch{5}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{5}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{5}.spm.stats.fmri_spec.sess.scans = cellstr(f);
    matlabbatch{5}.spm.stats.fmri_spec.sess.multi_reg = {
        fullfile(subj_dir, rp_file.name),...
        fullfile(subj_dir,'glm1','VOI_CSF_1.mat'),...
        fullfile(subj_dir,'glm1','VOI_WM_1.mat'),...
        }';

    % Second GLM estimation
    %-----------------------------------------------------------------
    matlabbatch{6}.spm.stats.fmri_est.spmmat = {fullfile(glmdir,'SPM.mat')};

    % Extraction of time series from specific nodes
    %-----------------------------------------------------------------
    matlabbatch{7}.spm.util.voi.spmmat = {fullfile(glmdir,'SPM.mat')};
    matlabbatch{7}.spm.util.voi.adjust = NaN;
    matlabbatch{7}.spm.util.voi.session = 1;
    matlabbatch{7}.spm.util.voi.name = 'ROI1';
    matlabbatch{7}.spm.util.voi.roi{1}.mask.image = {mask1};
    matlabbatch{7}.spm.util.voi.roi{1}.mask.threshold = 0.5;
    matlabbatch{7}.spm.util.voi.roi{2}.mask.image = {fullfile(glmdir,'mask.nii')};
    matlabbatch{7}.spm.util.voi.expression = 'i1 & i2';

    matlabbatch{8} = matlabbatch{7};
    matlabbatch{8}.spm.util.voi.name = 'ROI2';
    matlabbatch{8}.spm.util.voi.roi{1}.mask.image = {mask2};
   
    matlabbatch{9} = matlabbatch{7};
    matlabbatch{9}.spm.util.voi.name = 'ROI3';
    matlabbatch{9}.spm.util.voi.roi{1}.mask.image = {mask3};
    
    matlabbatch{10} = matlabbatch{7};
    matlabbatch{10}.spm.util.voi.name = 'ROI4';
    matlabbatch{10}.spm.util.voi.roi{1}.mask.image = {mask4};
    %%
    spm_jobman('run',matlabbatch);

    
    group_glm2_dir = [workdir, filesep, 'group_glm2', filesep, name_subj(s0).name];
    mkdir(group_glm2_dir)
    copyfile([glmdir, filesep, '*mat'], group_glm2_dir)

end

