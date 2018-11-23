classdef (Abstract) AbstractMRCurve < mlperfusion.IMRCurve 
	%% ABSTRACTMRCURVE   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 

    properties (Constant)
        CONTRAST_AGENT = 'gadobutrol'
    end    
    
	properties  		 
        dt = 1 % sec, for timeInterpolants
    end 
    
    properties (Dependent)
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        noclobber
         
        tracer
        length
        scanDuration % sec  
        dV % mL
        TR % sec
        times
        timeInterpolants
        conc
        concInterpolants
        header    
        
        taus
    end

    methods %% GET, SET 
        function f = get.filename(this)
            f = this.nifti_.filename;
        end
        function f = get.filepath(this)
            f = this.nifti_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.nifti_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.nifti_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.nifti_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.nifti_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.nifti_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.nifti_.fqfp;
        end
        function f = get.noclobber(this)
            f = this.nifti_.noclobber;
        end
        
        function id  = get.tracer(this)
            id = this.CONTRAST_AGENT;
        end
        function l    = get.length(this)
            assert(~isempty(this.nifti_));
            l = size(this.nifti_,4);
        end
        function sd   = get.scanDuration(this)
            assert(~isempty(this.times_));
            sd = this.times_(end);
        end
        function v = get.dV(this)
            %% GET.DV returns voxel volumes in mL
            
            v = prod(this.nifti_.mmppix(1:3))/1e3;
        end
        function t = get.TR(this)
            t = this.nifti_.pixdim(4);
        end
        function t    = get.times(this)
            assert(~isempty(this.times_));
            t = this.times_;
        end
        function this = set.times(this, t)
            assert(isnumeric(t));
            if (~isempty(this.conc_))
                assert(length(this.conc_) == length(t)); end
            this.times_ = t;
        end
        function t    = get.timeInterpolants(this)
            if (~isempty(this.timeInterpolants_))
                t = this.timeInterpolants_;
                return
            end
            assert(~isempty(this.times_));
            t = this.times_(1):this.dt:this.times_(end);
        end
        function this = set.timeInterpolants(this, t)
            assert(isnumeric(t));
            assert(this.uniformInterpolation(t));
            this.timeInterpolants_ = t;
            this.dt = t(2) - t(1);
        end
        function c    = get.conc(this)
            assert(~isempty(this.conc_));
            c = this.conc_;
        end
        function this = set.conc(this, c)
            assert(isnumeric(c));
            if (~isempty(this.times_))
                assert(length(this.times_) == length(c)); end
            this.conc_ = c;
        end
        function c    = get.concInterpolants(this)
            assert(~isempty(this.conc_));
            c = pchip(this.times_, this.conc_, this.timeInterpolants);
            c = c(1:length(this.timeInterpolants));
        end
        function h    = get.header(this)
            assert(~isempty(this.nifti_));
            h = this.nifti_;
        end
        function this = set.header(this, h)
            if (isa(h, 'mlfourd.INIfTI'))
                this.nifti_ = h; end            
        end        
        
        function t = get.taus(this)
            assert(~isempty(this.taus_));
            t = this.taus_;
        end
    end
    
	methods 		  
 		function this = AbstractMRCurve(fileLoc) 
 			%% ABSTRACTMRCURVE 
            %  Usage:  this = this@mlperfusion.AbstractMRCurve(file_location);

            this.nifti_ = mlfourd.NIfTI.load(fileLoc);
            this.times_ = 0:this.TR:this.TR*(this.length-1);
            this.taus_  = this.TR*ones(size(this.times_));
 		end 
        function this = saveas(this, fqfn)
            this.nifti_.fqfilename = fqfn;
            this.save;
        end
 	end 

    %% PROTECTED
    
    properties (Access = 'protected')        
        times_
        timeInterpolants_
        taus_
        conc_
        nifti_
    end    
    
    methods (Static, Access = 'protected')
        function tf = uniformInterpolation(t)
            tf = true;
            dt_ = t(2) - t(1);
            for tidx = 3:length(t)
                tf = tf && (dt_ == t(tidx) - t(tidx-1)); end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

