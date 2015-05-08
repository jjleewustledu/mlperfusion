classdef LaifDirector  
	%% LAIFDIRECTOR   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.5.0.197613 (R2015a) 
 	%  $Id$ 
 	 
    properties
        meansMatrix
        stdsMatrix
    end
    
	properties (Dependent)
 		 product
         times
         kAif
         kConcentration
         magnetization
         
         priorN
    end 
    
    methods %% GET
        function b = get.product(this)
            assert(~isempty(this.builder_));
            b = this.builder_;
        end
        function t = get.times(this)
            assert(~isempty(this.builder_));
            t = this.builder_.times;
        end
        function t = get.kAif(this)
            assert(~isempty(this.builder_));
            t = this.builder_.itsKAif;
        end
        function t = get.kConcentration(this)
            assert(~isempty(this.builder_));
            t = this.builder_.itsKConcentration;
        end
        function t = get.magnetization(this)
            assert(~isempty(this.builder_));
            t = this.builder_.magnetization;
        end
        function n = get.priorN(this)
            n = this.builder_.priorN;
        end
        function this = set.priorN(this, n)
            this.builder_.priorN = n;
        end
    end

    methods (Static)
        function this = loadLaif2(magnFn, maskFn)
            p = inputParser;
            addRequired(p, 'magnFn', @(x) lexist(x, 'file'));
            addRequired(p, 'maskFn', @(x) lexist(x, 'file'));
            parse(p, magnFn, maskFn);
            
            import mlperfusion.*;           
            this = LaifDirector( ...
                   Laif2.load(magnFn, maskFn));
        end
        function this = loadLaif0(magnFn, maskFn)
            p = inputParser;
            addRequired(p, 'magnFn', @(x) lexist(x, 'file'));
            addRequired(p, 'maskFn', @(x) lexist(x, 'file'));
            parse(p, magnFn, maskFn);
            
            import mlperfusion.*;           
            this = LaifDirector( ...
                   Laif0.load(magnFn, maskFn));
        end
        function this = loadKernel(laifObj, dcvFn)
            p = inputParser;
            addRequired(p, 'laifObj', @(x) isa(x, 'mlperfusion.Laif2'));
            addRequired(p, 'dcvFn',   @(x) lexist(x, 'file'));
            parse(p, laifObj, dcvFn);
            
            import mlperfusion.* mlpet.*;           
            this = LaifDirector( ...
                   BrainWaterKernel.load(laifObj, dcvFn));
        end
        
        function laifs = trainLaif2(locations)
            if (ischar(locations)); locations = {locations}; end
            assert(iscell(locations));
            import mlperfusion.*;
            pwd0 = pwd;
            diary(sprintf('LaifDirector.trainLaif2_%s.log', datestr(now, 30)));
            for l = 1:length(locations)
                cd(locations{l});
                this = LaifDirector.loadLaif2('ep2d_default_mcf.nii.gz', 'ep2d_mask.nii.gz');
                this = this.estimateAll;
                laifs{l} = this.product;
            end
            cd(pwd0);
            save('LaifDirector.trainLaif2.laifs.mat', 'laifs')
            diary off
        end
        function kernels = trainKernel(locations)
            if (ischar(locations)); locations = {locations}; end
            assert(iscell(locations));
            import mlperfusion.*;
            pwd0 = pwd;
            diary(sprintf('LaifDirector.trainKernel_%s.log', datestr(now, 30)));
            for l = 1:length(locations)
                cd(locations{l});
                pnum = str2pnum(locations{l});
                load('LaifDirector.product.mat');
                this = LaifDirector.loadKernel(laif, [pnum 'ho1.dcv']);
                this = this.estimateAll;
                kernels{l} = this.product;
            end
            cd(pwd0);
            save('LaifDirector.trainKernel.kernels.mat', 'kernels')
            diary off
        end
    end
    
	methods         
        function this = simulateItsMcmc(this)
            %% SIMULATEITSMCMC returns an entirely synthetic Laif (viz., builder, product) object
            
            this.builder_ = this.builder_.simulateItsMcmc;
            this.builder_.plotProduct;
        end
        function this = estimateAll(this)
            %% RUNITSAUTORADIOGRAPHY returns a Laif (viz., builder, product) object based on dsc & mutually consistent times
            
            this.builder_ = this.builder_.estimateAll;
            this.builder_.plotProduct;
            this.builder_.save;
        end
        function this = estimatePriors(this)
            % estimate params for data, initial
            % simulate MCMC for initial params, std
            % widen priors until failure to find usable prior widths
            % test simulation priors on data
            % fine-adjust priors
            % repeat over training set
           
        end
        
 		function this = LaifDirector(buildr) 
 			%% LAIFDIRECTOR 
 			%  Usage:  this = LaifDirector() 

            assert(isa(buildr, 'mlperfusion.ILaif') || isa(buildr, 'mlpet.BrainWaterKernel'));
            this.builder_ = buildr;
 		end 
        function        plotInitialData(this)
            this.builder_.plotInitialData;
        end
        function        plotParVars(this, par, vars)
            this.builder_.plotParVars(par, vars);
        end
 	end 

    %% PRIVATE
    
    properties (Access = 'private')
        builder_
    end    
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

