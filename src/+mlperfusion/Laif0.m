classdef Laif0 < mlperfusion.AbstractLaif 
	%% LAIF0   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties
        showPlots = true	 
        baseTitle = 'Laif0'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'        
        
        F  = 2.095813
        S0 = 540.664554
        a  = 5.582462
        b  = 1.278431
        d  = 0.493286
        t0 = 16.465791
        
        FStd  = 0.436116
        S0Std = 1.358619
        aStd  = 0.795849
        bStd  = 0.200685
        dStd  = 0.111199
        t0Std = 0.439540
    end 
    
    properties (Dependent)
        map 
    end
    
    methods %% GET
        function m = get.map(this)
            m = containers.Map;
            N = 3;
            m('F')  = struct('fixed', 0, 'min', this.F  - N*this.FStd,  'mean', this.F,  'max', this.F  + N*this.FStd);
            m('S0') = struct('fixed', 1, 'min', this.S0 - N*this.S0Std, 'mean', this.S0, 'max', this.S0 + N*this.S0Std);
            m('a')  = struct('fixed', 0, 'min', this.a  - N*this.aStd,  'mean', this.a,  'max', this.a  + N*this.aStd); 
            m('b')  = struct('fixed', 0, 'min', this.b  - N*this.bStd,  'mean', this.b,  'max', this.b  + N*this.bStd);
            m('d')  = struct('fixed', 0, 'min', this.d  - N*this.dStd,  'mean', this.d,  'max', this.d  + N*this.dStd);
            m('t0') = struct('fixed', 1, 'min', this.t0 - N*this.t0Std, 'mean', this.t0, 'max', this.t0 + N*this.t0Std); 
        end
    end
    
    methods (Static)
        function this = load(dscFn, maskFn)
            import mlperfusion.*;
            wbDsc = WholeBrainDSC(dscFn, maskFn);
            this = Laif0(wbDsc.times, wbDsc.itsMagnetization);
        end
        function this = runLaif(times, magn)
            this = mlperfusion.Laif0(times, magn);
            this = this.estimateS0t0;
            this = this.estimateParameters(this.map);
        end        
        function m    = magnetization(F, S0, a, b, d, t, t0)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif0.kConcentration(a, b, d, t, t0));
            m = abs(m);
        end          
        function kC   = kConcentration(a, b, d, t, t0)
            import mlperfusion.*;
            kC = Laif0.flowTerm(a, b, d, t, t0);
            kC = abs(kC);
        end
        function kA   = kAif(a, b, t, t0)
            import mlperfusion.*
            kA = Laif0.bolusFlowTerm(a, b, t, t0);
            kA = abs(kA);
        end
        function this = simulateMcmc(F, S0, a, b, d, t, t0, dsc, map)
            import mlperfusion.*;            
            magn = Laif0.magnetization(F, S0, a, b, d, t, t0);
            this = Laif0(t, dsc);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, magn, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  F%g, S0 %g alpha %g, beta %g, delta %g, t0 %g', ...
                  F, S0, a, b, d, t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end    
    end

	methods
 		function this = Laif0(varargin) 
 			%% LAIF0 
 			%  Usage:  this = Laif0([times, magnetization]) 
 			
 			this = this@mlperfusion.AbstractLaif(varargin{:});
            this.expectedBestFitParams_ = ...
                [this.F this.S0 this.a this.b this.d this.t0]';
        end 
        
        function this = simulateItsMcmc(this)
            import mlperfusion.*;
            magn = Laif0.magnetization( ...
                   this.F, this.S0, this.a, this.b, this.d, this.times, this.t0); 
            this = Laif0.simulateMcmc( ...
                   this.F, this.S0, this.a, this.b, this.d, this.times, this.t0, magn, this.map);
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.Laif0.kAif(this.a, this.b, this.times, this.t0);
        end
        function m    = itsMagnetization(this)
            m = mlperfusion.Laif0.magnetization(this.F, this.S0, this.a, this.b, this.d, this.times, this.t0);
        end
        function kc   = itsKConcentration(this)
            kc = mlperfusion.Laif0.kConcentration(this.a, this.b, this.d, this.times, this.t0);
        end
        function this = estimateAll(this)
            this = this.estimateS0t0;
            this = this.estimateParameters(this.map);
        end
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'map', this.map, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            import mlbayesian.*;
            this.paramsManager = BayesianParameters(ip.Results.map);
            this.ensureKeyOrdering({'F' 'S0' 'a' 'b' 'd' 't0'});
            this.mcmc          = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.mcmc]    = this.mcmc.runMcmc;
            this.F = this.finalParams('F');
            this.S0 = this.finalParams('S0');
            this.a = this.finalParams('a');
            this.b = this.finalParams('b');
            this.d = this.finalParams('d');
            this.t0 = this.finalParams('t0');
        end
        function ed   = estimateData(this)
            keys = this.paramsManager.paramsMap.keys;
            ed = this.estimateDataFast( ...
                this.finalParams(keys{1}), ...
                this.finalParams(keys{2}), ...
                this.finalParams(keys{3}), ...
                this.finalParams(keys{4}), ...
                this.finalParams(keys{5}), ...
                this.finalParams(keys{6}));
        end   
        function ed   = estimateDataFast(this, F, S0, a, b, d, t0)  
            ed = this.magnetization(F, S0, a, b, d, this.times, t0);
        end         
        function        plotInitialData(this)
            figure;
            max_m  = max(this.itsMagnetization);
            max_dd = max(this.dependentData);
            plot(this.times, this.itsMagnetization/max_m, ...
                 this.times, this.dependentData/max_dd);
            title(sprintf('Laif0.plotInitialData:  %s', str2pnum(pwd)), 'Interpreter', 'none');
            legend('Bayesian magn', 'magn from data');
            xlabel('time/s');
            ylabel(sprintf('arbitrary; rescaled by %g, %g', max_m, max_dd));
        end
        function        plotProduct(this)
            figure;
            plot(this.times, this.itsMagnetization, this.times, this.dependentData, 'o');
            legend('Bayesian magn', 'magn from data');
            title(sprintf('Laif0.plotProduct:  F %g, S0 %g, a %g, b %g, d %g, t0 %g', ...
                this.F, this.S0, this.a, this.b, this.d, this.t0), 'Interpreter', 'none');
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end        
        function        plotParVars(this, par, vars)
            assert(lstrfind(par, properties('mlperfusion.Laif0')));
            assert(isnumeric(vars));
            switch (par)
                case 'F'
                    for v = 1:length(vars)
                        args{v} = { vars(v) this.S0 this.a  this.b  this.d  this.t0  this.times }; end
                case 'S0'
                    for v = 1:length(vars)
                        args{v} = { this.F  vars(v) this.a  this.b  this.d  this.t0  this.times }; end
                case 'a'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 vars(v) this.b  this.d  this.t0  this.times }; end
                case 'b'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  vars(v) this.d  this.t0  this.times }; end
                case 'd'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  this.b  vars(v) this.t0  this.times }; end
                case 't0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  this.b  this.d  vars(v)  this.times }; end
            end
            this.plotParArgs(par, args, vars);
        end
        function ps   = adjustParams(this, ps)
            manager = this.paramsManager;
            if (ps(manager.paramsIndices('d')) > ps(manager.paramsIndices('b')))
                tmp                            = ps(manager.paramsIndices('b'));
                ps(manager.paramsIndices('b')) = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = tmp;
            end
        end
    end
    
    %% PRIVATE
    
    methods (Access = 'private')
        function plotParArgs(this, par, args, vars)
            assert(lstrfind(par, properties('mlperfusion.Laif0')));
            assert(iscell(args));
            assert(isnumeric(vars));
            import mlperfusion.*;
            figure
            hold on
            for v = 1:size(args,2)
                argsv = args{v};
                plot(this.times, Laif0.magnetization(argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{7}, argsv{6}));
            end
            title(sprintf('F %g, S0 %g, a %g, b %g, d %g, t0 %g', ...
                          argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}));
            legend(cellfun(@(x) sprintf('%s = %g', par, x), num2cell(vars), 'UniformOutput', false));
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

