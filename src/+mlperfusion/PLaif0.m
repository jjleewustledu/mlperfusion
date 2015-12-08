classdef PLaif0 < mlperfusion.AbstractPLaif 
	%% PLAIF0   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties
        baseTitle = 'PLaif0'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'        
        
        F  = 0.00654
        PS = 0.0239
        S0 = 8.40e6
        a  = 1.19
        b  = 0.193
        t0 = 50.1
    end 
    
    properties (Dependent)
        mapParams 
    end
    
    methods %% GET
        function m = get.mapParams(this)
            m = containers.Map;
            N = 5;
            m('F')  = struct('fixed', 0, 'min', 0.004305,                    'mean', this.F,  'max', 0.01229);
            m('PS') = struct('fixed', 0, 'min', 0.009275,                    'mean', this.PS, 'max', 0.03675);
            m('S0') = struct('fixed', 0, 'min', max(this.S0 - N*this.S0, 0), 'mean', this.S0, 'max', this.S0 + N*this.S0);
            m('a')  = struct('fixed', 0, 'min', max(this.a  - N*this.a,  0), 'mean', this.a,  'max', this.a  + N*this.a); 
            m('b')  = struct('fixed', 0, 'min', max(this.b  - N*this.b,  0), 'mean', this.b,  'max', this.b  + N*this.b);
            m('t0') = struct('fixed', 0, 'min',     this.t0 - N*this.t0,     'mean', this.t0, 'max', this.t0 + N*this.t0); 
        end
    end
    
    methods (Static)
        function this = load(ecatFn, maskFn)
            import mlpet.* mlperfusion.* mlfourd.*;
            mask = MaskingNIfTId.load(maskFn);
            ecat = EcatExactHRPlus.load(ecatFn);
            ecat = ecat.masked(mask);
            ecat = ecat.volumeSummed;
            
            ecat.img = ecat.img / mask.count;
           
            this = PLaif0(ecat.times, ecat.tscCounts);
        end
        function this = runPLaif(times, becq)
            this = mlperfusion.PLaif0(times, becq);
            this = this.estimateParameters(this.mapParams);
        end        
        function m    = tscCounts(F, PS, S0, a, b, t0, t)
            import mlperfusion.*;
            m = S0 * PLaif0.kConcentration(F, PS, a, b, t0, t);
        end          
        function kC   = kConcentration(F, PS, a, b, t0, t)
            import mlperfusion.*;
            psfTerm = (1 - exp(-PS/F));
            delta   = psfTerm * F / PLaif0.LAMBDA; %  + PLaif0.LAMBDA_DECAY_15O -  PLaif0.LAMBDA_DECAY_15O for non-decaying gamma-variate bolus
            kC      = psfTerm * F * PLaif0.flowTerm(a, b, delta, t0, t);
            kC      = abs(kC);
        end
        function kA   = kAif(a, b, t0, t)
            import mlperfusion.*
            kA = exp(-PLaif0.LAMBDA_DECAY_15O*(t - t0)) .* PLaif0.Heaviside(t, t0) .* PLaif0.bolusFlowTerm(a, b, t0, t);
            kA = abs(kA);
        end
        function this = simulateMcmc(F, PS, S0, a, b, t0, t, becq, mapParams)
            import mlperfusion.*;            
            this = PLaif0(t, becq);
            this = this.estimateParameters(mapParams) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, PLaif0.tscCounts(F, PS, S0, a, b, t0, t), 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  F%g, PS %g, S0 %g, alpha %g, beta %g, t0 %g', ...
                  F, PS, S0, a, b, t0));
            xlabel('time/s');
            ylabel('activity/Bq');
        end    
    end

	methods
 		function this = PLaif0(varargin) 
 			%% PLAIF0 
 			%  Usage:  this = PLaif0([times, tscCounts]) 
 			
 			this = this@mlperfusion.AbstractPLaif(varargin{:});
            this.expectedBestFitParams_ = ...
                [this.F this.PS this.S0 this.a this.b this.t0]';
        end 
        
        function this = simulateItsMcmc(this)
            import mlperfusion.*;
            becq = PLaif0.tscCounts( ...
                   this.F, this.PS, this.S0, this.a, this.b, this.t0, this.times); 
            this = PLaif0.simulateMcmc( ...
                   this.F, this.PS, this.S0, this.a, this.b, this.t0, this.times, becq, this.mapParams);
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.PLaif0.kAif(this.a, this.b, this.t0, this.times);
        end
        function m    = itsTscCounts(this)
            m = mlperfusion.PLaif0.tscCounts(this.F, this.PS, this.S0, this.a, this.b, this.t0, this.times);
        end
        function kc   = itsKConcentration(this)
            kc = mlperfusion.PLaif0.kConcentration(this.F, this.PS, this.a, this.b, this.t0, this.times);
        end
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'mapParams', this.mapParams, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            import mlbayesian.*;
            [this.S0,this.t0]      = this.estimateS0t0(this.independentData, this.dependentData);
            this.theParameters     = McmcParameters(ip.Results.mapParams);
            this.ensureKeyOrdering({'F' 'PS' 'S0' 'a' 'b' 't0'});
            this.theStrategy       = MCMC(this, this.dependentData, this.theParameters);
            [~,~,this.theStrategy] = this.theStrategy.runMcmc;
            this.F  = this.finalParams('F');
            this.PS = this.finalParams('PS');
            this.S0 = this.finalParams('S0');
            this.a  = this.finalParams('a');
            this.b  = this.finalParams('b');
            this.t0 = this.finalParams('t0');
        end
        function ed   = estimateData(this)
            keys = this.theParameters.paramsMap.keys;
            ed = this.estimateDataFast( ...
                this.finalParams(keys{1}), ...
                this.finalParams(keys{2}), ...
                this.finalParams(keys{3}), ...
                this.finalParams(keys{4}), ...
                this.finalParams(keys{5}), ...
                this.finalParams(keys{6}));
        end   
        function ed   = estimateDataFast(this, F, PS, S0, a, b, t0)
            ed = this.tscCounts(F, PS, S0, a, b, t0, this.times);
        end         
        function        plotInitialData(this)
            figure;
            max_b  = max(this.itsTscCounts);
            max_dd = max(this.dependentData);
            plot(this.times, this.itsTscCounts/max_b, ...
                 this.times, this.dependentData/max_dd);
            title(sprintf('PLaif0.plotInitialData:  %s', str2pnum(pwd)), 'Interpreter', 'none');
            legend('Bayesian activity', 'activity from data');
            xlabel('time/s');
            ylabel(sprintf('arbitrary; rescaled by %g, %g', max_b, max_dd));
        end
        function        plot(this, varargin)
            figure;
            plot(this.times, this.itsTscCounts, this.times, this.dependentData, 'o', varargin{:});
            legend('Bayesian activity', 'activity from data');
            title(sprintf('PLaif0.plotProduct:  F %g, PS %g, S0 %g, a %g, b %g, t0 %g', ...
                this.F, this.PS, this.S0, this.a, this.b, this.t0), 'Interpreter', 'none');
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end        
        function        plotParVars(this, par, vars)
            assert(lstrfind(par, properties('mlperfusion.PLaif0')));
            assert(isnumeric(vars));
            switch (par)
                case 'F'
                    for v = 1:length(vars)
                        args{v} = { vars(v) this.PS this.S0 this.a  this.b  this.t0  this.times }; end
                case 'PS'
                    for v = 1:length(vars)
                        args{v} = { this.F  vars(v) this.S0 this.a  this.b  this.t0  this.times }; end
                case 'S0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS vars(v) this.a  this.b  this.t0  this.times }; end
                case 'a'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 vars(v) this.b  this.t0  this.times }; end
                case 'b'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  vars(v) this.t0  this.times }; end
                case 't0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  vars(v)  this.times }; end
            end
            this.plotParArgs(par, args, vars);
        end
    end
    
    %% PRIVATE
    
    methods (Access = 'private')
        function plotParArgs(this, par, args, vars)
            assert(lstrfind(par, properties('mlperfusion.PLaif0')));
            assert(iscell(args));
            assert(isnumeric(vars));
            import mlperfusion.*;
            figure
            hold on
            for v = 1:size(args,2)
                argsv = args{v};
                plot(this.times, PLaif0.tscCounts(argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7}));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b %g, t0 %g', ...
                          argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}));
            legend(cellfun(@(x) sprintf('%s = %g', par, x), num2cell(vars), 'UniformOutput', false));
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

