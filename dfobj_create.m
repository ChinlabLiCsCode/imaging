function dfobj = dfobj_create(dfimgs, mask, pcanum)

% copy of cvpcreatedefringeset

% if nargin < 4
%     pca_number = Inf;
% end
% 
% if numel(size(in_file_range)) == 3
%     imagestack = in_file_range;
% else
%     if nargin < 6
%         exp_date = clock();
%         if nargin < 5 || numel(region) < 4
%             region = 1;
%         end
%     end
%     imagestack = cvploadimagestack(in_file_range,region,exp_date);
%     imagestack = squeeze(imagestack(:,:,:,shot_number(1))-imagestack(:,:,:,shot_number(2)));
% end
% 
% imagestack = real(log(imagestack));
% imagestack(~isfinite(imagestack)) = 0;
% orig_size = size(imagestack);
% imagestack(end+1,:,:) = ones(orig_size(2:3));
% orig_size = size(imagestack);
% 
% if pca_number > orig_size(1)
%     pca_number = orig_size(1);
% end
% 
% if size(mask,1) < 2
%     mask_x = zeros(orig_size(2:3));
%     mask_y = mask_x;
%     mask_x(mask(3):mask(4),:) = 1;
%     mask_y(:,mask(1):mask(2)) = 1;
%     mask = mask_x.*mask_y;
%     mask = ~mask;
% end
% 
% full_size = orig_size(2)*orig_size(3);
% imagestack = reshape(imagestack,[orig_size(1) full_size]);
% big_sparse = spdiags(mask(:), 0, full_size, full_size);
% cov_matrix = (imagestack)*big_sparse*(imagestack');
% [V, D] = eig(cov_matrix);
% [sortD, sort_order] = sort(diag(D),'descend');
% sortV = V(:,sort_order(1:pca_number));
% sortD = sortD(1:pca_number);
% sortV = sortV*diag(1./sqrt(sortD));
% 
% out_struct.out_vecs = (sortV')*imagestack;
% out_struct.sp_mask = big_sparse;


% this just is too confusing for me. going to copy paper. 

sz = size(dfimgs);
mask_x = zeros(sz(2:3));
mask_y = mask_x;
mask_x(mask(3):mask(4),:) = 1;
mask_y(:,mask(1):mask(2)) = 1;
mask = mask_x.*mask_y;
mask = ~mask;

npix = orig_size(2)*orig_size(3); % number of pixels per image
mask = reshape(mask, npix); % reshape mask to be column vec
maskmat = spdiags(mask, 0, npix, npix);
fullvecs = reshape(imagestack, [sz(1) npix]); % reshape image to be column vecs (R_i in the paper)
edgevecs = fullvecs(:, mask); % reshape edge pixels to be column vecs (u_i in the paper)
covmat = edgevecs * edgevecs'; % make covariance matrix (S in the paper)
[V,D] = eig(A); % find eigensystem
[eigvals, order] = sort(diag(D),'descend'); % sort eigenvals
eigvecs = V(:, order(1:pcanum)); % get first pcanum of eigvecs (v_i in the paper)
eigvals = eigvals(:, 1:pcanum); % get first pcanum of eigvals
eigvecs = eigvecs * diag(1./sqrt(eigvals)); % maybe this is some kind of normalization? 
fulleigvecs = (eigvecs') * fullvecs; % probably like P_j in the paper? 

dfobj = struct('maskmat', maskmat, 'fulleigvecs', fulleigvecs);