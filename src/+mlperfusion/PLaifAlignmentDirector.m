classdef PLaifAlignmentDirector 
	%% PLAIFALIGNMENTDIRECTOR  

	%  $Revision$
 	%  was created 23-Dec-2015 14:57:18
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		
    end
    
    methods (Static)
        function this = createAllAligned(sessPth)
            import mlperfusion.*;
            this = PLaifAlignmentDirector(PLaifAlignmentBuilder.loadUntouched(sessPth));             
            this = this.ensureSessionAtlas(this.sessionAtlasFilename);
            this = this.ensureSessionAnatomy(this.sessionAnatomyFilename);         
        end
    end
    
	methods 
		  
 		function this = PLaifAlignmentDirector(bldr)
 			%% PLAIFALIGNMENTDIRECTOR
 			%  Usage:  this = PLaifAlignmentDirector(PLaifAlignmentBuilder)
 			
            assert(isa(bldr, 'mlperfusion.PLaifAlignmentBuilder'));
            this.builder_  = bldr;
            import mlfourd.*;
            if (lexist(this.sessionAtlasFilename))
                this.sessionAtlas_ = ImagingContext(this.sessionAtlasFilename);
            end
            if (lexist(this.sessionAnatomyFilename))
                this.sessionAnatomy_ = ImagingContext(this.sessionAnatomyFilename);
            end
 		end
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        builder_
        sessionAtlas_
        sessionAnatomy_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

