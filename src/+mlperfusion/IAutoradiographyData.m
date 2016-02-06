classdef (Abstract) IAutoradiographyData 
	%% IAUTORADIOGRAPHYDATA  

	%  $Revision$
 	%  was created 12-Jan-2016 21:28:03
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties (Abstract)
        studyRegistry
        
        crv
        dcv
 		ecat
        lineKernel
        mask
 	end

	methods
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

