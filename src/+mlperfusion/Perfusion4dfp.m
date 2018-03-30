classdef Perfusion4dfp < mlperfusion.LaifParametersInterface
	%% PERFUSION4DFP manages data and methods involving Josh Shimony's perfusion_4dfp packages
	%
	%  $Revision$ 
	%  was created $Date$ 
	%  by $Author$, 
	%  last modified $LastChangedDate$ 
	%  and checked into repository $URL$, 
	%  developed on Matlab 8.3.0.532 (R2014a) 
	%  $Id$ 
	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties 
        defaultMaskFilename = 'bt1_default_mask_on_S0.nii.gz'
    end
    
	properties (Dependent) % NIfTI maps  
		S0    % param[1]
        CBF   % param[2]
        CBV
        MTT
        t0    % param[3]
        alpha % param[4]
        beta  % param[5]
        delta % param[6]
        gamma % param[7]
        eps   % param[8]
        t1    % param[9]
        nu    % param[10]
    end 
    
    methods %% GET
        function p = get.S0(this)
            p = this.parameterNIfTI('S0', 1);
        end
        function p = get.CBF(this)
            p = this.parameterNIfTI('CBF', 2);
        end
        function p = get.CBV(this)
            p = this.CBF.clone;
            p.fileprefix = 'CBV';
            p.img = scrubNaNs(this.CBF.img ./ this.delta.img, true);
        end
        function p = get.MTT(this)
            p = this.delta.clone;
            p.fileprefix = 'MTT';
            p.img = scrubNaNs(this.delta.ones.img ./ this.delta.img, true);
        end
        function p = get.t0(this)
            p = this.parameterNIfTI('t0', 3);
        end
        function p = get.alpha(this)
            p = this.parameterNIfTI('alpha', 4);
        end
        function p = get.beta(this)
            p = this.parameterNIfTI('beta', 5);
        end
        function p = get.delta(this)
            p = this.parameterNIfTI('delta', 6);
        end
        function p = get.gamma(this)
            p = this.parameterNIfTI('gamma', 7);
        end
        function p = get.eps(this)
            p = this.parameterNIfTI('eps', 8);
                    end
        function p = get.t1(this)
            p = this.parameterNIfTI('t1', 9);
        end
        function p = get.nu(this)
            p = this.parameterNIfTI('nu', 10);
        end
    end

    methods (Static)
        function this = load(niiFilename, varargin)
            %% LOAD
            %  Usage:   this = Perfusion4dfp.load(perfusion4dfp_logfile[, parameter_name, parameter_value])
            
            this = mlperfusion.Perfusion4dfp(varargin{:});
            this.perfusionNIfTI_ = mlfourd.NIfTI.load(niiFilename);
        end
    end
    
	methods 
        function m = iqr(this, param)
            m = iqr(this.arrayByMasking(param));
        end
        function m = mad(this, param) %% mean absolute deviation
            m = mad(this.arrayByMasking(param));
        end
        function m = max(this, param)
            m = max(this.arrayByMasking(param));
        end
        function m = mean(this, param)
            m = mean(this.arrayByMasking(param));
        end
        function m = median(this, param)
            m = median(this.arrayByMasking(param));
        end
        function m = min(this, param)
            m = min(this.arrayByMasking(param));
        end
        function m = range(this, param)
            m = range(this.arrayByMasking(param));
        end
        function s = std(this, param)
            s = std(this.arrayByMasking(param));
        end
        function s = statistics(this, param)
            s = struct( ...
                'iqr',    this.iqr(param), ...
                'mad',    this.mad(param), ...
                'max',    this.max(param), ...
                'mean',   this.mean(param), ...
                'median', this.median(param), ...
                'min',    this.min(param), ...
                'range',  this.range(param), ...
                'std',    this.std(param));
        end
        function s = summary(this)
            s = struct( ...
                'S0', this.median('S0'), ...
                'CBF', this.median('CBF'), ...
                'CBV', this.median('CBV'), ...
                'MTT', this.median('MTT'), ...
                't0', this.median('t0'), ...
                'alpha', this.median('alpha'), ...
                'beta', this.median('beta'), ...
                'delta', this.median('delta'), ...
                'gamma', this.median('gamma'), ...
                'eps', this.median('eps'), ...
                't1', this.median('t1'), ...
                'nu', this.median('nu'));
        end
        
 		function this = Perfusion4dfp(varargin)
			%% PERFUSION4DFP  
 			%  Usage:   this = Perfusion4dfp([parameter, parameter_values, ...])
            %                                 ^ mask_filename

            p = inputParser;
            addOptional(p, 'maskFilename', this.defaultMaskFilename, @(x) lexist(x, 'file'));
            parse(p, varargin{:});
            try
                this.maskNIfTI_ = mlfourd.NIfTI.load(p.Results.maskFilename);
            catch ME
                handexcept(ME, 'NIfTI file for mask, %s, not found', p.Results.maskFilename);
            end
		end 
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        perfusionNIfTI_
        maskNIfTI_
    end
    
    methods (Access = 'private')        
        function nii = parameterNIfTI(this, param, idx)            
            nii = this.perfusionNIfTI_.clone;
            nii.fileprefix = param;
            nii.img = squeeze(this.perfusionNIfTI_.img(:,:,:,idx));
            nii.img = nii.img .* this.maskNIfTI_.img;
        end
        function a = arrayByMasking(this, param)            
            msk = this.maskNIfTI_.img;
            a   = squeeze(this.(param).img) .* msk;
            a   = a(msk ~= 0);
        end
    end

	%  Created with NewClassStrategy by John J. Lee, after newfcn by Frank Gonzalez-Morphy 
end

