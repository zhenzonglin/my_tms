clear;clc;close all;
spm_get_defaults('cmdline', true);
global defaults
defaults.cmdline = true;
%%
workdir = 'C:\1_UP\MRI\sy\Pre\36BNTG_day3\part2_timeseries\dataPost';
spmdir = [workdir, filesep, 'group_glm2'];
dcm_tmp = 'C:\1_UP\MRI\sy\Pre\36BNTG_day3\part2_timeseries\dataPost\group_glm2\sub-00\DCM_temp.mat';
%
spmfile_dir = dir(fullfile(spmdir,'**','SPM.mat'));
spmfile = fullfile({spmfile_dir.folder},{spmfile_dir.name}).';
signfile = dir(fullfile(spmdir,'**','VOI_ROI1_1.mat'));
ROI1sign = fullfile({signfile.folder},{signfile.name}).';
signfile = dir(fullfile(spmdir,'**','VOI_ROI2_1.mat'));
ROI2sign = fullfile({signfile.folder},{signfile.name}).';
signfile = dir(fullfile(spmdir,'**','VOI_ROI3_1.mat'));
ROI3sign = fullfile({signfile.folder},{signfile.name}).';
signfile = dir(fullfile(spmdir,'**','VOI_ROI4_1.mat'));
ROI4sign = fullfile({signfile.folder},{signfile.name}).';
%%
matlabbatch{1}.spm.dcm.spec.fmri.group.output.dir = {spmdir};
matlabbatch{1}.spm.dcm.spec.fmri.group.output.name = 'DCM';
matlabbatch{1}.spm.dcm.spec.fmri.group.template.fulldcm = {dcm_tmp};
matlabbatch{1}.spm.dcm.spec.fmri.group.data.spmmats = spmfile;
matlabbatch{1}.spm.dcm.spec.fmri.group.data.session = 1;
matlabbatch{1}.spm.dcm.spec.fmri.group.data.region = {
    ROI1sign
    ROI2sign
    ROI3sign
    ROI4sign
    }';
%%
matlabbatch{2}.spm.dcm.estimate.dcms.gcmmat(1) = cfg_dep('Specify group: GCM mat File(s)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','gcmmat'));
matlabbatch{2}.spm.dcm.estimate.output.separate = struct([]);
matlabbatch{2}.spm.dcm.estimate.est_type = 1;
matlabbatch{2}.spm.dcm.estimate.fmri.analysis = 'csd';
%%
spm_jobman('run',matlabbatch);