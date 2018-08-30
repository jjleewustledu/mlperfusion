classdef (Abstract) ILaif < handle 
	%% ILAIF   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
    methods (Static, Abstract)   
        kConcentration
        kAif
        bolusFlowTerm
        bolusSteadyStateTerm
        flowTerm
        steadyStateTerm
        simulateMcmc
    end
    
    methods (Abstract) 
        itsKConcentration(this)
        itsKAif(this)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

