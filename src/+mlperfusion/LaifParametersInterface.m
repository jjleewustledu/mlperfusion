classdef LaifParametersInterface 
	%% LAIFPARAMETERSINTERFACE lists the canonical parameters estimated by Localized Arterial Input Fucnction (LAIF) methods using Bayesian methods.
    %  
	%  $Revision$ 
	%  was created $Date$ 
	%  by $Author$, 
	%  last modified $LastChangedDate$ 
	%  and checked into repository $URL$, 
	%  developed on Matlab 8.3.0.532 (R2014a) 
	%  $Id$ 
	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Abstract) 
        S0
        CBF
        CBV
        MTT
        t0    % bolus delay
        alpha % (t - t_0)^\alpha
        beta  % e^{-\beta (t - t_0)}
        delta % 1/MTT
        gamma % 1/\tau for time constant \tau for rise of steady-state term
        eps   % relative size of main bolus
        t1    % time of recirculation peak
        nu    % relative size of recirculation peak
        
        %  requires:  beta > delta; beta > gamma; alpha+1 > 0
        %  requires: eps > nu;  t1 > t0
        %  size constants:  eps*gv0 + nu*gv1 + (1-eps)*(SS const term)
	end 

	%  Created with NewClassStrategy by John J. Lee, after newfcn by Frank Gonzalez-Morphy 
end

