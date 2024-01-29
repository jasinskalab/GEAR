%% Add NIRS Toolbox to your path
addpath(genpath('/Users/shakhlonematova/Documents/MATLAB/nirs-toolbox-master'));

%% Put stims in s

nirs_files=dir('./**/*.nirs');
fprintf('I found %g files with .nirs extension.\n',length(nirs_files));

for f_idx = 1:length(nirs_files)
    
    filename = '';
    
    filename = [nirs_files(f_idx).folder filesep nirs_files(f_idx).name];
    
    % load the file into x
    
    x = load(filename,'-mat')
    
    % convert aux to s
    x.s = zeros([size(x.aux), max(x.aux)]);
    for stim_idx = 1:max(x.aux)
        x.s(:,stim_idx) = (x.aux==stim_idx);
    end
    
   
    % Save over the old file
    save( filename, '-struct', 'x')

end

%% Import data
raw = nirs.io.loadDirectory('.',{'subject','task'});

try 
    save(['/raw_' date '.mat'],'raw');
catch
    save(['raw_' date '.mat'],'raw');
end


%% Change the duration of stimulus from 0.1 to 60s
duration = 60;
raw_stimdur = nirs.design.change_stimulus_duration(raw,'stim_channel1',duration); %do it for all three tasks (English. Hindi, Tone)
raw = nirs.viz.StimUtil(raw_stimdur);

%% Add demographics
nirs.createDemographicsTable(raw)
% and now manually change the demographics table in Excel
demographics = readtable(fullfile('/Volumes/data/Data/GEAR/GEAR_PD/NIRS_analysis/CI_demotable.xlsx'))
job_demo = nirs.modules.AddDemographics
job_demo.demoTable=demographics;
raw = job_demo.run(raw);
nirs.createDemographicsTable(raw)

%% Preprocess the data using NIRS Toolbox / Homer2
% If you prefer to apply your own preprocessing procedures, you
% can call Homer2 functions from NIRS Toolbox and run them as jobs.
% Standard procedure in NIRS Toolbox does not apply motion correction or
% bandpass filtering because the AR-IRLS model is *supposed* to handle
% signal quality issues.
preproc1 = nirs.modules.OpticalDensity;
preproc1 = nirs.modules.FixFlatChans(preproc1); %with adjusted values in FixFlatChans for bad channels
preproc1 = nirs.modules.FixNaNs(preproc1);
raw = preproc1.run(raw);
% The build-in BeerLambertLaw module produces 0-value channels which
% crashes the GLM model. My version doesn't.
preproc2 = BeerLambertLaw_nLambda();
%preproc2 = nirs.modules.Resample(preproc2);
if exist('raw_hmr','var')
    HB_data = preproc2.run(raw_hmr);
else
    HB_data = preproc2.run(raw);
end

%% Subject level GLM to estimate task-level effects
glm_job = nirs.modules.GLM;
glm_job.type = '?';
glm_job.type = 'AR-IRLS'
SubjectLevelStats = glm_job.run(HB_data); 

try
    save(['/GLM_' date '.mat'],'SubjectLevelStats');
catch
    save(['GLM_' date '.mat'],'SubjectLevelStats');
end


%% LME to test across subjects
lme_job = nirs.modules.MixedEffects;
lme_job.formula='beta ~-1 + task+AgeCI+AgeASL+ AgeCI: AgeASL + AgeCI:task+ AgeASL:task+ AgeCI: AgeASL:task+(1|subject)';
lme_job.dummyCoding = 'effect';
HbModel = lme_job.run(SubjectLevelStats);
HbModel.draw('tstat',[],'q<0.05')
HbModel.table

%% Interaction interpretations for CI group only
%%Adjust values in demographics table to make interactions interpretable
demo_table = nirs.createDemographicsTable(SubjectLevelStats)
% manually change the demographics table to center on ASL or CI age of interest
%ASL -- mean=8.58, -1SD=1, +1SD=16.21;
%CI -- mean=8.5, -1SD=2.3, +1SD=14.6;
age_of_interest = 2.3;
lang_to_exclude = 'Tone';
demo_table.age_ci = demo_table.age_asl - age_of_interest;
job_demo = nirs.modules.AddDemographics;
job_demo.demoTable=demo_table;
job_demo.varToMatch={'subject','task'};
SubjectLevelStats_adj = job_demo.run(SubjectLevelStats);
SubjectLevelStats_adj = SubjectLevelStats_adj(...
    ~arrayfun(@(x) strcmp(x.demographics('task'),lang_to_exclude), SubjectLevelStats_adj));
nirs.createDemographicsTable(SubjectLevelStats_adj)

%% Same LME model for post-hoc testing
lme_job = nirs.modules.MixedEffects;
lme_job.centerVars = 0;
lme_job.formula='beta ~-1 + task+AgeCI+AgeASL+ AgeCI:AgeASL + AgeCI:task+ AgeASL:task+ AgeCI: AgeASL:task+(1|subject)';
lme_job.dummyCoding = 'effect';
HbModel_adj = lme_job.run(SubjectLevelStats_adj);
HbModel_adj.draw('tstat',[],'q<0.05')
HbModel_adj.table

%% ===========Correlation between neural and behavioral results==============

%% Add behavioral results in demographics
nirs.createDemographicsTable(SubjectLevelStats)
% and now manually change the demographics table in Excel
demographics = readtable(fullfile('/demotable.xlsx'))
job_demo = nirs.modules.AddDemographics
job_demo.demoTable=demographics;
Stats_wbeh = job_demo.run(SubjectLevelStats);
nirs.createDemographicsTable(Stats_wbeh)
%% Analyze results
lme_job = nirs.modules.MixedEffects;
lme_job.formula='beta ~-1 +task:d_score+(1|subject)';
lme_job.dummyCoding = 'full';
HbModel = lme_job.run(Stats_wbeh);
HbModel.table



