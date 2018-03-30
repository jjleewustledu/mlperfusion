classdef PLaif1TrainingModel < mlperfusion.IAutoradiographyModel
	%% PLAIF1TRAININGMODEL adapts PLaif1Training for use with mlperfusion.HO15ModelLayer
    %  See also:  mlperfusion.HO15ModelLayer

	%  $Revision$
 	%  was created 12-Jan-2016 19:59:51
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties (Dependent)
        baseTitle % get
        bestFitParams % get
        detailedTitle % get
        expectedBestFitParams % get
        mapParams % get
        meanParams % get
        stdParams % get
        
        dcv % set
 		ecat % set
        mask % set
    end
    
    methods %% GET/SET
        function g = get.baseTitle(this)
            g = this.mcmc_.baseTitle;
        end
        function g = get.bestFitParams(this)
            g = this.mcmc_.bestFitParams;
        end
        function g = get.detailedTitle(this)
            g = this.mcmc_.detailedTitle;
        end
        function g = get.expectedBestFitParams(this)
            g = this.mcmc_.expectedBestFitParams;
        end
        function g = get.mapParams(this)
            g = this.mcmc_.mapParams;
        end
        function g = get.meanParams(this)
            g = this.mcmc_.meanParams;
        end
        function g = get.stdParams(this)
            g = this.mcmc_.stdParams;
        end         
        
        function this = set.dcv(this, s)
            assert(isa(s, 'mlpet.DCV'));
            this.dcv_ = s;
        end 
        function this = set.ecat(this, s)
            assert(isa(s, 'mlfourd.ImagingContext'));
            this.ecat_ = s;
        end
        function this = set.mask(this, s)
            assert(isa(s, 'mlfourd.ImagingContext'));
            this.mask_ = s;
        end      
    end

	methods
 		function this = PLaif1TrainingModel
 			%% PLAIF1TRAININGMODEL
 			%  Usage:  this = PLaif1TrainingModel()
        end
        function this = estimateParameters(this)
            this.mask_.binarized;
            this.ecat_.ecatExactHRPlus;
            this.ecat_.masked(this.mask_);
            this.ecat_.volumeSummed;                
            mcmc = mlperfusion.PLaif1Training( ...
                {this.dcv_.times this.ecat_.times}, {this.dcv_.wellCounts this.ecat_.tscCounts'});
            this.mcmc_ = mcmc.estimateParameters;
        end
        function plot(this)
            this.mcmc_.plot;
        end
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        ecat_
        mask_
        mcmc_
        dcv_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

