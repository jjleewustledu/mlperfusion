classdef WholeBrainDSC < mlperfusion.AbstractMRCurve 
	%% WholeBrainDSC   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
    properties (Constant)
        EXTENSION = '.nii.gz'     
        TIMES_UNITS = 'sec'
        CONC_UNITS = 'arbitrary, from -log(M(t)/M0)'
    end    

	properties (Dependent)
 		 dscNifti  % NIfTI
         maskNifti % NIfTI
    end 
        
    methods %% GET/SET
        function d = get.dscNifti(this)
            assert(isa(this.nifti_, 'mlfourd.NIfTI'));
            d = this.nifti_;
        end
        function d = get.maskNifti(this)
            assert(isa(this.maskNifti_, 'mlfourd.NIfTI'));
            d = this.maskNifti_;
        end
    end
    
    methods (Static)
        function this = load(dscLoc, maskLoc, varargin)
            %% LOAD            
 			%  Usage:  this = WholeBrainDSC.load(DSC_filename, mask_filename[, timesToInterpolate]) 
            
            this = mlperfusion.WholeBrainDSC(dscLoc, maskLoc, varargin{:});
        end
    end
    
	methods 		  
 		function this = WholeBrainDSC(dscLoc, maskLoc, varargin) 
 			%% WholeBrainDSC 
 			%  Usage:  this = WholeBrainDSC(DSC_filename, mask_filename[, timesToInterpolate]) 

            this = this@mlperfusion.AbstractMRCurve(dscLoc);            
            
            p = inputParser;
            addRequired(p, 'dscLoc',                @(x) lexist(x, 'file'));
            addOptional(p, 'maskLoc', [],           @(x) lexist(x, 'file'));
            addOptional(p, 'timeInts', this.times_, @isnumeric);
            parse(p, dscLoc, maskLoc, varargin{:});
                     
            if (~isempty(p.Results.maskLoc))
                this.maskNifti_   = mlfourd.NIfTI.load(p.Results.maskLoc);
            else
                this.maskNifti_   = this.nifti_.ones;
            end
            this.timeInterpolants = p.Results.timeInts;
            this.conc             = this.itsKConcentration;
        end
        function m    = itsMagnetization(this)
            %% MAGNETIZATION calculates de novo from dscNifti \int_{V_{mask}} dx^3 mask(\vec{x}) M(\vec{x}, t) / V_{mask}
            
            m = zeros(1, size(this.dscNifti,4));
            for t = 1:length(m)
                m(t) = sum(sum(sum(this.dscNifti.img(:,:,:,t) .* this.maskNifti_.img, 1), 2), 3);                
            end
            m = m / sum(sum(sum(this.maskNifti_.img)));
        end
        function kC   = itsKConcentration(this)
            %% KCONCENTRATION calculates de novo from dscNifti
            
            m  = this.itsMagnetization;
            kC = -log(m/m(1));
        end
        function        save(~)
            error('mlperfusion:notImplemented', 'WholeBrainDSC.save');
        end
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
         maskNifti_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

