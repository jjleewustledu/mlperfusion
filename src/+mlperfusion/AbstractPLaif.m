classdef (Abstract) AbstractPLaif < mlbayesian.AbstractMcmcStrategy & mlperfusion.ILaif
	%% ABSTRACTPLAIF   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$     
    
    properties (Constant)        
        LAMBDA           = 0.95        % brain-blood equilibrium partition coefficient, mL/mL, Herscovitch, Raichle, JCBFM (1985) 5:65
        LAMBDA_DECAY_15O = 0.005670379 % k | dq/dt = -kq, for activity q of [15O] with half-life = 122.24 s
    end
    
    methods (Static)
        function conc = bolusFlowFractal(a, b, p, t0, t)
            if (t(1) >= t0) % saves extra flops from slide()
                t_   = t - t0;
                conc = t_.^a .* exp(-(b*t_).^p);
            else
                t_   = t - t(1);
                conc = t_.^a .* exp(-(b*t_).^p);
                conc = mlperfusion.AbstractPLaif.slide(abs(conc), t, t0 - t(1));
            end
            conc = abs(conc*p*b^(a+1)/gamma((a+1)/p));
        end
        function conc = bolusFlowTerm(a, b, t0, t)
            if (t(1) >= t0)
                t_   = t - t0;
                conc = t_.^a .* exp(-b*t_);
                conc = abs(conc);
            else 
                t_   = t - t(1);
                conc = t_.^a .* exp(-b*t_);
                conc = mlperfusion.AbstractPLaif.slide(abs(conc), t, t0 - t(1));
            end
            conc = conc*b^(a+1)/gamma(a+1);
        end
        function conc = bolusSteadyStateTerm(e, g, t0, t)
            import mlperfusion.*;
            if (t(1) >= t0)
                t_   = t - t0;
                conc = e * (1 - exp(-g*t_)) .* AbstractPLaif.Heaviside(t_, t0);
                conc = abs(conc);
            else 
                t_   = t - t(1);
                conc = e * (1 - exp(-g*t_)) .* AbstractPLaif.Heaviside(t_, t0);
                conc = AbstractPLaif.slide(abs(conc), t, t0 - t(1));
            end
        end
        function conc = flowFractal(a, b, d, ldecay, p, t0, t)
            dt = (t(2) - t(1))/2;
            t_ = t(1):dt:t(end);
            import mlperfusion.*;
            expl = exp(-ldecay*(t_ - t0)) .* AbstractPLaif.Heaviside(t_, t0);
            expd = exp(-d*(t_));
            conc = conv(AbstractPLaif.bolusFlowFractal(a, b, p, t0, t_) .* expl, expd);
            conc = conc(1:length(t_));
            conc = pchip(t_, conc, t); 
        end
        function conc = flowTerm(a, b, d, t0, t)
            if (t(1) >= t0)
                t_   = t - t0;
                conc = exp(-d*t_) * b^(a+1) / (b-d)^(a+1);
                conc = conc .* gammainc((b - d)*t_, a+1);
                conc = abs(conc);
            else 
                t_   = t - t(1); 
                conc = exp(-d*t_) * b^(a+1) / (b-d)^(a+1);
                conc = conc .* gammainc((b - d)*t_, a+1);
                conc = mlperfusion.AbstractPLaif.slide(abs(conc), t, t0 - t(1));
            end
        end
        function conc = steadyStateTerm(d, e, g, ldecay, t0, t)
            if (t(1) >= t0)
                t_   = t - t0;            
                conc = e * ((exp(-(ldecay + g)*t_) - exp(-d*t_))/(ldecay + g - d) - ...
                            (exp( -ldecay*t_)      - exp(-d*t_))/(ldecay - d));
                conc = abs(conc);
            else  
                t_   = t - t(1);
                conc = e * ((exp(-(ldecay + g)*t_) - exp(-d*t_))/(ldecay + g - d) - ...
                            (exp( -ldecay*t_)      - exp(-d*t_))/(ldecay - d));
                conc = mlperfusion.AbstractPLaif.slide(abs(conc), t, t0 - t(1));
            end
        end
        function f    = invs_to_mLmin100g(f)
            f = 100 * 60 * f / mlpet.AutoradiographyBuilder.BRAIN_DENSITY;
        end
    end

	methods 		  
 		function this = AbstractPLaif(varargin) 
 			%% ABSTRACTPLAIF 
 			%  Usage:  this = AbstractPLaif(times, magnetization[, ...]) % double
 			 
 			this = this@mlbayesian.AbstractMcmcStrategy(varargin{:});  
 		end 
 	end 
    
    %% PROTECTED
    
    methods (Static, Access = 'protected')
        function [S0,t0] = estimateS0t0(indDat, depDat)
            searchFraction = 0.05;
            bigChange = searchFraction * (max(depDat) - min(depDat));
            for ti = 1:length(indDat)-1
                if (depDat(ti+1) - depDat(ti) > bigChange)
                    tilast = ti;
                    break
                end
            end
            S0 = max(depDat);
            t0 = indDat(tilast);
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

