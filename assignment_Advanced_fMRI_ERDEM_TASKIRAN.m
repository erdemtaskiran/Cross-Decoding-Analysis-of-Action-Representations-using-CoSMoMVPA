    clear all; close all;
    
    %%  CosMoMVPA path to Matlab
    addpath(genpath('/Users/erdemtaskiran/Desktop/CoSMoMVPA-master'));
    
    %%path to data
    path2data = '/Users/erdemtaskiran/Desktop/fMRIset2';
    
    ROInames ={'MTG','PMC','SPL','IFG'};
    % there are 19 subjects and 4 different ROI
    for iSub = 1:19
        for iROI = 1:4
            
            ROI = ROInames{iROI};
            
            %% data for video conditions
            glm_fn = sprintf('%s/glm/SUB%02d_video_twoPerRunwise_sm3mm.mat', path2data, iSub);        
            % dataset with mask
            msk_fn = sprintf('%s/msk/univarConjunction_spherical_12mm_%s.mat', path2data, ROI);
            ds = cosmo_fmri_dataset(glm_fn, 'mask', msk_fn);
            %% crossvalidation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % first iTest ==>person-directed vs. not-person-directed actions across object-directedness
            % second iTest==>object-directed vs. not-object-directed actions across person-directedness
            for iTest = [1 2]
              
               if iTest==1
                    %% discriminate between person-directed vs. not-person-directed actions across object-directedness
                    idx=cosmo_match(ds.sa.targets,[1:8]); % get all actions needed for cross decoding
                    ds_sel=cosmo_slice(ds,idx);
                    
                    idx_target1=cosmo_match(ds_sel.sa.targets,[3 4 7 8]); % all person directed actions
                    idx_target2=cosmo_match(ds_sel.sa.targets,[1 2 5 6]); % all non-person directed actions
                    
                    idx_chunk1=cosmo_match(ds_sel.sa.targets,[1 2 3 4]); % train: object
                    idx_chunk2=cosmo_match(ds_sel.sa.targets,[5 6 7 8]); % test: non objects
                    
                    ds_sel.sa.targets(idx_target1)=1; %  all person-directed as target 1
                    ds_sel.sa.targets(idx_target2)=2; %  all non-person directed as target 2
                    
                    ds_sel.sa.chunks(idx_chunk1)=1; %  all object  as chunk 1
                    ds_sel.sa.chunks(idx_chunk2)=2;  %  all non-object  as chunk 2
                elseif iTest==2
                    %% discriminate between object-directed vs. not-object-directed actions across person-directedness
                    idx=cosmo_match(ds.sa.targets,[1:8]); % get all actions needed for cross decoding
                    ds_sel=cosmo_slice(ds,idx);
                    
                    idx_target3=cosmo_match(ds_sel.sa.targets,[1 2 3 4]); % all object directed 
                    idx_target4=cosmo_match(ds_sel.sa.targets,[5 6 7 8]); % all non -object directed 
                    
                    idx_chunk3=cosmo_match(ds_sel.sa.targets,[3 4 7 8]); % train: person directed
                    idx_chunk4=cosmo_match(ds_sel.sa.targets,[1 2 5 6]); % test: non person directed
                    
                    ds_sel.sa.targets(idx_target3)=1; %  all object-directed as target 1
                    ds_sel.sa.targets(idx_target4)=2; %  all non-object directed as target 2
                    
                    ds_sel.sa.chunks(idx_chunk3)=1; % all person-directed as chunk 1
                    ds_sel.sa.chunks(idx_chunk4)=2;  %  all non-person directed as chunk 2
                
                end
                
                %% classifier
                args.classifier=@cosmo_classify_lda;
                
                %% partitions
                args.partitions=cosmo_nfold_partitioner(ds_sel);
                
                %% decode using the measure (cosmo_crossvalidate)
                ds_accuracy=cosmo_crossvalidation_measure(ds_sel,args);
                fprintf('Test %d, Sub %d, %s, accuracy: %.3f\n', iTest, iSub, ROI, ds_accuracy.samples);
                
                allRes(iSub,iROI,iTest)=ds_accuracy.samples; 
                
            end
        end
    end
    
    %% compute mean and SEM across subjects, plot the results
    
    meanAcc = mean(allRes); % mean
    semAcc = std(allRes)/sqrt(19); % std err of mean
    
subplot(1,2,1);
bar(meanAcc(1,:,1), 'FaceColor', [0.7 0.7 0.7]); 
hold on;
errorbar(meanAcc(1,:,1), semAcc(1,:,1), '.', 'Capsize', 10, 'Color', [1 0.5 0], 'LineWidth', 1.0); 
ylabel('Accuracy');
line([0 length(ROInames)+1],[0.5 0.5]); % I added a line indicating accuracy at chance
set(gca, 'XTick', 1:length(ROInames), 'XTickLabel', ROInames); 
title('Person vs Non-Person Directed across objects','FontSize', 14);
ylim([0 1]);

subplot(1,2,2);
bar(meanAcc(1,:,2), 'FaceColor', [0.9 0.9 0.9]); 
hold on;
errorbar(meanAcc(1,:,2), semAcc(1,:,2), '.', 'Capsize', 10, 'Color', [1 0.5 0], 'LineWidth', 1.0); 
ylabel('Accuracy');
line([0 length(ROInames)+1],[0.5 0.5]); % add a line indicating accuracy at chance
set(gca, 'XTick', 1:length(ROInames), 'XTickLabel', ROInames); % labels
title('Object vs Non-Object Directed across Person','FontSize', 14);
ylim([0 1]);

% one-tailed one sample t test to look which brain regions showed chance
% level above the decoding accuracy
[H P CI STAT]=ttest(allRes,0.5,0.05,'right') % test for significance

