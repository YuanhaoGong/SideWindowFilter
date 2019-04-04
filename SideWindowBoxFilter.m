function result=SideWindowBoxFilter(im, radius, iteration)
%papers: 1) Sub-window Box Filter, Y.Gong, B.Liu, X.Hou, G.Qiu, VCIP2018, Dec.09, Taiwan
%        2) Side Window Filtering, H.Yin, Y.Gong, G.Qiu. CVPR2019
%implemented by Yuanhao Gong

r = radius; 
k = ones(2*r+1,1)/(2*r+1); %separable kernel 
k_L=k; k_L(r+2:end)=0; k_L = k_L/sum(k_L); %half kernel
k_R=flipud(k_L); 
m = size(im,1)+2*r; n = size(im,2)+2*r; total = m*n;
[row, col]=ndgrid(1:m,1:n); 
offset = row + m*(col-1) - total;
im = single(im); 
result = im; 
d = zeros(m,n,8,'single'); 

for ch=1:size(im,3)
    U = padarray(im(:,:,ch),[r,r],'replicate'); 
    for i = 1:iteration
        %all projection distances
        d(:,:,1) = conv2(k_L, k_L, U,'same') - U; 
        d(:,:,2) = conv2(k_L, k_R, U,'same') - U;
        d(:,:,3) = conv2(k_R, k_L, U,'same') - U; 
        d(:,:,4) = conv2(k_R, k_R, U,'same') - U;
        d(:,:,5) = conv2(k_L, k, U,'same') - U; 
        d(:,:,6) = conv2(k_R, k, U,'same') - U;
        d(:,:,7) = conv2(k, k_L, U,'same') - U; 
        d(:,:,8) = conv2(k, k_R, U,'same') - U;
        
        %find the minimal signed distance
        tmp = abs(d); 
        [~,ind] = min(tmp,[],3); 
        index = offset+total*ind;
        dm = d(index); %signed minimal distance
        %update
        U = U + dm; 
    end
    result(:,:,ch) = U(r+1:end-r,r+1:end-r);
end
