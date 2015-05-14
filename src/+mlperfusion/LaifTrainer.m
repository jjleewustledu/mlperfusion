classdef LaifTrainer < mlpet.AbstractTrainer 
	%% LAIFTRAINER   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.5.0.197613 (R2015a) 
 	%  $Id$ 
 	 

	methods (Static)        
        function prods = trainLaif2
            import mlperfusion.*;
            this = LaifTrainer;
            
            pwd0 = this.WORK_DIR;
            cd(pwd0);            
            diary(sprintf('LaifTrainer.trainLaif2_%s.log', datestr(now, 30)));
            for c = 1:length(this.MM_CASES)
                cd(fullfile(pwd0, this.casePaths{c})); 
                fprintf('-------------------------------------------------------------------------------------------------------------------------------\n');
                fprintf('AutoradiographyTrainer.trainLaif2 is working in %s\n', pwd);                             
                this.director_ = ...
                    LaifDirector.loadLaif2(this.dscFn, this.dscMaskFn);
                this.director_ = this.director_.estimateAll;
                prods{c} = this.director_.product;
            end
            cd(pwd0);
            
            laifs = prods; %#ok<NASGU>
            save(sprintf('LaifTrainer.trainLaif2.laifs.mat'), 'laifs');
            diary off
        end
        function prods = trainBrainWaterKernel
            import mlperfusion.*;
            this = LaifTrainer;
            
            pwd0 = this.WORK_DIR;
            cd(pwd0);            
            diary(sprintf('LaifTrainer.trainBrainWaterKernel_%s.log', datestr(now, 30)));
            load('LaifTrainer.trainLaif2.laifs.mat');
            for c = 1:length(this.MM_CASES)
                fprintf('LaifTrainer.trainBrainWaterKernel is working in %s\n', pwd);
                cd(fullfile(pwd0, this.casePaths{c}));
                this.director_ = ...
                    LaifDirector.loadKernel(laifs{c}, this.aifFn); %#ok<USENS>
                this.director_ = this.director_.estimateAll;
                prods{c} = this.director_.product;
            end
            cd(pwd0);
            
            save(sprintf('LaifTrainer.trainBrainWaterKernel.prods_%s.mat', datestr(now,30)), 'prods');
            diary off
        end
    end
    
	methods 
        function plotKernel(~, mcmc, t, dcvCurve)            
            figure;
            plot(mcmc.times, mcmc.estimateData, t, dcvCurve, 'o');
            legend('Bayesian DCV', 'DCV');
            title('LaifTrainer.plotKernel', 'Interpreter', 'none');
            xlabel('time/s');
            ylabel('well-counts/mL/s');
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

