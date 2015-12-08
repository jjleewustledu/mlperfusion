classdef (Abstract) AbstractLaif < mlbayesian.AbstractMcmcProblem & mlperfusion.ILaif
	%% ABSTRACTLAIF   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
    
    properties (Dependent)
        pnum
        taus
    end
    
    methods %% GET
        function p = get.pnum(~)
            p = str2pnum(pwd);
        end
        function t = get.taus(this)
            t = this.times(2:end) - this.times(1:end-1);
        end
    end
    
    methods (Static)
        function conc = bolusFlowTerm(a, b, t, t0)
            conc0 = b^(a+1) * t.^a .* exp(-b*t) / gamma(a+1);
            
            idx_t0 = mlperfusion.AbstractLaif.indexOf(t, t0);
            conc   = zeros(1, length(t));
            conc(idx_t0:end) = conc0(1:end-idx_t0+1);
            conc   = abs(conc);
        end
        function conc = bolusSteadyStateTerm(g, t, t0)
            conc0 = (1 - exp(-g*t));
            
            idx_t0 = mlperfusion.AbstractLaif.indexOf(t, t0);
            conc   = zeros(1, length(t));
            conc(idx_t0:end) = conc0(1:end-idx_t0+1);
            conc   = abs(conc);
        end
        function conc = flowTerm(a, b, d, t, t0)
            conc0 = exp(-d*t) * b^(a+1) / (b-d)^(a+1);
            conc0 = conc0 .* gammainc((b - d)*t, a+1);
            
            idx_t0 = mlperfusion.AbstractLaif.indexOf(t, t0);
            conc   = zeros(1, length(t));
            conc(idx_t0:end) = conc0(1:end-idx_t0+1);
            conc   = abs(conc);
        end
        function conc = steadyStateTerm(d, g, t, t0)
            conc0 = (1 - exp(-d*t))/d + ...
                    (exp(-g*t) - exp(-d*t))/(g - d);            
            
            idx_t0 = mlperfusion.AbstractLaif.indexOf(t, t0);
            conc   = zeros(1, length(t));
            conc(idx_t0:end) = conc0(1:end-idx_t0+1);
            conc   = abs(conc);
        end   
    end

	methods 		  
 		function this = AbstractLaif(varargin) 
 			%% ABSTRACTLAIF 
 			%  Usage:  this = AbstractLaif(times, magnetization[, ...]) % double
 			 
 			this = this@mlbayesian.AbstractMcmcProblem(varargin{:});  
 		end 
 	end 
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function this = estimateS0t0(this)
            searchFraction = 0.05;
            bigChange = searchFraction * (max(this.dependentData) - min(this.dependentData));
            for ti = 1:length(this.independentData)-1
                if (abs(this.dependentData(ti+1) - this.dependentData(ti)) > bigChange)
                    tilast = ti;
                    break
                end
            end
            this.S0 = mean(this.dependentData(1:tilast));
            this.t0 = this.independentData(tilast);
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

