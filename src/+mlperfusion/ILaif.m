classdef (Abstract) ILaif  
	%% ILAIF   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties (Abstract) 
        map
        expectedBestFitParams
    end 
    
    methods (Static, Abstract)   
        magnetization
        kConcentration
        flowTerm
        steadyStateTerm
        simulateMcmc
    end
    
    methods (Abstract) 
        itsMagnetization(this)
        itsKConcentration(this)
        priorLow(this)
        priorHigh(this)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

