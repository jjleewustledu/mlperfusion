classdef Laif2 < mlperfusion.AbstractLaif
	%% LAIF2   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
    
	properties
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'
        
        F  = 3.25  % set to expected best-fit
        S0 = 557
        a  = 6.53
        b  = 0.920
        d  = 0.511
        e  = 0.984
        g  = 0.186
        n  = 0.132
        t0 = 14.4
        t1 = 32.4
        
        FS  = 0.282321
        S0S = 0.5
        aS  = 0.267337
        bS  = 0.064123
        dS  = 0.056065
        eS  = 0.000459
        gS  = 0.035239
        nS  = 0.009767
        t0S = 0.1
        t1S = 0.426349
        
        priorN = 100
    end 
    
    properties (Dependent)
        baseTitle
        detailedTitle
        map 
    end
    
    methods %% GET
        function bt  = get.baseTitle(this)
            bt = sprintf('Laif2 %s', this.pnum);
        end
        function dt  = get.detailedTitle(this)
            dt = sprintf('%s:\nF %g, S0 %g, a %g, b %g, d %g, e %g, g %g, n %g, t0 %g, t1 %g', ...
                         this.baseTitle, this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.t0, this.t1);
        end
        function m = get.map(this)            
            m = containers.Map;
            m('F')  = struct('fixed',0,'min',this.prLow(this.F, this.FS, 1),  'mean',this.F, 'max',this.prHigh(this.F, this.FS,  6));
            m('S0') = struct('fixed',1,'min',this.prLow(this.S0,this.S0S,1e2),'mean',this.S0,'max',this.prHigh(this.S0,this.S0S, 1e3));
            m('a')  = struct('fixed',0,'min',this.prLow(this.a, this.aS, 0),  'mean',this.a, 'max',this.prHigh(this.a, this.aS, 30)); 
            m('b')  = struct('fixed',0,'min',this.prLow(this.b, this.bS, eps),'mean',this.b, 'max',this.prHigh(this.b, this.bS,  1));
            m('d')  = struct('fixed',0,'min',this.prLow(this.d, this.dS, eps),'mean',this.d, 'max',this.prHigh(this.d, this.dS,  1));
            m('e')  = struct('fixed',0,'min',this.prLow(this.e, this.eS, eps),'mean',this.e, 'max',this.prHigh(this.e, this.eS,  1));
            m('g')  = struct('fixed',0,'min',this.prLow(this.g, this.gS, eps),'mean',this.g, 'max',this.prHigh(this.g, this.gS,  1));
            m('n')  = struct('fixed',0,'min',eps,                             'mean',this.n, 'max',this.prHigh(this.n, this.nS,  0.5));
            m('t0') = struct('fixed',1,'min',this.prLow(this.t0,this.t0S,0),  'mean',this.t0,'max',this.prHigh(this.t0,this.t0S, this.timeFinal)); 
            m('t1') = struct('fixed',0,'min',this.prLow(this.t1,this.t1S,0),  'mean',this.t1,'max',this.prHigh(this.t1,this.t1S, this.timeFinal)); 
        end
    end
    
    methods (Static) 
        function this = load(varargin)
            %% LOAD
            %  Usage:  this = Laif2.load(DSC_filename, mask_filename[, timesToInterpolate])
            %  cf. ctor to mlperfusion.WholeBrainDSC
            
            import mlperfusion.*;
            wbDsc = WholeBrainDSC(varargin{:});
            this  = Laif2(wbDsc.times, wbDsc.itsMagnetization);
        end
        function this = simulateMcmc(F, S0, a, b, d, e, g, n, t, t0, t1, dsc, map)            
            import mlperfusion.*;            
            magn = Laif2.magnetization(F, S0, a, b, d, e, g, n, t, t0, t1);
            this = Laif2(t, dsc);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, magn, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  F %g, S0 %g, alpha %g, beta %g, delta %g, eps %g, gamma %g, nu %g, t0 %g, t1 %g', ...
                  F, S0, a, b, d, e, g, n, t0, t1));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end   
        function this = runLaif(times, magn)
            this = mlperfusion.Laif2(times, magn);
            this = this.estimateS0t0;
            this = this.estimateParameters(this.map);
        end
                  
        function m    = magnetization(F, S0, a, b, d, e, g, n, t, t0, t1)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif2.kConcentration(a, b, d, e, g, n, t, t0, t1));
            m = abs(m);
        end 
        function kC   = kConcentration(a, b, d, e, g, n, t, t0, t1)
            import mlperfusion.*;
            kC = (1 - n) * e  * Laif2.flowTerm(a, b, d, t, t0) + ...
                      n  * e  * Laif2.flowTerm(a, b, d, t, t1) + ...
                      (1 - e) * Laif2.steadyStateTerm(d, g, t, t0);
            kC = abs(kC);
        end     
        function kA   = kAif(a, b, e, g, n, t, t0, t1)
            import mlperfusion.*
            kA = (1 - n) * e  * Laif2.bolusFlowTerm(a, b, t, t0) + ...
                      n  * e  * Laif2.bolusFlowTerm(a, b, t, t1) + ...
                      (1 - e) * Laif2.bolusSteadyStateTerm(g, t, t0);
            kA = abs(kA);
        end   
        function kA   = kAif_1(a, b, t, t0)
            import mlperfusion.*
            kA = Laif2.bolusFlowTerm(a, b, t, t0);
            kA = abs(kA);
        end
        function kA   = kAif_2(a, b, n, t, t0, t1)
            import mlperfusion.*
            kA = (1 - n) * Laif2.bolusFlowTerm(a, b, t, t0) + ...
                      n  * Laif2.bolusFlowTerm(a, b, t, t1);
            kA = abs(kA);
        end
    end

	methods        
 		function this = Laif2(varargin) 
 			%% LAIF2 
 			%  Usage:  this = Laif2([times, magnetization]) 
 			
 			this = this@mlperfusion.AbstractLaif(varargin{:});            
            this.keysArgs_ = ...
                {this.F this.S0 this.a this.b this.d this.e this.g this.n this.t0 this.t1};
        end         
        
        function this = simulateItsMcmc(this)
            import mlperfusion.*;
            magn = Laif2.magnetization( ...
                   this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1); 
            this = Laif2.simulateMcmc( ...
                   this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1, magn, this.map);
        end
        function m    = itsMagnetization(this)
            m = mlperfusion.Laif2.magnetization(this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1);
        end
        function kc   = itsKConcentration(this)
            kc = mlperfusion.Laif2.kConcentration(this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1);
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.Laif2.kAif(this.a, this.b, this.e, this.g, this.n, this.times, this.t0, this.t1);
        end
        function ka   = itsKAif_1(this)
            ka = mlperfusion.Laif2.kAif_1(this.a, this.b, this.times, this.t0);
        end
        function ka   = itsKAif_2(this)
            ka = mlperfusion.Laif2.kAif_2(this.a, this.b, this.n, this.times, this.t0, this.t1); 
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
            this.paramsManager = BayesianParameters(varargin{:});
            this.ensureKeyOrdering({'F' 'S0' 'a' 'b' 'd' 'e' 'g' 'n' 't0' 't1'});
            this.mcmc          = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.mcmc]    = this.mcmc.runMcmc;
            this.F   = this.finalParams('F');
            this.S0  = this.finalParams('S0');
            this.a   = this.finalParams('a');
            this.b   = this.finalParams('b');
            this.d   = this.finalParams('d');
            this.e   = this.finalParams('e');
            this.g   = this.finalParams('g');
            this.n   = this.finalParams('n');
            this.t0  = this.finalParams('t0');
            this.t1  = this.finalParams('t1');
            if (~this.finalStds('F') < eps)
                this.FS  = this.finalStds('F'); end
            if (~this.finalStds('S0') < eps)
                this.S0S = this.finalStds('S0'); end
            if (~this.finalStds('a') < eps)
                this.aS  = this.finalStds('a'); end
            if (~this.finalStds('b') < eps)
                this.bS  = this.finalStds('b'); end
            if (~this.finalStds('d') < eps)
                this.dS  = this.finalStds('d'); end
            if (~this.finalStds('e') < eps)
                this.eS  = this.finalStds('e'); end
            if (~this.finalStds('g') < eps)
                this.gS  = this.finalStds('g'); end
            if (~this.finalStds('n') < eps)
                this.nS  = this.finalStds('n'); end
            if (~this.finalStds('t0') < eps)
                this.t0S = this.finalStds('t0'); end
            if (~this.finalStds('t1') < eps)
                this.t1S = this.finalStds('t1'); end
        end
        function ed   = estimateData(this)
            keys = this.paramsManager.paramsMap.keys;
            ed = this.estimateDataFast( ...
                this.finalParams(keys{1}), ...
                this.finalParams(keys{2}), ...
                this.finalParams(keys{3}), ...
                this.finalParams(keys{4}), ...
                this.finalParams(keys{5}), ...
                this.finalParams(keys{6}), ...
                this.finalParams(keys{7}), ...
                this.finalParams(keys{8}), ...
                this.finalParams(keys{9}), ...
                this.finalParams(keys{10}));
        end
        function ed   = estimateDataFast(this, F, S0, a, b, d, e, g, n, t0, t1)
            ed = this.magnetization(F, S0, a, b, d, e, g, n, this.times, t0, t1);
        end
        function ps   = adjustParams(this, ps)
            manager = this.paramsManager;
            if (ps(manager.paramsIndices('d')) > ps(manager.paramsIndices('b')))
                tmp                            = ps(manager.paramsIndices('b'));
                ps(manager.paramsIndices('b')) = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = tmp;
            end
            if (ps(manager.paramsIndices('g')) > ps(manager.paramsIndices('d')))
                tmp                            = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = ps(manager.paramsIndices('g'));
                ps(manager.paramsIndices('g')) = tmp;
            end
            if (ps(manager.paramsIndices('t0')) > ps(manager.paramsIndices('t1')))                
                tmp                             = ps(manager.paramsIndices('t1'));
                ps(manager.paramsIndices('t1')) = ps(manager.paramsIndices('t0'));
                ps(manager.paramsIndices('t0')) = tmp;
            end
        end
        function x    = prLow(this, x, xS, inf)
            x = x - this.priorN*xS;
            if (exist('inf','var') && x < inf); x = inf; end
        end
        function x    = prHigh(this, x, xS, sup)
            x = x + this.priorN*xS;
            if (exist('sup','var') && x > sup); x = sup; end
        end
        
        function        plotInitialData(this)
            figure;
            max_m  = max(this.itsMagnetization);
            max_dd = max(this.dependentData);
            plot(this.times, this.itsMagnetization/max_m, ...
                 this.times, this.dependentData/max_dd);
            title(sprintf('Laif2.plotInitialData:  %s', str2pnum(pwd)), 'Interpreter', 'none');
            legend('Bayesian magn', 'magn from data');
            xlabel('time/s');
            ylabel(sprintf('arbitrary; rescaled by %g, %g', max_m, max_dd));
        end
        function        plotProduct(this)
            figure;
            rescaling = max(this.itsMagnetization)/max(this.itsKAif);
            plot(this.times, this.itsMagnetization, this.times, this.itsKAif*rescaling, this.times, this.dependentData, 'o');
            legend('Bayesian magn', 'Bayesian AIF', 'magn from data');
            title(this.detailedTitle, 'Interpreter', 'none');
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end        
        function        plotParVars(this, par, vars)
            assert(lstrfind(par, properties('mlperfusion.Laif0')));
            assert(isnumeric(vars));
            switch (par)
                case 'F'
                    for v = 1:length(vars)
                        args{v} = { vars(v) this.S0 this.a  this.b  this.d  this.e  this.g  this.times this.n  this.t0  this.t1 }; end
                case 'S0'
                    for v = 1:length(vars)
                        args{v} = { this.F  vars(v) this.a  this.b  this.d  this.e  this.g  this.times this.n  this.t0  this.t1 }; end
                case 'a'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 vars(v) this.b  this.d  this.e  this.g  this.times this.n  this.t0  this.t1 }; end
                case 'b'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  vars(v) this.d  this.e  this.g  this.times this.n  this.t0  this.t1 }; end
                case 'd'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  this.b  vars(v) this.e  this.g  this.times this.n  this.t0  this.t1 }; end
                case 'e'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  this.b  this.d  vars(v) this.g  this.times this.n  this.t0  this.t1 }; end
                case 'g'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  this.b  this.d  this.e  vars(v) this.times this.n  this.t0  this.t1 }; end
                case 'n'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  this.b  this.d  this.e  this.g  this.times vars(v) this.t0  this.t1 }; end
                case 't0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  this.b  this.d  this.e  this.g  this.times this.n  vars(v)  this.t1 }; end
                case 't1'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.S0 this.a  this.b  this.d  this.e  this.g  this.times this.n  this.t0  vars(v) }; end
            end
            this.plotParArgs(par, args, vars);
        end
        function this = save(this)
            this = this.saveas('Laif2.save.mat');
        end
        function this = saveas(this, fn)     
            laif2 = this; %#ok<NASGU>
            save(fn, 'laif2');            
        end
    end
    
    %% PRIVATE
    
    methods (Access = 'private')
        function     plotParArgs(this, par, args, vars)
            assert(lstrfind(par, properties('mlperfusion.Laif2')));
            assert(iscell(args));
            assert(isnumeric(vars));
            import mlperfusion.*;
            figure
            hold on
            for v = 1:size(args,2)
                argsv = args{v};
                plot(this.times, ...
                    Laif0.magnetization( ...
                        argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, ...
                        argsv{6}, argsv{7}, argsv{8}, argsv{9}, argsv{10}, argsv{11}));
            end
            title(sprintf('F %g, S0 %g, a %g, b %g, d %g, e %g, g %g, n %g, t0 %g, t1 %g', ...
                          argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, ...
                          argsv{6}, argsv{7}, argsv{8}, argsv{10}, argsv{11}));
            legend(cellfun(@(x) sprintf('%s = %g', par, x), num2cell(vars), 'UniformOutput', false));
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

