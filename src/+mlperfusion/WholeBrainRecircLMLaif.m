classdef WholeBrainRecircLMLaif < mlperfusion.IMRCurve & mlperfusion.ILaif  
	%% WHOLEBRAINRECIRCLMLAIF   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
    properties (Constant)
        EXTENSION = '.nii.gz'     
        TIMES_UNITS = 'sec'
        CONC_UNITS = 'arbitrary, from -log(M(t)/M0)'
    end    

	properties (Dependent) 	
        dt % sec  
        
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        noclobber
        
        tracer % char, e.g., 'gadobutrol'
        length % integer, number valid frames
        scanDuration % sec  
        dV % mL
        TR % sec
        times
        timeInterpolants
        conc
        concInterpolants
        header % cf. mlfourd.NIfTIInterface   
        
        S0_laif
        CBF_laif
        CBV_laif
        t0_laif
        alpha_laif
        beta_laif
        delta_laif
        gamma_laif
        eps_laif
        t1_laif
        nu_laif
    end 
    
    methods %% GET/SET
        
        function f = get.filename(this)
            f = this.perfusionIO_.filename;
        end
        function f = get.filepath(this)
            f = this.perfusionIO_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.perfusionIO_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.perfusionIO_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.perfusionIO_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.perfusionIO_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.perfusionIO_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.perfusionIO_.fqfp;
        end
        function f = get.noclobber(this)
            f = this.perfusionIO_.noclobber;
        end
        
        function id  = get.tracer(this)
            id = this.wholeBrainDSC_.tracer;
        end
        function l    = get.length(this)
            l = this.wholeBrainDSC_.length;
        end
        function sd   = get.scanDuration(this)
            sd = this.wholeBrainDSC_.scanDuration;
        end
        function v = get.dV(this)
            %% GET.DV returns voxel volumes in mL
            
            v = this.wholeBrainDSC_.dV;
        end
        function t = get.TR(this)
            t = this.wholeBrainDSC_.TR;
        end
        function t    = get.times(this)
            t = this.wholeBrainDSC_.times;
        end
        function this = set.times(this, t)
            this.wholeBrainDSC_.times = t;
        end
        function t    = get.timeInterpolants(this)
            t = this.wholeBrainDSC_.timeInterpolants;
        end
        function this = set.timeInterpolants(this, t)
            this.wholeBrainDSC_.timeInterpolants = t;
        end
        function c    = get.conc(this)
            c = this.wholeBrainDSC_.conc;
        end
        function this = set.conc(this, c)
            this.wholeBrainDSC_.conc = c;
        end
        function c    = get.concInterpolants(this)
            c = this.wholeBrainDSC_.concInterpolants;
        end
        function h    = get.header(this)
            h = this.perfusionIO_.contents;
        end
        
        
        function x = get.S0_laif(this)
            x = this.perfusionIO_.S0;
        end
        function x = get.CBF_laif(this)
            x = this.perfusionIO_.CBF/this.TR;
        end
        function x = get.CBV_laif(this)
            x = this.CBF_laif/this.delta_laif;
        end
        function x = get.t0_laif(this)
            x = this.perfusionIO_.t0*this.TR;
        end
        function x = get.alpha_laif(this)
            x = this.perfusionIO_.alpha;
        end
        function x = get.beta_laif(this)
            x = this.perfusionIO_.beta/this.TR;
        end
        function x = get.delta_laif(this)
            x = this.perfusionIO_.delta/this.TR;
        end
        function x = get.gamma_laif(this)
            x = this.perfusionIO_.gamma/this.TR;
        end
        function x = get.eps_laif(this)
            x = this.perfusionIO_.eps;
        end
        function x = get.t1_laif(this)
            try
                x = this.perfusionIO_.t1*this.TR;
            catch ME %#ok<NASGU>
                x = [];
            end
        end
        function x = get.nu_laif(this)
            try
                x = this.perfusionIO_.nu;
            catch ME %#ok<NASGU>
                x = [];
            end
        end
    end

    methods (Static)
        function this   = load(fname, varargin)
            %% LOAD
            %  Usage:   this = WholeBrainRecircLMLaif.load(perfusion4dfp_logfile[, parameter_name, parameter_value])
            
            this = mlperfusion.WholeBrainRecircLMLaif(fname, varargin{:});
        end 
    end
    
	methods 		  
 		function this = WholeBrainRecircLMLaif(perfLoc, wholeBrainDSC, varargin) 
 			%% WHOLEBRAINRECIRCLMLAIF 
 			%  Usage:  this = WholeBrainRecircLMLaif(perfusion4dfp_logfile, WholeBrainDSC_object[, parameter_name, parameter_value]) 
            
            p = inputParser;
            addRequired( p, 'perfLoc',       @(x) lexist(x, 'file'));
            addRequired( p, 'wholeBrainDSC', @(x) isa(x, 'mlperfusion.WholeBrainDSC'));
            parse(p, perfLoc, wholeBrainDSC, varargin{:});
            
            this.perfusionIO_ = mlperfusion.PerfusionRecircIO.load(p.Results.perfLoc);
            this.wholeBrainDSC_ = p.Results.wholeBrainDSC;
            this.conc = this.kConcentration;
        end       
        function m    = magnetization(this)
            m = this.S0_laif * exp(-this.CBF_laif*this.kConcentration);
        end
        function kC   = kConcentration(this)
            ti = this.times;
            kC = this.eps_laif * this.flowTerm(this.alpha_laif, this.beta_laif, this.delta_laif, ti, this.t0_laif) + ...
                 (1 - this.eps_laif) * this.steadyStateTerm(this.delta_laif, this.gamma_laif, ti, this.t0_laif);
        end     
        function m    = magnetization2(this)
            m = this.S0_laif * exp(-this.CBF_laif*this.kConcentration);
        end
        function kC   = kConcentration2(this)
            ti = this.times;
            kC = this.eps_laif * this.flowTerm(this.alpha_laif, this.beta_laif, this.delta_laif, ti, this.t0_laif) + ...
                 this.nu_laif  * this.flowTerm(this.alpha_laif, this.beta_laif, this.delta_laif, ti, this.t1_laif) + ...
                 (1 - this.eps_laif) * this.steadyStateTerm(this.delta_laif, this.gamma_laif, ti, this.t0_laif);
        end
        function conc = flowTerm(~, a, b, d, t, t0)
            b = max(b,d);
            d = min(b,d);
            conc0 = exp(-d*t) * b^(a+1) / (b-d)^(a+1);
            conc0 = conc0 .* gammainc((b - d)*t, a+1);
            
            idx_t0 = floor(t0) + 1;
            conc   = zeros(1, length(t));
            conc(idx_t0:end) = conc0(1:end-idx_t0+1);
        end
        function conc = steadyStateTerm(~, d, g, t, t0)
            conc0 = (1 - exp(-d*t))/d + ...
                    (exp(-g*t) - exp(-d*t))/(g - d);
            
            idx_t0 = floor(t0) + 1;
            conc   = zeros(1, length(t));
            conc(idx_t0:end) = conc0(1:end-idx_t0+1);
        end
        
        function saveas(~)
            error('mlperfusion:notImplemented', 'WholeBrainRecircLMLaif.saveas');
        end
        function save(~)
            error('mlperfusion:notImplemented', 'WholeBrainRecircLMLaif.save');
        end
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        wholeBrainDSC_
        perfusionIO_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

