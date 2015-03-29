classdef WholeBrainLaif
	%% WHOLEBRAINLAIF   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 

	properties 
        wb_dsc
        laif
 	end 

	methods 
		  
 		function this = WholeBrainLaif() 
 			%% WHOLEBRAINLAIF 
 			%  Usage:  this = WholeBrainLaif() 

            import mlperfusion.*;
            this.wb_dsc = WholeBrainDSC('ep2d_default_mcf.nii.gz', 'perfMask.nii.gz');
            this.laif   = Laif(this.wb_dsc.times, this.wb_dsc.magnetization);
            
            map = containers.Map;            
            map('a')   = struct('fixed', 0, 'min',   2,    'mean',  8.5, 'max', 16);
            map('d')   = struct('fixed', 0, 'min',   0,    'mean',  5.4, 'max',  8);
            map('p')   = struct('fixed', 0, 'min',   0.5,  'mean',  1.1, 'max',  1.5); 
            map('q0')  = struct('fixed', 1, 'min',   1/tf, 'mean',  1,   'max',  2e7);
            map('t0')  = struct('fixed', 1, 'min',   0,    'mean', 0,    'max', tf/2); 

 		end 
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

