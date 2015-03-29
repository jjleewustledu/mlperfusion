classdef Laif < mlbayesian.AbstractMcmcProblem 
	%% LAIF   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties
        showPlots = true	 
        baseTitle = 'Laif'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'
    end 
    
    methods (Static)  
        
        function m    = magnetization0(S0, F, a, b, d, t, t0)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif.kConcentration0(a, b, d, t, t0));
            m = abs(m);
        end  
        function m    = magnetization1(S0, F, e, a, b, d, g, t, t0)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif.kConcentration1(e, a, b, d, g, t, t0));
            m = abs(m);
        end 
        function m    = magnetization2(S0, F, a, b, d, t, t0, t1, n)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif.kConcentration2(a, b, d, t, t0, t1, n));
            m = abs(m);
        end
        function m    = magnetization3(S0, F, e, a, b, d, g, t, t0, t1, n, n2)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif.kConcentration3(e, a, b, d, g, t, t0, t1, n, n2));
            m = abs(m);
        end
        
        function kC   = kConcentration0(a, b, d, t, t0)
            import mlperfusion.*;
            kC = Laif.flowTerm(a, b, d, t, t0);
        end  
        function kC   = kConcentration1(e, a, b, d, g, t, t0)
            import mlperfusion.*;
            kC = e * Laif.flowTerm(a, b, d, t, t0) + ...
                 (1 - e) * Laif.steadyStateTerm(d, g, t, t0);
        end    
        function kC   = kConcentration2(a, b, d, t, t0, t1, n)
            import mlperfusion.*;
            kC =     Laif.flowTerm(a, b, d, t, t0) + ...
                 n * Laif.flowTerm(a, b, d, t, t1);
        end
        function kC   = kConcentration3(e, a, b, d, g, t, t0, t1, n, n2)
            import mlperfusion.*;
            kC = e  * Laif.flowTerm(a, b, d, t, t0) + ...
                 n  * Laif.flowTerm(a, b, d, t, t1) + ...
                 n2 * Laif.flowTerm(a, b, d, t, t2) + ...
                 (1 - e) * Laif.steadyStateTerm(d, g, t, t2);
        end
        
        function conc = flowTerm(a, b, d, t, t0)
            if (b == d)
                b = b + eps;
            end
            conc0 = exp(-d*t) * b^(a+1) / (b-d)^(a+1);
            conc0 = conc0 .* gammainc((b - d)*t, a+1);
            
            idx_t0 = floor(t0) + 1;
            conc   = zeros(1, length(t));
            conc(idx_t0:end) = conc0(1:end-idx_t0+1);
        end
        function conc = steadyStateTerm(d, g, t, t0)
            if (g == d)
                g = g + eps;
            end
            conc0 = (1 - exp(-d*t))/d + ...
                    (exp(-g*t) - exp(-d*t))/(g - d);
            
            idx_t0 = floor(t0) + 1;
            conc   = zeros(1, length(t));
            conc(idx_t0:end) = conc0(1:end-idx_t0+1);
        end
        
        function this = simulateMcmc0(S0, F, a, b, d, t, t0, dsc, map)
            
            import mlperfusion.*;            
            m0   = Laif.magnetization0(S0, F, a, b, d, t, t0);
            this = Laif(t, dsc);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData0, t, m0, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  S0 %g, F %g, alpha %g, beta %g, delta %g, t0 %g', ...
                  S0, F, a, b, d, t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end        
        function this = simulateMcmc1(S0, F, e, a, b, d, g, t, t0, dsc, map)
            
            import mlperfusion.*;            
            m0   = Laif.magnetization1(S0, F, e, a, b, d, g, t, t0);
            this = Laif(t, dsc);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData1, t, m0, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  S0 %g, F %g, eps %g, alpha %g, beta %g, delta %g, gamma %g, t0 %g', ...
                  S0, F, e, a, b, d, g, t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end        
        function this = simulateMcmc2(S0, F, a, b, d, t, t0, t1, n, dsc, map)
            
            import mlperfusion.*;            
            m2   = Laif.magnetization2(S0, F, a, b, d, t, t0, t1, n);
            this = Laif(t, dsc);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData2, t, m2, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  S0 %g, F %g, alpha %g, beta %g, delta %g, t0 %g, t1 %g, n %g', ...
                  S0, F, a, b, d, t0, t1, n));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end
    end

	methods 		
        
 		function this = Laif(times, magn, varargin) 
 			%% LAIF 
 			%  Usage:  this = Laif(WholeBrainDSC_object) 
 			
 			this = this@mlbayesian.AbstractMcmcProblem(times, magn);  
            p = inputParser;
            addRequired(p, 'times', @isnumeric);
            addRequired(p, 'magn',  @isnumeric);
            parse(p, times, magn, varargin{:});
        end 
        function this = estimateParameters(this, map)
            import mlbayesian.*;
            assert(isa(map, 'containers.Map'));
            this.paramsManager = BayesianParameters(map);
            this.mcmc          = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.mcmc]    = this.mcmc.runMcmc;
        end
        function this = estimateData(this)
            this = this.estimateData1;
        end
        function this = estimateDataFast(this, S0, F, e, a, b, d, g, t0)
            this = this.estimateDataFast1(S0, F, e, a, b, d, g, t0);
        end
        function ps   = adjustParams(this, ps)
            ps = this.adjustParams0(ps);
        end
    end
    
    %% PRIVATE
    
    methods (Access = 'private')
        
        function ed   = estimateData0(this)
            ed = this.estimateDataFast0( ...
                this.finalParams('S0'), this.finalParams('F'), ...
                this.finalParams('a'),  this.finalParams('b'), this.finalParams('d'), this.finalParams('t0'));
        end
        function ed   = estimateDataFast0(this, S0, F, a, b, d, t0)  
            ed = this.magnetization0(S0, F, a, b, d, this.independentData, t0);
        end         
        function ps   = adjustParams0(this, ps)
            manager = this.paramsManager;
            if (ps(manager.paramsIndices('d')) > ps(manager.paramsIndices('b')))
                tmp                            = ps(manager.paramsIndices('b'));
                ps(manager.paramsIndices('b')) = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = tmp;
            end
        end
        
        function ed   = estimateData1(this)
            ed = this.estimateDataFast1( ...
                this.finalParams('S0'), this.finalParams('F'), this.finalParams('e'), ...
                this.finalParams('a'),  this.finalParams('b'), this.finalParams('d'), this.finalParams('g'), this.finalParams('t0'));
        end
        function ed   = estimateDataFast1(this, S0, F, e, a, b, d, g, t0)  
            ed = this.magnetization1(S0, F, e, a, b, d, g, this.independentData, t0);
        end         
        function ps   = adjustParams1(this, ps)
            manager = this.paramsManager;
            if (ps(manager.paramsIndices('d')) > ps(manager.paramsIndices('b')))
                tmp                            = ps(manager.paramsIndices('b'));
                ps(manager.paramsIndices('b')) = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = tmp;
            end
        end
        
        function ed   = estimateData2(this)
            ed = this.estimateDataFast2( ...
                this.finalParams('S0'), this.finalParams('F'), ...
                this.finalParams('a'),  this.finalParams('b'), this.finalParams('d'), this.finalParams('t0'), ...
                this.finalParams('t1'), this.finalParams('n'));
        end
        function ed   = estimateDataFast2(this, S0, F, a, b, d, t0, t1, n)  
            ed = this.magnetization2(S0, F, a, b, d, this.independentData, t0, t1, n);
        end         
        function ps   = adjustParams2(this, ps)
            manager = this.paramsManager;
            if (ps(manager.paramsIndices('d')) > ps(manager.paramsIndices('b')))
                tmp                            = ps(manager.paramsIndices('b'));
                ps(manager.paramsIndices('b')) = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = tmp;
            end
            if (ps(manager.paramsIndices('t0')) > ps(manager.paramsIndices('t1')))                
                tmp                             = ps(manager.paramsIndices('t0'));
                ps(manager.paramsIndices('t1')) = ps(manager.paramsIndices('t0'));
                ps(manager.paramsIndices('t0')) = tmp;
            end
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

