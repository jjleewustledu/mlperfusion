classdef HO15Data < mlperfusion.IAutoradiographyData
	%% HO15DATA  

	%  $Revision$
 	%  was created 12-Jan-2016 21:27:38
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
        studyRegistry
        
        crv
        dcv
 		ecat
        lineKernel
        mask % requires co-registration
    end
    
	methods		  
 		function this = HO15Data(varargin)
 			%% HO15DATA
 			%  Usage:  this = HO15Data()

 			ip = inputParser;
            addRequired(ip, 'studyReg', @(x) isa(x, 'mlpipeline.StudyRegistry'));
            parse(ip, varargin{:});
            
            this.studyRegistry = ip.Results.studyReg;
            
            import mlfourd.* mlpet.*;
            if (~isempty(this.crvFqfilename))
                this.crv = CRV.load(this.crvFqfilename);
            end
            if (~isempty(this.dcvFqfilename))
                this.dcv = DCV.load(this.dcvFqfilename);
            end
            if (~isempty(this.ecatFqfilename))
                this.ecat = ImagingContext.load(this.ecatFqfilename);
            end
            if (~isempty(this.lineKernelFqfilename))
                this.lineKernel = LineKernel.load(this.lineKernelFqfilename);
            end
            if (~isempty(this.maskFqfilename))
                this.mask = ImagingContext.load(this.maskFqfilename);
                afac      = mlfsl.RegistrationFacade;
                this.mask = afac.inverseAligned(this.mask, this.petAtlas);
            end
        end        
 	end 
    
    methods (Access = private)
        function f = crvFqfilename(this)
            f = this.studyRegistry.crvFqfilename;
        end
        function f = dcvFqfilename(this)
        end
        function f = ecatFqfilename(this)
            f = this.registry.hoFqfilename;
        end
        function f = lineKernelFqfilename(this)
        end
        function f = maskFqfilename(this)
        end
        function ic = petAtlas(this)
            %  @throws
            
            ic = mlfourd.ImagingContext(this.registry.hoFqfilename);
            ic.add(this.registry.ooFqfilename);
            ic.add(this.registry.ocFqfilename);
            ic.add(this.registry.trFqfilename);
            ic.add(this.registry.glucFqfilename);
            
            ic.atlas;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

