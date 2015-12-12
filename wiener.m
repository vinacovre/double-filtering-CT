 function filtrada = wiener(imgG,jan,dominio)
%FILTRO_DE_WIENER filtragem pr� ou p�s reconstru��o da imagem
%
%       O primeiro par�metro � o sinograma das proje��es ruidosas, no caso
%   do uso do wiener para pr�-reconstru��o. Ao abrir um arquivo .mat no
%   Matlab, uma vari�vel 'sinogram' � criada contendo o sinograma das
%   proje��es descritas nesse arquivo.
%       Para o caso do uso desse filtro para p�s-reconstru��o, o primeiro
%   par�metro � a imagem reconstru�da.
%
%       O par�metro pre_pos indica se o uso do filtro de wiener � para a
%   filtragem pr� ou p�s reconstru��o dos dados de proje��o.
%
%       O par�metro 'dominio' costuma ser 'ansc', pela filtragem ser  no
%   dom�nio de Anscombe, uma vez que o filtro de Wiener trata de ru�do
%   aditivo. Mas essa observa��o s� � v�lida caso a filtragem seja
%   pr�-reconstu��o dos dados de proje��o

%l (linhas) recebe a quantidade (tamanho) de linhas da vari�vel
%'sinogram'. Do mesmo modo para c (colunas).

if nargin > 3 || nargin < 1
    error('N�mero inv�lido de argumentos de entrada!');
    pause
elseif nargin == 1
    jan = 5;
    dominio = 'ansc';
else
    dominio = 'ansc';
end

mean_filt = fspecial('average', [1 jan]);
imgF = imfilter(imgG, mean_filt);

alfa = 1; %padr�o fora do dom�nio de anscombe: 0.85

imgG = noise_transform(imgG,'ansc');

[l,c]=size(imgG);
d = floor(jan/2); %d = deslocamento

% % mean_filt = fspecial('average', [1 jan]);
% % imgF = imfilter(imgG, mean_filt);

for k=1 : l
    imgF(k,:) = medida_sinal(imgG(k,:),'media',jan);
end
clear k;

% M = max(imgG(:));
% m = min(imgG(:));
% imgG = ((imgG-m)/(M-m))*255;
%
% M_ = max(imgF(:));
% m_ = min(imgF(:));
% imgF = ((imgF-m_)/(M_-m_))*255;

% M = max(M,M_);
% m = min(m,m_);

%C�LCULO DAS M�DIAS POR MEDIDA_SINAL
for k=1 : l
    mf(k,:) = medida_sinal(imgF(k,:),'media',jan);
end
clear k;
for k=1 : l
    mg(k,:) = medida_sinal(imgG(k,:),'media',jan);
end
%FIM DESSE C�LCULO

vr = 1; %variancia do ruido == 1 para trans ansc
ac_vf = zeros(l,c); %ac_vf = acumulador para a vari�ncia da imagem filtrada
ac_gKL = zeros(l,c);

i = 0;
for j = -d : d
    deslocadaF = circshift(imgF, [i j]);
    dif_vf = (deslocadaF - mf).^2;
    ac_vf = ac_vf + dif_vf;
    
    deslocadaG = circshift(imgG, [i j]);
    if (i==0 && j==0)
        continue;
    end
    dif_gKL = (deslocadaG - mg);
    ac_gKL = ac_gKL + dif_gKL;
end

clear i
for i=1 : l
    vf = medida_sinal(imgF(i,:),'variancia',jan); % n = jan*jan (f�rmula da vari�ncia)
    %Equa��o 5.13 da tese do Denis:
    filtrada(i,:) = mf(i,:) + (vf./(vf+vr)).*((alfa*(imgG(i,:)-mf(i,:))) + ((1-alfa)*ac_gKL(i,:)));
    % % filtrada = ((filtrada-min(filtrada(:)))/(max(filtrada(:))-min(filtrada(:))))*255;
    % filtrada = filtrada * (M-m)/255 + m;
end
filtrada = noise_transform(filtrada,'ansc_inverse');
end