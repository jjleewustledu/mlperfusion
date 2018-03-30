classdef HO15ModelLayer < mlarchitect.ModelLayer
	%% HO15MODELLAYER  

	%  $Revision$
 	%  was created 12-Jan-2016 19:07:41
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.

    properties (Dependent)
        bestFitParams
    end
    
    methods %% GET
        function g = get.bestFitParams(this)
            g = this.model_.bestFitParams;
        end
    end
    
    methods
        function estimateAutoradiography(this, model, data)
            %% ESTIMATEAUTORADIOGRAPHY
            %  @param model must be an mlperfusion.AutoradiographyModel instance.
            %  @param data  must be an mlperfusion.AutoradiographyData instance.
            
            ip = inputParser;
            addRequired(ip, 'model', @(x) isa(x, 'mlperfusion.IAutoradiographyModel'));
            addRequired(ip, 'data',  @(x) isa(x, 'mlperfusion.IAutoradiographyData'));
            parse(ip, model, data);
            
            model.ecat = data.ecat;
            model.mask = data.mask;
            if (isprop(model, 'dcv'))
                model.dcv = data.dcv;
            end
            if (isprop(model, 'crv'))
                model.crv = data.crv;
            end
            if (isprop(model, 'lineKernel'))
                model.lineKernel = data.lineKernel;
            end
            this.model_ = model.estimateParameters;
        end
        function plot(this)
            this.model_.plot;
        end
    end

    %% PRIVATE

    properties (Access = 'private')
        model_
    end
    
	methods (Access = 'private')
 		function this = HO15ModelLayer(varargin)
 			this = this@mlarchitect.ModelLayer(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

