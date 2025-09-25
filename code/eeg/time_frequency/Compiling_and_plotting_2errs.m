%% This script compiles a dataset with all conditions and all participants 
%and plots results as time frequency surfaces and topo plots

clear
clc;

%% MUST EDIT THIS
main_dir = '/home/data/NDClab/datasets/mfe-jr-dataset'; %directory on the HPC

%% 1. Data Location - this is the location of the .mat files for each participant for each condition
data_location = '/home/data/NDClab/datasets/mfe-jr-dataset/derivatives/eeg/TF_outputs/main_2errs';

% 2. Save Location - this is the location where you would like your
% datasets to be stored. We recommend this to be in a separate folder than
% where the .mat files are stored.
save_location = '/home/data/NDClab/datasets/mfe-jr-dataset/derivatives/eeg/TF_outputs/compiled_2errs/';
plot_save_location = '/home/data/NDClab/datasets/mfe-jr-dataset/derivatives/eeg/TF_outputs/plots_2errs/';


% 3. Set EEGLab path
addpath(genpath([main_dir filesep 'code' filesep 'eeg' filesep 'preprocessing' filesep 'eeglab2023']));% enter the path of the EEGLAB folder in this line


% 4. Is this resting or event-related data?
RestorEvent = 0; %1=rest, 0=event-related

% 5. Conditions for Event-Related Data - this should be the same name used in the main script
Conds = {'resp_i_0','resp_i_1'}; %leave blank if resting data

% 6. Name of Conditions to be used for plotting - this such make the order
% that the conditions are named above
ConditionNames = {'Incong error response' 'Incong correct response'}; %If resting, just put one condition name here (e.g., Resting)

% 7. Was TF baseline corrected?
TF_bln = 1; %0=no, 1=yes

% 8. Did you calculate ITPS and want it compiled and plotted?
ITPS_calc = 1; %0=no, 1=yes
% 8a. Was ITPS baseline corrected? 
ITPS_bln =1; %0=no, 1=yes

% 9. Did you calculate ICPS and want it compiled and plotted?
ICPS_calc = 0; %0=no, 1=yes
% 9a. Was ICPS baseline corrected? 
ICPS_bln = 1; %0=no, 1=yes

% 10. Did you calculate wPLI and want it compiled and plotted?
wPLI_calc = 1; %0=no, 1=yes
% 10a. Was wPLI baseline corrected? 
wPLI_bln = 1; %0=no, 1=yes

% 11. Did you downsample your data?
Downsample = 1; %0=no; 1=yes

%% Settings for Time Frequency Surface Plots
% 12. What time period (e.g., epoch length) would you like plotted on the x axis?
time_window_surface = [-1000 1000]; 
% 13. What frequency range would you like plotted on the y axis?
freq_window_surface = [1 12]; 

% 14. Choose which channels to plot for TF surface. (If more than one electrode, then those electrodes will be averaged).
% Theta (4-7 Hz); elecs [1 2 34 33]; time [0-250] || MFC
% Theta (4-7 Hz); elecs [22 53 24 55]; time [0-250] || posterior

%chans2plot_TF = {'1'};  % MFC 1
chans2plot_TF = {'1' '2' '34' '33'}; %MFC_cluster
%chans2plot_TF = {'22' '53' '24' '55'}; % posterior

% 15. Choose which channels to plot for ITPS surface. (If more than one electrode, then those electrodes will be averaged).
%chans2plot_ITPS =  {'1'};    
chans2plot_ITPS =  {'1' '2' '34' '33'};  
%chans2plot_ITPS = {'22' '53' '24' '55'};

% Choose plotting parameters for ICPS and wPLI 
% 16. If you have used an all-to-all approach, you will need to designate a seed for plotting. 
Seed = {'1'};
% 17. Choose which channels to plot. NOTE: This should not include the seed. 
chans2plot_ICPSwpli = {'22' '53' '24' '55'}; % posterior



%% Settings for Topo Plots
% 18. Choose what time period to average over for the topo plot. NOTE: It
% is probably advantageous to examine the TF surfaces first before choosing this time period.
time_window_for_topo = [0 250]; 

% 19. Choose what frequency range to average over for the topo plot. NOTE:
%This is probably an apriori decision based on hypotheses.
freq_window_for_topo = [4 7]; % Theta

% File list
cd(data_location)
subnum=dir('*.mat');
sub_list={subnum.name};
for i =1:length(sub_list)
    sub = sub_list{i};
    % subject_list{i}= sub(1:end-11);
    subjects{i}= sub(1:end-4);
end
unique_subjects=unique(extractBefore(subjects,'_'));

%%%%%%%%%%%%%%%% PLOTTING STARTS BELOW HERE %%%%%%%%%%%%%%%%%%%
% Looping to create a file that has all subjects' matrices in them
for subj = 1:length(unique_subjects)
    
    %%%%%%%%%% COMPILE TIME FREQUENCY DATA %%%%%%%%%%%%%%%%%
    fprintf('\n\n\n*** Processing subject %s ***\n\n\n', char(unique_subjects(subj)));
    if RestorEvent==0 %if event-related
        for cond=1:length(Conds)
            timefreqs_baselinecorr=[];
            timefreqs_data=[];
            %Find files for this subject
            sub_file_list =   contains(subjects,unique_subjects{subj});
            currentsubs = subjects(sub_file_list);
            %Find TF files for this subjects
            tf_file_list =  contains(currentsubs,'TF');
            currentTF = currentsubs(tf_file_list);
            %Find current condition TF files for this subject
            cond_file_list = contains(currentTF, Conds{cond});
            currentcond = char(currentTF(cond_file_list));
            
            %load appropriate file
            cd(data_location)
            load([currentcond '.mat']);
            
            
            if TF_bln ==1 % if baseline corrected
                if subj == 1 && cond ==1
                    TF_allsubs = zeros(length(unique_subjects), length(Conds),size(timefreqs_baselinecorr,1),size(timefreqs_baselinecorr,2),size(timefreqs_baselinecorr,3));
                    TF_allsubs(subj,cond,:,:,:)=timefreqs_baselinecorr;
                else
                    TF_allsubs(subj,cond,:,:,:)=timefreqs_baselinecorr;
                end
            elseif TF_bln==0 %if not baseline corrected
                if subj == 1 && cond ==1
                    TF_allsubs = zeros(length(unique_subjects), length(Conds),size(timefreqs_data,1),size(timefreqs_data,2),size(timefreqs_data,3));
                    TF_allsubs(subj,cond,:,:,:)=timefreqs_data;
                else
                    TF_allsubs(subj,cond,:,:,:)=timefreqs_data;
                end
            end  %end if baseline corrected
        end %end loop through conds
    elseif RestorEvent==1 %if resting data
        timefreqs_baselinecorr=[];
        timefreqs_data=[];
        %Find files for this subject
        sub_file_list =   contains(subjects,unique_subjects{subj});
        currentsubs = subjects(sub_file_list);
        %Find TF file for this subject (should only be 1 since only 1
        %condition in resting)
        tf_file_list =  contains(currentsubs,'TF');
        currentTF = currentsubs(tf_file_list);
        %Load file
        cd(data_location)
        load([currentTF '.mat']);
        
        if TF_bln ==1 %if baseline corrected
            if subj == 1
                TF_allsubs = zeros(length(unique_subjects),size(timefreqs_baselinecorr,1),size(timefreqs_baselinecorr,2),size(timefreqs_baselinecorr,3));
                TF_allsubs(subj,:,:,:)=timefreqs_baselinecorr;
            else
                TF_allsubs(subj,:,:,:)=timefreqs_baselinecorr;
            end
        elseif TF_bln==0 %if not baseline corrected
            if subj == 1
                TF_allsubs = zeros(length(unique_subjects), size(timefreqs_data,1),size(timefreqs_data,2),size(timefreqs_data,3));
                TF_allsubs(subj,:,:,:)=timefreqs_data;
            else
                TF_allsubs(subj,:,:,:)=timefreqs_data;
            end
        end %end if baseline corrected
    end %end if Resting or event
    

    %%%%%%%%%% COMPILE ITPS DATA %%%%%%%%%%%%%%%%%
    if ITPS_calc == 1 %only run if ITPS was calculated
        if RestorEvent==0 %if event-related
            for cond=1:length(Conds)
                ITPS_blncorr=[]; ITPS_all=[];
                
                sub_file_list =   contains(subjects,unique_subjects{subj});
                currentsubs = subjects(sub_file_list);
                itps_file_list =  contains(currentsubs,'ITPS');
                currentITPS = currentsubs(itps_file_list);
                
                
                cond_file_list = contains(currentITPS, Conds{cond});
                currentcond = char(currentITPS(cond_file_list));
                
                cd(data_location)
                load([currentcond '.mat']);
                
                if ITPS_bln == 1 %chose to baseline correct
                    if subj == 1 && cond ==1
                        ITPS_allsubs = zeros(length(unique_subjects), length(Conds),size(ITPS_blncorr,1),size(ITPS_blncorr,2),size(ITPS_blncorr,3));
                        ITPS_allsubs(subj,cond,:,:,:)=ITPS_blncorr;
                    else
                        ITPS_allsubs(subj,cond,:,:,:)=ITPS_blncorr;
                    end
                elseif ITPS_bln == 0 %chose not to baseline correct
                    if subj == 1 && cond ==1
                        ITPS_allsubs = zeros(length(unique_subjects), length(Conds),size(ITPS_all,1),size(ITPS_all,2),size(ITPS_all,3));
                        ITPS_allsubs(subj,cond,:,:,:)=ITPS_all;
                    else
                        ITPS_allsubs(subj,cond,:,:,:)=ITPS_all;
                    end
                end %end if ITPS was baseline corrected
            end %end loop through conditions
        elseif RestorEvent==1
            ITPS_blncorr=[]; ITPS_all=[];
            
            sub_file_list =   contains(subjects,unique_subjects{subj});
            currentsubs = subjects(sub_file_list);
            itps_file_list =  contains(currentsubs,'ITPS');
            currentITPS = currentsubs(itps_file_list);
            
            cd(data_location)
            load([currentITPS '.mat']);
            if ITPS_bln == 1 %chose to baseline correct
                if subj == 1
                    ITPS_allsubs = zeros(length(unique_subjects), size(ITPS_blncorr,1),size(ITPS_blncorr,2),size(ITPS_blncorr,3));
                    ITPS_allsubs(subj,:,:,:)=ITPS_blncorr;
                else
                    ITPS_allsubs(subj,:,:,:)=ITPS_blncorr;
                end
            elseif ITPS_bln == 0 %chose not to baseline correct
                if subj == 1
                    ITPS_allsubs = zeros(length(unique_subjects), size(ITPS_all,1),size(ITPS_all,2),size(ITPS_all,3));
                    ITPS_allsubs(subj,:,:,:)=ITPS_all;
                else
                    ITPS_allsubs(subj,:,:,:)=ITPS_all;
                end
            end %end if ITPS was baseline corrected
        end %end if rest or event
    end %end if ITPS was calculated
    
    
    %%%%%%%%%% COMPILE ICPS DATA %%%%%%%%%%%%%%%%%
    if ICPS_calc == 1
        if RestorEvent==0 %if event-related
            for cond=1:length(Conds)
                ICPS_blncorr=[]; ICPS_all=[];
                
                sub_file_list =   contains(subjects,unique_subjects{subj});
                currentsubs = subjects(sub_file_list);
                icps_file_list =  contains(currentsubs,'ICPS');
                currentICPS = currentsubs(icps_file_list);
                
                cond_file_list = contains(currentICPS, Conds{cond});
                currentcond = char(currentICPS(cond_file_list));
                
                cd(data_location)
                load([currentcond '.mat']);
                
                if ICPS_bln == 1 %chose to baseline correct
                    X = ndims(ICPS_blncorr);
                    if X == 3 %seed-based output
                        if subj == 1 && cond ==1
                            ICPS_allsubs = zeros(length(unique_subjects), length(Conds),size(ICPS_blncorr,1),size(ICPS_blncorr,2),size(ICPS_blncorr,3));
                            ICPS_allsubs(subj,cond,:,:,:)=ICPS_blncorr;
                        else
                            ICPS_allsubs(subj,cond,:,:,:)=ICPS_blncorr;
                        end
                    elseif X ==4 %all-to-all output
                        %Find seed index
                        Seed_idx= find(strcmp({channel_location.labels}, Seed));
                        %Pull out ICPS values between each electrode and the seed
                        ICPS_blncorr_seed = squeeze(ICPS_blncorr(:,:,:,Seed_idx));
                        if subj == 1 && cond ==1
                            ICPS_allsubs = zeros(length(unique_subjects), length(Conds),size(ICPS_blncorr_seed,1),size(ICPS_blncorr_seed,2),size(ICPS_blncorr_seed,3));
                            ICPS_allsubs(subj,cond,:,:,:)=ICPS_blncorr_seed;
                        else
                            ICPS_allsubs(subj,cond,:,:,:)=ICPS_blncorr_seed;
                        end
                    end
                elseif ICPS_bln == 0 %chose not to baseline correct
                    X = ndims(ICPS_all);
                    if X ==3 %seed-based output
                        if subj == 1 && cond ==1
                            ICPS_allsubs = zeros(length(unique_subjects), length(Conds),size(ICPS_all,1),size(ICPS_all,2),size(ICPS_all,3));
                            ICPS_allsubs(subj,cond,:,:,:)=ICPS_all;
                        else
                            ICPS_allsubs(subj,cond,:,:,:)=ICPS_all;
                        end
                    elseif X ==4 %all-to-all output
                        %Find seed index
                        Seed_idx= find(strcmp({channel_location.labels}, Seed));
                        %Pull out ICPS values between each electrode and the seed
                        ICPS_all_seed = squeeze(ICPS_all(:,:,:,Seed_idx));
                        if subj == 1 && cond ==1
                            ICPS_allsubs = zeros(length(unique_subjects), length(Conds),size(ICPS_all_seed,1),size(ICPS_all_seed,2),size(ICPS_all_seed,3));
                            ICPS_allsubs(subj,cond,:,:,:)=ICPS_all;
                        else
                            ICPS_allsubs(subj,cond,:,:,:)=ICPS_all;
                        end
                    end %end if seed or all-to-all
                end %end if ICPS was baseline corrected
            end %end loop through conditions
            
        elseif RestorEvent==1
            sub_file_list =   contains(subjects,unique_subjects{subj});
            currentsubs = subjects(sub_file_list);
            icps_file_list =  contains(currentsubs,'ICPS');
            currentICPS = currentsubs(icps_file_list);
            
            cd(data_location)
            load([currentICPS '.mat']);
            if ICPS_bln == 1 %chose to baseline correct
                X = ndims(ICPS_blncorr);
                if X == 3 %seed-based output
                    if subj == 1
                        ICPS_allsubs = zeros(length(unique_subjects),size(ICPS_blncorr,1),size(ICPS_blncorr,2),size(ICPS_blncorr,3));
                        ICPS_allsubs(subj,:,:,:)=ICPS_blncorr;
                    else
                        ICPS_allsubs(subj,:,:,:)=ICPS_blncorr;
                    end
                elseif X ==4 %all-to-all output
                    %Find seed index
                    Seed_idx= find(strcmp({channel_location.labels}, Seed));
                    %Pull out ICPS values between each electrode and the seed
                    ICPS_blncorr_seed = squeeze(ICPS_blncorr(:,:,:,Seed_idx));
                    if subj == 1
                        ICPS_allsubs = zeros(length(unique_subjects), size(ICPS_blncorr_seed,1),size(ICPS_blncorr_seed,2),size(ICPS_blncorr_seed,3));
                        ICPS_allsubs(subj,:,:,:)=ICPS_blncorr_seed;
                    else
                        ICPS_allsubs(subj,:,:,:)=ICPS_blncorr_seed;
                    end
                end
            elseif ICPS_bln == 0 %chose not to baseline correct
                X = ndims(ICPS_all);
                if X ==3 %seed-based output
                    if subj == 1
                        ICPS_allsubs = zeros(length(unique_subjects), size(ICPS_all,1),size(ICPS_all,2),size(ICPS_all,3));
                        ICPS_allsubs(subj,:,:,:)=ICPS_all;
                    else
                        ICPS_allsubs(subj,:,:,:)=ICPS_all;
                    end
                elseif X ==4 %all-to-all output
                    %Find seed index
                    Seed_idx= find(strcmp({channel_location.labels}, Seed));
                    %Pull out ICPS values between each electrode and the seed
                    ICPS_all_seed = squeeze(ICPS_all(:,:,:,Seed_idx));
                    if subj == 1
                        ICPS_allsubs = zeros(length(unique_subjects),size(ICPS_all_seed,1),size(ICPS_all_seed,2),size(ICPS_all_seed,3));
                        ICPS_allsubs(subj,:,:,:)=ICPS_all;
                    else
                        ICPS_allsubs(subj,:,:,:)=ICPS_all;
                    end
                end %end if seed or all-to-all
            end %end if ICPS was baseline corrected
        end% end if rest or event
    end %end if ICPS was calculated
      %%%%%%%%%% COMPILE wPLI DATA %%%%%%%%%%%%%%%%%

      if wPLI_calc == 1
          if RestorEvent==0
              for cond=1:length(Conds)
                  wPLI_blncorr=[]; wPLI_all=[];
                  
                  sub_file_list =   contains(subjects,unique_subjects{subj});
                  currentsubs = subjects(sub_file_list);
                  wpli_file_list =  contains(currentsubs,'wPLI');
                  currentwpli = currentsubs(wpli_file_list);
                  
                  
                  cond_file_list = contains(currentwpli, Conds{cond});
                  currentcond = char(currentwpli(cond_file_list));
                  
                  cd(data_location)
                  load([currentcond '.mat']);
                  
                  
                  
                  if wPLI_bln == 1 %chose to baseline correct
                      X = ndims(wPLI_blncorr);
                      if X == 3 %for seed-based output
                          if subj == 1 && cond ==1
                              wpli_allsubs = zeros(length(unique_subjects), length(Conds),size(wPLI_blncorr,1),size(wPLI_blncorr,2),size(wPLI_blncorr,3));
                              wpli_allsubs(subj,cond,:,:,:)=wPLI_blncorr;
                          else
                              wpli_allsubs(subj,cond,:,:,:)=wPLI_blncorr;
                          end
                      elseif X ==4 %for all-to-all output
                          %Find seed index
                          Seed_idx= find(strcmp({channel_location.labels}, Seed));
                          %Pull out ICPS values between each electrode and the seed
                          wPLI_blncorr_seed = squeeze(wPLI_blncorr(:,:,:,Seed_idx));
                          if subj == 1 && cond ==1
                              wpli_allsubs = zeros(length(unique_subjects), length(Conds),size(wPLI_blncorr_seed,1),size(wPLI_blncorr_seed,2),size(wPLI_blncorr_seed,3));
                              wpli_allsubs(subj,cond,:,:,:)=wPLI_blncorr;
                          else
                              wpli_allsubs(subj,cond,:,:,:)=wPLI_blncorr;
                          end
                      end
                  elseif wPLI_bln == 0 %chose not to baseline correct
                      X = ndims(wPLI_all);
                      if X == 3 %seed-based analyses
                          if subj == 1 && cond ==1
                              wpli_allsubs = zeros(length(unique_subjects), length(Conds),size(wPLI_all,1),size(wPLI_all,2),size(wPLI_all,3));
                              wpli_allsubs(subj,cond,:,:,:)=wPLI_all;
                          else
                              wpli_allsubs(subj,cond,:,:,:)=wPLI_all;
                          end
                      elseif X ==4 %all-to-all analyses
                          %Find seed index
                          Seed_idx= find(strcmp({channel_location.labels}, Seed));
                          %Pull out ICPS values between each electrode and the seed
                          wPLI_all_seed = squeeze(wPLI_all(:,:,:,Seed_idx));
                          if subj == 1 && cond ==1
                              %initialize matrix if first condition for first subject only
                              wpli_allsubs = zeros(length(unique_subjects), length(Conds),size(wPLI_all_seed,1),size(wPLI_all_seed,2),size(wPLI_all_seed,3));
                              wpli_allsubs(subj,cond,:,:,:)=wPLI_all;
                          else
                              %fill in matrix
                              wpli_allsubs(subj,cond,:,:,:)=wPLI_all;
                          end
                      end %end if seed or all-to-all
                  end %end if baseline corrected
              end %end loop through conditions
          elseif RestorEvent==1
              sub_file_list =   contains(subjects,unique_subjects{subj});
              currentsubs = subjects(sub_file_list);
              wpli_file_list =  contains(currentsubs,'wPLI');
              currentwpli = currentsubs(wpli_file_list);
              
              cd(data_location)
              load([currentwpli '.mat']);
              
              if wPLI_bln == 1 %chose to baseline correct
                  X = ndims(wPLI_blncorr);
                  if X == 3 %for seed-based output
                      if subj == 1
                          wpli_allsubs = zeros(length(unique_subjects), size(wPLI_blncorr,1),size(wPLI_blncorr,2),size(wPLI_blncorr,3));
                          wpli_allsubs(subj,:,:,:)=wPLI_blncorr;
                      else
                          wpli_allsubs(subj,:,:,:)=wPLI_blncorr;
                      end
                  elseif X ==4 %for all-to-all output
                      %Find seed index
                      Seed_idx= find(strcmp({channel_location.labels}, Seed));
                      %Pull out ICPS values between each electrode and the seed
                      wPLI_blncorr_seed = squeeze(wPLI_blncorr(:,:,:,Seed_idx));
                      if subj == 1
                          wpli_allsubs = zeros(length(unique_subjects), size(wPLI_blncorr_seed,1),size(wPLI_blncorr_seed,2),size(wPLI_blncorr_seed,3));
                          wpli_allsubs(subj,:,:,:)=wPLI_blncorr;
                      else
                          wpli_allsubs(subj,:,:,:)=wPLI_blncorr;
                      end
                  end
              elseif wPLI_bln == 0 %chose not to baseline correct
                  X = ndims(wPLI_all);
                  if X == 3 %seed-based analyses
                      if subj == 1
                          wpli_allsubs = zeros(length(unique_subjects), size(wPLI_all,1),size(wPLI_all,2),size(wPLI_all,3));
                          wpli_allsubs(subj,:,:,:)=wPLI_all;
                      else
                          wpli_allsubs(subj,:,:,:)=wPLI_all;
                      end
                  elseif X ==4 %all-to-all analyses
                      %Find seed index
                      Seed_idx= find(strcmp({channel_location.labels}, Seed));
                      %Pull out ICPS values between each electrode and the seed
                      wPLI_all_seed = squeeze(wPLI_all(:,:,:,Seed_idx));
                      if subj == 1
                          %initialize matrix if first condition for first subject only
                          wpli_allsubs = zeros(length(unique_subjects), size(wPLI_all_seed,1),size(wPLI_all_seed,2),size(wPLI_all_seed,3));
                          wpli_allsubs(subj,:,:,:)=wPLI_all;
                      else
                          %fill in matrix
                          wpli_allsubs(subj,:,:,:)=wPLI_all;
                      end
                  end %end if seed or all-to-all
              end %end if baseline corrected
          end %end if rest or event
      end %end if wPLI was calculated
end %end loop through subject numbers

    
cd(save_location)
if Downsample == 1
    save_data = 'TF_AllSubs';
    save (save_data, 'TF_allsubs','ds_time','frequency','channel_location');
elseif Downsample == 0
    save_data = 'TF_AllSubs';
    save (save_data, 'TF_allsubs','time','frequency','channel_location');
end

if ITPS_calc==1
    if Downsample == 1
        save_data = 'ITPS_AllSubs';
        save (save_data, 'ITPS_allsubs','ds_time','frequency','channel_location');
    elseif Downsample ==0
        save_data = 'ITPS_AllSubs';
        save (save_data, 'ITPS_allsubs','time','frequency','channel_location');
    end
end

if ICPS_calc==1
    if Downsample ==1
        save_data = 'ICPS_AllSubs';
        save (save_data, 'ICPS_allsubs','ds_time','frequency','channel_location');
    elseif Downsample ==0
        save_data = 'ICPS_AllSubs';
        save (save_data, 'ICPS_allsubs','time','frequency','channel_location');
    end
end

if wPLI_calc ==1
    if Downsample ==1
        save_data = 'wPLI_AllSubs';
        save (save_data, 'wpli_allsubs','ds_time','frequency','channel_location');
    elseif Downsample ==0
        save_data = 'wPLI_AllSubs';
        save (save_data, 'wpli_allsubs','time','frequency','channel_location');
    end
end


%% Kia: Updating ConditionNames as I need to plot the difference in addition to incong error and incong correct.

ConditionNames = {'Incong error response' 'Incong correct response' 'Difference (error - correct)'}; 

%% %%%%%%%%%%%%%%% PLOT TF %%%%%%%%%%%%%%%%%%%%%%%
%If you do not want to re-compile your data everytime, you can just load
%the _allsubs.mat file before continuing to plot. Just make sure that you
%also evaluate the variables at the top of the script related to plotting


eeglab 

for cond=1:length(ConditionNames)
    %pull out time, frequency, and channel indices for surface plots
    freq_surface_idx = dsearchn(frequency',freq_window_surface');
    if Downsample ==1
        time_surface_idx = dsearchn(ds_time',time_window_surface');
    elseif Downsample ==0
        time_surface_idx = dsearchn(time',time_window_surface');
    end
    
    % Find indices of the channels to plot
    for i=1:length(chans2plot_TF)
        Elecs_idx (i)= find(strcmp({channel_location.labels}, chans2plot_TF{i}));
    end
    
    %Time Frequency surface
    if cond < 3
        TF_forTFsurface = squeeze(mean(mean(TF_allsubs(:,cond,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5));
    elseif cond == 3
        TF_forTFsurface = squeeze(mean(mean(TF_allsubs(:,1,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5)) - squeeze(mean(mean(TF_allsubs(:,2,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5));
    end
    
    %find bounds for plot
    if cond==1
    %clim_min = min(TF_forTFsurface(:));
    clim_max = max(TF_forTFsurface(:));
    
    clim_surface = [-clim_max clim_max];
    end
    
    %Plot TF
    f4 = figure;
    hold on;
    if Downsample ==1
        contourf(ds_time(time_surface_idx(1,1):time_surface_idx(2,1)), frequency(freq_surface_idx(1,1):freq_surface_idx(2,1)), TF_forTFsurface, 20,'linecolor','none');
        set(gca, 'ylim', freq_window_surface, 'xlim', time_window_surface, 'clim', clim_surface);
        title(['Time Frequency ' ConditionNames(cond)], 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal');
        xlabel('Time (ms)'), ylabel('Frequency (Hz)')
        set(findall(gcf,'-property','FontSize'),'FontSize',14)
        set(findall(gcf,'-property','fontname'),'fontname','arial')
        cbar('vert',0, clim_surface, 5);
        
    elseif Downsample ==0
        contourf(time(time_surface_idx(1,1):time_surface_idx(2,1)), frequency(freq_surface_idx(1,1):freq_surface_idx(2,1)), TF_forTFsurface, 20,'linecolor','none');
        set(gca, 'ylim', freq_window_surface, 'xlim', time_window_surface, 'clim', clim_surface);
        title(['Time Frequency ' ConditionNames(cond)], 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal');
        xlabel('Time (ms)'), ylabel('Frequency (Hz)')
        set(findall(gcf,'-property','FontSize'),'FontSize',14)
        set(findall(gcf,'-property','fontname'),'fontname','arial')
        cbar('vert',0, clim_surface, 5);
        
    end
    
    if cond == 1
        saveas(f4,[plot_save_location 'error_tf.png'])
    elseif cond ==2
        saveas(f4,[plot_save_location 'correct_tf.png'])
    elseif cond ==3
        saveas(f4,[plot_save_location 'diff_tf.png'])
    end

    %pull out time, frequency, and channel indices for surface plots
    freq_topo_idx = dsearchn(frequency',freq_window_for_topo');
    if Downsample ==1
        time_topo_idx = dsearchn(ds_time',time_window_for_topo');
    elseif Downsample ==0
        time_topo_idx = dsearchn(time',time_window_for_topo');
    end

    
    %Topo plot
    if cond < 3
        TF_fortopo = squeeze(mean(mean(mean(TF_allsubs(:,cond,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4));
    elseif cond == 3
        TF_fortopo = squeeze(mean(mean(mean(TF_allsubs(:,1,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4)) - squeeze(mean(mean(mean(TF_allsubs(:,2,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4)); % difference
    end

    
    %find bounds for plot
    if cond==1
    %clim_min = min(TF_forTFsurface(:));
    %clim_max = max(abs(TF_fortopo(:)));
    clim_max = 6;
    clim_topo = [-clim_max clim_max];
    end
    
    %Plot
    f3 = figure;
    hold on;
    topoplot(TF_fortopo,channel_location,'plotrad',.55,'maplimits',clim_topo,'electrodes','on','numcontour',0);
    title(['Time Frequency ' ConditionNames(cond)]);
    set(gca, 'FontName','Arial', 'FontSize', 14)

    if cond == 1
        saveas(f3,[plot_save_location 'error_tf_topo.png'])
    elseif cond ==2
        saveas(f3,[plot_save_location 'correct_tf_topo.png'])
    elseif cond ==3
        saveas(f3,[plot_save_location 'diff_tf_topo.png'])
    end
end %end loop through 




%% %%%%%%%%%%%%%%% PLOT ITPS %%%%%%%%%%%%%%%%%%%%%%%
%If you do not want to re-compile your data everytime, you can just load
%the _allsubs.mat file before continuing to plot. Just make sure that you
%also evaluate the variables at the top of the script related to plotting


eeglab 

if ITPS_calc==1
    for cond=1:length(ConditionNames)
        %pull out time, frequency, and channel indices for surface plots
        freq_surface_idx = dsearchn(frequency',freq_window_surface');
        if Downsample ==1
            time_surface_idx = dsearchn(ds_time',time_window_surface');
        elseif Downsample ==0
            time_surface_idx = dsearchn(time',time_window_surface');
        end
        
        % Find indices of the channels to plot
        for i=1:length(chans2plot_ITPS)
            Elecs_idx (i)= find(strcmp({channel_location.labels}, chans2plot_ITPS{i}));
        end
        
        %Time Frequency surface
        if cond < 3
            ITPS_forTFsurface = squeeze(mean(mean(ITPS_allsubs(:,cond,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5));
        elseif cond == 3
            ITPS_forTFsurface = squeeze(mean(mean(ITPS_allsubs(:,1,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5)) - squeeze(mean(mean(ITPS_allsubs(:,2,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5));
        end
        
        %find bounds for plot
        if cond==1
            %clim_min = min(TF_forTFsurface(:));
            clim_max = max(abs(ITPS_forTFsurface(:)));
            
            clim_surface = [-clim_max clim_max];
        end
    
        %Plot TF
        f1 = figure;
        hold on;
        if Downsample ==1
            contourf(ds_time(time_surface_idx(1,1):time_surface_idx(2,1)), frequency(freq_surface_idx(1,1):freq_surface_idx(2,1)), ITPS_forTFsurface, 20,'linecolor','none');
            set(gca, 'ylim', freq_window_surface, 'xlim', time_window_surface, 'clim', clim_surface);
            title(['ITPS ' ConditionNames(cond)], 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal');
            xlabel('Time (ms)'), ylabel('Frequency (Hz)')
            set(findall(gcf,'-property','FontSize'),'FontSize',14)
            set(findall(gcf,'-property','fontname'),'fontname','arial')
            cbar('vert',0, clim_surface, 5);
        elseif Downsample ==0
            contourf(time(time_surface_idx(1,1):time_surface_idx(2,1)), frequency(freq_surface_idx(1,1):freq_surface_idx(2,1)), ITPS_forTFsurface, 20,'linecolor','none');
            set(gca, 'ylim', freq_window_surface, 'xlim', time_window_surface, 'clim', clim_surface);
            title(['ITPS ' ConditionNames(cond)], 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal');
            xlabel('Time (ms)'), ylabel('Frequency (Hz)')
            set(findall(gcf,'-property','FontSize'),'FontSize',14)
            set(findall(gcf,'-property','fontname'),'fontname','arial')
            cbar('vert',0, clim_surface, 5);
        end
        if cond == 1
            saveas(f1,[plot_save_location 'error_itps.png'])
        elseif cond ==2
            saveas(f1,[plot_save_location 'correct_itps.png'])
        elseif cond ==3
            saveas(f1,[plot_save_location 'diff_itps.png'])
        end
        
        %pull out time, frequency, and channel indices for surface plots
        freq_topo_idx = dsearchn(frequency',freq_window_for_topo');
        if Downsample ==1
            time_topo_idx = dsearchn(ds_time',time_window_for_topo');
        elseif Downsample ==0
            time_topo_idx = dsearchn(time',time_window_for_topo');
        end
        
        
        %Topo plot
        if cond < 3
            ITPS_fortopo = squeeze(mean(mean(mean(ITPS_allsubs(:,cond,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4));
        elseif cond == 3
            ITPS_fortopo = squeeze(mean(mean(mean(ITPS_allsubs(:,1,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4)) - squeeze(mean(mean(mean(ITPS_allsubs(:,2,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4));
        end


         %find bounds for plot
        if cond==1
        %clim_min = min(TF_forTFsurface(:));
        clim_max = max(ITPS_fortopo(:));
    
        clim_topo = [-clim_max clim_max];
        end
        
        
        %Plot
        f2= figure;
        hold on;
        topoplot(ITPS_fortopo,channel_location,'plotrad',.55,'maplimits',clim_topo,'electrodes','on','numcontour',0);
        title(['ITPS ' ConditionNames(cond)]);
        set(gca, 'FontName','Arial', 'FontSize', 14)
       
        if cond == 1
            saveas(f2,[plot_save_location 'error_itps_topo.png'])
        elseif cond ==2
            saveas(f2,[plot_save_location 'correct_itps_topo.png'])
        elseif cond ==3
            saveas(f2,[plot_save_location 'diff_itps_topo.png'])
        end
        
    end %end loop through
else
end


%% %%%%%%%%%%%%%%% PLOT CONNECTIVITY %%%%%%%%%%%%%%%%%%%%%%%
%If you do not want to re-compile your data everytime, you can just load
%the _allsubs.mat file before continuing to plot. Just make sure that you
%also evaluate the variables at the top of the script related to plotting


eeglab 
if ICPS_calc==1
    for cond=1:length(ConditionNames)
           %pull out time, frequency, and channel indices for surface plots
        freq_surface_idx = dsearchn(frequency',freq_window_surface');
        if Downsample ==1
            time_surface_idx = dsearchn(ds_time',time_window_surface');
        elseif Downsample ==0
            time_surface_idx = dsearchn(time',time_window_surface');
        end
        
        % Find indices of the channels to plot
        for i=1:length(chans2plot_ICPSwpli)
            Elecs_idx (i)= find(strcmp({channel_location.labels}, chans2plot_ICPSwpli{i}));
        end
        
        %Time Frequency surface
        ICPS_forTFsurface = squeeze(mean(mean(ICPS_allsubs(:,cond,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5));
        
        %find bounds for plot
        if cond==1
            %clim_min = min(TF_forTFsurface(:));
            clim_max = max(ICPS_forTFsurface(:));
            
            clim_surface = [-clim_max clim_max];
        end
    
        %Plot TF
        figure;
        hold on;
        if Downsample ==1
            contourf(ds_time(time_surface_idx(1,1):time_surface_idx(2,1)), frequency(freq_surface_idx(1,1):freq_surface_idx(2,1)), ICPS_forTFsurface, 20,'linecolor','none');
            set(gca, 'ylim', freq_window_surface, 'xlim', time_window_surface, 'clim', clim_surface);
            title(['ICPS ' ConditionNames(cond)], 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal');
            xlabel('Time (ms)'), ylabel('Frequency (Hz)')
            set(findall(gcf,'-property','FontSize'),'FontSize',14)
            set(findall(gcf,'-property','fontname'),'fontname','arial')
            cbar('vert',0, clim_surface, 5);
        elseif Downsample ==0
            contourf(time(time_surface_idx(1,1):time_surface_idx(2,1)), frequency(freq_surface_idx(1,1):freq_surface_idx(2,1)), ICPS_forTFsurface, 20,'linecolor','none');
            set(gca, 'ylim', freq_window_surface, 'xlim', time_window_surface, 'clim', clim_surface);
            title(['ICPS ' ConditionNames(cond)], 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal');
            xlabel('Time (ms)'), ylabel('Frequency (Hz)')
            set(findall(gcf,'-property','FontSize'),'FontSize',14)
            set(findall(gcf,'-property','fontname'),'fontname','arial')
            cbar('vert',0, clim_surface, 5);
        end
        
        %pull out time, frequency, and channel indices for surface plots
        freq_topo_idx = dsearchn(frequency',freq_window_for_topo');
        if Downsample ==1
            time_topo_idx = dsearchn(ds_time',time_window_for_topo');
        elseif Downsample ==0
            time_topo_idx = dsearchn(time',time_window_for_topo');
        end
        
        
        %Topo plot
        ICPS_fortopo = squeeze(mean(mean(mean(ICPS_allsubs(:,cond,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4));
        
         %find bounds for plot
        if cond==1
        %clim_min = min(TF_forTFsurface(:));
        clim_max = max(ICPS_fortopo(:));
    
        clim_topo = [-clim_max clim_max];
        end
        
        
        %Plot
        figure;
        hold on;
        topoplot(ICPS_fortopo,channel_location,'plotrad',.55,'maplimits',clim_topo,'electrodes','on','numcontour',0);
        title(['ICPS ' ConditionNames(cond)]);
        set(gca, 'FontName','Arial', 'FontSize', 14)
        
    end %end loop through
else
end

if wPLI_calc==1
    for cond=1:length(ConditionNames)
        %pull out time, frequency, and channel indices for surface plots
        freq_surface_idx = dsearchn(frequency',freq_window_surface');
        if Downsample ==1
            time_surface_idx = dsearchn(ds_time',time_window_surface');
        elseif Downsample ==0
            time_surface_idx = dsearchn(time',time_window_surface');
        end
        
        % Find indices of the channels to plot
        for i=1:length(chans2plot_ICPSwpli)
            Elecs_idx (i)= find(strcmp({channel_location.labels}, chans2plot_ICPSwpli{i}));
        end
        
        %Time Frequency surface
        if cond < 3
             wpli_forTFsurface = squeeze(mean(mean(wpli_allsubs(:,cond,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5));
        elseif cond == 3
            wpli_forTFsurface = squeeze(mean(mean(wpli_allsubs(:,1,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5)) - squeeze(mean(mean(wpli_allsubs(:,2,freq_surface_idx(1,1):freq_surface_idx(2,1),time_surface_idx(1,1):time_surface_idx(2,1),Elecs_idx),1),5));
        end

        
        %find bounds for plot
        if cond==1
            %clim_min = min(TF_forTFsurface(:));
            clim_max = max(wpli_forTFsurface(:));
            
            clim_surface = [-clim_max clim_max];
        end
    
        %Plot TF
        f5 = figure;
        hold on;
        if Downsample ==1
            contourf(ds_time(time_surface_idx(1,1):time_surface_idx(2,1)), frequency(freq_surface_idx(1,1):freq_surface_idx(2,1)), wpli_forTFsurface, 20,'linecolor','none');
            set(gca, 'ylim', freq_window_surface, 'xlim', time_window_surface, 'clim', clim_surface);
            title(['wPLI ' ConditionNames(cond)], 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal');
            xlabel('Time (ms)'), ylabel('Frequency (Hz)')
            set(findall(gcf,'-property','FontSize'),'FontSize',14)
            set(findall(gcf,'-property','fontname'),'fontname','arial')
            cbar('vert',0, clim_surface, 5);
        elseif Downsample ==0
            contourf(time(time_surface_idx(1,1):time_surface_idx(2,1)), frequency(freq_surface_idx(1,1):freq_surface_idx(2,1)), wpli_forTFsurface, 20,'linecolor','none');
            set(gca, 'ylim', freq_window_surface, 'xlim', time_window_surface, 'clim', clim_surface);
            title(['wPLI ' ConditionNames(cond)], 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal');
            xlabel('Time (ms)'), ylabel('Frequency (Hz)')
            set(findall(gcf,'-property','FontSize'),'FontSize',14)
            set(findall(gcf,'-property','fontname'),'fontname','arial')
            cbar('vert',0, clim_surface, 5);
        end

        if cond == 1
            saveas(f5,[plot_save_location 'error_wpli.png'])
        elseif cond ==2
            saveas(f5,[plot_save_location 'correct_wpli.png'])
        elseif cond ==3
            saveas(f5,[plot_save_location 'diff_wpli.png'])
        end

        %pull out time, frequency, and channel indices for surface plots
        freq_topo_idx = dsearchn(frequency',freq_window_for_topo');
        if Downsample ==1
            time_topo_idx = dsearchn(ds_time',time_window_for_topo');
        elseif Downsample ==0
            time_topo_idx = dsearchn(time',time_window_for_topo');
        end
        
        
        %Topo plot
        if cond < 3
             wpli_fortopo = squeeze(mean(mean(mean(wpli_allsubs(:,cond,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4));
        elseif cond == 3
            wpli_fortopo = squeeze(mean(mean(mean(wpli_allsubs(:,1,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4)) - squeeze(mean(mean(mean(wpli_allsubs(:,2,freq_topo_idx(1,1):freq_topo_idx(2,1),time_topo_idx(1,1):time_topo_idx(2,1),:),1),3),4));
        end

       
         %find bounds for plot
        if cond==1
        %clim_min = min(TF_forTFsurface(:));
        clim_max = max(wpli_fortopo(:));
    
        clim_topo = [-clim_max clim_max];
        end
        
        
        %Plot
        f6 = figure;
        hold on;
        topoplot(wpli_fortopo,channel_location,'plotrad',.55,'maplimits',clim_topo,'electrodes','on','numcontour',0);
        title(['wPLI ' ConditionNames(cond)]);
        set(gca, 'FontName','Arial', 'FontSize', 14)
        if cond == 1
            saveas(f6,[plot_save_location 'error_wpli_topo.png'])
        elseif cond ==2
            saveas(f6,[plot_save_location 'correct_wpli_topo.png'])
        elseif cond ==3
            saveas(f6,[plot_save_location 'diff_wpli_topo.png'])
        end
    end %end loop through conditions
else
end


