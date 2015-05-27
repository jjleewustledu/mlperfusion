classdef LaifTrainer < mlpet.AbstractAutoradiographyTrainer 
	%% LAIFTRAINER   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.5.0.197613 (R2015a) 
 	%  $Id$ 
 	 

	methods (Static)        
        function prods = trainLaif2(varargin)
            import mlperfusion.* mlpet.*;
            this = LaifTrainer;            
            
            p = inputParser;
            addOptional(p, 'figFolder', pwd, @(x) lexist(x, 'dir'));
            parse(p, varargin{:}); 
            
            pwd0 = pwd;
            cd(this.logPath);            
            diary(sprintf('LaifTrainer.trainLaif2_%s.log', datestr(now, 30)));
            for c = 1:length(this.moyamoyaCases)
                cd(fullfile(this.logPath, this.casePaths{c})); 
                fprintf('-------------------------------------------------------------------------------------------------------------------------------\n');
                fprintf('LaifTrainer.trainLaif2 is working in %s\n', pwd);                             
                this.director_ = ...
                    LaifDirector.loadLaif2(this.dscFn, this.dscMaskFn);
                this.director_ = this.director_.estimateAll;
                prods{c} = this.director_.product;
                laif2    = this.director_.product; %#ok<NASGU>
                save('LaifTrainer.trainLaif2.laif2.mat', 'laif2');
            end
            cd(this.logPath);
            save(sprintf('LaifTrainer.trainLaif2.prods_%s.mat', datestr(now,30)), 'prods');
            cd(p.Results.figFolder);
            AutoradiographyTrainer.laif2;
            cd(pwd0);
            diary off
        end
        function prods = trainBrainWaterKernel(varargin)
            import mlperfusion.* mlpet.*;
            this = LaifTrainer;
            
            p = inputParser;
            addOptional(p, 'figFolder', pwd, @(x) lexist(x, 'dir'));
            parse(p, varargin{:});  
            
            pwd0 = pwd;
            cd(this.logPath);            
            diary(sprintf('LaifTrainer.trainBrainWaterKernel_%s.log', datestr(now, 30)));
            for c = 1:length(this.moyamoyaCases)
                cd(fullfile(this.logPath, this.casePaths{c}));
                fprintf('-------------------------------------------------------------------------------------------------------------------------------\n');
                fprintf('LaifTrainer.trainBrainWaterKernel is working in %s\n', pwd);
                load('LaifTrainer.trainLaif2.laif2.mat')
                this.director_ = ...
                    LaifDirector.loadKernel(laif2, this.aifFn, this.DCV_SHIFTS(c)); 
                this.director_ = this.director_.estimateAll;
                prods{c} = this.director_.product;
            end
            cd(this.logPath); 
            save(sprintf('LaifTrainer.trainBrainWaterKernel.prods_%s.mat', datestr(now,30)), 'prods');
            cd(p.Results.figFolder);
            AutoradiographyTrainer.saveFigs;
            cd(pwd0);
            diary off
        end
    end
    
    methods
        function this = LaifTrainer
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

