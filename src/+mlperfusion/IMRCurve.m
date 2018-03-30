classdef (Abstract) IMRCurve < mlio.IOInterface 
	%% IMRCURVE   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	
    
    properties (Abstract)  
        noclobber
        
        tracer % char, e.g., 'gadobutrol'
        length % integer, number valid frames
        scanDuration % sec  
        dt % sec  
        dV % mL
        TR % sec
        times
        timeInterpolants
        conc
        concInterpolants
        header % cf. mlfourd.NIfTIInterface        
    end 
    
    methods (Abstract)
        itsMagnetization(this)
        itsKConcentration(this)
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

