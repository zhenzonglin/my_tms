clear;clc;close all;
%% check GCM
workdir = 'C:\1_UP\MRI\sy\Pre\36BNTG_day3\part2_timeseries\dataPost';
cd(workdir);
load([workdir '\group_glm2\GCM_DCM.mat'])
spm_dcm_fmri_check(GCM);
%% design matrix
N1 = 12;
N2 = 12;
C1 = ones(N1+N2,1);
C2 = [ones(N1,1);-ones(N2,1)];
C2 = C2 - mean(C2);  %除C1外，其他都需要减均值
C = [C1, C2];
%%
matlabbatch{1}.spm.dcm.peb.specify.name = 'DCM';
matlabbatch{1}.spm.dcm.peb.specify.model_space_mat = {'C:\1_UP\MRI\sy\Pre\36BNTG_day3\part2_timeseries\dataPost\group_glm2\GCM_DCM.mat'};
matlabbatch{1}.spm.dcm.peb.specify.dcm.index = 1;
matlabbatch{1}.spm.dcm.peb.specify.cov.design_mtx.cov_design = C;
matlabbatch{1}.spm.dcm.peb.specify.cov.design_mtx.name = {
    'mean'
    'diff'
    }';
matlabbatch{1}.spm.dcm.peb.specify.fields.custom = {'A'};
%
matlabbatch{2}.spm.dcm.peb.reduce_all.peb_mat(1) = cfg_dep('Specify / Estimate PEB: PEB mat File(s)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','peb_mat'));
matlabbatch{2}.spm.dcm.peb.reduce_all.model_space_mat = {[workdir '\group_glm2\GCM_DCM.mat']};
matlabbatch{2}.spm.dcm.peb.reduce_all.nullpcov = 0;
matlabbatch{2}.spm.dcm.peb.reduce_all.show_review = 1;
%
spm_jobman('run',matlabbatch);

%% group mean

Eq1 = xPEB.Eq;
Pp1 = reshape(xPEB.Pp, size(Eq1));

save results1_group_mean.mat Eq1 Pp1

%% group difference--主要

Eq2 = xPEB.Eq;
Pp2 = reshape(xPEB.Pp, size(Eq2));

save results2_group_difference.mat Eq2 Pp2