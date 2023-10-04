
% cs h params
paramsCH_IS = struct( ...
    'atom', 'C', ...
    'cam', 'H', ...
    'wavelength', 852.347e-9, ...
    'pixel', 7.72e-6, ...
    'I_sat', Inf, ...
    'alpha', [1 0 0], ...
    'pcanum', 3, ...
    'view', [820 1060 215 275], ...
    'mask', [105 175 5 45], ...
    'fittype', 'gauss', ...
    'date', day);

paramsCH_RSC = paramsCH_IS;
paramsCH_RSC.view = [600 1200 400 1000];
paramsCH_RSC.mask = [40 560 40 560];

paramsCH_BEC = paramsCH_IS;
paramsCH_BEC.view = [900 1000 770 870];
paramsCH_BEC.mask = [20 80 20 80];

paramsCH_B = paramsCH_IS;
paramsCH_B.view = [825 1075 200 300];
paramsCH_B.mask = [5 245 20 80];
paramsCH_B.fittype = {'dbl', 'gauss'};

paramsCH_MOT = paramsCH_IS;
paramsCH_MOT.view = [300 1000 400 1000];
paramsCH_MOT.mask = [60 140 60 140];


% li h params
paramsLH_IS = paramsCH_IS;
paramsLH_IS.atom = 'L';
paramsLH_IS.wavelength = 670.977e-9;
paramsLH_IS.view = [910 1010 200 300];
paramsLH_IS.mask = [20 80 20 80];

paramsLH_MOT = paramsLH_IS;
paramsLH_IS.view = [770 1170 50 450];
paramsLH_IS.mask = [20 380 20 380];


% cs v params
paramsCV_IS = struct( ...
    'atom', 'C', ...
    'cam', 'V',...
    'wavelength', paramsCH_IS.wavelength, ...
    'pixel', 0.78e-6, ...
    'I_sat', 125, ...
    'alpha', [1.23 0.19 0.0051], ...
    'pcanum', 20, ...
    'view', [10 50 475 755], ...
    'mask', [11 31 31 251], ...
    'fittype', 'gauss', ...
    'date', day);


% li v params
paramsLV_IS = struct( ...
    'atom', 'L', ...
    'cam', 'V', ...
    'wavelength', paramsLH_IS.wavelength, ...
    'pixel', paramsCV_IS.pixel, ...
    'I_sat', 125, ...
    'alpha', [1 0 0], ...
    'pcanum', 20, ...
    'view', [1 80 325 875], ...
    'mask', [10 55 76 451], ...
    'fittype', 'gauss', ...
    'date', day);
