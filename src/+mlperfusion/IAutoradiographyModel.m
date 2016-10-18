classdef (Abstract) IAutoradiographyModel 
	%% IAUTORADIOGRAPHYMODEL  

	%  $Revision$
 	%  was created 12-Jan-2016 21:02:30
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties (Abstract)
        baseTitle
        bestFitParams
        detailedTitle
 		ecat
        expectedBestFitParams
        mapParams
        mask
        meanParams
        stdParams
 	end

	methods (Abstract)
        estimateParameters(this)
        plot(this)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

