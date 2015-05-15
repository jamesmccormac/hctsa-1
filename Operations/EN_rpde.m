% ------------------------------------------------------------------------------
% EN_rpde
% ------------------------------------------------------------------------------
% Performs fast recurrence period density entropy (RPDE) analysis on an input
% signal to obtain an estimate of the H_norm value and other related statistics.
% 
% Based on Max Little's code rpde (see below)
%
%---USAGE:
% [H_norm, rpd] = rpde(x, m, tau)
% [H_norm, rpd] = rpde(x, m, tau, epsilon)
% [H_norm, rpd] = rpde(x, m, tau, epsilon, T_max)
% 
%---INPUTS:
%    x       - input signal: must be a row vector
%    m       - embedding dimension
%    tau     - embedding time delay
%    
%---OPTIONAL INPUTS:
%    epsilon - recurrence neighbourhood radius
%              (If not specified, then a suitable value is chosen automatically)
%    T_max   - maximum recurrence time
%              (If not specified, then all recurrence times are returned)
%---OUTPUTS:
%    H_norm  - Estimated RPDE value
%    rpd     - Estimated recurrence period density
% 
% ------------------------------------------------------------------------------
% (c) 2007 Max Little.
% ------------------------------------------------------------------------------
% If you use this code, please cite:
% Exploiting Nonlinear Recurrence and Fractal Scaling Properties for Voice
% Disorder Detection
% M. Little, P. McSharry, S. Roberts, D. Costello, I. Moroz (2007),
% BioMedical Engineering OnLine 2007, 6:23
% ------------------------------------------------------------------------------
% Minor tweaks and additional outputs added by Ben Fulcher, 2015-05-15, for use
% with the hctsa package
% ------------------------------------------------------------------------------

function out = EN_rpde(x, m, tau, epsilon, T_max)

% ------------------------------------------------------------------------------
% Check inputs and set defaults
% ------------------------------------------------------------------------------
if nargin < 2 || isempty(m)
    m = 2;
end
if nargin < 3 || isempty(tau)
    tau = 1;
end

% Specified a way of determining m and/or tau, use BF_embed to estimate:
if ischar(tau) || ischar(m)
    tauAndM = BF_embed(x,tau,m,2);
    tau = tauAndM(1);
    m = tauAndM(2);
end

if (nargin < 4)
    epsilon = 0.12;
end

if (nargin < 5)
    T_max = -1;
end

if (nargin > 5)
    help rpde;
    return
end
% ------------------------------------------------------------------------------

% Compute the rpd using C code:
rpd = ML_close_ret(x, m, tau, epsilon);

if (T_max > -1)
    rpd = rpd(1:T_max);
end
rpd = rpd/sum(rpd);

N = length(rpd);

% Matrix version of commented out code below:
ip = (rpd > 0); % is positive
H = -sum(rpd(ip).*log(rpd(ip)));
% H = 0;
% for j = 1:N
%    H = H - rpd(j) * logz(rpd(j));
% end

H_norm = H/log(N); % log(N) is the H for an iid process

% ------------------------------------------------------------------------------
% Make outputs for hctsa:
% ------------------------------------------------------------------------------

% Entropy and normalized entropy:
out.H = H;
out.H_norm = H_norm;

% proportion of non-zero entries:
out.propNonZero = mean(rpd>0); % proportion of rpds that are non-zero
out.meanNonZero = mean(rpd(rpd>0))*N; % mean value when rpd is non-zero (rescale by N)
out.maxRPD = max(rpd)*N; % maximum value of rpd (rescale by N)

% % ------------------------------------------------------------------------------
% function y = logz(x)
% if (x > 0)
%    y = log(x);
% else
%    y = 0;
% end
% % ------------------------------------------------------------------------------

end